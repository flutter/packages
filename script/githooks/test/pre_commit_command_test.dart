// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';

import 'package:githooks/src/pre_commit_command.dart';
import 'package:test/test.dart';

void main() {
  const repoRoot = '/mock/repo/root';
  const toolScript = '$repoRoot/script/tool/bin/flutter_plugin_tools.dart';

  group('pre-commit hook', () {
    test('passes when both format and analyze succeed', () async {
      final List<List<String>> executedArguments = [];
      final command = PreCommitCommand(
        processRunner:
            (String executable, List<String> arguments, {String? workingDirectory}) async {
              executedArguments.add(arguments);
              if (executable == 'git') {
                if (arguments.contains('rev-parse')) {
                  return ProcessResult(0, 0, '$repoRoot\n', '');
                }
                if (arguments.contains('diff')) {
                  return ProcessResult(0, 0, 'packages/a_plugin/lib/a.dart\u0000', '');
                }
              }
              return ProcessResult(0, 0, 'Success', '');
            },
      );

      final bool result = await command.run();
      expect(result, isTrue);

      // Verify the exact arguments passed to format and analyze
      expect(
        executedArguments,
        anyElement(
          equals(['run', toolScript, 'format', '--run-on-staged-packages', '--fail-on-change']),
        ),
      );
      expect(
        executedArguments,
        anyElement(equals(['run', toolScript, 'analyze', '--run-on-staged-packages', '--dart'])),
      );
    });

    test('fails when formatting fails', () async {
      final List<List<String>> executedArguments = [];
      final command = PreCommitCommand(
        processRunner:
            (String executable, List<String> arguments, {String? workingDirectory}) async {
              executedArguments.add(arguments);
              if (executable == 'git') {
                if (arguments.contains('rev-parse')) {
                  return ProcessResult(0, 0, '$repoRoot\n', '');
                }
                if (arguments.contains('diff')) {
                  return ProcessResult(0, 0, 'packages/a_plugin/lib/a.dart\u0000', '');
                }
              }
              if (arguments.contains('format')) {
                return ProcessResult(0, 1, 'bad_file.dart', '');
              }
              return ProcessResult(0, 0, 'Success', '');
            },
      );

      final bool result = await command.run();
      expect(result, isFalse);

      expect(
        executedArguments,
        anyElement(
          equals(['run', toolScript, 'format', '--run-on-staged-packages', '--fail-on-change']),
        ),
      );
      // Verify that static analysis was skipped because formatting failed
      expect(executedArguments.any((args) => args.contains('analyze')), isFalse);
    });

    test('fails when analysis fails', () async {
      final List<List<String>> executedArguments = [];
      final command = PreCommitCommand(
        processRunner:
            (String executable, List<String> arguments, {String? workingDirectory}) async {
              executedArguments.add(arguments);
              if (executable == 'git') {
                if (arguments.contains('rev-parse')) {
                  return ProcessResult(0, 0, '$repoRoot\n', '');
                }
                if (arguments.contains('diff')) {
                  return ProcessResult(0, 0, 'packages/a_plugin/lib/a.dart\u0000', '');
                }
              }
              if (arguments.contains('analyze')) {
                return ProcessResult(0, 1, 'error in file.dart', '');
              }
              return ProcessResult(0, 0, 'Success', '');
            },
      );

      final bool result = await command.run();
      expect(result, isFalse);

      expect(
        executedArguments,
        anyElement(equals(['run', toolScript, 'analyze', '--run-on-staged-packages', '--dart'])),
      );
    });

    test('exits early with success if there are no staged packages', () async {
      final List<List<String>> executedArguments = [];
      final command = PreCommitCommand(
        processRunner:
            (String executable, List<String> arguments, {String? workingDirectory}) async {
              executedArguments.add(arguments);
              if (executable == 'git') {
                if (arguments.contains('rev-parse')) {
                  return ProcessResult(0, 0, '$repoRoot\n', '');
                }
                if (arguments.contains('diff')) {
                  return ProcessResult(
                    0,
                    0,
                    'script/githooks/test/pre_commit_command_test.dart\u0000',
                    '',
                  );
                }
              }
              return ProcessResult(0, 0, 'Success', '');
            },
      );

      final bool result = await command.run();
      expect(result, isTrue);

      // Verify that no format or analyze commands were run
      expect(
        executedArguments.any((args) => args.contains('format') || args.contains('analyze')),
        isFalse,
      );
    });

    test('exits early with success if there are no staged changes at all', () async {
      final List<List<String>> executedArguments = [];
      final command = PreCommitCommand(
        processRunner:
            (String executable, List<String> arguments, {String? workingDirectory}) async {
              executedArguments.add(arguments);
              if (executable == 'git') {
                if (arguments.contains('rev-parse')) {
                  return ProcessResult(0, 0, '$repoRoot\n', '');
                }
                if (arguments.contains('diff')) {
                  return ProcessResult(0, 0, '', '');
                }
              }
              return ProcessResult(0, 0, 'Success', '');
            },
      );

      final bool result = await command.run();
      expect(result, isTrue);

      // Verify that no format or analyze commands were run
      expect(
        executedArguments.any((args) => args.contains('format') || args.contains('analyze')),
        isFalse,
      );
    });

    test('fails when checking staged packages fails', () async {
      final command = PreCommitCommand(
        processRunner:
            (String executable, List<String> arguments, {String? workingDirectory}) async {
              if (executable == 'git') {
                if (arguments.contains('rev-parse')) {
                  return ProcessResult(0, 0, '$repoRoot\n', '');
                }
                if (arguments.contains('diff')) {
                  return ProcessResult(0, 1, '', 'Git diff failed');
                }
              }
              return ProcessResult(0, 0, 'Success', '');
            },
      );

      final bool result = await command.run();
      expect(result, isFalse);
    });

    test('fails when git root cannot be found', () async {
      final command = PreCommitCommand(
        processRunner:
            (String executable, List<String> arguments, {String? workingDirectory}) async {
              if (executable == 'git' && arguments.contains('rev-parse')) {
                return ProcessResult(0, 1, '', 'Not a git repository');
              }
              return ProcessResult(0, 0, 'Success', '');
            },
      );

      final bool result = await command.run();
      expect(result, isFalse);
    });
  });
}
