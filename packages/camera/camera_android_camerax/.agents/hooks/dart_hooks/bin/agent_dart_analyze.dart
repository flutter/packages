#!/usr/bin/env dart
// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';
import 'package:dart_hooks/src/dart_analyze_hook.dart';
import 'package:path/path.dart' as path;

Future<void> main(List<String> args) async {
  if (path.basename(Directory.current.path) != '.agents') {
    stderr.writeln(
      'WARNING: This script is expected to be run from the .agents directory.',
    );
  }
  final String scriptDir = File(Platform.script.toFilePath()).parent.path;
  // Log file placed in the package root directory
  final logFilePath = '$scriptDir/../dart_analyze.log';
  final logFile = File(logFilePath);

  Future<void> logToFile(String message) async {
    final String now = DateTime.now().toIso8601String();
    await logFile.writeAsString('[$now] $message\n', mode: FileMode.append);
  }

  // The hook runs in .agents/ directory, so parent is package root.
  final String packageRoot = Directory.current.parent.path;

  final hook = DartAnalyzeHook(logToFile: logToFile);
  await hook.run(args, Directory.current.path, packageRoot);
}
