// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: avoid_print

import 'dart:io';
import 'package:args/command_runner.dart';

/// The author name used in evaluation test commits.
const String evalAuthorName = 'Eval Author';

/// The author email used in evaluation test commits.
const String evalAuthorEmail = 'eval-author@example.com';

/// The command that implements the pre-push githook.
class PrePushCommand extends Command<bool> {
  /// Creates a [PrePushCommand].
  PrePushCommand({
    Future<ProcessResult> Function(
      String executable,
      List<String> arguments, {
      String? workingDirectory,
    })?
    processRunner,
  }) : processRunner = processRunner ?? Process.run;

  /// The process runner injected for testing.
  final Future<ProcessResult> Function(
    String executable,
    List<String> arguments, {
    String? workingDirectory,
  })
  processRunner;

  @override
  final String name = 'pre-push';

  @override
  final String description =
      'Validates that recent commits do not contain evaluation test credentials before "git push"';

  @override
  Future<bool> run() async {
    print('Running pre-push validation...');

    final ProcessResult logResult = await processRunner('git', <String>[
      'log',
      '-n',
      '20',
      '--format=%h | Author: %an <%ae> | Committer: %cn <%ce> | %s',
    ]);

    if (logResult.exitCode != 0) {
      print('Failed to check git commit history.');
      if (logResult.stderr.toString().isNotEmpty) {
        print(logResult.stderr);
      }
      return false;
    }

    final stdoutStr = logResult.stdout as String;
    final List<String> commitLines = stdoutStr
        .split('\n')
        .map((String line) => line.trim())
        .where((String line) => line.isNotEmpty)
        .toList();

    final forbiddenIdentities = <String>[evalAuthorEmail, evalAuthorName];

    for (final commitLine in commitLines) {
      for (final forbiddenIdentity in forbiddenIdentities) {
        if (commitLine.contains(forbiddenIdentity)) {
          print('''
Pre-push check failed: Found commit(s) authored or committed with evaluation test credentials:
  $commitLine

Evaluation test commits must not be pushed. Clean or rebase your branch before pushing.
To bypass this check, push with --no-verify.''');
          return false;
        }
      }
    }

    print('Pre-push validation passed.');
    return true;
  }
}
