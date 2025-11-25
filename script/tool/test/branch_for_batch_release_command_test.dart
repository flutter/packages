// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:args/command_runner.dart';
import 'package:file/file.dart';
import 'package:flutter_plugin_tools/src/branch_for_batch_release_command.dart';
import 'package:flutter_plugin_tools/src/common/core.dart';
import 'package:git/git.dart';
import 'package:test/test.dart';

import 'mocks.dart';

import 'util.dart';

void main() {
  late MockPlatform mockPlatform;
  late Directory packagesDir;
  late RecordingProcessRunner processRunner;
  late RecordingProcessRunner gitProcessRunner;
  late CommandRunner<void> runner;

  void createPendingChangelogFile(
    RepositoryPackage package,
    String name,
    String content,
  ) {
    final File pendingChangelog =
        package.directory.childDirectory('pending_changelogs').childFile(name)
          ..createSync(recursive: true);
    pendingChangelog.writeAsStringSync(content);
  }

  Future<List<String>> runBatchCommand({
    void Function(Error error)? errorHandler,
  }) => runCapturingPrint(runner, <String>[
    'branch-for-batch-release',
    '--packages=a_package',
    '--branch=release-branch',
    '--remote=origin',
  ], errorHandler: errorHandler);

  RepositoryPackage createTestPackage() {
    final RepositoryPackage package = createFakePackage(
      'a_package',
      packagesDir,
    );

    package.changelogFile.writeAsStringSync('''
## 1.0.0

- Old changes
''');
    package.pubspecFile.writeAsStringSync('''
name: a_package
version: 1.0.0
''');
    package.directory.childDirectory('pending_changelogs').createSync();
    return package;
  }

  const expectedGitCallsForABFiles = <ProcessCall>[
    ProcessCall('git-checkout', <String>['-b', 'release-branch'], null),
    ProcessCall('git-rm', <String>[
      '/packages/a_package/pending_changelogs/a.yaml',
      '/packages/a_package/pending_changelogs/b.yaml',
    ], null),
    ProcessCall('git-add', <String>[
      '/packages/a_package/pubspec.yaml',
      '/packages/a_package/CHANGELOG.md',
    ], null),
    ProcessCall('git-commit', <String>[
      '-m',
      '[a_package] Prepare for batch release',
    ], null),
    ProcessCall('git-push', <String>['origin', 'release-branch'], null),
  ];
  const expectedGitCallsForAFiles = <ProcessCall>[
    ProcessCall('git-checkout', <String>['-b', 'release-branch'], null),
    ProcessCall('git-rm', <String>[
      '/packages/a_package/pending_changelogs/a.yaml',
    ], null),
    ProcessCall('git-add', <String>[
      '/packages/a_package/pubspec.yaml',
      '/packages/a_package/CHANGELOG.md',
    ], null),
    ProcessCall('git-commit', <String>[
      '-m',
      '[a_package] Prepare for batch release',
    ], null),
    ProcessCall('git-push', <String>['origin', 'release-branch'], null),
  ];

  setUp(() {
    mockPlatform = MockPlatform();
    final GitDir gitDir;
    (:packagesDir, :processRunner, :gitProcessRunner, :gitDir) =
        configureBaseCommandMocks(platform: mockPlatform);
    final command = BranchForBatchReleaseCommand(
      packagesDir,
      processRunner: processRunner,
      gitDir: gitDir,
      platform: mockPlatform,
    );
    runner = CommandRunner<void>(
      'branch_for_batch_release_command',
      'Test for branch_for_batch_release_command',
    );
    runner.addCommand(command);
  });

  group('happy path', () {
    test('can bump minor', () async {
      final RepositoryPackage package = createTestPackage();
      addTearDown(() {
        package.directory.deleteSync(recursive: true);
      });
      createPendingChangelogFile(package, 'a.yaml', '''
changelog: A new feature
version: minor
''');

      final List<String> output = await runBatchCommand();

      expect(
        output,
        containsAllInOrder(<String>[
          'Parsing package "a_package"...',
          '  Creating new branch "release-branch"...',
          '  Pushing branch release-branch to remote origin...',
        ]),
      );

      expect(
        package.pubspecFile.readAsStringSync(),
        contains('version: 1.1.0'),
      );
      final String changelogContent = package.changelogFile.readAsStringSync();
      expect(changelogContent, startsWith('## 1.1.0'));
      expect(changelogContent, contains('A new feature'));
      expect(
        gitProcessRunner.recordedCalls,
        orderedEquals(expectedGitCallsForAFiles),
      );
    });

    test('can bump major', () async {
      final RepositoryPackage package = createTestPackage();
      addTearDown(() {
        package.directory.deleteSync(recursive: true);
      });
      createPendingChangelogFile(package, 'a.yaml', '''
changelog: A new feature
version: major
''');

      final List<String> output = await runBatchCommand();

      expect(
        output,
        containsAllInOrder(<String>[
          'Parsing package "a_package"...',
          '  Creating new branch "release-branch"...',
          '  Pushing branch release-branch to remote origin...',
        ]),
      );

      expect(
        package.pubspecFile.readAsStringSync(),
        contains('version: 2.0.0'),
      );
      final String changelogContent = package.changelogFile.readAsStringSync();
      expect(changelogContent, startsWith('## 2.0.0'));
      expect(changelogContent, contains('A new feature'));
      expect(
        gitProcessRunner.recordedCalls,
        orderedEquals(expectedGitCallsForAFiles),
      );
    });

    test('can bump patch', () async {
      final RepositoryPackage package = createTestPackage();
      addTearDown(() {
        package.directory.deleteSync(recursive: true);
      });
      createPendingChangelogFile(package, 'a.yaml', '''
changelog: A new feature
version: patch
''');

      final List<String> output = await runBatchCommand();

      expect(
        output,
        containsAllInOrder(<String>[
          'Parsing package "a_package"...',
          '  Creating new branch "release-branch"...',
          '  Pushing branch release-branch to remote origin...',
        ]),
      );

      expect(
        package.pubspecFile.readAsStringSync(),
        contains('version: 1.0.1'),
      );
      final String changelogContent = package.changelogFile.readAsStringSync();
      expect(changelogContent, startsWith('## 1.0.1'));
      expect(changelogContent, contains('A new feature'));
      expect(
        gitProcessRunner.recordedCalls,
        orderedEquals(expectedGitCallsForAFiles),
      );
    });

    test('merges multiple changelogs, minor and major', () async {
      final RepositoryPackage package = createTestPackage();
      addTearDown(() {
        package.directory.deleteSync(recursive: true);
      });
      createPendingChangelogFile(package, 'a.yaml', '''
changelog: A new feature
version: minor
''');
      createPendingChangelogFile(package, 'b.yaml', '''
changelog: A breaking change
version: major
''');

      final List<String> output = await runBatchCommand();

      expect(
        output,
        containsAllInOrder(<String>[
          'Parsing package "a_package"...',
          '  Creating new branch "release-branch"...',
          '  Pushing branch release-branch to remote origin...',
        ]),
      );

      expect(
        package.pubspecFile.readAsStringSync(),
        contains('version: 2.0.0'),
      );
      final String changelogContent = package.changelogFile.readAsStringSync();
      expect(changelogContent, startsWith('## 2.0.0'));
      expect(changelogContent, contains('A new feature'));
      expect(changelogContent, contains('A breaking change'));
      expect(
        gitProcessRunner.recordedCalls,
        orderedEquals(expectedGitCallsForABFiles),
      );
    });

    test('merges multiple changelogs, minor and patch', () async {
      final RepositoryPackage package = createTestPackage();
      addTearDown(() {
        package.directory.deleteSync(recursive: true);
      });
      createPendingChangelogFile(package, 'a.yaml', '''
changelog: A new feature
version: minor
''');
      createPendingChangelogFile(package, 'b.yaml', '''
changelog: A bug fix
version: patch
''');

      final List<String> output = await runBatchCommand();

      expect(
        output,
        containsAllInOrder(<String>[
          'Parsing package "a_package"...',
          '  Creating new branch "release-branch"...',
          '  Pushing branch release-branch to remote origin...',
        ]),
      );

      expect(
        package.pubspecFile.readAsStringSync(),
        contains('version: 1.1.0'),
      );
      final String changelogContent = package.changelogFile.readAsStringSync();
      expect(changelogContent, startsWith('## 1.1.0'));
      expect(changelogContent, contains('A new feature'));
      expect(changelogContent, contains('A bug fix'));
      expect(
        gitProcessRunner.recordedCalls,
        orderedEquals(expectedGitCallsForABFiles),
      );
    });

    test('merges multiple changelogs, major and patch', () async {
      final RepositoryPackage package = createTestPackage();
      addTearDown(() {
        package.directory.deleteSync(recursive: true);
      });
      createPendingChangelogFile(package, 'a.yaml', '''
changelog: A breaking change
version: major
''');
      createPendingChangelogFile(package, 'b.yaml', '''
changelog: A bug fix
version: patch
''');

      final List<String> output = await runBatchCommand();

      expect(
        output,
        containsAllInOrder(<String>[
          'Parsing package "a_package"...',
          '  Creating new branch "release-branch"...',
          '  Pushing branch release-branch to remote origin...',
        ]),
      );

      expect(
        package.pubspecFile.readAsStringSync(),
        contains('version: 2.0.0'),
      );
      final String changelogContent = package.changelogFile.readAsStringSync();
      expect(changelogContent, startsWith('## 2.0.0'));
      expect(changelogContent, contains('A breaking change'));
      expect(changelogContent, contains('A bug fix'));
      expect(
        gitProcessRunner.recordedCalls,
        orderedEquals(expectedGitCallsForABFiles),
      );
    });

    test('merges multiple changelogs, minor, major and patch', () async {
      final RepositoryPackage package = createTestPackage();
      addTearDown(() {
        package.directory.deleteSync(recursive: true);
      });
      createPendingChangelogFile(package, 'a.yaml', '''
changelog: A new feature
version: minor
''');
      createPendingChangelogFile(package, 'b.yaml', '''
changelog: A breaking change
version: major
''');
      createPendingChangelogFile(package, 'c.yaml', '''
changelog: A bug fix
version: patch
''');

      final List<String> output = await runBatchCommand();

      expect(
        output,
        containsAllInOrder(<String>[
          'Parsing package "a_package"...',
          '  Creating new branch "release-branch"...',
          '  Pushing branch release-branch to remote origin...',
        ]),
      );

      expect(
        package.pubspecFile.readAsStringSync(),
        contains('version: 2.0.0'),
      );
      final String changelogContent = package.changelogFile.readAsStringSync();
      expect(changelogContent, startsWith('## 2.0.0'));
      expect(changelogContent, contains('A new feature'));
      expect(changelogContent, contains('A breaking change'));
      expect(changelogContent, contains('A bug fix'));
      expect(
        gitProcessRunner.recordedCalls,
        orderedEquals(<ProcessCall>[
          const ProcessCall('git-checkout', <String>[
            '-b',
            'release-branch',
          ], null),
          const ProcessCall('git-rm', <String>[
            '/packages/a_package/pending_changelogs/a.yaml',
            '/packages/a_package/pending_changelogs/b.yaml',
            '/packages/a_package/pending_changelogs/c.yaml',
          ], null),
          const ProcessCall('git-add', <String>[
            '/packages/a_package/pubspec.yaml',
            '/packages/a_package/CHANGELOG.md',
          ], null),
          const ProcessCall('git-commit', <String>[
            '-m',
            '[a_package] Prepare for batch release',
          ], null),
          const ProcessCall('git-push', <String>[
            'origin',
            'release-branch',
          ], null),
        ]),
      );
    });

    test('merges multiple changelogs with same version', () async {
      final RepositoryPackage package = createTestPackage();
      addTearDown(() {
        package.directory.deleteSync(recursive: true);
      });
      createPendingChangelogFile(package, 'a.yaml', '''
changelog: A new feature
version: minor
''');
      createPendingChangelogFile(package, 'b.yaml', '''
changelog: Another new feature
version: minor
''');

      final List<String> output = await runBatchCommand();

      expect(
        output,
        containsAllInOrder(<String>[
          'Parsing package "a_package"...',
          '  Creating new branch "release-branch"...',
          '  Pushing branch release-branch to remote origin...',
        ]),
      );

      expect(
        package.pubspecFile.readAsStringSync(),
        contains('version: 1.1.0'),
      );
      final String changelogContent = package.changelogFile.readAsStringSync();
      expect(changelogContent, startsWith('## 1.1.0'));
      expect(changelogContent, contains('A new feature'));
      expect(changelogContent, contains('Another new feature'));
      expect(
        gitProcessRunner.recordedCalls,
        orderedEquals(expectedGitCallsForABFiles),
      );
    });

    test('mix of skip and other version changes', () async {
      final RepositoryPackage package = createTestPackage();
      addTearDown(() {
        package.directory.deleteSync(recursive: true);
      });
      createPendingChangelogFile(package, 'a.yaml', '''
changelog: A new feature
version: minor
''');
      createPendingChangelogFile(package, 'b.yaml', '''
changelog: A documentation update
version: skip
''');

      final List<String> output = await runBatchCommand();

      expect(
        output,
        containsAllInOrder(<String>[
          'Parsing package "a_package"...',
          '  Creating new branch "release-branch"...',
          '  Pushing branch release-branch to remote origin...',
        ]),
      );

      expect(
        package.pubspecFile.readAsStringSync(),
        contains('version: 1.1.0'),
      );
      final String changelogContent = package.changelogFile.readAsStringSync();
      expect(changelogContent, startsWith('## 1.1.0'));
      expect(changelogContent, contains('A new feature'));
      expect(changelogContent, contains('A documentation update'));
      expect(
        gitProcessRunner.recordedCalls,
        orderedEquals(expectedGitCallsForABFiles),
      );
    });

    test('skips version update', () async {
      final RepositoryPackage package = createTestPackage();
      addTearDown(() {
        package.directory.deleteSync(recursive: true);
      });
      createPendingChangelogFile(package, 'a.yaml', '''
changelog: A new feature
version: skip
''');

      final List<String> output = await runBatchCommand();

      expect(
        output,
        containsAllInOrder(<String>[
          'Parsing package "a_package"...',
          'No version change specified in pending changelogs for a_package.',
        ]),
      );
      expect(
        package.pubspecFile.readAsStringSync(),
        contains('version: 1.0.0'),
      );
      expect(package.changelogFile.readAsStringSync(), startsWith('## 1.0.0'));
      expect(gitProcessRunner.recordedCalls, orderedEquals(<ProcessCall>[]));
    });

    test('handles no changelog files', () async {
      final RepositoryPackage package = createTestPackage();
      addTearDown(() {
        package.directory.deleteSync(recursive: true);
      });
      final List<String> output = await runBatchCommand();

      expect(
        output,
        containsAllInOrder(<String>[
          'Parsing package "a_package"...',
          'No pending changelogs found for a_package.',
        ]),
      );
      expect(
        package.pubspecFile.readAsStringSync(),
        contains('version: 1.0.0'),
      );
      expect(package.changelogFile.readAsStringSync(), startsWith('## 1.0.0'));
      expect(gitProcessRunner.recordedCalls, orderedEquals(<ProcessCall>[]));
    });

    test('replaces ## NEXT with new version', () async {
      final RepositoryPackage package = createTestPackage();
      addTearDown(() {
        package.directory.deleteSync(recursive: true);
      });
      // Overwrite changelog to have ## NEXT
      package.changelogFile.writeAsStringSync('''
## NEXT

- Existing unreleased change
''');

      createPendingChangelogFile(package, 'a.yaml', '''
changelog: A new feature
version: minor
''');

      final List<String> output = await runBatchCommand();

      expect(
        output,
        containsAllInOrder(<String>[
          'Parsing package "a_package"...',
          '  Creating new branch "release-branch"...',
        ]),
      );

      final String changelogContent = package.changelogFile.readAsStringSync();
      expect(changelogContent, '''
## 1.1.0

A new feature
- Existing unreleased change
''');
    });
  });

  group('error handling', () {
    test('throw when git-checkout fails', () async {
      final RepositoryPackage package = createTestPackage();
      addTearDown(() {
        package.directory.deleteSync(recursive: true);
      });
      createPendingChangelogFile(package, 'a.yaml', '''
changelog: A new feature
version: major
''');
      gitProcessRunner.mockProcessesForExecutable['git-checkout'] =
          <FakeProcessInfo>[
            FakeProcessInfo(MockProcess(stderr: 'error', exitCode: 1)),
          ];
      final List<String> output = await runBatchCommand(
        errorHandler: (Error e) {
          expect(e, isA<ToolExit>());
          expect((e as ToolExit).exitCode, 4);
        },
      );

      expect(
        output.last,
        contains('Failed to create branch release-branch: error'),
      );
    });

    test('throw when git-rm fails', () async {
      final RepositoryPackage package = createTestPackage();
      addTearDown(() {
        package.directory.deleteSync(recursive: true);
      });
      createPendingChangelogFile(package, 'a.yaml', '''
changelog: A new feature
version: major
''');
      gitProcessRunner.mockProcessesForExecutable['git-rm'] = <FakeProcessInfo>[
        FakeProcessInfo(MockProcess(stderr: 'error', exitCode: 1)),
      ];
      final List<String> output = await runBatchCommand(
        errorHandler: (Error e) {
          expect(e, isA<ToolExit>());
          expect((e as ToolExit).exitCode, 4);
        },
      );

      expect(
        output.last,
        contains(
          'Failed to rm /packages/a_package/pending_changelogs/a.yaml: error',
        ),
      );
    });

    test('throw when git-add fails', () async {
      final RepositoryPackage package = createTestPackage();
      addTearDown(() {
        package.directory.deleteSync(recursive: true);
      });
      createPendingChangelogFile(package, 'a.yaml', '''
changelog: A new feature
version: major
''');
      gitProcessRunner.mockProcessesForExecutable['git-add'] =
          <FakeProcessInfo>[
            FakeProcessInfo(MockProcess(stderr: 'error', exitCode: 1)),
          ];
      final List<String> output = await runBatchCommand(
        errorHandler: (Error e) {
          expect(e, isA<ToolExit>());
          expect((e as ToolExit).exitCode, 4);
        },
      );

      expect(output.last, contains('Failed to git add: error'));
    });

    test('throw when git-commit fails', () async {
      final RepositoryPackage package = createTestPackage();
      addTearDown(() {
        package.directory.deleteSync(recursive: true);
      });
      createPendingChangelogFile(package, 'a.yaml', '''
changelog: A new feature
version: major
''');
      gitProcessRunner.mockProcessesForExecutable['git-commit'] =
          <FakeProcessInfo>[
            FakeProcessInfo(MockProcess(stderr: 'error', exitCode: 1)),
          ];
      final List<String> output = await runBatchCommand(
        errorHandler: (Error e) {
          expect(e, isA<ToolExit>());
          expect((e as ToolExit).exitCode, 4);
        },
      );

      expect(output.last, contains('Failed to commit: error'));
    });

    test('throw when git-push fails', () async {
      final RepositoryPackage package = createTestPackage();
      addTearDown(() {
        package.directory.deleteSync(recursive: true);
      });
      createPendingChangelogFile(package, 'a.yaml', '''
changelog: A new feature
version: major
''');
      gitProcessRunner.mockProcessesForExecutable['git-push'] =
          <FakeProcessInfo>[
            FakeProcessInfo(MockProcess(stderr: 'error', exitCode: 1)),
          ];
      final List<String> output = await runBatchCommand(
        errorHandler: (Error e) {
          expect(e, isA<ToolExit>());
          expect((e as ToolExit).exitCode, 4);
        },
      );

      expect(output.last, contains('Failed to push to release-branch: error'));
    });

    test('throws for pre-1.0.0 packages', () async {
      final RepositoryPackage package = createFakePackage(
        'a_package',
        packagesDir,
      );

      addTearDown(() {
        package.directory.deleteSync(recursive: true);
      });

      // Set a pre-1.0.0 version.
      package.changelogFile.writeAsStringSync('''
## 0.5.0

- Old changes
''');
      package.pubspecFile.writeAsStringSync('''
name: a_package
version: 0.5.0
''');
      package.directory.childDirectory('pending_changelogs').createSync();
      createPendingChangelogFile(package, 'a.yaml', '''
changelog: A new feature
version: minor
''');

      final List<String> output = await runBatchCommand(
        errorHandler: (Error e) {
          expect(e, isA<ToolExit>());
          expect((e as ToolExit).exitCode, 3);
        },
      );

      expect(
        output.last,
        contains(
          'This script only supports packages with version >= 1.0.0. Current version: 0.5.0.',
        ),
      );
    });
  });
}
