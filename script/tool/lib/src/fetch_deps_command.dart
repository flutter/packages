// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:file/file.dart';

import 'common/core.dart';
import 'common/gradle.dart';
import 'common/output_utils.dart';
import 'common/package_looping_command.dart';
import 'common/plugin_utils.dart';
import 'common/repository_package.dart';

const int _exitNothingRequested = 3;

/// Download dependencies, both Dart and native.
///
/// Specficially each platform runs:
///   Android: 'gradlew dependencies'.
///   Dart: 'flutter pub get'.
///   iOS/macOS: 'pod install'.
///
/// See https://docs.gradle.org/6.4/userguide/core_dependency_management.html#sec:dependency-mgmt-in-gradle.
class FetchDepsCommand extends PackageLoopingCommand {
  /// Creates an instance of the fetch-deps command.
  FetchDepsCommand(
    super.packagesDir, {
    super.processRunner,
    super.platform,
  }) {
    argParser.addFlag(_dartFlag, defaultsTo: true, help: 'Run "pub get".');
    argParser.addFlag(platformAndroid,
        help: 'Run "gradlew dependencies" for Android plugins.');
    argParser.addFlag(platformIOS, help: 'Run "pod install" for iOS plugins.');
    argParser.addFlag(platformMacOS,
        help: 'Run "pod install" for macOS plugins.');
  }

  static const String _dartFlag = 'dart';

  @override
  final String name = 'fetch-deps';

  @override
  final String description = 'Fetches dependencies for packages';

  @override
  Future<PackageResult> runForPackage(RepositoryPackage package) async {
    bool fetchedDeps = false;
    if (getBoolArg(_dartFlag)) {
      fetchedDeps = true;
      if (!await _fetchDartPackages(package)) {
        // If Dart-level depenendencies fail, fail immediately since the native
        // dependencies won't be useful.
        return PackageResult.fail(<String>['Failed to "pub get".']);
      }
    }

    final Iterable<String> supportedPlatforms = <String>[
      platformAndroid,
      platformIOS,
      platformMacOS,
    ];
    final Iterable<String> targetPlatforms =
        supportedPlatforms.where((String platform) => getBoolArg(platform));

    final List<String> errors = <String>[];
    final List<String> skips = <String>[];
    for (final String platform in targetPlatforms) {
      final PackageResult result;
      switch (platform) {
        case platformAndroid:
          result = await _fetchAndroidDeps(package);
          break;
        case platformIOS:
          result = await _fetchDarwinDeps(package, platformIOS);
          break;
        case platformMacOS:
          result = await _fetchDarwinDeps(package, platformMacOS);
          break;
        default:
          throw UnimplementedError();
      }
      switch (result.state) {
        case RunState.succeeded:
          fetchedDeps = true;
          break;
        case RunState.skipped:
          skips.add(result.details.first);
          break;
        case RunState.failed:
          errors.addAll(result.details);
          break;
        case RunState.excluded:
          throw StateError('Unreachable');
      }
    }

    if (errors.isNotEmpty) {
      return PackageResult.fail(errors);
    }
    if (fetchedDeps) {
      return PackageResult.success();
    }
    if (skips.isNotEmpty) {
      return PackageResult.skip(skips.join(', '));
    }

    printError('At least one type of dependency must be requested');
    throw ToolExit(_exitNothingRequested);
  }

  Future<PackageResult> _fetchAndroidDeps(RepositoryPackage package) async {
    if (!pluginSupportsPlatform(platformAndroid, package,
        requiredMode: PlatformSupport.inline)) {
      return PackageResult.skip(
          'Package does not have native Android dependencies.');
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

      final int exitCode =
          await gradleProject.runCommand('$packageName:dependencies');
      if (exitCode != 0) {
        return PackageResult.fail();
      }
    }

    return PackageResult.success();
  }

  Future<PackageResult> _fetchDarwinDeps(
      RepositoryPackage package, final String platform) async {
    if (!pluginSupportsPlatform(platform, package,
        requiredMode: PlatformSupport.inline)) {
      return PackageResult.skip(
          'Package does not have native $platform dependencies.');
    }

    // Running `pod install` requires `flutter pub get` or `flutter build` to
    // have been run first to create the necessary native build files, so run
    // pub get if it wasn't already run above.
    if (!getBoolArg(_dartFlag)) {
      final int exitCode = await processRunner.runAndStream(
        flutterCommand,
        <String>[flutterCommand, 'pub', 'get'],
        workingDir: package.directory,
      );
      if (exitCode != 0) {
        printError('Unable to prepare native project files.');
        return PackageResult.fail(<String>['Unable to configure project.']);
      }
    }

    for (final RepositoryPackage example in package.getExamples()) {
      final Directory platformDir = example.platformDirectory(
          platform == platformMacOS
              ? FlutterPlatform.macos
              : FlutterPlatform.ios);

      final int exitCode = await processRunner.runAndStream(
        'pod',
        <String>['install'],
        workingDir: platformDir,
      );
      if (exitCode != 0) {
        printError('Unable to "pod install"');
        return PackageResult.fail(<String>['Unable to "pod install"']);
      }
    }

    return PackageResult.success();
  }

  Future<bool> _fetchDartPackages(RepositoryPackage package) async {
    final String command = package.requiresFlutter() ? flutterCommand : 'dart';
    final int exitCode = await processRunner.runAndStream(
        command, <String>['pub', 'get'],
        workingDir: package.directory);
    return exitCode == 0;
  }
}
