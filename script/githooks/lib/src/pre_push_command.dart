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

/// The command that implements the `pre-push` Git hook.
///
/// It inspects the last 20 commits in git history to ensure no commits
/// were authored or committed using evaluation test credentials (`Eval Author`
/// or `eval-author@example.com`).
///
/// Checking the last 20 commits keeps the hook simple and deterministic,
/// avoiding complex diff calculations against arbitrary remote branches or
/// tracking whether a branch has an open pull request under review.
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
      '--format=%h%x00%an%x00%ae%x00%cn%x00%ce%x00%s',
    ]);

    if (logResult.exitCode != 0) {
      print('Failed to check git commit history.');
      if (logResult.stderr.toString().isNotEmpty) {
        print(logResult.stderr);
      }
      return false;
    }

    final stdoutStr = logResult.stdout as String;
    final List<String> commitEntries = stdoutStr
        .split('\n')
        .map((String line) => line.trim())
        .where((String line) => line.isNotEmpty)
        .toList();

    for (final entry in commitEntries) {
      final List<String> fields = entry.split('\u0000');
      if (fields.length < 6) {
        continue;
      }
      final String sha = fields[0];
      final String authorName = fields[1];
      final String authorEmail = fields[2];
      final String committerName = fields[3];
      final String committerEmail = fields[4];
      final String subject = fields[5];

      if (authorName == evalAuthorName ||
          authorEmail == evalAuthorEmail ||
          committerName == evalAuthorName ||
          committerEmail == evalAuthorEmail) {
        print('''
Pre-push check failed: Found commit(s) authored or committed with evaluation test credentials:
  $sha | Author: $authorName <$authorEmail> | Committer: $committerName <$committerEmail> | $subject

Evaluation test commits must not be pushed. Clean or rebase your branch before pushing.
To bypass this check, push with --no-verify.''');
        return false;
      }
    }

    print('Pre-push validation passed.');
    return true;
  }
}
