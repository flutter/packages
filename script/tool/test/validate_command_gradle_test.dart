// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:args/command_runner.dart';
import 'package:file/file.dart';
import 'package:flutter_plugin_tools/src/common/core.dart';
import 'package:flutter_plugin_tools/src/common/plugin_utils.dart';
import 'package:flutter_plugin_tools/src/validate_command.dart';
import 'package:flutter_plugin_tools/src/validators/gradle_validator.dart';
import 'package:git/git.dart';
import 'package:test/test.dart';

import 'util.dart';

const String _defaultFakeNamespace = 'dev.flutter.foo';

void main() {
  late CommandRunner<void> runner;
  late Directory packagesDir;
  const javaIncompatabilityIndicator =
      'build.gradle.kts must set an explicit Java compatibility version.';

  setUp(() {
    final GitDir gitDir;
    (:packagesDir, processRunner: _, gitProcessRunner: _, :gitDir) = configureBaseCommandMocks();
    final command = ValidateCommand(
      packagesDir,
      gitDir: gitDir,
      targetedValidators: {Validator.gradle},
    );

    runner = CommandRunner<void>('validate_gradle_test', 'Test for gradle validations');
    runner.addCommand(command);
  });

  /// Writes a fake android/build.gradle.kts file for plugin [package] with the
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
    String compileSdk = '36',
    bool includeKotlinCompilerOptions = true,
    bool commentKotlinCompilerOptions = false,
    bool useDeprecatedJvmTargetStyle = false,
    bool useJavaVersionStringForJvmTarget = false,
    int jvmTargetValue = 17,
    int kotlinJvmValue = 17,
    bool includeKotlinGradlePlugin = false,
    bool includeDeprecatedKotlinOptionsInsideAndroid = false,
    bool includeDeprecatedKotlinOptionsInsideKotlin = false,
  }) {
    final File buildGradle = package
        .platformDirectory(FlutterPlatform.android)
        .childFile('build.gradle.kts');
    buildGradle.createSync(recursive: true);

    const warningConfig = '''
    lint {
        checkAllWarnings = true
        warningsAsErrors = true
        disable.addAll(setOf("AndroidGradlePluginVersion", "InvalidPackage", "GradleDependency", "NewerVersionAvailable"))
        baseline = file("lint-baseline.xml")
    }
''';
    final javaSection =
        '''
java {
    toolchain {
        ${commentSourceLanguage ? '// ' : ''}languageVersion = JavaLanguageVersion.of(8)
    }
}

''';
    final sourceCompat =
        '${commentSourceLanguage ? '// ' : ''}sourceCompatibility = JavaVersion.VERSION_$jvmTargetValue';
    final targetCompat =
        '${commentSourceLanguage ? '// ' : ''}targetCompatibility = JavaVersion.VERSION_$jvmTargetValue';
    final namespace = '    ${commentNamespace ? '// ' : ''}namespace = "$_defaultFakeNamespace"';
    final _KotlinConfigParts kotlinConfigParts = _generateKotlinConfigParts(
      commentKotlinCompilerOptions: commentKotlinCompilerOptions,
      useJavaVersionStringForJvmTarget: useJavaVersionStringForJvmTarget,
      useDeprecatedJvmTargetStyle: useDeprecatedJvmTargetStyle,
      jvmTargetValue: jvmTargetValue,
      kotlinJvmValue: kotlinJvmValue,
    );

    buildGradle.writeAsStringSync('''
group = "dev.flutter.plugins.fake"
version = "1.0-SNAPSHOT"

buildscript {
    repositories {
        google()
        mavenCentral()
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

plugins {
    id("com.android.library")
    ${includeKotlinGradlePlugin ? 'id("kotlin-android")' : ''}
}

${includeLanguageVersion ? javaSection : ''}
${includeKotlinCompilerOptions ? kotlinConfigParts.kotlinConfig : ''}
${includeDeprecatedKotlinOptionsInsideKotlin ? kotlinConfigParts.kotlinDeprecatedInKotlinConfig : ''}

android {
${includeNamespace ? namespace : ''}
    compileSdk = $compileSdk

    defaultConfig {
        minSdk = 30
    }
${warningsConfigured ? warningConfig : ''}
    compileOptions {
        ${includeSourceCompat ? sourceCompat : ''}
        ${includeTargetCompat ? targetCompat : ''}
    }
    ${includeDeprecatedKotlinOptionsInsideAndroid ? kotlinConfigParts.kotlinDeprecatedInAndroidConfig : ''}
    testOptions {
        unitTests {
            isIncludeAndroidResources = true
        }
    }
}

dependencies {
    implementation("fake.package:fake:1.0.0")
}
''');
  }

  /// Writes a fake android/build.gradle.kts file for an example [package] with
  /// the given options.
  void writeFakeExampleTopLevelBuildGradle(
    RepositoryPackage package, {
    required String pluginName,
    bool warningsConfigured = true,
    bool includeArtifactHub = true,
  }) {
    final File buildGradle = package
        .platformDirectory(FlutterPlatform.android)
        .childFile('build.gradle.kts');
    buildGradle.createSync(recursive: true);

    final warningConfig =
        '''
gradle.projectsEvaluated {
    project(":$pluginName") {
        tasks.withType<JavaCompile> {
            options.compilerArgs.addAll(listOf("-Xlint:all", "-Werror"))
        }
    }
}
''';

    buildGradle.writeAsStringSync('''
allprojects {
    repositories {
        ${includeArtifactHub ? GradleValidator.exampleRootGradleArtifactHubString : ''}
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}

${warningsConfigured ? warningConfig : ''}
''');
  }

  /// Writes a fake android/settings.gradle.kts file for an example [package]
  /// with the given options.
  void writeFakeExampleSettingsGradle(
    RepositoryPackage package, {
    required String kotlinVersion,
    bool includeArtifactHub = true,
    bool includeArtifactDocumentation = true,
  }) {
    final File settingsGradle = package
        .platformDirectory(FlutterPlatform.android)
        .childFile('settings.gradle.kts');
    settingsGradle.createSync(recursive: true);

    settingsGradle.writeAsStringSync('''
pluginManagement {
    val flutterSdkPath =
        run {
            val properties = java.util.Properties()
            file("local.properties").inputStream().use { properties.load(it) }
            val flutterSdkPath = properties.getProperty("flutter.sdk")
            require(flutterSdkPath != null) { "flutter.sdk not set in local.properties" }
            flutterSdkPath
        }

    includeBuild("\$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

${includeArtifactDocumentation ? '// See ${GradleValidator.artifactHubDocumentationString} for more info.' : ''}
plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    id("com.android.application") version "8.11.1" apply false
    id("org.jetbrains.kotlin.android") version "$kotlinVersion" apply false
    ${includeArtifactHub ? 'id("com.google.cloud.artifactregistry.gradle-plugin") version "2.2.1"' : ''}
}

include ":app"
''');
  }

  /// Writes a fake android/app/build.gradle.kts file for an example [package]
  /// with the given options.
  void writeFakeExampleAppBuildGradle(
    RepositoryPackage package, {
    required bool includeNamespace,
    required bool commentNamespace,
    bool includeKotlinCompilerOptions = true,
    bool commentKotlinCompilerOptions = false,
    bool useDeprecatedJvmTargetStyle = false,
    bool useJavaVersionStringForJvmTarget = false,
    int jvmTargetValue = 17,
    int kotlinJvmValue = 17,
    bool includeKotlinGradlePlugin = false,
    bool includeDeprecatedKotlinOptionsInsideAndroid = false,
    bool includeDeprecatedKotlinOptionsInsideKotlin = false,
  }) {
    final File buildGradle = package
        .platformDirectory(FlutterPlatform.android)
        .childDirectory('app')
        .childFile('build.gradle.kts');
    buildGradle.createSync(recursive: true);

    final namespace = '${commentNamespace ? '// ' : ''}namespace = "$_defaultFakeNamespace"';

    final _KotlinConfigParts kotlinConfigParts = _generateKotlinConfigParts(
      commentKotlinCompilerOptions: commentKotlinCompilerOptions,
      useJavaVersionStringForJvmTarget: useJavaVersionStringForJvmTarget,
      useDeprecatedJvmTargetStyle: useDeprecatedJvmTargetStyle,
      jvmTargetValue: jvmTargetValue,
      kotlinJvmValue: kotlinJvmValue,
    );

    buildGradle.writeAsStringSync('''
plugins {
    id("com.android.application")
    ${includeKotlinGradlePlugin ? 'id("kotlin-android")' : ''}
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

${includeKotlinCompilerOptions ? kotlinConfigParts.kotlinConfig : ''}
${includeDeprecatedKotlinOptionsInsideKotlin ? kotlinConfigParts.kotlinDeprecatedInKotlinConfig : ''}

android {
    ${includeNamespace ? namespace : ''}
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_$jvmTargetValue
        targetCompatibility = JavaVersion.VERSION_$jvmTargetValue
    }

    defaultConfig {
        applicationId = "$_defaultFakeNamespace.example"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
    ${includeDeprecatedKotlinOptionsInsideAndroid ? kotlinConfigParts.kotlinDeprecatedInAndroidConfig : ''}
}

flutter {
    source = "../.."
}
''');
  }

  void writeFakeExampleBuildGradles(
    RepositoryPackage package, {
    required String pluginName,
    String? kotlinVersion,
    bool includeNamespace = true,
    bool commentNamespace = false,
    bool warningsConfigured = true,
    bool includeBuildArtifactHub = true,
    bool includeSettingsArtifactHub = true,
    bool includeSettingsDocumentationArtifactHub = true,
    bool includeKotlinCompilerOptions = true,
    bool commentKotlinCompilerOptions = false,
    bool useDeprecatedJvmTargetStyle = false,
    bool useJavaVersionStringForJvmTarget = false,
    int jvmTargetValue = 17,
    int kotlinJvmValue = 17,
    bool includeKotlinGradlePlugin = false,
    bool includeDeprecatedKotlinOptionsInsideAndroid = false,
    bool includeDeprecatedKotlinOptionsInsideKotlin = false,
  }) {
    writeFakeExampleTopLevelBuildGradle(
      package,
      pluginName: pluginName,
      warningsConfigured: warningsConfigured,
      includeArtifactHub: includeBuildArtifactHub,
    );
    writeFakeExampleAppBuildGradle(
      package,
      includeNamespace: includeNamespace,
      commentNamespace: commentNamespace,
      includeKotlinCompilerOptions: includeKotlinCompilerOptions,
      commentKotlinCompilerOptions: commentKotlinCompilerOptions,
      useDeprecatedJvmTargetStyle: useDeprecatedJvmTargetStyle,
      useJavaVersionStringForJvmTarget: useJavaVersionStringForJvmTarget,
      jvmTargetValue: jvmTargetValue,
      kotlinJvmValue: kotlinJvmValue,
      includeKotlinGradlePlugin: includeKotlinGradlePlugin,
      includeDeprecatedKotlinOptionsInsideAndroid: includeDeprecatedKotlinOptionsInsideAndroid,
      includeDeprecatedKotlinOptionsInsideKotlin: includeDeprecatedKotlinOptionsInsideKotlin,
    );
    writeFakeExampleSettingsGradle(
      package,
      kotlinVersion: kotlinVersion ?? '2.2.20',
      includeArtifactHub: includeSettingsArtifactHub,
      includeArtifactDocumentation: includeSettingsDocumentationArtifactHub,
    );
  }

  void writeFakeManifest(
    RepositoryPackage package, {
    bool isApp = false,
    String packageName = _defaultFakeNamespace,
  }) {
    final Directory androidDir = package.platformDirectory(FlutterPlatform.android);
    final Directory startDir = isApp ? androidDir.childDirectory('app') : androidDir;
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

  test('passes when package has no Android directory', () async {
    createFakePackage('a_package', packagesDir, examples: <String>[]);

    final List<String> output = await runCapturingPrint(runner, <String>['validate']);

    expect(output, containsAllInOrder(<Matcher>[contains('Running for a_package')]));
  });

  test('fails when build.gradle.kts has no java compatibility version', () async {
    final RepositoryPackage package = createFakePlugin(
      'a_plugin',
      packagesDir,
      examples: <String>[],
    );
    writeFakePluginBuildGradle(package);
    writeFakeManifest(package);

    Error? commandError;
    final List<String> output = await runCapturingPrint(
      runner,
      <String>['validate'],
      errorHandler: (Error e) {
        commandError = e;
      },
    );

    expect(commandError, isA<ToolExit>());
    expect(output, containsAllInOrder(<Matcher>[contains(javaIncompatabilityIndicator)]));
  });

  test('fails when sourceCompatibility is provided with out targetCompatibility', () async {
    final RepositoryPackage package = createFakePlugin(
      'a_plugin',
      packagesDir,
      examples: <String>[],
    );
    writeFakePluginBuildGradle(package, includeSourceCompat: true);
    writeFakeManifest(package);

    Error? commandError;
    final List<String> output = await runCapturingPrint(
      runner,
      <String>['validate'],
      errorHandler: (Error e) {
        commandError = e;
      },
    );

    expect(commandError, isA<ToolExit>());
    expect(output, containsAllInOrder(<Matcher>[contains(javaIncompatabilityIndicator)]));
  });

  test('fails when sourceCompatibility/targetCompatibility are below minimum', () async {
    final RepositoryPackage package = createFakePlugin(
      'a_plugin',
      packagesDir,
      examples: <String>[],
    );
    writeFakePluginBuildGradle(
      package,
      includeSourceCompat: true,
      includeTargetCompat: true,
      jvmTargetValue: 11,
      kotlinJvmValue: 11,
    );
    writeFakeManifest(package);

    Error? commandError;
    final List<String> output = await runCapturingPrint(
      runner,
      <String>['validate'],
      errorHandler: (Error e) {
        commandError = e;
      },
    );

    expect(commandError, isA<ToolExit>());
    expect(
      output,
      containsAllInOrder(<Matcher>[
        contains('Which is below the minimum required. Use at least "JavaVersion.VERSION_'),
      ]),
    );
  });

  test('fails when compatibility values do not match kotlin compiler options', () async {
    final RepositoryPackage package = createFakePlugin(
      'a_plugin',
      packagesDir,
      examples: <String>[],
    );
    writeFakePluginBuildGradle(
      package,
      includeSourceCompat: true,
      includeTargetCompat: true,
      jvmTargetValue: 21,
      // ignore: avoid_redundant_argument_values
      kotlinJvmValue: 17,
    );
    writeFakeManifest(package);

    Error? commandError;
    final List<String> output = await runCapturingPrint(
      runner,
      <String>['validate'],
      errorHandler: (Error e) {
        commandError = e;
      },
    );

    expect(commandError, isA<ToolExit>());
    expect(
      output,
      containsAllInOrder(<Matcher>[
        contains(
          'If build.gradle.kts uses JavaVersion.* and JvmTarget.*, the versions must be the same.',
        ),
      ]),
    );
  });

  test('passes when jvmValues are higher than minimim', () async {
    final RepositoryPackage package = createFakePlugin(
      'a_plugin',
      packagesDir,
      examples: <String>[],
    );
    writeFakePluginBuildGradle(
      package,
      includeSourceCompat: true,
      includeTargetCompat: true,
      jvmTargetValue: 21,
      kotlinJvmValue: 21,
    );
    writeFakeManifest(package);

    final List<String> output = await runCapturingPrint(runner, <String>['validate']);

    expect(output, containsAllInOrder(<Matcher>[contains('Validating android/build.gradle.kts')]));
  });

  test('passes when sourceCompatibility and targetCompatibility are specified', () async {
    final RepositoryPackage package = createFakePlugin(
      'a_plugin',
      packagesDir,
      examples: <String>[],
    );
    writeFakePluginBuildGradle(package, includeSourceCompat: true, includeTargetCompat: true);
    writeFakeManifest(package);

    final List<String> output = await runCapturingPrint(runner, <String>['validate']);

    expect(output, containsAllInOrder(<Matcher>[contains('Validating android/build.gradle.kts')]));
  });

  test('passes when toolchain languageVersion is specified', () async {
    final RepositoryPackage package = createFakePlugin(
      'a_plugin',
      packagesDir,
      examples: <String>[],
    );
    writeFakePluginBuildGradle(package, includeLanguageVersion: true);
    writeFakeManifest(package);

    final List<String> output = await runCapturingPrint(runner, <String>['validate']);

    expect(output, containsAllInOrder(<Matcher>[contains('Validating android/build.gradle.kts')]));
  });

  test('does not require java version in examples', () async {
    const pluginName = 'a_plugin';
    final RepositoryPackage package = createFakePackage(pluginName, packagesDir);
    final RepositoryPackage example = package.getExamples().first;
    writeFakeExampleBuildGradles(example, pluginName: pluginName);
    writeFakeManifest(example, isApp: true);

    final List<String> output = await runCapturingPrint(runner, <String>['validate']);

    expect(
      output,
      containsAllInOrder(<Matcher>[
        contains('Running for a_plugin/example'),
        contains('Validating android/build.gradle.kts'),
      ]),
    );
  });

  test('fails when java compatibility version is commented out', () async {
    final RepositoryPackage package = createFakePlugin(
      'a_plugin',
      packagesDir,
      examples: <String>[],
    );
    writeFakePluginBuildGradle(
      package,
      includeSourceCompat: true,
      includeTargetCompat: true,
      commentSourceLanguage: true,
    );
    writeFakeManifest(package);

    Error? commandError;
    final List<String> output = await runCapturingPrint(
      runner,
      <String>['validate'],
      errorHandler: (Error e) {
        commandError = e;
      },
    );

    expect(commandError, isA<ToolExit>());
    expect(output, containsAllInOrder(<Matcher>[contains(javaIncompatabilityIndicator)]));
  });

  test('fails when languageVersion is commented out', () async {
    final RepositoryPackage package = createFakePlugin(
      'a_plugin',
      packagesDir,
      examples: <String>[],
    );
    writeFakePluginBuildGradle(package, includeLanguageVersion: true, commentSourceLanguage: true);
    writeFakeManifest(package);

    Error? commandError;
    final List<String> output = await runCapturingPrint(
      runner,
      <String>['validate'],
      errorHandler: (Error e) {
        commandError = e;
      },
    );

    expect(commandError, isA<ToolExit>());
    expect(output, containsAllInOrder(<Matcher>[contains(javaIncompatabilityIndicator)]));
  });

  test('fails when plugin namespace does not match AndroidManifest.xml', () async {
    final RepositoryPackage package = createFakePlugin(
      'a_plugin',
      packagesDir,
      examples: <String>[],
    );
    writeFakePluginBuildGradle(package, includeLanguageVersion: true);
    writeFakeManifest(package, packageName: 'wrong.package.name');

    Error? commandError;
    final List<String> output = await runCapturingPrint(
      runner,
      <String>['validate'],
      errorHandler: (Error e) {
        commandError = e;
      },
    );

    expect(commandError, isA<ToolExit>());
    expect(
      output,
      containsAllInOrder(<Matcher>[
        contains(
          'build.gradle.kts "namespace" must match the "package" attribute in AndroidManifest.xml',
        ),
      ]),
    );
  });

  test('fails when namespace is missing', () async {
    final RepositoryPackage package = createFakePlugin(
      'a_plugin',
      packagesDir,
      examples: <String>[],
    );
    writeFakePluginBuildGradle(package, includeLanguageVersion: true, includeNamespace: false);
    writeFakeManifest(package);

    Error? commandError;
    final List<String> output = await runCapturingPrint(
      runner,
      <String>['validate'],
      errorHandler: (Error e) {
        commandError = e;
      },
    );

    expect(commandError, isA<ToolExit>());
    expect(
      output,
      containsAllInOrder(<Matcher>[contains('build.gradle.kts must set a "namespace"')]),
    );
  });

  test('fails when namespace is missing from example', () async {
    const pluginName = 'a_plugin';
    final RepositoryPackage package = createFakePlugin(pluginName, packagesDir);
    writeFakePluginBuildGradle(package, includeLanguageVersion: true);
    writeFakeManifest(package);
    final RepositoryPackage example = package.getExamples().first;
    writeFakeExampleBuildGradles(example, pluginName: pluginName, includeNamespace: false);
    writeFakeManifest(example, isApp: true);

    Error? commandError;
    final List<String> output = await runCapturingPrint(
      runner,
      <String>['validate'],
      errorHandler: (Error e) {
        commandError = e;
      },
    );

    expect(commandError, isA<ToolExit>());
    expect(
      output,
      containsAllInOrder(<Matcher>[contains('build.gradle.kts must set a "namespace"')]),
    );
  });

  // TODO(stuartmorgan): Consider removing this in the future; we may at some
  // point decide that we have a use case of example apps having different
  // app IDs and namespaces. For now, it's enforced for consistency so they
  // don't just accidentally diverge.
  test('fails when namespace in example does not match AndroidManifest.xml', () async {
    const pluginName = 'a_plugin';
    final RepositoryPackage package = createFakePlugin(pluginName, packagesDir);
    writeFakePluginBuildGradle(package, includeLanguageVersion: true);
    writeFakeManifest(package);
    final RepositoryPackage example = package.getExamples().first;
    writeFakeExampleBuildGradles(example, pluginName: pluginName);
    writeFakeManifest(example, isApp: true, packageName: 'wrong.package.name');

    Error? commandError;
    final List<String> output = await runCapturingPrint(
      runner,
      <String>['validate'],
      errorHandler: (Error e) {
        commandError = e;
      },
    );

    expect(commandError, isA<ToolExit>());
    expect(
      output,
      containsAllInOrder(<Matcher>[
        contains(
          'build.gradle.kts "namespace" must match the "package" attribute in AndroidManifest.xml',
        ),
      ]),
    );
  });

  test('fails when namespace is commented out', () async {
    final RepositoryPackage package = createFakePlugin(
      'a_plugin',
      packagesDir,
      examples: <String>[],
    );
    writeFakePluginBuildGradle(package, includeLanguageVersion: true, commentNamespace: true);
    writeFakeManifest(package);

    Error? commandError;
    final List<String> output = await runCapturingPrint(
      runner,
      <String>['validate'],
      errorHandler: (Error e) {
        commandError = e;
      },
    );

    expect(commandError, isA<ToolExit>());
    expect(
      output,
      containsAllInOrder(<Matcher>[contains('build.gradle.kts must set a "namespace"')]),
    );
  });

  test('fails if gradle-driven lint-warnings-as-errors is missing', () async {
    const pluginName = 'a_plugin';
    final RepositoryPackage plugin = createFakePlugin(
      pluginName,
      packagesDir,
      examples: <String>[],
    );
    writeFakePluginBuildGradle(plugin, includeLanguageVersion: true, warningsConfigured: false);
    writeFakeManifest(plugin);

    Error? commandError;
    final List<String> output = await runCapturingPrint(
      runner,
      <String>['validate'],
      errorHandler: (Error e) {
        commandError = e;
      },
    );

    expect(commandError, isA<ToolExit>());
    expect(
      output,
      containsAllInOrder(<Matcher>[
        contains(
          'This package is not configured to enable all '
          'Gradle-driven lint warnings and treat them as errors.',
        ),
        contains('The following packages had errors:'),
      ]),
    );
  });

  test('fails if plugin example javac lint-warnings-as-errors is missing', () async {
    const pluginName = 'a_plugin';
    final RepositoryPackage plugin = createFakePlugin(
      pluginName,
      packagesDir,
      platformSupport: <String, PlatformDetails>{
        platformAndroid: const PlatformDetails(PlatformSupport.inline),
      },
    );
    writeFakePluginBuildGradle(plugin, includeLanguageVersion: true);
    writeFakeManifest(plugin);
    final RepositoryPackage example = plugin.getExamples().first;
    writeFakeExampleBuildGradles(example, pluginName: pluginName, warningsConfigured: false);
    writeFakeManifest(example, isApp: true);

    Error? commandError;
    final List<String> output = await runCapturingPrint(
      runner,
      <String>['validate'],
      errorHandler: (Error e) {
        commandError = e;
      },
    );

    expect(commandError, isA<ToolExit>());
    expect(
      output,
      containsAllInOrder(<Matcher>[
        contains(
          'The example "example" is not configured to treat javac '
          'lints and warnings as errors.',
        ),
        contains('The following packages had errors:'),
      ]),
    );
  });

  test('passes if non-plugin package example javac lint-warnings-as-errors is missing', () async {
    const packageName = 'a_package';
    final RepositoryPackage plugin = createFakePackage(packageName, packagesDir);
    final RepositoryPackage example = plugin.getExamples().first;
    writeFakeExampleBuildGradles(example, pluginName: packageName, warningsConfigured: false);
    writeFakeManifest(example, isApp: true);

    final List<String> output = await runCapturingPrint(runner, <String>['validate']);

    expect(output, containsAllInOrder(<Matcher>[contains('Validating android/build.gradle.kts')]));
  });

  group('Artifact Hub check', () {
    test('passes build.gradle.kts artifact hub check when set', () async {
      const packageName = 'a_package';
      final RepositoryPackage package = createFakePackage('a_package', packagesDir);
      final RepositoryPackage example = package.getExamples().first;
      writeFakeExampleBuildGradles(
        example,
        pluginName: packageName,
        // ignore: avoid_redundant_argument_values
        includeBuildArtifactHub: true,
        // ignore: avoid_redundant_argument_values
        includeSettingsArtifactHub: true,
        // ignore: avoid_redundant_argument_values
        includeSettingsDocumentationArtifactHub: true,
      );
      writeFakeManifest(example, isApp: true);

      final List<String> output = await runCapturingPrint(runner, <String>['validate']);

      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('Validating android/build.gradle.kts'),
          contains('Validating android/settings.gradle.kts'),
        ]),
      );
    });

    test('fails artifact hub check when build and settings sections missing', () async {
      const packageName = 'a_package';
      final RepositoryPackage package = createFakePackage('a_package', packagesDir);
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
        runner,
        <String>['validate'],
        errorHandler: (Error e) {
          commandError = e;
        },
      );

      expect(commandError, isA<ToolExit>());
      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains(GradleValidator.exampleRootGradleArtifactHubString),
          contains(GradleValidator.exampleSettingsArtifactHubString),
        ]),
      );
    });

    test('fails build.gradle.kts artifact hub check when missing', () async {
      const packageName = 'a_package';
      final RepositoryPackage package = createFakePackage('a_package', packagesDir);
      final RepositoryPackage example = package.getExamples().first;
      writeFakeExampleBuildGradles(
        example,
        pluginName: packageName,
        includeBuildArtifactHub: false,
        // ignore: avoid_redundant_argument_values
        includeSettingsArtifactHub: true,
      );
      writeFakeManifest(example, isApp: true);

      Error? commandError;
      final List<String> output = await runCapturingPrint(
        runner,
        <String>['validate'],
        errorHandler: (Error e) {
          commandError = e;
        },
      );

      expect(commandError, isA<ToolExit>());
      expect(
        output,
        containsAllInOrder(<Matcher>[contains(GradleValidator.exampleRootGradleArtifactHubString)]),
      );
    });

    test('fails settings.gradle.kts artifact hub check when missing', () async {
      const packageName = 'a_package';
      final RepositoryPackage package = createFakePackage('a_package', packagesDir);
      final RepositoryPackage example = package.getExamples().first;
      writeFakeExampleBuildGradles(
        example,
        pluginName: packageName,
        // ignore: avoid_redundant_argument_values
        includeBuildArtifactHub: true,
        includeSettingsArtifactHub: false,
      );
      writeFakeManifest(example, isApp: true);

      Error? commandError;
      final List<String> output = await runCapturingPrint(
        runner,
        <String>['validate'],
        errorHandler: (Error e) {
          commandError = e;
        },
      );

      expect(commandError, isA<ToolExit>());
      expect(
        output,
        containsAllInOrder(<Matcher>[contains(GradleValidator.exampleSettingsArtifactHubString)]),
      );
      expect(output, isNot(contains(GradleValidator.exampleRootGradleArtifactHubString)));
    });

    test('error message is printed when documentation link is missing', () async {
      const packageName = 'a_package';
      final RepositoryPackage package = createFakePackage('a_package', packagesDir);
      final RepositoryPackage example = package.getExamples().first;
      writeFakeExampleBuildGradles(
        example,
        pluginName: packageName,
        // ignore: avoid_redundant_argument_values
        includeBuildArtifactHub: true,
        // ignore: avoid_redundant_argument_values
        includeSettingsArtifactHub: true,
        includeSettingsDocumentationArtifactHub: false,
      );
      writeFakeManifest(example, isApp: true);

      Error? commandError;
      final List<String> output = await runCapturingPrint(
        runner,
        <String>['validate'],
        errorHandler: (Error e) {
          commandError = e;
        },
      );

      expect(commandError, isA<ToolExit>());
      expect(
        output,
        containsAllInOrder(<Matcher>[contains(GradleValidator.artifactHubDocumentationString)]),
      );
    });
  });

  group('Kotlin version check', () {
    test('passes if not set', () async {
      const packageName = 'a_package';
      final RepositoryPackage package = createFakePackage('a_package', packagesDir);
      final RepositoryPackage example = package.getExamples().first;
      writeFakeExampleBuildGradles(example, pluginName: packageName);
      writeFakeManifest(example, isApp: true);

      final List<String> output = await runCapturingPrint(runner, <String>['validate']);

      expect(
        output,
        containsAllInOrder(<Matcher>[contains('Validating android/build.gradle.kts')]),
      );
    });

    test('passes if at the minimum allowed version', () async {
      const packageName = 'a_package';
      final RepositoryPackage package = createFakePackage('a_package', packagesDir);
      final RepositoryPackage example = package.getExamples().first;
      writeFakeExampleBuildGradles(
        example,
        pluginName: packageName,
        kotlinVersion: minKotlinVersion.toString(),
      );
      writeFakeManifest(example, isApp: true);

      final List<String> output = await runCapturingPrint(runner, <String>['validate']);

      expect(
        output,
        containsAllInOrder(<Matcher>[contains('Validating android/build.gradle.kts')]),
      );
    });

    test('passes if above the minimum allowed version', () async {
      const packageName = 'a_package';
      final RepositoryPackage package = createFakePackage('a_package', packagesDir);
      final RepositoryPackage example = package.getExamples().first;
      writeFakeExampleBuildGradles(example, pluginName: packageName, kotlinVersion: '99.99.0');
      writeFakeManifest(example, isApp: true);

      final List<String> output = await runCapturingPrint(runner, <String>['validate']);

      expect(
        output,
        containsAllInOrder(<Matcher>[contains('Validating android/build.gradle.kts')]),
      );
    });

    test('fails if below the minimum allowed version', () async {
      const packageName = 'a_package';
      final RepositoryPackage package = createFakePackage('a_package', packagesDir);
      final RepositoryPackage example = package.getExamples().first;
      writeFakeExampleBuildGradles(example, pluginName: packageName, kotlinVersion: '1.9.20');
      writeFakeManifest(example, isApp: true);

      Error? commandError;
      final List<String> output = await runCapturingPrint(
        runner,
        <String>['validate'],
        errorHandler: (Error e) {
          commandError = e;
        },
      );

      expect(commandError, isA<ToolExit>());
      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains(
            'settings.gradle.kts sets the "org.jetbrains.kotlin.android" plugin '
            'version to "1.9.20". The minimum Kotlin version that can be '
            'specified is $minKotlinVersion, for compatibility with modern '
            'dependencies.',
          ),
        ]),
      );
    });
  });

  group('compileSdk check', () {
    test('passes if set to a version higher than flutter.compileSdkVersion', () async {
      const packageName = 'a_package';
      final RepositoryPackage package = createFakePackage(
        packageName,
        packagesDir,
        isFlutter: true,
      );
      // Current flutter.compileSdkVersion is 36.
      writeFakePluginBuildGradle(package, includeLanguageVersion: true, compileSdk: '37');
      writeFakeManifest(package);
      final RepositoryPackage example = package.getExamples().first;
      writeFakeExampleBuildGradles(example, pluginName: packageName);
      writeFakeManifest(example, isApp: true);

      final List<String> output = await runCapturingPrint(runner, <String>['validate']);

      expect(
        output,
        containsAllInOrder(<Matcher>[contains('Validating android/build.gradle.kts')]),
      );
    });

    test('passes if set to flutter.compileSdkVersion with Flutter 3.27+', () async {
      const packageName = 'a_package';
      final RepositoryPackage package = createFakePackage(
        packageName,
        packagesDir,
        isFlutter: true,
        flutterConstraint: '>=3.27.0',
      );
      writeFakePluginBuildGradle(
        package,
        includeLanguageVersion: true,
        compileSdk: 'flutter.compileSdkVersion',
      );
      writeFakeManifest(package);
      final RepositoryPackage example = package.getExamples().first;
      writeFakeExampleBuildGradles(example, pluginName: packageName);
      writeFakeManifest(example, isApp: true);

      final List<String> output = await runCapturingPrint(runner, <String>['validate']);

      expect(
        output,
        containsAllInOrder(<Matcher>[contains('Validating android/build.gradle.kts')]),
      );
    });

    test('fails if set to a version lower than flutter.compileSdkVersion', () async {
      const packageName = 'a_package';
      final RepositoryPackage package = createFakePackage(
        packageName,
        packagesDir,
        isFlutter: true,
      );
      // Current flutter.compileSdkVersion is 36.
      const minCompileSdkVersion = '36';
      const testCompileSdkVersion = '35';
      writeFakePluginBuildGradle(
        package,
        includeLanguageVersion: true,
        compileSdk: testCompileSdkVersion,
      );
      writeFakeManifest(package);
      final RepositoryPackage example = package.getExamples().first;
      writeFakeExampleBuildGradles(example, pluginName: packageName);
      writeFakeManifest(example, isApp: true);

      Error? commandError;
      final List<String> output = await runCapturingPrint(
        runner,
        <String>['validate'],
        errorHandler: (Error e) {
          commandError = e;
        },
      );

      expect(commandError, isA<ToolExit>());
      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains(
            'compileSdk version $testCompileSdkVersion is too low. '
            'Minimum required version is $minCompileSdkVersion.',
          ),
        ]),
      );
    });

    test('fails if set to flutter.compileSdkVersion with Flutter <3.27', () async {
      const packageName = 'a_package';
      final RepositoryPackage package = createFakePackage(
        packageName,
        packagesDir,
        isFlutter: true,
        flutterConstraint: '>=3.24.0',
      );
      writeFakePluginBuildGradle(
        package,
        includeLanguageVersion: true,
        compileSdk: 'flutter.compileSdkVersion',
      );
      writeFakeManifest(package);
      final RepositoryPackage example = package.getExamples().first;
      writeFakeExampleBuildGradles(example, pluginName: packageName);
      writeFakeManifest(example, isApp: true);

      Error? commandError;
      final List<String> output = await runCapturingPrint(
        runner,
        <String>['validate'],
        errorHandler: (Error e) {
          commandError = e;
        },
      );

      expect(commandError, isA<ToolExit>());
      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains(
            'Use of flutter.compileSdkVersion requires a minimum '
            'Flutter version of 3.27, but this package currently supports '
            '3.24.0',
          ),
        ]),
      );
    });
  });

  group('kotlin gradle plugin check', () {
    test('passes when kotlin gradle plugin is not applied', () async {
      final RepositoryPackage package = createFakePlugin(
        'a_plugin',
        packagesDir,
        examples: <String>[],
      );
      writeFakePluginBuildGradle(package, includeLanguageVersion: true);
      writeFakeManifest(package);

      final List<String> output = await runCapturingPrint(runner, <String>['validate']);

      expect(
        output,
        containsAllInOrder(<Matcher>[contains('Validating android/build.gradle.kts')]),
      );
    });

    test('fails when kotlin gradle plugin is applied', () async {
      final RepositoryPackage package = createFakePlugin(
        'a_plugin',
        packagesDir,
        examples: <String>[],
      );
      writeFakePluginBuildGradle(
        package,
        includeLanguageVersion: true,
        includeKotlinGradlePlugin: true,
      );
      writeFakeManifest(package);

      Error? commandError;
      final List<String> output = await runCapturingPrint(
        runner,
        <String>['validate'],
        errorHandler: (Error e) {
          commandError = e;
        },
      );

      expect(commandError, isA<ToolExit>());
      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains(
            "The kotlin-android plugin should not be applied in the plugin module's build.gradle.kts",
          ),
        ]),
      );
    });

    test('passes when Kotlin Gradle plugin is not applied in app/build.gradle.kts', () async {
      const pluginName = 'a_plugin';
      final RepositoryPackage package = createFakePackage(pluginName, packagesDir);
      final RepositoryPackage example = package.getExamples().first;
      writeFakeExampleBuildGradles(example, pluginName: pluginName);
      writeFakeManifest(example, isApp: true);

      final List<String> output = await runCapturingPrint(runner, <String>['validate']);

      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('Running for a_plugin/example'),
          contains('Validating android/app/build.gradle.kts'),
        ]),
      );
    });

    test('fails when Kotlin Gradle plugin is applied in app/build.gradle.kts', () async {
      const pluginName = 'a_plugin';
      final RepositoryPackage package = createFakePackage(pluginName, packagesDir);
      final RepositoryPackage example = package.getExamples().first;
      writeFakeExampleBuildGradles(
        example,
        pluginName: pluginName,
        includeKotlinGradlePlugin: true,
      );
      writeFakeManifest(example, isApp: true);

      Error? commandError;
      final List<String> output = await runCapturingPrint(
        runner,
        <String>['validate'],
        errorHandler: (Error e) {
          commandError = e;
        },
      );

      expect(commandError, isA<ToolExit>());
      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains(
            "The kotlin-android plugin should not be applied in the app module's build.gradle.kts",
          ),
        ]),
      );
    });
  });

  group('kotlin compiler options check', () {
    test('passes when kotlin compiler options are specified', () async {
      final RepositoryPackage package = createFakePlugin(
        'a_plugin',
        packagesDir,
        examples: <String>[],
      );
      writeFakePluginBuildGradle(
        package,
        includeLanguageVersion: true,
        // ignore: avoid_redundant_argument_values ensure codepath is tested if defaults change.
        includeKotlinCompilerOptions: true,
      );
      writeFakeManifest(package);

      final List<String> output = await runCapturingPrint(runner, <String>['validate']);

      expect(
        output,
        containsAllInOrder(<Matcher>[contains('Validating android/build.gradle.kts')]),
      );
    });

    test('passes when kotlin compiler options are not specified', () async {
      final RepositoryPackage package = createFakePlugin(
        'a_plugin',
        packagesDir,
        examples: <String>[],
      );
      writeFakePluginBuildGradle(
        package,
        includeLanguageVersion: true,
        includeKotlinCompilerOptions: false,
      );
      writeFakeManifest(package);

      final List<String> output = await runCapturingPrint(runner, <String>['validate']);

      expect(
        output,
        containsAllInOrder(<Matcher>[contains('Validating android/build.gradle.kts')]),
      );
    });

    test('passes when kotlin compiler options is commented out', () async {
      final RepositoryPackage package = createFakePlugin(
        'a_plugin',
        packagesDir,
        examples: <String>[],
      );
      writeFakePluginBuildGradle(
        package,
        includeLanguageVersion: true,
        commentKotlinCompilerOptions: true,
      );
      writeFakeManifest(package);

      final List<String> output = await runCapturingPrint(runner, <String>['validate']);

      expect(
        output,
        containsAllInOrder(<Matcher>[contains('Validating android/build.gradle.kts')]),
      );
    });

    test('fails when kotlin compiler options uses string jvm version', () async {
      final RepositoryPackage package = createFakePlugin(
        'a_plugin',
        packagesDir,
        examples: <String>[],
      );
      writeFakePluginBuildGradle(
        package,
        includeLanguageVersion: true,
        useDeprecatedJvmTargetStyle: true,
      );
      writeFakeManifest(package);

      Error? commandError;
      final List<String> output = await runCapturingPrint(
        runner,
        <String>['validate'],
        errorHandler: (Error e) {
          commandError = e;
        },
      );

      expect(commandError, isA<ToolExit>());
      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains(
            'If build.gradle.kts sets jvmTarget inside kotlin.compilerOptions, it must use JvmTarget syntax.',
          ),
        ]),
      );
    });

    test('fails when kotlin compiler options uses JavaVersion string', () async {
      final RepositoryPackage package = createFakePlugin(
        'a_plugin',
        packagesDir,
        examples: <String>[],
      );
      writeFakePluginBuildGradle(
        package,
        includeLanguageVersion: true,
        useJavaVersionStringForJvmTarget: true,
      );
      writeFakeManifest(package);

      Error? commandError;
      final List<String> output = await runCapturingPrint(
        runner,
        <String>['validate'],
        errorHandler: (Error e) {
          commandError = e;
        },
      );

      expect(commandError, isA<ToolExit>());
      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains(
            'If build.gradle.kts sets jvmTarget inside kotlin.compilerOptions, it must use JvmTarget syntax.',
          ),
        ]),
      );
    });

    test('fails when there is a kotlin compiler options DSL block in the android block', () async {
      final RepositoryPackage package = createFakePlugin(
        'a_plugin',
        packagesDir,
        examples: <String>[],
      );
      writeFakePluginBuildGradle(
        package,
        includeLanguageVersion: true,
        includeKotlinCompilerOptions: false,
      );

      final File buildGradle = package
          .platformDirectory(FlutterPlatform.android)
          .childFile('build.gradle.kts');
      final String contents = buildGradle.readAsStringSync();
      final String updatedContents = contents.replaceFirst(
        'android {',
        'android {\n    kotlin {\n        compilerOptions {\n            jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17\n        }\n    }',
      );
      buildGradle.writeAsStringSync(updatedContents);
      writeFakeManifest(package);

      Error? commandError;
      final List<String> output = await runCapturingPrint(
        runner,
        <String>['validate'],
        errorHandler: (Error e) {
          commandError = e;
        },
      );

      expect(commandError, isA<ToolExit>());
      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains(
            'build.gradle.kts must not nest "kotlin" or "compilerOptions" inside the "android" block. It must be at the top-level',
          ),
        ]),
      );
    });

    test('fails when kotlinOptions is used in the android block', () async {
      final RepositoryPackage package = createFakePlugin(
        'a_plugin',
        packagesDir,
        examples: <String>[],
      );
      writeFakePluginBuildGradle(
        package,
        includeLanguageVersion: true,
        includeDeprecatedKotlinOptionsInsideAndroid: true,
      );
      writeFakeManifest(package);

      Error? commandError;
      final List<String> output = await runCapturingPrint(
        runner,
        <String>['validate'],
        errorHandler: (Error e) {
          commandError = e;
        },
      );

      expect(commandError, isA<ToolExit>());
      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains(
            'build.gradle.kts must not use the deprecated "kotlinOptions" DSL. Use "kotlin.compilerOptions" instead',
          ),
        ]),
      );
    });

    test('fails when kotlinOptions is used in the kotlin block', () async {
      final RepositoryPackage package = createFakePlugin(
        'a_plugin',
        packagesDir,
        examples: <String>[],
      );
      writeFakePluginBuildGradle(
        package,
        includeLanguageVersion: true,
        includeDeprecatedKotlinOptionsInsideKotlin: true,
      );
      writeFakeManifest(package);

      Error? commandError;
      final List<String> output = await runCapturingPrint(
        runner,
        <String>['validate'],
        errorHandler: (Error e) {
          commandError = e;
        },
      );

      expect(commandError, isA<ToolExit>());
      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains(
            'build.gradle.kts must not use the deprecated "kotlinOptions" DSL. Use "kotlin.compilerOptions" instead',
          ),
        ]),
      );
    });

    test('fails when kotlinOptions is used in both the android and kotlin blocks', () async {
      final RepositoryPackage package = createFakePlugin(
        'a_plugin',
        packagesDir,
        examples: <String>[],
      );
      writeFakePluginBuildGradle(
        package,
        includeLanguageVersion: true,
        includeDeprecatedKotlinOptionsInsideAndroid: true,
        includeDeprecatedKotlinOptionsInsideKotlin: true,
      );
      writeFakeManifest(package);

      Error? commandError;
      final List<String> output = await runCapturingPrint(
        runner,
        <String>['validate'],
        errorHandler: (Error e) {
          commandError = e;
        },
      );

      expect(commandError, isA<ToolExit>());
      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains(
            'build.gradle.kts must not use the deprecated "kotlinOptions" DSL. Use "kotlin.compilerOptions" instead',
          ),
        ]),
      );
    });
  });

  group('example app kotlin compiler options check', () {
    test('passes when kotlin compiler options are specified', () async {
      const pluginName = 'a_plugin';
      final RepositoryPackage package = createFakePackage(pluginName, packagesDir);
      final RepositoryPackage example = package.getExamples().first;
      writeFakeExampleBuildGradles(example, pluginName: pluginName);
      writeFakeManifest(example, isApp: true);

      final List<String> output = await runCapturingPrint(runner, <String>['validate']);

      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('Running for a_plugin/example'),
          contains('Validating android/app/build.gradle.kts'),
        ]),
      );
    });

    test('passes when kotlin compiler options are not specified', () async {
      const pluginName = 'a_plugin';
      final RepositoryPackage package = createFakePackage(pluginName, packagesDir);
      final RepositoryPackage example = package.getExamples().first;
      writeFakeExampleBuildGradles(
        example,
        pluginName: pluginName,
        includeKotlinCompilerOptions: false,
      );
      writeFakeManifest(example, isApp: true);

      final List<String> output = await runCapturingPrint(runner, <String>['validate']);

      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('Running for a_plugin/example'),
          contains('Validating android/app/build.gradle.kts'),
        ]),
      );
    });

    test('passes when kotlin compiler options is commented out', () async {
      const pluginName = 'a_plugin';
      final RepositoryPackage package = createFakePackage(pluginName, packagesDir);
      final RepositoryPackage example = package.getExamples().first;
      writeFakeExampleBuildGradles(
        example,
        pluginName: pluginName,
        commentKotlinCompilerOptions: true,
      );
      writeFakeManifest(example, isApp: true);

      final List<String> output = await runCapturingPrint(runner, <String>['validate']);

      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('Running for a_plugin/example'),
          contains('Validating android/app/build.gradle.kts'),
        ]),
      );
    });

    test('fails when kotlin compiler options uses string jvm version', () async {
      const pluginName = 'a_plugin';
      final RepositoryPackage package = createFakePackage(pluginName, packagesDir);
      final RepositoryPackage example = package.getExamples().first;
      writeFakeExampleBuildGradles(
        example,
        pluginName: pluginName,
        useDeprecatedJvmTargetStyle: true,
      );
      writeFakeManifest(example, isApp: true);

      Error? commandError;
      final List<String> output = await runCapturingPrint(
        runner,
        <String>['validate'],
        errorHandler: (Error e) {
          commandError = e;
        },
      );

      expect(commandError, isA<ToolExit>());
      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains(
            'If build.gradle.kts sets jvmTarget inside kotlin.compilerOptions, it must use JvmTarget syntax.',
          ),
        ]),
      );
    });

    test('fails when kotlin compiler options uses JavaVersion string', () async {
      const pluginName = 'a_plugin';
      final RepositoryPackage package = createFakePackage(pluginName, packagesDir);
      final RepositoryPackage example = package.getExamples().first;
      writeFakeExampleBuildGradles(
        example,
        pluginName: pluginName,
        useJavaVersionStringForJvmTarget: true,
      );
      writeFakeManifest(example, isApp: true);

      Error? commandError;
      final List<String> output = await runCapturingPrint(
        runner,
        <String>['validate'],
        errorHandler: (Error e) {
          commandError = e;
        },
      );

      expect(commandError, isA<ToolExit>());
      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains(
            'If build.gradle.kts sets jvmTarget inside kotlin.compilerOptions, it must use JvmTarget syntax.',
          ),
        ]),
      );
    });

    test('fails when there is a kotlin compiler options DSL block in the android block', () async {
      const pluginName = 'a_plugin';
      final RepositoryPackage package = createFakePackage(pluginName, packagesDir);
      final RepositoryPackage example = package.getExamples().first;
      writeFakeExampleBuildGradles(
        example,
        pluginName: pluginName,
        includeKotlinCompilerOptions: false,
      );

      final File buildGradle = example
          .platformDirectory(FlutterPlatform.android)
          .childDirectory('app')
          .childFile('build.gradle.kts');
      final String contents = buildGradle.readAsStringSync();
      final String updatedContents = contents.replaceFirst(
        'android {',
        'android {\n    kotlin {\n        compilerOptions {\n            jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17\n        }\n    }',
      );
      buildGradle.writeAsStringSync(updatedContents);
      writeFakeManifest(example, isApp: true);

      Error? commandError;
      final List<String> output = await runCapturingPrint(
        runner,
        <String>['validate'],
        errorHandler: (Error e) {
          commandError = e;
        },
      );

      expect(commandError, isA<ToolExit>());
      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains(
            'build.gradle.kts must not nest "kotlin" or "compilerOptions" inside the "android" block. It must be at the top-level',
          ),
        ]),
      );
    });

    test('fails when kotlinOptions is used in the android block', () async {
      const pluginName = 'a_plugin';
      final RepositoryPackage package = createFakePackage(pluginName, packagesDir);
      final RepositoryPackage example = package.getExamples().first;
      writeFakeExampleBuildGradles(
        example,
        pluginName: pluginName,
        includeKotlinCompilerOptions: false,
        includeDeprecatedKotlinOptionsInsideAndroid: true,
      );
      writeFakeManifest(example, isApp: true);

      Error? commandError;
      final List<String> output = await runCapturingPrint(
        runner,
        <String>['validate'],
        errorHandler: (Error e) {
          commandError = e;
        },
      );

      expect(commandError, isA<ToolExit>());
      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains(
            'build.gradle.kts must not use the deprecated "kotlinOptions" DSL. Use "kotlin.compilerOptions" instead',
          ),
        ]),
      );
    });

    test('fails when kotlinOptions is used in the kotlin block', () async {
      const pluginName = 'a_plugin';
      final RepositoryPackage package = createFakePackage(pluginName, packagesDir);
      final RepositoryPackage example = package.getExamples().first;
      writeFakeExampleBuildGradles(
        example,
        pluginName: pluginName,
        includeKotlinCompilerOptions: false,
        includeDeprecatedKotlinOptionsInsideKotlin: true,
      );
      writeFakeManifest(example, isApp: true);

      Error? commandError;
      final List<String> output = await runCapturingPrint(
        runner,
        <String>['validate'],
        errorHandler: (Error e) {
          commandError = e;
        },
      );

      expect(commandError, isA<ToolExit>());
      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains(
            'build.gradle.kts must not use the deprecated "kotlinOptions" DSL. Use "kotlin.compilerOptions" instead',
          ),
        ]),
      );
    });

    test('fails when kotlinOptions is used in both the android and kotlin blocks', () async {
      const pluginName = 'a_plugin';
      final RepositoryPackage package = createFakePackage(pluginName, packagesDir);
      final RepositoryPackage example = package.getExamples().first;
      writeFakeExampleBuildGradles(
        example,
        pluginName: pluginName,
        includeKotlinCompilerOptions: false,
        includeDeprecatedKotlinOptionsInsideAndroid: true,
        includeDeprecatedKotlinOptionsInsideKotlin: true,
      );
      writeFakeManifest(example, isApp: true);

      Error? commandError;
      final List<String> output = await runCapturingPrint(
        runner,
        <String>['validate'],
        errorHandler: (Error e) {
          commandError = e;
        },
      );

      expect(commandError, isA<ToolExit>());
      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains(
            'build.gradle.kts must not use the deprecated "kotlinOptions" DSL. Use "kotlin.compilerOptions" instead',
          ),
        ]),
      );
    });
  });
}

class _KotlinConfigParts {
  const _KotlinConfigParts({
    required this.kotlinConfig,
    required this.kotlinDeprecatedInAndroidConfig,
    required this.kotlinDeprecatedInKotlinConfig,
  });

  final String kotlinConfig;
  final String kotlinDeprecatedInAndroidConfig;
  final String kotlinDeprecatedInKotlinConfig;
}

_KotlinConfigParts _generateKotlinConfigParts({
  required bool commentKotlinCompilerOptions,
  required bool useJavaVersionStringForJvmTarget,
  required bool useDeprecatedJvmTargetStyle,
  required int jvmTargetValue,
  required int kotlinJvmValue,
}) {
  final String kotlinJvmTarget;
  if (useJavaVersionStringForJvmTarget) {
    kotlinJvmTarget = 'JavaVersion.VERSION_$kotlinJvmValue.toString()';
  } else if (useDeprecatedJvmTargetStyle) {
    kotlinJvmTarget = '"$jvmTargetValue"';
  } else {
    kotlinJvmTarget = 'org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_$kotlinJvmValue';
  }

  final kotlinConfig =
      '''
${commentKotlinCompilerOptions ? '// ' : ''}kotlin {
${commentKotlinCompilerOptions ? '// ' : ''}    compilerOptions {
${commentKotlinCompilerOptions ? '// ' : ''}        jvmTarget = $kotlinJvmTarget
${commentKotlinCompilerOptions ? '// ' : ''}    }
${commentKotlinCompilerOptions ? '// ' : ''}}''';

  final kotlinDeprecatedInAndroidConfig =
      '''
    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_$kotlinJvmValue.toString()
    }''';

  final kotlinDeprecatedInKotlinConfig =
      '''
    kotlin {
        $kotlinDeprecatedInAndroidConfig
    }''';

  return _KotlinConfigParts(
    kotlinConfig: kotlinConfig,
    kotlinDeprecatedInAndroidConfig: kotlinDeprecatedInAndroidConfig,
    kotlinDeprecatedInKotlinConfig: kotlinDeprecatedInKotlinConfig,
  );
}
