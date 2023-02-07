// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io' show Process, stderr, stdout;

Future<Process> _streamOutput(Future<Process> processFuture) async {
  final Process process = await processFuture;
  await Future.wait(<Future<Object?>>[
    stdout.addStream(process.stdout),
    stderr.addStream(process.stderr),
  ]);
  return process;
}

Future<int> runProcess(String command, List<String> arguments,
    {String? workingDirectory,
    bool streamOutput = true,
    bool logFailure = false}) async {
  final Future<Process> future = Process.start(
    command,
    arguments,
    workingDirectory: workingDirectory,
  );
  final Process process = await (streamOutput ? _streamOutput(future) : future);
  final int exitCode = await process.exitCode;
  if (exitCode != 0 && logFailure) {
    // ignore: avoid_print
    print('$command $arguments failed:');
    process.stdout.pipe(stdout);
    process.stderr.pipe(stderr);
  }
  return exitCode;
}
