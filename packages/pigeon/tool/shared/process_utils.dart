// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:io' show Process, stderr, stdout;

Future<Process> _streamOutput(Future<Process> processFuture) async {
  //print('Waiting for process');
  final Process process = await processFuture;
  print('Waiting for streams');
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
  //print('Starting process');
  final Future<Process> future = Process.start(
    command,
    arguments,
    workingDirectory: workingDirectory,
  );
  final Process process = await (streamOutput ? _streamOutput(future) : future);
  print('Waiting for exit');
  final int exitCode = await process.exitCode;
  //print('Done waiting');
  if (exitCode != 0 && logFailure) {
    print('$command $arguments failed:');
    process.stdout.pipe(stdout);
    process.stderr.pipe(stderr);
  }
  return exitCode;
}
