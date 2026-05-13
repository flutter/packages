// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: avoid_print

// Runs `dart test -p chrome` in the root of the cross_file package.
//
// Called from the custom-tests CI action.
//
// usage: dart run tool/run_tests.dart
// (needs a `chrome` executable in $PATH, or a tweak to dart_test.yaml)
import 'dart:async';
import 'dart:io';
import 'package:path/path.dart' as p;

Future<void> main(List<String> args) async {
  if (!Platform.isLinux) {
    // The test was migrated from a Linux-only task, so this preserves behavior.
    // If desired, it can be enabled for other platforms in the future.
    print('Skipping for non-Linux host');
    exit(0);
  }

  final Directory packageDir = Directory(
    p.dirname(Platform.script.path),
  ).parent;
  final String testingAppDirPath = p.join(
    packageDir.path,
    'testing',
    'test_app',
  );

  // Fetch the test app's dependencies.
  int status = await _runProcess('flutter', <String>[
    'pub',
    'get',
  ], workingDirectory: testingAppDirPath);
  if (status != 0) {
    exit(status);
  }

  // Run the tests.
  status = await _runProcess('flutter', <String>[
    'test',
    'testing',
  ], workingDirectory: packageDir.path);

  exit(status);
}

Future<Process> _streamOutput(Future<Process> processFuture) async {
  final Process process = await processFuture;
  await Future.wait(<Future<void>>[
    stdout.addStream(process.stdout),
    stderr.addStream(process.stderr),
  ]);
  return process;
}

Future<int> _runProcess(
  String command,
  List<String> arguments, {
  String? workingDirectory,
}) async {
  final Process process = await _streamOutput(
    Process.start(command, arguments, workingDirectory: workingDirectory),
  );
  return process.exitCode;
}
