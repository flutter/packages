// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:meta/meta.dart';

import 'file_system.dart';
import 'logger.dart';

/// Emum for each officially supported platform.
enum SupportedPlatform {
  android,
  ios,
  linux,
  macos,
  web,
  windows,
  fuchsia,
}

class FlutterProjectFactory {
  FlutterProjectFactory();

  @visibleForTesting
  final Map<String, FlutterProject> projects = <String, FlutterProject>{};

  /// Returns a [FlutterProject] view of the given directory or a ToolExit error,
  /// if `pubspec.yaml` or `example/pubspec.yaml` is invalid.
  FlutterProject fromDirectory(Directory directory) {
    return projects.putIfAbsent(directory.path, () {
      return FlutterProject(directory);
    });
  }
}

/// Represents the contents of a Flutter project at the specified [directory].
class FlutterProject {
  FlutterProject(this.directory);

  /// Returns a [FlutterProject] view of the current directory or a ToolExit error,
  /// if `pubspec.yaml` or `example/pubspec.yaml` is invalid.
  static FlutterProject current(FileSystem fs) =>
      FlutterProject(fs.currentDirectory);

  /// Create a [FlutterProject] and bypass the project caching.
  @visibleForTesting
  static FlutterProject fromDirectoryTest(Directory directory,
      [Logger? logger]) {
    logger ??= BufferLogger.test();
    return FlutterProject(directory);
  }

  Directory directory;

  /// The `pubspec.yaml` file of this project.
  File get pubspecFile => directory.childFile('pubspec.yaml');

  /// The `.metadata` file of this project.
  File get metadataFile => directory.childFile('.metadata');

  /// Returns a list of platform names that are supported by the project.
  List<SupportedPlatform> getSupportedPlatforms() {
    final List<SupportedPlatform> platforms = <SupportedPlatform>[];
    if (directory.childDirectory('android').existsSync()) {
      platforms.add(SupportedPlatform.android);
    }
    if (directory.childDirectory('ios').existsSync()) {
      platforms.add(SupportedPlatform.ios);
    }
    if (directory.childDirectory('web').existsSync()) {
      platforms.add(SupportedPlatform.web);
    }
    if (directory.childDirectory('macos').existsSync()) {
      platforms.add(SupportedPlatform.macos);
    }
    if (directory.childDirectory('linux').existsSync()) {
      platforms.add(SupportedPlatform.linux);
    }
    if (directory.childDirectory('windows').existsSync()) {
      platforms.add(SupportedPlatform.windows);
    }
    if (directory.childDirectory('fuchsia').existsSync()) {
      platforms.add(SupportedPlatform.fuchsia);
    }
    return platforms;
  }
}
