// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: avoid_print

import 'dart:io';
import 'package:args/command_runner.dart';

/// The command that implements the pre-commit githook.
class PreCommitCommand extends Command<bool> {
  /// Creates a [PreCommitCommand].
  PreCommitCommand({
    Future<ProcessResult> Function(
      String executable,
      List<String> arguments, {
      String? workingDirectory,
    })?
    processRunner,
  }) : processRunner = processRunner ?? Process.run;

  /// The process runner injected for testing.
  final Future<ProcessResult> Function(
    String executable,
    List<String> arguments, {
    String? workingDirectory,
  })
  processRunner;

  @override
  final String name = 'pre-commit';

  @override
  final String description = 'Checks to run before a "git commit"';

  @override
  Future<bool> run() async {
    // Find the repo root where the plugin tool is located.
    Directory repoRoot = Directory.current;
    while (repoRoot.path != '/' && !Directory('${repoRoot.path}/.git').existsSync()) {
      repoRoot = repoRoot.parent;
    }

    if (repoRoot.path == '/') {
      print('❌ Could not find .git directory.');
      return false;
    }

    final toolScript = '${repoRoot.path}/script/tool/bin/flutter_plugin_tools.dart';

    print('🔍 Running pre-commit checks on changed packages using flutter_plugin_tools...');
    var hasError = false;

    // Check formatting.
    print('Checking formatting...');
    final ProcessResult formatResult = await processRunner('dart', [
      'run',
      toolScript,
      'format',
      '--run-on-changed-packages',
      '--fail-on-change',
    ], workingDirectory: repoRoot.path);

    if (formatResult.exitCode != 0) {
      print(
        '❌ Formatting issues found. Please run "dart run script/tool/bin/flutter_plugin_tools.dart format --run-on-changed-packages" to fix them.',
      );
      hasError = true;
    } else {
      print('✅ Formatting looks good.');
    }

    // Run static analysis.
    print('Running static analysis...');
    final ProcessResult analyzeResult = await processRunner('dart', [
      'run',
      toolScript,
      'analyze',
      '--run-on-changed-packages',
      '--fatal-infos',
    ], workingDirectory: repoRoot.path);

    if (analyzeResult.exitCode != 0) {
      print('❌ Static analysis errors found. Please fix the errors listed above.');
      hasError = true;
    } else {
      print('✅ Static analysis looks good.');
    }

    return !hasError;
  }
}
