// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: avoid_print

import 'dart:io';
import 'package:args/command_runner.dart';
import 'package:path/path.dart' as p;

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
    final ProcessResult rootResult = await processRunner('git', <String>[
      'rev-parse',
      '--show-toplevel',
    ], workingDirectory: Directory.current.path);

    if (rootResult.exitCode != 0) {
      print('❌ Could not find git repository.');
      return false;
    }

    final repoRoot = Directory((rootResult.stdout as String).trim());

    // Check if there are any staged changes first to exit early.
    final ProcessResult diffResult = await processRunner('git', <String>[
      'diff',
      '--cached',
      '--name-only',
    ], workingDirectory: repoRoot.path);

    if (diffResult.exitCode == 0 && (diffResult.stdout as String).trim().isEmpty) {
      print('✅ No staged changes to check.');
      return true;
    }

    final String toolScript = p.join(
      repoRoot.path,
      'script',
      'tool',
      'bin',
      'flutter_plugin_tools.dart',
    );

    print('Checking staged changes...');

    // Run format first so analyze runs on the final formatted code.
    final ProcessResult formatResult = await processRunner('dart', [
      'run',
      toolScript,
      'format',
      '--run-on-staged-packages',
      '--fail-on-change',
    ], workingDirectory: repoRoot.path);

    var hasError = false;

    // Report formatting results.
    if (formatResult.exitCode != 0) {
      if (formatResult.stdout.toString().isNotEmpty) {
        print(formatResult.stdout);
      }
      if (formatResult.stderr.toString().isNotEmpty) {
        print(formatResult.stderr);
      }
      print(
        'Formatting issues found. Please run "dart run script/tool/bin/flutter_plugin_tools.dart format --run-on-staged-packages" to fix them.',
      );
      hasError = true;
    } else {
      print('Formatting looks good!');
    }

    // Only run static analysis if formatting passed, to ensure we analyze the final formatted code.
    if (!hasError) {
      final ProcessResult analyzeResult = await processRunner('dart', [
        'run',
        toolScript,
        'analyze',
        '--run-on-staged-packages',
        '--dart',
      ], workingDirectory: repoRoot.path);

      // Report static analysis results.
      if (analyzeResult.exitCode != 0) {
        if (analyzeResult.stdout.toString().isNotEmpty) {
          print(analyzeResult.stdout);
        }
        if (analyzeResult.stderr.toString().isNotEmpty) {
          print(analyzeResult.stderr);
        }
        print('Static analysis errors found.');
        hasError = true;
      } else {
        print('Static analysis looks good!');
      }
    }

    if (hasError) {
      print('Static analysis failed. Please fix the errors listed above.');
    }

    return !hasError;
  }
}
