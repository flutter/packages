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
    // Currently the only check is not relevant to examples; checks that apply
    // to both plugins and examples should go above here.
    if (!isExample) {
      print('${indentation}Validating android/build.gradle.');
      final String contents = package
          .platformDirectory(FlutterPlatform.android)
          .childFile('build.gradle')
          .readAsStringSync();
      final List<String> lines = contents.split('\n');

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
        return false;
      }
    }

    return true;
  }
}
