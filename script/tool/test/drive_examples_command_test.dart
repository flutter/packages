// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';

import 'package:args/command_runner.dart';
import 'package:file/file.dart';
import 'package:file/memory.dart';
import 'package:flutter_plugin_tools/src/common/core.dart';
import 'package:flutter_plugin_tools/src/common/plugin_utils.dart';
import 'package:flutter_plugin_tools/src/drive_examples_command.dart';
import 'package:platform/platform.dart';
import 'package:test/test.dart';

import 'mocks.dart';
import 'util.dart';

const String _fakeIOSDevice = '67d5c3d1-8bdf-46ad-8f6b-b00e2a972dda';
const String _fakeAndroidDevice = 'emulator-1234';

void main() {
  group('test drive_example_command', () {
    late FileSystem fileSystem;
    late Platform mockPlatform;
    late Directory packagesDir;
    late CommandRunner<void> runner;
    late RecordingProcessRunner processRunner;

    setUp(() {
      fileSystem = MemoryFileSystem();
      mockPlatform = MockPlatform();
      packagesDir = createPackagesDirectory(fileSystem: fileSystem);
      processRunner = RecordingProcessRunner();
      final DriveExamplesCommand command = DriveExamplesCommand(packagesDir,
          processRunner: processRunner, platform: mockPlatform);

      runner = CommandRunner<void>(
          'drive_examples_command', 'Test for drive_example_command');
      runner.addCommand(command);

      // TODO(dit): Clean this up, https://github.com/flutter/flutter/issues/151869
      mockPlatform.environment['CHANNEL'] = 'master';
      mockPlatform.environment['FLUTTER_LOGS_DIR'] = '/path/to/logs';
    });

    void setMockFlutterDevicesOutput({
      bool hasIOSDevice = true,
      bool hasAndroidDevice = true,
      bool includeBanner = false,
    }) {
      const String updateBanner = '''
╔════════════════════════════════════════════════════════════════════════════╗
║ A new version of Flutter is available!                                     ║
║                                                                            ║
║ To update to the latest version, run "flutter upgrade".                    ║
╚════════════════════════════════════════════════════════════════════════════╝
''';
      final List<String> devices = <String>[
        if (hasIOSDevice) '{"id": "$_fakeIOSDevice", "targetPlatform": "ios"}',
        if (hasAndroidDevice)
          '{"id": "$_fakeAndroidDevice", "targetPlatform": "android-x86"}',
      ];
      final String output =
          '''${includeBanner ? updateBanner : ''}[${devices.join(',')}]''';

      final MockProcess mockDevicesProcess =
          MockProcess(stdout: output, stdoutEncoding: utf8);
      processRunner
              .mockProcessesForExecutable[getFlutterCommand(mockPlatform)] =
          <FakeProcessInfo>[
        FakeProcessInfo(mockDevicesProcess, <String>['devices'])
      ];
    }

    test('fails if no platforms are provided', () async {
      setMockFlutterDevicesOutput();
      Error? commandError;
      final List<String> output = await runCapturingPrint(
          runner, <String>['drive-examples'], errorHandler: (Error e) {
        commandError = e;
      });

      expect(commandError, isA<ToolExit>());
      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('Exactly one of'),
        ]),
      );
    });

    test('fails if wasm flag is present but not web platform', () async {
      setMockFlutterDevicesOutput();
      Error? commandError;
      final List<String> output = await runCapturingPrint(
          runner, <String>['drive-examples', '--android', '--wasm'],
          errorHandler: (Error e) {
        commandError = e;
      });

      expect(commandError, isA<ToolExit>());
      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('--wasm is only supported on the web platform'),
        ]),
      );
    });

    test('fails if multiple platforms are provided', () async {
      setMockFlutterDevicesOutput();
      Error? commandError;
      final List<String> output = await runCapturingPrint(
          runner, <String>['drive-examples', '--ios', '--macos'],
          errorHandler: (Error e) {
        commandError = e;
      });

      expect(commandError, isA<ToolExit>());
      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('Exactly one of'),
        ]),
      );
    });

    test('fails for iOS if no iOS devices are present', () async {
      setMockFlutterDevicesOutput(hasIOSDevice: false);

      Error? commandError;
      final List<String> output = await runCapturingPrint(
          runner, <String>['drive-examples', '--ios'], errorHandler: (Error e) {
        commandError = e;
      });

      expect(commandError, isA<ToolExit>());
      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('No iOS devices'),
        ]),
      );
    });

    test('handles flutter tool banners when checking devices', () async {
      createFakePlugin(
        'plugin',
        packagesDir,
        extraFiles: <String>[
          'example/test_driver/integration_test.dart',
          'example/integration_test/foo_test.dart',
          'example/ios/ios.m',
        ],
        platformSupport: <String, PlatformDetails>{
          platformIOS: const PlatformDetails(PlatformSupport.inline),
        },
      );

      setMockFlutterDevicesOutput(includeBanner: true);
      final List<String> output =
          await runCapturingPrint(runner, <String>['drive-examples', '--ios']);

      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('Running for plugin'),
          contains('No issues found!'),
        ]),
      );
    });

    test('fails for iOS if getting devices fails', () async {
      // Simulate failure from `flutter devices`.
      processRunner
              .mockProcessesForExecutable[getFlutterCommand(mockPlatform)] =
          <FakeProcessInfo>[
        FakeProcessInfo(MockProcess(exitCode: 1), <String>['devices'])
      ];

      Error? commandError;
      final List<String> output = await runCapturingPrint(
          runner, <String>['drive-examples', '--ios'], errorHandler: (Error e) {
        commandError = e;
      });

      expect(commandError, isA<ToolExit>());
      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('No iOS devices'),
        ]),
      );
    });

    test('fails for Android if no Android devices are present', () async {
      setMockFlutterDevicesOutput(hasAndroidDevice: false);
      Error? commandError;
      final List<String> output = await runCapturingPrint(
          runner, <String>['drive-examples', '--android'],
          errorHandler: (Error e) {
        commandError = e;
      });

      expect(commandError, isA<ToolExit>());
      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('No Android devices'),
        ]),
      );
    });

    test('a plugin without any integration test files is reported as an error',
        () async {
      setMockFlutterDevicesOutput();
      createFakePlugin(
        'plugin',
        packagesDir,
        extraFiles: <String>[
          'example/lib/main.dart',
          'example/android/android.java',
          'example/ios/ios.m',
        ],
        platformSupport: <String, PlatformDetails>{
          platformAndroid: const PlatformDetails(PlatformSupport.inline),
          platformIOS: const PlatformDetails(PlatformSupport.inline),
        },
      );

      Error? commandError;
      final List<String> output = await runCapturingPrint(
          runner, <String>['drive-examples', '--android'],
          errorHandler: (Error e) {
        commandError = e;
      });

      expect(commandError, isA<ToolExit>());
      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('Running for plugin'),
          contains('No driver tests were run (1 example(s) found).'),
          contains('No tests ran'),
        ]),
      );
    });

    test('integration tests using test(...) fail validation', () async {
      setMockFlutterDevicesOutput();
      final RepositoryPackage package = createFakePlugin(
        'plugin',
        packagesDir,
        extraFiles: <String>[
          'example/test_driver/integration_test.dart',
          'example/integration_test/foo_test.dart',
          'example/android/android.java',
        ],
        platformSupport: <String, PlatformDetails>{
          platformAndroid: const PlatformDetails(PlatformSupport.inline),
          platformIOS: const PlatformDetails(PlatformSupport.inline),
        },
      );
      package.directory
          .childDirectory('example')
          .childDirectory('integration_test')
          .childFile('foo_test.dart')
          .writeAsStringSync('''
   test('this is the wrong kind of test!'), () {
     ...
   }
''');

      Error? commandError;
      final List<String> output = await runCapturingPrint(
          runner, <String>['drive-examples', '--android'],
          errorHandler: (Error e) {
        commandError = e;
      });

      expect(commandError, isA<ToolExit>());
      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('foo_test.dart failed validation'),
        ]),
      );
    });

    test('tests an iOS plugin', () async {
      final RepositoryPackage plugin = createFakePlugin(
        'plugin',
        packagesDir,
        extraFiles: <String>[
          'example/integration_test/bar_test.dart',
          'example/integration_test/foo_test.dart',
          'example/integration_test/ignore_me.dart',
          'example/android/android.java',
          'example/ios/ios.m',
        ],
        platformSupport: <String, PlatformDetails>{
          platformAndroid: const PlatformDetails(PlatformSupport.inline),
          platformIOS: const PlatformDetails(PlatformSupport.inline),
        },
      );

      final Directory pluginExampleDirectory = getExampleDir(plugin);

      setMockFlutterDevicesOutput();
      final List<String> output =
          await runCapturingPrint(runner, <String>['drive-examples', '--ios']);

      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('Running for plugin'),
          contains('No issues found!'),
        ]),
      );

      expect(
          processRunner.recordedCalls,
          orderedEquals(<ProcessCall>[
            ProcessCall(getFlutterCommand(mockPlatform),
                const <String>['devices', '--machine'], null),
            ProcessCall(
                getFlutterCommand(mockPlatform),
                const <String>[
                  'test',
                  '-d',
                  _fakeIOSDevice,
                  '--debug-logs-dir=/path/to/logs',
                  'integration_test',
                ],
                pluginExampleDirectory.path),
          ]));
    });

    test('handles missing CI debug logs directory', () async {
      mockPlatform.environment.remove('FLUTTER_LOGS_DIR');

      final RepositoryPackage plugin = createFakePlugin(
        'plugin',
        packagesDir,
        extraFiles: <String>[
          'example/integration_test/bar_test.dart',
          'example/integration_test/foo_test.dart',
          'example/integration_test/ignore_me.dart',
          'example/android/android.java',
          'example/ios/ios.m',
        ],
        platformSupport: <String, PlatformDetails>{
          platformAndroid: const PlatformDetails(PlatformSupport.inline),
          platformIOS: const PlatformDetails(PlatformSupport.inline),
        },
      );

      final Directory pluginExampleDirectory = getExampleDir(plugin);

      setMockFlutterDevicesOutput();
      final List<String> output =
          await runCapturingPrint(runner, <String>['drive-examples', '--ios']);

      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('Running for plugin'),
          contains('No issues found!'),
        ]),
      );

      expect(
          processRunner.recordedCalls,
          orderedEquals(<ProcessCall>[
            ProcessCall(getFlutterCommand(mockPlatform),
                const <String>['devices', '--machine'], null),
            ProcessCall(
                getFlutterCommand(mockPlatform),
                const <String>[
                  'test',
                  '-d',
                  _fakeIOSDevice,
                  'integration_test',
                ],
                pluginExampleDirectory.path),
          ]));
    });

    test('driving when plugin does not support Linux is a no-op', () async {
      createFakePlugin('plugin', packagesDir, extraFiles: <String>[
        'example/integration_test/plugin_test.dart',
      ]);

      final List<String> output = await runCapturingPrint(runner, <String>[
        'drive-examples',
        '--linux',
      ]);

      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('Running for plugin'),
          contains('Skipping unsupported platform linux...'),
          contains('No issues found!'),
        ]),
      );

      // Output should be empty since running drive-examples --linux on a non-Linux
      // plugin is a no-op.
      expect(processRunner.recordedCalls, <ProcessCall>[]);
    });

    test('tests a Linux plugin', () async {
      final RepositoryPackage plugin = createFakePlugin(
        'plugin',
        packagesDir,
        extraFiles: <String>[
          'example/integration_test/plugin_test.dart',
          'example/linux/linux.cc',
        ],
        platformSupport: <String, PlatformDetails>{
          platformLinux: const PlatformDetails(PlatformSupport.inline),
        },
      );

      final Directory pluginExampleDirectory = getExampleDir(plugin);

      final List<String> output = await runCapturingPrint(runner, <String>[
        'drive-examples',
        '--linux',
      ]);

      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('Running for plugin'),
          contains('No issues found!'),
        ]),
      );

      expect(
          processRunner.recordedCalls,
          orderedEquals(<ProcessCall>[
            ProcessCall(
                getFlutterCommand(mockPlatform),
                const <String>[
                  'test',
                  '-d',
                  'linux',
                  '--debug-logs-dir=/path/to/logs',
                  'integration_test',
                ],
                pluginExampleDirectory.path),
          ]));
    });

    test('driving when plugin does not suppport macOS is a no-op', () async {
      createFakePlugin('plugin', packagesDir, extraFiles: <String>[
        'example/integration_test/plugin_test.dart',
      ]);

      final List<String> output = await runCapturingPrint(runner, <String>[
        'drive-examples',
        '--macos',
      ]);

      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('Running for plugin'),
          contains('Skipping unsupported platform macos...'),
          contains('No issues found!'),
        ]),
      );

      // Output should be empty since running drive-examples --macos with no macos
      // implementation is a no-op.
      expect(processRunner.recordedCalls, <ProcessCall>[]);
    });

    test('tests a macOS plugin', () async {
      final RepositoryPackage plugin = createFakePlugin(
        'plugin',
        packagesDir,
        extraFiles: <String>[
          'example/integration_test/plugin_test.dart',
          'example/macos/macos.swift',
        ],
        platformSupport: <String, PlatformDetails>{
          platformMacOS: const PlatformDetails(PlatformSupport.inline),
        },
      );

      final Directory pluginExampleDirectory = getExampleDir(plugin);

      final List<String> output = await runCapturingPrint(runner, <String>[
        'drive-examples',
        '--macos',
      ]);

      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('Running for plugin'),
          contains('No issues found!'),
        ]),
      );

      expect(
          processRunner.recordedCalls,
          orderedEquals(<ProcessCall>[
            ProcessCall(
                getFlutterCommand(mockPlatform),
                const <String>[
                  'test',
                  '-d',
                  'macos',
                  '--debug-logs-dir=/path/to/logs',
                  'integration_test',
                ],
                pluginExampleDirectory.path),
          ]));
    });

    // This tests the workaround for https://github.com/flutter/flutter/issues/135673
    // and the behavior it tests should be removed once that is fixed.
    group('runs tests separately on desktop', () {
      test('macOS', () async {
        final RepositoryPackage plugin = createFakePlugin(
          'plugin',
          packagesDir,
          extraFiles: <String>[
            'example/integration_test/first_test.dart',
            'example/integration_test/second_test.dart',
            'example/macos/macos.swift',
          ],
          platformSupport: <String, PlatformDetails>{
            platformMacOS: const PlatformDetails(PlatformSupport.inline),
          },
        );

        final Directory pluginExampleDirectory = getExampleDir(plugin);

        final List<String> output = await runCapturingPrint(runner, <String>[
          'drive-examples',
          '--macos',
        ]);

        expect(
          output,
          containsAllInOrder(<Matcher>[
            contains('Running for plugin'),
            contains('No issues found!'),
          ]),
        );

        expect(
            processRunner.recordedCalls,
            orderedEquals(<ProcessCall>[
              ProcessCall(
                  getFlutterCommand(mockPlatform),
                  const <String>[
                    'test',
                    '-d',
                    'macos',
                    '--debug-logs-dir=/path/to/logs',
                    'integration_test/first_test.dart',
                  ],
                  pluginExampleDirectory.path),
              ProcessCall(
                  getFlutterCommand(mockPlatform),
                  const <String>[
                    'test',
                    '-d',
                    'macos',
                    '--debug-logs-dir=/path/to/logs',
                    'integration_test/second_test.dart',
                  ],
                  pluginExampleDirectory.path),
            ]));
      });

      // This tests the workaround for https://github.com/flutter/flutter/issues/135673
      // and the behavior it tests should be removed once that is fixed.
      test('Linux', () async {
        final RepositoryPackage plugin = createFakePlugin(
          'plugin',
          packagesDir,
          extraFiles: <String>[
            'example/integration_test/first_test.dart',
            'example/integration_test/second_test.dart',
            'example/linux/foo.cc',
          ],
          platformSupport: <String, PlatformDetails>{
            platformLinux: const PlatformDetails(PlatformSupport.inline),
          },
        );

        final Directory pluginExampleDirectory = getExampleDir(plugin);

        final List<String> output = await runCapturingPrint(runner, <String>[
          'drive-examples',
          '--linux',
        ]);

        expect(
          output,
          containsAllInOrder(<Matcher>[
            contains('Running for plugin'),
            contains('No issues found!'),
          ]),
        );

        expect(
            processRunner.recordedCalls,
            orderedEquals(<ProcessCall>[
              ProcessCall(
                  getFlutterCommand(mockPlatform),
                  const <String>[
                    'test',
                    '-d',
                    'linux',
                    '--debug-logs-dir=/path/to/logs',
                    'integration_test/first_test.dart',
                  ],
                  pluginExampleDirectory.path),
              ProcessCall(
                  getFlutterCommand(mockPlatform),
                  const <String>[
                    'test',
                    '-d',
                    'linux',
                    '--debug-logs-dir=/path/to/logs',
                    'integration_test/second_test.dart',
                  ],
                  pluginExampleDirectory.path),
            ]));
      });

      // This tests the workaround for https://github.com/flutter/flutter/issues/135673
      // and the behavior it tests should be removed once that is fixed.
      test('Windows', () async {
        final RepositoryPackage plugin = createFakePlugin(
          'plugin',
          packagesDir,
          extraFiles: <String>[
            'example/integration_test/first_test.dart',
            'example/integration_test/second_test.dart',
            'example/windows/foo.cpp',
          ],
          platformSupport: <String, PlatformDetails>{
            platformWindows: const PlatformDetails(PlatformSupport.inline),
          },
        );

        final Directory pluginExampleDirectory = getExampleDir(plugin);

        final List<String> output = await runCapturingPrint(runner, <String>[
          'drive-examples',
          '--windows',
        ]);

        expect(
          output,
          containsAllInOrder(<Matcher>[
            contains('Running for plugin'),
            contains('No issues found!'),
          ]),
        );

        expect(
            processRunner.recordedCalls,
            orderedEquals(<ProcessCall>[
              ProcessCall(
                  getFlutterCommand(mockPlatform),
                  const <String>[
                    'test',
                    '-d',
                    'windows',
                    '--debug-logs-dir=/path/to/logs',
                    'integration_test/first_test.dart',
                  ],
                  pluginExampleDirectory.path),
              ProcessCall(
                  getFlutterCommand(mockPlatform),
                  const <String>[
                    'test',
                    '-d',
                    'windows',
                    '--debug-logs-dir=/path/to/logs',
                    'integration_test/second_test.dart',
                  ],
                  pluginExampleDirectory.path),
            ]));
      });
    });

    test('driving when plugin does not suppport web is a no-op', () async {
      createFakePlugin('plugin', packagesDir, extraFiles: <String>[
        'example/integration_test/plugin_test.dart',
      ]);

      final List<String> output = await runCapturingPrint(runner, <String>[
        'drive-examples',
        '--web',
      ]);

      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('Running for plugin'),
          contains('No issues found!'),
        ]),
      );

      // Output should be empty since running drive-examples --web on a non-web
      // plugin is a no-op.
      expect(processRunner.recordedCalls, <ProcessCall>[]);
    });

    test('drives a web plugin', () async {
      final RepositoryPackage plugin = createFakePlugin(
        'plugin',
        packagesDir,
        extraFiles: <String>[
          'example/integration_test/plugin_test.dart',
          'example/test_driver/integration_test.dart',
          'example/web/index.html',
        ],
        platformSupport: <String, PlatformDetails>{
          platformWeb: const PlatformDetails(PlatformSupport.inline),
        },
      );

      final Directory pluginExampleDirectory = getExampleDir(plugin);

      final List<String> output = await runCapturingPrint(runner, <String>[
        'drive-examples',
        '--web',
      ]);

      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('Running for plugin'),
          contains('No issues found!'),
        ]),
      );

      expect(
          processRunner.recordedCalls,
          orderedEquals(<ProcessCall>[
            ProcessCall(
                getFlutterCommand(mockPlatform),
                const <String>[
                  'drive',
                  '-d',
                  'web-server',
                  '--web-port=7357',
                  '--browser-name=chrome',
                  '--screenshot=/path/to/logs/plugin_example-drive',
                  '--driver',
                  'test_driver/integration_test.dart',
                  '--target',
                  'integration_test/plugin_test.dart',
                ],
                pluginExampleDirectory.path),
          ]));
    });

    test('drives a web plugin compiled to WASM', () async {
      final RepositoryPackage plugin = createFakePlugin(
        'plugin',
        packagesDir,
        extraFiles: <String>[
          'example/integration_test/plugin_test.dart',
          'example/test_driver/integration_test.dart',
          'example/web/index.html',
        ],
        platformSupport: <String, PlatformDetails>{
          platformWeb: const PlatformDetails(PlatformSupport.inline),
        },
      );

      final Directory pluginExampleDirectory = getExampleDir(plugin);

      final List<String> output = await runCapturingPrint(runner, <String>[
        'drive-examples',
        '--web',
        '--wasm',
      ]);

      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('Running for plugin'),
          contains('No issues found!'),
        ]),
      );

      expect(
          processRunner.recordedCalls,
          orderedEquals(<ProcessCall>[
            ProcessCall(
                getFlutterCommand(mockPlatform),
                const <String>[
                  'drive',
                  '-d',
                  'web-server',
                  '--web-port=7357',
                  '--browser-name=chrome',
                  '--wasm',
                  '--screenshot=/path/to/logs/plugin_example-drive',
                  '--driver',
                  'test_driver/integration_test.dart',
                  '--target',
                  'integration_test/plugin_test.dart',
                ],
                pluginExampleDirectory.path),
          ]));
    });

    test('runs chromedriver when requested', () async {
      final RepositoryPackage plugin = createFakePlugin(
        'plugin',
        packagesDir,
        extraFiles: <String>[
          'example/integration_test/plugin_test.dart',
          'example/test_driver/integration_test.dart',
          'example/web/index.html',
        ],
        platformSupport: <String, PlatformDetails>{
          platformWeb: const PlatformDetails(PlatformSupport.inline),
        },
      );

      final Directory pluginExampleDirectory = getExampleDir(plugin);

      final List<String> output = await runCapturingPrint(
          runner, <String>['drive-examples', '--web', '--run-chromedriver']);

      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('Running for plugin'),
          contains('No issues found!'),
        ]),
      );

      expect(
          processRunner.recordedCalls,
          orderedEquals(<ProcessCall>[
            const ProcessCall('chromedriver', <String>['--port=4444'], null),
            ProcessCall(
                getFlutterCommand(mockPlatform),
                const <String>[
                  'drive',
                  '-d',
                  'web-server',
                  '--web-port=7357',
                  '--browser-name=chrome',
                  '--screenshot=/path/to/logs/plugin_example-drive',
                  '--driver',
                  'test_driver/integration_test.dart',
                  '--target',
                  'integration_test/plugin_test.dart',
                ],
                pluginExampleDirectory.path),
          ]));
    });

    test('drives a web plugin with CHROME_EXECUTABLE', () async {
      final RepositoryPackage plugin = createFakePlugin(
        'plugin',
        packagesDir,
        extraFiles: <String>[
          'example/integration_test/plugin_test.dart',
          'example/test_driver/integration_test.dart',
          'example/web/index.html',
        ],
        platformSupport: <String, PlatformDetails>{
          platformWeb: const PlatformDetails(PlatformSupport.inline),
        },
      );

      final Directory pluginExampleDirectory = getExampleDir(plugin);

      mockPlatform.environment['CHROME_EXECUTABLE'] = '/path/to/chrome';

      final List<String> output = await runCapturingPrint(runner, <String>[
        'drive-examples',
        '--web',
      ]);

      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('Running for plugin'),
          contains('No issues found!'),
        ]),
      );

      expect(
          processRunner.recordedCalls,
          orderedEquals(<ProcessCall>[
            ProcessCall(
                getFlutterCommand(mockPlatform),
                const <String>[
                  'drive',
                  '-d',
                  'web-server',
                  '--web-port=7357',
                  '--browser-name=chrome',
                  '--chrome-binary=/path/to/chrome',
                  '--screenshot=/path/to/logs/plugin_example-drive',
                  '--driver',
                  'test_driver/integration_test.dart',
                  '--target',
                  'integration_test/plugin_test.dart',
                ],
                pluginExampleDirectory.path),
          ]));
    });

    test('driving when plugin does not suppport Windows is a no-op', () async {
      createFakePlugin('plugin', packagesDir, extraFiles: <String>[
        'example/integration_test/plugin_test.dart',
      ]);

      final List<String> output = await runCapturingPrint(runner, <String>[
        'drive-examples',
        '--windows',
      ]);

      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('Running for plugin'),
          contains('Skipping unsupported platform windows...'),
          contains('No issues found!'),
        ]),
      );

      // Output should be empty since running drive-examples --windows on a
      // non-Windows plugin is a no-op.
      expect(processRunner.recordedCalls, <ProcessCall>[]);
    });

    test('tests a Windows plugin', () async {
      final RepositoryPackage plugin = createFakePlugin(
        'plugin',
        packagesDir,
        extraFiles: <String>[
          'example/integration_test/plugin_test.dart',
          'example/windows/windows.cpp',
        ],
        platformSupport: <String, PlatformDetails>{
          platformWindows: const PlatformDetails(PlatformSupport.inline),
        },
      );

      final Directory pluginExampleDirectory = getExampleDir(plugin);

      final List<String> output = await runCapturingPrint(runner, <String>[
        'drive-examples',
        '--windows',
      ]);

      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('Running for plugin'),
          contains('No issues found!'),
        ]),
      );

      expect(
          processRunner.recordedCalls,
          orderedEquals(<ProcessCall>[
            ProcessCall(
                getFlutterCommand(mockPlatform),
                const <String>[
                  'test',
                  '-d',
                  'windows',
                  '--debug-logs-dir=/path/to/logs',
                  'integration_test',
                ],
                pluginExampleDirectory.path),
          ]));
    });

    test('tests an Android plugin', () async {
      final RepositoryPackage plugin = createFakePlugin(
        'plugin',
        packagesDir,
        extraFiles: <String>[
          'example/integration_test/plugin_test.dart',
          'example/android/android.java',
        ],
        platformSupport: <String, PlatformDetails>{
          platformAndroid: const PlatformDetails(PlatformSupport.inline),
        },
      );

      final Directory pluginExampleDirectory = getExampleDir(plugin);

      setMockFlutterDevicesOutput();
      final List<String> output = await runCapturingPrint(runner, <String>[
        'drive-examples',
        '--android',
      ]);

      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('Running for plugin'),
          contains('No issues found!'),
        ]),
      );

      expect(
          processRunner.recordedCalls,
          orderedEquals(<ProcessCall>[
            ProcessCall(getFlutterCommand(mockPlatform),
                const <String>['devices', '--machine'], null),
            ProcessCall(
                getFlutterCommand(mockPlatform),
                const <String>[
                  'test',
                  '-d',
                  _fakeAndroidDevice,
                  '--debug-logs-dir=/path/to/logs',
                  'integration_test',
                ],
                pluginExampleDirectory.path),
          ]));
    });

    test('tests an Android plugin with "apk" alias', () async {
      final RepositoryPackage plugin = createFakePlugin(
        'plugin',
        packagesDir,
        extraFiles: <String>[
          'example/integration_test/plugin_test.dart',
          'example/android/android.java',
        ],
        platformSupport: <String, PlatformDetails>{
          platformAndroid: const PlatformDetails(PlatformSupport.inline),
        },
      );

      final Directory pluginExampleDirectory = getExampleDir(plugin);

      setMockFlutterDevicesOutput();
      final List<String> output = await runCapturingPrint(runner, <String>[
        'drive-examples',
        '--apk',
      ]);

      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('Running for plugin'),
          contains('No issues found!'),
        ]),
      );

      expect(
          processRunner.recordedCalls,
          orderedEquals(<ProcessCall>[
            ProcessCall(getFlutterCommand(mockPlatform),
                const <String>['devices', '--machine'], null),
            ProcessCall(
                getFlutterCommand(mockPlatform),
                const <String>[
                  'test',
                  '-d',
                  _fakeAndroidDevice,
                  '--debug-logs-dir=/path/to/logs',
                  'integration_test',
                ],
                pluginExampleDirectory.path),
          ]));
    });

    test('driving when plugin does not support Android is no-op', () async {
      createFakePlugin(
        'plugin',
        packagesDir,
        extraFiles: <String>[
          'example/integration_test/plugin_test.dart',
        ],
        platformSupport: <String, PlatformDetails>{
          platformMacOS: const PlatformDetails(PlatformSupport.inline),
        },
      );

      setMockFlutterDevicesOutput();
      final List<String> output = await runCapturingPrint(
          runner, <String>['drive-examples', '--android']);

      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('Running for plugin'),
          contains('Skipping unsupported platform android...'),
          contains('No issues found!'),
        ]),
      );

      // Output should be empty other than the device query.
      expect(processRunner.recordedCalls, <ProcessCall>[
        ProcessCall(getFlutterCommand(mockPlatform),
            const <String>['devices', '--machine'], null),
      ]);
    });

    test('driving when plugin does not support iOS is no-op', () async {
      createFakePlugin(
        'plugin',
        packagesDir,
        extraFiles: <String>[
          'example/integration_test/plugin_test.dart',
        ],
        platformSupport: <String, PlatformDetails>{
          platformMacOS: const PlatformDetails(PlatformSupport.inline),
        },
      );

      setMockFlutterDevicesOutput();
      final List<String> output =
          await runCapturingPrint(runner, <String>['drive-examples', '--ios']);

      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('Running for plugin'),
          contains('Skipping unsupported platform ios...'),
          contains('No issues found!'),
        ]),
      );

      // Output should be empty other than the device query.
      expect(processRunner.recordedCalls, <ProcessCall>[
        ProcessCall(getFlutterCommand(mockPlatform),
            const <String>['devices', '--machine'], null),
      ]);
    });

    test('platform interface plugins are silently skipped', () async {
      createFakePlugin('aplugin_platform_interface', packagesDir,
          examples: <String>[]);

      setMockFlutterDevicesOutput();
      final List<String> output = await runCapturingPrint(
          runner, <String>['drive-examples', '--macos']);

      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('Running for aplugin_platform_interface'),
          contains(
              'SKIPPING: Platform interfaces are not expected to have integration tests.'),
          contains('No issues found!'),
        ]),
      );

      // Output should be empty since it's skipped.
      expect(processRunner.recordedCalls, <ProcessCall>[]);
    });

    test('enable-experiment flag', () async {
      final RepositoryPackage plugin = createFakePlugin(
        'plugin',
        packagesDir,
        extraFiles: <String>[
          'example/integration_test/plugin_test.dart',
          'example/android/android.java',
          'example/ios/ios.m',
        ],
        platformSupport: <String, PlatformDetails>{
          platformAndroid: const PlatformDetails(PlatformSupport.inline),
          platformIOS: const PlatformDetails(PlatformSupport.inline),
        },
      );

      final Directory pluginExampleDirectory = getExampleDir(plugin);

      setMockFlutterDevicesOutput();
      await runCapturingPrint(runner, <String>[
        'drive-examples',
        '--ios',
        '--enable-experiment=exp1',
      ]);

      expect(
          processRunner.recordedCalls,
          orderedEquals(<ProcessCall>[
            ProcessCall(getFlutterCommand(mockPlatform),
                const <String>['devices', '--machine'], null),
            ProcessCall(
                getFlutterCommand(mockPlatform),
                const <String>[
                  'test',
                  '-d',
                  _fakeIOSDevice,
                  '--enable-experiment=exp1',
                  '--debug-logs-dir=/path/to/logs',
                  'integration_test',
                ],
                pluginExampleDirectory.path),
          ]));
    });

    test('fails when no example is present', () async {
      createFakePlugin(
        'plugin',
        packagesDir,
        examples: <String>[],
        platformSupport: <String, PlatformDetails>{
          platformWeb: const PlatformDetails(PlatformSupport.inline),
        },
      );

      Error? commandError;
      final List<String> output = await runCapturingPrint(
          runner, <String>['drive-examples', '--web'], errorHandler: (Error e) {
        commandError = e;
      });

      expect(commandError, isA<ToolExit>());
      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('Running for plugin'),
          contains('No driver tests were run (0 example(s) found).'),
          contains('The following packages had errors:'),
          contains('  plugin:\n'
              '    No tests ran (use --exclude if this is intentional)'),
        ]),
      );
    });

    test('web fails when no driver is present', () async {
      createFakePlugin(
        'plugin',
        packagesDir,
        extraFiles: <String>[
          'example/integration_test/bar_test.dart',
          'example/integration_test/foo_test.dart',
          'example/web/index.html',
        ],
        platformSupport: <String, PlatformDetails>{
          platformWeb: const PlatformDetails(PlatformSupport.inline),
        },
      );

      Error? commandError;
      final List<String> output = await runCapturingPrint(
          runner, <String>['drive-examples', '--web'], errorHandler: (Error e) {
        commandError = e;
      });

      expect(commandError, isA<ToolExit>());
      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('Running for plugin'),
          contains('No driver found for plugin/example'),
          contains('No driver tests were run (1 example(s) found).'),
          contains('The following packages had errors:'),
          contains('  plugin:\n'
              '    No tests ran (use --exclude if this is intentional)'),
        ]),
      );
    });

    test('web fails when no integration tests are present', () async {
      createFakePlugin(
        'plugin',
        packagesDir,
        extraFiles: <String>[
          'example/test_driver/integration_test.dart',
          'example/web/index.html',
        ],
        platformSupport: <String, PlatformDetails>{
          platformWeb: const PlatformDetails(PlatformSupport.inline),
        },
      );

      Error? commandError;
      final List<String> output = await runCapturingPrint(
          runner, <String>['drive-examples', '--web'], errorHandler: (Error e) {
        commandError = e;
      });

      expect(commandError, isA<ToolExit>());
      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('Running for plugin'),
          contains('No driver tests were run (1 example(s) found).'),
          contains('The following packages had errors:'),
          contains('  plugin:\n'
              '    No tests ran (use --exclude if this is intentional)'),
        ]),
      );
    });

    test('"flutter drive" reports test failures', () async {
      final RepositoryPackage plugin = createFakePlugin(
        'plugin',
        packagesDir,
        extraFiles: <String>[
          'example/test_driver/integration_test.dart',
          'example/integration_test/bar_test.dart',
          'example/integration_test/foo_test.dart',
          'example/web/index.html',
        ],
        platformSupport: <String, PlatformDetails>{
          platformWeb: const PlatformDetails(PlatformSupport.inline),
        },
      );

      // Simulate failure from `flutter drive`.
      processRunner
              .mockProcessesForExecutable[getFlutterCommand(mockPlatform)] =
          <FakeProcessInfo>[
        // Fail both bar_test.dart and foo_test.dart.
        FakeProcessInfo(MockProcess(exitCode: 1), <String>['drive']),
        FakeProcessInfo(MockProcess(exitCode: 1), <String>['drive']),
      ];

      Error? commandError;
      final List<String> output = await runCapturingPrint(
          runner, <String>['drive-examples', '--web'], errorHandler: (Error e) {
        commandError = e;
      });

      expect(commandError, isA<ToolExit>());
      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('Running for plugin'),
          contains('The following packages had errors:'),
          contains('  plugin:\n'
              '    example/integration_test/bar_test.dart\n'
              '    example/integration_test/foo_test.dart'),
        ]),
      );

      final Directory pluginExampleDirectory = getExampleDir(plugin);
      expect(
          processRunner.recordedCalls,
          orderedEquals(<ProcessCall>[
            ProcessCall(
                getFlutterCommand(mockPlatform),
                const <String>[
                  'drive',
                  '-d',
                  'web-server',
                  '--web-port=7357',
                  '--browser-name=chrome',
                  '--screenshot=/path/to/logs/plugin_example-drive',
                  '--driver',
                  'test_driver/integration_test.dart',
                  '--target',
                  'integration_test/bar_test.dart',
                ],
                pluginExampleDirectory.path),
            ProcessCall(
                getFlutterCommand(mockPlatform),
                const <String>[
                  'drive',
                  '-d',
                  'web-server',
                  '--web-port=7357',
                  '--browser-name=chrome',
                  '--screenshot=/path/to/logs/plugin_example-drive',
                  '--driver',
                  'test_driver/integration_test.dart',
                  '--target',
                  'integration_test/foo_test.dart',
                ],
                pluginExampleDirectory.path),
          ]));
    });

    test('"flutter test" reports test failures', () async {
      final RepositoryPackage plugin = createFakePlugin(
        'plugin',
        packagesDir,
        extraFiles: <String>[
          'example/integration_test/bar_test.dart',
          'example/integration_test/foo_test.dart',
          'example/ios/ios.swift',
        ],
        platformSupport: <String, PlatformDetails>{
          platformIOS: const PlatformDetails(PlatformSupport.inline),
        },
      );

      setMockFlutterDevicesOutput();
      // Simulate failure from `flutter test`.
      processRunner.mockProcessesForExecutable[getFlutterCommand(mockPlatform)]!
          .add(FakeProcessInfo(MockProcess(exitCode: 1), <String>['test']));

      Error? commandError;
      final List<String> output = await runCapturingPrint(
          runner, <String>['drive-examples', '--ios'], errorHandler: (Error e) {
        commandError = e;
      });

      expect(commandError, isA<ToolExit>());
      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('Running for plugin'),
          contains('The following packages had errors:'),
          contains('  plugin:\n'
              '    Integration tests failed.'),
        ]),
      );

      final Directory pluginExampleDirectory = getExampleDir(plugin);
      expect(
          processRunner.recordedCalls,
          orderedEquals(<ProcessCall>[
            ProcessCall(getFlutterCommand(mockPlatform),
                const <String>['devices', '--machine'], null),
            ProcessCall(
                getFlutterCommand(mockPlatform),
                const <String>[
                  'test',
                  '-d',
                  _fakeIOSDevice,
                  '--debug-logs-dir=/path/to/logs',
                  'integration_test',
                ],
                pluginExampleDirectory.path),
          ]));
    });

    group('packages', () {
      test('can be driven', () async {
        final RepositoryPackage package =
            createFakePackage('a_package', packagesDir, extraFiles: <String>[
          'example/integration_test/foo_test.dart',
          'example/test_driver/integration_test.dart',
          'example/web/index.html',
        ]);
        final Directory exampleDirectory = getExampleDir(package);

        final List<String> output = await runCapturingPrint(runner, <String>[
          'drive-examples',
          '--web',
        ]);

        expect(
          output,
          containsAllInOrder(<Matcher>[
            contains('Running for a_package'),
            contains('No issues found!'),
          ]),
        );

        expect(
            processRunner.recordedCalls,
            orderedEquals(<ProcessCall>[
              ProcessCall(
                  getFlutterCommand(mockPlatform),
                  const <String>[
                    'drive',
                    '-d',
                    'web-server',
                    '--web-port=7357',
                    '--browser-name=chrome',
                    '--screenshot=/path/to/logs/a_package_example-drive',
                    '--driver',
                    'test_driver/integration_test.dart',
                    '--target',
                    'integration_test/foo_test.dart'
                  ],
                  exampleDirectory.path),
            ]));
      });

      test('drive handles missing CI screenshot directory', () async {
        mockPlatform.environment.remove('FLUTTER_LOGS_DIR');

        final RepositoryPackage package =
            createFakePackage('a_package', packagesDir, extraFiles: <String>[
          'example/integration_test/foo_test.dart',
          'example/test_driver/integration_test.dart',
          'example/web/index.html',
        ]);
        final Directory exampleDirectory = getExampleDir(package);

        final List<String> output = await runCapturingPrint(runner, <String>[
          'drive-examples',
          '--web',
        ]);

        expect(
          output,
          containsAllInOrder(<Matcher>[
            contains('Running for a_package'),
            contains('No issues found!'),
          ]),
        );

        expect(
            processRunner.recordedCalls,
            orderedEquals(<ProcessCall>[
              ProcessCall(
                  getFlutterCommand(mockPlatform),
                  const <String>[
                    'drive',
                    '-d',
                    'web-server',
                    '--web-port=7357',
                    '--browser-name=chrome',
                    '--driver',
                    'test_driver/integration_test.dart',
                    '--target',
                    'integration_test/foo_test.dart'
                  ],
                  exampleDirectory.path),
            ]));
      });

      test('are skipped when example does not support platform', () async {
        createFakePackage('a_package', packagesDir,
            isFlutter: true,
            extraFiles: <String>[
              'example/integration_test/foo_test.dart',
              'example/test_driver/integration_test.dart',
            ]);

        final List<String> output = await runCapturingPrint(runner, <String>[
          'drive-examples',
          '--web',
        ]);

        expect(
          output,
          containsAllInOrder(<Matcher>[
            contains('Running for a_package'),
            contains('Skipping a_package/example; does not support any '
                'requested platforms'),
            contains('SKIPPING: No example supports requested platform(s).'),
          ]),
        );

        expect(processRunner.recordedCalls.isEmpty, true);
      });

      test('drive only supported examples if there is more than one', () async {
        final RepositoryPackage package = createFakePackage(
            'a_package', packagesDir,
            isFlutter: true,
            examples: <String>[
              'with_web',
              'without_web'
            ],
            extraFiles: <String>[
              'example/with_web/integration_test/foo_test.dart',
              'example/with_web/test_driver/integration_test.dart',
              'example/with_web/web/index.html',
              'example/without_web/integration_test/foo_test.dart',
              'example/without_web/test_driver/integration_test.dart',
            ]);
        final Directory supportedExampleDirectory =
            getExampleDir(package).childDirectory('with_web');

        final List<String> output = await runCapturingPrint(runner, <String>[
          'drive-examples',
          '--web',
        ]);

        expect(
          output,
          containsAllInOrder(<Matcher>[
            contains('Running for a_package'),
            contains(
                'Skipping a_package/example/without_web; does not support any requested platforms.'),
            contains('No issues found!'),
          ]),
        );

        expect(
            processRunner.recordedCalls,
            orderedEquals(<ProcessCall>[
              ProcessCall(
                  getFlutterCommand(mockPlatform),
                  const <String>[
                    'drive',
                    '-d',
                    'web-server',
                    '--web-port=7357',
                    '--browser-name=chrome',
                    '--screenshot=/path/to/logs/a_package_example_with_web-drive',
                    '--driver',
                    'test_driver/integration_test.dart',
                    '--target',
                    'integration_test/foo_test.dart'
                  ],
                  supportedExampleDirectory.path),
            ]));
      });

      test('are skipped when there is no integration testing', () async {
        createFakePackage('a_package', packagesDir,
            isFlutter: true, extraFiles: <String>['example/web/index.html']);

        final List<String> output = await runCapturingPrint(runner, <String>[
          'drive-examples',
          '--web',
        ]);

        expect(
          output,
          containsAllInOrder(<Matcher>[
            contains('Running for a_package'),
            contains(
                'SKIPPING: No example is configured for integration tests.'),
          ]),
        );

        expect(processRunner.recordedCalls.isEmpty, true);
      });
    });
  });
}
