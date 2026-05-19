import 'dart:convert';
import 'dart:io';
import 'package:dart_hooks/src/dart_analyze_hook.dart';
import 'package:test/test.dart';

void main() {
  group('DartAnalyzeHook Unit Tests', () {
    test('Parse --source flag correctly', () async {
      String? loggedMessage;

      final hook = DartAnalyzeHook(
        runProcess:
            (
              cmd,
              args, {
              bool runInShell = false,
              String? workingDirectory,
            }) async {
              if (cmd == 'git' && args.first == 'rev-parse') {
                return ProcessResult(0, 0, '/repo/root', '');
              }
              if (cmd == 'git' && args.first == 'ls-files') {
                return ProcessResult(0, 0, '', '');
              }
              return ProcessResult(0, 0, '', '');
            },
        fileExists: (path) => true,
        logToFile: (msg) async => loggedMessage = msg,
      );

      await hook.run(['--source', 'hook'], '/current/path', '/package/root');

      expect(loggedMessage, contains('(Trigger: HOOK)'));
    });

    test('JSON decision output on success', () async {
      String? stdoutMessage;
      int? exitCode;

      final hook = DartAnalyzeHook(
        runProcess:
            (
              cmd,
              args, {
              bool runInShell = false,
              String? workingDirectory,
            }) async {
              if (cmd == 'git' && args.first == 'rev-parse') {
                return ProcessResult(0, 0, '/repo/root', '');
              }
              if (cmd == 'git' && args.first == 'ls-files') {
                return ProcessResult(0, 0, 'lib/file.dart', '');
              }
              if (cmd == 'dart' && args.first == 'analyze') {
                return ProcessResult(0, 0, 'No issues found.', '');
              }
              return ProcessResult(0, 0, '', '');
            },
        fileExists: (path) => true,
        printStdout: (msg) => stdoutMessage = msg,
        logToFile: (msg) async {},
        onExit: (code) => exitCode = code,
      );

      await hook.run([], '/current/path', '/package/root');

      expect(stdoutMessage, equals(jsonEncode({'decision': 'stop'})));
      expect(exitCode, equals(0));
    });

    test('JSON decision output on failure', () async {
      String? stdoutMessage;
      int? exitCode;

      final hook = DartAnalyzeHook(
        runProcess:
            (
              cmd,
              args, {
              bool runInShell = false,
              String? workingDirectory,
            }) async {
              if (cmd == 'git' && args.first == 'rev-parse') {
                return ProcessResult(0, 0, '/repo/root', '');
              }
              if (cmd == 'git' && args.first == 'ls-files') {
                return ProcessResult(0, 0, 'lib/file.dart', '');
              }
              if (cmd == 'dart' && args.first == 'analyze') {
                return ProcessResult(1, 0, 'Issue found.', '');
              }
              return ProcessResult(0, 0, '', '');
            },
        fileExists: (path) => true,
        printStdout: (msg) => stdoutMessage = msg,
        logToFile: (msg) async {},
        onExit: (code) => exitCode = code,
      );

      await hook.run([], '/current/path', '/package/root');

      expect(stdoutMessage, contains('"decision":"continue"'));
      expect(exitCode, equals(0)); // Exits 0 so framework gets JSON
    });
  });
}
