// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:args/command_runner.dart';
import 'package:file/file.dart';
import 'package:flutter_plugin_tools/src/build_examples_command.dart';
import 'package:flutter_plugin_tools/src/common/core.dart';
import 'package:flutter_plugin_tools/src/common/plugin_utils.dart';
import 'package:git/git.dart';
import 'package:test/test.dart';

import 'mocks.dart';
import 'util.dart';

void main() {
  group('build-example', () {
    late MockPlatform mockPlatform;
    late Directory packagesDir;
    late CommandRunner<void> runner;
    late RecordingProcessRunner processRunner;
    late RecordingProcessRunner gitProcessRunner;

    setUp(() {
      mockPlatform = MockPlatform();
      final GitDir gitDir;
      (:packagesDir, :processRunner, :gitProcessRunner, :gitDir) =
          configureBaseCommandMocks(platform: mockPlatform);
      final BuildExamplesCommand command = BuildExamplesCommand(
        packagesDir,
        processRunner: processRunner,
        platform: mockPlatform,
        gitDir: gitDir,
      );

      runner = CommandRunner<void>(
          'build_examples_command', 'Test for build_example_command');
      runner.addCommand(command);
    });

    test('fails if no plaform flags are passed', () async {
      Error? commandError;
      final List<String> output = await runCapturingPrint(
          runner, <String>['build-examples'], errorHandler: (Error e) {
        commandError = e;
      });

      expect(commandError, isA<ToolExit>());
      expect(
          output,
          containsAllInOrder(<Matcher>[
            contains('At least one platform must be provided'),
          ]));
    });

    test('fails if building fails', () async {
      createFakePlugin('plugin', packagesDir,
          platformSupport: <String, PlatformDetails>{
            platformIOS: const PlatformDetails(PlatformSupport.inline),
          });

      processRunner
              .mockProcessesForExecutable[getFlutterCommand(mockPlatform)] =
          <FakeProcessInfo>[
        FakeProcessInfo(MockProcess(exitCode: 1), <String>['build'])
      ];

      Error? commandError;
      final List<String> output = await runCapturingPrint(
          runner, <String>['build-examples', '--ios'], errorHandler: (Error e) {
        commandError = e;
      });

      expect(commandError, isA<ToolExit>());
      expect(
          output,
          containsAllInOrder(<Matcher>[
            contains('The following packages had errors:'),
            contains('  plugin:\n'
                '    plugin/example (iOS)'),
          ]));
    });

    test('fails if a plugin has no examples', () async {
      createFakePlugin('plugin', packagesDir,
          examples: <String>[],
          platformSupport: <String, PlatformDetails>{
            platformIOS: const PlatformDetails(PlatformSupport.inline)
          });

      processRunner
              .mockProcessesForExecutable[getFlutterCommand(mockPlatform)] =
          <FakeProcessInfo>[
        FakeProcessInfo(MockProcess(exitCode: 1), <String>['pub', 'get'])
      ];

      Error? commandError;
      final List<String> output = await runCapturingPrint(
          runner, <String>['build-examples', '--ios'], errorHandler: (Error e) {
        commandError = e;
      });

      expect(commandError, isA<ToolExit>());
      expect(
          output,
          containsAllInOrder(<Matcher>[
            contains('The following packages had errors:'),
            contains('  plugin:\n'
                '    No examples found'),
          ]));
    });

    test('building for iOS when plugin is not set up for iOS results in no-op',
        () async {
      mockPlatform.isMacOS = true;
      createFakePlugin('plugin', packagesDir);

      final List<String> output =
          await runCapturingPrint(runner, <String>['build-examples', '--ios']);

      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('Running for plugin'),
          contains('iOS is not supported by this plugin'),
        ]),
      );

      // Output should be empty since running build-examples --macos with no macos
      // implementation is a no-op.
      expect(processRunner.recordedCalls, orderedEquals(<ProcessCall>[]));
    });

    test('building for iOS', () async {
      mockPlatform.isMacOS = true;
      final RepositoryPackage plugin = createFakePlugin('plugin', packagesDir,
          platformSupport: <String, PlatformDetails>{
            platformIOS: const PlatformDetails(PlatformSupport.inline),
          });

      final Directory pluginExampleDirectory = getExampleDir(plugin);

      final List<String> output = await runCapturingPrint(runner,
          <String>['build-examples', '--ios', '--enable-experiment=exp1']);

      expect(
        output,
        containsAllInOrder(<String>[
          '\nBUILDING plugin/example for iOS',
        ]),
      );

      expect(
          processRunner.recordedCalls,
          orderedEquals(<ProcessCall>[
            ProcessCall(
                getFlutterCommand(mockPlatform),
                const <String>[
                  'build',
                  'ios',
                  '--no-codesign',
                  '--enable-experiment=exp1'
                ],
                pluginExampleDirectory.path),
          ]));
    });

    test('building for iOS with CocoaPods', () async {
      mockPlatform.isMacOS = true;

      final RepositoryPackage plugin = createFakePlugin('plugin', packagesDir,
          platformSupport: <String, PlatformDetails>{
            platformIOS: const PlatformDetails(PlatformSupport.inline),
          });

      final RepositoryPackage example = plugin.getExamples().first;
      final String originalPubspecContents =
          example.pubspecFile.readAsStringSync();
      String? buildTimePubspecContents;
      processRunner
              .mockProcessesForExecutable[getFlutterCommand(mockPlatform)] =
          <FakeProcessInfo>[
        FakeProcessInfo(MockProcess(), <String>['build'], () {
          buildTimePubspecContents = example.pubspecFile.readAsStringSync();
        })
      ];

      final List<String> output = await runCapturingPrint(runner, <String>[
        'build-examples',
        '--ios',
        '--enable-experiment=exp1',
        '--no-swift-package-manager',
      ]);

      expect(
        output,
        containsAllInOrder(<String>[
          '\nBUILDING plugin/example for iOS',
        ]),
      );

      // Ensure that SwiftPM was disabled for the package.
      expect(originalPubspecContents,
          isNot(contains('enable-swift-package-manager: false')));
      expect(buildTimePubspecContents,
          contains('enable-swift-package-manager: false'));
      // And that it was undone after.
      expect(example.pubspecFile.readAsStringSync(), originalPubspecContents);

      expect(
        processRunner.recordedCalls,
        orderedEquals(<ProcessCall>[
          ProcessCall(
            getFlutterCommand(mockPlatform),
            const <String>[
              'build',
              'ios',
              '--no-codesign',
              '--enable-experiment=exp1'
            ],
            example.path,
          ),
        ]),
      );
    });

    test('building for iOS with Swift Package Manager', () async {
      mockPlatform.isMacOS = true;

      final RepositoryPackage plugin = createFakePlugin('plugin', packagesDir,
          platformSupport: <String, PlatformDetails>{
            platformIOS: const PlatformDetails(PlatformSupport.inline),
          });

      final RepositoryPackage example = plugin.getExamples().first;
      final String originalPubspecContents =
          example.pubspecFile.readAsStringSync();
      String? buildTimePubspecContents;
      processRunner
              .mockProcessesForExecutable[getFlutterCommand(mockPlatform)] =
          <FakeProcessInfo>[
        FakeProcessInfo(MockProcess(), <String>['build'], () {
          buildTimePubspecContents = example.pubspecFile.readAsStringSync();
        })
      ];

      final List<String> output = await runCapturingPrint(runner, <String>[
        'build-examples',
        '--ios',
        '--enable-experiment=exp1',
        '--swift-package-manager',
      ]);

      expect(
        output,
        containsAllInOrder(<String>[
          '\nBUILDING plugin/example for iOS',
        ]),
      );

      // Ensure that SwiftPM was enabled for the package.
      expect(originalPubspecContents,
          isNot(contains('enable-swift-package-manager: true')));
      expect(buildTimePubspecContents,
          contains('enable-swift-package-manager: true'));
      // And that it was undone after.
      expect(example.pubspecFile.readAsStringSync(), originalPubspecContents);

      expect(
        processRunner.recordedCalls,
        orderedEquals(<ProcessCall>[
          ProcessCall(
            getFlutterCommand(mockPlatform),
            const <String>[
              'build',
              'ios',
              '--no-codesign',
              '--enable-experiment=exp1'
            ],
            example.path,
          ),
        ]),
      );
    });

    test(
        'building for Linux when plugin is not set up for Linux results in no-op',
        () async {
      mockPlatform.isLinux = true;
      createFakePlugin('plugin', packagesDir);

      final List<String> output = await runCapturingPrint(
          runner, <String>['build-examples', '--linux']);

      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('Running for plugin'),
          contains('Linux is not supported by this plugin'),
        ]),
      );

      // Output should be empty since running build-examples --linux with no
      // Linux implementation is a no-op.
      expect(processRunner.recordedCalls, orderedEquals(<ProcessCall>[]));
    });

    test('building for Linux', () async {
      mockPlatform.isLinux = true;
      final RepositoryPackage plugin = createFakePlugin('plugin', packagesDir,
          platformSupport: <String, PlatformDetails>{
            platformLinux: const PlatformDetails(PlatformSupport.inline),
          });

      final Directory pluginExampleDirectory = getExampleDir(plugin);

      final List<String> output = await runCapturingPrint(
          runner, <String>['build-examples', '--linux']);

      expect(
        output,
        containsAllInOrder(<String>[
          '\nBUILDING plugin/example for Linux',
        ]),
      );

      expect(
          processRunner.recordedCalls,
          orderedEquals(<ProcessCall>[
            ProcessCall(getFlutterCommand(mockPlatform),
                const <String>['build', 'linux'], pluginExampleDirectory.path),
          ]));
    });

    test('building for macOS with no implementation results in no-op',
        () async {
      mockPlatform.isMacOS = true;
      createFakePlugin('plugin', packagesDir);

      final List<String> output = await runCapturingPrint(
          runner, <String>['build-examples', '--macos']);

      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('Running for plugin'),
          contains('macOS is not supported by this plugin'),
        ]),
      );

      // Output should be empty since running build-examples --macos with no macos
      // implementation is a no-op.
      expect(processRunner.recordedCalls, orderedEquals(<ProcessCall>[]));
    });

    test('building for macOS', () async {
      mockPlatform.isMacOS = true;
      final RepositoryPackage plugin = createFakePlugin('plugin', packagesDir,
          platformSupport: <String, PlatformDetails>{
            platformMacOS: const PlatformDetails(PlatformSupport.inline),
          });

      final Directory pluginExampleDirectory = getExampleDir(plugin);

      final List<String> output = await runCapturingPrint(
          runner, <String>['build-examples', '--macos']);

      expect(
        output,
        containsAllInOrder(<String>[
          '\nBUILDING plugin/example for macOS',
        ]),
      );

      expect(
          processRunner.recordedCalls,
          orderedEquals(<ProcessCall>[
            ProcessCall(getFlutterCommand(mockPlatform),
                const <String>['build', 'macos'], pluginExampleDirectory.path),
          ]));
    });

    test('building for macOS with CocoaPods', () async {
      mockPlatform.isMacOS = true;

      final RepositoryPackage plugin = createFakePlugin('plugin', packagesDir,
          platformSupport: <String, PlatformDetails>{
            platformMacOS: const PlatformDetails(PlatformSupport.inline),
          });

      final RepositoryPackage example = plugin.getExamples().first;
      final String originalPubspecContents =
          example.pubspecFile.readAsStringSync();
      String? buildTimePubspecContents;
      processRunner
              .mockProcessesForExecutable[getFlutterCommand(mockPlatform)] =
          <FakeProcessInfo>[
        FakeProcessInfo(MockProcess(), <String>['build'], () {
          buildTimePubspecContents = example.pubspecFile.readAsStringSync();
        })
      ];

      final List<String> output = await runCapturingPrint(runner,
          <String>['build-examples', '--macos', '--no-swift-package-manager']);

      expect(
        output,
        containsAllInOrder(<String>[
          '\nBUILDING plugin/example for macOS',
        ]),
      );

      // Ensure that SwiftPM was enabled for the package.
      expect(originalPubspecContents,
          isNot(contains('enable-swift-package-manager: false')));
      expect(buildTimePubspecContents,
          contains('enable-swift-package-manager: false'));
      // And that it was undone after.
      expect(example.pubspecFile.readAsStringSync(), originalPubspecContents);

      expect(
        processRunner.recordedCalls,
        orderedEquals(<ProcessCall>[
          ProcessCall(
            getFlutterCommand(mockPlatform),
            const <String>[
              'build',
              'macos',
            ],
            example.path,
          ),
        ]),
      );
    });

    test('building for macOS with Swift Package Manager', () async {
      mockPlatform.isMacOS = true;

      final RepositoryPackage plugin = createFakePlugin('plugin', packagesDir,
          platformSupport: <String, PlatformDetails>{
            platformMacOS: const PlatformDetails(PlatformSupport.inline),
          });

      final RepositoryPackage example = plugin.getExamples().first;
      final String originalPubspecContents =
          example.pubspecFile.readAsStringSync();
      String? buildTimePubspecContents;
      processRunner
              .mockProcessesForExecutable[getFlutterCommand(mockPlatform)] =
          <FakeProcessInfo>[
        FakeProcessInfo(MockProcess(), <String>['build'], () {
          buildTimePubspecContents = example.pubspecFile.readAsStringSync();
        })
      ];

      final List<String> output = await runCapturingPrint(runner,
          <String>['build-examples', '--macos', '--swift-package-manager']);

      expect(
        output,
        containsAllInOrder(<String>[
          '\nBUILDING plugin/example for macOS',
        ]),
      );

      // Ensure that SwiftPM was enabled for the package.
      expect(originalPubspecContents,
          isNot(contains('enable-swift-package-manager: true')));
      expect(buildTimePubspecContents,
          contains('enable-swift-package-manager: true'));
      // And that it was undone after.
      expect(example.pubspecFile.readAsStringSync(), originalPubspecContents);

      expect(
        processRunner.recordedCalls,
        orderedEquals(<ProcessCall>[
          ProcessCall(
            getFlutterCommand(mockPlatform),
            const <String>[
              'build',
              'macos',
            ],
            example.path,
          ),
        ]),
      );
    });

    test('building for web with no implementation results in no-op', () async {
      createFakePlugin('plugin', packagesDir);

      final List<String> output =
          await runCapturingPrint(runner, <String>['build-examples', '--web']);

      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('Running for plugin'),
          contains('web is not supported by this plugin'),
        ]),
      );

      // Output should be empty since running build-examples --macos with no macos
      // implementation is a no-op.
      expect(processRunner.recordedCalls, orderedEquals(<ProcessCall>[]));
    });

    test('building for web', () async {
      final RepositoryPackage plugin = createFakePlugin('plugin', packagesDir,
          platformSupport: <String, PlatformDetails>{
            platformWeb: const PlatformDetails(PlatformSupport.inline),
          });

      final Directory pluginExampleDirectory = getExampleDir(plugin);

      final List<String> output =
          await runCapturingPrint(runner, <String>['build-examples', '--web']);

      expect(
        output,
        containsAllInOrder(<String>[
          '\nBUILDING plugin/example for web',
        ]),
      );

      expect(
          processRunner.recordedCalls,
          orderedEquals(<ProcessCall>[
            ProcessCall(getFlutterCommand(mockPlatform),
                const <String>['build', 'web'], pluginExampleDirectory.path),
          ]));
    });

    test(
        'building for Windows when plugin is not set up for Windows results in no-op',
        () async {
      mockPlatform.isWindows = true;
      createFakePlugin('plugin', packagesDir);

      final List<String> output = await runCapturingPrint(
          runner, <String>['build-examples', '--windows']);

      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('Running for plugin'),
          contains('Windows is not supported by this plugin'),
        ]),
      );

      // Output should be empty since running build-examples --windows with no
      // Windows implementation is a no-op.
      expect(processRunner.recordedCalls, orderedEquals(<ProcessCall>[]));
    });

    test('building for Windows', () async {
      mockPlatform.isWindows = true;
      final RepositoryPackage plugin = createFakePlugin('plugin', packagesDir,
          platformSupport: <String, PlatformDetails>{
            platformWindows: const PlatformDetails(PlatformSupport.inline),
          });

      final Directory pluginExampleDirectory = getExampleDir(plugin);

      final List<String> output = await runCapturingPrint(
          runner, <String>['build-examples', '--windows']);

      expect(
        output,
        containsAllInOrder(<String>[
          '\nBUILDING plugin/example for Windows',
        ]),
      );

      expect(
          processRunner.recordedCalls,
          orderedEquals(<ProcessCall>[
            ProcessCall(
                getFlutterCommand(mockPlatform),
                const <String>['build', 'windows'],
                pluginExampleDirectory.path),
          ]));
    });

    test(
        'building for Android when plugin is not set up for Android results in no-op',
        () async {
      createFakePlugin('plugin', packagesDir);

      final List<String> output =
          await runCapturingPrint(runner, <String>['build-examples', '--apk']);

      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('Running for plugin'),
          contains('Android is not supported by this plugin'),
        ]),
      );

      // Output should be empty since running build-examples --macos with no macos
      // implementation is a no-op.
      expect(processRunner.recordedCalls, orderedEquals(<ProcessCall>[]));
    });

    test('building for Android', () async {
      final RepositoryPackage plugin = createFakePlugin('plugin', packagesDir,
          platformSupport: <String, PlatformDetails>{
            platformAndroid: const PlatformDetails(PlatformSupport.inline),
          });

      final Directory pluginExampleDirectory = getExampleDir(plugin);

      final List<String> output = await runCapturingPrint(runner, <String>[
        'build-examples',
        '--apk',
      ]);

      expect(
        output,
        containsAllInOrder(<String>[
          '\nBUILDING plugin/example for Android (apk)',
        ]),
      );

      expect(
          processRunner.recordedCalls,
          orderedEquals(<ProcessCall>[
            ProcessCall(getFlutterCommand(mockPlatform),
                const <String>['build', 'apk'], pluginExampleDirectory.path),
          ]));
    });

    test('building for Android with alias', () async {
      final RepositoryPackage plugin = createFakePlugin('plugin', packagesDir,
          platformSupport: <String, PlatformDetails>{
            platformAndroid: const PlatformDetails(PlatformSupport.inline),
          });

      final Directory pluginExampleDirectory = getExampleDir(plugin);

      final List<String> output = await runCapturingPrint(runner, <String>[
        'build-examples',
        '--android',
      ]);

      expect(
        output,
        containsAllInOrder(<String>[
          '\nBUILDING plugin/example for Android (apk)',
        ]),
      );

      expect(
          processRunner.recordedCalls,
          orderedEquals(<ProcessCall>[
            ProcessCall(getFlutterCommand(mockPlatform),
                const <String>['build', 'apk'], pluginExampleDirectory.path),
          ]));
    });

    test('enable-experiment flag for Android', () async {
      final RepositoryPackage plugin = createFakePlugin('plugin', packagesDir,
          platformSupport: <String, PlatformDetails>{
            platformAndroid: const PlatformDetails(PlatformSupport.inline),
          });

      final Directory pluginExampleDirectory = getExampleDir(plugin);

      await runCapturingPrint(runner,
          <String>['build-examples', '--apk', '--enable-experiment=exp1']);

      expect(
          processRunner.recordedCalls,
          orderedEquals(<ProcessCall>[
            ProcessCall(
                getFlutterCommand(mockPlatform),
                const <String>['build', 'apk', '--enable-experiment=exp1'],
                pluginExampleDirectory.path),
          ]));
    });

    test('enable-experiment flag for ios', () async {
      final RepositoryPackage plugin = createFakePlugin('plugin', packagesDir,
          platformSupport: <String, PlatformDetails>{
            platformIOS: const PlatformDetails(PlatformSupport.inline),
          });

      final Directory pluginExampleDirectory = getExampleDir(plugin);

      await runCapturingPrint(runner,
          <String>['build-examples', '--ios', '--enable-experiment=exp1']);
      expect(
          processRunner.recordedCalls,
          orderedEquals(<ProcessCall>[
            ProcessCall(
                getFlutterCommand(mockPlatform),
                const <String>[
                  'build',
                  'ios',
                  '--no-codesign',
                  '--enable-experiment=exp1'
                ],
                pluginExampleDirectory.path),
          ]));
    });

    test('logs skipped platforms', () async {
      createFakePlugin('plugin', packagesDir,
          platformSupport: <String, PlatformDetails>{
            platformAndroid: const PlatformDetails(PlatformSupport.inline),
          });

      final List<String> output = await runCapturingPrint(
          runner, <String>['build-examples', '--apk', '--ios', '--macos']);

      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('Skipping unsupported platform(s): iOS, macOS'),
        ]),
      );
    });

    group('packages', () {
      test('builds when requested platform is supported by example', () async {
        final RepositoryPackage package = createFakePackage(
            'package', packagesDir, isFlutter: true, extraFiles: <String>[
          'example/ios/Runner.xcodeproj/project.pbxproj'
        ]);

        final List<String> output = await runCapturingPrint(
            runner, <String>['build-examples', '--ios']);

        expect(
          output,
          containsAllInOrder(<Matcher>[
            contains('Running for package'),
            contains('BUILDING package/example for iOS'),
          ]),
        );

        expect(
            processRunner.recordedCalls,
            orderedEquals(<ProcessCall>[
              ProcessCall(
                  getFlutterCommand(mockPlatform),
                  const <String>[
                    'build',
                    'ios',
                    '--no-codesign',
                  ],
                  getExampleDir(package).path),
            ]));
      });

      test('skips non-Flutter examples', () async {
        createFakePackage('package', packagesDir);

        final List<String> output = await runCapturingPrint(
            runner, <String>['build-examples', '--ios']);

        expect(
          output,
          containsAllInOrder(<Matcher>[
            contains('Running for package'),
            contains('No examples found supporting requested platform(s).'),
          ]),
        );

        expect(processRunner.recordedCalls, orderedEquals(<ProcessCall>[]));
      });

      test('skips when there is no example', () async {
        createFakePackage('package', packagesDir,
            isFlutter: true, examples: <String>[]);

        final List<String> output = await runCapturingPrint(
            runner, <String>['build-examples', '--ios']);

        expect(
          output,
          containsAllInOrder(<Matcher>[
            contains('Running for package'),
            contains('No examples found supporting requested platform(s).'),
          ]),
        );

        expect(processRunner.recordedCalls, orderedEquals(<ProcessCall>[]));
      });

      test('skip when example does not support requested platform', () async {
        createFakePackage('package', packagesDir,
            isFlutter: true,
            extraFiles: <String>['example/linux/CMakeLists.txt']);

        final List<String> output = await runCapturingPrint(
            runner, <String>['build-examples', '--ios']);

        expect(
          output,
          containsAllInOrder(<Matcher>[
            contains('Running for package'),
            contains('Skipping iOS for package/example; not supported.'),
            contains('No examples found supporting requested platform(s).'),
          ]),
        );

        expect(processRunner.recordedCalls, orderedEquals(<ProcessCall>[]));
      });

      test('logs skipped platforms when only some are supported', () async {
        final RepositoryPackage package = createFakePackage(
            'package', packagesDir,
            isFlutter: true,
            extraFiles: <String>['example/linux/CMakeLists.txt']);

        final List<String> output = await runCapturingPrint(
            runner, <String>['build-examples', '--apk', '--linux']);

        expect(
          output,
          containsAllInOrder(<Matcher>[
            contains('Running for package'),
            contains('Building for: Android, Linux'),
            contains('Skipping Android for package/example; not supported.'),
          ]),
        );

        expect(
            processRunner.recordedCalls,
            orderedEquals(<ProcessCall>[
              ProcessCall(
                  getFlutterCommand(mockPlatform),
                  const <String>['build', 'linux'],
                  getExampleDir(package).path),
            ]));
      });
    });

    test('The .pluginToolsConfig.yaml file', () async {
      mockPlatform.isLinux = true;
      final RepositoryPackage plugin = createFakePlugin('plugin', packagesDir,
          platformSupport: <String, PlatformDetails>{
            platformLinux: const PlatformDetails(PlatformSupport.inline),
            platformMacOS: const PlatformDetails(PlatformSupport.inline),
          });

      final Directory pluginExampleDirectory = getExampleDir(plugin);

      final File pluginExampleConfigFile =
          pluginExampleDirectory.childFile('.pluginToolsConfig.yaml');
      pluginExampleConfigFile
          .writeAsStringSync('buildFlags:\n  global:\n     - "test argument"');

      final List<String> output = <String>[
        ...await runCapturingPrint(
            runner, <String>['build-examples', '--linux']),
        ...await runCapturingPrint(
            runner, <String>['build-examples', '--macos']),
      ];

      expect(
        output,
        containsAllInOrder(<String>[
          '\nBUILDING plugin/example for Linux',
          '\nBUILDING plugin/example for macOS',
        ]),
      );

      expect(
          processRunner.recordedCalls,
          orderedEquals(<ProcessCall>[
            ProcessCall(
                getFlutterCommand(mockPlatform),
                const <String>['build', 'linux', 'test argument'],
                pluginExampleDirectory.path),
            ProcessCall(
                getFlutterCommand(mockPlatform),
                const <String>['build', 'macos', 'test argument'],
                pluginExampleDirectory.path),
          ]));
    });

    group('file filtering', () {
      const List<String> files = <String>[
        'pubspec.yaml',
        'foo.dart',
        'foo.java',
        'foo.kt',
        'foo.m',
        'foo.swift',
        'foo.cc',
        'foo.cpp',
        'foo.h',
      ];
      for (final String file in files) {
        test('runs command for changes to $file', () async {
          createFakePackage('package_a', packagesDir);

          gitProcessRunner.mockProcessesForExecutable['git-diff'] =
              <FakeProcessInfo>[
            FakeProcessInfo(MockProcess(stdout: '''
packages/package_a/$file
''')),
          ];

          // The target platform is irrelevant here; because this repo's
          // packages are fully federated, there's no need to distinguish
          // the ignore list by target (e.g., skipping iOS tests if only Java or
          // Kotlin files change), because package-level filering will already
          // accomplish the same goal.
          final List<String> output = await runCapturingPrint(
              runner, <String>['build-examples', '--web']);

          expect(
              output,
              containsAllInOrder(<Matcher>[
                contains('Running for package_a'),
              ]));
        });
      }

      test('skips commands if all files should be ignored', () async {
        createFakePackage('package_a', packagesDir);

        gitProcessRunner.mockProcessesForExecutable['git-diff'] =
            <FakeProcessInfo>[
          FakeProcessInfo(MockProcess(stdout: '''
README.md
CODEOWNERS
packages/package_a/CHANGELOG.md
''')),
        ];

        final List<String> output =
            await runCapturingPrint(runner, <String>['build-examples']);

        expect(
            output,
            isNot(containsAllInOrder(<Matcher>[
              contains('Running for package_a'),
            ])));
        expect(
            output,
            containsAllInOrder(<Matcher>[
              contains('SKIPPING ALL PACKAGES'),
            ]));
      });
    });
  });
}
