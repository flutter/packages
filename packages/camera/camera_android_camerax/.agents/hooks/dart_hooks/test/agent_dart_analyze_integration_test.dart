import 'dart:convert';
import 'dart:io';
import 'package:dart_hooks/src/dart_analyze_hook.dart';
import 'package:path/path.dart' as path;
import 'package:test/test.dart';

void main() {
  group('DartAnalyzeHook Integration Tests', () {
    late Directory tempDir;
    late String repoRoot;
    late String packageRoot;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('dart_analyze_test_');
      repoRoot = tempDir.path;
      packageRoot = path.join(repoRoot, 'packages', 'camera_package');

      await Directory(packageRoot).create(recursive: true);

      // Create dummy pubspec.yaml to give analyzer context
      await File(path.join(packageRoot, 'pubspec.yaml')).writeAsString('''
name: test_package
environment:
  sdk: '>=3.0.0 <4.0.0'
''');

      // Initialize a git repo in the temp directory
      final ProcessResult initResult = await Process.run(
        'git',
        ['init'],
        workingDirectory: repoRoot,
        runInShell: true,
      );
      if (initResult.exitCode != 0) {
        throw Exception('git init failed: ${initResult.stderr}');
      }

      // Git requires user name and email
      await Process.run(
        'git',
        ['config', 'user.email', 'test@example.com'],
        workingDirectory: repoRoot,
        runInShell: true,
      );
      await Process.run(
        'git',
        ['config', 'user.name', 'Test User'],
        workingDirectory: repoRoot,
        runInShell: true,
      );

      // Create an initial commit to make the repo fully operational
      await File(
        path.join(repoRoot, 'README.md'),
      ).writeAsString('Initial file');
      await Process.run(
        'git',
        ['add', '.'],
        workingDirectory: repoRoot,
        runInShell: true,
      );
      await Process.run(
        'git',
        ['commit', '-m', 'Initial commit'],
        workingDirectory: repoRoot,
        runInShell: true,
      );
    });

    tearDown(() async {
      await tempDir.delete(recursive: true);
    });

    test('Finds and analyzes file in package', () async {
      final fileToAnalyze = File(path.join(packageRoot, 'lib', 'test.dart'));
      await fileToAnalyze.create(recursive: true);
      await fileToAnalyze.writeAsString('void main() {}'); // Valid file

      // Stage the file
      await Process.run(
        'git',
        ['add', '.'],
        workingDirectory: repoRoot,
        runInShell: true,
      );

      String? stdoutMessage;
      int? exitCode;
      final List<String> logs = [];

      final hook = DartAnalyzeHook(
        runProcess:
            (cmd, args, {bool runInShell = false, String? workingDirectory}) {
              return Process.run(
                cmd,
                args,
                runInShell: runInShell,
                workingDirectory: workingDirectory ?? packageRoot,
              );
            },
        fileExists: (p) => File(p).existsSync(),
        printStdout: (msg) => stdoutMessage = msg,
        logToFile: (msg) async => logs.add(msg),
        onExit: (code) => exitCode = code,
      );

      // Run the hook from a simulated .agents directory inside packageRoot
      final String agentsDir = path.join(packageRoot, '.agents');

      await hook.run([], agentsDir, packageRoot);

      // Verify JSON output
      expect(
        stdoutMessage,
        equals(jsonEncode({'decision': 'stop'})),
      ); // Success decision
      expect(exitCode, equals(0));

      // Verify files were actually found and analyzed
      expect(logs.any((l) => l.contains('Running dart analyze on')), isTrue);
    });
  });
}
