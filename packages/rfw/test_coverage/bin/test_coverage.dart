// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: avoid_print

import 'dart:io';

import 'package:lcov_parser/lcov_parser.dart' as lcov;

// After you run this script, `.../rfw/coverage/lcov.info` will represent the
// latest coverage information for the package. Load that file into your IDE's
// coverage mode to see what lines need coverage.
// In Emacs, that's `M-x coverlay-load-file`, for example.
// (If you're using Emacs, you may need to set the variable `coverlay:base-path`
// first (make sure it has a trailing slash), then load the overlay file, and
// once it is loaded you can call `M-x coverlay-display-stats` to get a summary
// of the files to look at.)

// Please update these targets when you update this package.
// Please ensure that test coverage continues to be 100%.
const int targetLines = 3114;
const String targetPercent = '100';
const String lastUpdate = '2023-06-29';

Future<void> main(List<String> arguments) async {
  // This script is mentioned in the README.md file.

  final Directory coverageDirectory = Directory('coverage');

  if (coverageDirectory.existsSync()) {
    coverageDirectory.deleteSync(recursive: true);
  }

  final ProcessResult result = Process.runSync(
    'flutter',
    <String>['test', '--coverage'],
  );
  if (result.exitCode != 0) {
    print(result.stdout);
    print(result.stderr);
    print('Tests failed.');
    // leave coverage directory around to aid debugging
    exit(1);
  }

  if (Platform.environment.containsKey('CHANNEL') &&
      Platform.environment['CHANNEL'] != 'master' &&
      Platform.environment['CHANNEL'] != 'main') {
    print(
      'Tests passed. (Coverage verification skipped; currently on ${Platform.environment['CHANNEL']} channel.)',
    );
    coverageDirectory.deleteSync(recursive: true);
    exit(0);
  }

  final List<lcov.Record> records = await lcov.Parser.parse(
    'coverage/lcov.info',
  );
  int totalLines = 0;
  int coveredLines = 0;
  for (final lcov.Record record in records) {
    totalLines += record.lines?.found ?? 0;
    coveredLines += record.lines?.hit ?? 0;
  }
  if (totalLines == 0 || totalLines < coveredLines) {
    print('Failed to compute coverage.');
    exit(1);
  }

  final String coveredPercent =
      (100.0 * coveredLines / totalLines).toStringAsFixed(1);

  // We only check the TARGET_LINES matches, not the TARGET_PERCENT,
  // because we expect the percentage to drop over time as Dart fixes
  // various bugs in how it determines what lines are coverable.
  if (coveredLines < targetLines) {
    print('');
    print('                  ╭──────────────────────────────╮');
    print('                  │ COVERAGE REGRESSION DETECTED │');
    print('                  ╰──────────────────────────────╯');
    print('');
    print(
      'Coverage has reduced to only $coveredLines lines ($coveredPercent%). This is lower than',
    );
    print(
      'it was as of $lastUpdate, when coverage was $targetPercent%, covering $targetLines lines.',
    );
    print(
      'Please add sufficient tests to get coverage back to 100%, and update',
    );
    print(
      'test_coverage/bin/test_coverage.dart to have the appropriate targets.',
    );
    print('');
    print(
      'When in doubt, ask @Hixie for advice. Thanks!',
    );
    exit(1);
  } else {
    if (coveredLines < totalLines) {
      print(
        'Warning: Coverage of package:rfw is no longer 100%. (Coverage is now $coveredPercent%.)',
      );
    }
    if (coveredLines > targetLines) {
      print(
        'test_coverage/bin/test_coverage.dart should be updated to have a new target ($coveredLines).',
      );
    }
  }

  coverageDirectory.deleteSync(recursive: true);
}
