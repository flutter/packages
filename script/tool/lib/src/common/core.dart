// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:file/file.dart';
import 'package:platform/platform.dart';
import 'package:pub_semver/pub_semver.dart';

/// The signature for a print handler for commands that allow overriding the
/// print destination.
typedef Print = void Function(Object? object);

/// Key for APK (Android) platform.
const String platformAndroid = 'android';

/// Alias for APK (Android) platform.
const String platformAndroidAlias = 'apk';

/// Key for IPA (iOS) platform.
const String platformIOS = 'ios';

/// Key for linux platform.
const String platformLinux = 'linux';

/// Key for macos platform.
const String platformMacOS = 'macos';

/// Key for Web platform.
const String platformWeb = 'web';

/// Key for windows platform.
const String platformWindows = 'windows';

/// Key for enable experiment.
const String kEnableExperiment = 'enable-experiment';

/// A String to add to comments on temporarily-added changes that should not
/// land (e.g., dependency overrides in federated plugin combination PRs).
const String kDoNotLandWarning = 'DO NOT MERGE';

/// Key for enabling web WASM compilation
const String kWebWasmFlag = 'wasm';

/// Target platforms supported by Flutter.
// ignore: public_member_api_docs
enum FlutterPlatform { android, ios, linux, macos, web, windows }

const Map<String, FlutterPlatform> _platformByName = <String, FlutterPlatform>{
  platformAndroid: FlutterPlatform.android,
  platformIOS: FlutterPlatform.ios,
  platformLinux: FlutterPlatform.linux,
  platformMacOS: FlutterPlatform.macos,
  platformWeb: FlutterPlatform.web,
  platformWindows: FlutterPlatform.windows,
};

/// Maps from a platform name (e.g., flag or platform directory) to the
/// corresponding platform enum.
FlutterPlatform getPlatformByName(String name) {
  final FlutterPlatform? platform = _platformByName[name];
  if (platform == null) {
    throw ArgumentError('Invalid platform: $name');
  }
  return platform;
}

// Flutter->Dart SDK version mapping. Any time a command fails to look up a
// corresponding version, this map should be updated.
final Map<Version, Version> _dartSdkForFlutterSdk = <Version, Version>{
  Version(3, 0, 0): Version(2, 17, 0),
  Version(3, 0, 5): Version(2, 17, 6),
  Version(3, 3, 0): Version(2, 18, 0),
  Version(3, 3, 10): Version(2, 18, 6),
  Version(3, 7, 0): Version(2, 19, 0),
  Version(3, 7, 12): Version(2, 19, 6),
  Version(3, 10, 0): Version(3, 0, 0),
  Version(3, 10, 6): Version(3, 0, 6),
  Version(3, 13, 0): Version(3, 1, 0),
  Version(3, 13, 9): Version(3, 1, 5),
  Version(3, 16, 0): Version(3, 2, 0),
  Version(3, 16, 6): Version(3, 2, 3),
  Version(3, 16, 9): Version(3, 2, 6),
  Version(3, 19, 0): Version(3, 3, 0),
  Version(3, 19, 6): Version(3, 3, 4),
  Version(3, 22, 0): Version(3, 4, 0),
  Version(3, 22, 3): Version(3, 4, 4),
  Version(3, 24, 0): Version(3, 5, 0),
  Version(3, 24, 5): Version(3, 5, 4),
  Version(3, 27, 0): Version(3, 6, 0),
  Version(3, 27, 4): Version(3, 6, 2),
  Version(3, 29, 0): Version(3, 7, 0),
  Version(3, 29, 3): Version(3, 7, 2),
  Version(3, 32, 0): Version(3, 8, 0),
  Version(3, 32, 8): Version(3, 8, 1),
  Version(3, 35, 0): Version(3, 9, 0),
};

/// Returns the version of the Dart SDK that shipped with the given Flutter
/// SDK.
Version? getDartSdkForFlutterSdk(Version flutterVersion) =>
    _dartSdkForFlutterSdk[flutterVersion];

/// Returns whether the given directory is a Dart package.
bool isPackage(FileSystemEntity entity) {
  if (entity is! Directory) {
    return false;
  }
  // According to
  // https://dart.dev/guides/libraries/create-packages#what-makes-a-library-package
  // a package must also have a `lib/` directory, but in practice that's not
  // always true. Some special cases (espresso, flutter_template_images, etc.)
  // don't have any source, so this deliberately doesn't check that there's a
  // lib directory.
  return entity.childFile('pubspec.yaml').existsSync();
}

/// Error thrown when a command needs to exit with a non-zero exit code.
///
/// While there is no specific definition of the meaning of different non-zero
/// exit codes for this tool, commands should follow the general convention:
///   1: The command ran correctly, but found errors.
///   2: The command failed to run because the arguments were invalid.
///  >2: The command failed to run correctly for some other reason. Ideally,
///      each such failure should have a unique exit code within the context of
///      that command.
class ToolExit extends Error {
  /// Creates a tool exit with the given [exitCode].
  ToolExit(this.exitCode);

  /// The code that the process should exit with.
  final int exitCode;
}

/// A exit code for [ToolExit] for a successful run that found errors.
const int exitCommandFoundErrors = 1;

/// A exit code for [ToolExit] for a failure to run due to invalid arguments.
const int exitInvalidArguments = 2;

/// The directory to which to write logs and other artifacts, if set in CI.
Directory? ciLogsDirectory(Platform platform, FileSystem fileSystem) {
  final String? logsDirectoryPath = platform.environment['FLUTTER_LOGS_DIR'];
  Directory? logsDirectory;
  if (logsDirectoryPath != null) {
    logsDirectory = fileSystem.directory(logsDirectoryPath);
  }
  return logsDirectory;
}
