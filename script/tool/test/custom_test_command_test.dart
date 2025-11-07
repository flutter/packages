// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:args/command_runner.dart';
import 'package:file/file.dart';
import 'package:flutter_plugin_tools/src/common/core.dart';
import 'package:flutter_plugin_tools/src/custom_test_command.dart';
import 'package:git/git.dart';
import 'package:test/test.dart';

import 'mocks.dart';
import 'util.dart';

void main() {
  late MockPlatform mockPlatform;
  late Directory packagesDir;
  late RecordingProcessRunner processRunner;
  late CommandRunner<void> runner;

  group('posix', () {
    setUp(() {
      mockPlatform = MockPlatform();
      final GitDir gitDir;
      (:packagesDir, :processRunner, gitProcessRunner: _, :gitDir) =
          configureBaseCommandMocks(platform: mockPlatform);
      final CustomTestCommand analyzeCommand = CustomTestCommand(
        packagesDir,
        processRunner: processRunner,
        platform: mockPlatform,
        gitDir: gitDir,
      );

      runner = CommandRunner<void>(
          'custom_test_command', 'Test for custom_test_command');
      runner.addCommand(analyzeCommand);
    });

    test('runs both new and legacy when both are present', () async {
      final RepositoryPackage package =
          createFakePackage('a_package', packagesDir, extraFiles: <String>[
        'tool/run_tests.dart',
        'run_tests.sh',
      ]);

      final List<String> output =
          await runCapturingPrint(runner, <String>['custom-test']);

      expect(
          processRunner.recordedCalls,
          containsAll(<ProcessCall>[
            ProcessCall(package.directory.childFile('run_tests.sh').path,
                const <String>[], package.path),
            ProcessCall('dart', const <String>['run', 'tool/run_tests.dart'],
                package.path),
          ]));

      expect(
          output,
          containsAllInOrder(<Matcher>[
            contains('Ran for 1 package(s)'),
          ]));
    });

    test('runs when only new is present', () async {
      final RepositoryPackage package = createFakePackage(
          'a_package', packagesDir,
          extraFiles: <String>['tool/run_tests.dart']);

      final List<String> output =
          await runCapturingPrint(runner, <String>['custom-test']);

      expect(
          processRunner.recordedCalls,
          containsAll(<ProcessCall>[
            ProcessCall('dart', const <String>['run', 'tool/run_tests.dart'],
                package.path),
          ]));

      expect(
          output,
          containsAllInOrder(<Matcher>[
            contains('Ran for 1 package(s)'),
          ]));
    });

    test('runs pub get before running Dart test script', () async {
      final RepositoryPackage package = createFakePackage(
          'a_package', packagesDir,
          extraFiles: <String>['tool/run_tests.dart']);

      await runCapturingPrint(runner, <String>['custom-test']);

      expect(
          processRunner.recordedCalls,
          containsAll(<ProcessCall>[
            ProcessCall('dart', const <String>['pub', 'get'], package.path),
            ProcessCall('dart', const <String>['run', 'tool/run_tests.dart'],
                package.path),
          ]));
    });

    test('runs when only legacy is present', () async {
      final RepositoryPackage package = createFakePackage(
          'a_package', packagesDir,
          extraFiles: <String>['run_tests.sh']);

      final List<String> output =
          await runCapturingPrint(runner, <String>['custom-test']);

      expect(
          processRunner.recordedCalls,
          containsAll(<ProcessCall>[
            ProcessCall(package.directory.childFile('run_tests.sh').path,
                const <String>[], package.path),
          ]));

      expect(
          output,
          containsAllInOrder(<Matcher>[
            contains('Ran for 1 package(s)'),
          ]));
    });

    test('skips when neither is present', () async {
      createFakePackage('a_package', packagesDir);

      final List<String> output =
          await runCapturingPrint(runner, <String>['custom-test']);

      expect(processRunner.recordedCalls, isEmpty);

      expect(
          output,
          containsAllInOrder(<Matcher>[
            contains('Skipped 1 package(s)'),
          ]));
    });

    test('fails if new fails', () async {
      createFakePackage('a_package', packagesDir, extraFiles: <String>[
        'tool/run_tests.dart',
        'run_tests.sh',
      ]);

      processRunner.mockProcessesForExecutable['dart'] = <FakeProcessInfo>[
        FakeProcessInfo(MockProcess(), <String>['pub', 'get']),
        FakeProcessInfo(MockProcess(exitCode: 1), <String>['test']),
      ];

      Error? commandError;
      final List<String> output = await runCapturingPrint(
          runner, <String>['custom-test'], errorHandler: (Error e) {
        commandError = e;
      });

      expect(commandError, isA<ToolExit>());
      expect(
          output,
          containsAllInOrder(<Matcher>[
            contains('The following packages had errors:'),
            contains('a_package')
          ]));
    });

    test('fails if pub get fails', () async {
      createFakePackage('a_package', packagesDir, extraFiles: <String>[
        'tool/run_tests.dart',
        'run_tests.sh',
      ]);

      processRunner.mockProcessesForExecutable['dart'] = <FakeProcessInfo>[
        FakeProcessInfo(MockProcess(exitCode: 1), <String>['pub', 'get']),
      ];

      Error? commandError;
      final List<String> output = await runCapturingPrint(
          runner, <String>['custom-test'], errorHandler: (Error e) {
        commandError = e;
      });

      expect(commandError, isA<ToolExit>());
      expect(
          output,
          containsAllInOrder(<Matcher>[
            contains('The following packages had errors:'),
            contains('a_package:\n'
                '    Unable to get script dependencies')
          ]));
    });

    test('fails if legacy fails', () async {
      final RepositoryPackage package =
          createFakePackage('a_package', packagesDir, extraFiles: <String>[
        'tool/run_tests.dart',
        'run_tests.sh',
      ]);

      processRunner.mockProcessesForExecutable[
          package.directory.childFile('run_tests.sh').path] = <FakeProcessInfo>[
        FakeProcessInfo(MockProcess(exitCode: 1)),
      ];

      Error? commandError;
      final List<String> output = await runCapturingPrint(
          runner, <String>['custom-test'], errorHandler: (Error e) {
        commandError = e;
      });

      expect(commandError, isA<ToolExit>());
      expect(
          output,
          containsAllInOrder(<Matcher>[
            contains('The following packages had errors:'),
            contains('a_package')
          ]));
    });
  });

  group('Windows', () {
    setUp(() {
      mockPlatform = MockPlatform(isWindows: true);
      final GitDir gitDir;
      (:packagesDir, :processRunner, gitProcessRunner: _, :gitDir) =
          configureBaseCommandMocks(platform: mockPlatform);
      final CustomTestCommand analyzeCommand = CustomTestCommand(
        packagesDir,
        processRunner: processRunner,
        platform: mockPlatform,
        gitDir: gitDir,
      );

      runner = CommandRunner<void>(
          'custom_test_command', 'Test for custom_test_command');
      runner.addCommand(analyzeCommand);
    });

    test('runs new and skips old when both are present', () async {
      final RepositoryPackage package =
          createFakePackage('a_package', packagesDir, extraFiles: <String>[
        'tool/run_tests.dart',
        'run_tests.sh',
      ]);

      final List<String> output =
          await runCapturingPrint(runner, <String>['custom-test']);

      expect(
          processRunner.recordedCalls,
          containsAll(<ProcessCall>[
            ProcessCall('dart', const <String>['run', 'tool/run_tests.dart'],
                package.path),
          ]));

      expect(
          output,
          containsAllInOrder(<Matcher>[
            contains('Ran for 1 package(s)'),
          ]));
    });

    test('runs when only new is present', () async {
      final RepositoryPackage package = createFakePackage(
          'a_package', packagesDir,
          extraFiles: <String>['tool/run_tests.dart']);

      final List<String> output =
          await runCapturingPrint(runner, <String>['custom-test']);

      expect(
          processRunner.recordedCalls,
          containsAll(<ProcessCall>[
            ProcessCall('dart', const <String>['run', 'tool/run_tests.dart'],
                package.path),
          ]));

      expect(
          output,
          containsAllInOrder(<Matcher>[
            contains('Ran for 1 package(s)'),
          ]));
    });

    test('skips package when only legacy is present', () async {
      createFakePackage('a_package', packagesDir,
          extraFiles: <String>['run_tests.sh']);

      final List<String> output =
          await runCapturingPrint(runner, <String>['custom-test']);

      expect(processRunner.recordedCalls, isEmpty);

      expect(
          output,
          containsAllInOrder(<Matcher>[
            contains('run_tests.sh is not supported on Windows'),
            contains('Skipped 1 package(s)'),
          ]));
    });

    test('fails if new fails', () async {
      createFakePackage('a_package', packagesDir, extraFiles: <String>[
        'tool/run_tests.dart',
        'run_tests.sh',
      ]);

      processRunner.mockProcessesForExecutable['dart'] = <FakeProcessInfo>[
        FakeProcessInfo(MockProcess(), <String>['pub', 'get']),
        FakeProcessInfo(MockProcess(exitCode: 1), <String>['test']),
      ];

      Error? commandError;
      final List<String> output = await runCapturingPrint(
          runner, <String>['custom-test'], errorHandler: (Error e) {
        commandError = e;
      });

      expect(commandError, isA<ToolExit>());
      expect(
          output,
          containsAllInOrder(<Matcher>[
            contains('The following packages had errors:'),
            contains('a_package')
          ]));
    });
  });
}
