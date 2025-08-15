// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:args/command_runner.dart';
import 'package:file/file.dart';
import 'package:flutter_plugin_tools/src/common/core.dart';
import 'package:flutter_plugin_tools/src/common/plugin_utils.dart';
import 'package:flutter_plugin_tools/src/xcode_analyze_command.dart';
import 'package:git/git.dart';
import 'package:test/test.dart';

import 'mocks.dart';
import 'util.dart';

// TODO(stuartmorgan): Rework these tests to use a mock Xcode instead of
// doing all the process mocking and validation.
void main() {
  group('test xcode_analyze_command', () {
    late MockPlatform mockPlatform;
    late Directory packagesDir;
    late CommandRunner<void> runner;
    late RecordingProcessRunner processRunner;
    late RecordingProcessRunner gitProcessRunner;

    setUp(() {
      mockPlatform = MockPlatform(isMacOS: true);
      final GitDir gitDir;
      (:packagesDir, :processRunner, :gitProcessRunner, :gitDir) =
          configureBaseCommandMocks(platform: mockPlatform);
      final XcodeAnalyzeCommand command = XcodeAnalyzeCommand(
        packagesDir,
        processRunner: processRunner,
        platform: mockPlatform,
        gitDir: gitDir,
      );

      runner = CommandRunner<void>(
          'xcode_analyze_command', 'Test for xcode_analyze_command');
      runner.addCommand(command);
    });

    test('Fails if no platforms are provided', () async {
      Error? commandError;
      final List<String> output = await runCapturingPrint(
          runner, <String>['xcode-analyze'], errorHandler: (Error e) {
        commandError = e;
      });

      expect(commandError, isA<ToolExit>());
      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('At least one platform flag must be provided'),
        ]),
      );
    });

    test('temporarily disables Swift Package Manager', () async {
      final RepositoryPackage plugin = createFakePlugin('plugin', packagesDir,
          platformSupport: <String, PlatformDetails>{
            platformIOS: const PlatformDetails(PlatformSupport.inline),
          });

      final RepositoryPackage example = plugin.getExamples().first;
      final String originalPubspecContents =
          example.pubspecFile.readAsStringSync();
      String? buildTimePubspecContents;
      processRunner.mockProcessesForExecutable['xcrun'] = <FakeProcessInfo>[
        FakeProcessInfo(MockProcess(), <String>[], () {
          buildTimePubspecContents = example.pubspecFile.readAsStringSync();
        })
      ];

      await runCapturingPrint(runner, <String>[
        'xcode-analyze',
        '--ios',
      ]);

      // Ensure that SwiftPM was disabled for the package.
      expect(originalPubspecContents,
          isNot(contains('enable-swift-package-manager: false')));
      expect(buildTimePubspecContents,
          contains('enable-swift-package-manager: false'));
      // And that it was undone after.
      expect(example.pubspecFile.readAsStringSync(), originalPubspecContents);
    });

    group('iOS', () {
      test('skip if iOS is not supported', () async {
        createFakePlugin('plugin', packagesDir,
            platformSupport: <String, PlatformDetails>{
              platformMacOS: const PlatformDetails(PlatformSupport.inline),
            });

        final List<String> output =
            await runCapturingPrint(runner, <String>['xcode-analyze', '--ios']);
        expect(output,
            contains(contains('Not implemented for target platform(s).')));
        expect(processRunner.recordedCalls, orderedEquals(<ProcessCall>[]));
      });

      test('skip if iOS is implemented in a federated package', () async {
        createFakePlugin('plugin', packagesDir,
            platformSupport: <String, PlatformDetails>{
              platformIOS: const PlatformDetails(PlatformSupport.federated)
            });

        final List<String> output =
            await runCapturingPrint(runner, <String>['xcode-analyze', '--ios']);
        expect(output,
            contains(contains('Not implemented for target platform(s).')));
        expect(processRunner.recordedCalls, orderedEquals(<ProcessCall>[]));
      });

      test('runs for iOS plugin', () async {
        final RepositoryPackage plugin = createFakePlugin('plugin', packagesDir,
            platformSupport: <String, PlatformDetails>{
              platformIOS: const PlatformDetails(PlatformSupport.inline)
            });

        final Directory pluginExampleDirectory = getExampleDir(plugin);

        final List<String> output = await runCapturingPrint(runner, <String>[
          'xcode-analyze',
          '--ios',
        ]);

        expect(
            output,
            containsAllInOrder(<Matcher>[
              contains('Running for plugin'),
              contains('plugin/example (iOS) passed analysis.')
            ]));

        expect(
            processRunner.recordedCalls,
            orderedEquals(<ProcessCall>[
              ProcessCall(
                  'flutter',
                  const <String>[
                    'build',
                    'ios',
                    '--debug',
                    '--config-only',
                  ],
                  pluginExampleDirectory.path),
              ProcessCall(
                  'xcrun',
                  const <String>[
                    'xcodebuild',
                    'clean',
                    'analyze',
                    '-workspace',
                    'ios/Runner.xcworkspace',
                    '-scheme',
                    'Runner',
                    '-configuration',
                    'Debug',
                    '-destination',
                    'generic/platform=iOS Simulator',
                    'GCC_TREAT_WARNINGS_AS_ERRORS=YES',
                  ],
                  pluginExampleDirectory.path),
            ]));
      });

      test('passes min iOS deployment version when requested', () async {
        final RepositoryPackage plugin = createFakePlugin('plugin', packagesDir,
            platformSupport: <String, PlatformDetails>{
              platformIOS: const PlatformDetails(PlatformSupport.inline)
            });

        final Directory pluginExampleDirectory = getExampleDir(plugin);

        final List<String> output = await runCapturingPrint(runner,
            <String>['xcode-analyze', '--ios', '--ios-min-version=14.0']);

        expect(
            output,
            containsAllInOrder(<Matcher>[
              contains('Running for plugin'),
              contains('plugin/example (iOS) passed analysis.')
            ]));

        expect(
            processRunner.recordedCalls,
            orderedEquals(<ProcessCall>[
              ProcessCall(
                  'flutter',
                  const <String>[
                    'build',
                    'ios',
                    '--debug',
                    '--config-only',
                  ],
                  pluginExampleDirectory.path),
              ProcessCall(
                  'xcrun',
                  const <String>[
                    'xcodebuild',
                    'clean',
                    'analyze',
                    '-workspace',
                    'ios/Runner.xcworkspace',
                    '-scheme',
                    'Runner',
                    '-configuration',
                    'Debug',
                    '-destination',
                    'generic/platform=iOS Simulator',
                    'IPHONEOS_DEPLOYMENT_TARGET=14.0',
                    'GCC_TREAT_WARNINGS_AS_ERRORS=YES',
                  ],
                  pluginExampleDirectory.path),
            ]));
      });

      test('fails if xcrun fails', () async {
        createFakePlugin('plugin', packagesDir,
            platformSupport: <String, PlatformDetails>{
              platformIOS: const PlatformDetails(PlatformSupport.inline)
            });

        processRunner.mockProcessesForExecutable['xcrun'] = <FakeProcessInfo>[
          FakeProcessInfo(MockProcess(exitCode: 1))
        ];

        Error? commandError;
        final List<String> output = await runCapturingPrint(
          runner,
          <String>[
            'xcode-analyze',
            '--ios',
          ],
          errorHandler: (Error e) {
            commandError = e;
          },
        );

        expect(commandError, isA<ToolExit>());
        expect(
            output,
            containsAllInOrder(<Matcher>[
              contains('The following packages had errors:'),
              contains('  plugin'),
            ]));
      });
    });

    group('macOS', () {
      test('skip if macOS is not supported', () async {
        createFakePlugin(
          'plugin',
          packagesDir,
        );

        final List<String> output = await runCapturingPrint(
            runner, <String>['xcode-analyze', '--macos']);
        expect(output,
            contains(contains('Not implemented for target platform(s).')));
        expect(processRunner.recordedCalls, orderedEquals(<ProcessCall>[]));
      });

      test('skip if macOS is implemented in a federated package', () async {
        createFakePlugin('plugin', packagesDir,
            platformSupport: <String, PlatformDetails>{
              platformMacOS: const PlatformDetails(PlatformSupport.federated),
            });

        final List<String> output = await runCapturingPrint(
            runner, <String>['xcode-analyze', '--macos']);
        expect(output,
            contains(contains('Not implemented for target platform(s).')));
        expect(processRunner.recordedCalls, orderedEquals(<ProcessCall>[]));
      });

      test('runs for macOS plugin', () async {
        final RepositoryPackage plugin = createFakePlugin('plugin', packagesDir,
            platformSupport: <String, PlatformDetails>{
              platformMacOS: const PlatformDetails(PlatformSupport.inline),
            });

        final Directory pluginExampleDirectory = getExampleDir(plugin);

        final List<String> output = await runCapturingPrint(runner, <String>[
          'xcode-analyze',
          '--macos',
        ]);

        expect(output,
            contains(contains('plugin/example (macOS) passed analysis.')));

        expect(
            processRunner.recordedCalls,
            orderedEquals(<ProcessCall>[
              ProcessCall(
                  'flutter',
                  const <String>[
                    'build',
                    'macos',
                    '--debug',
                    '--config-only',
                  ],
                  pluginExampleDirectory.path),
              ProcessCall(
                  'xcrun',
                  const <String>[
                    'xcodebuild',
                    'clean',
                    'analyze',
                    '-workspace',
                    'macos/Runner.xcworkspace',
                    '-scheme',
                    'Runner',
                    '-configuration',
                    'Debug',
                    'GCC_TREAT_WARNINGS_AS_ERRORS=YES',
                  ],
                  pluginExampleDirectory.path),
            ]));
      });

      test('passes min macOS deployment version when requested', () async {
        final RepositoryPackage plugin = createFakePlugin('plugin', packagesDir,
            platformSupport: <String, PlatformDetails>{
              platformMacOS: const PlatformDetails(PlatformSupport.inline),
            });

        final Directory pluginExampleDirectory = getExampleDir(plugin);

        final List<String> output = await runCapturingPrint(runner,
            <String>['xcode-analyze', '--macos', '--macos-min-version=12.0']);

        expect(output,
            contains(contains('plugin/example (macOS) passed analysis.')));

        expect(
            processRunner.recordedCalls,
            orderedEquals(<ProcessCall>[
              ProcessCall(
                  'flutter',
                  const <String>[
                    'build',
                    'macos',
                    '--debug',
                    '--config-only',
                  ],
                  pluginExampleDirectory.path),
              ProcessCall(
                  'xcrun',
                  const <String>[
                    'xcodebuild',
                    'clean',
                    'analyze',
                    '-workspace',
                    'macos/Runner.xcworkspace',
                    '-scheme',
                    'Runner',
                    '-configuration',
                    'Debug',
                    'MACOSX_DEPLOYMENT_TARGET=12.0',
                    'GCC_TREAT_WARNINGS_AS_ERRORS=YES',
                  ],
                  pluginExampleDirectory.path),
            ]));
      });

      test('fails if xcrun fails', () async {
        createFakePlugin('plugin', packagesDir,
            platformSupport: <String, PlatformDetails>{
              platformMacOS: const PlatformDetails(PlatformSupport.inline),
            });

        processRunner.mockProcessesForExecutable['xcrun'] = <FakeProcessInfo>[
          FakeProcessInfo(MockProcess(exitCode: 1))
        ];

        Error? commandError;
        final List<String> output = await runCapturingPrint(
            runner, <String>['xcode-analyze', '--macos'],
            errorHandler: (Error e) {
          commandError = e;
        });

        expect(commandError, isA<ToolExit>());
        expect(
          output,
          containsAllInOrder(<Matcher>[
            contains('The following packages had errors:'),
            contains('  plugin'),
          ]),
        );
      });
    });

    group('combined', () {
      test('runs both iOS and macOS when supported', () async {
        final RepositoryPackage plugin = createFakePlugin('plugin', packagesDir,
            platformSupport: <String, PlatformDetails>{
              platformIOS: const PlatformDetails(PlatformSupport.inline),
              platformMacOS: const PlatformDetails(PlatformSupport.inline),
            });

        final Directory pluginExampleDirectory = getExampleDir(plugin);

        final List<String> output = await runCapturingPrint(runner, <String>[
          'xcode-analyze',
          '--ios',
          '--macos',
        ]);

        expect(
            output,
            containsAll(<Matcher>[
              contains('plugin/example (iOS) passed analysis.'),
              contains('plugin/example (macOS) passed analysis.'),
            ]));

        expect(
            processRunner.recordedCalls,
            orderedEquals(<ProcessCall>[
              ProcessCall(
                  'flutter',
                  const <String>[
                    'build',
                    'ios',
                    '--debug',
                    '--config-only',
                  ],
                  pluginExampleDirectory.path),
              ProcessCall(
                  'xcrun',
                  const <String>[
                    'xcodebuild',
                    'clean',
                    'analyze',
                    '-workspace',
                    'ios/Runner.xcworkspace',
                    '-scheme',
                    'Runner',
                    '-configuration',
                    'Debug',
                    '-destination',
                    'generic/platform=iOS Simulator',
                    'GCC_TREAT_WARNINGS_AS_ERRORS=YES',
                  ],
                  pluginExampleDirectory.path),
              ProcessCall(
                  'flutter',
                  const <String>[
                    'build',
                    'macos',
                    '--debug',
                    '--config-only',
                  ],
                  pluginExampleDirectory.path),
              ProcessCall(
                  'xcrun',
                  const <String>[
                    'xcodebuild',
                    'clean',
                    'analyze',
                    '-workspace',
                    'macos/Runner.xcworkspace',
                    '-scheme',
                    'Runner',
                    '-configuration',
                    'Debug',
                    'GCC_TREAT_WARNINGS_AS_ERRORS=YES',
                  ],
                  pluginExampleDirectory.path),
            ]));
      });

      test('runs only macOS for a macOS plugin', () async {
        final RepositoryPackage plugin = createFakePlugin('plugin', packagesDir,
            platformSupport: <String, PlatformDetails>{
              platformMacOS: const PlatformDetails(PlatformSupport.inline),
            });

        final Directory pluginExampleDirectory = getExampleDir(plugin);

        final List<String> output = await runCapturingPrint(runner, <String>[
          'xcode-analyze',
          '--ios',
          '--macos',
        ]);

        expect(
            output,
            containsAllInOrder(<Matcher>[
              contains('plugin/example (macOS) passed analysis.'),
            ]));

        expect(
            processRunner.recordedCalls,
            orderedEquals(<ProcessCall>[
              ProcessCall(
                  'flutter',
                  const <String>[
                    'build',
                    'macos',
                    '--debug',
                    '--config-only',
                  ],
                  pluginExampleDirectory.path),
              ProcessCall(
                  'xcrun',
                  const <String>[
                    'xcodebuild',
                    'clean',
                    'analyze',
                    '-workspace',
                    'macos/Runner.xcworkspace',
                    '-scheme',
                    'Runner',
                    '-configuration',
                    'Debug',
                    'GCC_TREAT_WARNINGS_AS_ERRORS=YES',
                  ],
                  pluginExampleDirectory.path),
            ]));
      });

      test('runs only iOS for a iOS plugin', () async {
        final RepositoryPackage plugin = createFakePlugin('plugin', packagesDir,
            platformSupport: <String, PlatformDetails>{
              platformIOS: const PlatformDetails(PlatformSupport.inline)
            });

        final Directory pluginExampleDirectory = getExampleDir(plugin);

        final List<String> output = await runCapturingPrint(runner, <String>[
          'xcode-analyze',
          '--ios',
          '--macos',
        ]);

        expect(
            output,
            containsAllInOrder(
                <Matcher>[contains('plugin/example (iOS) passed analysis.')]));

        expect(
            processRunner.recordedCalls,
            orderedEquals(<ProcessCall>[
              ProcessCall(
                  'flutter',
                  const <String>[
                    'build',
                    'ios',
                    '--debug',
                    '--config-only',
                  ],
                  pluginExampleDirectory.path),
              ProcessCall(
                  'xcrun',
                  const <String>[
                    'xcodebuild',
                    'clean',
                    'analyze',
                    '-workspace',
                    'ios/Runner.xcworkspace',
                    '-scheme',
                    'Runner',
                    '-configuration',
                    'Debug',
                    '-destination',
                    'generic/platform=iOS Simulator',
                    'GCC_TREAT_WARNINGS_AS_ERRORS=YES',
                  ],
                  pluginExampleDirectory.path),
            ]));
      });

      test('skips when neither are supported', () async {
        createFakePlugin('plugin', packagesDir);

        final List<String> output = await runCapturingPrint(runner, <String>[
          'xcode-analyze',
          '--ios',
          '--macos',
        ]);

        expect(
            output,
            containsAllInOrder(<Matcher>[
              contains('SKIPPING: Not implemented for target platform(s).'),
            ]));

        expect(processRunner.recordedCalls, orderedEquals(<ProcessCall>[]));
      });
    });

    group('file filtering', () {
      const List<String> files = <String>[
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

          final List<String> output = await runCapturingPrint(
              runner, <String>['xcode-analyze', '--ios']);

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
.gemini/config.yaml
AGENTS.md
README.md
CODEOWNERS
packages/package_a/CHANGELOG.md
packages/package_a/lib/foo.dart
''')),
        ];

        final List<String> output =
            await runCapturingPrint(runner, <String>['xcode-analyze', '--ios']);

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
