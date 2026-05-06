#!/usr/bin/env dart
// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';
import 'dart:io';

/// Formats modified Dart files in the repository.
///
/// This script is intended to be used as a Jetski hook (e.g., PostToolUse).
/// It detects modified files via `git status` and runs `dart format` on them.
///
/// Supported flags:
///   --source <value>  Specifies the trigger source (e.g., 'hook'). Logs this value.
///                     Defaults to 'MANUAL' if not provided.
Future<void> main(List<String> args) async {
  // Resolve the log file relative to the script location to avoid /tmp pollution.
  // This assumes the script is in .agents/hooks/.
  final scriptDir = File(Platform.script.toFilePath()).parent.path;
  final logFilePath = '$scriptDir/dart_format.log';
  final logFile = File(logFilePath);

  final now = DateTime.now().toIso8601String();

  Future<void> log(String message) async {
    await logFile.writeAsString('[$now] $message\n', mode: FileMode.append);
  }

  void emitEmptyResult() {
    stdout.writeln(jsonEncode({}));
  }

  final sourceIdx = args.indexOf('--source');
  final triggerSource = (sourceIdx != -1 && sourceIdx + 1 < args.length)
      ? args[sourceIdx + 1].toUpperCase()
      : 'MANUAL';
  await log(
    'dart_format.dart started in ${Directory.current.path} (Trigger: $triggerSource)',
  );

  try {
    // Get the repo root to resolve paths in monorepo.
    final repoRootResult = await Process.run('git', [
      'rev-parse',
      '--show-toplevel',
    ], runInShell: true);
    if (repoRootResult.exitCode != 0) {
      await log('ERROR: Failed to get git repo root.');
      emitEmptyResult();
      exit(1);
    }
    final repoRoot = (repoRootResult.stdout as String).trim();

    // 1. Check if there are modified .dart files.
    final gitResult = await Process.run('git', [
      'status',
      '--porcelain',
    ], runInShell: true);

    if (gitResult.exitCode != 0) {
      await log(
        'ERROR: git status failed with exit code ${gitResult.exitCode}',
      );
      await log(gitResult.stderr as String);
      // Exit with failure so the hook caller knows something went wrong.
      emitEmptyResult();
      exit(1);
    }

    final stdoutStr = gitResult.stdout as String;
    final modifiedDartFiles = stdoutStr
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty && line.endsWith('.dart'))
        .map((line) {
          // git status --porcelain output: "M  path/to/file.dart".
          final parts = line.split(RegExp(r'\s+'));
          return parts.length > 1 ? parts.last : '';
        })
        .map((path) => '$repoRoot/$path')
        .where((path) => path.isNotEmpty && File(path).existsSync())
        .toList();

    if (modifiedDartFiles.isEmpty) {
      await log('No modified dart files, exiting.');
      emitEmptyResult();
      exit(0);
    }

    await log('Running dart format on: ${modifiedDartFiles.join(', ')}');

    // 2. Run dart format ONLY on the modified files.
    final result = await Process.run('dart', [
      'format',
      '--output=write',
      ...modifiedDartFiles,
    ], runInShell: true);

    await log('dart format finished with exit code ${result.exitCode}');
    await log('STDOUT:\n${result.stdout}');
    await log('STDERR:\n${result.stderr}');

    if (result.exitCode != 0) {
      // Propagate the failure to the caller.
      emitEmptyResult();
      exit(result.exitCode);
    }

    emitEmptyResult();
    exit(0);
  } catch (e, stackTrace) {
    await log('UNHANDLED EXCEPTION: $e');
    await log(stackTrace.toString());
    emitEmptyResult();
    exit(1);
  }
}
