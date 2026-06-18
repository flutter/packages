// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: avoid_print

import 'dart:io';
import 'package:args/command_runner.dart';

/// The command that implements the pre-commit githook
class PreCommitCommand extends Command<bool> {
  @override
  final String name = 'pre-commit';

  @override
  final String description = 'Checks to run before a "git commit"';

  @override
  Future<bool> run() async {
    // Find changed Dart files.
    final ProcessResult diffResult = await Process.run('git', [
      'diff',
      '--cached',
      '--name-only',
      '--diff-filter=ACM',
    ]);
    if (diffResult.exitCode != 0) {
      print('Failed to get staged files.');
      exit(1);
    }

    final List<String> stagedDartFiles = (diffResult.stdout as String)
        .split('\n')
        .map((file) => file.trim())
        .where((file) => file.endsWith('.dart'))
        .toList();

    if (stagedDartFiles.isEmpty) {
      // No Dart files are being committed.
      return true;
    }

    print('🔍 Running pre-commit checks on staged Dart files...');
    var hasError = false;

    // Check formatting.
    print('Checking formatting...');
    final ProcessResult formatResult = await Process.run('dart', [
      'format',
      '--output=none',
      '--set-exit-if-changed',
      ...stagedDartFiles,
    ]);

    if (formatResult.exitCode != 0) {
      print('❌ Formatting issues found in the following files:');
      print((formatResult.stdout as String).trim());
      print(
        '👉 Please run "dart format" on these files to fix them.',
      );
      hasError = true;
    } else {
      print('✅ Formatting looks good.');
    }

    // Run static analysis.
    print('Running static analysis...');
    final ProcessResult analyzeResult = await Process.run('dart', [
      'analyze',
      '--fatal-infos',
      ...stagedDartFiles,
    ]);

    if (analyzeResult.exitCode != 0) {
      print('❌ Static analysis errors found:');
      print((analyzeResult.stdout as String).trim());
      hasError = true;
    } else {
      print('✅ Static analysis looks good.');
    }

    return !hasError;
  }
}
