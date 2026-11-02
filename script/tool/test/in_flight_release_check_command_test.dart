// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:args/command_runner.dart';
import 'package:file/file.dart';
import 'package:flutter_plugin_tools/src/common/core.dart';
import 'package:flutter_plugin_tools/src/in_flight_release_check_command.dart';
import 'package:git/git.dart';
import 'package:platform/platform.dart';
import 'package:test/test.dart';

import 'mocks.dart';

import 'util.dart';

void main() {
  late NativePlatform mockPlatform;
  late Directory packagesDir;
  late RecordingProcessRunner gitProcessRunner;
  late CommandRunner<void> runner;

  const lsRemoteCall = ProcessCall('git-ls-remote', <String>[
    '--heads',
    'origin',
    'refs/heads/release-a_package-*',
  ], null);

  Future<List<String>> runCheck({void Function(Error error)? errorHandler}) => runCapturingPrint(
    runner,
    <String>['in-flight-release-check', '--packages=a_package', '--remote=origin'],
    errorHandler: errorHandler,
  );

  /// Makes `git ls-remote` report [branches] as the package's release branches.
  void mockRemoteReleaseBranches(List<String> branches) {
    gitProcessRunner.mockProcessesForExecutable['git-ls-remote'] = <FakeProcessInfo>[
      FakeProcessInfo(
        MockProcess(
          stdout: branches.map((String branch) => '0123abc\trefs/heads/$branch').join('\n'),
        ),
      ),
    ];
  }

  setUp(() {
    mockPlatform = createMockPlatform();
    final GitDir gitDir;
    final RecordingProcessRunner processRunner;
    (:packagesDir, :processRunner, :gitProcessRunner, :gitDir) = configureBaseCommandMocks(
      platform: mockPlatform,
    );
    final command = InFlightReleaseCheckCommand(
      packagesDir,
      processRunner: processRunner,
      gitDir: gitDir,
      platform: mockPlatform,
    );
    runner = CommandRunner<void>(
      'in_flight_release_check_command',
      'Test for in_flight_release_check_command',
    );
    runner.addCommand(command);
  });

  test('reports the blocking branch when an earlier release is not merged back', () async {
    final RepositoryPackage package = createFakePackage('a_package', packagesDir, version: '1.0.0');
    addTearDown(() {
      package.directory.deleteSync(recursive: true);
    });
    mockRemoteReleaseBranches(<String>['release-a_package-1.1.0']);

    final List<String> output = await runCheck();

    expect(
      output.last,
      contains('The remote branch "release-a_package-1.1.0" is ahead of the 1.0.0'),
    );
    expect(gitProcessRunner.recordedCalls, orderedEquals(<ProcessCall>[lsRemoteCall]));
  });

  test('reports the blocking branch as a GitHub Actions output', () async {
    final RepositoryPackage package = createFakePackage('a_package', packagesDir, version: '1.0.0');
    addTearDown(() {
      package.directory.deleteSync(recursive: true);
    });
    final File outputFile = packagesDir.fileSystem.file('/github_output');
    mockPlatform.environment['GITHUB_OUTPUT'] = outputFile.path;
    mockRemoteReleaseBranches(<String>[
      'release-a_package-1.1.0',
      'release-a_package-2.0.0',
      'release-a_package-0.9.0',
    ]);

    await runCheck();

    // The highest version is the most recently cut release.
    expect(outputFile.readAsStringSync(), 'blocking_branch=release-a_package-2.0.0\n');
  });

  test('treats a build-only version bump as in flight', () async {
    final RepositoryPackage package = createFakePackage('a_package', packagesDir, version: '0.1.0');
    addTearDown(() {
      package.directory.deleteSync(recursive: true);
    });
    mockRemoteReleaseBranches(<String>['release-a_package-0.1.0+1']);

    final List<String> output = await runCheck();

    expect(output.last, contains('release-a_package-0.1.0+1'));
  });

  test('passes when the last release branch has been merged back', () async {
    final RepositoryPackage package = createFakePackage('a_package', packagesDir, version: '1.0.0');
    addTearDown(() {
      package.directory.deleteSync(recursive: true);
    });
    mockRemoteReleaseBranches(<String>['release-a_package-0.9.0', 'release-a_package-1.0.0']);

    final List<String> output = await runCheck();

    expect(output, contains('No in-flight release for a_package.'));
  });

  test('passes when there are no release branches', () async {
    final RepositoryPackage package = createFakePackage('a_package', packagesDir, version: '1.0.0');
    addTearDown(() {
      package.directory.deleteSync(recursive: true);
    });

    final List<String> output = await runCheck();

    expect(output, contains('No in-flight release for a_package.'));
  });

  test('ignores branches that do not belong to the package', () async {
    final RepositoryPackage package = createFakePackage('a_package', packagesDir, version: '1.0.0');
    addTearDown(() {
      package.directory.deleteSync(recursive: true);
    });
    mockRemoteReleaseBranches(<String>['release-a_package_two-9.0.0']);

    final List<String> output = await runCheck();

    expect(output, contains('No in-flight release for a_package.'));
  });

  test('ignores branches without a valid version suffix', () async {
    final RepositoryPackage package = createFakePackage('a_package', packagesDir, version: '1.0.0');
    addTearDown(() {
      package.directory.deleteSync(recursive: true);
    });
    mockRemoteReleaseBranches(<String>['release-a_package-experiment']);

    final List<String> output = await runCheck();

    expect(output, contains('No in-flight release for a_package.'));
  });

  test('ignores malformed ls-remote output', () async {
    final RepositoryPackage package = createFakePackage('a_package', packagesDir, version: '1.0.0');
    addTearDown(() {
      package.directory.deleteSync(recursive: true);
    });
    gitProcessRunner.mockProcessesForExecutable['git-ls-remote'] = <FakeProcessInfo>[
      FakeProcessInfo(
        MockProcess(stdout: 'not a ref line\n\n0123abc\trefs/heads/release-a_package-1.0.0\n'),
      ),
    ];

    final List<String> output = await runCheck();

    expect(output, contains('No in-flight release for a_package.'));
  });

  test('throws when the remote cannot be queried', () async {
    final RepositoryPackage package = createFakePackage('a_package', packagesDir, version: '1.0.0');
    addTearDown(() {
      package.directory.deleteSync(recursive: true);
    });
    gitProcessRunner.mockProcessesForExecutable['git-ls-remote'] = <FakeProcessInfo>[
      FakeProcessInfo(MockProcess(stderr: 'error', exitCode: 1)),
    ];

    final List<String> output = await runCheck(
      errorHandler: (Error e) {
        expect(e, isA<ToolExit>());
        expect((e as ToolExit).exitCode, 6);
      },
    );

    expect(output.last, contains('Failed to list release branches on origin: error'));
  });
}
