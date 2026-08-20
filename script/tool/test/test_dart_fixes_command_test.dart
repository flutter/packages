// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:args/command_runner.dart';
import 'package:file/file.dart';
import 'package:flutter_plugin_tools/src/common/core.dart';
import 'package:flutter_plugin_tools/src/test_dart_fixes_command.dart';
import 'package:git/git.dart';
import 'package:platform/platform.dart';
import 'package:test/test.dart';

import 'mocks.dart';
import 'util.dart';

void main() {
  group('TestDartFixesCommand', () {
    late Platform mockPlatform;
    late Directory packagesDir;
    late CommandRunner<void> runner;
    late RecordingProcessRunner processRunner;
    late TestDartFixesCommand command;

    setUp(() {
      mockPlatform = MockPlatform();
      final GitDir gitDir;
      (:packagesDir, :processRunner, gitProcessRunner: _, :gitDir) = configureBaseCommandMocks(
        platform: mockPlatform,
      );
      command = TestDartFixesCommand(
        packagesDir,
        processRunner: processRunner,
        platform: mockPlatform,
        gitDir: gitDir,
      );

      runner = CommandRunner<void>('test_dart_fixes', 'Test for $TestDartFixesCommand');
      runner.addCommand(command);
    });

    test('runs on each package with a test_fixes directory', () async {
      final RepositoryPackage package1 = createFakePackage(
        'package1',
        packagesDir,
        examples: <String>[],
        extraFiles: <String>['test_fixes/empty.dart', 'test_fixes/empty.dart.expect'],
      );
      final RepositoryPackage package2 = createFakePackage(
        'package2',
        packagesDir,
        examples: <String>[],
        extraFiles: <String>['test_fixes/empty.dart', 'test_fixes/empty.dart.expect'],
      );
      createFakePackage('package3', packagesDir, examples: <String>[]);

      final List<String> output = await runCapturingPrint(runner, <String>['test-dart-fixes']);

      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('Running for package1'),
          contains('Running for package2'),
          contains('Running for package3'),
          contains("SKIPPING: No MemoryDirectory: '/packages/package3/test_fixes' directory."),
        ]),
      );

      expect(
        processRunner.recordedCalls,
        orderedEquals(<ProcessCall>[
          ProcessCall(getFlutterCommand(mockPlatform), const <String>[
            'pub',
            'get',
          ], command.testDirectories[package1.displayName]!.path),
          ProcessCall('dart', const <String>[
            'fix',
            '--compare-to-golden',
          ], command.testDirectories[package1.displayName]!.path),
          ProcessCall(getFlutterCommand(mockPlatform), const <String>[
            'pub',
            'get',
          ], command.testDirectories[package2.displayName]!.path),
          ProcessCall('dart', const <String>[
            'fix',
            '--compare-to-golden',
          ], command.testDirectories[package2.displayName]!.path),
        ]),
      );
    });

    test('fails when dart fix test fails', () async {
      final RepositoryPackage packageThatFails = createFakePackage(
        'package1',
        packagesDir,
        examples: <String>[],
        extraFiles: <String>['test_fixes/fix.dart', 'test_fixes/fix.dart.expect'],
      );
      packageThatFails.dartFixTestDirectory.childFile('fix.dart').writeAsStringSync('a');
      packageThatFails.dartFixTestDirectory.childFile('fix.dart.expect').writeAsStringSync('b');

      final RepositoryPackage packageThatSucceeds = createFakePackage(
        'package2',
        packagesDir,
        examples: <String>[],
        extraFiles: <String>['test_fixes/fix.dart', 'test_fixes/fix.dart.expect'],
      );
      packageThatSucceeds.dartFixTestDirectory.childFile('fix.dart').writeAsStringSync('c');
      packageThatSucceeds.dartFixTestDirectory.childFile('fix.dart.expect').writeAsStringSync('c');

      processRunner.mockProcessesForExecutable['dart'] = <FakeProcessInfo>[
        FakeProcessInfo(_MockDartFixProcess(processRunner, packagesDir.fileSystem), const <String>[
          'fix',
          '--compare-to-golden',
        ]),
        FakeProcessInfo(_MockDartFixProcess(processRunner, packagesDir.fileSystem), const <String>[
          'fix',
          '--compare-to-golden',
        ]),
      ];

      Error? commandError;
      final List<String> output = await runCapturingPrint(
        runner,
        <String>['test-dart-fixes'],
        errorHandler: (e) {
          commandError = e;
        },
      );

      expect(commandError, isA<ToolExit>());
      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('The following packages had errors:'),
          contains('  package1'),
          isNot(contains('package2')),
        ]),
      );
    });
  });
}

/// Fails when fix.dart does not equal fix.dart.expect.
class _MockDartFixProcess extends MockProcess {
  _MockDartFixProcess(this.processRunner, this.fileSystem);
  final RecordingProcessRunner processRunner;
  final FileSystem fileSystem;

  @override
  Future<int> get exitCode async {
    final ProcessCall call = processRunner.recordedCalls.last;
    final String? workingDir = call.workingDir;
    final File fixDart = fileSystem.file(fileSystem.path.join(workingDir!, 'fix.dart'));
    final File fixExpect = fileSystem.file(fileSystem.path.join(workingDir, 'fix.dart.expect'));
    if (!fixDart.existsSync() || !fixExpect.existsSync()) {
      return 1;
    }
    return fixDart.readAsStringSync() == fixExpect.readAsStringSync() ? 0 : 1;
  }
}
