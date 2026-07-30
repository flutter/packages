// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:args/command_runner.dart';
import 'package:file/file.dart';
import 'package:flutter_plugin_tools/src/common/core.dart';
import 'package:flutter_plugin_tools/src/coverage_check_command.dart';
import 'package:git/git.dart';
import 'package:platform/platform.dart';
import 'package:test/test.dart';

import 'mocks.dart';
import 'util.dart';

void main() {
  group('CoverageCheckCommand', () {
    late Platform mockPlatform;
    late Directory packagesDir;
    late CommandRunner<void> runner;
    late RecordingProcessRunner processRunner;
    late CoverageCheckCommand command;

    setUp(() {
      mockPlatform = MockPlatform();
      late GitDir gitDir;
      (:packagesDir, :processRunner, gitProcessRunner: _, :gitDir) = configureBaseCommandMocks(
        platform: mockPlatform,
      );
      command = CoverageCheckCommand(
        packagesDir,
        processRunner: processRunner,
        platform: mockPlatform,
        gitDir: gitDir,
      );

      runner = CommandRunner<void>('coverage_test', 'Test for CoverageCheckCommand');
      runner.addCommand(command);

      final File minimumsFile = packagesDir.parent
          .childDirectory('script')
          .childDirectory('configs')
          .childFile('custom_coverage_minimums.yaml');
      minimumsFile.createSync(recursive: true);
      minimumsFile.writeAsStringSync('''
custom_coverage_minimums:
  plugin1: 50.0
  plugin2: 100.0
''');
    });

    test('fails if custom_coverage_minimums.yaml is missing', () async {
      final File minimumsFile = packagesDir.parent
          .childDirectory('script')
          .childDirectory('configs')
          .childFile('custom_coverage_minimums.yaml');
      minimumsFile.deleteSync();

      Error? commandError;
      final List<String> output = await runCapturingPrint(
        runner,
        <String>['coverage-check'],
        errorHandler: (Error e) {
          commandError = e;
        },
      );

      expect(commandError, isA<ToolExit>());
      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('The custom_coverage_minimums.yaml file is missing.'),
        ]),
      );
    });

    test('skips packages not in custom minimums', () async {
      createFakePlugin(
        'unlisted_plugin',
        packagesDir,
        extraFiles: <String>['test/empty_test.dart'],
      );

      final List<String> output = await runCapturingPrint(runner, <String>['coverage-check']);

      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('SKIPPING: Package not opted into coverage checks.'),
        ]),
      );
      expect(processRunner.recordedCalls, isEmpty);
    });

    test('skips third-party packages', () async {
      createFakePlugin(
        'plugin1',
        packagesDir.parent.childDirectory('third_party').childDirectory('packages'),
        extraFiles: <String>['test/empty_test.dart'],
      );

      final List<String> output = await runCapturingPrint(runner, <String>['coverage-check']);

      expect(
        output,
        containsAllInOrder(<Matcher>[contains('SKIPPING: Not a first-party package.')]),
      );
      expect(processRunner.recordedCalls, isEmpty);
    });

    test('passes when coverage meets minimum', () async {
      final RepositoryPackage plugin = createFakePlugin(
        'plugin1',
        packagesDir,
        extraFiles: <String>['test/empty_test.dart'],
      );

      final Directory coverageDir = plugin.directory.childDirectory('coverage');
      coverageDir.createSync();
      coverageDir.childFile('lcov.info').writeAsStringSync('''
SF:lib/plugin1.dart
DA:1,1
DA:2,1
LF:2
LH:2
end_of_record
''');

      final List<String> output = await runCapturingPrint(runner, <String>['coverage-check']);

      expect(
        processRunner.recordedCalls,
        orderedEquals(<ProcessCall>[
          ProcessCall('flutter', const <String>['test', '--coverage'], plugin.path),
        ]),
      );
      expect(output, contains(contains('Ran for 1 package(s)')));
      expect(coverageDir.existsSync(), isFalse);
    });

    test('fails when coverage is below minimum', () async {
      final RepositoryPackage plugin = createFakePlugin(
        'plugin1',
        packagesDir,
        extraFiles: <String>['test/empty_test.dart'],
      );

      final Directory coverageDir = plugin.directory.childDirectory('coverage');
      coverageDir.createSync();
      coverageDir.childFile('lcov.info').writeAsStringSync('''
SF:lib/plugin1.dart
DA:1,1
DA:2,0
DA:3,0
DA:4,0
LF:4
LH:1
end_of_record
''');

      Error? commandError;
      final List<String> output = await runCapturingPrint(
        runner,
        <String>['coverage-check'],
        errorHandler: (Error e) {
          commandError = e;
        },
      );

      expect(commandError, isA<ToolExit>());
      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('Code coverage for plugin1 is 25.0%, which is below the required 50.0%.'),
        ]),
      );
      expect(coverageDir.existsSync(), isFalse);
    });

    test('ignores generated files when calculating coverage', () async {
      final RepositoryPackage plugin = createFakePlugin(
        'plugin1',
        packagesDir,
        extraFiles: <String>['test/empty_test.dart'],
      );

      final Directory coverageDir = plugin.directory.childDirectory('coverage');
      coverageDir.createSync();
      coverageDir.childFile('lcov.info').writeAsStringSync('''
SF:lib/plugin1.dart
DA:1,1
DA:2,1
LF:2
LH:2
end_of_record
SF:lib/plugin1.g.dart
DA:1,0
DA:2,0
DA:3,0
DA:4,0
LF:4
LH:0
end_of_record
''');

      final List<String> output = await runCapturingPrint(runner, <String>['coverage-check']);

      expect(output, contains(contains('Ran for 1 package(s)')));
    });

    test('fails with clear message when no instrumented lines are found', () async {
      final RepositoryPackage plugin = createFakePlugin(
        'plugin1',
        packagesDir,
        extraFiles: <String>['test/empty_test.dart'],
      );

      final Directory coverageDir = plugin.directory.childDirectory('coverage');
      coverageDir.createSync();
      coverageDir.childFile('lcov.info').writeAsStringSync('''
SF:lib/plugin1.g.dart
DA:1,0
LF:1
LH:0
end_of_record
''');

      Error? commandError;
      final List<String> output = await runCapturingPrint(
        runner,
        <String>['coverage-check'],
        errorHandler: (Error e) {
          commandError = e;
        },
      );

      expect(commandError, isA<ToolExit>());
      expect(
        output,
        contains(
          contains('No instrumented Dart lines were found in the coverage report for plugin1.'),
        ),
      );
      expect(
        output,
        contains(contains('If this package contains no code to cover, please remove it from')),
      );
    });

    test('calculates coverage correctly across multiple files', () async {
      final RepositoryPackage plugin = createFakePlugin(
        'plugin1',
        packagesDir,
        extraFiles: <String>['test/empty_test.dart'],
      );

      final Directory coverageDir = plugin.directory.childDirectory('coverage');
      coverageDir.createSync();
      coverageDir.childFile('lcov.info').writeAsStringSync('''
SF:lib/file1.dart
DA:1,1
DA:2,0
LF:2
LH:1
end_of_record
SF:lib/file2.dart
DA:1,1
DA:2,1
DA:3,1
LF:3
LH:3
end_of_record
'''); // Total LF: 5, LH: 4 => 80.0% coverage. 80.0 >= 50.0 so it should pass.

      final List<String> output = await runCapturingPrint(runner, <String>['coverage-check']);

      expect(output, contains(contains('Ran for 1 package(s)')));
    });

    test('fails when test command fails', () async {
      createFakePlugin('plugin1', packagesDir, extraFiles: <String>['test/empty_test.dart']);

      processRunner.mockProcessesForExecutable['flutter'] = <FakeProcessInfo>[
        FakeProcessInfo(MockProcess(exitCode: 1), <String>['test', '--coverage']),
      ];

      Error? commandError;
      final List<String> output = await runCapturingPrint(
        runner,
        <String>['coverage-check'],
        errorHandler: (Error e) {
          commandError = e;
        },
      );

      expect(commandError, isA<ToolExit>());
      expect(
        output,
        containsAllInOrder(<Matcher>[contains('Failed to run tests or parse coverage')]),
      );
    });

    test('fails when lcov.info is missing', () async {
      createFakePlugin('plugin1', packagesDir, extraFiles: <String>['test/empty_test.dart']);

      Error? commandError;
      final List<String> output = await runCapturingPrint(
        runner,
        <String>['coverage-check'],
        errorHandler: (Error e) {
          commandError = e;
        },
      );

      expect(commandError, isA<ToolExit>());
      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains(
            'Coverage file not found at ${packagesDir.childDirectory('plugin1').childDirectory('coverage').childFile('lcov.info').path}.',
          ),
          contains('Failed to run tests or parse coverage'),
        ]),
      );
    });

    group('calculateCoverage', () {
      late File tempLcovFile;

      setUp(() {
        tempLcovFile = packagesDir.parent.childFile('temp_lcov.info');
      });

      tearDown(() {
        if (tempLcovFile.existsSync()) {
          tempLcovFile.deleteSync();
        }
      });

      test('calculates 100% coverage correctly', () {
        tempLcovFile.writeAsStringSync('''
SF:lib/foo.dart
DA:1,1
DA:2,1
LF:2
LH:2
end_of_record
''');
        expect(command.calculateCoverage(tempLcovFile), 100.0);
      });

      test('calculates partial coverage correctly', () {
        tempLcovFile.writeAsStringSync('''
SF:lib/foo.dart
DA:1,1
DA:2,0
LF:2
LH:1
end_of_record
''');
        expect(command.calculateCoverage(tempLcovFile), 50.0);
      });

      test('calculates partial coverage across multiple files correctly', () {
        tempLcovFile.writeAsStringSync('''
SF:lib/foo.dart
DA:1,1
DA:2,0
LF:2
LH:1
end_of_record
SF:lib/bar.dart
DA:1,1
DA:2,1
DA:3,0
LF:3
LH:2
end_of_record
''');
        expect(command.calculateCoverage(tempLcovFile), 60.0);
      });

      test('throws NoLinesFoundException when no lines are found', () {
        tempLcovFile.writeAsStringSync('''
SF:lib/foo.g.dart
DA:1,0
LF:1
LH:0
end_of_record
''');
        expect(
          () => command.calculateCoverage(tempLcovFile),
          throwsA(isA<NoLinesFoundException>()),
        );
      });

      test('ignores multiple types of generated files', () {
        tempLcovFile.writeAsStringSync('''
SF:lib/foo.dart
DA:1,1
LF:1
LH:1
end_of_record
SF:lib/foo.g.dart
DA:1,0
LF:1
LH:0
end_of_record
SF:lib/foo.mocks.dart
DA:1,0
LF:1
LH:0
end_of_record
SF:lib/foo.pb.dart
DA:1,0
LF:1
LH:0
end_of_record
''');
        expect(command.calculateCoverage(tempLcovFile), 100.0);
      });
    });
  });
}
