// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';

import 'package:githooks/src/pre_push_command.dart';
import 'package:test/test.dart';

void main() {
  group('pre-push hook', () {
    test('passes when recent commits contain no evaluation credentials', () async {
      final List<List<String>> executedArguments = <List<String>>[];
      final command = PrePushCommand(
        processRunner: (String executable, List<String> arguments, {String? workingDirectory}) async {
          executedArguments.add(arguments);
          if (executable == 'git' && arguments.contains('log')) {
            return ProcessResult(
              0,
              0,
              'abc1234 | Author: Alice <alice@google.com> | Committer: Alice <alice@google.com> | Fix feature\n'
                  'def5678 | Author: Bob <bob@example.com> | Committer: Bob <bob@example.com> | Add unit tests\n',
              '',
            );
          }
          return ProcessResult(0, 0, 'Success', '');
        },
      );

      final bool result = await command.run();
      expect(result, isTrue);

      expect(
        executedArguments,
        anyElement(
          equals(<String>[
            'log',
            '-n',
            '20',
            '--format=%h | Author: %an <%ae> | Committer: %cn <%ce> | %s',
          ]),
        ),
      );
    });

    test('fails when recent commit is authored by Eval Author', () async {
      final command = PrePushCommand(
        processRunner: (String executable, List<String> arguments, {String? workingDirectory}) async {
          if (executable == 'git' && arguments.contains('log')) {
            return ProcessResult(
              0,
              0,
              'abc1234 | Author: Eval Author <contributor@example.com> | Committer: Contributor <contributor@example.com> | Eval change\n',
              '',
            );
          }
          return ProcessResult(0, 0, 'Success', '');
        },
      );

      final bool result = await command.run();
      expect(result, isFalse);
    });

    test('fails when recent commit is authored by eval-author@example.com', () async {
      final command = PrePushCommand(
        processRunner: (String executable, List<String> arguments, {String? workingDirectory}) async {
          if (executable == 'git' && arguments.contains('log')) {
            return ProcessResult(
              0,
              0,
              'abc1234 | Author: Contributor <eval-author@example.com> | Committer: Contributor <contributor@example.com> | Eval change\n',
              '',
            );
          }
          return ProcessResult(0, 0, 'Success', '');
        },
      );

      final bool result = await command.run();
      expect(result, isFalse);
    });

    test('fails when recent commit is committed by Eval Author', () async {
      final command = PrePushCommand(
        processRunner: (String executable, List<String> arguments, {String? workingDirectory}) async {
          if (executable == 'git' && arguments.contains('log')) {
            return ProcessResult(
              0,
              0,
              'abc1234 | Author: Contributor <contributor@example.com> | Committer: Eval Author <contributor@example.com> | Eval change\n',
              '',
            );
          }
          return ProcessResult(0, 0, 'Success', '');
        },
      );

      final bool result = await command.run();
      expect(result, isFalse);
    });

    test('fails when recent commit is committed by eval-author@example.com', () async {
      final command = PrePushCommand(
        processRunner: (String executable, List<String> arguments, {String? workingDirectory}) async {
          if (executable == 'git' && arguments.contains('log')) {
            return ProcessResult(
              0,
              0,
              'abc1234 | Author: Contributor <contributor@example.com> | Committer: Contributor <eval-author@example.com> | Eval change\n',
              '',
            );
          }
          return ProcessResult(0, 0, 'Success', '');
        },
      );

      final bool result = await command.run();
      expect(result, isFalse);
    });

    test('fails when git log execution fails', () async {
      final command = PrePushCommand(
        processRunner:
            (String executable, List<String> arguments, {String? workingDirectory}) async {
              if (executable == 'git' && arguments.contains('log')) {
                return ProcessResult(0, 1, '', 'Git fatal error');
              }
              return ProcessResult(0, 0, 'Success', '');
            },
      );

      final bool result = await command.run();
      expect(result, isFalse);
    });

    test('passes when git log returns empty output', () async {
      final command = PrePushCommand(
        processRunner:
            (String executable, List<String> arguments, {String? workingDirectory}) async {
              if (executable == 'git' && arguments.contains('log')) {
                return ProcessResult(0, 0, '', '');
              }
              return ProcessResult(0, 0, 'Success', '');
            },
      );

      final bool result = await command.run();
      expect(result, isTrue);
    });
  });
}
