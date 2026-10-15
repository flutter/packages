// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:ffi' show Abi;
import 'dart:io';

import 'package:cli_util/cli_util.dart' as cli_util;
import 'package:path/path.dart' as p;

/// Returns the engine-artifact subpath (`<platform-dir>/<file>`) for [abi],
/// or `null` if the host is unsupported.
String? engineArtifactSubpath({
  required String windowsFile,
  required String macOSFile,
  required String linuxFile,
  required Abi abi,
}) {
  return switch (abi) {
    Abi.windowsX64 || Abi.windowsArm64 => 'windows-x64/$windowsFile',
    Abi.macosX64 || Abi.macosArm64 => 'darwin-x64/$macOSFile',
    Abi.linuxX64 => 'linux-x64/$linuxFile',
    Abi.linuxArm64 => 'linux-arm64/$linuxFile',
    _ => null,
  };
}

/// Resolves the Flutter artifact cache root directory (`<flutter>/bin/cache`),
/// or `null` if it cannot be located.
///
/// Checks [resolvedExecutable] (defaulting to [Platform.resolvedExecutable])
/// when running under `flutter_tester`, and otherwise uses `package:cli_util`'s
/// [cli_util.sdkPath] so standalone AOT-compiled executables (`dart install` /
/// `dart compile exe`) can locate the Flutter artifact cache.
Directory? resolveFlutterCacheRoot({String? resolvedExecutable, String? dartSdkPath}) {
  final String executable = resolvedExecutable ?? Platform.resolvedExecutable;
  if (executable.contains('flutter_tester')) {
    return File(executable).parent.parent.parent.parent;
  }

  final String? sdk = dartSdkPath ?? cli_util.sdkPath;
  if (sdk != null) {
    final Directory candidate = Directory(sdk).parent;
    if (_hasEngineArtifacts(candidate) || p.basename(candidate.path) == 'cache') {
      return candidate;
    }
  }

  return null;
}

bool _hasEngineArtifacts(Directory cacheRoot) {
  return Directory(p.join(cacheRoot.path, 'artifacts', 'engine')).existsSync();
}
