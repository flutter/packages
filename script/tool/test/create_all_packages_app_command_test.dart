// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io' as io;

import 'package:args/command_runner.dart';
import 'package:file/file.dart';
import 'package:file/memory.dart';
import 'package:flutter_plugin_tools/src/common/core.dart';
import 'package:flutter_plugin_tools/src/create_all_packages_app_command.dart';
import 'package:platform/platform.dart';
import 'package:test/test.dart';

import 'mocks.dart';
import 'util.dart';

void main() {
  late CommandRunner<void> runner;
  late CreateAllPackagesAppCommand command;
  late FileSystem fileSystem;
  late Directory testRoot;
  late Directory packagesDir;
  late RecordingProcessRunner processRunner;

  setUp(() {
    fileSystem = MemoryFileSystem();
    testRoot = fileSystem.systemTempDirectory.createTempSync();
    packagesDir = testRoot.childDirectory('packages');
    processRunner = RecordingProcessRunner();

    command = CreateAllPackagesAppCommand(
      packagesDir,
      processRunner: processRunner,
    );
    runner = CommandRunner<void>(
        'create_all_test', 'Test for $CreateAllPackagesAppCommand');
    runner.addCommand(command);
  });

  /// Simulates enough of `flutter create`s output to allow the modifications
  /// made by the command to work.
  void writeFakeFlutterCreateOutput(Directory outputDirectory,
      {String dartSdkConstraint = '>=3.0.0 <4.0.0'}) {
    final RepositoryPackage package = RepositoryPackage(
        outputDirectory.childDirectory(allPackagesProjectName));

    package.pubspecFile
      ..createSync(recursive: true)
      ..writeAsStringSync('''
name: $allPackagesProjectName
description: Flutter app containing all 1st party plugins.
publish_to: none
version: 1.0.0

environment:
  sdk: '$dartSdkConstraint'

dependencies:
  flutter:
    sdk: flutter

dev_dependencies:
  flutter_test:
    sdk: flutter
###
''');

// Android
    final Directory android =
        package.platformDirectory(FlutterPlatform.android);
    android.childFile('build.gradle')
      ..createSync(recursive: true)
      ..writeAsStringSync(r'''
buildscript {
    ext.kotlin_version = '1.6.21'
    repositories {
        google()
        mavenCentral()
    }

    dependencies {
        classpath 'com.android.tools.build:gradle:7.4.2'
        classpath "org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlin_version"
    }
}
''');
    android.childDirectory('app').childFile('build.gradle')
      ..createSync(recursive: true)
      ..writeAsStringSync(r'''
android {
    namespace 'dev.flutter.packages.foo.example'
    compileSdkVersion flutter.compileSdkVersion
    sourceSets {
        main.java.srcDirs += 'src/main/kotlin'
    }
    defaultConfig {
        applicationId "dev.flutter.packages.foo.example"
        minSdkVersion flutter.minSdkVersion
        targetSdkVersion 32
    }
}

dependencies {
    implementation "org.jetbrains.kotlin:kotlin-stdlib-jdk7:$kotlin_version"
    testImplementation 'junit:junit:4.12'
}
''');
    android
        .childDirectory('gradle')
        .childDirectory('wrapper')
        .childFile('gradle-wrapper.properties')
      ..createSync(recursive: true)
      ..writeAsStringSync(r'''
distributionBase=GRADLE_USER_HOME
distributionPath=wrapper/dists
distributionUrl=https\://services.gradle.org/distributions/gradle-7.6.1-all.zip
''');

    // macOS
    final Directory macOS = package.platformDirectory(FlutterPlatform.macos);
    macOS.childDirectory('Runner.xcodeproj').childFile('project.pbxproj')
      ..createSync(recursive: true)
      ..writeAsStringSync('''
    97C147041CF9000F007C117D /* Release */ = {
      isa = XCBuildConfiguration;
      buildSettings = {
        GCC_WARN_UNUSED_VARIABLE = YES;
        MACOSX_DEPLOYMENT_TARGET = 10.14;
      };
      name = Release;
    };
''');
    macOS.childFile('Podfile')
      ..createSync(recursive: true)
      ..writeAsStringSync('''
# platform :osx, '10.14'

ENV['COCOAPODS_DISABLE_STATS'] = 'true'

project 'Runner', {
  'Debug' => :debug,
  'Profile' => :release,
  'Release' => :release,
}
''');
  }

  group('non-macOS host', () {
    setUp(() {
      command = CreateAllPackagesAppCommand(
        packagesDir,
        processRunner: processRunner,
        // Set isWindows or not based on the actual host, so that
        // `flutterCommand` works, since these tests actually call 'flutter'.
        // The important thing is that isMacOS always returns false.
        platform: MockPlatform(isWindows: const LocalPlatform().isWindows),
      );
      runner = CommandRunner<void>(
          'create_all_test', 'Test for $CreateAllPackagesAppCommand');
      runner.addCommand(command);
    });

    test('uses Kotlin by default', () async {
      writeFakeFlutterCreateOutput(testRoot);
      createFakePlugin('plugina', packagesDir);

      await runCapturingPrint(runner, <String>['create-all-packages-app']);

      expect(
          processRunner.recordedCalls,
          contains(ProcessCall(
              getFlutterCommand(const LocalPlatform()),
              <String>[
                'create',
                '--template=app',
                '--project-name=$allPackagesProjectName',
                '--android-language=kotlin',
                testRoot.childDirectory(allPackagesProjectName).path,
              ],
              null)));
    });

    test('uses Java when requested', () async {
      writeFakeFlutterCreateOutput(testRoot);
      createFakePlugin('plugina', packagesDir);

      await runCapturingPrint(runner, <String>[
        'create-all-packages-app',
        '--android-language=java',
      ]);

      expect(
          processRunner.recordedCalls,
          contains(ProcessCall(
              getFlutterCommand(const LocalPlatform()),
              <String>[
                'create',
                '--template=app',
                '--project-name=$allPackagesProjectName',
                '--android-language=java',
                testRoot.childDirectory(allPackagesProjectName).path,
              ],
              null)));
    });

    test('pubspec includes all plugins', () async {
      writeFakeFlutterCreateOutput(testRoot);
      createFakePlugin('plugina', packagesDir);
      createFakePlugin('pluginb', packagesDir);
      createFakePlugin('pluginc', packagesDir);

      await runCapturingPrint(runner, <String>['create-all-packages-app']);
      final List<String> pubspec = command.app.pubspecFile.readAsLinesSync();

      expect(
          pubspec,
          containsAll(<Matcher>[
            contains(RegExp('path: .*/packages/plugina')),
            contains(RegExp('path: .*/packages/pluginb')),
            contains(RegExp('path: .*/packages/pluginc')),
          ]));
    });

    test('pubspec has overrides for all plugins', () async {
      writeFakeFlutterCreateOutput(testRoot);
      createFakePlugin('plugina', packagesDir);
      createFakePlugin('pluginb', packagesDir);
      createFakePlugin('pluginc', packagesDir);

      await runCapturingPrint(runner, <String>['create-all-packages-app']);
      final List<String> pubspec = command.app.pubspecFile.readAsLinesSync();

      expect(
          pubspec,
          containsAllInOrder(<Matcher>[
            contains('dependency_overrides:'),
            contains(RegExp('path: .*/packages/plugina')),
            contains(RegExp('path: .*/packages/pluginb')),
            contains(RegExp('path: .*/packages/pluginc')),
          ]));
    });

    test('pubspec preserves existing Dart SDK version', () async {
      const String existingSdkConstraint = '>=1.0.0 <99.0.0';
      writeFakeFlutterCreateOutput(testRoot,
          dartSdkConstraint: existingSdkConstraint);
      createFakePlugin('plugina', packagesDir);

      await runCapturingPrint(runner, <String>['create-all-packages-app']);
      final Pubspec generatedPubspec = command.app.parsePubspec();

      const String dartSdkKey = 'sdk';
      expect(generatedPubspec.environment?[dartSdkKey].toString(),
          existingSdkConstraint);
    });

    test('Android app gradle is modified as expected', () async {
      writeFakeFlutterCreateOutput(testRoot);
      createFakePlugin('plugina', packagesDir);

      await runCapturingPrint(runner, <String>['create-all-packages-app']);

      final List<String> buildGradle = command.app
          .platformDirectory(FlutterPlatform.android)
          .childDirectory('app')
          .childFile('build.gradle')
          .readAsLinesSync();

      expect(
          buildGradle,
          containsAll(<Matcher>[
            contains('minSdkVersion 21'),
            contains('compileSdkVersion 33'),
            contains('multiDexEnabled true'),
            contains('androidx.lifecycle:lifecycle-runtime'),
          ]));
    });

    test('Android AGP and Gradle versions are modified if requested', () async {
      writeFakeFlutterCreateOutput(testRoot);
      createFakePlugin('plugina', packagesDir);

      const String agpVersion = '9.8.7';
      const String gradleVersion = '99.87';
      await runCapturingPrint(runner, <String>[
        'create-all-packages-app',
        '--agp-version=$agpVersion',
        '--gradle-version=$gradleVersion'
      ]);

      final List<String> buildGradle = command.app
          .platformDirectory(FlutterPlatform.android)
          .childFile('build.gradle')
          .readAsLinesSync();
      final List<String> gradleWrapper = command.app
          .platformDirectory(FlutterPlatform.android)
          .childDirectory('gradle')
          .childDirectory('wrapper')
          .childFile('gradle-wrapper.properties')
          .readAsLinesSync();

      expect(
          buildGradle,
          contains(contains(
              "classpath 'com.android.tools.build:gradle:$agpVersion'")));
      expect(
          gradleWrapper,
          contains(contains(
              'distributionUrl=https\\://services.gradle.org/distributions/gradle-$gradleVersion-bin.zip')));
    });

    test('macOS deployment target is modified in pbxproj', () async {
      writeFakeFlutterCreateOutput(testRoot);
      createFakePlugin('plugina', packagesDir);

      await runCapturingPrint(runner, <String>['create-all-packages-app']);
      final List<String> pbxproj = command.app
          .platformDirectory(FlutterPlatform.macos)
          .childDirectory('Runner.xcodeproj')
          .childFile('project.pbxproj')
          .readAsLinesSync();

      expect(
          pbxproj,
          everyElement((String line) =>
              !line.contains('MACOSX_DEPLOYMENT_TARGET') ||
              line.contains('10.15')));
    });

    test('calls flutter pub get', () async {
      writeFakeFlutterCreateOutput(testRoot);
      createFakePlugin('plugina', packagesDir);

      await runCapturingPrint(runner, <String>['create-all-packages-app']);

      expect(
          processRunner.recordedCalls,
          contains(ProcessCall(
              getFlutterCommand(const LocalPlatform()),
              const <String>['pub', 'get'],
              testRoot.childDirectory(allPackagesProjectName).path)));
    },
        // See comment about Windows in create_all_packages_app_command.dart
        skip: io.Platform.isWindows);

    test('fails if flutter create fails', () async {
      writeFakeFlutterCreateOutput(testRoot);
      createFakePlugin('plugina', packagesDir);

      processRunner.mockProcessesForExecutable[
          getFlutterCommand(const LocalPlatform())] = <FakeProcessInfo>[
        FakeProcessInfo(MockProcess(exitCode: 1), <String>['create'])
      ];
      Error? commandError;
      final List<String> output = await runCapturingPrint(
          runner, <String>['create-all-packages-app'], errorHandler: (Error e) {
        commandError = e;
      });

      expect(commandError, isA<ToolExit>());
      expect(
          output,
          containsAllInOrder(<Matcher>[
            contains('Failed to `flutter create`'),
          ]));
    });

    test('fails if flutter pub get fails', () async {
      writeFakeFlutterCreateOutput(testRoot);
      createFakePlugin('plugina', packagesDir);

      processRunner.mockProcessesForExecutable[
          getFlutterCommand(const LocalPlatform())] = <FakeProcessInfo>[
        FakeProcessInfo(MockProcess(), <String>['create']),
        FakeProcessInfo(MockProcess(exitCode: 1), <String>['pub', 'get'])
      ];
      Error? commandError;
      final List<String> output = await runCapturingPrint(
          runner, <String>['create-all-packages-app'], errorHandler: (Error e) {
        commandError = e;
      });

      expect(commandError, isA<ToolExit>());
      expect(
          output,
          containsAllInOrder(<Matcher>[
            contains(
                "Failed to generate native build files via 'flutter pub get'"),
          ]));
    },
        // See comment about Windows in create_all_packages_app_command.dart
        skip: io.Platform.isWindows);

    test('handles --output-dir', () async {
      final Directory customOutputDir =
          fileSystem.systemTempDirectory.createTempSync();
      writeFakeFlutterCreateOutput(customOutputDir);
      createFakePlugin('plugina', packagesDir);

      await runCapturingPrint(runner, <String>[
        'create-all-packages-app',
        '--output-dir=${customOutputDir.path}'
      ]);

      expect(command.app.path,
          customOutputDir.childDirectory(allPackagesProjectName).path);
    });

    test('logs exclusions', () async {
      writeFakeFlutterCreateOutput(testRoot);
      createFakePlugin('plugina', packagesDir);
      createFakePlugin('pluginb', packagesDir);
      createFakePlugin('pluginc', packagesDir);

      final List<String> output = await runCapturingPrint(runner,
          <String>['create-all-packages-app', '--exclude=pluginb,pluginc']);

      expect(
          output,
          containsAllInOrder(<String>[
            'Exluding the following plugins from the combined build:',
            '  pluginb',
            '  pluginc',
          ]));
    });
  });

  group('macOS host', () {
    setUp(() {
      command = CreateAllPackagesAppCommand(
        packagesDir,
        processRunner: processRunner,
        platform: MockPlatform(isMacOS: true),
      );
      runner = CommandRunner<void>(
          'create_all_test', 'Test for $CreateAllPackagesAppCommand');
      runner.addCommand(command);
    });

    test('macOS deployment target is modified in Podfile', () async {
      writeFakeFlutterCreateOutput(testRoot);
      createFakePlugin('plugina', packagesDir);

      final File podfileFile = RepositoryPackage(
              command.packagesDir.parent.childDirectory(allPackagesProjectName))
          .platformDirectory(FlutterPlatform.macos)
          .childFile('Podfile');
      podfileFile.createSync(recursive: true);
      podfileFile.writeAsStringSync("""
platform :osx, '10.11'
# some other line
""");

      await runCapturingPrint(runner, <String>['create-all-packages-app']);
      final List<String> podfile = command.app
          .platformDirectory(FlutterPlatform.macos)
          .childFile('Podfile')
          .readAsLinesSync();

      expect(
          podfile,
          everyElement((String line) =>
              !line.contains('platform :osx') || line.contains("'10.15'")));
    },
        // Podfile is only generated (and thus only edited) on macOS.
        skip: !io.Platform.isMacOS);
  });
}
