// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';

import 'package:check_readiness/check_readiness.dart';
import 'package:path/path.dart' as p;

Future<void> main(List<String> args) async {
  // Determine the workspace root. Assuming bin/check.dart is located in:
  // packages/camera/camera_android_camerax/.agents/skills/check-readiness/bin/check.dart
  // We need to point to packages/camera/camera_android_camerax/
  final String currentPath = p.dirname(Platform.script.toFilePath());
  final String workspaceRoot = p.normalize(p.join(currentPath, '..', '..', '..', '..'));

  final checker = ReadinessChecker();
  final bool isReady = await checker.checkReadiness(workspaceRoot);
  exitCode = isReady ? 0 : 1;
}
