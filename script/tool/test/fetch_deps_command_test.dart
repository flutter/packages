// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:args/command_runner.dart';
import 'package:file/file.dart';
import 'package:flutter_plugin_tools/src/common/core.dart';
import 'package:flutter_plugin_tools/src/common/plugin_utils.dart';
import 'package:flutter_plugin_tools/src/fetch_deps_command.dart';
import 'package:git/git.dart';
import 'package:test/test.dart';

import 'mocks.dart';
import 'util.dart';

void main() {
  group('FetchDepsCommand', () {
    late Directory packagesDir;
    late CommandRunner<void> runner;
    late MockPlatform mockPlatform;
    late RecordingProcessRunner processRunner;

    setUp(() {
      mockPlatform = MockPlatform();
      final GitDir gitDir;
      (:packagesDir, :processRunner, gitProcessRunner: _, :gitDir) =
          configureBaseCommandMocks(platform: mockPlatform);

      final FetchDepsCommand command = FetchDepsCommand(
        packagesDir,
        processRunner: processRunner,
        platform: mockPlatform,
        gitDir: gitDir,
      );

      runner =
          CommandRunner<void>('fetch_deps_test', 'Test for $FetchDepsCommand');
      runner.addCommand(command);
    });

    group('dart', () {
      test('runs pub get', () async {
        final RepositoryPackage plugin = createFakePlugin(
            'plugin1', packagesDir, platformSupport: <String, PlatformDetails>{
          platformIOS: const PlatformDetails(PlatformSupport.inline)
        });

        final List<String> output =
            await runCapturingPrint(runner, <String>['fetch-deps']);

        expect(
          processRunner.recordedCalls,
          orderedEquals(<ProcessCall>[
            ProcessCall(
              'flutter',
              const <String>['pub', 'get'],
              plugin.directory.path,
            ),
          ]),
        );

        expect(
            output,
            containsAllInOrder(<Matcher>[
              contains('Running for plugin1'),
              contains('No issues found!'),
            ]));
      });

      test('fails if pub get fails', () async {
        createFakePlugin('plugin1', packagesDir,
            platformSupport: <String, PlatformDetails>{
              platformIOS: const PlatformDetails(PlatformSupport.inline)
            });

        processRunner
                .mockProcessesForExecutable[getFlutterCommand(mockPlatform)] =
            <FakeProcessInfo>[
          FakeProcessInfo(MockProcess(exitCode: 1)),
        ];

        Error? commandError;
        final List<String> output = await runCapturingPrint(
            runner, <String>['fetch-deps'], errorHandler: (Error e) {
          commandError = e;
        });

        expect(commandError, isA<ToolExit>());
        expect(
            output,
            containsAllInOrder(
              <Matcher>[
                contains('Failed to "pub get"'),
              ],
            ));
      });

      test('skips unsupported packages when any platforms are passed',
          () async {
        final RepositoryPackage packageWithBoth = createFakePackage(
            'supports_both', packagesDir, extraFiles: <String>[
          'example/linux/placeholder',
          'example/windows/placeholder'
        ]);
        final RepositoryPackage packageWithOne = createFakePackage(
            'supports_one', packagesDir,
            extraFiles: <String>['example/linux/placeholder']);
        createFakePackage('supports_neither', packagesDir);

        await runCapturingPrint(runner, <String>[
          'fetch-deps',
          '--linux',
          '--windows',
          '--supporting-target-platforms-only'
        ]);

        expect(
          processRunner.recordedCalls,
          orderedEquals(<ProcessCall>[
            ProcessCall(
              'dart',
              const <String>['pub', 'get'],
              packageWithBoth.path,
            ),
            ProcessCall(
              'dart',
              const <String>['pub', 'get'],
              packageWithOne.path,
            ),
          ]),
        );
      });
    });

    group('android', () {
      test('runs pub get before gradlew dependencies', () async {
        final RepositoryPackage plugin =
            createFakePlugin('plugin1', packagesDir, extraFiles: <String>[
          'example/android/gradlew',
        ], platformSupport: <String, PlatformDetails>{
          platformAndroid: const PlatformDetails(PlatformSupport.inline)
        });

        final Directory androidDir = plugin
            .getExamples()
            .first
            .platformDirectory(FlutterPlatform.android);

        final List<String> output = await runCapturingPrint(
            runner, <String>['fetch-deps', '--android']);

        expect(
          processRunner.recordedCalls,
          orderedEquals(<ProcessCall>[
            ProcessCall(
              'flutter',
              const <String>['pub', 'get'],
              plugin.directory.path,
            ),
            ProcessCall(
              androidDir.childFile('gradlew').path,
              const <String>['plugin1:dependencies'],
              androidDir.path,
            ),
          ]),
        );

        expect(
            output,
            containsAllInOrder(<Matcher>[
              contains('Running for plugin1'),
              contains('No issues found!'),
            ]));
      });

      test('runs gradlew dependencies', () async {
        final RepositoryPackage plugin =
            createFakePlugin('plugin1', packagesDir, extraFiles: <String>[
          'example/android/gradlew',
        ], platformSupport: <String, PlatformDetails>{
          platformAndroid: const PlatformDetails(PlatformSupport.inline)
        });

        final Directory androidDir = plugin
            .getExamples()
            .first
            .platformDirectory(FlutterPlatform.android);

        final List<String> output = await runCapturingPrint(
            runner, <String>['fetch-deps', '--no-dart', '--android']);

        expect(
          processRunner.recordedCalls,
          orderedEquals(<ProcessCall>[
            ProcessCall(
              androidDir.childFile('gradlew').path,
              const <String>['plugin1:dependencies'],
              androidDir.path,
            ),
          ]),
        );

        expect(
            output,
            containsAllInOrder(<Matcher>[
              contains('Running for plugin1'),
              contains('No issues found!'),
            ]));
      });

      test('runs on all examples', () async {
        final List<String> examples = <String>['example1', 'example2'];
        final RepositoryPackage plugin = createFakePlugin(
            'plugin1', packagesDir,
            examples: examples,
            extraFiles: <String>[
              'example/example1/android/gradlew',
              'example/example2/android/gradlew',
            ],
            platformSupport: <String, PlatformDetails>{
              platformAndroid: const PlatformDetails(PlatformSupport.inline)
            });

        final Iterable<Directory> exampleAndroidDirs = plugin.getExamples().map(
            (RepositoryPackage example) =>
                example.platformDirectory(FlutterPlatform.android));

        final List<String> output = await runCapturingPrint(
            runner, <String>['fetch-deps', '--no-dart', '--android']);

        expect(
          processRunner.recordedCalls,
          orderedEquals(<ProcessCall>[
            for (final Directory directory in exampleAndroidDirs)
              ProcessCall(
                directory.childFile('gradlew').path,
                const <String>['plugin1:dependencies'],
                directory.path,
              ),
          ]),
        );

        expect(
            output,
            containsAllInOrder(<Matcher>[
              contains('Running for plugin1'),
              contains('No issues found!'),
            ]));
      });

      test('runs --config-only build if gradlew is missing', () async {
        final RepositoryPackage plugin = createFakePlugin(
            'plugin1', packagesDir, platformSupport: <String, PlatformDetails>{
          platformAndroid: const PlatformDetails(PlatformSupport.inline)
        });

        final Directory androidDir = plugin
            .getExamples()
            .first
            .platformDirectory(FlutterPlatform.android);

        final List<String> output = await runCapturingPrint(
            runner, <String>['fetch-deps', '--no-dart', '--android']);

        expect(
          processRunner.recordedCalls,
          orderedEquals(<ProcessCall>[
            ProcessCall(
              getFlutterCommand(mockPlatform),
              const <String>['build', 'apk', '--config-only'],
              plugin.getExamples().first.directory.path,
            ),
            ProcessCall(
              androidDir.childFile('gradlew').path,
              const <String>['plugin1:dependencies'],
              androidDir.path,
            ),
          ]),
        );

        expect(
            output,
            containsAllInOrder(<Matcher>[
              contains('Running for plugin1'),
              contains('No issues found!'),
            ]));
      });

      test('fails if gradlew generation fails', () async {
        createFakePlugin('plugin1', packagesDir,
            platformSupport: <String, PlatformDetails>{
              platformAndroid: const PlatformDetails(PlatformSupport.inline)
            });

        processRunner
                .mockProcessesForExecutable[getFlutterCommand(mockPlatform)] =
            <FakeProcessInfo>[
          FakeProcessInfo(MockProcess(exitCode: 1)),
        ];

        Error? commandError;
        final List<String> output = await runCapturingPrint(
            runner, <String>['fetch-deps', '--no-dart', '--android'],
            errorHandler: (Error e) {
          commandError = e;
        });

        expect(commandError, isA<ToolExit>());
        expect(
            output,
            containsAllInOrder(
              <Matcher>[
                contains('Unable to configure Gradle project'),
              ],
            ));
      });

      test('fails if dependency download finds issues', () async {
        final RepositoryPackage plugin =
            createFakePlugin('plugin1', packagesDir, extraFiles: <String>[
          'example/android/gradlew',
        ], platformSupport: <String, PlatformDetails>{
          platformAndroid: const PlatformDetails(PlatformSupport.inline)
        });

        final String gradlewPath = plugin
            .getExamples()
            .first
            .platformDirectory(FlutterPlatform.android)
            .childFile('gradlew')
            .path;
        processRunner.mockProcessesForExecutable[gradlewPath] =
            <FakeProcessInfo>[
          FakeProcessInfo(MockProcess(exitCode: 1)),
        ];

        Error? commandError;
        final List<String> output = await runCapturingPrint(
            runner, <String>['fetch-deps', '--no-dart', '--android'],
            errorHandler: (Error e) {
          commandError = e;
        });

        expect(commandError, isA<ToolExit>());
        expect(
            output,
            containsAllInOrder(
              <Matcher>[
                contains('The following packages had errors:'),
              ],
            ));
      });

      test('skips non-Android plugins', () async {
        createFakePlugin('plugin1', packagesDir);

        final List<String> output = await runCapturingPrint(
            runner, <String>['fetch-deps', '--no-dart', '--android']);

        expect(
            output,
            containsAllInOrder(
              <Matcher>[
                contains('Package does not have native Android dependencies.')
              ],
            ));
      });

      test('skips non-inline plugins', () async {
        createFakePlugin('plugin1', packagesDir,
            platformSupport: <String, PlatformDetails>{
              platformAndroid: const PlatformDetails(PlatformSupport.federated)
            });

        final List<String> output = await runCapturingPrint(
            runner, <String>['fetch-deps', '--no-dart', '--android']);

        expect(
            output,
            containsAllInOrder(
              <Matcher>[
                contains('Package does not have native Android dependencies.')
              ],
            ));
      });
    });

    group('ios', () {
      test('runs on all examples', () async {
        final List<String> examples = <String>['example1', 'example2'];
        final RepositoryPackage plugin = createFakePlugin(
            'plugin1', packagesDir,
            examples: examples,
            platformSupport: <String, PlatformDetails>{
              platformIOS: const PlatformDetails(PlatformSupport.inline)
            });

        final Iterable<Directory> exampleDirs = plugin
            .getExamples()
            .map((RepositoryPackage example) => example.directory);

        final List<String> output = await runCapturingPrint(
            runner, <String>['fetch-deps', '--no-dart', '--ios']);

        expect(
          processRunner.recordedCalls,
          orderedEquals(<ProcessCall>[
            const ProcessCall(
              'flutter',
              <String>['precache', '--ios'],
              null,
            ),
            const ProcessCall(
              'pod',
              <String>['repo', 'update'],
              null,
            ),
            for (final Directory directory in exampleDirs)
              ProcessCall(
                'flutter',
                const <String>['build', 'ios', '--config-only'],
                directory.path,
              ),
          ]),
        );

        expect(
            output,
            containsAllInOrder(<Matcher>[
              contains('Running for plugin1'),
              contains('No issues found!'),
            ]));
      });

      test('fails if flutter build --config-only fails', () async {
        createFakePlugin('plugin1', packagesDir,
            platformSupport: <String, PlatformDetails>{
              platformIOS: const PlatformDetails(PlatformSupport.inline)
            });

        processRunner
                .mockProcessesForExecutable[getFlutterCommand(mockPlatform)] =
            <FakeProcessInfo>[
          FakeProcessInfo(MockProcess(), <String>['precache']),
          FakeProcessInfo(MockProcess(), <String>['repo', 'update']),
          FakeProcessInfo(MockProcess(exitCode: 1),
              <String>['build', 'ios', '--config-only']),
        ];

        Error? commandError;
        final List<String> output = await runCapturingPrint(
            runner, <String>['fetch-deps', '--no-dart', '--ios'],
            errorHandler: (Error e) {
          commandError = e;
        });

        expect(commandError, isA<ToolExit>());
        expect(
            output,
            containsAllInOrder(
              <Matcher>[
                contains('The following packages had errors:'),
              ],
            ));
      });

      test('skips non-iOS plugins', () async {
        createFakePlugin('plugin1', packagesDir);

        final List<String> output = await runCapturingPrint(
            runner, <String>['fetch-deps', '--no-dart', '--ios']);

        expect(
            output,
            containsAllInOrder(
              <Matcher>[
                contains('Package does not have native iOS dependencies.')
              ],
            ));
      });

      test('skips non-inline plugins', () async {
        createFakePlugin('plugin1', packagesDir,
            platformSupport: <String, PlatformDetails>{
              platformIOS: const PlatformDetails(PlatformSupport.federated)
            });

        final List<String> output = await runCapturingPrint(
            runner, <String>['fetch-deps', '--no-dart', '--ios']);

        expect(
            output,
            containsAllInOrder(
              <Matcher>[
                contains('Package does not have native iOS dependencies.')
              ],
            ));
      });
    });

    group('macos', () {
      test('runs on all examples', () async {
        final List<String> examples = <String>['example1', 'example2'];
        final RepositoryPackage plugin = createFakePlugin(
            'plugin1', packagesDir,
            examples: examples,
            platformSupport: <String, PlatformDetails>{
              platformMacOS: const PlatformDetails(PlatformSupport.inline)
            });

        final Iterable<Directory> exampleDirs = plugin
            .getExamples()
            .map((RepositoryPackage example) => example.directory);

        final List<String> output = await runCapturingPrint(
            runner, <String>['fetch-deps', '--no-dart', '--macos']);

        expect(
          processRunner.recordedCalls,
          orderedEquals(<ProcessCall>[
            const ProcessCall(
              'flutter',
              <String>['precache', '--macos'],
              null,
            ),
            const ProcessCall(
              'pod',
              <String>['repo', 'update'],
              null,
            ),
            for (final Directory directory in exampleDirs)
              ProcessCall(
                'flutter',
                const <String>['build', 'macos', '--config-only'],
                directory.path,
              ),
          ]),
        );

        expect(
            output,
            containsAllInOrder(<Matcher>[
              contains('Running for plugin1'),
              contains('No issues found!'),
            ]));
      });

      test('fails if flutter build --config-only fails', () async {
        createFakePlugin('plugin1', packagesDir,
            platformSupport: <String, PlatformDetails>{
              platformMacOS: const PlatformDetails(PlatformSupport.inline)
            });

        processRunner
                .mockProcessesForExecutable[getFlutterCommand(mockPlatform)] =
            <FakeProcessInfo>[
          FakeProcessInfo(MockProcess(), <String>['precache']),
          FakeProcessInfo(MockProcess(), <String>['repo', 'update']),
          FakeProcessInfo(MockProcess(exitCode: 1),
              <String>['build', 'macos', '--config-only']),
        ];

        Error? commandError;
        final List<String> output = await runCapturingPrint(
            runner, <String>['fetch-deps', '--no-dart', '--macos'],
            errorHandler: (Error e) {
          commandError = e;
        });

        expect(commandError, isA<ToolExit>());
        expect(
            output,
            containsAllInOrder(
              <Matcher>[
                contains('The following packages had errors:'),
              ],
            ));
      });

      test('skips non-macOS plugins', () async {
        createFakePlugin('plugin1', packagesDir);

        final List<String> output = await runCapturingPrint(
            runner, <String>['fetch-deps', '--no-dart', '--macos']);

        expect(
            output,
            containsAllInOrder(
              <Matcher>[
                contains('Package does not have native macOS dependencies.')
              ],
            ));
      });

      test('skips non-inline plugins', () async {
        createFakePlugin('plugin1', packagesDir,
            platformSupport: <String, PlatformDetails>{
              platformMacOS: const PlatformDetails(PlatformSupport.federated)
            });

        final List<String> output = await runCapturingPrint(
            runner, <String>['fetch-deps', '--no-dart', '--macos']);

        expect(
            output,
            containsAllInOrder(
              <Matcher>[
                contains('Package does not have native macOS dependencies.')
              ],
            ));
      });
    });
  });
}
