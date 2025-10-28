// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:args/command_runner.dart';
import 'package:file/file.dart';
import 'package:flutter_plugin_tools/src/branch_for_batch_release_command.dart';
import 'package:flutter_plugin_tools/src/common/repository_package.dart';
import 'package:git/git.dart';
import 'package:test/test.dart';

import 'mocks.dart';

import 'util.dart';

void main() {
  late Directory packagesDir;
  late RecordingProcessRunner processRunner;
  late RecordingProcessRunner gitProcessRunner;
  late CommandRunner<void> runner;

  setUp(() {
    final GitDir gitDir;
    (:packagesDir, :processRunner, :gitProcessRunner, :gitDir) =
        configureBaseCommandMocks();

    final BranchForBatchReleaseCommand command = BranchForBatchReleaseCommand(
      packagesDir,
      processRunner: processRunner,
      gitDir: gitDir,
    );
    runner = CommandRunner<void>('branch_for_batch_release_command',
        'Test for branch_for_batch_release_command');
    runner.addCommand(command);
  });

  group('happy path', () {
    late RepositoryPackage package;
    setUp(() {
      package = createFakePackage('a_package', packagesDir);

      package.changelogFile.writeAsStringSync('''
## 1.0.0

- Old changes
''');
      package.pubspecFile.writeAsStringSync('''
name: a_package
version: 1.0.0
''');
      final File pendingChangelog = package.directory
          .childDirectory('pending_changelogs')
          .childFile('a.yaml')
        ..createSync(recursive: true);
      pendingChangelog.writeAsStringSync('''
changelog: A new feature
version: minor
''');
    });

    tearDown(() {
      package.directory.deleteSync(recursive: true);
    });

    test('makes a branch', () async {
      // Set up a mock for the git calls to have side-effects.
      gitProcessRunner.mockProcessesForExecutable['git'] = <FakeProcessInfo>[
        // checkout
        FakeProcessInfo(
            MockProcess(), const <String>['checkout', '-b', 'release-branch']),
        // rm
        FakeProcessInfo(MockProcess(), <String>[
          'rm',
          package.directory
              .childDirectory('pending_changelogs')
              .childFile('a.yaml')
              .path
        ], () {
          package.directory
              .childDirectory('pending_changelogs')
              .childFile('a.yaml')
              .deleteSync();
        }),
        // add
        FakeProcessInfo(MockProcess(), <String>[
          'add',
          package.pubspecFile.path,
          package.changelogFile.path
        ]),
        // commit
        FakeProcessInfo(MockProcess(),
            const <String>['commit', '-m', 'a_package: Prepare for release']),
        // push
        FakeProcessInfo(MockProcess(),
            const <String>['push', 'origin', 'release-branch', '--force']),
      ];
      final List<String> output = await runCapturingPrint(runner, <String>[
        'branch-for-batch-release',
        '--packages=a_package',
        '--branch=release-branch',
      ]);

      expect(
          output,
          containsAllInOrder(<String>[
            'Parsing package "a_package"...',
            'Creating and pushing release branch...',
            '  Creating new branch "release-branch"...',
            '  Updating pubspec.yaml to version 1.1.0...',
            '  Updating CHANGELOG.md...',
            '  Removing pending changelog files...',
            '  Staging changes...',
            '  Committing changes...',
            '  Pushing to remote...',
          ]));

      expect(package.pubspecFile.readAsStringSync(), '''
name: a_package
version: 1.1.0
''');
      expect(package.changelogFile.readAsStringSync(), '''
## 1.1.0

A new feature

## 1.0.0

- Old changes
''');

      expect(
          gitProcessRunner.recordedCalls,
          orderedEquals(<ProcessCall>[
            const ProcessCall(
                'git-checkout', <String>['-b', 'release-branch'], null),
            ProcessCall(
                'git-rm',
                <String>[
                  package.directory
                      .childDirectory('pending_changelogs')
                      .childFile('a.yaml')
                      .path
                ],
                null),
            ProcessCall(
                'git-add',
                <String>[package.pubspecFile.path, package.changelogFile.path],
                null),
            const ProcessCall('git-commit',
                <String>['-m', 'a_package: Prepare for release'], null),
            const ProcessCall('git-push',
                <String>['origin', 'release-branch', '--force'], null),
          ]));
    });
  });
}
