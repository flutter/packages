// Copyright 2013 The Flutter Authors. All rights reserved.
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
  late RepositoryPackage package;

  // A helper function to create a changelog file with the given content.
  void createChangelogFile(String name, String content) {
    final File pendingChangelog = package.directory
        .childDirectory('pending_changelogs')
        .childFile(name)
      ..createSync(recursive: true);
    pendingChangelog.writeAsStringSync(content);
  }

  setUp(() {
    mockPlatform = MockPlatform();
    final GitDir gitDir;
    (:packagesDir, :processRunner, :gitProcessRunner, :gitDir) =
        configureBaseCommandMocks(platform: mockPlatform);
    final BranchForBatchReleaseCommand command = BranchForBatchReleaseCommand(
      packagesDir,
      processRunner: processRunner,
      gitDir: gitDir,
      platform: mockPlatform,
    );
    runner = CommandRunner<void>('branch_for_batch_release_command',
        'Test for branch_for_batch_release_command');
    runner.addCommand(command);
    package = createFakePackage('a_package', packagesDir);

    package.changelogFile.writeAsStringSync('''
## 1.0.0

- Old changes
''');
    package.pubspecFile.writeAsStringSync('''
name: a_package
version: 1.0.0
''');
    package.directory.childDirectory('pending_changelogs').createSync();
  });

  tearDown(() {
    package.directory.deleteSync(recursive: true);
  });

  Future<void> testReleaseBranch({
    required Map<String, String> changelogs,
    required List<String> expectedOutput,
    String? expectedVersion,
    List<String> expectedChangelogSnippets = const <String>[],
  }) async {
    for (final MapEntry<String, String> entry in changelogs.entries) {
      createChangelogFile(entry.key, entry.value);
    }

    final List<String> output = await runCapturingPrint(runner, <String>[
      'branch-for-batch-release',
      '--packages=a_package',
      '--branch=release-branch',
    ]);

    expect(output, containsAllInOrder(expectedOutput));

    if (expectedVersion != null) {
      expect(package.pubspecFile.readAsStringSync(),
          contains('version: $expectedVersion'));
      final String changelogContent = package.changelogFile.readAsStringSync();
      expect(changelogContent, startsWith('## $expectedVersion'));
      for (final String snippet in expectedChangelogSnippets) {
        expect(changelogContent, contains(snippet));
      }
    }
  }

  group('happy path', () {
    test('can bump minor', () async {
      await testReleaseBranch(
        changelogs: <String, String>{
          'a.yaml': '''
changelog: A new feature
version: minor
'''
        },
        expectedVersion: '1.1.0',
        expectedChangelogSnippets: <String>['A new feature'],
        expectedOutput: <String>[
          'Parsing package "a_package"...',
          'Creating and pushing release branch...',
          '  Creating new branch "release-branch"...',
          '  Updating pubspec.yaml to version 1.1.0...',
          '  Updating CHANGELOG.md...',
        ],
      );
    });

    test('can bump major', () async {
      await testReleaseBranch(
        changelogs: <String, String>{
          'a.yaml': '''
changelog: A new feature
version: major
'''
        },
        expectedVersion: '2.0.0',
        expectedChangelogSnippets: <String>['A new feature'],
        expectedOutput: <String>[
          'Parsing package "a_package"...',
          'Creating and pushing release branch...',
          '  Creating new branch "release-branch"...',
          '  Updating pubspec.yaml to version 2.0.0...',
          '  Updating CHANGELOG.md...',
        ],
      );
    });

    test('can bump patch', () async {
      await testReleaseBranch(
        changelogs: <String, String>{
          'a.yaml': '''
changelog: A new feature
version: patch
'''
        },
        expectedVersion: '1.0.1',
        expectedChangelogSnippets: <String>['A new feature'],
        expectedOutput: <String>[
          'Parsing package "a_package"...',
          'Creating and pushing release branch...',
          '  Creating new branch "release-branch"...',
          '  Updating pubspec.yaml to version 1.0.1...',
          '  Updating CHANGELOG.md...',
        ],
      );
    });

    test('merges multiple changelogs', () async {
      await testReleaseBranch(
        changelogs: <String, String>{
          'a.yaml': '''
changelog: A new feature
version: minor
''',
          'b.yaml': '''
changelog: A breaking change
version: major
'''
        },
        expectedVersion: '2.0.0',
        expectedChangelogSnippets: <String>[
          'A new feature',
          'A breaking change'
        ],
        expectedOutput: <String>[
          'Parsing package "a_package"...',
          'Creating and pushing release branch...',
          '  Creating new branch "release-branch"...',
          '  Updating pubspec.yaml to version 2.0.0...',
          '  Updating CHANGELOG.md...',
        ],
      );
    });

    test('skips version update', () async {
      await testReleaseBranch(
        changelogs: <String, String>{
          'a.yaml': '''
changelog: A new feature
version: skip
'''
        },
        expectedOutput: <String>[
          'Parsing package "a_package"...',
          'No version change specified in pending changelogs for a_package.',
        ],
      );
      expect(
          package.pubspecFile.readAsStringSync(), contains('version: 1.0.0'));
      expect(package.changelogFile.readAsStringSync(), startsWith('## 1.0.0'));
      expect(gitProcessRunner.recordedCalls, orderedEquals(<ProcessCall>[]));
    });

    test('handles no changelog files', () async {
      await testReleaseBranch(
        changelogs: <String, String>{},
        expectedOutput: <String>[
          'Parsing package "a_package"...',
          'No pending changelogs found for a_package.',
        ],
      );
      expect(
          package.pubspecFile.readAsStringSync(), contains('version: 1.0.0'));
      expect(package.changelogFile.readAsStringSync(), startsWith('## 1.0.0'));
      expect(gitProcessRunner.recordedCalls, orderedEquals(<ProcessCall>[]));
    });
  });

  test('throw when github fails', () async {
    createChangelogFile('a.yaml', '''
changelog: A new feature
version: major
''');
    gitProcessRunner.mockProcessesForExecutable['git-rm'] = <FakeProcessInfo>[
      FakeProcessInfo(MockProcess(stderr: 'error', exitCode: 1)),
    ];
    Object? error;
    try {
      await runCapturingPrint(runner, <String>[
        'branch-for-batch-release',
        '--packages=a_package',
        '--branch=release-branch',
      ]);
    } catch (e) {
      error = e;
    }

    expect(error, isA<ToolExit>());
  });
}
