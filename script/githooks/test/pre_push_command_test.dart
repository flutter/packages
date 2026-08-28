// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';

import 'package:githooks/src/pre_push_command.dart';
import 'package:test/test.dart';

void main() {
  group('pre-push hook', () {
    PrePushCommand createCommand(
      String gitLogOutput, {
      int exitCode = 0,
      String? stderr = '',
      List<List<String>>? capturedArgs,
    }) {
      return PrePushCommand(
        processRunner:
            (String executable, List<String> arguments, {String? workingDirectory}) async {
              capturedArgs?.add(arguments);
              if (executable == 'git' && arguments.contains('log')) {
                return ProcessResult(0, exitCode, gitLogOutput, stderr);
              }
              return ProcessResult(0, 0, 'Success', '');
            },
      );
    }

    String formatCommit({
      String sha = 'abc1234',
      String authorName = 'Alice',
      String authorEmail = 'alice@google.com',
      String committerName = 'Alice',
      String committerEmail = 'alice@google.com',
      String subject = 'Valid commit',
    }) {
      return '$sha\u0000$authorName\u0000$authorEmail\u0000$committerName\u0000$committerEmail\u0000$subject\n';
    }

    test('passes when recent commits contain no evaluation credentials', () async {
      final executedArguments = <List<String>>[];
      final PrePushCommand command = createCommand(
        '${formatCommit(subject: 'Fix feature')}'
        '${formatCommit(sha: 'def5678', authorName: 'Bob', authorEmail: 'bob@example.com', committerName: 'Bob', committerEmail: 'bob@example.com', subject: 'Add unit tests')}',
        capturedArgs: executedArguments,
      );

      final bool result = await command.run();
      expect(result, isTrue);

      expect(
        executedArguments,
        anyElement(
          equals(<String>['log', '-n', '20', '--format=%h%x00%an%x00%ae%x00%cn%x00%ce%x00%s']),
        ),
      );
    });

    test('passes when commit message contains eval credentials in subject', () async {
      final PrePushCommand command = createCommand(
        formatCommit(subject: 'Fix bug with eval-author@example.com and Eval Author'),
      );

      final bool result = await command.run();
      expect(result, isTrue);
    });

    test('fails when recent commit is authored by Eval Author', () async {
      final PrePushCommand command = createCommand(formatCommit(authorName: 'Eval Author'));

      final bool result = await command.run();
      expect(result, isFalse);
    });

    test('fails when recent commit is authored by eval-author@example.com', () async {
      final PrePushCommand command = createCommand(
        formatCommit(authorEmail: 'eval-author@example.com'),
      );

      final bool result = await command.run();
      expect(result, isFalse);
    });

    test('fails when recent commit is committed by Eval Author', () async {
      final PrePushCommand command = createCommand(formatCommit(committerName: 'Eval Author'));

      final bool result = await command.run();
      expect(result, isFalse);
    });

    test('fails when recent commit is committed by eval-author@example.com', () async {
      final PrePushCommand command = createCommand(
        formatCommit(committerEmail: 'eval-author@example.com'),
      );

      final bool result = await command.run();
      expect(result, isFalse);
    });

    test('fails when git log execution fails', () async {
      final PrePushCommand command = createCommand('', exitCode: 1, stderr: 'Git fatal error');

      final bool result = await command.run();
      expect(result, isFalse);
    });

    test('fails when git log execution fails with null stderr', () async {
      final PrePushCommand command = createCommand('', exitCode: 1, stderr: null);

      final bool result = await command.run();
      expect(result, isFalse);
    });

    test('passes when git log returns empty output', () async {
      final PrePushCommand command = createCommand('');

      final bool result = await command.run();
      expect(result, isTrue);
    });
  });
}
