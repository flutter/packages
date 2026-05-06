import 'dart:convert';
import 'dart:io';
import 'package:dart_hooks/src/dart_format_hook.dart';
import 'package:path/path.dart' as path;
import 'package:test/test.dart';

void main() {
  group('DartFormatHook Integration Tests', () {
    late Directory tempDir;
    late String repoRoot;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('dart_format_test_');
      repoRoot = tempDir.path;

      // Initialize a git repo in the temp directory
      await Process.run(
        'git',
        ['init'],
        workingDirectory: repoRoot,
        runInShell: true,
      );

      // Git requires user name and email to be set in some environments
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
    });

    tearDown(() async {
      await tempDir.delete(recursive: true);
    });

    test('Formats modified file', () async {
      final fileToFormat = File(path.join(repoRoot, 'test.dart'));
      await fileToFormat.writeAsString(
        'void main() {  print("hello");}',
      ); // Poorly formatted

      // Stage the file so git status sees it or leave it untracked?
      // The hook checks `git status --porcelain` which sees both modified and untracked files (if not ignored).

      String? stdoutMessage;
      int? exitCode;

      final hook = DartFormatHook(
        runProcess:
            (cmd, args, {bool runInShell = false, String? workingDirectory}) {
              // Delegate to real Process.run but force workingDirectory to repoRoot
              return Process.run(
                cmd,
                args,
                runInShell: runInShell,
                workingDirectory: workingDirectory ?? repoRoot,
              );
            },
        fileExists: (p) => File(p).existsSync(),
        printStdout: (msg) => stdoutMessage = msg,
        logToFile: (msg) async {},
        onExit: (code) => exitCode = code,
      );

      // Stage the file so git status sees it as added
      await Process.run(
        'git',
        ['add', 'test.dart'],
        workingDirectory: repoRoot,
        runInShell: true,
      );

      // Run the hook
      await hook.run([], repoRoot);

      // Verify JSON output
      expect(stdoutMessage, equals(jsonEncode({})));
      expect(exitCode, equals(0));

      // Verify file was formatted
      final String content = await fileToFormat.readAsString();
      expect(
        content,
        equals('void main() {\n  print("hello");\n}\n'),
      ); // Assuming standard dart format
    });

    test('Creates log file and appends to it', () async {
      final logFile = File(path.join(repoRoot, 'test.log'));

      Future<void> testLog(String message) async {
        await logFile.writeAsString('$message\n', mode: FileMode.append);
      }

      final hook = DartFormatHook(
        runProcess:
            (
              cmd,
              args, {
              bool runInShell = false,
              String? workingDirectory,
            }) async {
              if (cmd == 'git' && args.first == 'rev-parse') {
                return ProcessResult(0, 0, repoRoot, '');
              }
              if (cmd == 'git' && args.first == 'status') {
                return ProcessResult(0, 0, '', '');
              }
              return ProcessResult(0, 0, '', '');
            },
        fileExists: (p) => true,
        printStdout: (msg) {},
        logToFile: testLog,
        onExit: (code) {},
      );

      // Run it first time
      await hook.run([], repoRoot);

      expect(logFile.existsSync(), isTrue);
      final List<String> linesFirstRun = await logFile.readAsLines();
      expect(linesFirstRun.length, equals(2)); // Start + No files found

      // Run it second time to verify append
      await hook.run([], repoRoot);

      final List<String> linesSecondRun = await logFile.readAsLines();
      expect(linesSecondRun.length, equals(4)); // Appended 2 more lines
    });
  });
}
