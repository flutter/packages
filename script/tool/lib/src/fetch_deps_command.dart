// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.


import 'common/core.dart';
import 'common/gradle.dart';
import 'common/output_utils.dart';
import 'common/package_looping_command.dart';
import 'common/plugin_utils.dart';
import 'common/repository_package.dart';

/// Download dependencies for the following platforms {android}.
///
/// Specficially each platform runs:
///   Android: 'gradlew dependencies'.
///   Dart: TBD (flutter/flutter/issues/130279)
///   iOS: TBD (flutter/flutter/issues/130280)
///
/// See https://docs.gradle.org/6.4/userguide/core_dependency_management.html#sec:dependency-mgmt-in-gradle.
class FetchDepsCommand extends PackageLoopingCommand {
  /// Creates an instance of the fetch-deps command.
  FetchDepsCommand(
    super.packagesDir, {
    super.processRunner,
    super.platform,
  });

  @override
  final String name = 'fetch-deps';

  @override
  final String description = 'Fetches dependencies for plugins.\n'
      'Runs "gradlew dependencies" on Android plugins.\n'
      'Dart see flutter/flutter/issues/130279\n'
      'iOS plugins see flutter/flutter/issues/130280\n'
      '\n'
      'Requires the examples to have been built at least once before running.';

  @override
  Future<PackageResult> runForPackage(RepositoryPackage package) async {
    if (!pluginSupportsPlatform(platformAndroid, package,
        requiredMode: PlatformSupport.inline)) {
      return PackageResult.skip(
          'Plugin does not have an Android implementation.');
    }

    for (final RepositoryPackage example in package.getExamples()) {
      final GradleProject gradleProject = GradleProject(example,
          processRunner: processRunner, platform: platform);

      if (!gradleProject.isConfigured()) {
        final int exitCode = await processRunner.runAndStream(
          flutterCommand,
          <String>['build', 'apk', '--config-only'],
          workingDir: example.directory,
        );
        if (exitCode != 0) {
          printError('Unable to configure Gradle project.');
          return PackageResult.fail(<String>['Unable to configure Gradle.']);
        }
      }

      final String packageName = package.directory.basename;

      final int exitCode = await gradleProject.runCommand('$packageName:dependencies');
      if (exitCode != 0) {
        return PackageResult.fail();
      }
    }

    return PackageResult.success();
  }
}
