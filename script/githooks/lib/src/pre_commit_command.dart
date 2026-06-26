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

  /// Runs a pre-commit check for correct formatting and static analysis.
  ///
  /// It will check for any staged changes and run the plugin tool format and analyze commands on them.
  /// If any of the commands fail, it will return false; otherwise, it will return true.
  @override
  Future<bool> run() async {
    final Directory? repoRoot = await _findRepoRoot();
    if (repoRoot == null) {
      print('Could not find git repository.');
      return false;
    }

    if (!await _hasStagedChanges(repoRoot)) {
      print('No staged changes to check.');
      return true;
    }

    final String toolScript = p.join(
      repoRoot.path,
      'script',
      'tool',
      'bin',
      'flutter_plugin_tools.dart',
    );

    print('Running pre-commit format and static analysis checks for staged changes...');

    // Check format.
    final bool formatPassed = await _checkFormatting(repoRoot, toolScript);
    if (!formatPassed) {
      return false;
    }

    // Check static analysis if format passed.
    return _checkStaticAnalysis(repoRoot, toolScript);
  }

  /// Finds the repository root directory using git.
  ///
  /// Returns null if git fails or if the directory is not a git repository.
  Future<Directory?> _findRepoRoot() async {
    final ProcessResult rootResult = await processRunner('git', <String>[
      'rev-parse',
      '--show-toplevel',
    ], workingDirectory: Directory.current.path);

    if (rootResult.exitCode != 0) {
      return null;
    }
    return Directory((rootResult.stdout as String).trim());
  }

  /// Checks if there are any staged changes in the repository.
  Future<bool> _hasStagedChanges(Directory repoRoot) async {
    final ProcessResult diffResult = await processRunner('git', <String>[
      'diff',
      '--cached',
      '--name-only',
    ], workingDirectory: repoRoot.path);

    if (diffResult.exitCode != 0) {
      print('Failed to check staged changes.');
      if (diffResult.stderr.toString().isNotEmpty) {
        print(diffResult.stderr);
      }
      // If we cannot determine the diff, abort pre-commit check.
      return false;
    }

    return (diffResult.stdout as String).trim().isNotEmpty;
  }

  /// Runs the formatting check on staged files.
  ///
  /// Returns true if all staged files are correctly formatted.
  Future<bool> _checkFormatting(Directory repoRoot, String toolScript) async {
    final ProcessResult formatResult = await processRunner('dart', [
      'run',
      toolScript,
      'format',
      '--run-on-staged-packages',
      '--fail-on-change',
    ], workingDirectory: repoRoot.path);

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
      return false;
    }

    final stdoutStr = formatResult.stdout.toString();
    if (stdoutStr.contains('Ran for 0 package(s)')) {
      print('Formatting skipped (no staged packages).');
    } else {
      print('Formatting looks good!');
    }
    return true;
  }

  /// Runs the static analysis check on staged files.
  ///
  /// Returns true if all staged files pass analysis.
  Future<bool> _checkStaticAnalysis(Directory repoRoot, String toolScript) async {
    final ProcessResult analyzeResult = await processRunner('dart', [
      'run',
      toolScript,
      'analyze',
      '--run-on-staged-packages',
      '--dart',
    ], workingDirectory: repoRoot.path);

    if (analyzeResult.exitCode != 0) {
      if (analyzeResult.stdout.toString().isNotEmpty) {
        print(analyzeResult.stdout);
      }
      if (analyzeResult.stderr.toString().isNotEmpty) {
        print(analyzeResult.stderr);
      }
      print('Static analysis failed. Please fix the errors listed above.');
      return false;
    }

    final String stdoutStr = analyzeResult.stdout.toString();
    if (stdoutStr.contains('Ran for 0 package(s)')) {
      print('Static analysis skipped (no staged packages).');
    } else {
      print('Static analysis looks good!');
    }
    return true;
  }
}
