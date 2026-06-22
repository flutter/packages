// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';

import 'package:githooks/src/pre_commit_command.dart';
import 'package:test/test.dart';

void main() {
  group('pre-commit hook', () {
    test('passes when both format and analyze succeed', () async {
      final List<List<String>> executedArguments = [];
      final command = PreCommitCommand(
        processRunner:
            (String executable, List<String> arguments, {String? workingDirectory}) async {
              executedArguments.add(arguments);
              if (executable == 'git') {
                return ProcessResult(0, 0, 'script/githooks/lib/githooks.dart\n', '');
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
          equals(['format', '--set-exit-if-changed', 'script/githooks/lib/githooks.dart']),
        ),
      );
      expect(
        executedArguments,
        anyElement(equals(['analyze', '--fatal-infos', 'script/githooks/lib/githooks.dart'])),
      );
    });

    test('fails when formatting fails', () async {
      final List<List<String>> executedArguments = [];
      final command = PreCommitCommand(
        processRunner:
            (String executable, List<String> arguments, {String? workingDirectory}) async {
              executedArguments.add(arguments);
              if (executable == 'git') {
                return ProcessResult(0, 0, 'script/githooks/lib/githooks.dart\n', '');
              }
              if (arguments.isNotEmpty && arguments[0] == 'format') {
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
          equals(['format', '--set-exit-if-changed', 'script/githooks/lib/githooks.dart']),
        ),
      );
    });

    test('fails when analysis fails', () async {
      final List<List<String>> executedArguments = [];
      final command = PreCommitCommand(
        processRunner:
            (String executable, List<String> arguments, {String? workingDirectory}) async {
              executedArguments.add(arguments);
              if (executable == 'git') {
                return ProcessResult(0, 0, 'script/githooks/lib/githooks.dart\n', '');
              }
              if (arguments.isNotEmpty && arguments[0] == 'analyze') {
                return ProcessResult(0, 1, 'error in file.dart', '');
              }
              return ProcessResult(0, 0, 'Success', '');
            },
      );

      final bool result = await command.run();
      expect(result, isFalse);

      expect(
        executedArguments,
        anyElement(equals(['analyze', '--fatal-infos', 'script/githooks/lib/githooks.dart'])),
      );
    });

    test('ignores non-dart files', () async {
      final List<List<String>> executedArguments = [];
      final command = PreCommitCommand(
        processRunner:
            (String executable, List<String> arguments, {String? workingDirectory}) async {
              executedArguments.add(arguments);
              if (executable == 'git') {
                return ProcessResult(0, 0, 'README.md\n', '');
              }
              return ProcessResult(0, 0, 'Success', '');
            },
      );

      final bool result = await command.run();
      expect(result, isTrue);

      // Verify that dart format and analyze were NEVER called.
      expect(executedArguments.any((args) => args.contains('format')), isFalse);
      expect(executedArguments.any((args) => args.contains('analyze')), isFalse);
    });
    test('runs native formatter when native files are staged', () async {
      final List<List<String>> executedArguments = [];
      final command = PreCommitCommand(
        processRunner:
            (String executable, List<String> arguments, {String? workingDirectory}) async {
              executedArguments.add(arguments);
              if (executable == 'git') {
                return ProcessResult(0, 0, 'packages/pkg/ios/Classes/Foo.m\n', '');
              }
              return ProcessResult(0, 0, 'Success', '');
            },
      );

      final bool result = await command.run();
      expect(result, isTrue);

      expect(
        executedArguments.any(
          (args) =>
              args.contains('format') && args.contains('--no-dart') && args.contains('--no-java'),
        ),
        isTrue,
      );
    });
  });
}
