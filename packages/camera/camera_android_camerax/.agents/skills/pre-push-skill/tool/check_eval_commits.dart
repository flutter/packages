// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';

import '../evals/test_data/test_utils.dart';

void main() {
  // Fetch upstream main if available to compare against.
  Process.runSync('git', <String>['fetch', 'origin', 'main']);

  final ProcessResult result = Process.runSync('git', <String>[
    'log',
    'origin/main..HEAD',
    '--format=%an <%ae>',
  ]);

  final logOutput = result.exitCode == 0
      ? result.stdout.toString()
      : (Process.runSync('git', <String>[
          'log',
          '-n',
          '20',
          '--format=%an <%ae>',
        ]).stdout as String);

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
    exit(1);
  }

  stdout.writeln('No evaluation test commits found.');
}
