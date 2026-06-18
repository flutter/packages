// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';

import 'package:githooks/src/pre_commit_command.dart';
import 'package:test/test.dart';

void main() {
  group('pre-commit hook', () {
    test('passes when both format and analyze succeed', () async {
      final command = PreCommitCommand(
        processRunner:
            (String executable, List<String> arguments, {String? workingDirectory}) async {
              return ProcessResult(0, 0, 'Success', '');
            },
      );

      final bool result = await command.run();
      expect(result, isTrue);
    });

    test('fails when formatting fails', () async {
      final command = PreCommitCommand(
        processRunner:
            (String executable, List<String> arguments, {String? workingDirectory}) async {
              if (arguments.contains('format')) {
                return ProcessResult(0, 1, 'bad_file.dart', '');
              }
              return ProcessResult(0, 0, 'Success', '');
            },
      );

      final bool result = await command.run();
      expect(result, isFalse);
    });

    test('fails when analysis fails', () async {
      final command = PreCommitCommand(
        processRunner:
            (String executable, List<String> arguments, {String? workingDirectory}) async {
              if (arguments.contains('analyze')) {
                return ProcessResult(0, 1, 'error in file.dart', '');
              }
              return ProcessResult(0, 0, 'Success', '');
            },
      );

      final bool result = await command.run();
      expect(result, isFalse);
    });
  });
}
