// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';

import 'package:args/args.dart';

import 'test_utils.dart';

const String _remoteFlag = 'remote';
const String _baseBranchFlag = 'base-branch';
const String _headFlag = 'head';
const String _helpFlag = 'help';

void main(List<String> args) {
  final parser = ArgParser()
    ..addOption(
      _remoteFlag,
      defaultsTo: 'origin',
      help: 'The git remote to compare against.',
    )
    ..addOption(
      _baseBranchFlag,
      defaultsTo: 'main',
      help: 'The base branch to compare against.',
    )
    ..addOption(
      _headFlag,
      defaultsTo: 'HEAD',
      help: 'The head commit or reference to compare.',
    )
    ..addFlag(
      _helpFlag,
      abbr: 'h',
      negatable: false,
      help: 'Prints usage information.',
    );

  final ArgResults argResults;
  try {
    argResults = parser.parse(args);
  } on FormatException catch (e) {
    stderr.writeln(e.message);
    stderr.writeln(parser.usage);
    exitCode = 1;
    return;
  }

  if (argResults.wasParsed(_helpFlag)) {
    stdout.writeln('Checks git commit history for forbidden evaluation author credentials.\n');
    stdout.writeln(parser.usage);
    return;
  }

  final remote = argResults[_remoteFlag] as String;
  final baseBranch = argResults[_baseBranchFlag] as String;
  final head = argResults[_headFlag] as String;

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
