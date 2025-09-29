// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:collection/collection.dart';
import 'package:file/file.dart';
import 'package:meta/meta.dart';
import 'package:pub_semver/pub_semver.dart';

import 'common/core.dart';
import 'common/output_utils.dart';
import 'common/package_looping_command.dart';
import 'common/plugin_utils.dart';
import 'common/repository_package.dart';

/// The lowest `ext.kotlin_version` that example apps are allowed to use.
@visibleForTesting
final Version minKotlinVersion = Version(1, 7, 10);

/// A command to enforce gradle file conventions and best practices.
class GradleCheckCommand extends PackageLoopingCommand {
  /// Creates an instance of the gradle check command.
  GradleCheckCommand(
    super.packagesDir, {
    super.gitDir,
  });

  @override
  final String name = 'gradle-check';

  @override
  List<String> get aliases => <String>['check-gradle'];

  @override
  final String description =
      'Checks that gradle files follow repository conventions.';

  @override
  bool get hasLongOutput => false;

  @override
  PackageLoopingType get packageLoopingType =>
      PackageLoopingType.includeAllSubpackages;

  @override
  Future<PackageResult> runForPackage(RepositoryPackage package) async {
    if (!package.platformDirectory(FlutterPlatform.android).existsSync()) {
      return PackageResult.skip('No android/ directory.');
    }

    const String exampleDirName = 'example';
    final bool isExample = package.directory.basename == exampleDirName ||
        package.directory.parent.basename == exampleDirName;
    if (!_validateBuildGradles(package, isExample: isExample)) {
      return PackageResult.fail();
    }
    return PackageResult.success();
  }

  bool _validateBuildGradles(RepositoryPackage package,
      {required bool isExample}) {
    final Directory androidDir =
        package.platformDirectory(FlutterPlatform.android);
    final File topLevelGradleFile = _getBuildGradleFile(androidDir);

    // This is tracked as a variable rather than a sequence of &&s so that all
    // failures are reported at once, not just the first one.
    bool succeeded = true;
    if (isExample) {
      if (!_validateExampleTopLevelBuildGradle(package, topLevelGradleFile)) {
        succeeded = false;
      }
      final File topLevelSettingsGradleFile =
          _getSettingsGradleFile(androidDir);
      if (!_validateExampleTopLevelSettingsGradle(
          package, topLevelSettingsGradleFile)) {
        succeeded = false;
      }

      final File appGradleFile =
          _getBuildGradleFile(androidDir.childDirectory('app'));
      if (!_validateExampleAppBuildGradle(package, appGradleFile)) {
        succeeded = false;
      }
    } else {
      succeeded = _validatePluginBuildGradle(package, topLevelGradleFile);
    }

    return succeeded;
  }

  // Returns the gradle file in the given directory.
  File _getBuildGradleFile(Directory dir) => dir.childFile('build.gradle');

  // Returns the settings gradle file in the given directory.
  File _getSettingsGradleFile(Directory dir) =>
      dir.childFile('settings.gradle');

  // Returns the main/AndroidManifest.xml file for the given package.
  File _getMainAndroidManifest(RepositoryPackage package,
      {required bool isExample}) {
    final Directory androidDir =
        package.platformDirectory(FlutterPlatform.android);
    final Directory baseDir =
        isExample ? androidDir.childDirectory('app') : androidDir;
    return baseDir
        .childDirectory('src')
        .childDirectory('main')
        .childFile('AndroidManifest.xml');
  }

  bool _isCommented(String line) => line.trim().startsWith('//');

  /// Validates the build.gradle file for a plugin
  /// (some_plugin/android/build.gradle).
  bool _validatePluginBuildGradle(RepositoryPackage package, File gradleFile) {
    print('${indentation}Validating '
        '${getRelativePosixPath(gradleFile, from: package.directory)}.');
    final String contents = gradleFile.readAsStringSync();
    final List<String> lines = contents.split('\n');

    // This is tracked as a variable rather than a sequence of &&s so that all
    // failures are reported at once, not just the first one.
    bool succeeded = true;
    if (!_validateNamespace(package, contents, isExample: false)) {
      succeeded = false;
    }
    if (!_validateCompatibilityVersions(lines)) {
      succeeded = false;
    }
    if (!_validateGradleDrivenLintConfig(package, lines)) {
      succeeded = false;
    }
    if (!_validateCompileSdkUsage(package, lines)) {
      succeeded = false;
    }
    return succeeded;
  }

  /// Documentation url for Artifact hub implementation in flutter repo's.
  @visibleForTesting
  static const String artifactHubDocumentationString =
      r'https://github.com/flutter/flutter/blob/master/docs/ecosystem/Plugins-and-Packages-repository-structure.md#gradle-structure';

  /// String printed as example of valid example root build.gradle repository
  /// configuration that enables artifact hub env variable.
  @visibleForTesting
  static const String exampleRootGradleArtifactHubString = '''
        // See $artifactHubDocumentationString for more info.
        def artifactRepoKey = 'ARTIFACT_HUB_REPOSITORY'
        if (System.getenv().containsKey(artifactRepoKey)) {
            println "Using artifact hub"
            maven { url System.getenv(artifactRepoKey) }
        }
''';

  /// Validates that [gradleLines] reads and uses a artifiact hub repository
  /// when ARTIFACT_HUB_REPOSITORY is set.
  ///
  /// Required in root gradle file.
  bool _validateArtifactHubUsage(
      RepositoryPackage example, List<String> gradleLines) {
    // Gradle variable name used to hold environment variable string.
    const String keyVariable = 'artifactRepoKey';
    final RegExp keyPresentRegex =
        RegExp('$keyVariable' r"\s+=\s+'ARTIFACT_HUB_REPOSITORY'");
    final RegExp documentationPresentRegex = RegExp(
        r'github\.com.*flutter.*blob.*Plugins-and-Packages-repository-structure.*gradle-structure');
    final RegExp keyReadRegex =
        RegExp(r'if.*System\.getenv.*\.containsKey.*' '$keyVariable');
    final RegExp keyUsedRegex =
        RegExp(r'maven.*url.*System\.getenv\(' '$keyVariable');

    final bool keyPresent =
        gradleLines.any((String line) => keyPresentRegex.hasMatch(line));
    final bool documentationPresent = gradleLines
        .any((String line) => documentationPresentRegex.hasMatch(line));
    final bool keyRead =
        gradleLines.any((String line) => keyReadRegex.hasMatch(line));
    final bool keyUsed =
        gradleLines.any((String line) => keyUsedRegex.hasMatch(line));

    if (!(documentationPresent && keyPresent && keyRead && keyUsed)) {
      printError('Failed Artifact Hub validation. Include the following in '
          'example root build.gradle:\n$exampleRootGradleArtifactHubString');
    }

    return keyPresent && documentationPresent && keyRead && keyUsed;
  }

  /// Validates the top-level settings.gradle for an example app (e.g.,
  /// some_package/example/android/settings.gradle).
  bool _validateExampleTopLevelSettingsGradle(
      RepositoryPackage package, File gradleSettingsFile) {
    print('${indentation}Validating '
        '${getRelativePosixPath(gradleSettingsFile, from: package.directory)}.');
    final String contents = gradleSettingsFile.readAsStringSync();
    final List<String> lines = contents.split('\n');
    // This is tracked as a variable rather than a sequence of &&s so that all
    // failures are reported at once, not just the first one.
    bool succeeded = true;
    if (!_validateArtifactHubSettingsUsage(package, lines)) {
      succeeded = false;
    }
    return succeeded;
  }

  /// String printed as a valid example of settings.gradle repository
  /// configuration that enables artifact hub env variable.
  @visibleForTesting
  static String exampleSettingsArtifactHubString = '''
plugins {
    id "dev.flutter.flutter-plugin-loader" version "1.0.0"
    // ...other plugins
    id "com.google.cloud.artifactregistry.gradle-plugin" version "2.2.1"
}
  ''';

  /// Validates that [gradleLines] reads and uses a artifiact hub repository
  /// when ARTIFACT_HUB_REPOSITORY is set.
  ///
  /// Required in root gradle file.
  bool _validateArtifactHubSettingsUsage(
      RepositoryPackage example, List<String> gradleLines) {
    final RegExp documentationPresentRegex = RegExp(
        r'github\.com.*flutter.*blob.*Plugins-and-Packages-repository-structure.*gradle-structure');
    final RegExp artifactRegistryPluginApplyRegex = RegExp(
        r'id.*com\.google\.cloud\.artifactregistry\.gradle-plugin.*version.*\b\d+\.\d+\.\d+\b');

    final bool documentationPresent = gradleLines
        .any((String line) => documentationPresentRegex.hasMatch(line));
    final bool declarativeArtifactRegistryApplied = gradleLines
        .any((String line) => artifactRegistryPluginApplyRegex.hasMatch(line));
    final bool validArtifactConfiguration =
        documentationPresent && declarativeArtifactRegistryApplied;

    if (!validArtifactConfiguration) {
      printError('Failed Artifact Hub validation.');
      if (!documentationPresent) {
        printError(
            'The link to the Artifact Hub documentation is missing. Include the following in '
            'example root settings.gradle:\n// See $artifactHubDocumentationString for more info.');
      }
      if (!declarativeArtifactRegistryApplied) {
        printError('Include the following in '
            'example root settings.gradle:\n$exampleSettingsArtifactHubString');
      }
    }
    return validArtifactConfiguration;
  }

  /// Validates the top-level build.gradle for an example app (e.g.,
  /// some_package/example/android/build.gradle).
  bool _validateExampleTopLevelBuildGradle(
      RepositoryPackage package, File gradleFile) {
    print('${indentation}Validating '
        '${getRelativePosixPath(gradleFile, from: package.directory)}.');
    final String contents = gradleFile.readAsStringSync();
    final List<String> lines = contents.split('\n');

    // This is tracked as a variable rather than a sequence of &&s so that all
    // failures are reported at once, not just the first one.
    bool succeeded = true;
    if (!_validateJavacLintConfig(package, lines)) {
      succeeded = false;
    }
    if (!_validateKotlinVersion(package, lines)) {
      succeeded = false;
    }
    if (!_validateArtifactHubUsage(package, lines)) {
      succeeded = false;
    }
    return succeeded;
  }

  /// Validates the app-level build.gradle for an example app (e.g.,
  /// some_package/example/android/app/build.gradle).
  bool _validateExampleAppBuildGradle(
      RepositoryPackage package, File gradleFile) {
    print('${indentation}Validating '
        '${getRelativePosixPath(gradleFile, from: package.directory)}.');
    final String contents = gradleFile.readAsStringSync();

    // This is tracked as a variable rather than a sequence of &&s so that all
    // failures are reported at once, not just the first one.
    bool succeeded = true;
    if (!_validateNamespace(package, contents, isExample: true)) {
      succeeded = false;
    }
    return succeeded;
  }

  /// Validates that [gradleContents] sets a namespace, which is required for
  /// compatibility with apps that use AGP 8+.
  bool _validateNamespace(RepositoryPackage package, String gradleContents,
      {required bool isExample}) {
    // Regex to validate that the following namespace definition
    // is found (where the single quotes can be single or double):
    //  - namespace = 'dev.flutter.foo'
    final RegExp nameSpaceRegex =
        RegExp('^\\s*namespace\\s+=\\s*[\'"](.*?)[\'"]', multiLine: true);
    final RegExpMatch? nameSpaceRegexMatch =
        nameSpaceRegex.firstMatch(gradleContents);

    if (nameSpaceRegexMatch == null) {
      const String errorMessage = '''
build.gradle must set a "namespace":

    android {
        namespace = "dev.flutter.foo"
    }

The value must match the "package" attribute in AndroidManifest.xml, if one is
present. For more information, see:
https://developer.android.com/build/publish-library/prep-lib-release#choose-namespace
''';

      printError(
          '$indentation${errorMessage.split('\n').join('\n$indentation')}');
      return false;
    } else {
      return _validateNamespaceMatchesManifest(package,
          isExample: isExample, namespace: nameSpaceRegexMatch.group(1)!);
    }
  }

  /// Validates that the given namespace matches the manifest package of
  /// [package] (if any; a package does not need to be in the manifest in cases
  /// where compatibility with AGP <7 is no longer required).
  ///
  /// Prints an error and returns false if validation fails.
  bool _validateNamespaceMatchesManifest(RepositoryPackage package,
      {required bool isExample, required String namespace}) {
    final RegExp manifestPackageRegex = RegExp(r'package\s*=\s*"(.*?)"');
    final String manifestContents =
        _getMainAndroidManifest(package, isExample: isExample)
            .readAsStringSync();
    final RegExpMatch? packageMatch =
        manifestPackageRegex.firstMatch(manifestContents);
    if (packageMatch != null && namespace != packageMatch.group(1)) {
      final String errorMessage = '''
build.gradle "namespace" must match the "package" attribute in AndroidManifest.xml, if one is present.
  build.gradle namespace: "$namespace"
  AndroidMastifest.xml package: "${packageMatch.group(1)}"
''';
      printError(
          '$indentation${errorMessage.split('\n').join('\n$indentation')}');
      return false;
    }
    return true;
  }

  /// Checks for a source compatibiltiy version, so that it's explicit rather
  /// than using whatever the client's local toolchaing defaults to (which can
  /// lead to compile errors that show up for clients, but not in CI).
  bool _validateCompatibilityVersions(List<String> gradleLines) {
    final bool hasLanguageVersion = gradleLines.any((String line) =>
        line.contains('languageVersion') && !_isCommented(line));
    final bool hasCompabilityVersions = gradleLines.any((String line) =>
            line.contains('sourceCompatibility') && !_isCommented(line)) &&
        // Newer toolchains default targetCompatibility to the same value as
        // sourceCompatibility, but older toolchains require it to be set
        // explicitly. The exact version cutoff (and of which piece of the
        // toolchain; likely AGP) is unknown; for context see
        // https://github.com/flutter/flutter/issues/125482
        gradleLines.any((String line) =>
            line.contains('targetCompatibility') && !_isCommented(line));
    if (!hasLanguageVersion && !hasCompabilityVersions) {
      const String errorMessage = '''
build.gradle must set an explicit Java compatibility version.

This can be done either via "sourceCompatibility"/"targetCompatibility":
    android {
        compileOptions {
            sourceCompatibility = JavaVersion.VERSION_11
            targetCompatibility = JavaVersion.VERSION_11
        }
    }

or "toolchain":
    java {
        toolchain {
            languageVersion = JavaLanguageVersion.of(11)
        }
    }

See:
https://docs.gradle.org/current/userguide/java_plugin.html#toolchain_and_compatibility
for more details.''';

      printError(
          '$indentation${errorMessage.split('\n').join('\n$indentation')}');
      return false;
    }
    return true;
  }

  /// Returns whether the given gradle content is configured to enable all
  /// Gradle-driven lints (those checked by ./gradlew lint) and treat them as
  /// errors.
  bool _validateGradleDrivenLintConfig(
      RepositoryPackage package, List<String> gradleLines) {
    final List<String> gradleBuildContents = package
        .platformDirectory(FlutterPlatform.android)
        .childFile('build.gradle')
        .readAsLinesSync();
    if (!gradleBuildContents.any((String line) =>
            line.contains('checkAllWarnings true') && !_isCommented(line)) ||
        !gradleBuildContents.any((String line) =>
            line.contains('warningsAsErrors true') && !_isCommented(line))) {
      printError('${indentation}This package is not configured to enable all '
          'Gradle-driven lint warnings and treat them as errors. '
          'Please add the following to the lintOptions section of '
          'android/build.gradle:');
      print('''
        checkAllWarnings true
        warningsAsErrors true
''');
      return false;
    }
    return true;
  }

  bool _validateCompileSdkUsage(
      RepositoryPackage package, List<String> gradleLines) {
    final RegExp linePattern = RegExp(r'^\s*compileSdk.*\s+=');
    final RegExp legacySettingPattern = RegExp(r'^\s*compileSdkVersion');
    final String? compileSdkLine = gradleLines
        .firstWhereOrNull((String line) => linePattern.hasMatch(line));

    if (compileSdkLine == null) {
      // Equals regex not found check for method pattern.
      final RegExp compileSpacePattern = RegExp(r'^\s*compileSdk');
      final String? methodAssignmentLine = gradleLines.firstWhereOrNull(
          (String line) => compileSpacePattern.hasMatch(line));
      if (methodAssignmentLine == null) {
        printError('${indentation}No compileSdk or compileSdkVersion found.');
      } else {
        printError(
            '${indentation}No "compileSdk =" found. Please use property assignment.');
      }
      return false;
    }
    if (legacySettingPattern.hasMatch(compileSdkLine)) {
      printError('${indentation}Please replace the deprecated '
          '"compileSdkVersion" setting with the newer "compileSdk"');
      return false;
    }
    if (compileSdkLine.contains('flutter.compileSdkVersion')) {
      final Pubspec pubspec = package.parsePubspec();
      final VersionConstraint? flutterConstraint =
          pubspec.environment['flutter'];
      final Version? minFlutterVersion =
          flutterConstraint != null && flutterConstraint is VersionRange
              ? flutterConstraint.min
              : null;
      if (minFlutterVersion == null) {
        printError('${indentation}Unable to find a Flutter SDK version '
            'constraint. Use of flutter.compileSdkVersion requires a minimum '
            'Flutter version of 3.27');
        return false;
      }
      if (minFlutterVersion < Version(3, 27, 0)) {
        printError('${indentation}Use of flutter.compileSdkVersion requires a '
            'minimum Flutter version of 3.27, but this package currently '
            'supports $minFlutterVersion.\n'
            "${indentation}Please update the package's minimum Flutter SDK "
            'version to at least 3.27.');
        return false;
      }
    } else {
      // Extract compileSdkVersion and check if it is higher than flutter.compileSdkVersion.
      final RegExp numericVersionPattern = RegExp(r'=\s*(\d+)');
      final RegExpMatch? versionMatch =
          numericVersionPattern.firstMatch(compileSdkLine);

      if (versionMatch != null) {
        final int compileSdkVersion = int.parse(versionMatch.group(1)!);
        const int minCompileSdkVersion = 36;

        if (compileSdkVersion < minCompileSdkVersion) {
          printError(
              '${indentation}compileSdk version $compileSdkVersion is too low. '
              'Minimum required version is $minCompileSdkVersion.\n'
              "${indentation}Please update this package's compileSdkVersion to at least "
              '$minCompileSdkVersion or use flutter.compileSdkVersion.');
          return false;
        }
      } else {
        printError('${indentation}Unable to parse compileSdk version number.');
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
  bool _validateJavacLintConfig(
      RepositoryPackage example, List<String> gradleLines) {
    final RepositoryPackage enclosingPackage = example.getEnclosingPackage()!;
    if (!pluginSupportsPlatform(platformAndroid, enclosingPackage,
        requiredMode: PlatformSupport.inline)) {
      return true;
    }
    final String enclosingPackageName = enclosingPackage.directory.basename;

    // The check here is intentionally somewhat loose, to allow for the
    // possibility of variations (e.g., not using Xlint:all in some cases, or
    // passing other arguments).
    if (!(gradleLines.any((String line) =>
            line.contains('project(":$enclosingPackageName")')) &&
        gradleLines.any((String line) =>
            line.contains('options.compilerArgs') &&
            line.contains('-Xlint') &&
            line.contains('-Werror')))) {
      printError('The example '
          '"${getRelativePosixPath(example.directory, from: enclosingPackage.directory)}" '
          'is not configured to treat javac lints and warnings as errors. '
          'Please add the following to its build.gradle:');
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
  bool _validateKotlinVersion(
      RepositoryPackage example, List<String> gradleLines) {
    final RegExp kotlinVersionRegex =
        RegExp(r"ext\.kotlin_version\s*=\s*'([\d.]+)'");
    RegExpMatch? match;
    if (gradleLines.any((String line) {
      match = kotlinVersionRegex.firstMatch(line);
      return match != null;
    })) {
      final Version version = Version.parse(match!.group(1)!);
      if (version < minKotlinVersion) {
        printError('build.gradle sets "ext.kotlin_version" to "$version". The '
            'minimum Kotlin version that can be specified is '
            '$minKotlinVersion, for compatibility with modern dependencies.');
        return false;
      }
    }
    return true;
  }
}
