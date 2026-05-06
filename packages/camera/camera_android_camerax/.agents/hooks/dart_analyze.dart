#!/usr/bin/env dart
// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';
import 'dart:io';

void main() async {
  const logFile = '/tmp/dart_analyze.log';
  final now = DateTime.now();
  
  // Log start
  await File(logFile).writeAsString(
    '[$now] dart_analyze.dart started in ${Directory.current.path}\n',
    mode: FileMode.append,
  );

  // Get list of all Dart files not ignored by git
  final ProcessResult gitResult = await Process.run(
    'git',
    ['ls-files', '--cached', '--others', '--exclude-standard', '*.dart'],
    runInShell: true,
  );

  if (gitResult.exitCode != 0) {
    await File(logFile).writeAsString(
      '[$now] Failed to get git files. Exit code ${gitResult.exitCode}\n',
      mode: FileMode.append,
    );
    stdout.writeln(jsonEncode({'decision': 'continue', 'reason': 'Failed to get git files.'}));
    exit(0);
  }

  final List<String> files = (gitResult.stdout as String)
      .split('\n')
      .where((line) => line.isNotEmpty)
      .toList();

  // Run dart analyze on those files
  final ProcessResult result = await Process.run(
    'dart',
    ['analyze', '--fatal-infos', ...files],
    runInShell: true,
  );

  final int exitCode = result.exitCode;
  // Ignored due to conflict between specify_nonobvious_local_variable_types and omit_obvious_local_variable_types.
  // ignore: omit_obvious_local_variable_types
  final String output = result.stdout as String;
  // Ignored due to conflict between specify_nonobvious_local_variable_types and omit_obvious_local_variable_types.
  // ignore: omit_obvious_local_variable_types
  final String error = result.stderr as String;

  await File(logFile).writeAsString(
    '[$now] Analysis finished with code $exitCode\n',
    mode: FileMode.append,
  );

  // If exit code is 0 (no issues), allow the agent to stop
  if (exitCode == 0) {
    await File(logFile).writeAsString(
      '[$now] Analysis passed\n',
      mode: FileMode.append,
    );
    stdout.writeln(jsonEncode({'decision': 'stop'}));
    exit(0);
  }

  // If there are issues, tell Jetski to CONTINUE and provide the reason
  await File(logFile).writeAsString(
    '[$now] Analysis failed\n',
    mode: FileMode.append,
  );

  final reason =
      'Analyzer issues found. Please fix these before finishing:\n\n$output$error';

  stdout.writeln(jsonEncode({'decision': 'continue', 'reason': reason}));
  exit(0); // Exit 0 so Jetski captures the stdout JSON
}
