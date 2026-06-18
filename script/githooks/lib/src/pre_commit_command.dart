import 'dart:io';
import 'package:args/command_runner.dart';

class PreCommitCommand extends Command {
  @override
  final String name = 'pre-commit';

  @override
  final String description = 'Runs pre-commit checks like format and analyze.';

  @override
  Future<void> run() async {
    // 1. Get the list of staged files
    final diffResult = await Process.run('git', ['diff', '--cached', '--name-only', '--diff-filter=ACM']);
    if (diffResult.exitCode != 0) {
      print('Failed to get staged files.');
      exit(1);
    }

    // Filter for Dart files
    final stagedDartFiles = (diffResult.stdout as String)
        .split('\n')
        .map((file) => file.trim())
        .where((file) => file.endsWith('.dart'))
        .toList();

    if (stagedDartFiles.isEmpty) {
      // No Dart files are being committed; exit cleanly
      return;
    }

    print('🔍 Running pre-commit checks on staged Dart files...');
    bool hasError = false;

    // 2. Code Formatting Check
    print('Checking formatting...');
    final formatResult = await Process.run('dart', [
      'format',
      '--output=none',
      '--set-exit-if-changed',
      ...stagedDartFiles,
    ]);

    if (formatResult.exitCode != 0) {
      print('❌ Formatting issues found in the following files:');
      print((formatResult.stdout as String).trim());
      print('👉 Please run "dart format" on these files to fix them.');
      hasError = true;
    } else {
      print('✅ Formatting looks good.');
    }

    // 3. Static Analysis Check
    print('Running static analysis...');
    final analyzeResult = await Process.run('dart', [
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

    // 4. Final Verdict
    if (hasError) {
      print('🚨 Pre-commit checks failed. Please fix the above errors and try committing again.');
      exit(1);
    }
  }
}
