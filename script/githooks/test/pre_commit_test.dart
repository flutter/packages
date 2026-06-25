// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';

import 'package:githooks/src/pre_commit_command.dart';
import 'package:path/path.dart' as path;
import 'package:test/test.dart';

void main() {
  group('pre-commit hook', () {
    test('passes when both format and analyze succeed', () async {
      final List<List<String>> executedArguments = [];
      final command = PreCommitCommand(
        processRunner:
            (String executable, List<String> arguments, {String? workingDirectory}) async {
              executedArguments.add(arguments);
              if (executable == 'git' && arguments.contains('rev-parse')) {
                return ProcessResult(0, 0, '/mock/repo/root\n', '');
              }
              return ProcessResult(0, 0, 'Success', '');
            },
      );

      final bool result = await command.run();
      expect(result, isTrue);

      const String repoRoot = '/mock/repo/root';
      final String toolScript = '$repoRoot/script/tool/bin/flutter_plugin_tools.dart';

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
              if (executable == 'git' && arguments.contains('rev-parse')) {
                return ProcessResult(0, 0, '/mock/repo/root\n', '');
              }
              if (arguments.isNotEmpty && arguments.length > 2 && arguments[2] == 'format') {
                return ProcessResult(0, 1, 'bad_file.dart', '');
              }
              return ProcessResult(0, 0, 'Success', '');
            },
      );

      final bool result = await command.run();
      expect(result, isFalse);

      const String repoRoot = '/mock/repo/root';
      final String toolScript = '$repoRoot/script/tool/bin/flutter_plugin_tools.dart';

      expect(
        executedArguments,
        anyElement(
          equals(['run', toolScript, 'format', '--run-on-staged-packages', '--fail-on-change']),
        ),
      );
    });

    test('fails when analysis fails', () async {
      final List<List<String>> executedArguments = [];
      final command = PreCommitCommand(
        processRunner:
            (String executable, List<String> arguments, {String? workingDirectory}) async {
              executedArguments.add(arguments);
              if (executable == 'git' && arguments.contains('rev-parse')) {
                return ProcessResult(0, 0, '/mock/repo/root\n', '');
              }
              if (arguments.isNotEmpty && arguments.length > 2 && arguments[2] == 'analyze') {
                return ProcessResult(0, 1, 'error in file.dart', '');
              }
              return ProcessResult(0, 0, 'Success', '');
            },
      );

      final bool result = await command.run();
      expect(result, isFalse);

      const String repoRoot = '/mock/repo/root';
      final String toolScript = '$repoRoot/script/tool/bin/flutter_plugin_tools.dart';

      expect(
        executedArguments,
        anyElement(equals(['run', toolScript, 'analyze', '--run-on-staged-packages', '--dart'])),
      );
    });
  });
}
