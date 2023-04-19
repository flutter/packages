// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:args/command_runner.dart';
import 'package:file/file.dart';
import 'package:file/memory.dart';
import 'package:flutter_plugin_tools/src/common/core.dart';
import 'package:flutter_plugin_tools/src/common/plugin_utils.dart';
import 'package:flutter_plugin_tools/src/lint_android_command.dart';
import 'package:test/test.dart';

import 'mocks.dart';
import 'util.dart';

void main() {
  group('LintAndroidCommand', () {
    FileSystem fileSystem;
    late Directory packagesDir;
    late CommandRunner<void> runner;
    late MockPlatform mockPlatform;
    late RecordingProcessRunner processRunner;

    setUp(() {
      fileSystem = MemoryFileSystem();
      packagesDir = createPackagesDirectory(fileSystem: fileSystem);
      mockPlatform = MockPlatform();
      processRunner = RecordingProcessRunner();
      final LintAndroidCommand command = LintAndroidCommand(
        packagesDir,
        processRunner: processRunner,
        platform: mockPlatform,
      );

      runner = CommandRunner<void>(
          'lint_android_test', 'Test for $LintAndroidCommand');
      runner.addCommand(command);
    });

    void writeFakePluginBuildGradle(RepositoryPackage plugin,
        {bool warningsConfigured = true}) {
      const String warningConfig = '''
    lintOptions {
        checkAllWarnings true
        warningsAsErrors true
        disable 'AndroidGradlePluginVersion', 'InvalidPackage', 'GradleDependency'
        baseline file("lint-baseline.xml")
    }
''';
      final File gradleFile = plugin
          .platformDirectory(FlutterPlatform.android)
          .childFile('build.gradle');
      gradleFile.createSync(recursive: true);
      gradleFile.writeAsStringSync('''
android {
    compileSdkVersion 33

    defaultConfig {
        minSdkVersion 16
        testInstrumentationRunner "androidx.test.runner.AndroidJUnitRunner"
    }
${warningsConfigured ? warningConfig : ''}
    testOptions {
        unitTests.returnDefaultValues = true
        unitTests.all {
            testLogging {
               events "passed", "skipped", "failed", "standardOut", "standardError"
               outputs.upToDateWhen {false}
               showStandardStreams = true
            }
        }
    }
}

''');
    }

    void writeFakeExampleBuildGradle(
        RepositoryPackage example, String pluginName,
        {bool warningsConfigured = true}) {
      final String warningConfig = '''
gradle.projectsEvaluated {
    project(":$pluginName") {
        tasks.withType(JavaCompile) {
            options.compilerArgs << "-Xlint:all" << "-Werror"
        }
    }
}
''';
      example
          .platformDirectory(FlutterPlatform.android)
          .childFile('build.gradle')
          .writeAsStringSync('''
buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath 'com.android.tools.build:gradle:8.0.1'
    }
}
allprojects {
    repositories {
        google()
        mavenCentral()
    }
}
${warningsConfigured ? warningConfig : ''}
''');
    }

    test('runs gradle lint', () async {
      final RepositoryPackage plugin =
          createFakePlugin('plugin1', packagesDir, extraFiles: <String>[
        'example/android/gradlew',
      ], platformSupport: <String, PlatformDetails>{
        platformAndroid: const PlatformDetails(PlatformSupport.inline)
      });
      writeFakePluginBuildGradle(plugin);
      writeFakeExampleBuildGradle(plugin.getExamples().first, 'plugin1');

      final Directory androidDir =
          plugin.getExamples().first.platformDirectory(FlutterPlatform.android);

      final List<String> output =
          await runCapturingPrint(runner, <String>['lint-android']);

      expect(
        processRunner.recordedCalls,
        orderedEquals(<ProcessCall>[
          ProcessCall(
            androidDir.childFile('gradlew').path,
            const <String>['plugin1:lintDebug'],
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
      final RepositoryPackage plugin = createFakePlugin('plugin1', packagesDir,
          examples: examples,
          extraFiles: <String>[
            'example/example1/android/gradlew',
            'example/example2/android/gradlew',
          ],
          platformSupport: <String, PlatformDetails>{
            platformAndroid: const PlatformDetails(PlatformSupport.inline)
          });
      writeFakePluginBuildGradle(plugin);
      for (final RepositoryPackage example in plugin.getExamples()) {
        writeFakeExampleBuildGradle(example, 'plugin1');
      }

      final Iterable<Directory> exampleAndroidDirs = plugin.getExamples().map(
          (RepositoryPackage example) =>
              example.platformDirectory(FlutterPlatform.android));

      final List<String> output =
          await runCapturingPrint(runner, <String>['lint-android']);

      expect(
        processRunner.recordedCalls,
        orderedEquals(<ProcessCall>[
          for (final Directory directory in exampleAndroidDirs)
            ProcessCall(
              directory.childFile('gradlew').path,
              const <String>['plugin1:lintDebug'],
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

    test('fails if gradlew is missing', () async {
      final RepositoryPackage plugin = createFakePlugin('plugin1', packagesDir,
          platformSupport: <String, PlatformDetails>{
            platformAndroid: const PlatformDetails(PlatformSupport.inline)
          });
      writeFakePluginBuildGradle(plugin);

      Error? commandError;
      final List<String> output = await runCapturingPrint(
          runner, <String>['lint-android'], errorHandler: (Error e) {
        commandError = e;
      });

      expect(commandError, isA<ToolExit>());
      expect(
          output,
          containsAllInOrder(
            <Matcher>[
              contains('Build examples before linting'),
            ],
          ));
    });

    test('fails if linting finds issues', () async {
      final RepositoryPackage plugin =
          createFakePlugin('plugin1', packagesDir, extraFiles: <String>[
        'example/android/gradlew',
      ], platformSupport: <String, PlatformDetails>{
        platformAndroid: const PlatformDetails(PlatformSupport.inline)
      });
      writeFakePluginBuildGradle(plugin);
      writeFakeExampleBuildGradle(plugin.getExamples().first, 'plugin1');

      final String gradlewPath = plugin
          .getExamples()
          .first
          .platformDirectory(FlutterPlatform.android)
          .childFile('gradlew')
          .path;
      processRunner.mockProcessesForExecutable[gradlewPath] = <FakeProcessInfo>[
        FakeProcessInfo(MockProcess(exitCode: 1)),
      ];

      Error? commandError;
      final List<String> output = await runCapturingPrint(
          runner, <String>['lint-android'], errorHandler: (Error e) {
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

    test('fails if gradle-driven lint-warnings-as-errors is missing', () async {
      final RepositoryPackage plugin =
          createFakePlugin('plugin1', packagesDir, extraFiles: <String>[
        'example/android/gradlew',
      ], platformSupport: <String, PlatformDetails>{
        platformAndroid: const PlatformDetails(PlatformSupport.inline)
      });
      writeFakePluginBuildGradle(plugin, warningsConfigured: false);
      writeFakeExampleBuildGradle(plugin.getExamples().first, 'plugin1');

      Error? commandError;
      final List<String> output = await runCapturingPrint(
          runner, <String>['lint-android'], errorHandler: (Error e) {
        commandError = e;
      });

      expect(commandError, isA<ToolExit>());
      expect(
          output,
          containsAllInOrder(
            <Matcher>[
              contains('This plugin is not configured to enable all '
                  'Gradle-driven lint warnings and treat them as errors.'),
              contains('The following packages had errors:'),
            ],
          ));
    });

    test('fails if javac lint-warnings-as-errors is missing', () async {
      final RepositoryPackage plugin =
          createFakePlugin('plugin1', packagesDir, extraFiles: <String>[
        'example/android/gradlew',
      ], platformSupport: <String, PlatformDetails>{
        platformAndroid: const PlatformDetails(PlatformSupport.inline)
      });
      writeFakePluginBuildGradle(plugin);
      writeFakeExampleBuildGradle(plugin.getExamples().first, 'plugin1',
          warningsConfigured: false);

      Error? commandError;
      final List<String> output = await runCapturingPrint(
          runner, <String>['lint-android'], errorHandler: (Error e) {
        commandError = e;
      });

      expect(commandError, isA<ToolExit>());
      expect(
          output,
          containsAllInOrder(
            <Matcher>[
              contains('The example "example" is not configured to treat javac '
                  'lints and warnings as errors.'),
              contains('The following packages had errors:'),
            ],
          ));
    });

    test('skips non-Android plugins', () async {
      createFakePlugin('plugin1', packagesDir);

      final List<String> output =
          await runCapturingPrint(runner, <String>['lint-android']);

      expect(
          output,
          containsAllInOrder(
            <Matcher>[
              contains(
                  'SKIPPING: Plugin does not have an Android implementation.')
            ],
          ));
    });

    test('skips non-inline plugins', () async {
      createFakePlugin('plugin1', packagesDir,
          platformSupport: <String, PlatformDetails>{
            platformAndroid: const PlatformDetails(PlatformSupport.federated)
          });

      final List<String> output =
          await runCapturingPrint(runner, <String>['lint-android']);

      expect(
          output,
          containsAllInOrder(
            <Matcher>[
              contains(
                  'SKIPPING: Plugin does not have an Android implementation.')
            ],
          ));
    });
  });
}
