// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';

import 'package:check_readiness/check_readiness.dart';
import 'package:path/path.dart' as p;

Future<void> main(List<String> args) async {
  // Locate the repository root by walking up from this script's path.
  var repoRoot = Directory(p.dirname(Platform.script.toFilePath()));
  var rootFound = false;
  while (repoRoot.path != repoRoot.parent.path) {
    if (Directory(p.join(repoRoot.path, 'packages')).existsSync() &&
        Directory(p.join(repoRoot.path, 'script')).existsSync()) {
      rootFound = true;
      break;
    }
    repoRoot = repoRoot.parent;
  }
  if (!rootFound) {
    stderr.writeln(
        'Error: Could not locate repository root. This script must be run inside a valid packages repository.');
    exit(1);
  }
  final String workspaceRoot = repoRoot.path;

  final checker = ReadinessChecker();
  final bool isReady = await checker.checkReadiness(workspaceRoot);
  exitCode = isReady ? 0 : 1;
}
