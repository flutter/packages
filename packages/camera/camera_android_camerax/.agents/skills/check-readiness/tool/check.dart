// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';

import 'package:check_readiness/check_readiness.dart';
import 'package:path/path.dart' as p;

/// Resolves the package root directory from the script URI.
Directory findPackageDir(Uri scriptUri) {
  final scriptDir = Directory(p.dirname(scriptUri.toFilePath()));
  // The script is at: .agents/skills/check-readiness/tool/check.dart
  // Going up 4 levels to get the camera_android_camerax package root.
  return scriptDir.parent.parent.parent.parent;
}

Future<void> main(List<String> args) async {
  final Directory packageDir = findPackageDir(Platform.script);
  final String packageRoot = packageDir.path;

  final checker = ReadinessChecker();
  final bool isReady = await checker.checkReadiness(packageRoot);
  exitCode = isReady ? 0 : 1;
}
