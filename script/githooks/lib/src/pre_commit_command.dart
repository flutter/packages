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

    final String toolScript = p.join(
      repoRoot.path,
      'script',
      'tool',
      'bin',
      'flutter_plugin_tools.dart',
    );

    var hasError = false;

    // Check formatting.
    stdout.write('Checking formatting...');
    final ProcessResult formatResult = await processRunner('dart', [
      'run',
      toolScript,
      'format',
      '--run-on-staged-packages',
      '--fail-on-change',
    ], workingDirectory: repoRoot.path);

    if (formatResult.exitCode != 0) {
      stdout.write(stdout.supportsAnsiEscapes ? '\x1B[2K\r' : '\n');
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
      stdout.write(
        stdout.supportsAnsiEscapes
            ? '\x1B[2K\r✅ Formatting looks good.\n'
            : '✅ Formatting looks good.\n',
      );
    }

    // Run static analysis on staged files.
    stdout.write('Running static analysis...');
    final ProcessResult analyzeResult = await processRunner('dart', [
      'run',
      toolScript,
      'analyze',
      '--run-on-staged-packages',
      '--dart',
    ], workingDirectory: repoRoot.path);

    if (analyzeResult.exitCode != 0) {
      stdout.write(stdout.supportsAnsiEscapes ? '\x1B[2K\r' : '\n');
      if (analyzeResult.stdout.toString().isNotEmpty) {
        print(analyzeResult.stdout);
      }
      if (analyzeResult.stderr.toString().isNotEmpty) {
        print(analyzeResult.stderr);
      }
      print('❌ Static analysis errors found.');
      hasError = true;
    } else {
      stdout.write(
        stdout.supportsAnsiEscapes
            ? '\x1B[2K\r✅ Static analysis looks good.\n'
            : '✅ Static analysis looks good.\n',
      );
    }

    if (hasError) {
      print('❌ Please fix the errors listed above.');
    }

    return !hasError;
  }
}
