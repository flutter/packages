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

    final Set<String> targetPackageDirs = {};
    for (final file in stagedFiles) {
      final String? packageDir = _findPackagePath(file, repoRoot.path);
      if (packageDir != null) {
        targetPackageDirs.add(packageDir);
      }
    }

    if (targetPackageDirs.isEmpty) {
      return true; // None of the changed files are part of a package we care about.
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

    // Determine which toolchains are needed based on file extensions
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

    final List<String> dartFiles = stagedFiles.where((f) => f.endsWith('.dart')).toList();

    print(
      '🔍 Running pre-commit checks on ${targetPackages.length} packages: ${targetPackages.join(', ')}',
    );
    var hasError = false;

    // Check formatting.
    stdout.write('Checking formatting...');

    // Format Dart files instantly using dart format directly
    if (dartFiles.isNotEmpty) {
      final ProcessResult dartFormatResult = await processRunner('dart', [
        'format',
        '--set-exit-if-changed',
        ...dartFiles,
      ], workingDirectory: repoRoot.path);

      if (dartFormatResult.exitCode != 0) {
        if (!hasError) {
          stdout.write('\x1B[2K\r');
        }
        if (dartFormatResult.stdout.toString().isNotEmpty) {
          print(dartFormatResult.stdout);
        }
        if (dartFormatResult.stderr.toString().isNotEmpty) {
          print(dartFormatResult.stderr);
        }
        print('❌ Formatting issues found in Dart files. Please run "dart format" to fix them.');
        hasError = true;
      }
    }

    // Format native files using flutter_plugin_tools
    final bool needsNativeFormat = hasClang || hasJava || hasKotlin || hasSwift;
    if (needsNativeFormat) {
      final nativeFormatFlags = [
        '--no-dart',
        if (!hasClang) '--no-clang-format',
        if (!hasJava) '--no-java',
        if (!hasKotlin) '--no-kotlin',
        if (!hasSwift) '--no-swift',
      ];

      final ProcessResult nativeFormatResult = await processRunner('dart', [
        'run',
        toolScript,
        'format',
        packageArgs,
        '--fail-on-change',
        ...nativeFormatFlags,
      ], workingDirectory: repoRoot.path);

      if (nativeFormatResult.exitCode != 0) {
        if (!hasError) {
          stdout.write('\x1B[2K\r');
        }
        if (nativeFormatResult.stdout.toString().isNotEmpty) {
          print(nativeFormatResult.stdout);
        }
        if (nativeFormatResult.stderr.toString().isNotEmpty) {
          print(nativeFormatResult.stderr);
        }
        print(
          '❌ Formatting issues found in native files. Please run "dart run script/tool/bin/flutter_plugin_tools.dart format $packageArgs" to fix them.',
        );
        hasError = true;
      }
    }

    if (!hasError) {
      stdout.write('\x1B[2K\r✅ Formatting looks good.\n');
    }

    // Run static analysis directly on staged files
    var analyzeHasError = false;
    stdout.write('Running static analysis...');
    if (dartFiles.isNotEmpty) {
      final ProcessResult analyzeResult = await processRunner('dart', [
        'analyze',
        '--fatal-infos',
        ...dartFiles,
      ], workingDirectory: repoRoot.path);

      if (analyzeResult.exitCode != 0) {
        if (!analyzeHasError) {
          stdout.write('\x1B[2K\r');
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
    }

    if (!analyzeHasError) {
      stdout.write('\x1B[2K\r✅ Static analysis looks good.\n');
    }

    if (hasError) {
      print('❌ Please fix the errors listed above.');
    }

    return !hasError;
  }
}
