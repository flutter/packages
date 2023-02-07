// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: avoid_print

import 'dart:io' show Directory;

import 'package:process_runner/process_runner.dart';

Future<int> runProcess(String command, List<String> arguments,
    {String? workingDirectory,
    bool streamOutput = true,
    bool logFailure = false}) async {
  final ProcessRunner runner = ProcessRunner();
  final ProcessRunnerResult result = await runner.runProcess(
      <String>[command, ...arguments],
      workingDirectory:
          workingDirectory == null ? null : Directory(workingDirectory),
      failOk: true,
      printOutput: streamOutput);
  if (result.exitCode != 0 && logFailure) {
    print('$command $arguments failed.');
    print('stderr:');
    print(result.stderr);
    print('stdout:');
    print(result.stdout);
  }
  return result.exitCode;
}
