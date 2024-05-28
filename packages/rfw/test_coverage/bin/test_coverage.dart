// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: avoid_print

import 'dart:io';

import 'package:lcov_parser/lcov_parser.dart' as lcov;
import 'package:meta/meta.dart';

// After you run `flutter test --coverage`, `.../rfw/coverage/lcov.info` will
// represent the latest coverage information for the package. Load that file
// into your IDE's coverage mode to see what lines need coverage.
// In Emacs, that's `M-x coverlay-load-file`, for example.
// (If you're using Emacs, you may need to set the variable `coverlay:base-path`
// first (make sure it has a trailing slash), then load the overlay file, and
// once it is loaded you can call `M-x coverlay-display-stats` to get a summary
// of the files to look at.)

// If Dart coverage increases the number of lines that could be covered, it is
// possible that this package will no longer report 100% coverage even though
// nothing has changed about the package itself. In the event that that happens,
// set this constant to the number of lines currently being covered and file a
// bug, cc'ing the current package owner (Hixie) so that they can add more tests.
const int? targetLines = null;

@immutable
final class LcovLine {
  const LcovLine(this.filename, this.line);
  final String filename;
  final int line;

  @override
  int get hashCode => Object.hash(filename, line);

  @override
  bool operator ==(Object other) {
    return other is LcovLine &&
        other.line == line &&
        other.filename == filename;
  }

  @override
  String toString() {
    return '$filename:$line';
  }
}

Future<void> main(List<String> arguments) async {
  // This script is mentioned in the CONTRIBUTING.md file.

  final Directory coverageDirectory = Directory('coverage');

  if (coverageDirectory.existsSync()) {
    coverageDirectory.deleteSync(recursive: true);
  }

  final ProcessResult result = Process.runSync(
    'flutter',
    <String>[
      'test',
      '--coverage',
      if (arguments.isNotEmpty) ...arguments,
    ],
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

  final List<File> libFiles = Directory('lib')
      .listSync(recursive: true)
      .whereType<File>()
      .where((File file) => file.path.endsWith('.dart'))
      .toList();
  final Set<LcovLine> flakyLines = <LcovLine>{};
  final Set<LcovLine> deadLines = <LcovLine>{};
  for (final File file in libFiles) {
    int lineNumber = 0;
    for (final String line in file.readAsLinesSync()) {
      lineNumber += 1;
      if (line.endsWith('// dead code on VM target')) {
        deadLines.add(LcovLine(file.path, lineNumber));
      }
      if (line.endsWith('// https://github.com/dart-lang/sdk/issues/53349')) {
        flakyLines.add(LcovLine(file.path, lineNumber));
      }
    }
  }

  final List<lcov.Record> records = await lcov.Parser.parse(
    'coverage/lcov.info',
  );
  int totalLines = 0;
  int coveredLines = 0;
  bool deadLinesError = false;
  for (final lcov.Record record in records) {
    if (record.lines != null) {
      totalLines += record.lines!.found ?? 0;
      coveredLines += record.lines!.hit ?? 0;
      if (record.file != null && record.lines!.details != null) {
        for (int index = 0; index < record.lines!.details!.length; index += 1) {
          if (record.lines!.details![index].hit != null &&
              record.lines!.details![index].line != null) {
            final LcovLine line = LcovLine(
              record.file!,
              record.lines!.details![index].line!,
            );
            if (flakyLines.contains(line)) {
              totalLines -= 1;
              if (record.lines!.details![index].hit! > 0) {
                coveredLines -= 1;
              }
            }
            if (deadLines.contains(line)) {
              deadLines.remove(line);
              totalLines -= 1;
              if (record.lines!.details![index].hit! > 0) {
                print(
                  '$line: Line is marked as being dead code but was nonetheless covered.',
                );
                deadLinesError = true;
              }
            }
          }
        }
      }
    }
  }
  if (deadLines.isNotEmpty || deadLinesError) {
    for (final LcovLine line in deadLines) {
      print(
        '$line: Line is marked as being undetectably dead code but was not considered reachable.',
      );
    }
    print(
      'Consider removing the "dead code on VM target" comment from affected lines.',
    );
    exit(1);
  }
  if (totalLines <= 0 || totalLines < coveredLines) {
    print('Failed to compute coverage correctly.');
    exit(1);
  }

  final String coveredPercent =
      (100.0 * coveredLines / totalLines).toStringAsFixed(1);

  if (targetLines != null) {
    if (targetLines! < totalLines) {
      print(
        'Warning: test_coverage has an override set to reduce the expected number of covered lines from $totalLines to $targetLines.\n'
        'New tests should be written to cover all lines in the package.',
      );
      totalLines = targetLines!;
    } else if (targetLines == totalLines) {
      print(
        'Warning: test_coverage has a redundant targetLines; it is equal to the actual number of coverable lines ($totalLines).\n'
        'Update test_coverage.dart to set the targetLines constant to null.',
      );
    } else {
      print(
        'Warning: test_coverage has an outdated targetLines ($targetLines) that is above the total number of lines in the package ($totalLines).\n'
        'Update test_coverage.dart to set the targetLines constant to null.',
      );
    }
  }

  if (coveredLines < totalLines) {
    print('');
    print('                  ╭──────────────────────────────╮');
    print('                  │ COVERAGE REGRESSION DETECTED │');
    print('                  ╰──────────────────────────────╯');
    print('');
    print(
      'Coverage has reduced to only $coveredLines lines ($coveredPercent%), out\n'
      'of $totalLines total lines; ${totalLines - coveredLines} lines are not covered by tests.\n'
      'Please add sufficient tests to get coverage back to 100%.',
    );
    print('');
    print(
      'When in doubt, ask @Hixie for advice. Thanks!',
    );
    exit(1);
  }

  coverageDirectory.deleteSync(recursive: true);
}
