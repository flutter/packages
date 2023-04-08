// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:file/file.dart';
import 'package:platform/platform.dart';

import 'common/core.dart';
import 'common/gradle.dart';
import 'common/package_looping_command.dart';
import 'common/plugin_utils.dart';
import 'common/process_runner.dart';
import 'common/repository_package.dart';

/// Run 'gradlew lint'.
///
/// See https://developer.android.com/studio/write/lint.
class LintAndroidCommand extends PackageLoopingCommand {
  /// Creates an instance of the linter command.
  LintAndroidCommand(
    Directory packagesDir, {
    ProcessRunner processRunner = const ProcessRunner(),
    Platform platform = const LocalPlatform(),
  }) : super(packagesDir, processRunner: processRunner, platform: platform);

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

    bool failed = false;

    // Ensure that the plugin has a strict Gradle-driven lint configuration, so
    // that this test actually catches most issues.
    if (!_mainGradleHasLintConfig(package)) {
      failed = true;
      printError('This plugin is not configured to enable all Gradle-driven '
          'lint warnings and treat them as errors. '
          'Please add the following to the lintOptions section of '
          'android/build.gradle:');
      print('''
        checkAllWarnings true
        warningsAsErrors true
''');
    }

    for (final RepositoryPackage example in package.getExamples()) {
      final GradleProject project = GradleProject(example,
          processRunner: processRunner, platform: platform);

      if (!project.isConfigured()) {
        // TODO(stuartmorgan): Replace this with a --config-only build once
        // that's available on stable.
        return PackageResult.fail(<String>['Build examples before linting']);
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
        failed = true;
      }

      // In addition to running the Gradle-driven lint step, also ensure that
      // the example project is configured to build with javac lints enabled and
      // treated as errors.
      if (!_exampleGradleHasJavacLintConfig(example, packageName)) {
        failed = true;
        printError('The example '
            '"${getRelativePosixPath(example.directory, from: package.directory)}" '
            'is not configured to treat javac lints and warnings as errors. '
            'Please add the following to its build.gradle:');
        print('''
gradle.projectsEvaluated {
    project(":${package.directory.basename}") {
        tasks.withType(JavaCompile) {
            options.compilerArgs << "-Xlint:all" << "-Werror"
        }
    }
}
''');
      }
    }

    return failed ? PackageResult.fail() : PackageResult.success();
  }

  /// Returns whether the plugin project is configured to enable all Gradle
  /// lints and treat them as errors.
  bool _mainGradleHasLintConfig(RepositoryPackage package) {
    final List<String> gradleBuildContents = package
        .platformDirectory(FlutterPlatform.android)
        .childFile('build.gradle')
        .readAsLinesSync();
    return gradleBuildContents
            .any((String line) => line.contains('checkAllWarnings true')) &&
        gradleBuildContents
            .any((String line) => line.contains('warningsAsErrors true'));
  }

  /// Returns whether the example project is configured to build with javac
  /// lints enabled and treated as errors.
  bool _exampleGradleHasJavacLintConfig(
      RepositoryPackage example, String pluginPackageName) {
    final List<String> gradleBuildContents = example
        .platformDirectory(FlutterPlatform.android)
        .childFile('build.gradle')
        .readAsLinesSync();
    // The check here is intentionally somewhat loose, to allow for the
    // possibility of variations (e.g., not using Xlint:all in some cases, or
    // passing other arguments).
    return gradleBuildContents.any(
            (String line) => line.contains('project(":$pluginPackageName")')) &&
        gradleBuildContents.any((String line) =>
            line.contains('options.compilerArgs') &&
            line.contains('-Xlint') &&
            line.contains('-Werror'));
  }
}
