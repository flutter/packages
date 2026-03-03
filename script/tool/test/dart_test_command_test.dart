// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:args/command_runner.dart';
import 'package:file/file.dart';
import 'package:flutter_plugin_tools/src/common/core.dart';
import 'package:flutter_plugin_tools/src/common/plugin_utils.dart';
import 'package:flutter_plugin_tools/src/dart_test_command.dart';
import 'package:git/git.dart';
import 'package:platform/platform.dart';
import 'package:test/test.dart';

import 'mocks.dart';
import 'util.dart';

void main() {
  group('TestCommand', () {
    late Platform mockPlatform;
    late Directory packagesDir;
    late CommandRunner<void> runner;
    late RecordingProcessRunner processRunner;
    late RecordingProcessRunner gitProcessRunner;

    setUp(() {
      mockPlatform = MockPlatform();
      final GitDir gitDir;
      (:packagesDir, :processRunner, :gitProcessRunner, :gitDir) =
          configureBaseCommandMocks(platform: mockPlatform);
      final command = DartTestCommand(
        packagesDir,
        processRunner: processRunner,
        platform: mockPlatform,
        gitDir: gitDir,
      );

      runner = CommandRunner<void>('test_test', 'Test for $DartTestCommand');
      runner.addCommand(command);
    });

    test('legacy "test" name still works', () async {
      final RepositoryPackage plugin = createFakePlugin(
        'a_plugin',
        packagesDir,
        extraFiles: <String>['test/a_test.dart'],
      );

      await runCapturingPrint(runner, <String>['test']);

      expect(
        processRunner.recordedCalls,
        orderedEquals(<ProcessCall>[
          ProcessCall(getFlutterCommand(mockPlatform), const <String>[
            'test',
            '--color',
          ], plugin.path),
        ]),
      );
    });

    test('runs flutter test on each plugin', () async {
      final RepositoryPackage plugin1 = createFakePlugin(
        'plugin1',
        packagesDir,
        extraFiles: <String>['test/empty_test.dart'],
      );
      final RepositoryPackage plugin2 = createFakePlugin(
        'plugin2',
        packagesDir,
        extraFiles: <String>['test/empty_test.dart'],
      );

      await runCapturingPrint(runner, <String>['dart-test']);

      expect(
        processRunner.recordedCalls,
        orderedEquals(<ProcessCall>[
          ProcessCall(getFlutterCommand(mockPlatform), const <String>[
            'test',
            '--color',
          ], plugin1.path),
          ProcessCall(getFlutterCommand(mockPlatform), const <String>[
            'test',
            '--color',
          ], plugin2.path),
        ]),
      );
    });

    test('runs flutter test on Flutter package example tests', () async {
      final RepositoryPackage plugin = createFakePlugin(
        'a_plugin',
        packagesDir,
        extraFiles: <String>[
          'test/empty_test.dart',
          'example/test/an_example_test.dart',
        ],
      );

      await runCapturingPrint(runner, <String>['dart-test']);

      expect(
        processRunner.recordedCalls,
        orderedEquals(<ProcessCall>[
          ProcessCall(getFlutterCommand(mockPlatform), const <String>[
            'test',
            '--color',
          ], plugin.path),
          ProcessCall(getFlutterCommand(mockPlatform), const <String>[
            'test',
            '--color',
          ], getExampleDir(plugin).path),
        ]),
      );
    });

    test('fails when Flutter tests fail', () async {
      createFakePlugin(
        'plugin1',
        packagesDir,
        extraFiles: <String>['test/empty_test.dart'],
      );
      createFakePlugin(
        'plugin2',
        packagesDir,
        extraFiles: <String>['test/empty_test.dart'],
      );

      processRunner.mockProcessesForExecutable[getFlutterCommand(
        mockPlatform,
      )] = <FakeProcessInfo>[
        FakeProcessInfo(MockProcess(exitCode: 1), <String>[
          'dart-test',
        ]), // plugin 1 test
        FakeProcessInfo(MockProcess(), <String>['dart-test']), // plugin 2 test
      ];

      Error? commandError;
      final List<String> output = await runCapturingPrint(
        runner,
        <String>['dart-test'],
        errorHandler: (Error e) {
          commandError = e;
        },
      );

      expect(commandError, isA<ToolExit>());
      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('The following packages had errors:'),
          contains('  plugin1'),
        ]),
      );
    });

    test('skips testing plugins without test directory', () async {
      createFakePlugin('plugin1', packagesDir);
      final RepositoryPackage plugin2 = createFakePlugin(
        'plugin2',
        packagesDir,
        extraFiles: <String>['test/empty_test.dart'],
      );

      await runCapturingPrint(runner, <String>['dart-test']);

      expect(
        processRunner.recordedCalls,
        orderedEquals(<ProcessCall>[
          ProcessCall(getFlutterCommand(mockPlatform), const <String>[
            'test',
            '--color',
          ], plugin2.path),
        ]),
      );
    });

    test('runs dart run test on non-Flutter packages', () async {
      final RepositoryPackage plugin = createFakePlugin(
        'a',
        packagesDir,
        extraFiles: <String>['test/empty_test.dart'],
      );
      final RepositoryPackage package = createFakePackage(
        'b',
        packagesDir,
        extraFiles: <String>['test/empty_test.dart'],
      );

      await runCapturingPrint(runner, <String>[
        'dart-test',
        '--enable-experiment=exp1',
      ]);

      expect(
        processRunner.recordedCalls,
        orderedEquals(<ProcessCall>[
          ProcessCall(getFlutterCommand(mockPlatform), const <String>[
            'test',
            '--color',
            '--enable-experiment=exp1',
          ], plugin.path),
          ProcessCall('dart', const <String>['pub', 'get'], package.path),
          ProcessCall('dart', const <String>[
            'run',
            '--enable-experiment=exp1',
            'test',
          ], package.path),
        ]),
      );
    });

    test('runs dart run test on non-Flutter package examples', () async {
      final RepositoryPackage package = createFakePackage(
        'a_package',
        packagesDir,
        extraFiles: <String>[
          'test/empty_test.dart',
          'example/test/an_example_test.dart',
        ],
      );

      await runCapturingPrint(runner, <String>['dart-test']);

      expect(
        processRunner.recordedCalls,
        orderedEquals(<ProcessCall>[
          ProcessCall('dart', const <String>['pub', 'get'], package.path),
          ProcessCall('dart', const <String>['run', 'test'], package.path),
          ProcessCall('dart', const <String>[
            'pub',
            'get',
          ], getExampleDir(package).path),
          ProcessCall('dart', const <String>[
            'run',
            'test',
          ], getExampleDir(package).path),
        ]),
      );
    });

    test('fails when getting non-Flutter package dependencies fails', () async {
      createFakePackage(
        'a_package',
        packagesDir,
        extraFiles: <String>['test/empty_test.dart'],
      );

      processRunner.mockProcessesForExecutable['dart'] = <FakeProcessInfo>[
        FakeProcessInfo(MockProcess(exitCode: 1), <String>['pub', 'get']),
      ];

      Error? commandError;
      final List<String> output = await runCapturingPrint(
        runner,
        <String>['dart-test'],
        errorHandler: (Error e) {
          commandError = e;
        },
      );

      expect(commandError, isA<ToolExit>());
      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('Unable to fetch dependencies'),
          contains('The following packages had errors:'),
          contains('  a_package'),
        ]),
      );
    });

    test('fails when non-Flutter tests fail', () async {
      createFakePackage(
        'a_package',
        packagesDir,
        extraFiles: <String>['test/empty_test.dart'],
      );

      processRunner.mockProcessesForExecutable['dart'] = <FakeProcessInfo>[
        FakeProcessInfo(MockProcess(), <String>['pub', 'get']),
        FakeProcessInfo(MockProcess(exitCode: 1), <String>['run']), // run test
      ];

      Error? commandError;
      final List<String> output = await runCapturingPrint(
        runner,
        <String>['dart-test'],
        errorHandler: (Error e) {
          commandError = e;
        },
      );

      expect(commandError, isA<ToolExit>());
      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('The following packages had errors:'),
          contains('  a_package'),
        ]),
      );
    });

    test('converts --platform=vm to no argument for flutter test', () async {
      final RepositoryPackage plugin = createFakePlugin(
        'some_plugin',
        packagesDir,
        extraFiles: <String>['test/empty_test.dart'],
      );

      await runCapturingPrint(runner, <String>['dart-test', '--platform=vm']);

      expect(
        processRunner.recordedCalls,
        orderedEquals(<ProcessCall>[
          ProcessCall(getFlutterCommand(mockPlatform), const <String>[
            'test',
            '--color',
          ], plugin.path),
        ]),
      );
    });

    test('throws for an unrecognized test_on type', () async {
      final RepositoryPackage package = createFakePackage(
        'a_package',
        packagesDir,
        extraFiles: <String>['test/empty_test.dart'],
      );
      package.directory.childFile('dart_test.yaml').writeAsStringSync('''
test_on: unknown
''');

      Error? commandError;
      final List<String> output = await runCapturingPrint(
        runner,
        <String>['dart-test', '--platform=vm'],
        errorHandler: (Error e) {
          commandError = e;
        },
      );

      expect(commandError, isA<ToolExit>());

      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains(
            'Unknown "test_on" value: "unknown"\n'
            "If this value needs to be supported for this package's "
            'tests, please update the repository tooling to support more '
            'test_on modes.',
          ),
        ]),
      );
    });

    test('throws for an valid but complex test_on directive', () async {
      final RepositoryPackage package = createFakePackage(
        'a_package',
        packagesDir,
        extraFiles: <String>['test/empty_test.dart'],
      );
      package.directory.childFile('dart_test.yaml').writeAsStringSync('''
test_on: vm && browser
''');

      Error? commandError;
      final List<String> output = await runCapturingPrint(
        runner,
        <String>['dart-test', '--platform=vm'],
        errorHandler: (Error e) {
          commandError = e;
        },
      );

      expect(commandError, isA<ToolExit>());

      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains(
            'Unknown "test_on" value: "vm && browser"\n'
            "If this value needs to be supported for this package's "
            'tests, please update the repository tooling to support more '
            'test_on modes.',
          ),
        ]),
      );
    });

    test('runs in Chrome when requested for Flutter package', () async {
      final RepositoryPackage package = createFakePackage(
        'a_package',
        packagesDir,
        isFlutter: true,
        extraFiles: <String>['test/empty_test.dart'],
      );

      await runCapturingPrint(runner, <String>[
        'dart-test',
        '--platform=chrome',
      ]);

      expect(
        processRunner.recordedCalls,
        orderedEquals(<ProcessCall>[
          ProcessCall(getFlutterCommand(mockPlatform), const <String>[
            'test',
            '--color',
            '--platform=chrome',
          ], package.path),
        ]),
      );
    });

    test('runs in Chrome (wasm) when requested for Flutter package', () async {
      final RepositoryPackage package = createFakePackage(
        'a_package',
        packagesDir,
        isFlutter: true,
        extraFiles: <String>['test/empty_test.dart'],
      );

      await runCapturingPrint(runner, <String>[
        'dart-test',
        '--platform=chrome',
        '--wasm',
      ]);

      expect(
        processRunner.recordedCalls,
        orderedEquals(<ProcessCall>[
          ProcessCall(getFlutterCommand(mockPlatform), const <String>[
            'test',
            '--color',
            '--platform=chrome',
            '--wasm',
          ], package.path),
        ]),
      );
    });

    test(
      'runs in Chrome by default for Flutter plugins that implement web',
      () async {
        final RepositoryPackage plugin = createFakePlugin(
          'some_plugin_web',
          packagesDir,
          extraFiles: <String>['test/empty_test.dart'],
          platformSupport: <String, PlatformDetails>{
            platformWeb: const PlatformDetails(PlatformSupport.inline),
          },
        );

        await runCapturingPrint(runner, <String>['dart-test']);

        expect(
          processRunner.recordedCalls,
          orderedEquals(<ProcessCall>[
            ProcessCall(getFlutterCommand(mockPlatform), const <String>[
              'test',
              '--color',
              '--platform=chrome',
            ], plugin.path),
          ]),
        );
      },
    );

    test(
      'runs in Chrome when requested for Flutter plugins that implement web',
      () async {
        final RepositoryPackage plugin = createFakePlugin(
          'some_plugin_web',
          packagesDir,
          extraFiles: <String>['test/empty_test.dart'],
          platformSupport: <String, PlatformDetails>{
            platformWeb: const PlatformDetails(PlatformSupport.inline),
          },
        );

        await runCapturingPrint(runner, <String>[
          'dart-test',
          '--platform=chrome',
        ]);

        expect(
          processRunner.recordedCalls,
          orderedEquals(<ProcessCall>[
            ProcessCall(getFlutterCommand(mockPlatform), const <String>[
              'test',
              '--color',
              '--platform=chrome',
            ], plugin.path),
          ]),
        );
      },
    );

    test(
      'runs in Chrome when requested for Flutter plugin that endorse web',
      () async {
        final RepositoryPackage plugin = createFakePlugin(
          'plugin',
          packagesDir,
          extraFiles: <String>['test/empty_test.dart'],
          platformSupport: <String, PlatformDetails>{
            platformWeb: const PlatformDetails(PlatformSupport.federated),
          },
        );

        await runCapturingPrint(runner, <String>[
          'dart-test',
          '--platform=chrome',
        ]);

        expect(
          processRunner.recordedCalls,
          orderedEquals(<ProcessCall>[
            ProcessCall(getFlutterCommand(mockPlatform), const <String>[
              'test',
              '--color',
              '--platform=chrome',
            ], plugin.path),
          ]),
        );
      },
    );

    test('skips running non-web plugins in browser mode', () async {
      createFakePlugin(
        'non_web_plugin',
        packagesDir,
        extraFiles: <String>['test/empty_test.dart'],
      );

      final List<String> output = await runCapturingPrint(runner, <String>[
        'dart-test',
        '--platform=chrome',
      ]);

      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains("Non-web plugin tests don't need web testing."),
        ]),
      );
      expect(processRunner.recordedCalls, orderedEquals(<ProcessCall>[]));
    });

    test('skips running web plugins in explicit vm mode', () async {
      createFakePlugin(
        'some_plugin_web',
        packagesDir,
        extraFiles: <String>['test/empty_test.dart'],
        platformSupport: <String, PlatformDetails>{
          platformWeb: const PlatformDetails(PlatformSupport.inline),
        },
      );

      final List<String> output = await runCapturingPrint(runner, <String>[
        'dart-test',
        '--platform=vm',
      ]);

      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains("Web plugin tests don't need vm testing."),
        ]),
      );
      expect(processRunner.recordedCalls, orderedEquals(<ProcessCall>[]));
    });

    test('does not skip for plugins that endorse web', () async {
      final RepositoryPackage plugin = createFakePlugin(
        'some_plugin',
        packagesDir,
        extraFiles: <String>['test/empty_test.dart'],
        platformSupport: <String, PlatformDetails>{
          platformWeb: const PlatformDetails(PlatformSupport.federated),
          platformAndroid: const PlatformDetails(PlatformSupport.federated),
        },
      );

      await runCapturingPrint(runner, <String>[
        'dart-test',
        '--platform=chrome',
      ]);

      expect(
        processRunner.recordedCalls,
        orderedEquals(<ProcessCall>[
          ProcessCall(getFlutterCommand(mockPlatform), const <String>[
            'test',
            '--color',
            '--platform=chrome',
          ], plugin.path),
        ]),
      );
    });

    test('runs in Chrome when requested for Dart package', () async {
      final RepositoryPackage package = createFakePackage(
        'package',
        packagesDir,
        extraFiles: <String>['test/empty_test.dart'],
      );

      await runCapturingPrint(runner, <String>[
        'dart-test',
        '--platform=chrome',
      ]);

      expect(
        processRunner.recordedCalls,
        orderedEquals(<ProcessCall>[
          ProcessCall('dart', const <String>['pub', 'get'], package.path),
          ProcessCall('dart', const <String>[
            'run',
            'test',
            '--platform=chrome',
          ], package.path),
        ]),
      );
    });

    test('runs in Chrome (wasm) when requested for Dart package', () async {
      final RepositoryPackage package = createFakePackage(
        'package',
        packagesDir,
        extraFiles: <String>['test/empty_test.dart'],
      );

      await runCapturingPrint(runner, <String>[
        'dart-test',
        '--platform=chrome',
        '--wasm',
      ]);

      expect(
        processRunner.recordedCalls,
        orderedEquals(<ProcessCall>[
          ProcessCall('dart', const <String>['pub', 'get'], package.path),
          ProcessCall('dart', const <String>[
            'run',
            'test',
            '--platform=chrome',
            '--compiler=dart2wasm',
          ], package.path),
        ]),
      );
    });

    test('skips running in browser mode if package opts out', () async {
      final RepositoryPackage package = createFakePackage(
        'a_package',
        packagesDir,
        extraFiles: <String>['test/empty_test.dart'],
      );
      package.directory.childFile('dart_test.yaml').writeAsStringSync('''
test_on: vm
''');

      final List<String> output = await runCapturingPrint(runner, <String>[
        'dart-test',
        '--platform=chrome',
      ]);

      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('Package has opted out of non-vm testing.'),
        ]),
      );
      expect(processRunner.recordedCalls, orderedEquals(<ProcessCall>[]));
    });

    test('does not skip running vm in vm mode', () async {
      final RepositoryPackage package = createFakePackage(
        'a_package',
        packagesDir,
        extraFiles: <String>['test/empty_test.dart'],
      );
      package.directory.childFile('dart_test.yaml').writeAsStringSync('''
test_on: vm
''');

      final List<String> output = await runCapturingPrint(runner, <String>[
        'dart-test',
        '--platform=vm',
      ]);

      expect(
        output,
        isNot(containsAllInOrder(<Matcher>[contains('Package has opted out')])),
      );
      expect(processRunner.recordedCalls, isNotEmpty);
    });

    test('skips running in vm mode if package opts out', () async {
      final RepositoryPackage package = createFakePackage(
        'a_package',
        packagesDir,
        extraFiles: <String>['test/empty_test.dart'],
      );
      package.directory.childFile('dart_test.yaml').writeAsStringSync('''
test_on: browser
''');

      final List<String> output = await runCapturingPrint(runner, <String>[
        'dart-test',
        '--platform=vm',
      ]);

      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('Package has opted out of vm testing.'),
        ]),
      );
      expect(processRunner.recordedCalls, orderedEquals(<ProcessCall>[]));
    });

    test('does not skip running browser in browser mode', () async {
      final RepositoryPackage package = createFakePackage(
        'a_package',
        packagesDir,
        extraFiles: <String>['test/empty_test.dart'],
      );
      package.directory.childFile('dart_test.yaml').writeAsStringSync('''
test_on: browser
''');

      final List<String> output = await runCapturingPrint(runner, <String>[
        'dart-test',
        '--platform=browser',
      ]);

      expect(
        output,
        isNot(containsAllInOrder(<Matcher>[contains('Package has opted out')])),
      );
      expect(processRunner.recordedCalls, isNotEmpty);
    });

    test(
      'tries to run for a test_on that the tool does not recognize',
      () async {
        final RepositoryPackage package = createFakePackage(
          'a_package',
          packagesDir,
          extraFiles: <String>['test/empty_test.dart'],
        );
        package.directory.childFile('dart_test.yaml').writeAsStringSync('''
test_on: !vm && firefox
''');

        await runCapturingPrint(runner, <String>['dart-test']);

        expect(
          processRunner.recordedCalls,
          orderedEquals(<ProcessCall>[
            ProcessCall('dart', const <String>['pub', 'get'], package.path),
            ProcessCall('dart', const <String>['run', 'test'], package.path),
          ]),
        );
      },
    );

    test('enable-experiment flag', () async {
      final RepositoryPackage plugin = createFakePlugin(
        'a',
        packagesDir,
        extraFiles: <String>['test/empty_test.dart'],
      );
      final RepositoryPackage package = createFakePackage(
        'b',
        packagesDir,
        extraFiles: <String>['test/empty_test.dart'],
      );

      await runCapturingPrint(runner, <String>[
        'dart-test',
        '--enable-experiment=exp1',
      ]);

      expect(
        processRunner.recordedCalls,
        orderedEquals(<ProcessCall>[
          ProcessCall(getFlutterCommand(mockPlatform), const <String>[
            'test',
            '--color',
            '--enable-experiment=exp1',
          ], plugin.path),
          ProcessCall('dart', const <String>['pub', 'get'], package.path),
          ProcessCall('dart', const <String>[
            'run',
            '--enable-experiment=exp1',
            'test',
          ], package.path),
        ]),
      );
    });

    group('file filtering', () {
      test('runs command for changes to Dart source', () async {
        createFakePackage('package_a', packagesDir);

        gitProcessRunner.mockProcessesForExecutable['git-diff'] =
            <FakeProcessInfo>[
              FakeProcessInfo(
                MockProcess(
                  stdout: '''
packages/package_a/foo.dart
''',
                ),
              ),
            ];

        final List<String> output = await runCapturingPrint(runner, <String>[
          'test',
        ]);

        expect(
          output,
          containsAllInOrder(<Matcher>[contains('Running for package_a')]),
        );
      });

      const files = <String>[
        'foo.java',
        'foo.kt',
        'foo.m',
        'foo.swift',
        'foo.c',
        'foo.cc',
        'foo.cpp',
        'foo.h',
      ];
      for (final file in files) {
        test('skips command for changes to non-Dart source $file', () async {
          createFakePackage('package_a', packagesDir);

          gitProcessRunner.mockProcessesForExecutable['git-diff'] =
              <FakeProcessInfo>[
                FakeProcessInfo(
                  MockProcess(
                    stdout:
                        '''
packages/package_a/$file
''',
                  ),
                ),
              ];

          final List<String> output = await runCapturingPrint(runner, <String>[
            'test',
          ]);

          expect(
            output,
            isNot(
              containsAllInOrder(<Matcher>[contains('Running for package_a')]),
            ),
          );
          expect(
            output,
            containsAllInOrder(<Matcher>[contains('SKIPPING ALL PACKAGES')]),
          );
        });
      }

      test('skips commands if all files should be ignored', () async {
        createFakePackage('package_a', packagesDir);

        gitProcessRunner.mockProcessesForExecutable['git-diff'] =
            <FakeProcessInfo>[
              FakeProcessInfo(
                MockProcess(
                  stdout: '''
README.md
CODEOWNERS
packages/package_a/CHANGELOG.md
''',
                ),
              ),
            ];

        final List<String> output = await runCapturingPrint(runner, <String>[
          'test',
        ]);

        expect(
          output,
          isNot(
            containsAllInOrder(<Matcher>[contains('Running for package_a')]),
          ),
        );
        expect(
          output,
          containsAllInOrder(<Matcher>[contains('SKIPPING ALL PACKAGES')]),
        );
      });
    });
  });
}
