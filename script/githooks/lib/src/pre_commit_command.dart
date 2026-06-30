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
  final String description =
      'Runs formatting and static analysis checks on staged changes before a "git commit"';

  /// Runs a pre-commit check for correct formatting and static analysis.
  ///
  /// It runs the plugin tool format and analyze commands on all packages that have staged changes.
  /// If any of the commands fail, it will return false; otherwise, it will return true.
  @override
  Future<bool> run() async {
    final Directory? repoRoot = await _findRepoRoot();
    if (repoRoot == null) {
      print('Could not find git repository.');
      return false;
    }

    // final bool? hasStaged = await _hasStagedPackages(repoRoot);
    // if (hasStaged == null) {
    //   return false;
    // }
    // if (!hasStaged) {
    //   print('No staged package changes to check.');
    //   return true;
    // }

    final String toolScript = p.join(
      repoRoot.path,
      'script',
      'tool',
      'bin',
      'flutter_plugin_tools.dart',
    );

    print('Running pre-commit format and static analysis checks for staged changes...');

    // Check format.
    final bool formatPassed = await _executeCheckFormatting(repoRoot, toolScript);
    if (!formatPassed) {
      return false;
    }

    return _executeCheckStaticAnalysis(repoRoot, toolScript);
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

  /// Checks if there are any staged package changes in the repository.
  ///
  /// Returns true if at least one staged file is located within a package directory
  /// (under packages/ or third_party/packages/), false if there are none, or null
  /// if the git command fails.
  Future<bool?> _hasStagedPackages(Directory repoRoot) async {
    final ProcessResult diffResult = await processRunner('git', <String>[
      'diff',
      '--cached',
      '-z',
      '--name-only',
    ], workingDirectory: repoRoot.path);

    if (diffResult.exitCode != 0) {
      print('Failed to check staged changes.');
      if (diffResult.stderr.toString().isNotEmpty) {
        print(diffResult.stderr);
      }
      // If we cannot determine the diff, abort pre-commit check by returning null.
      return null;
    }

    final stdoutStr = diffResult.stdout as String;
    if (stdoutStr.isEmpty) {
      return false;
    }

    final List<String> lines = stdoutStr.split('\u0000')
      ..removeWhere((String element) => element.isEmpty);
    return lines.any(
      (String path) => path.startsWith('packages/') || path.startsWith('third_party/packages/'),
    );
  }

  /// Runs the formatting check on staged files.
  ///
  /// Returns true if all staged files are correctly formatted or false otherwise.
  Future<bool> _executeCheckFormatting(Directory repoRoot, String toolScript) async {
    final ProcessResult formatResult = await processRunner('dart', [
      'run',
      toolScript,
      'format',
      '--run-on-staged-packages',
      '--fail-on-change',
    ], workingDirectory: repoRoot.path);

    if (formatResult.exitCode != 0) {
      print('''
Formatting check failed.
To fix formatting automatically, run:
  dart run script/tool/bin/flutter_plugin_tools.dart format --run-on-staged-packages
To bypass this check, commit with --no-verify.''');
      return false;
    }

    print('Formatting looks good!');
    return true;
  }

  /// Runs the static analysis check on staged files.
  ///
  /// Returns true if all staged files pass analysis or false otherwise.
  Future<bool> _executeCheckStaticAnalysis(Directory repoRoot, String toolScript) async {
    final ProcessResult analyzeResult = await processRunner('dart', [
      'run',
      toolScript,
      'analyze',
      '--run-on-staged-packages',
      '--dart',
    ], workingDirectory: repoRoot.path);

    if (analyzeResult.exitCode != 0) {
      print('''
Static analysis check failed.
To view and fix analysis errors, run:
  dart run script/tool/bin/flutter_plugin_tools.dart analyze --run-on-staged-packages --dart
To bypass this check, commit with --no-verify.''');
      return false;
    }

    print('Static analysis looks good!');
    return true;
  }
}
