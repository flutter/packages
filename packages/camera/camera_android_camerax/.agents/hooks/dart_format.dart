#!/usr/bin/env dart
// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';
import 'dart:io';

void main() async {
  const logFile = '/tmp/dart_format.log';
  final now = DateTime.now().toIso8601String();
  
  await File(logFile).writeAsString('[$now] dart_format.dart started in ${Directory.current.path}\n', mode: FileMode.append);

  // Check if there are modified .dart files
  final gitResult = await Process.run('git', ['status', '--porcelain'], runInShell: true);
  if (gitResult.exitCode == 0) {
    final stdoutStr = gitResult.stdout as String;
    final hasModifiedDart = stdoutStr.split('\n').any((line) => line.trim().endsWith('.dart'));
    
    if (!hasModifiedDart) {
      await File(logFile).writeAsString('[$now] No modified dart files, exiting\n', mode: FileMode.append);
      stdout.writeln(jsonEncode({}));
      exit(0);
    }
  } else {
     await File(logFile).writeAsString('[$now] Git command failed with exit code ${gitResult.exitCode}\n', mode: FileMode.append);
  }

  await File(logFile).writeAsString('[$now] Running dart format\n', mode: FileMode.append);
  
  final result = await Process.run('dart', ['format', '--output=write', '.'], runInShell: true);
  
  await File(logFile).writeAsString('[$now] dart format finished with exit code ${result.exitCode}\n', mode: FileMode.append);
  await File(logFile).writeAsString(result.stdout as String, mode: FileMode.append);
  await File(logFile).writeAsString(result.stderr as String, mode: FileMode.append);

  stdout.writeln(jsonEncode({}));
}
