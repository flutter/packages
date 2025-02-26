// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'common/core.dart';
import 'common/gradle.dart';
import 'common/output_utils.dart';
import 'common/package_looping_command.dart';
import 'common/plugin_utils.dart';
import 'common/repository_package.dart';

/// Run 'gradlew lint'.
///
/// See https://developer.android.com/studio/write/lint.
class LintAndroidCommand extends PackageLoopingCommand {
  /// Creates an instance of the linter command.
  LintAndroidCommand(
    super.packagesDir, {
    super.processRunner,
    super.platform,
    super.gitDir,
  });

  @override
  final String name = 'lint-android';

  @override
  final String description = 'Runs "gradlew lint" on Android plugins.\n\n'
      'Requires the examples to have been build at least once before running.';

  @override
  Future<PackageResult> runForPackage(RepositoryPackage package) async {
    if (!pluginSupportsPlatform(platformAndroid, package,
        requiredMode: PlatformSupport.inline)) {
      return PackageResult.skip(
          'Plugin does not have an Android implementation.');
    }

    for (final RepositoryPackage example in package.getExamples()) {
      final GradleProject project = GradleProject(example,
          processRunner: processRunner, platform: platform);

      if (!project.isConfigured()) {
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

      // Only lint one build mode to avoid extra work.
      // Only lint the plugin project itself, to avoid failing due to errors in
      // dependencies.
      //
      // TODO(stuartmorgan): Consider adding an XML parser to read and summarize
      // all results. Currently, only the first three errors will be shown
      // inline, and the rest have to be checked via the CI-uploaded artifact.
      final int exitCode = await project.runCommand('$packageName:lintDebug');
      if (exitCode != 0) {
        return PackageResult.fail();
      }
    }

    return PackageResult.success();
  }
}
