#!/usr/bin/env dart
// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';
import 'dart:io';

/// Runs Dart analysis on all tracked and untracked Dart files in the repository.
///
/// This script is intended to be used as a Jetski hook (e.g., Stop).
/// It gathers files via `git ls-files` and runs `dart analyze --fatal-infos`.
///
/// Supported flags:
///   --source <value>  Specifies the trigger source (e.g., 'hook'). Logs this value.
///                     Defaults to 'MANUAL' if not provided.
Future<void> main(List<String> args) async {
  final scriptDir = File(Platform.script.toFilePath()).parent.path;
  final logFilePath = '$scriptDir/dart_analyze.log';
  final logFile = File(logFilePath);
  final now = DateTime.now().toIso8601String();

  final sourceIdx = args.indexOf('--source');
  final triggerSource = (sourceIdx != -1 && sourceIdx + 1 < args.length)
      ? args[sourceIdx + 1].toUpperCase()
      : 'MANUAL';

  Future<void> log(String message) async {
    await logFile.writeAsString('[$now] $message\n', mode: FileMode.append);
  }

  await log(
    'dart_analyze.dart started in ${Directory.current.path} (Trigger: $triggerSource)',
  );

  try {
    // Get the repo root to resolve paths in monorepo.
    final repoRootResult = await Process.run('git', [
      'rev-parse',
      '--show-toplevel',
    ], runInShell: true);
    if (repoRootResult.exitCode != 0) {
      await log('ERROR: Failed to get git repo root.');
      stdout.writeln(
        jsonEncode({
          'decision': 'continue',
          'reason': 'Failed to get git repo root.',
        }),
      );
      exit(1);
    }
    final repoRoot = (repoRootResult.stdout as String).trim();

    // Get list of all Dart files not ignored by git.
    final ProcessResult gitResult = await Process.run('git', [
      'ls-files',
      '--cached',
      '--others',
      '--exclude-standard',
      '*.dart',
    ], runInShell: true);

    if (gitResult.exitCode != 0) {
      await log(
        'ERROR: Failed to get git files. Exit code ${gitResult.exitCode}',
      );
      await log(gitResult.stderr as String);
      stdout.writeln(
        jsonEncode({
          'decision': 'continue',
          'reason': 'Failed to get git files.',
        }),
      );
      exit(0); // Exit 0 so Jetski captures the stdout JSON.
    }

    final List<String> files = (gitResult.stdout as String)
        .split('\n')
        .where((line) => line.isNotEmpty)
        .map((path) => '$repoRoot/$path')
        .where((path) => File(path).existsSync())
        .toList();

    if (files.isEmpty) {
      await log('No dart files found to analyze.');
      stdout.writeln(jsonEncode({'decision': 'stop'}));
      exit(0);
    }

    await log('Running dart analyze on ${files.length} files...');

    // Run dart analyze on those files.
    final ProcessResult result = await Process.run('dart', [
      'analyze',
      '--fatal-infos',
      ...files,
    ], runInShell: true);

    final int exitCode = result.exitCode;
    final String output = result.stdout as String;
    final String error = result.stderr as String;

    await log('Analysis finished with code $exitCode');

    // If exit code is 0 (no issues), allow the agent to stop.
    if (exitCode == 0) {
      await log('Analysis passed');
      stdout.writeln(jsonEncode({'decision': 'stop'}));
      exit(0);
    }

    // If there are issues, tell Jetski to CONTINUE and provide the reason.
    await log('Analysis failed');

    final reason =
        'Analyzer issues found. Please fix these before finishing:\n\n$output$error';
    stdout.writeln(jsonEncode({'decision': 'continue', 'reason': reason}));
    exit(0); // Exit 0 so Jetski captures the stdout JSON.
  } catch (e, stackTrace) {
    await log('UNHANDLED EXCEPTION: $e');
    await log(stackTrace.toString());
    stdout.writeln(
      jsonEncode({
        'decision': 'continue',
        'reason': 'Unhandled exception in dart_analyze hook.',
      }),
    );
    exit(1);
  }
}
