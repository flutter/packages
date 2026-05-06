import 'dart:convert';
import 'dart:io';
import 'package:dart_hooks/src/dart_format_hook.dart';
import 'package:test/test.dart';

void main() {
  group('DartFormatHook Unit Tests', () {
    test('Parse --source flag correctly', () async {
      String? loggedMessage;

      final hook = DartFormatHook(
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
              if (cmd == 'git' && args.first == 'status') {
                return ProcessResult(0, 0, '', '');
              }
              return ProcessResult(0, 0, '', '');
            },
        fileExists: (path) => true,
        printStdout: (msg) {},
        logToFile: (msg) async => loggedMessage = msg,
      );

      await hook.run(['--source', 'hook'], '/current/path');

      expect(loggedMessage, contains('(Trigger: HOOK)'));
    });

    test('Defaults to MANUAL source when flag missing', () async {
      String? loggedMessage;

      final hook = DartFormatHook(
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
              return ProcessResult(0, 0, '', '');
            },
        fileExists: (path) => true,
        logToFile: (msg) async => loggedMessage = msg,
      );

      await hook.run([], '/current/path');

      expect(loggedMessage, contains('(Trigger: MANUAL)'));
    });

    test('JSON contract adherence on success', () async {
      String? stdoutMessage;
      int? exitCode;

      final hook = DartFormatHook(
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
              if (cmd == 'git' && args.first == 'status') {
                return ProcessResult(0, 0, 'M  file.dart', '');
              }
              if (cmd == 'dart' && args.first == 'format') {
                return ProcessResult(0, 0, 'Formatted file.dart', '');
              }
              return ProcessResult(0, 0, '', '');
            },
        fileExists: (path) => true,
        printStdout: (msg) => stdoutMessage = msg,
        logToFile: (msg) async {},
        onExit: (code) => exitCode = code,
      );

      await hook.run([], '/current/path');

      expect(stdoutMessage, equals(jsonEncode({})));
      expect(exitCode, equals(0));
    });
  });
}
