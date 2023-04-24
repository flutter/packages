// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:args/command_runner.dart';
import 'package:file/file.dart';
import 'package:file/memory.dart';
import 'package:flutter_plugin_tools/src/common/core.dart';
import 'package:flutter_plugin_tools/src/gradle_check_command.dart';
import 'package:test/test.dart';

import 'util.dart';

void main() {
  late CommandRunner<void> runner;
  late FileSystem fileSystem;
  late Directory packagesDir;

  setUp(() {
    fileSystem = MemoryFileSystem();
    packagesDir = fileSystem.currentDirectory.childDirectory('packages');
    createPackagesDirectory(parentDir: packagesDir.parent);
    final GradleCheckCommand command = GradleCheckCommand(
      packagesDir,
    );

    runner = CommandRunner<void>(
        'gradle_check_command', 'Test for gradle_check_command');
    runner.addCommand(command);
  });

  void writeFakeBuildGradle(
    RepositoryPackage package, {
    bool includeLanguageVersion = false,
    bool includeSourceCompat = false,
    bool commentRequiredLine = false,
  }) {
    final File buildGradle = package
        .platformDirectory(FlutterPlatform.android)
        .childFile('build.gradle');
    buildGradle.createSync(recursive: true);

    final String compileOptionsSection = '''
    compileOptions {
        ${commentRequiredLine ? '// ' : ''}sourceCompatibility JavaVersion.VERSION_1_8
    }
''';
    final String javaSection = '''
java {
    toolchain {
        ${commentRequiredLine ? '// ' : ''}languageVersion = JavaLanguageVersion.of(8)
    }
}

''';

    buildGradle.writeAsStringSync('''
group 'dev.flutter.plugins.fake'
version '1.0-SNAPSHOT'

buildscript {
    repositories {
        google()
        mavenCentral()
    }
}

apply plugin: 'com.android.library'

${includeLanguageVersion ? javaSection : ''}
android {
    compileSdkVersion 33

    defaultConfig {
        minSdkVersion 30
    }
    lintOptions {
        checkAllWarnings true
    }
    testOptions {
        unitTests.includeAndroidResources = true
    }
${includeSourceCompat ? compileOptionsSection : ''}
}

dependencies {
    implementation 'fake.package:fake:1.0.0'
}
''');
  }

  test('skips when package has no Android directory', () async {
    createFakePackage('a_package', packagesDir, examples: <String>[]);

    final List<String> output =
        await runCapturingPrint(runner, <String>['gradle-check']);

    expect(
      output,
      containsAllInOrder(<Matcher>[
        contains('Skipped 1 package(s)'),
      ]),
    );
  });

  test('fails when build.gradle has no java compatibility version', () async {
    final RepositoryPackage package =
        createFakePlugin('a_plugin', packagesDir, examples: <String>[]);
    writeFakeBuildGradle(package);

    Error? commandError;
    final List<String> output = await runCapturingPrint(
        runner, <String>['gradle-check'], errorHandler: (Error e) {
      commandError = e;
    });

    expect(commandError, isA<ToolExit>());
    expect(
      output,
      containsAllInOrder(<Matcher>[
        contains(
            'build.gradle must set an explicit Java compatibility version.'),
      ]),
    );
  });

  test('passes when sourceCompatibility is specified', () async {
    final RepositoryPackage package =
        createFakePlugin('a_plugin', packagesDir, examples: <String>[]);
    writeFakeBuildGradle(package, includeSourceCompat: true);

    final List<String> output =
        await runCapturingPrint(runner, <String>['gradle-check']);

    expect(
      output,
      containsAllInOrder(<Matcher>[
        contains('Validating android/build.gradle'),
      ]),
    );
  });

  test('passes when toolchain languageVersion is specified', () async {
    final RepositoryPackage package =
        createFakePlugin('a_plugin', packagesDir, examples: <String>[]);
    writeFakeBuildGradle(package, includeLanguageVersion: true);

    final List<String> output =
        await runCapturingPrint(runner, <String>['gradle-check']);

    expect(
      output,
      containsAllInOrder(<Matcher>[
        contains('Validating android/build.gradle'),
      ]),
    );
  });

  test('does not require java version in examples', () async {
    final RepositoryPackage package = createFakePlugin('a_plugin', packagesDir);
    writeFakeBuildGradle(package, includeLanguageVersion: true);
    writeFakeBuildGradle(package.getExamples().first);

    final List<String> output =
        await runCapturingPrint(runner, <String>['gradle-check']);

    expect(
      output,
      containsAllInOrder(<Matcher>[
        contains('Validating android/build.gradle'),
        contains('Ran for 2 package(s)'),
      ]),
    );
  });

  test('fails when java compatibility version is commented out', () async {
    final RepositoryPackage package =
        createFakePlugin('a_plugin', packagesDir, examples: <String>[]);
    writeFakeBuildGradle(package,
        includeSourceCompat: true, commentRequiredLine: true);

    Error? commandError;
    final List<String> output = await runCapturingPrint(
        runner, <String>['gradle-check'], errorHandler: (Error e) {
      commandError = e;
    });

    expect(commandError, isA<ToolExit>());
    expect(
      output,
      containsAllInOrder(<Matcher>[
        contains(
            'build.gradle must set an explicit Java compatibility version.'),
      ]),
    );
  });

  test('fails when languageVersion is commented out', () async {
    final RepositoryPackage package =
        createFakePlugin('a_plugin', packagesDir, examples: <String>[]);
    writeFakeBuildGradle(package,
        includeLanguageVersion: true, commentRequiredLine: true);

    Error? commandError;
    final List<String> output = await runCapturingPrint(
        runner, <String>['gradle-check'], errorHandler: (Error e) {
      commandError = e;
    });

    expect(commandError, isA<ToolExit>());
    expect(
      output,
      containsAllInOrder(<Matcher>[
        contains(
            'build.gradle must set an explicit Java compatibility version.'),
      ]),
    );
  });
}
