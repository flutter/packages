// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:args/command_runner.dart';
import 'package:file/file.dart';
import 'package:file/memory.dart';
import 'package:flutter_plugin_tools/src/common/core.dart';
import 'package:flutter_plugin_tools/src/common/plugin_utils.dart';
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

  /// Writes a fake android/build.gradle file for plugin [package] with the
  /// given options.
  void writeFakePluginBuildGradle(
    RepositoryPackage package, {
    bool includeLanguageVersion = false,
    bool includeSourceCompat = false,
    bool includeTargetCompat = false,
    bool commentSourceLanguage = false,
    bool includeNamespace = true,
    bool commentNamespace = false,
    bool warningsConfigured = true,
  }) {
    final File buildGradle = package
        .platformDirectory(FlutterPlatform.android)
        .childFile('build.gradle');
    buildGradle.createSync(recursive: true);

    const String warningConfig = '''
    lintOptions {
        checkAllWarnings true
        warningsAsErrors true
        disable 'AndroidGradlePluginVersion', 'InvalidPackage', 'GradleDependency', 'NewerVersionAvailable'
        baseline file("lint-baseline.xml")
    }
''';
    final String javaSection = '''
java {
    toolchain {
        ${commentSourceLanguage ? '// ' : ''}languageVersion = JavaLanguageVersion.of(8)
    }
}

''';
    final String sourceCompat =
        '${commentSourceLanguage ? '// ' : ''}sourceCompatibility JavaVersion.VERSION_11';
    final String targetCompat =
        '${commentSourceLanguage ? '// ' : ''}targetCompatibility JavaVersion.VERSION_11';
    final String namespace =
        "    ${commentNamespace ? '// ' : ''}namespace '$_defaultFakeNamespace'";

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
    compileSdk 33

    defaultConfig {
        minSdkVersion 30
    }
${warningsConfigured ? warningConfig : ''}
    compileOptions {
        ${includeSourceCompat ? sourceCompat : ''}
        ${includeTargetCompat ? targetCompat : ''}
    }
    testOptions {
        unitTests.includeAndroidResources = true
    }
}

dependencies {
    implementation 'fake.package:fake:1.0.0'
}
''');
  }

  /// Writes a fake android/build.gradle file for an example [package] with the
  /// given options.
  void writeFakeExampleTopLevelBuildGradle(
    RepositoryPackage package, {
    required String pluginName,
    required bool warningsConfigured,
    String? kotlinVersion,
    bool includeArtifactHub = true,
  }) {
    final File buildGradle = package
        .platformDirectory(FlutterPlatform.android)
        .childFile('build.gradle');
    buildGradle.createSync(recursive: true);

    final String warningConfig = '''
gradle.projectsEvaluated {
    project(":$pluginName") {
        tasks.withType(JavaCompile) {
            options.compilerArgs << "-Xlint:all" << "-Werror"
        }
    }
}
''';
    buildGradle.writeAsStringSync('''
buildscript {
    ${kotlinVersion == null ? '' : "ext.kotlin_version = '$kotlinVersion'"}
    repositories {
        ${includeArtifactHub ? GradleCheckCommand.exampleRootGradleArtifactHubString : ''}
        google()
        mavenCentral()
    }

    dependencies {
        classpath 'fake.package:fake:1.0.0'
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

rootProject.buildDir = '../build'
subprojects {
    project.buildDir = "\${rootProject.buildDir}/\${project.name}"
}
subprojects {
    project.evaluationDependsOn(':app')
}

task clean(type: Delete) {
    delete rootProject.buildDir
}

${warningsConfigured ? warningConfig : ''}
''');
  }

  /// Writes a fake android/build.gradle file for an example [package] with the
  /// given options.
  void writeFakeExampleTopLevelSettingsGradle(
    RepositoryPackage package, {
    bool includeArtifactHub = true,
  }) {
    final File settingsGradle = package
        .platformDirectory(FlutterPlatform.android)
        .childFile('settings.gradle');
    settingsGradle.createSync(recursive: true);

    settingsGradle.writeAsStringSync('''
include ':app'

def flutterProjectRoot = rootProject.projectDir.parentFile.toPath()

def plugins = new Properties()
def pluginsFile = new File(flutterProjectRoot.toFile(), '.flutter-plugins')
if (pluginsFile.exists()) {
    pluginsFile.withInputStream { stream -> plugins.load(stream) }
}

plugins.each { name, path ->
    def pluginDirectory = flutterProjectRoot.resolve(path).resolve('android').toFile()
    include ":\$name"
    project(":\$name").projectDir = pluginDirectory
}
${includeArtifactHub ? GradleCheckCommand.exampleRootSettingsArtifactHubString : ''}
''');
  }

  /// Writes a fake android/app/build.gradle file for an example [package] with
  /// the given options.
  void writeFakeExampleAppBuildGradle(
    RepositoryPackage package, {
    required bool includeNamespace,
    required bool commentNamespace,
  }) {
    final File buildGradle = package
        .platformDirectory(FlutterPlatform.android)
        .childDirectory('app')
        .childFile('build.gradle');
    buildGradle.createSync(recursive: true);

    final String namespace =
        "${commentNamespace ? '// ' : ''}namespace '$_defaultFakeNamespace'";
    buildGradle.writeAsStringSync('''
def flutterRoot = localProperties.getProperty('flutter.sdk')
if (flutterRoot == null) {
    throw new GradleException("Flutter SDK not found. Define location with flutter.sdk in the local.properties file.")
}

apply plugin: 'com.android.application'
apply from: "\$flutterRoot/packages/flutter_tools/gradle/flutter.gradle"

android {
    ${includeNamespace ? namespace : ''}
    compileSdk flutter.compileSdkVersion

    lintOptions {
        disable 'InvalidPackage'
    }

    defaultConfig {
        applicationId "io.flutter.plugins.cameraexample"
        minSdkVersion 21
        targetSdkVersion 28
    }
}

flutter {
    source '../..'
}

dependencies {
    testImplementation 'fake.package:fake:1.0.0'
}
''');
  }

  void writeFakeExampleBuildGradles(
    RepositoryPackage package, {
    required String pluginName,
    bool includeNamespace = true,
    bool commentNamespace = false,
    bool warningsConfigured = true,
    String? kotlinVersion,
    bool includeBuildArtifactHub = true,
    bool includeSettingsArtifactHub = true,
  }) {
    writeFakeExampleTopLevelBuildGradle(
      package,
      pluginName: pluginName,
      warningsConfigured: warningsConfigured,
      kotlinVersion: kotlinVersion,
      includeArtifactHub: includeBuildArtifactHub,
    );
    writeFakeExampleAppBuildGradle(package,
        includeNamespace: includeNamespace, commentNamespace: commentNamespace);
    writeFakeExampleTopLevelSettingsGradle(
      package,
      includeArtifactHub: includeSettingsArtifactHub,
    );
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
    writeFakePluginBuildGradle(package);
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

  test(
      'fails when sourceCompatibility is provided with out targetCompatibility',
      () async {
    final RepositoryPackage package =
        createFakePlugin('a_plugin', packagesDir, examples: <String>[]);
    writeFakePluginBuildGradle(package, includeSourceCompat: true);
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

  test('passes when sourceCompatibility and targetCompatibility are specified',
      () async {
    final RepositoryPackage package =
        createFakePlugin('a_plugin', packagesDir, examples: <String>[]);
    writeFakePluginBuildGradle(package,
        includeSourceCompat: true, includeTargetCompat: true);
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
    writeFakePluginBuildGradle(package, includeLanguageVersion: true);
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
    const String pluginName = 'a_plugin';
    final RepositoryPackage package = createFakePlugin(pluginName, packagesDir);
    writeFakePluginBuildGradle(package, includeLanguageVersion: true);
    writeFakeManifest(package);
    final RepositoryPackage example = package.getExamples().first;
    writeFakeExampleBuildGradles(example, pluginName: pluginName);
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
    writeFakePluginBuildGradle(package,
        includeSourceCompat: true,
        includeTargetCompat: true,
        commentSourceLanguage: true);
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
    writeFakePluginBuildGradle(package,
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
    writeFakePluginBuildGradle(package, includeLanguageVersion: true);
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
    writeFakePluginBuildGradle(package,
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
    const String pluginName = 'a_plugin';
    final RepositoryPackage package = createFakePlugin(pluginName, packagesDir);
    writeFakePluginBuildGradle(package, includeLanguageVersion: true);
    writeFakeManifest(package);
    final RepositoryPackage example = package.getExamples().first;
    writeFakeExampleBuildGradles(example,
        pluginName: pluginName, includeNamespace: false);
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
    const String pluginName = 'a_plugin';
    final RepositoryPackage package = createFakePlugin(pluginName, packagesDir);
    writeFakePluginBuildGradle(package, includeLanguageVersion: true);
    writeFakeManifest(package);
    final RepositoryPackage example = package.getExamples().first;
    writeFakeExampleBuildGradles(example, pluginName: pluginName);
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
    writeFakePluginBuildGradle(package,
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

  test('fails if gradle-driven lint-warnings-as-errors is missing', () async {
    const String pluginName = 'a_plugin';
    final RepositoryPackage plugin =
        createFakePlugin(pluginName, packagesDir, examples: <String>[]);
    writeFakePluginBuildGradle(plugin,
        includeLanguageVersion: true, warningsConfigured: false);
    writeFakeManifest(plugin);

    Error? commandError;
    final List<String> output = await runCapturingPrint(
        runner, <String>['gradle-check'], errorHandler: (Error e) {
      commandError = e;
    });

    expect(commandError, isA<ToolExit>());
    expect(
        output,
        containsAllInOrder(
          <Matcher>[
            contains('This package is not configured to enable all '
                'Gradle-driven lint warnings and treat them as errors.'),
            contains('The following packages had errors:'),
          ],
        ));
  });

  test('fails if plugin example javac lint-warnings-as-errors is missing',
      () async {
    const String pluginName = 'a_plugin';
    final RepositoryPackage plugin = createFakePlugin(pluginName, packagesDir,
        platformSupport: <String, PlatformDetails>{
          platformAndroid: const PlatformDetails(PlatformSupport.inline),
        });
    writeFakePluginBuildGradle(plugin, includeLanguageVersion: true);
    writeFakeManifest(plugin);
    final RepositoryPackage example = plugin.getExamples().first;
    writeFakeExampleBuildGradles(example,
        pluginName: pluginName, warningsConfigured: false);
    writeFakeManifest(example, isApp: true);

    Error? commandError;
    final List<String> output = await runCapturingPrint(
        runner, <String>['gradle-check'], errorHandler: (Error e) {
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

  test(
      'passes if non-plugin package example javac lint-warnings-as-errors is missing',
      () async {
    const String packageName = 'a_package';
    final RepositoryPackage plugin =
        createFakePackage(packageName, packagesDir);
    final RepositoryPackage example = plugin.getExamples().first;
    writeFakeExampleBuildGradles(example,
        pluginName: packageName, warningsConfigured: false);
    writeFakeManifest(example, isApp: true);

    final List<String> output =
        await runCapturingPrint(runner, <String>['gradle-check']);

    expect(
        output,
        containsAllInOrder(
          <Matcher>[
            contains('Validating android/build.gradle'),
          ],
        ));
  });

  group('Artifact Hub check', () {
    test('passes build.gradle artifact hub check when set', () async {
      const String packageName = 'a_package';
      final RepositoryPackage package =
          createFakePackage('a_package', packagesDir);
      writeFakePluginBuildGradle(package, includeLanguageVersion: true);
      writeFakeManifest(package);
      final RepositoryPackage example = package.getExamples().first;
      writeFakeExampleBuildGradles(
        example,
        pluginName: packageName,
        // ignore: avoid_redundant_argument_values
        includeBuildArtifactHub: true,
        // ignore: avoid_redundant_argument_values
        includeSettingsArtifactHub: true,
      );
      writeFakeManifest(example, isApp: true);

      final List<String> output =
          await runCapturingPrint(runner, <String>['gradle-check']);

      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('Validating android/build.gradle'),
          contains('Validating android/settings.gradle'),
        ]),
      );
    });
    test('fails artifact hub check when build and settings sections missing',
        () async {
      const String packageName = 'a_package';
      final RepositoryPackage package =
          createFakePackage('a_package', packagesDir);
      writeFakePluginBuildGradle(package, includeLanguageVersion: true);
      writeFakeManifest(package);
      final RepositoryPackage example = package.getExamples().first;
      writeFakeExampleBuildGradles(
        example,
        pluginName: packageName,
        includeBuildArtifactHub: false,
        includeSettingsArtifactHub: false,
      );
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
          contains(GradleCheckCommand.exampleRootGradleArtifactHubString),
          contains(GradleCheckCommand.exampleRootSettingsArtifactHubString),
        ]),
      );
    });

    test('fails build.gradle artifact hub check when missing', () async {
      const String packageName = 'a_package';
      final RepositoryPackage package =
          createFakePackage('a_package', packagesDir);
      writeFakePluginBuildGradle(package, includeLanguageVersion: true);
      writeFakeManifest(package);
      final RepositoryPackage example = package.getExamples().first;
      writeFakeExampleBuildGradles(example,
          pluginName: packageName,
          includeBuildArtifactHub: false,
          // ignore: avoid_redundant_argument_values
          includeSettingsArtifactHub: true);
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
          contains(GradleCheckCommand.exampleRootGradleArtifactHubString),
        ]),
      );
      expect(
        output,
        isNot(
            contains(GradleCheckCommand.exampleRootSettingsArtifactHubString)),
      );
    });

    test('fails settings.gradle artifact hub check when missing', () async {
      const String packageName = 'a_package';
      final RepositoryPackage package =
          createFakePackage('a_package', packagesDir);
      writeFakePluginBuildGradle(package, includeLanguageVersion: true);
      writeFakeManifest(package);
      final RepositoryPackage example = package.getExamples().first;
      writeFakeExampleBuildGradles(example,
          pluginName: packageName,
          // ignore: avoid_redundant_argument_values
          includeBuildArtifactHub: true,
          includeSettingsArtifactHub: false);
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
          contains(GradleCheckCommand.exampleRootSettingsArtifactHubString),
        ]),
      );
      expect(
        output,
        isNot(contains(GradleCheckCommand.exampleRootGradleArtifactHubString)),
      );
    });
  });

  group('Kotlin version check', () {
    test('passes if not set', () async {
      const String packageName = 'a_package';
      final RepositoryPackage package =
          createFakePackage('a_package', packagesDir);
      writeFakePluginBuildGradle(package, includeLanguageVersion: true);
      writeFakeManifest(package);
      final RepositoryPackage example = package.getExamples().first;
      writeFakeExampleBuildGradles(example, pluginName: packageName);
      writeFakeManifest(example, isApp: true);

      final List<String> output =
          await runCapturingPrint(runner, <String>['gradle-check']);

      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('Validating android/build.gradle'),
        ]),
      );
    });

    test('passes if at the minimum allowed version', () async {
      const String packageName = 'a_package';
      final RepositoryPackage package =
          createFakePackage('a_package', packagesDir);
      writeFakePluginBuildGradle(package, includeLanguageVersion: true);
      writeFakeManifest(package);
      final RepositoryPackage example = package.getExamples().first;
      writeFakeExampleBuildGradles(example,
          pluginName: packageName, kotlinVersion: minKotlinVersion.toString());
      writeFakeManifest(example, isApp: true);

      final List<String> output =
          await runCapturingPrint(runner, <String>['gradle-check']);

      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('Validating android/build.gradle'),
        ]),
      );
    });

    test('passes if above the minimum allowed version', () async {
      const String packageName = 'a_package';
      final RepositoryPackage package =
          createFakePackage('a_package', packagesDir);
      writeFakePluginBuildGradle(package, includeLanguageVersion: true);
      writeFakeManifest(package);
      final RepositoryPackage example = package.getExamples().first;
      writeFakeExampleBuildGradles(example,
          pluginName: packageName, kotlinVersion: '99.99.0');
      writeFakeManifest(example, isApp: true);

      final List<String> output =
          await runCapturingPrint(runner, <String>['gradle-check']);

      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('Validating android/build.gradle'),
        ]),
      );
    });

    test('fails if below the minimum allowed version', () async {
      const String packageName = 'a_package';
      final RepositoryPackage package =
          createFakePackage('a_package', packagesDir);
      writeFakePluginBuildGradle(package, includeLanguageVersion: true);
      writeFakeManifest(package);
      final RepositoryPackage example = package.getExamples().first;
      writeFakeExampleBuildGradles(example,
          pluginName: packageName, kotlinVersion: '1.6.21');
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
          contains('build.gradle sets "ext.kotlin_version" to "1.6.21". The '
              'minimum Kotlin version that can be specified is '
              '$minKotlinVersion, for compatibility with modern dependencies.'),
        ]),
      );
    });
  });
}
