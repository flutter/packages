// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:file/file.dart';

import 'common/core.dart';
import 'common/package_looping_command.dart';
import 'common/repository_package.dart';

/// A command to enforce gradle file conventions and best practices.
class GradleCheckCommand extends PackageLoopingCommand {
  /// Creates an instance of the gradle check command.
  GradleCheckCommand(Directory packagesDir) : super(packagesDir);

  @override
  final String name = 'gradle-check';

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
    if (!_validateSourceCompatibilityVersion(lines)) {
      succeeded = false;
    }
    return succeeded;
  }

  /// Validates the top-level build.gradle for an example app (e.g.,
  /// some_package/example/android/build.gradle).
  bool _validateExampleTopLevelBuildGradle(
      RepositoryPackage package, File gradleFile) {
    print('${indentation}Validating '
        '${getRelativePosixPath(gradleFile, from: package.directory)}.');
    // TODO(stuartmorgan): Move the -Xlint validation from lint_android_command
    // to here.
    return true;
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
    final RegExp namespaceRegex =
        RegExp('^\\s*namespace\\s+[\'"](.*?)[\'"]', multiLine: true);
    final RegExpMatch? namespaceMatch =
        namespaceRegex.firstMatch(gradleContents);
    if (namespaceMatch == null) {
      const String errorMessage = '''
build.gradle must set a "namespace":

    android {
        namespace 'dev.flutter.foo'
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
          isExample: isExample, namespace: namespaceMatch.group(1)!);
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
  bool _validateSourceCompatibilityVersion(List<String> gradleLines) {
    if (!gradleLines.any((String line) =>
            line.contains('languageVersion') &&
            !line.trim().startsWith('//')) &&
        !gradleLines.any((String line) =>
            line.contains('sourceCompatibility') &&
            !line.trim().startsWith('//'))) {
      const String errorMessage = '''
build.gradle must set an explicit Java compatibility version.

This can be done either via "sourceCompatibility":
    android {
        compileOptions {
            sourceCompatibility JavaVersion.VERSION_1_8
        }
    }

or "toolchain":
    java {
        toolchain {
            languageVersion = JavaLanguageVersion.of(8)
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
}
