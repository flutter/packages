// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';

import '../evals/test_data/test_utils.dart';

void main(List<String> args) {
  var remote = 'origin';
  var baseBranch = 'main';
  var head = 'HEAD';

  for (final arg in args) {
    if (arg.startsWith('--remote=')) {
      remote = arg.substring('--remote='.length);
    } else if (arg.startsWith('--base-branch=')) {
      baseBranch = arg.substring('--base-branch='.length);
    } else if (arg.startsWith('--head=')) {
      head = arg.substring('--head='.length);
    }
  }

  // Fetch upstream to ensure base branch is available.
  final ProcessResult fetchResult = Process.runSync('git', <String>['fetch', remote, baseBranch]);
  if (fetchResult.exitCode != 0) {
    stderr.writeln('Warning: Failed to fetch $remote/$baseBranch: ${fetchResult.stderr}');
  }

  // Format '%an <%ae>' extracts the commit Author Name (%an) and Author Email (%ae),
  // for example: "Eval Author <eval-author@example.com>".
  final ProcessResult result = Process.runSync('git', <String>[
    'log',
    '$remote/$baseBranch..$head',
    '--format=%an <%ae>',
  ]);

  if (result.exitCode != 0) {
    stderr.writeln(
      'ERROR: Failed to run git log for $remote/$baseBranch..$head:\n${result.stderr}',
    );
    exitCode = result.exitCode;
    return;
  }

  final logOutput = result.stdout.toString();

  final List<String> authors = logOutput
      .split('\n')
      .map((String line) => line.trim())
      .where((String line) => line.isNotEmpty)
      .toList();

  final forbidden = <String>[
    evalAuthorEmail,
    evalAuthorName,
    'author@example.com',
  ];

  final violatingAuthors = <String>[];
  for (final author in authors) {
    for (final pattern in forbidden) {
      if (author.contains(pattern)) {
        violatingAuthors.add(author);
        break;
      }
    }
  }

  if (violatingAuthors.isNotEmpty) {
    stderr.writeln(
      'ERROR: Found commit(s) authored by evaluation test credentials:\n'
      '  ${violatingAuthors.toSet().join('\n  ')}\n'
      'Evaluation test commits must not be pushed. Clean or rebase your branch before pushing.',
    );
    exitCode = 1;
    return;
  }

}
