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

  String? _findPackagePath(String filePath, String repoRoot) {
    Directory currentDir = File(p.join(repoRoot, filePath)).parent;
    while (p.isWithin(repoRoot, currentDir.path) || p.equals(repoRoot, currentDir.path)) {
      final String dirName = p.basename(currentDir.path);
      if (dirName != 'example' && File(p.join(currentDir.path, 'pubspec.yaml')).existsSync()) {
        return currentDir.path;
      }
      if (p.equals(repoRoot, currentDir.path)) {
        break;
      }
      currentDir = currentDir.parent;
    }
    return null;
  }

  @override
  Future<bool> run() async {
    // Find the repo root where the plugin tool is located.
    Directory repoRoot = Directory.current;
    while (repoRoot.path != repoRoot.parent.path &&
        !(Directory(p.join(repoRoot.path, '.git')).existsSync() ||
            File(p.join(repoRoot.path, '.git')).existsSync())) {
      repoRoot = repoRoot.parent;
    }
    if (!(Directory(p.join(repoRoot.path, '.git')).existsSync() ||
        File(p.join(repoRoot.path, '.git')).existsSync())) {
      print('❌ Could not find .git directory.');
      return false;
    }

    // Get all staged files that are added, copied, or modified.
    final ProcessResult diffResult = await processRunner('git', [
      'diff',
      '--cached',
      '--name-only',
      '--diff-filter=ACM',
    ], workingDirectory: repoRoot.path);

    if (diffResult.exitCode != 0) {
      print('❌ Failed to get staged files');
      return false;
    }

    final List<String> stagedFiles = (diffResult.stdout as String)
        .split('\n')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    if (stagedFiles.isEmpty) {
      // No files changed.
      return true;
    }

    final Set<String> targetPackageDirs = {};
    for (final file in stagedFiles) {
      final String? packageDir = _findPackagePath(file, repoRoot.path);
      if (packageDir != null) {
        targetPackageDirs.add(packageDir);
      }
    }

    if (targetPackageDirs.isEmpty) {
      // None of the changed files are part of a package we care about.
      return true;
    }

    final Set<String> targetPackages = targetPackageDirs.map((dir) => p.basename(dir)).toSet();

    final String toolScript = p.join(
      repoRoot.path,
      'script',
      'tool',
      'bin',
      'flutter_plugin_tools.dart',
    );
    final packageArgs = '--packages=${targetPackages.join(',')}';

    final String customFilesArg = '--custom-files=${stagedFiles.join(',')}';

    print(
      '🏃 Running pre-commit checks on ${targetPackages.length} packages: ${targetPackages.join(', ')}',
    );
    var hasError = false;

    // Check formatting.
    stdout.write('Checking formatting...');
    final ProcessResult formatResult = await processRunner('dart', [
      'run',
      toolScript,
      'format',
      customFilesArg,
      '--fail-on-change',
    ], workingDirectory: repoRoot.path);

    if (formatResult.exitCode != 0) {
      if (!hasError) {
        stdout.write(stdout.supportsAnsiEscapes ? '\x1B[2K\r' : '\n');
      }
      if (formatResult.stdout.toString().isNotEmpty) {
        print(formatResult.stdout);
      }
      if (formatResult.stderr.toString().isNotEmpty) {
        print(formatResult.stderr);
      }
      print('❌ Formatting issues found. Please run "dart run script/tool/bin/flutter_plugin_tools.dart format $customFilesArg" to fix them.');
      hasError = true;
    }

    if (!hasError) {
      stdout.write(
        stdout.supportsAnsiEscapes
            ? '\x1B[2K\r✅ Formatting looks good.\n'
            : '✅ Formatting looks good.\n',
      );
    }

    // Run static analysis on staged files.
    var analyzeHasError = false;
    stdout.write('Running static analysis...');
    final ProcessResult analyzeResult = await processRunner('dart', [
      'run',
      toolScript,
      'analyze',
      customFilesArg,
      '--dart',
    ], workingDirectory: repoRoot.path);

    if (analyzeResult.exitCode != 0) {
      if (!analyzeHasError) {
        stdout.write(stdout.supportsAnsiEscapes ? '\x1B[2K\r' : '\n');
      }
      if (analyzeResult.stdout.toString().isNotEmpty) {
        print(analyzeResult.stdout);
      }
      if (analyzeResult.stderr.toString().isNotEmpty) {
        print(analyzeResult.stderr);
      }
      print('❌ Static analysis errors found.');
      analyzeHasError = true;
      hasError = true;
    }

    if (!analyzeHasError) {
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
