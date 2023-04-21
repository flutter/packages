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
    if (!_validateBuildGradle(package, isExample: isExample)) {
      return PackageResult.fail();
    }
    return PackageResult.success();
  }

  bool _validateBuildGradle(RepositoryPackage package,
      {required bool isExample}) {
    final Directory androidDir =
        package.platformDirectory(FlutterPlatform.android);
    // For apps, the relevant files are in android/app, rather than android/.
    final Directory parentDir =
        isExample ? androidDir.childDirectory('app') : androidDir;
    final File gradleFile = parentDir.childFile('build.gradle');
    print('${indentation}Validating '
        '${getRelativePosixPath(gradleFile, from: package.directory)}.');
    final String contents = gradleFile.readAsStringSync();
    final List<String> lines = contents.split('\n');

    bool succeeded = true;

    // Check for namespace, which is require for compatibility with apps that
    // use AGP 8+.
    final RegExp namespaceRegex =
        RegExp('^\\s*namespace\\s+[\'"](.*?)[\'"]', multiLine: true);
    final RegExpMatch? namespaceMatch = namespaceRegex.firstMatch(contents);
    if (namespaceMatch == null) {
      const String errorMessage = '''
build.gradle must set a "namespace":

    android {
        namespace 'dev.flutter.foo'
    }

The value must match the "package" attribute in AndroidManifest.xml.
''';

      printError(
          '$indentation${errorMessage.split('\n').join('\n$indentation')}');
      succeeded = false;
    } else {
      succeeded = succeeded &&
          _validateNamespace(package,
              isExample: isExample, namespace: namespaceMatch.group(1)!);
    }

    // Additional checks that only apply to the top-level package.
    if (!isExample) {
      // Check for a source compatibiltiy version, so that it's explicit
      // rather than using whatever the client's local toolchaing defaults to
      // (which can lead to compile errors that show up for clients, but not in
      // CI).
      if (!lines.any((String line) =>
              line.contains('languageVersion') &&
              !line.trim().startsWith('//')) &&
          !lines.any((String line) =>
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
        succeeded = false;
      }
    }

    return succeeded;
  }

  // Validate that the given namespace matches the manifest package of [package]
  // (if any; a package does not need to be in the manifest in cases where
  // compatibility with AGP <7.3 is no longer required).
  //
  // Prints an error and returns false if validation fails.
  bool _validateNamespace(RepositoryPackage package,
      {required bool isExample, required String namespace}) {
    final RegExp manifestPackageRegex = RegExp(r'package\s*=\s*"(.*?)"');
    final Directory androidDir =
        package.platformDirectory(FlutterPlatform.android);
    final Directory baseDir =
        isExample ? androidDir.childDirectory('app') : androidDir;
    final String manifestContents = baseDir
        .childDirectory('src')
        .childDirectory('main')
        .childFile('AndroidManifest.xml')
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
}
