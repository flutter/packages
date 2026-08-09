// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:math' as math;

import 'package:collection/collection.dart';
import 'package:file/file.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart' as path;
import 'package:pub_semver/pub_semver.dart';

import '../common/file_utils.dart';
import '../common/output_utils.dart';
import '../common/repository_package.dart';

/// The lowest `ext.kotlin_version` that example apps are allowed to use.
@visibleForTesting
final Version minKotlinVersion = Version(2, 0, 0);

/// A validator that checks that Gradle files follow repository conventions.
class GradleValidator {
  /// Creates a new validator with the given command context.
  GradleValidator({required path.Context path, required String indentation}) {
    _path = path;
    _indentation = indentation;
  }

  late path.Context _path;
  late String _indentation;

  static const int _minimumJavaVersion = 17;

  /// Documentation url for Artifact hub implementation in flutter repo's.
  @visibleForTesting
  static const String artifactHubDocumentationString =
      r'https://github.com/flutter/flutter/blob/master/docs/ecosystem/Plugins-and-Packages-repository-structure.md#gradle-structure';

  /// String printed as example of valid example root build.gradle.kts
  /// repository configuration that enables artifact hub env variable.
  @visibleForTesting
  static const String exampleRootGradleArtifactHubString =
      '''
        // See $artifactHubDocumentationString for more info.
        val artifactRepoKey = "ARTIFACT_HUB_REPOSITORY"
        val artifactRepoUrl = System.getenv(artifactRepoKey)
        if (artifactRepoUrl != null) {
            println("Using artifact hub")
            maven {
                url = uri(artifactRepoUrl)
            }
        }
''';

  /// Validates the Gradle configuration for the given package, returning a list
  /// of error messages.
  ///
  /// Returns an empty list if validation succeeds.
  List<String> validateGradle(RepositoryPackage package) {
    const exampleDirName = 'example';
    final bool isExample =
        package.directory.basename == exampleDirName ||
        package.directory.parent.basename == exampleDirName;
    if (!_validateBuildGradles(package, isExample: isExample)) {
      return <String>['Failed Gradle validation'];
    }
    return <String>[];
  }

  bool _validateBuildGradles(RepositoryPackage package, {required bool isExample}) {
    final Directory androidDir = package.platformDirectory(FlutterPlatform.android);
    final File topLevelGradleFile = _getBuildGradleFile(androidDir);

    // This is tracked as a variable rather than a sequence of &&s so that all
    // failures are reported at once, not just the first one.
    var succeeded = true;
    if (isExample) {
      if (!_validateExampleTopLevelBuildGradle(package, topLevelGradleFile)) {
        succeeded = false;
      }
      final File topLevelSettingsGradleFile = _getSettingsGradleFile(androidDir);
      if (!_validateExampleTopLevelSettingsGradle(package, topLevelSettingsGradleFile)) {
        succeeded = false;
      }

      final File appGradleFile = _getBuildGradleFile(androidDir.childDirectory('app'));
      if (!_validateExampleAppBuildGradle(package, appGradleFile)) {
        succeeded = false;
      }
    } else {
      succeeded = _validatePluginBuildGradle(package, topLevelGradleFile);
    }

    return succeeded;
  }

  // Returns the gradle file in the given directory.
  File _getBuildGradleFile(Directory dir) {
    const buildGradleBaseName = 'build.gradle';
    const buildGradleKtsBaseName = '$buildGradleBaseName.kts';
    if (dir.childFile(buildGradleKtsBaseName).existsSync()) {
      return dir.childFile(buildGradleKtsBaseName);
    }
    return dir.childFile(buildGradleBaseName);
  }

  // Returns the settings gradle file in the given directory.
  File _getSettingsGradleFile(Directory dir) {
    const settingsGradleBaseName = 'settings.gradle';
    const settingsGradleKtsBaseName = '$settingsGradleBaseName.kts';
    if (dir.childFile(settingsGradleKtsBaseName).existsSync()) {
      return dir.childFile(settingsGradleKtsBaseName);
    }
    return dir.childFile(settingsGradleBaseName);
  }

  // Returns the main/AndroidManifest.xml file for the given package.
  File _getMainAndroidManifest(RepositoryPackage package, {required bool isExample}) {
    final Directory androidDir = package.platformDirectory(FlutterPlatform.android);
    final Directory baseDir = isExample ? androidDir.childDirectory('app') : androidDir;
    return baseDir.childDirectory('src').childDirectory('main').childFile('AndroidManifest.xml');
  }

  bool _isCommented(String line) => line.trim().startsWith('//');

  /// Validates the build.gradle file for a plugin
  /// (some_plugin/android/build.gradle).
  bool _validatePluginBuildGradle(RepositoryPackage package, File gradleFile) {
    print(
      '${_indentation}Validating '
      '${_getRelativePosixPath(gradleFile, from: package.directory)}.',
    );
    final String contents = gradleFile.readAsStringSync();
    final List<String> lines = contents.split('\n');

    // This is tracked as a variable rather than a sequence of &&s so that all
    // failures are reported at once, not just the first one.
    var succeeded = true;
    if (!_validateNamespace(package, contents, isExample: false)) {
      succeeded = false;
    }
    if (!_validateCompatibilityVersions(lines)) {
      succeeded = false;
    }
    if (!_validateKotlinPluginUsage(lines)) {
      succeeded = false;
    }
    if (!_validateKotlinJvmCompatibility(lines)) {
      succeeded = false;
    }
    if (!_validateJavaKotlinCompilerOptionsAlignment(lines)) {
      succeeded = false;
    }
    if (!_validateGradleDrivenLintConfig(lines)) {
      succeeded = false;
    }
    if (!_validateCompileSdkUsage(package, lines)) {
      succeeded = false;
    }
    return succeeded;
  }

  /// Validates that [gradleLines] reads and uses a artifiact hub repository
  /// when ARTIFACT_HUB_REPOSITORY is set.
  ///
  /// Required in root gradle file.
  bool _validateArtifactHubUsage(RepositoryPackage example, List<String> gradleLines) {
    // Gradle variable name used to hold environment variable string.
    const keyVariable = 'artifactRepoKey';
    const urlVariable = 'artifactRepoUrl';
    final keyPresentRegex = RegExp(
      '$keyVariable'
      r'''\s+=\s+["']ARTIFACT_HUB_REPOSITORY["']''',
    );
    final documentationPresentRegex = RegExp(
      r'github\.com.*flutter.*blob.*Plugins-and-Packages-repository-structure.*gradle-structure',
    );
    final keyReadRegex = RegExp(
      '$urlVariable'
      r'\s*=\s*System\.getenv\('
      '$keyVariable'
      r'\)',
    );
    final keyUsedRegex = RegExp(
      r'url = uri\('
      '$urlVariable'
      r'\)',
    );

    final bool keyPresent = gradleLines.any((String line) => keyPresentRegex.hasMatch(line));
    final bool documentationPresent = gradleLines.any(
      (String line) => documentationPresentRegex.hasMatch(line),
    );
    final bool keyRead = gradleLines.any((String line) => keyReadRegex.hasMatch(line));
    final bool keyUsed = gradleLines.any((String line) => keyUsedRegex.hasMatch(line));

    if (!(documentationPresent && keyPresent && keyRead && keyUsed)) {
      printError(
        'Failed Artifact Hub validation. Include the following in '
        'example root build.gradle:\n$exampleRootGradleArtifactHubString',
      );
    }

    return keyPresent && documentationPresent && keyRead && keyUsed;
  }

  /// Validates the top-level settings.gradle for an example app (e.g.,
  /// some_package/example/android/settings.gradle).
  bool _validateExampleTopLevelSettingsGradle(RepositoryPackage package, File gradleSettingsFile) {
    print(
      '${_indentation}Validating '
      '${_getRelativePosixPath(gradleSettingsFile, from: package.directory)}.',
    );
    final String contents = gradleSettingsFile.readAsStringSync();
    final List<String> lines = contents.split('\n');
    // This is tracked as a variable rather than a sequence of &&s so that all
    // failures are reported at once, not just the first one.
    var succeeded = true;
    if (!_validateArtifactHubSettingsUsage(package, lines)) {
      succeeded = false;
    }
    if (!_validateKotlinVersion(package, lines)) {
      succeeded = false;
    }
    return succeeded;
  }

  /// String printed as a valid example of settings.gradle.kts repository
  /// configuration that enables artifact hub env variable.
  @visibleForTesting
  static const String exampleSettingsArtifactHubString = '''
plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    // ...other plugins
    id("com.google.cloud.artifactregistry.gradle-plugin") version "2.2.1"
}
  ''';

  /// Validates that [gradleLines] reads and uses a artifiact hub repository
  /// when ARTIFACT_HUB_REPOSITORY is set.
  ///
  /// Required in root gradle file.
  bool _validateArtifactHubSettingsUsage(RepositoryPackage example, List<String> gradleLines) {
    final documentationPresentRegex = RegExp(
      r'github\.com.*flutter.*blob.*Plugins-and-Packages-repository-structure.*gradle-structure',
    );
    final artifactRegistryPluginApplyRegex = RegExp(
      r'id.*com\.google\.cloud\.artifactregistry\.gradle-plugin.*version.*\b\d+\.\d+\.\d+\b',
    );

    final bool documentationPresent = gradleLines.any(
      (String line) => documentationPresentRegex.hasMatch(line),
    );
    final bool declarativeArtifactRegistryApplied = gradleLines.any(
      (String line) => artifactRegistryPluginApplyRegex.hasMatch(line),
    );
    final bool validArtifactConfiguration =
        documentationPresent && declarativeArtifactRegistryApplied;

    if (!validArtifactConfiguration) {
      printError('Failed Artifact Hub validation.');
      if (!documentationPresent) {
        printError(
          'The link to the Artifact Hub documentation is missing. Include the following in '
          'example root settings.gradle:\n// See $artifactHubDocumentationString for more info.',
        );
      }
      if (!declarativeArtifactRegistryApplied) {
        printError(
          'Include the following in '
          'example root settings.gradle:\n$exampleSettingsArtifactHubString',
        );
      }
    }
    return validArtifactConfiguration;
  }

  /// Validates the top-level build.gradle(.kts) for an example app (e.g.,
  /// some_package/example/android/build.gradle(.kts)).
  bool _validateExampleTopLevelBuildGradle(RepositoryPackage package, File gradleFile) {
    print(
      '${_indentation}Validating '
      '${_getRelativePosixPath(gradleFile, from: package.directory)}.',
    );
    final String contents = gradleFile.readAsStringSync();
    final List<String> lines = contents.split('\n');

    // This is tracked as a variable rather than a sequence of &&s so that all
    // failures are reported at once, not just the first one.
    var succeeded = true;
    if (!_validateJavacLintConfig(package, lines)) {
      succeeded = false;
    }
    if (!_validateArtifactHubUsage(package, lines)) {
      succeeded = false;
    }
    return succeeded;
  }

  /// Validates the app-level build.gradle(.kts) for an example app (e.g.,
  /// some_package/example/android/app/build.gradle(.kts)).
  bool _validateExampleAppBuildGradle(RepositoryPackage package, File gradleFile) {
    print(
      '${_indentation}Validating '
      '${_getRelativePosixPath(gradleFile, from: package.directory)}.',
    );
    final String contents = gradleFile.readAsStringSync();
    final List<String> lines = contents.split('\n');

    // This is tracked as a variable rather than a sequence of &&s so that all
    // failures are reported at once, not just the first one.
    var succeeded = true;
    if (!_validateNamespace(package, contents, isExample: true)) {
      succeeded = false;
    }
    if (!_validateKotlinPluginUsage(lines)) {
      succeeded = false;
    }
    if (!_validateKotlinJvmCompatibility(lines)) {
      succeeded = false;
    }
    if (!_validateJavaKotlinCompilerOptionsAlignment(lines)) {
      succeeded = false;
    }
    return succeeded;
  }

  /// Validates that [gradleContents] sets a namespace, which is required for
  /// compatibility with apps that use AGP 8+.
  bool _validateNamespace(
    RepositoryPackage package,
    String gradleContents, {
    required bool isExample,
  }) {
    // Regex to validate that the following namespace definition
    // is found (where the single quotes can be single or double):
    //  - namespace = 'dev.flutter.foo'
    final nameSpaceRegex = RegExp('^\\s*namespace\\s+=\\s*[\'"](.*?)[\'"]', multiLine: true);
    final RegExpMatch? nameSpaceRegexMatch = nameSpaceRegex.firstMatch(gradleContents);

    if (nameSpaceRegexMatch == null) {
      const errorMessage = '''
build.gradle.kts must set a "namespace":

    android {
        namespace = "dev.flutter.foo"
    }

The value must match the "package" attribute in AndroidManifest.xml, if one is
present. For more information, see:
https://developer.android.com/build/publish-library/prep-lib-release#choose-namespace
''';

      printError('$_indentation${errorMessage.split('\n').join('\n$_indentation')}');
      return false;
    } else {
      return _validateNamespaceMatchesManifest(
        package,
        isExample: isExample,
        namespace: nameSpaceRegexMatch.group(1)!,
      );
    }
  }

  /// Validates that the given namespace matches the manifest package of
  /// [package] (if any; a package does not need to be in the manifest in cases
  /// where compatibility with AGP <7 is no longer required).
  ///
  /// Prints an error and returns false if validation fails.
  bool _validateNamespaceMatchesManifest(
    RepositoryPackage package, {
    required bool isExample,
    required String namespace,
  }) {
    final manifestPackageRegex = RegExp(r'package\s*=\s*"(.*?)"');
    final String manifestContents = _getMainAndroidManifest(
      package,
      isExample: isExample,
    ).readAsStringSync();
    final RegExpMatch? packageMatch = manifestPackageRegex.firstMatch(manifestContents);
    if (packageMatch != null && namespace != packageMatch.group(1)) {
      const buildGradleName = 'build.gradle.kts';
      final errorMessage =
          '''
$buildGradleName "namespace" must match the "package" attribute in AndroidManifest.xml, if one is present.
  $buildGradleName namespace: "$namespace"
  AndroidMastifest.xml package: "${packageMatch.group(1)}"
''';
      printError('$_indentation${errorMessage.split('\n').join('\n$_indentation')}');
      return false;
    }
    return true;
  }

  /// Checks for a source compatibiltiy version, so that it's explicit rather
  /// than using whatever the client's local toolchaing defaults to (which can
  /// lead to compile errors that show up for clients, but not in CI).
  bool _validateCompatibilityVersions(List<String> gradleLines) {
    final bool hasLanguageVersion = gradleLines.any(
      (String line) => line.contains('languageVersion') && !_isCommented(line),
    );
    final bool hasCompabilityVersions =
        gradleLines.any(
          (String line) =>
              line.contains('sourceCompatibility = JavaVersion.VERSION_') && !_isCommented(line),
        ) &&
        // Newer toolchains default targetCompatibility to the same value as
        // sourceCompatibility, but older toolchains require it to be set
        // explicitly. The exact version cutoff (and of which piece of the
        // toolchain; likely AGP) is unknown; for context see
        // https://github.com/flutter/flutter/issues/125482
        gradleLines.any(
          (String line) =>
              line.contains('targetCompatibility = JavaVersion.VERSION_') && !_isCommented(line),
        );
    if (!hasLanguageVersion && !hasCompabilityVersions) {
      const javaErrorMessage =
          '''
build.gradle.kts must set an explicit Java compatibility version.

This can be done either via "sourceCompatibility"/"targetCompatibility":
    android {
        compileOptions {
            sourceCompatibility = JavaVersion.VERSION_$_minimumJavaVersion
            targetCompatibility = JavaVersion.VERSION_$_minimumJavaVersion
        }
    }

or "toolchain":
    java {
        toolchain {
            languageVersion = JavaLanguageVersion.of($_minimumJavaVersion)
        }
    }

See:
https://docs.gradle.org/current/userguide/java_plugin.html#toolchain_and_compatibility
for more details.''';

      printError('$_indentation${javaErrorMessage.split('\n').join('\n$_indentation')}');
      return false;
    }

    return true;
  }

  bool _validateKotlinJvmCompatibility(List<String> gradleLines) {
    bool isKotlinOptions(String line) => line.contains('kotlinOptions') && !_isCommented(line);
    final bool hasKotlinOptions = gradleLines.any(isKotlinOptions);
    if (hasKotlinOptions) {
      const kotlinOptionsErrorMessage =
          '''
build.gradle.kts must not use the deprecated "kotlinOptions" DSL. Use "kotlin.compilerOptions" instead:

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_$_minimumJavaVersion
    }
}
''';
      printError('$_indentation${kotlinOptionsErrorMessage.split('\n').join('\n$_indentation')}');
      return false;
    }

    bool isCompilerOptions(String line) => line.contains('compilerOptions') && !_isCommented(line);
    final bool hasCompilerOptions = gradleLines.any(isCompilerOptions);

    if (hasCompilerOptions && _isCompilerOptionsInsideAndroid(gradleLines)) {
      const nestedCompilerOptionsErrorMessage =
          '''
build.gradle.kts must not nest "kotlin" or "compilerOptions" inside the "android" block. It must be at the top-level:
  Good:
    kotlin {
        compilerOptions {
            jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_$_minimumJavaVersion
        }
    }

    android {
        ...
    }
  BAD:
    android {
        kotlin {
            compilerOptions {
                jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_$_minimumJavaVersion
            }
        }
    }
''';
      printError(
        '$_indentation${nestedCompilerOptionsErrorMessage.split('\n').join('\n$_indentation')}',
      );
      return false;
    }

    final bool compilerOptionsUsesJvmTargetEnum = gradleLines.any(
      (String line) =>
          RegExp(r'jvmTarget\s*=\s*(?:[a-zA-Z0-9.]+)?JvmTarget\.JVM_\d+').hasMatch(line) &&
          !_isCommented(line),
    );

    // Either does not set compilerOptions or does and uses non-string based syntax.
    if (hasCompilerOptions && !compilerOptionsUsesJvmTargetEnum) {
      var badLines = '';
      final int startIndex = gradleLines.indexOf(gradleLines.firstWhere(isCompilerOptions));
      for (var i = startIndex; i < math.min(startIndex + 4, gradleLines.length); i++) {
        badLines += '${gradleLines[i]}\n';
      }

      final kotlinErrorMessage =
          '''
If build.gradle.kts sets jvmTarget inside kotlin.compilerOptions, it must use JvmTarget syntax.
  Good:
    kotlin {
        compilerOptions {
            jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_$_minimumJavaVersion
        }
    }
  BAD:
    ${badLines.trim()}
''';
      printError('$_indentation${kotlinErrorMessage.split('\n').join('\n$_indentation')}');
      return false;
    }
    // No error condition.
    return true;
  }

  bool _isCompilerOptionsInsideAndroid(List<String> gradleLines) {
    final int androidIndex = gradleLines.indexWhere(
      (String line) => line.contains('android {') && !_isCommented(line),
    );
    if (androidIndex == -1) {
      return false;
    }

    // Find closing brace of android block.
    var braceCount = 1;
    var androidEndIndex = -1;
    for (int i = androidIndex + 1; i < gradleLines.length; i++) {
      final String line = gradleLines[i];
      if (_isCommented(line)) {
        continue;
      }
      braceCount += line.split('{').length - 1;
      braceCount -= line.split('}').length - 1;
      if (braceCount == 0) {
        androidEndIndex = i;
        break;
      }
    }

    if (androidEndIndex == -1) {
      return false;
    }

    for (int i = androidIndex + 1; i < androidEndIndex; i++) {
      final String line = gradleLines[i];
      if (line.contains('compilerOptions') && !_isCommented(line)) {
        return true;
      }
    }

    return false;
  }

  bool _validateKotlinPluginUsage(List<String> gradleLines) {
    final kotlinPluginRegex = RegExp(
      r'''id\s*\(?\s*["'](?:kotlin-android|org\.jetbrains\.kotlin\.android)["']\s*\)?''',
    );
    final bool hasKotlinPlugin = gradleLines.any(
      (String line) => kotlinPluginRegex.hasMatch(line) && !_isCommented(line),
    );

    if (hasKotlinPlugin) {
      final bool isApp = gradleLines.any(
        (String line) => line.contains('com.android.application') && !_isCommented(line),
      );
      final moduleType = isApp ? 'app' : 'plugin';
      final pluginId = isApp ? 'com.android.application' : 'com.android.library';
      final kotlinPluginErrorMessage =
          '''
The kotlin-android plugin should not be applied in the $moduleType module's build.gradle.kts.
  Good:
    plugins {
        id("$pluginId")
    }
  BAD:
    plugins {
        id("$pluginId")
        id("kotlin-android")
    }
''';
      printError('$_indentation${kotlinPluginErrorMessage.split('\n').join('\n$_indentation')}');
      return false;
    }

    return true;
  }

  bool _validateJavaKotlinCompilerOptionsAlignment(List<String> gradleLines) {
    final javaVersions = <String>[];
    // Some java versions have the format VERSION_1_8 but we dont need to handle those
    // because they are below the minimum.
    final javaVersionMatcher = RegExp(r'JavaVersion.VERSION_(?<javaVersion>\d+)');
    final kotlinJvmTargetMatcher = RegExp(r'JvmTarget.JVM_(?<kotlinJvmVersion>\d+)');
    for (final line in gradleLines) {
      if (_isCommented(line)) {
        continue;
      }
      final RegExpMatch? javaMatch = javaVersionMatcher.firstMatch(line);
      if (javaMatch != null) {
        final String? foundVersion = javaMatch.namedGroup('javaVersion');
        if (foundVersion != null) {
          javaVersions.add(foundVersion);
        }
      }
      final RegExpMatch? kotlinJvmMatch = kotlinJvmTargetMatcher.firstMatch(line);
      if (kotlinJvmMatch != null) {
        final String? foundVersion = kotlinJvmMatch.namedGroup('kotlinJvmVersion');
        if (foundVersion != null) {
          javaVersions.add(foundVersion);
        }
      }
    }
    if (javaVersions.isNotEmpty) {
      final int version = int.parse(javaVersions.first);
      if (!javaVersions.every((String element) => element == '$version')) {
        const javaVersionAlignmentError = '''
If build.gradle.kts uses JavaVersion.* and JvmTarget.*, the versions must be the same.
''';
        printError('$_indentation${javaVersionAlignmentError.split('\n').join('\n$_indentation')}');
        return false;
      }

      if (version < _minimumJavaVersion) {
        final minimumJavaVersionError =
            '''
build.gradle.kts uses "JavaVersion.VERSION_$version".
Which is below the minimum required. Use at least "JavaVersion.VERSION_$_minimumJavaVersion".
''';
        printError('$_indentation${minimumJavaVersionError.split('\n').join('\n$_indentation')}');
        return false;
      }
    }

    return true;
  }

  /// Returns whether the given gradle content is configured to enable all
  /// Gradle-driven lints (those checked by ./gradlew lint) and treat them as
  /// errors.
  bool _validateGradleDrivenLintConfig(List<String> gradleLines) {
    if (!gradleLines.any(
          (String line) => line.contains('checkAllWarnings = true') && !_isCommented(line),
        ) ||
        !gradleLines.any(
          (String line) => line.contains('warningsAsErrors = true') && !_isCommented(line),
        )) {
      printError(
        '${_indentation}This package is not configured to enable all '
        'Gradle-driven lint warnings and treat them as errors. '
        'Please add the following to the lintOptions section of '
        'android/build.gradle.kts:',
      );
      print('''
        checkAllWarnings = true
        warningsAsErrors = true
''');
      return false;
    }
    return true;
  }

  bool _validateCompileSdkUsage(RepositoryPackage package, List<String> gradleLines) {
    final linePattern = RegExp(r'^\s*compileSdk.*\s+=');
    final legacySettingPattern = RegExp(r'^\s*compileSdkVersion');
    final String? compileSdkLine = gradleLines.firstWhereOrNull(
      (String line) => linePattern.hasMatch(line),
    );

    if (compileSdkLine == null) {
      // Equals regex not found check for method pattern.
      final compileSpacePattern = RegExp(r'^\s*compileSdk');
      final String? methodAssignmentLine = gradleLines.firstWhereOrNull(
        (String line) => compileSpacePattern.hasMatch(line),
      );
      if (methodAssignmentLine == null) {
        printError('${_indentation}No compileSdk or compileSdkVersion found.');
      } else {
        printError('${_indentation}No "compileSdk =" found. Please use property assignment.');
      }
      return false;
    }
    if (legacySettingPattern.hasMatch(compileSdkLine)) {
      printError(
        '${_indentation}Please replace the deprecated '
        '"compileSdkVersion" setting with the newer "compileSdk"',
      );
      return false;
    }
    if (compileSdkLine.contains('flutter.compileSdkVersion')) {
      final Pubspec pubspec = package.parsePubspec();
      final VersionConstraint? flutterConstraint = pubspec.environment['flutter'];
      final Version? minFlutterVersion =
          flutterConstraint != null && flutterConstraint is VersionRange
          ? flutterConstraint.min
          : null;
      if (minFlutterVersion == null) {
        printError(
          '${_indentation}Unable to find a Flutter SDK version '
          'constraint. Use of flutter.compileSdkVersion requires a minimum '
          'Flutter version of 3.27',
        );
        return false;
      }
      if (minFlutterVersion < Version(3, 27, 0)) {
        printError(
          '${_indentation}Use of flutter.compileSdkVersion requires a '
          'minimum Flutter version of 3.27, but this package currently '
          'supports $minFlutterVersion.\n'
          "${_indentation}Please update the package's minimum Flutter SDK "
          'version to at least 3.27.',
        );
        return false;
      }
    } else {
      // Extract compileSdkVersion and check if it is higher than flutter.compileSdkVersion.
      final numericVersionPattern = RegExp(r'=\s*(\d+)');
      final RegExpMatch? versionMatch = numericVersionPattern.firstMatch(compileSdkLine);

      if (versionMatch != null) {
        final int compileSdkVersion = int.parse(versionMatch.group(1)!);
        const minCompileSdkVersion = 36;

        if (compileSdkVersion < minCompileSdkVersion) {
          printError(
            '${_indentation}compileSdk version $compileSdkVersion is too low. '
            'Minimum required version is $minCompileSdkVersion.\n'
            "${_indentation}Please update this package's compileSdkVersion to at least "
            '$minCompileSdkVersion or use flutter.compileSdkVersion.',
          );
          return false;
        }
      } else {
        printError('${_indentation}Unable to parse compileSdk version number.');
        return false;
      }
    }
    return true;
  }

  /// Validates whether the given [example]'s gradle content is configured to
  /// build its plugin target with javac lints enabled and treated as errors,
  /// if the enclosing package is a plugin.
  ///
  /// This can only be called on example packages. (Plugin packages should not
  /// be configured this way, since it would affect clients.)
  ///
  /// If [example]'s enclosing package is not a plugin package, this just
  /// returns true.
  bool _validateJavacLintConfig(RepositoryPackage example, List<String> gradleLines) {
    final RepositoryPackage enclosingPackage = example.getEnclosingPackage()!;
    // This checks for android/ rather than using pluginSupportsPlatform because
    // Dart-only implementations (e.g., usin jnigen) won't have this
    // configuration since there's no native plugin code to check.
    if (!enclosingPackage.platformDirectory(FlutterPlatform.android).existsSync()) {
      return true;
    }
    final String enclosingPackageName = enclosingPackage.directory.basename;

    // The check here is intentionally somewhat loose, to allow for the
    // possibility of variations (e.g., not using Xlint:all in some cases, or
    // passing other arguments).
    if (!(gradleLines.any((String line) => line.contains('project(":$enclosingPackageName")')) &&
        gradleLines.any(
          (String line) =>
              line.contains('options.compilerArgs') &&
              line.contains('-Xlint') &&
              line.contains('-Werror'),
        ))) {
      printError(
        'The example '
        '"${_getRelativePosixPath(example.directory, from: enclosingPackage.directory)}" '
        'is not configured to treat javac lints and warnings as errors. '
        'Please add the following to its build.gradle:',
      );
      print('''
gradle.projectsEvaluated {
    project(":$enclosingPackageName") {
        tasks.withType(JavaCompile) {
            options.compilerArgs << "-Xlint:all" << "-Werror"
        }
    }
}
''');
      return false;
    }
    return true;
  }

  /// Validates whether the given [example] has its Kotlin version set to at
  /// least a minimum value, if it is set at all.
  bool _validateKotlinVersion(RepositoryPackage example, List<String> gradleLines) {
    final kotlinVersionRegex = RegExp(
      r'id\("org\.jetbrains\.kotlin\.android"\) version "([\d.]+)"',
    );
    RegExpMatch? match;
    if (gradleLines.any((String line) {
      match = kotlinVersionRegex.firstMatch(line);
      return match != null;
    })) {
      final version = Version.parse(match!.group(1)!);
      if (version < minKotlinVersion) {
        printError(
          'settings.gradle.kts sets the "org.jetbrains.kotlin.android" '
          'plugin version to "$version". The minimum Kotlin version that can '
          'be specified is $minKotlinVersion, for compatibility with modern '
          'dependencies.',
        );
        return false;
      }
    }
    return true;
  }

  String _getRelativePosixPath(FileSystemEntity file, {required Directory from}) {
    return relativePosixPath(file, from: from, platformContext: _path);
  }
}
