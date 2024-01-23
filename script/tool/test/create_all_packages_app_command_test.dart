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
import 'package:pubspec_parse/pubspec_parse.dart';
import 'package:test/test.dart';

import 'mocks.dart';
import 'util.dart';

void main() {
  late CommandRunner<void> runner;
  late CreateAllPackagesAppCommand command;
  late Platform mockPlatform;
  late FileSystem fileSystem;
  late Directory testRoot;
  late Directory packagesDir;
  late RecordingProcessRunner processRunner;

  setUp(() {
    mockPlatform = MockPlatform(isMacOS: true);
    fileSystem = MemoryFileSystem();
    testRoot = fileSystem.systemTempDirectory.createTempSync();
    packagesDir = testRoot.childDirectory('packages');
    processRunner = RecordingProcessRunner();

    command = CreateAllPackagesAppCommand(
      packagesDir,
      processRunner: processRunner,
      platform: mockPlatform,
    );
    runner = CommandRunner<void>(
        'create_all_test', 'Test for $CreateAllPackagesAppCommand');
    runner.addCommand(command);
  });

  /// Simulates enough of `flutter create`s output to allow the modifications
  /// made by the command to work.
  void writeFakeFlutterCreateOutput(
    Directory outputDirectory, {
    String dartSdkConstraint = '>=3.0.0 <4.0.0',
    String? appBuildGradleDependencies,
    bool androidOnly = false,
  }) {
    final RepositoryPackage package = RepositoryPackage(
        outputDirectory.childDirectory(allPackagesProjectName));

    // Android
    final String dependencies = appBuildGradleDependencies ??
        r'''
dependencies {
    implementation "org.jetbrains.kotlin:kotlin-stdlib-jdk7:$kotlin_version"
}
''';
    package
        .platformDirectory(FlutterPlatform.android)
        .childDirectory('app')
        .childFile('build.gradle')
      ..createSync(recursive: true)
      ..writeAsStringSync('''
android {
    namespace 'dev.flutter.packages.foo.example'
    compileSdk flutter.compileSdkVersion
    sourceSets {
        main.java.srcDirs += 'src/main/kotlin'
    }
    defaultConfig {
        applicationId "dev.flutter.packages.foo.example"
        minSdkVersion flutter.minSdkVersion
        targetSdkVersion 32
    }
}

$dependencies
''');

    if (androidOnly) {
      return;
    }

    // Non-platform-specific
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
      mockPlatform = MockPlatform(isLinux: true);
      command = CreateAllPackagesAppCommand(
        packagesDir,
        processRunner: processRunner,
        platform: mockPlatform,
      );
      runner = CommandRunner<void>(
          'create_all_test', 'Test for $CreateAllPackagesAppCommand');
      runner.addCommand(command);
    });

    test('calls "flutter create"', () async {
      writeFakeFlutterCreateOutput(testRoot);
      createFakePlugin('plugina', packagesDir);

      await runCapturingPrint(runner, <String>['create-all-packages-app']);

      expect(
          processRunner.recordedCalls,
          contains(ProcessCall(
              getFlutterCommand(mockPlatform),
              <String>[
                'create',
                '--template=app',
                '--project-name=$allPackagesProjectName',
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

    test(
        'pubspec special-cases camera_android to remove it from deps but not overrides',
        () async {
      writeFakeFlutterCreateOutput(testRoot);
      final Directory cameraDir = packagesDir.childDirectory('camera');
      createFakePlugin('camera', cameraDir);
      createFakePlugin('camera_android', cameraDir);
      createFakePlugin('camera_android_camerax', cameraDir);

      await runCapturingPrint(runner, <String>['create-all-packages-app']);
      final Pubspec pubspec = command.app.parsePubspec();

      final Dependency? cameraDependency = pubspec.dependencies['camera'];
      final Dependency? cameraAndroidDependency =
          pubspec.dependencies['camera_android'];
      final Dependency? cameraCameraXDependency =
          pubspec.dependencies['camera_android_camerax'];
      expect(cameraDependency, isA<PathDependency>());
      expect((cameraDependency! as PathDependency).path,
          endsWith('/packages/camera/camera'));
      expect(cameraCameraXDependency, isA<PathDependency>());
      expect((cameraCameraXDependency! as PathDependency).path,
          endsWith('/packages/camera/camera_android_camerax'));
      expect(cameraAndroidDependency, null);

      final Dependency? cameraAndroidOverride =
          pubspec.dependencyOverrides['camera_android'];
      expect(cameraAndroidOverride, isA<PathDependency>());
      expect((cameraAndroidOverride! as PathDependency).path,
          endsWith('/packages/camera/camera_android'));
    });

    test('legacy files are copied when requested', () async {
      writeFakeFlutterCreateOutput(testRoot);
      createFakePlugin('plugina', packagesDir);
      // Make a fake legacy source with all the necessary files, replacing one
      // of them.
      final Directory legacyDir = testRoot.childDirectory('legacy');
      final RepositoryPackage legacySource =
          RepositoryPackage(legacyDir.childDirectory(allPackagesProjectName));
      writeFakeFlutterCreateOutput(legacyDir, androidOnly: true);
      const String legacyAppBuildGradleContents = 'Fake legacy content';
      final File legacyGradleFile = legacySource
          .platformDirectory(FlutterPlatform.android)
          .childFile('build.gradle');
      legacyGradleFile.writeAsStringSync(legacyAppBuildGradleContents);

      await runCapturingPrint(runner, <String>[
        'create-all-packages-app',
        '--legacy-source=${legacySource.path}',
      ]);

      final File buildGradle = command.app
          .platformDirectory(FlutterPlatform.android)
          .childFile('build.gradle');

      expect(buildGradle.readAsStringSync(), legacyAppBuildGradleContents);
    });

    test('legacy directory replaces, rather than overlaying', () async {
      writeFakeFlutterCreateOutput(testRoot);
      createFakePlugin('plugina', packagesDir);
      final File extraFile =
          RepositoryPackage(testRoot.childDirectory(allPackagesProjectName))
              .platformDirectory(FlutterPlatform.android)
              .childFile('extra_file');
      extraFile.createSync(recursive: true);
      // Make a fake legacy source with all the necessary files, but not
      // including the extra file.
      final Directory legacyDir = testRoot.childDirectory('legacy');
      final RepositoryPackage legacySource =
          RepositoryPackage(legacyDir.childDirectory(allPackagesProjectName));
      writeFakeFlutterCreateOutput(legacyDir, androidOnly: true);

      await runCapturingPrint(runner, <String>[
        'create-all-packages-app',
        '--legacy-source=${legacySource.path}',
      ]);

      expect(extraFile.existsSync(), false);
    });

    test('legacy files are modified as needed by the tool', () async {
      writeFakeFlutterCreateOutput(testRoot);
      createFakePlugin('plugina', packagesDir);
      // Make a fake legacy source with all the necessary files, replacing one
      // of them.
      final Directory legacyDir = testRoot.childDirectory('legacy');
      final RepositoryPackage legacySource =
          RepositoryPackage(legacyDir.childDirectory(allPackagesProjectName));
      writeFakeFlutterCreateOutput(legacyDir, androidOnly: true);
      const String legacyAppBuildGradleContents = '''
# This is the legacy file
android {
    compileSdk flutter.compileSdkVersion
    defaultConfig {
        minSdkVersion flutter.minSdkVersion
    }
}
''';
      final File legacyGradleFile = legacySource
          .platformDirectory(FlutterPlatform.android)
          .childDirectory('app')
          .childFile('build.gradle');
      legacyGradleFile.writeAsStringSync(legacyAppBuildGradleContents);

      await runCapturingPrint(runner, <String>[
        'create-all-packages-app',
        '--legacy-source=${legacySource.path}',
      ]);

      final List<String> buildGradle = command.app
          .platformDirectory(FlutterPlatform.android)
          .childDirectory('app')
          .childFile('build.gradle')
          .readAsLinesSync();

      expect(
          buildGradle,
          containsAll(<Matcher>[
            contains('This is the legacy file'),
            contains('minSdkVersion 21'),
            contains('compileSdk 34'),
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
            contains('compileSdk 34'),
            contains('multiDexEnabled true'),
            contains('androidx.lifecycle:lifecycle-runtime'),
          ]));
    });

    // The template's app/build.gradle does not always have a dependencies
    // section; ensure that the dependency is added if there is not one.
    test('Android lifecyle dependency is added with no dependencies', () async {
      writeFakeFlutterCreateOutput(testRoot, appBuildGradleDependencies: '');
      createFakePlugin('plugina', packagesDir);

      await runCapturingPrint(runner, <String>['create-all-packages-app']);

      final List<String> buildGradle = command.app
          .platformDirectory(FlutterPlatform.android)
          .childDirectory('app')
          .childFile('build.gradle')
          .readAsLinesSync();

      expect(
          buildGradle,
          containsAllInOrder(<Matcher>[
            equals('dependencies {'),
            contains('androidx.lifecycle:lifecycle-runtime'),
            equals('}'),
          ]));
    });

    // Some versions of the template's app/build.gradle has an empty
    // dependencies section; ensure that the dependency is added in that case.
    test('Android lifecyle dependency is added with empty dependencies',
        () async {
      writeFakeFlutterCreateOutput(testRoot,
          appBuildGradleDependencies: 'dependencies {}');
      createFakePlugin('plugina', packagesDir);

      await runCapturingPrint(runner, <String>['create-all-packages-app']);

      final List<String> buildGradle = command.app
          .platformDirectory(FlutterPlatform.android)
          .childDirectory('app')
          .childFile('build.gradle')
          .readAsLinesSync();

      expect(
          buildGradle,
          containsAllInOrder(<Matcher>[
            equals('dependencies {'),
            contains('androidx.lifecycle:lifecycle-runtime'),
            equals('}'),
          ]));
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
              getFlutterCommand(mockPlatform),
              const <String>['pub', 'get'],
              testRoot.childDirectory(allPackagesProjectName).path)));
    });

    test('fails if flutter create fails', () async {
      writeFakeFlutterCreateOutput(testRoot);
      createFakePlugin('plugina', packagesDir);

      processRunner
              .mockProcessesForExecutable[getFlutterCommand(mockPlatform)] =
          <FakeProcessInfo>[
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

      processRunner
              .mockProcessesForExecutable[getFlutterCommand(mockPlatform)] =
          <FakeProcessInfo>[
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
