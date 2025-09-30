// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:file/file.dart';
import 'package:platform/platform.dart';

import 'process_runner.dart';
import 'repository_package.dart';

const String _gradleWrapperWindows = 'gradlew.bat';
const String _gradleWrapperNonWindows = 'gradlew';

/// A utility class for interacting with Gradle projects.
class GradleProject {
  /// Creates an instance that runs commands for [project] with the given
  /// [processRunner].
  GradleProject(
    this.flutterProject, {
    this.processRunner = const ProcessRunner(),
    this.platform = const LocalPlatform(),
  });

  /// The directory of a Flutter project to run Gradle commands in.
  final RepositoryPackage flutterProject;

  /// The [ProcessRunner] used to run commands. Overridable for testing.
  final ProcessRunner processRunner;

  /// The platform that commands are being run on.
  final Platform platform;

  /// The project's 'android' directory.
  Directory get androidDirectory =>
      flutterProject.platformDirectory(FlutterPlatform.android);

  /// The path to the Gradle wrapper file for the project.
  File get gradleWrapper => androidDirectory.childFile(
      platform.isWindows ? _gradleWrapperWindows : _gradleWrapperNonWindows);

  /// Whether or not the project is ready to have Gradle commands run on it
  /// (i.e., whether the `flutter` tool has generated the necessary files).
  bool isConfigured() => gradleWrapper.existsSync();

  /// Runs a `gradlew` command with the given parameters.
  Future<int> runCommand(
    String task, {
    List<String> additionalTasks = const <String>[],
    List<String> arguments = const <String>[],
  }) {
    return processRunner.runAndStream(
      gradleWrapper.path,
      <String>[task, ...additionalTasks, ...arguments],
      workingDir: androidDirectory,
    );
  }
}
