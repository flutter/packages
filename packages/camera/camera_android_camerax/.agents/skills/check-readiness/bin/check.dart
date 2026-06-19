// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';

import 'package:check_readiness/check_readiness.dart';
import 'package:path/path.dart' as p;

Future<void> main(List<String> args) async {
  // Since this tool is executed via `dart run` from the package root,
  // the current directory is the workspace root.
  final String workspaceRoot = Directory.current.path;

  final checker = ReadinessChecker();
  final bool isReady = await checker.checkReadiness(workspaceRoot);
  exitCode = isReady ? 0 : 1;
}
