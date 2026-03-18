// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:args/command_runner.dart';
import 'package:file/file.dart';
import 'package:flutter_plugin_tools/src/common/core.dart';
import 'package:flutter_plugin_tools/src/common/plugin_utils.dart';
import 'package:flutter_plugin_tools/src/gradle_check_command.dart';
import 'package:git/git.dart';
import 'package:test/test.dart';

import 'util.dart';

const String _defaultFakeNamespace = 'dev.flutter.foo';

void main() {
  late CommandRunner<void> runner;
  late Directory packagesDir;
  const groovyJavaIncompatabilityIndicator =
      'build.gradle must set an explicit Java compatibility version.';

  setUp(() {
    final GitDir gitDir;
    (:packagesDir, processRunner: _, gitProcessRunner: _, :gitDir) =
        configureBaseCommandMocks();
    final command = GradleCheckCommand(packagesDir, gitDir: gitDir);

    runner = CommandRunner<void>(
      'gradle_check_command',
      'Test for gradle_check_command',
    );
    runner.addCommand(command);
  });

  /// Writes a fake android/build.gradle file for plugin [package] with the
  /// given options.
  void writeFakeGroovyPluginBuildGradle(
    RepositoryPackage package, {
    bool includeLanguageVersion = false,
    bool includeSourceCompat = false,
    bool includeTargetCompat = false,
    bool commentSourceLanguage = false,
    bool includeNamespace = true,
    bool commentNamespace = false,
    bool warningsConfigured = true,
    bool useDeprecatedCompileSdkVersion = false,
    bool usePropertyAssignment = true,
    String compileSdk = '36',
    bool includeKotlinOptions = true,
    bool commentKotlinOptions = false,
    bool useDeprecatedJvmTargetStyle = false,
    int jvmTargetValue = 17,
    int kotlinJvmValue = 17,
  }) {
    final File buildGradle = package
        .platformDirectory(FlutterPlatform.android)
        .childFile('build.gradle');
    buildGradle.createSync(recursive: true);

    const warningConfig = '''
    lintOptions {
        checkAllWarnings = true
        warningsAsErrors = true
        disable 'AndroidGradlePluginVersion', 'InvalidPackage', 'GradleDependency', 'NewerVersionAvailable'
        baseline file("lint-baseline.xml")
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
    final namespace =
        "    ${commentNamespace ? '// ' : ''}namespace = '$_defaultFakeNamespace'";
    final kotlinJvmTarget = useDeprecatedJvmTargetStyle
        ? '$jvmTargetValue'
        : 'JavaVersion.VERSION_$kotlinJvmValue.toString()';
    final kotlinConfig =
        '''
    ${commentKotlinOptions ? '//' : ''}kotlinOptions {
        ${commentKotlinOptions ? '//' : ''}jvmTarget = $kotlinJvmTarget
    ${commentKotlinOptions ? '//' : ''}}''';

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
    ${useDeprecatedCompileSdkVersion ? 'compileSdkVersion' : 'compileSdk'} ${usePropertyAssignment ? '=' : ''} $compileSdk

    defaultConfig {
        minSdk ${usePropertyAssignment ? '=' : ''} 30
    }
${warningsConfigured ? warningConfig : ''}
    compileOptions {
        ${includeSourceCompat ? sourceCompat : ''}
        ${includeTargetCompat ? targetCompat : ''}
    }
    ${includeKotlinOptions ? kotlinConfig : ''}
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
  // TODO(stuartmorgan): Once all packages are migrated to Kotlin, remove all
  // the Groovy variants, and switch all tests to the Kotlin variants.
  void writeFakeGroovyExampleTopLevelBuildGradle(
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

    final warningConfig =
        '''
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
        ${includeArtifactHub ? GradleCheckCommand.exampleGroovyRootGradleArtifactHubString : ''}
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

  /// Writes a fake android/build.gradle.kts file for an example [package] with
  /// the given options.
  void writeFakeKotlinExampleTopLevelBuildGradle(
    RepositoryPackage package, {
    required String pluginName,
    bool warningsConfigured = true,
    bool includeArtifactHub = true,
  }) {
    final File buildGradle = package
        .platformDirectory(FlutterPlatform.android)
        .childFile('build.gradle.kts');
    buildGradle.createSync(recursive: true);

    // TODO(stuartmorgan): Add support for warningsConfigured when we start
    // migrating plugins to Kotlin Gradle. See Groovy variant above. For now,
    // throw if any test requires warnings.
    if (warningsConfigured) {
      throw UnimplementedError(
        'warningsConfigured is not yet supported for Kotlin Gradle',
      );
    }

    buildGradle.writeAsStringSync('''
allprojects {
    repositories {
        ${includeArtifactHub ? GradleCheckCommand.exampleKotlinRootGradleArtifactHubString : ''}
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
''');
  }

  /// Writes a fake android/build.gradle file for an example [package] with the
  /// given options.
  void writeFakeGroovyExampleSettingsGradle(
    RepositoryPackage package, {
    bool includeArtifactHub = true,
    bool includeArtifactDocumentation = true,
  }) {
    final File settingsGradle = package
        .platformDirectory(FlutterPlatform.android)
        .childFile('settings.gradle');
    settingsGradle.createSync(recursive: true);

    /// String printed as a valid example of settings.gradle repository
    /// configuration without the artifact hub env variable.
    const exampleSettingsWithoutArtifactHubString = '''
plugins {
    id "dev.flutter.flutter-plugin-loader" version "1.0.0"
    // ...other plugins
}
  ''';

    settingsGradle.writeAsStringSync('''
pluginManagement {
  def flutterSdkPath = {
    def properties = new Properties()
    file("local.properties").withInputStream { properties.load(it) }
    def flutterSdkPath = properties.getProperty("flutter.sdk")
    assert flutterSdkPath != null, "flutter.sdk not set in local.properties"
    return flutterSdkPath
  }()

  includeBuild("\$flutterSdkPath/packages/flutter_tools/gradle")

  repositories {
    google()
    mavenCentral()
    gradlePluginPortal()
  }
}

${includeArtifactDocumentation ? '// See ${GradleCheckCommand.artifactHubDocumentationString} for more info.' : ''}
${includeArtifactHub ? GradleCheckCommand.exampleGroovySettingsArtifactHubString : exampleSettingsWithoutArtifactHubString}
include ":app"
''');
  }

  /// Writes a fake android/build.gradle file for an example [package] with the
  /// given options.
  void writeFakeKotlinExampleSettingsGradle(
    RepositoryPackage package, {
    bool includeArtifactHub = true,
    bool includeArtifactDocumentation = true,
  }) {
    final File settingsGradle = package
        .platformDirectory(FlutterPlatform.android)
        .childFile('settings.gradle.kts');
    settingsGradle.createSync(recursive: true);

    /// String printed as a valid example of settings.gradle repository
    /// configuration without the artifact hub env variable.
    const exampleSettingsWithoutArtifactHubString = '''
plugins {
    id "dev.flutter.flutter-plugin-loader" version "1.0.0"
    // ...other plugins
}
  ''';

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

${includeArtifactDocumentation ? '// See ${GradleCheckCommand.artifactHubDocumentationString} for more info.' : ''}
${includeArtifactHub ? GradleCheckCommand.exampleKotlinSettingsArtifactHubString : exampleSettingsWithoutArtifactHubString}
include ":app"
''');
  }

  /// Writes a fake android/app/build.gradle file for an example [package] with
  /// the given options.
  void writeFakeGroovyExampleAppBuildGradle(
    RepositoryPackage package, {
    required bool includeNamespace,
    required bool commentNamespace,
    required bool includeNameSpaceAsDeclaration,
    required bool usePropertyAssignment,
  }) {
    final File buildGradle = package
        .platformDirectory(FlutterPlatform.android)
        .childDirectory('app')
        .childFile('build.gradle');
    buildGradle.createSync(recursive: true);

    final namespace =
        "${commentNamespace ? '// ' : ''}namespace ${includeNameSpaceAsDeclaration ? '= ' : ''}'$_defaultFakeNamespace'";
    buildGradle.writeAsStringSync('''
def flutterRoot = localProperties.getProperty('flutter.sdk')
if (flutterRoot == null) {
    throw new GradleException("Flutter SDK not found. Define location with flutter.sdk in the local.properties file.")
}

apply plugin: 'com.android.application'
apply from: "\$flutterRoot/packages/flutter_tools/gradle/flutter.gradle"

android {
    ${includeNamespace ? namespace : ''}
    compileSdk ${usePropertyAssignment ? '=' : ''} flutter.compileSdkVersion

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
    testImplementation("fake.package:fake:1.0.0")
}
''');
  }

  /// Writes a fake android/app/build.gradle file for an example [package] with
  /// the given options.
  void writeFakeKotlinExampleAppBuildGradle(
    RepositoryPackage package, {
    required bool includeNamespace,
    required bool commentNamespace,
  }) {
    final File buildGradle = package
        .platformDirectory(FlutterPlatform.android)
        .childDirectory('app')
        .childFile('build.gradle.kts');
    buildGradle.createSync(recursive: true);

    final namespace =
        '${commentNamespace ? '// ' : ''}namespace = "$_defaultFakeNamespace"';
    buildGradle.writeAsStringSync('''
plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    ${includeNamespace ? namespace : ''}
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
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
}

flutter {
    source = "../.."
}
''');
  }

  void writeFakeGroovyExampleBuildGradles(
    RepositoryPackage package, {
    required String pluginName,
    bool includeNamespace = true,
    bool commentNamespace = false,
    bool includeNameSpaceAsDeclaration = true,
    bool warningsConfigured = true,
    String? kotlinVersion,
    bool includeBuildArtifactHub = true,
    bool includeSettingsArtifactHub = true,
    bool includeSettingsDocumentationArtifactHub = true,
    bool usePropertyAssignment = true,
  }) {
    writeFakeGroovyExampleTopLevelBuildGradle(
      package,
      pluginName: pluginName,
      warningsConfigured: warningsConfigured,
      kotlinVersion: kotlinVersion,
      includeArtifactHub: includeBuildArtifactHub,
    );
    writeFakeGroovyExampleAppBuildGradle(
      package,
      includeNamespace: includeNamespace,
      commentNamespace: commentNamespace,
      includeNameSpaceAsDeclaration: includeNameSpaceAsDeclaration,
      usePropertyAssignment: usePropertyAssignment,
    );
    writeFakeGroovyExampleSettingsGradle(
      package,
      includeArtifactHub: includeSettingsArtifactHub,
      includeArtifactDocumentation: includeSettingsDocumentationArtifactHub,
    );
  }

  void writeFakeKotlinExampleBuildGradles(
    RepositoryPackage package, {
    required String pluginName,
    bool includeNamespace = true,
    bool commentNamespace = false,
    // TODO(stuartmorgan): Default to true once the test helper supports it.
    bool warningsConfigured = false,
    bool includeBuildArtifactHub = true,
    bool includeSettingsArtifactHub = true,
    bool includeSettingsDocumentationArtifactHub = true,
  }) {
    writeFakeKotlinExampleTopLevelBuildGradle(
      package,
      pluginName: pluginName,
      warningsConfigured: warningsConfigured,
      includeArtifactHub: includeBuildArtifactHub,
    );
    writeFakeKotlinExampleAppBuildGradle(
      package,
      includeNamespace: includeNamespace,
      commentNamespace: commentNamespace,
    );
    writeFakeKotlinExampleSettingsGradle(
      package,
      includeArtifactHub: includeSettingsArtifactHub,
      includeArtifactDocumentation: includeSettingsDocumentationArtifactHub,
    );
  }

  void writeFakeManifest(
    RepositoryPackage package, {
    bool isApp = false,
    String packageName = _defaultFakeNamespace,
  }) {
    final Directory androidDir = package.platformDirectory(
      FlutterPlatform.android,
    );
    final Directory startDir = isApp
        ? androidDir.childDirectory('app')
        : androidDir;
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

    final List<String> output = await runCapturingPrint(runner, <String>[
      'gradle-check',
    ]);

    expect(
      output,
      containsAllInOrder(<Matcher>[contains('Skipped 1 package(s)')]),
    );
  });

  test('fails when build.gradle has no java compatibility version', () async {
    final RepositoryPackage package = createFakePlugin(
      'a_plugin',
      packagesDir,
      examples: <String>[],
    );
    writeFakeGroovyPluginBuildGradle(package);
    writeFakeManifest(package);

    Error? commandError;
    final List<String> output = await runCapturingPrint(
      runner,
      <String>['gradle-check'],
      errorHandler: (Error e) {
        commandError = e;
      },
    );

    expect(commandError, isA<ToolExit>());
    expect(
      output,
      containsAllInOrder(<Matcher>[
        contains(groovyJavaIncompatabilityIndicator),
      ]),
    );
  });

  test(
    'fails when sourceCompatibility is provided with out targetCompatibility',
    () async {
      final RepositoryPackage package = createFakePlugin(
        'a_plugin',
        packagesDir,
        examples: <String>[],
      );
      writeFakeGroovyPluginBuildGradle(package, includeSourceCompat: true);
      writeFakeManifest(package);

      Error? commandError;
      final List<String> output = await runCapturingPrint(
        runner,
        <String>['gradle-check'],
        errorHandler: (Error e) {
          commandError = e;
        },
      );

      expect(commandError, isA<ToolExit>());
      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains(groovyJavaIncompatabilityIndicator),
        ]),
      );
    },
  );

  test(
    'fails when sourceCompatibility/targetCompatibility are below minimum',
    () async {
      final RepositoryPackage package = createFakePlugin(
        'a_plugin',
        packagesDir,
        examples: <String>[],
      );
      writeFakeGroovyPluginBuildGradle(
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
        <String>['gradle-check'],
        errorHandler: (Error e) {
          commandError = e;
        },
      );

      expect(commandError, isA<ToolExit>());
      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains(
            'Which is below the minimum required. Use at least "JavaVersion.VERSION_',
          ),
        ]),
      );
    },
  );

  test('fails when compatibility values do not match kotlinOptions', () async {
    final RepositoryPackage package = createFakePlugin(
      'a_plugin',
      packagesDir,
      examples: <String>[],
    );
    writeFakeGroovyPluginBuildGradle(
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
      <String>['gradle-check'],
      errorHandler: (Error e) {
        commandError = e;
      },
    );

    expect(commandError, isA<ToolExit>());
    expect(
      output,
      containsAllInOrder(<Matcher>[
        contains(
          'If build.gradle uses JavaVersion.* versions must be the same.',
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
    writeFakeGroovyPluginBuildGradle(
      package,
      includeSourceCompat: true,
      includeTargetCompat: true,
      jvmTargetValue: 21,
      kotlinJvmValue: 21,
    );
    writeFakeManifest(package);

    final List<String> output = await runCapturingPrint(runner, <String>[
      'gradle-check',
    ]);

    expect(
      output,
      containsAllInOrder(<Matcher>[
        contains('Validating android/build.gradle'),
      ]),
    );
  });

  test(
    'passes when sourceCompatibility and targetCompatibility are specified',
    () async {
      final RepositoryPackage package = createFakePlugin(
        'a_plugin',
        packagesDir,
        examples: <String>[],
      );
      writeFakeGroovyPluginBuildGradle(
        package,
        includeSourceCompat: true,
        includeTargetCompat: true,
      );
      writeFakeManifest(package);

      final List<String> output = await runCapturingPrint(runner, <String>[
        'gradle-check',
      ]);

      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('Validating android/build.gradle'),
        ]),
      );
    },
  );

  test('passes when toolchain languageVersion is specified', () async {
    final RepositoryPackage package = createFakePlugin(
      'a_plugin',
      packagesDir,
      examples: <String>[],
    );
    writeFakeGroovyPluginBuildGradle(package, includeLanguageVersion: true);
    writeFakeManifest(package);

    final List<String> output = await runCapturingPrint(runner, <String>[
      'gradle-check',
    ]);

    expect(
      output,
      containsAllInOrder(<Matcher>[
        contains('Validating android/build.gradle'),
      ]),
    );
  });

  test('does not require java version in examples - groovy', () async {
    const pluginName = 'a_plugin';
    final RepositoryPackage package = createFakePlugin(pluginName, packagesDir);
    writeFakeGroovyPluginBuildGradle(package, includeLanguageVersion: true);
    writeFakeManifest(package);
    final RepositoryPackage example = package.getExamples().first;
    writeFakeGroovyExampleBuildGradles(example, pluginName: pluginName);
    writeFakeManifest(example, isApp: true);

    final List<String> output = await runCapturingPrint(runner, <String>[
      'gradle-check',
    ]);

    expect(
      output,
      containsAllInOrder(<Matcher>[
        contains('Validating android/build.gradle'),
        contains('Ran for 2 package(s)'),
      ]),
    );
  });

  test('does not require java version in examples - kotlin', () async {
    const pluginName = 'a_plugin';
    final RepositoryPackage package = createFakePlugin(pluginName, packagesDir);
    writeFakeGroovyPluginBuildGradle(package, includeLanguageVersion: true);
    writeFakeManifest(package);
    final RepositoryPackage example = package.getExamples().first;
    writeFakeKotlinExampleBuildGradles(example, pluginName: pluginName);
    writeFakeManifest(example, isApp: true);

    final List<String> output = await runCapturingPrint(runner, <String>[
      'gradle-check',
    ]);

    expect(
      output,
      containsAllInOrder(<Matcher>[
        contains('Validating android/build.gradle.kts'),
        contains('Ran for 2 package(s)'),
      ]),
    );
  });

  test('fails when java compatibility version is commented out', () async {
    final RepositoryPackage package = createFakePlugin(
      'a_plugin',
      packagesDir,
      examples: <String>[],
    );
    writeFakeGroovyPluginBuildGradle(
      package,
      includeSourceCompat: true,
      includeTargetCompat: true,
      commentSourceLanguage: true,
    );
    writeFakeManifest(package);

    Error? commandError;
    final List<String> output = await runCapturingPrint(
      runner,
      <String>['gradle-check'],
      errorHandler: (Error e) {
        commandError = e;
      },
    );

    expect(commandError, isA<ToolExit>());
    expect(
      output,
      containsAllInOrder(<Matcher>[
        contains(groovyJavaIncompatabilityIndicator),
      ]),
    );
  });

  test('fails when languageVersion is commented out', () async {
    final RepositoryPackage package = createFakePlugin(
      'a_plugin',
      packagesDir,
      examples: <String>[],
    );
    writeFakeGroovyPluginBuildGradle(
      package,
      includeLanguageVersion: true,
      commentSourceLanguage: true,
    );
    writeFakeManifest(package);

    Error? commandError;
    final List<String> output = await runCapturingPrint(
      runner,
      <String>['gradle-check'],
      errorHandler: (Error e) {
        commandError = e;
      },
    );

    expect(commandError, isA<ToolExit>());
    expect(
      output,
      containsAllInOrder(<Matcher>[
        contains(groovyJavaIncompatabilityIndicator),
      ]),
    );
  });

  test(
    'fails when plugin namespace does not match AndroidManifest.xml',
    () async {
      final RepositoryPackage package = createFakePlugin(
        'a_plugin',
        packagesDir,
        examples: <String>[],
      );
      writeFakeGroovyPluginBuildGradle(package, includeLanguageVersion: true);
      writeFakeManifest(package, packageName: 'wrong.package.name');

      Error? commandError;
      final List<String> output = await runCapturingPrint(
        runner,
        <String>['gradle-check'],
        errorHandler: (Error e) {
          commandError = e;
        },
      );

      expect(commandError, isA<ToolExit>());
      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains(
            'build.gradle "namespace" must match the "package" attribute in AndroidManifest.xml',
          ),
        ]),
      );
    },
  );

  test('fails when namespace is missing', () async {
    final RepositoryPackage package = createFakePlugin(
      'a_plugin',
      packagesDir,
      examples: <String>[],
    );
    writeFakeGroovyPluginBuildGradle(
      package,
      includeLanguageVersion: true,
      includeNamespace: false,
    );
    writeFakeManifest(package);

    Error? commandError;
    final List<String> output = await runCapturingPrint(
      runner,
      <String>['gradle-check'],
      errorHandler: (Error e) {
        commandError = e;
      },
    );

    expect(commandError, isA<ToolExit>());
    expect(
      output,
      containsAllInOrder(<Matcher>[
        contains('build.gradle must set a "namespace"'),
      ]),
    );
  });

  test('fails when namespace is missing from example - groovy', () async {
    const pluginName = 'a_plugin';
    final RepositoryPackage package = createFakePlugin(pluginName, packagesDir);
    writeFakeGroovyPluginBuildGradle(package, includeLanguageVersion: true);
    writeFakeManifest(package);
    final RepositoryPackage example = package.getExamples().first;
    writeFakeGroovyExampleBuildGradles(
      example,
      pluginName: pluginName,
      includeNamespace: false,
    );
    writeFakeManifest(example, isApp: true);

    Error? commandError;
    final List<String> output = await runCapturingPrint(
      runner,
      <String>['gradle-check'],
      errorHandler: (Error e) {
        commandError = e;
      },
    );

    expect(commandError, isA<ToolExit>());
    expect(
      output,
      containsAllInOrder(<Matcher>[
        contains('build.gradle must set a "namespace"'),
      ]),
    );
  });

  test('fails when namespace is missing from example - kotlin', () async {
    const pluginName = 'a_plugin';
    final RepositoryPackage package = createFakePlugin(pluginName, packagesDir);
    writeFakeGroovyPluginBuildGradle(package, includeLanguageVersion: true);
    writeFakeManifest(package);
    final RepositoryPackage example = package.getExamples().first;
    writeFakeKotlinExampleBuildGradles(
      example,
      pluginName: pluginName,
      includeNamespace: false,
    );
    writeFakeManifest(example, isApp: true);

    Error? commandError;
    final List<String> output = await runCapturingPrint(
      runner,
      <String>['gradle-check'],
      errorHandler: (Error e) {
        commandError = e;
      },
    );

    expect(commandError, isA<ToolExit>());
    expect(
      output,
      containsAllInOrder(<Matcher>[
        contains('build.gradle.kts must set a "namespace"'),
      ]),
    );
  });

  // TODO(stuartmorgan): Consider removing this in the future; we may at some
  // point decide that we have a use case of example apps having different
  // app IDs and namespaces. For now, it's enforced for consistency so they
  // don't just accidentally diverge.
  test(
    'fails when namespace in example does not match AndroidManifest.xml',
    () async {
      const pluginName = 'a_plugin';
      final RepositoryPackage package = createFakePlugin(
        pluginName,
        packagesDir,
      );
      writeFakeGroovyPluginBuildGradle(package, includeLanguageVersion: true);
      writeFakeManifest(package);
      final RepositoryPackage example = package.getExamples().first;
      writeFakeGroovyExampleBuildGradles(example, pluginName: pluginName);
      writeFakeManifest(
        example,
        isApp: true,
        packageName: 'wrong.package.name',
      );

      Error? commandError;
      final List<String> output = await runCapturingPrint(
        runner,
        <String>['gradle-check'],
        errorHandler: (Error e) {
          commandError = e;
        },
      );

      expect(commandError, isA<ToolExit>());
      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains(
            'build.gradle "namespace" must match the "package" attribute in AndroidManifest.xml',
          ),
        ]),
      );
    },
  );

  test('fails when namespace is commented out', () async {
    final RepositoryPackage package = createFakePlugin(
      'a_plugin',
      packagesDir,
      examples: <String>[],
    );
    writeFakeGroovyPluginBuildGradle(
      package,
      includeLanguageVersion: true,
      commentNamespace: true,
    );
    writeFakeManifest(package);

    Error? commandError;
    final List<String> output = await runCapturingPrint(
      runner,
      <String>['gradle-check'],
      errorHandler: (Error e) {
        commandError = e;
      },
    );

    expect(commandError, isA<ToolExit>());
    expect(
      output,
      containsAllInOrder(<Matcher>[
        contains('build.gradle must set a "namespace"'),
      ]),
    );
  });

  test('fails when namespace is declared without "=" declaration', () async {
    const pluginName = 'a_plugin';
    final RepositoryPackage package = createFakePlugin(pluginName, packagesDir);
    writeFakeGroovyPluginBuildGradle(package, includeLanguageVersion: true);
    writeFakeManifest(package);
    final RepositoryPackage example = package.getExamples().first;
    writeFakeGroovyExampleBuildGradles(
      example,
      pluginName: pluginName,
      includeNameSpaceAsDeclaration: false,
    );
    writeFakeManifest(example, isApp: true);

    Error? commandError;
    final List<String> output = await runCapturingPrint(
      runner,
      <String>['gradle-check'],
      errorHandler: (Error e) {
        commandError = e;
      },
    );

    expect(commandError, isA<ToolExit>());
    expect(
      output,
      containsAllInOrder(<Matcher>[
        contains('build.gradle must set a "namespace"'),
        contains('The following packages had errors:'),
      ]),
    );
  });

  test('fails if gradle-driven lint-warnings-as-errors is missing', () async {
    const pluginName = 'a_plugin';
    final RepositoryPackage plugin = createFakePlugin(
      pluginName,
      packagesDir,
      examples: <String>[],
    );
    writeFakeGroovyPluginBuildGradle(
      plugin,
      includeLanguageVersion: true,
      warningsConfigured: false,
    );
    writeFakeManifest(plugin);

    Error? commandError;
    final List<String> output = await runCapturingPrint(
      runner,
      <String>['gradle-check'],
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

  test(
    'fails if plugin example javac lint-warnings-as-errors is missing',
    () async {
      const pluginName = 'a_plugin';
      final RepositoryPackage plugin = createFakePlugin(
        pluginName,
        packagesDir,
        platformSupport: <String, PlatformDetails>{
          platformAndroid: const PlatformDetails(PlatformSupport.inline),
        },
      );
      writeFakeGroovyPluginBuildGradle(plugin, includeLanguageVersion: true);
      writeFakeManifest(plugin);
      final RepositoryPackage example = plugin.getExamples().first;
      writeFakeGroovyExampleBuildGradles(
        example,
        pluginName: pluginName,
        warningsConfigured: false,
      );
      writeFakeManifest(example, isApp: true);

      Error? commandError;
      final List<String> output = await runCapturingPrint(
        runner,
        <String>['gradle-check'],
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
    },
  );

  test(
    'passes if non-plugin package example javac lint-warnings-as-errors is missing - groovy',
    () async {
      const packageName = 'a_package';
      final RepositoryPackage plugin = createFakePackage(
        packageName,
        packagesDir,
      );
      final RepositoryPackage example = plugin.getExamples().first;
      writeFakeGroovyExampleBuildGradles(
        example,
        pluginName: packageName,
        warningsConfigured: false,
      );
      writeFakeManifest(example, isApp: true);

      final List<String> output = await runCapturingPrint(runner, <String>[
        'gradle-check',
      ]);

      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('Validating android/build.gradle'),
        ]),
      );
    },
  );

  test(
    'passes if non-plugin package example javac lint-warnings-as-errors is missing - kotlin',
    () async {
      const packageName = 'a_package';
      final RepositoryPackage plugin = createFakePackage(
        packageName,
        packagesDir,
      );
      final RepositoryPackage example = plugin.getExamples().first;
      writeFakeKotlinExampleBuildGradles(
        example,
        pluginName: packageName,
        // TODO(stuartmorgan): Remove the ignore once the default flips. See
        // the comment in writeFakeKotlinExampleBuildGradles.
        // ignore: avoid_redundant_argument_values
        warningsConfigured: false,
      );
      writeFakeManifest(example, isApp: true);

      final List<String> output = await runCapturingPrint(runner, <String>[
        'gradle-check',
      ]);

      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('Validating android/build.gradle.kts'),
        ]),
      );
    },
  );

  group('Artifact Hub check', () {
    test('passes build.gradle artifact hub check when set - groovy', () async {
      const packageName = 'a_package';
      final RepositoryPackage package = createFakePackage(
        'a_package',
        packagesDir,
      );
      final RepositoryPackage example = package.getExamples().first;
      writeFakeGroovyExampleBuildGradles(
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

      final List<String> output = await runCapturingPrint(runner, <String>[
        'gradle-check',
      ]);

      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('Validating android/build.gradle'),
          contains('Validating android/settings.gradle'),
        ]),
      );
    });

    test('passes build.gradle artifact hub check when set - kotlin', () async {
      const packageName = 'a_package';
      final RepositoryPackage package = createFakePackage(
        'a_package',
        packagesDir,
      );
      final RepositoryPackage example = package.getExamples().first;
      writeFakeKotlinExampleBuildGradles(
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

      final List<String> output = await runCapturingPrint(runner, <String>[
        'gradle-check',
      ]);

      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('Validating android/build.gradle.kts'),
          contains('Validating android/settings.gradle.kts'),
        ]),
      );
    });

    test(
      'fails artifact hub check when build and settings sections missing - groovy',
      () async {
        const packageName = 'a_package';
        final RepositoryPackage package = createFakePackage(
          'a_package',
          packagesDir,
        );
        final RepositoryPackage example = package.getExamples().first;
        writeFakeGroovyExampleBuildGradles(
          example,
          pluginName: packageName,
          includeBuildArtifactHub: false,
          includeSettingsArtifactHub: false,
        );
        writeFakeManifest(example, isApp: true);

        Error? commandError;
        final List<String> output = await runCapturingPrint(
          runner,
          <String>['gradle-check'],
          errorHandler: (Error e) {
            commandError = e;
          },
        );

        expect(commandError, isA<ToolExit>());
        expect(
          output,
          containsAllInOrder(<Matcher>[
            contains(
              GradleCheckCommand.exampleGroovyRootGradleArtifactHubString,
            ),
            contains(GradleCheckCommand.exampleGroovySettingsArtifactHubString),
          ]),
        );
      },
    );

    test(
      'fails artifact hub check when build and settings sections missing - kotlin',
      () async {
        const packageName = 'a_package';
        final RepositoryPackage package = createFakePackage(
          'a_package',
          packagesDir,
        );
        final RepositoryPackage example = package.getExamples().first;
        writeFakeKotlinExampleBuildGradles(
          example,
          pluginName: packageName,
          includeBuildArtifactHub: false,
          includeSettingsArtifactHub: false,
        );
        writeFakeManifest(example, isApp: true);

        Error? commandError;
        final List<String> output = await runCapturingPrint(
          runner,
          <String>['gradle-check'],
          errorHandler: (Error e) {
            commandError = e;
          },
        );

        expect(commandError, isA<ToolExit>());
        expect(
          output,
          containsAllInOrder(<Matcher>[
            contains(
              GradleCheckCommand.exampleKotlinRootGradleArtifactHubString,
            ),
            contains(GradleCheckCommand.exampleKotlinSettingsArtifactHubString),
          ]),
        );
      },
    );

    test('fails build.gradle artifact hub check when missing', () async {
      const packageName = 'a_package';
      final RepositoryPackage package = createFakePackage(
        'a_package',
        packagesDir,
      );
      final RepositoryPackage example = package.getExamples().first;
      writeFakeGroovyExampleBuildGradles(
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
        <String>['gradle-check'],
        errorHandler: (Error e) {
          commandError = e;
        },
      );

      expect(commandError, isA<ToolExit>());
      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains(GradleCheckCommand.exampleGroovyRootGradleArtifactHubString),
        ]),
      );
    });

    test('fails build.gradle.kts artifact hub check when missing', () async {
      const packageName = 'a_package';
      final RepositoryPackage package = createFakePackage(
        'a_package',
        packagesDir,
      );
      final RepositoryPackage example = package.getExamples().first;
      writeFakeKotlinExampleBuildGradles(
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
        <String>['gradle-check'],
        errorHandler: (Error e) {
          commandError = e;
        },
      );

      expect(commandError, isA<ToolExit>());
      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains(GradleCheckCommand.exampleKotlinRootGradleArtifactHubString),
        ]),
      );
    });

    test('fails settings.gradle artifact hub check when missing', () async {
      const packageName = 'a_package';
      final RepositoryPackage package = createFakePackage(
        'a_package',
        packagesDir,
      );
      final RepositoryPackage example = package.getExamples().first;
      writeFakeGroovyExampleBuildGradles(
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
        <String>['gradle-check'],
        errorHandler: (Error e) {
          commandError = e;
        },
      );

      expect(commandError, isA<ToolExit>());
      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains(GradleCheckCommand.exampleGroovySettingsArtifactHubString),
        ]),
      );
      expect(
        output,
        isNot(
          contains(GradleCheckCommand.exampleGroovyRootGradleArtifactHubString),
        ),
      );
    });

    test('fails settings.gradle.kts artifact hub check when missing', () async {
      const packageName = 'a_package';
      final RepositoryPackage package = createFakePackage(
        'a_package',
        packagesDir,
      );
      final RepositoryPackage example = package.getExamples().first;
      writeFakeKotlinExampleBuildGradles(
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
        <String>['gradle-check'],
        errorHandler: (Error e) {
          commandError = e;
        },
      );

      expect(commandError, isA<ToolExit>());
      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains(GradleCheckCommand.exampleKotlinSettingsArtifactHubString),
        ]),
      );
      expect(
        output,
        isNot(
          contains(GradleCheckCommand.exampleKotlinRootGradleArtifactHubString),
        ),
      );
    });

    test(
      'prints error for declarative method of applying gradle plugins',
      () async {
        const packageName = 'a_package';
        final RepositoryPackage package = createFakePackage(
          'a_package',
          packagesDir,
        );
        writeFakeGroovyPluginBuildGradle(package, includeLanguageVersion: true);
        writeFakeManifest(package);
        final RepositoryPackage example = package.getExamples().first;
        writeFakeGroovyExampleBuildGradles(
          example,
          pluginName: packageName,
          // ignore: avoid_redundant_argument_values
          includeBuildArtifactHub: true,
          includeSettingsArtifactHub: false,
          // ignore: avoid_redundant_argument_values
          includeSettingsDocumentationArtifactHub: true,
        );
        writeFakeManifest(example, isApp: true);

        Error? commandError;
        final List<String> output = await runCapturingPrint(
          runner,
          <String>['gradle-check'],
          errorHandler: (Error e) {
            commandError = e;
          },
        );

        expect(commandError, isA<ToolExit>());
        expect(
          output,
          containsAllInOrder(<Matcher>[
            contains(GradleCheckCommand.exampleGroovySettingsArtifactHubString),
          ]),
        );
      },
    );

    test(
      'error message is printed when documentation link is missing - groovy',
      () async {
        const packageName = 'a_package';
        final RepositoryPackage package = createFakePackage(
          'a_package',
          packagesDir,
        );
        final RepositoryPackage example = package.getExamples().first;
        writeFakeGroovyExampleBuildGradles(
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
          <String>['gradle-check'],
          errorHandler: (Error e) {
            commandError = e;
          },
        );

        expect(commandError, isA<ToolExit>());
        expect(
          output,
          containsAllInOrder(<Matcher>[
            contains(GradleCheckCommand.artifactHubDocumentationString),
          ]),
        );
      },
    );

    test(
      'error message is printed when documentation link is missing - kotlin',
      () async {
        const packageName = 'a_package';
        final RepositoryPackage package = createFakePackage(
          'a_package',
          packagesDir,
        );
        final RepositoryPackage example = package.getExamples().first;
        writeFakeKotlinExampleBuildGradles(
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
          <String>['gradle-check'],
          errorHandler: (Error e) {
            commandError = e;
          },
        );

        expect(commandError, isA<ToolExit>());
        expect(
          output,
          containsAllInOrder(<Matcher>[
            contains(GradleCheckCommand.artifactHubDocumentationString),
          ]),
        );
      },
    );
  });

  group('Kotlin version check', () {
    test('passes if not set', () async {
      const packageName = 'a_package';
      final RepositoryPackage package = createFakePackage(
        'a_package',
        packagesDir,
      );
      writeFakeGroovyPluginBuildGradle(package, includeLanguageVersion: true);
      writeFakeManifest(package);
      final RepositoryPackage example = package.getExamples().first;
      writeFakeGroovyExampleBuildGradles(example, pluginName: packageName);
      writeFakeManifest(example, isApp: true);

      final List<String> output = await runCapturingPrint(runner, <String>[
        'gradle-check',
      ]);

      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('Validating android/build.gradle'),
        ]),
      );
    });

    test('passes if at the minimum allowed version', () async {
      const packageName = 'a_package';
      final RepositoryPackage package = createFakePackage(
        'a_package',
        packagesDir,
      );
      writeFakeGroovyPluginBuildGradle(package, includeLanguageVersion: true);
      writeFakeManifest(package);
      final RepositoryPackage example = package.getExamples().first;
      writeFakeGroovyExampleBuildGradles(
        example,
        pluginName: packageName,
        kotlinVersion: minKotlinVersion.toString(),
      );
      writeFakeManifest(example, isApp: true);

      final List<String> output = await runCapturingPrint(runner, <String>[
        'gradle-check',
      ]);

      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('Validating android/build.gradle'),
        ]),
      );
    });

    test('passes if above the minimum allowed version', () async {
      const packageName = 'a_package';
      final RepositoryPackage package = createFakePackage(
        'a_package',
        packagesDir,
      );
      writeFakeGroovyPluginBuildGradle(package, includeLanguageVersion: true);
      writeFakeManifest(package);
      final RepositoryPackage example = package.getExamples().first;
      writeFakeGroovyExampleBuildGradles(
        example,
        pluginName: packageName,
        kotlinVersion: '99.99.0',
      );
      writeFakeManifest(example, isApp: true);

      final List<String> output = await runCapturingPrint(runner, <String>[
        'gradle-check',
      ]);

      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('Validating android/build.gradle'),
        ]),
      );
    });

    test('fails if below the minimum allowed version', () async {
      const packageName = 'a_package';
      final RepositoryPackage package = createFakePackage(
        'a_package',
        packagesDir,
      );
      writeFakeGroovyPluginBuildGradle(package, includeLanguageVersion: true);
      writeFakeManifest(package);
      final RepositoryPackage example = package.getExamples().first;
      writeFakeGroovyExampleBuildGradles(
        example,
        pluginName: packageName,
        kotlinVersion: '1.6.21',
      );
      writeFakeManifest(example, isApp: true);

      Error? commandError;
      final List<String> output = await runCapturingPrint(
        runner,
        <String>['gradle-check'],
        errorHandler: (Error e) {
          commandError = e;
        },
      );

      expect(commandError, isA<ToolExit>());
      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains(
            'build.gradle sets "ext.kotlin_version" to "1.6.21". The '
            'minimum Kotlin version that can be specified is '
            '$minKotlinVersion, for compatibility with modern dependencies.',
          ),
        ]),
      );
    });
  });

  group('compileSdk check', () {
    test(
      'passes if set to a version higher than flutter.compileSdkVersion',
      () async {
        const packageName = 'a_package';
        final RepositoryPackage package = createFakePackage(
          packageName,
          packagesDir,
          isFlutter: true,
        );
        // Current flutter.compileSdkVersion is 36.
        writeFakeGroovyPluginBuildGradle(
          package,
          includeLanguageVersion: true,
          compileSdk: '37',
        );
        writeFakeManifest(package);
        final RepositoryPackage example = package.getExamples().first;
        writeFakeGroovyExampleBuildGradles(example, pluginName: packageName);
        writeFakeManifest(example, isApp: true);

        final List<String> output = await runCapturingPrint(runner, <String>[
          'gradle-check',
        ]);

        expect(
          output,
          containsAllInOrder(<Matcher>[
            contains('Validating android/build.gradle'),
          ]),
        );
      },
    );

    test(
      'passes if set to flutter.compileSdkVersion with Flutter 3.27+',
      () async {
        const packageName = 'a_package';
        final RepositoryPackage package = createFakePackage(
          packageName,
          packagesDir,
          isFlutter: true,
          flutterConstraint: '>=3.27.0',
        );
        writeFakeGroovyPluginBuildGradle(
          package,
          includeLanguageVersion: true,
          compileSdk: 'flutter.compileSdkVersion',
        );
        writeFakeManifest(package);
        final RepositoryPackage example = package.getExamples().first;
        writeFakeGroovyExampleBuildGradles(example, pluginName: packageName);
        writeFakeManifest(example, isApp: true);

        final List<String> output = await runCapturingPrint(runner, <String>[
          'gradle-check',
        ]);

        expect(
          output,
          containsAllInOrder(<Matcher>[
            contains('Validating android/build.gradle'),
          ]),
        );
      },
    );

    test(
      'fails if set to a version lower than flutter.compileSdkVersion',
      () async {
        const packageName = 'a_package';
        final RepositoryPackage package = createFakePackage(
          packageName,
          packagesDir,
          isFlutter: true,
        );
        // Current flutter.compileSdkVersion is 36.
        const minCompileSdkVersion = '36';
        const testCompileSdkVersion = '35';
        writeFakeGroovyPluginBuildGradle(
          package,
          includeLanguageVersion: true,
          compileSdk: testCompileSdkVersion,
        );
        writeFakeManifest(package);
        final RepositoryPackage example = package.getExamples().first;
        writeFakeGroovyExampleBuildGradles(example, pluginName: packageName);
        writeFakeManifest(example, isApp: true);

        Error? commandError;
        final List<String> output = await runCapturingPrint(
          runner,
          <String>['gradle-check'],
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
      },
    );

    test(
      'fails if set to flutter.compileSdkVersion with Flutter <3.27',
      () async {
        const packageName = 'a_package';
        final RepositoryPackage package = createFakePackage(
          packageName,
          packagesDir,
          isFlutter: true,
          flutterConstraint: '>=3.24.0',
        );
        writeFakeGroovyPluginBuildGradle(
          package,
          includeLanguageVersion: true,
          compileSdk: 'flutter.compileSdkVersion',
        );
        writeFakeManifest(package);
        final RepositoryPackage example = package.getExamples().first;
        writeFakeGroovyExampleBuildGradles(example, pluginName: packageName);
        writeFakeManifest(example, isApp: true);

        Error? commandError;
        final List<String> output = await runCapturingPrint(
          runner,
          <String>['gradle-check'],
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
      },
    );

    test('fails if uses the legacy key', () async {
      const packageName = 'a_package';
      final RepositoryPackage package = createFakePackage(
        packageName,
        packagesDir,
        isFlutter: true,
      );
      writeFakeGroovyPluginBuildGradle(
        package,
        includeLanguageVersion: true,
        useDeprecatedCompileSdkVersion: true,
      );
      writeFakeManifest(package);
      final RepositoryPackage example = package.getExamples().first;
      writeFakeGroovyExampleBuildGradles(example, pluginName: packageName);
      writeFakeManifest(example, isApp: true);

      Error? commandError;
      final List<String> output = await runCapturingPrint(
        runner,
        <String>['gradle-check'],
        errorHandler: (Error e) {
          commandError = e;
        },
      );

      expect(commandError, isA<ToolExit>());
      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains(
            'Please replace the deprecated "compileSdkVersion" setting '
            'with the newer "compileSdk"',
          ),
        ]),
      );
    });

    test('fails if compileSdk uses the method assignment', () async {
      const packageName = 'a_package';
      final RepositoryPackage package = createFakePackage(
        packageName,
        packagesDir,
        isFlutter: true,
      );
      writeFakeGroovyPluginBuildGradle(
        package,
        includeLanguageVersion: true,
        usePropertyAssignment: false,
      );
      writeFakeManifest(package);
      final RepositoryPackage example = package.getExamples().first;
      writeFakeGroovyExampleBuildGradles(
        example,
        pluginName: packageName,
        usePropertyAssignment: false,
      );
      writeFakeManifest(example, isApp: true);

      Error? commandError;
      final List<String> output = await runCapturingPrint(
        runner,
        <String>['gradle-check'],
        errorHandler: (Error e) {
          commandError = e;
        },
      );

      expect(commandError, isA<ToolExit>());
      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('No "compileSdk =" found. Please use property assignment.'),
        ]),
      );
    });
  });

  group('kotlinOptions check', () {
    test('passes when kotlin options are specified', () async {
      final RepositoryPackage package = createFakePlugin(
        'a_plugin',
        packagesDir,
        examples: <String>[],
      );
      writeFakeGroovyPluginBuildGradle(
        package,
        includeLanguageVersion: true,
        // ignore: avoid_redundant_argument_values ensure codepath is tested if defaults change.
        includeKotlinOptions: true,
      );
      writeFakeManifest(package);

      final List<String> output = await runCapturingPrint(runner, <String>[
        'gradle-check',
      ]);

      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('Validating android/build.gradle'),
        ]),
      );
    });

    test('passes when kotlin options are not specified', () async {
      final RepositoryPackage package = createFakePlugin(
        'a_plugin',
        packagesDir,
        examples: <String>[],
      );
      writeFakeGroovyPluginBuildGradle(
        package,
        includeLanguageVersion: true,
        includeKotlinOptions: false,
      );
      writeFakeManifest(package);

      final List<String> output = await runCapturingPrint(runner, <String>[
        'gradle-check',
      ]);

      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('Validating android/build.gradle'),
        ]),
      );
    });

    test('passes when kotlin options commented out', () async {
      final RepositoryPackage package = createFakePlugin(
        'a_plugin',
        packagesDir,
        examples: <String>[],
      );
      writeFakeGroovyPluginBuildGradle(
        package,
        includeLanguageVersion: true,
        commentKotlinOptions: true,
      );
      writeFakeManifest(package);

      final List<String> output = await runCapturingPrint(runner, <String>[
        'gradle-check',
      ]);

      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('Validating android/build.gradle'),
        ]),
      );
    });

    test('fails when kotlin options uses string jvm version', () async {
      final RepositoryPackage package = createFakePlugin(
        'a_plugin',
        packagesDir,
        examples: <String>[],
      );
      writeFakeGroovyPluginBuildGradle(
        package,
        includeLanguageVersion: true,
        useDeprecatedJvmTargetStyle: true,
      );
      writeFakeManifest(package);

      Error? commandError;
      final List<String> output = await runCapturingPrint(
        runner,
        <String>['gradle-check'],
        errorHandler: (Error e) {
          commandError = e;
        },
      );

      expect(commandError, isA<ToolExit>());
      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains(
            'build.gradle sets jvmTarget then it must use JavaVersion syntax',
          ),
        ]),
      );
    });
  });
}
