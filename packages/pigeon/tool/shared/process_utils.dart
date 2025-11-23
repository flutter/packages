// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io' show Process, ProcessStartMode, stderr, stdout;

Future<int> runProcess(
  String command,
  List<String> arguments, {
  String? workingDirectory,
  bool streamOutput = true,
  bool logFailure = false,
}) async {
  final Process process = await Process.start(
    command,
    arguments,
    workingDirectory: workingDirectory,
    mode: streamOutput
        ? ProcessStartMode.inheritStdio
        : ProcessStartMode.normal,
  );

  if (streamOutput) {
    return process.exitCode;
  }

  final List<int> stdoutBuffer = <int>[];
  final List<int> stderrBuffer = <int>[];
  final Future<void> stdoutFuture = process.stdout.forEach(stdoutBuffer.addAll);
  final Future<void> stderrFuture = process.stderr.forEach(stderrBuffer.addAll);
  final int exitCode = await process.exitCode;
  await Future.wait(<Future<void>>[stdoutFuture, stderrFuture]);

  if (exitCode != 0 && logFailure) {
    // ignore: avoid_print
    print('$command $arguments failed:');
    stdout.add(stdoutBuffer);
    stderr.add(stderrBuffer);
    await Future.wait(<Future<void>>[stdout.flush(), stderr.flush()]);
  }
  return exitCode;
}
