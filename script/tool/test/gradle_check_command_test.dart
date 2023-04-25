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

const String _defaultFakeNamespace = 'dev.flutter.foo';

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
    bool isApp = false,
    bool includeLanguageVersion = false,
    bool includeSourceCompat = false,
    bool commentSourceLanguage = false,
    bool includeNamespace = true,
    bool commentNamespace = false,
  }) {
    final Directory androidDir =
        package.platformDirectory(FlutterPlatform.android);
    final Directory parentDir =
        isApp ? androidDir.childDirectory('app') : androidDir;
    final File buildGradle = parentDir.childFile('build.gradle');
    buildGradle.createSync(recursive: true);

    final String compileOptionsSection = '''
    compileOptions {
        ${commentSourceLanguage ? '// ' : ''}sourceCompatibility JavaVersion.VERSION_1_8
    }
''';
    final String javaSection = '''
java {
    toolchain {
        ${commentSourceLanguage ? '// ' : ''}languageVersion = JavaLanguageVersion.of(8)
    }
}

''';
    final String namespace =
        "${commentNamespace ? '// ' : ''}namespace '$_defaultFakeNamespace'";

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
    ${includeNamespace ? namespace : ''}
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

  void writeFakeManifest(
    RepositoryPackage package, {
    bool isApp = false,
    String packageName = _defaultFakeNamespace,
  }) {
    final Directory androidDir =
        package.platformDirectory(FlutterPlatform.android);
    final Directory startDir =
        isApp ? androidDir.childDirectory('app') : androidDir;
    final File manifest = startDir
        .childDirectory('src')
        .childDirectory('main')
        .childFile('AndroidManifest.xml');
    manifest.createSync(recursive: true);
    manifest.writeAsString('''
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="$packageName">
</manifest>''');
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
    writeFakeManifest(package);

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
    writeFakeManifest(package);

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
    writeFakeManifest(package);

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
    writeFakeManifest(package);
    final RepositoryPackage example = package.getExamples().first;
    writeFakeBuildGradle(example, isApp: true);
    writeFakeManifest(example, isApp: true);

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
        includeSourceCompat: true, commentSourceLanguage: true);
    writeFakeManifest(package);

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
        includeLanguageVersion: true, commentSourceLanguage: true);
    writeFakeManifest(package);

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

  test('fails when plugin namespace does not match AndroidManifest.xml',
      () async {
    final RepositoryPackage package =
        createFakePlugin('a_plugin', packagesDir, examples: <String>[]);
    writeFakeBuildGradle(package, includeLanguageVersion: true);
    writeFakeManifest(package, packageName: 'wrong.package.name');

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
            'build.gradle "namespace" must match the "package" attribute in AndroidManifest.xml'),
      ]),
    );
  });

  test('fails when namespace is missing', () async {
    final RepositoryPackage package =
        createFakePlugin('a_plugin', packagesDir, examples: <String>[]);
    writeFakeBuildGradle(package,
        includeLanguageVersion: true, includeNamespace: false);
    writeFakeManifest(package);

    Error? commandError;
    final List<String> output = await runCapturingPrint(
        runner, <String>['gradle-check'], errorHandler: (Error e) {
      commandError = e;
    });

    expect(commandError, isA<ToolExit>());
    expect(
      output,
      containsAllInOrder(<Matcher>[
        contains('build.gradle must set a "namespace"'),
      ]),
    );
  });

  test('fails when namespace is missing from example', () async {
    final RepositoryPackage package = createFakePlugin('a_plugin', packagesDir);
    writeFakeBuildGradle(package, includeLanguageVersion: true);
    writeFakeManifest(package);
    final RepositoryPackage example = package.getExamples().first;
    writeFakeBuildGradle(example,
        isApp: true, includeLanguageVersion: true, includeNamespace: false);
    writeFakeManifest(example, isApp: true);

    Error? commandError;
    final List<String> output = await runCapturingPrint(
        runner, <String>['gradle-check'], errorHandler: (Error e) {
      commandError = e;
    });

    expect(commandError, isA<ToolExit>());
    expect(
      output,
      containsAllInOrder(<Matcher>[
        contains('build.gradle must set a "namespace"'),
      ]),
    );
  });

  // TODO(stuartmorgan): Consider removing this in the future; we may at some
  // point decide that we have a use case of example apps having different
  // app IDs and namespaces. For now, it's enforced for consistency so they
  // don't just accidentally diverge.
  test('fails when namespace in example does not match AndroidManifest.xml',
      () async {
    final RepositoryPackage package = createFakePlugin('a_plugin', packagesDir);
    writeFakeBuildGradle(package, includeLanguageVersion: true);
    writeFakeManifest(package);
    final RepositoryPackage example = package.getExamples().first;
    writeFakeBuildGradle(example, isApp: true, includeLanguageVersion: true);
    writeFakeManifest(example, isApp: true, packageName: 'wrong.package.name');

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
            'build.gradle "namespace" must match the "package" attribute in AndroidManifest.xml'),
      ]),
    );
  });

  test('fails when namespace is commented out', () async {
    final RepositoryPackage package =
        createFakePlugin('a_plugin', packagesDir, examples: <String>[]);
    writeFakeBuildGradle(package,
        includeLanguageVersion: true, commentNamespace: true);
    writeFakeManifest(package);

    Error? commandError;
    final List<String> output = await runCapturingPrint(
        runner, <String>['gradle-check'], errorHandler: (Error e) {
      commandError = e;
    });

    expect(commandError, isA<ToolExit>());
    expect(
      output,
      containsAllInOrder(<Matcher>[
        contains('build.gradle must set a "namespace"'),
      ]),
    );
  });
}
