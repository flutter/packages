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

  String? _findPackageName(String filePath, String repoRoot) {
    Directory currentDir = File(p.join(repoRoot, filePath)).parent;
    while (p.isWithin(repoRoot, currentDir.path) || p.equals(repoRoot, currentDir.path)) {
      final String dirName = p.basename(currentDir.path);
      if (dirName != 'example' && File(p.join(currentDir.path, 'pubspec.yaml')).existsSync()) {
        return dirName;
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
    while (repoRoot.path != '/' && !Directory(p.join(repoRoot.path, '.git')).existsSync()) {
      repoRoot = repoRoot.parent;
    }

    if (repoRoot.path == '/') {
      print('❌ Could not find .git directory.');
      return false;
    }

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
      return true; // No files changed.
    }

    final Set<String> targetPackages = {};
    for (final file in stagedFiles) {
      final String? packageName = _findPackageName(file, repoRoot.path);
      if (packageName != null) {
        targetPackages.add(packageName);
      }
    }

    if (targetPackages.isEmpty) {
      return true; // None of the changed files are part of a package we care about.
    }

    final String toolScript = p.join(
      repoRoot.path,
      'script',
      'tool',
      'bin',
      'flutter_plugin_tools.dart',
    );
    final packageArgs = '--packages=${targetPackages.join(',')}';

    // Determine which toolchains are needed based on file extensions
    final bool hasDart = stagedFiles.any((f) => f.endsWith('.dart'));
    final bool hasClang = stagedFiles.any(
      (f) =>
          f.endsWith('.c') ||
          f.endsWith('.cc') ||
          f.endsWith('.cpp') ||
          f.endsWith('.h') ||
          f.endsWith('.m') ||
          f.endsWith('.mm'),
    );
    final bool hasJava = stagedFiles.any((f) => f.endsWith('.java'));
    final bool hasKotlin = stagedFiles.any((f) => f.endsWith('.kt'));
    final bool hasSwift = stagedFiles.any((f) => f.endsWith('.swift'));

    final formatFlags = [
      if (!hasDart) '--no-dart',
      if (!hasClang) '--no-clang-format',
      if (!hasJava) '--no-java',
      if (!hasKotlin) '--no-kotlin',
      if (!hasSwift) '--no-swift',
    ];

    print(
      '🔍 Running pre-commit checks on ${targetPackages.length} packages: ${targetPackages.join(', ')}',
    );
    var hasError = false;

    // Check formatting.
    print('Checking formatting...');
    final ProcessResult formatResult = await processRunner('dart', [
      'run',
      toolScript,
      'format',
      packageArgs,
      '--fail-on-change',
      ...formatFlags,
    ], workingDirectory: repoRoot.path);

    if (formatResult.exitCode != 0) {
      if (formatResult.stdout.toString().isNotEmpty) {
        print(formatResult.stdout);
      }
      if (formatResult.stderr.toString().isNotEmpty) {
        print(formatResult.stderr);
      }
      print(
        '❌ Formatting issues found. Please run "dart run script/tool/bin/flutter_plugin_tools.dart format $packageArgs" to fix them.',
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
      packageArgs,
    ], workingDirectory: repoRoot.path);

    if (analyzeResult.exitCode != 0) {
      if (analyzeResult.stdout.toString().isNotEmpty) {
        print(analyzeResult.stdout);
      }
      if (analyzeResult.stderr.toString().isNotEmpty) {
        print(analyzeResult.stderr);
      }
      print('❌ Static analysis errors found. Please fix the errors listed above.');
      hasError = true;
    } else {
      print('✅ Static analysis looks good.');
    }

    return !hasError;
  }
}
