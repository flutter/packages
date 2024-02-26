// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io' show Process, ProcessStartMode, stderr, stdout;

Future<int> runProcess(String command, List<String> arguments,
    {String? workingDirectory,
    bool streamOutput = true,
    bool logFailure = false}) async {
  final Process process = await Process.start(
    command,
    arguments,
    workingDirectory: workingDirectory,
    mode:
        streamOutput ? ProcessStartMode.inheritStdio : ProcessStartMode.normal,
  );
  final int exitCode = await process.exitCode;
  if (exitCode != 0 && logFailure) {
    // ignore: avoid_print
    print('$command $arguments failed:');
    await Future.wait(<Future<void>>[
      process.stdout.pipe(stdout),
      process.stderr.pipe(stderr),
    ]);
  }
  return exitCode;
}
