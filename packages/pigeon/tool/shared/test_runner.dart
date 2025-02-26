// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: avoid_print

import 'dart:io';

import 'package:path/path.dart' as p;

import 'generation.dart';
import 'test_suites.dart';

/// Runs the given tests, printing status and exiting with failure if any of
/// them fails.
Future<void> runTests(
  List<String> testsToRun, {
  bool runFormat = false,
  bool runGeneration = true,
  bool ciMode = false,
  bool includeOverflow = false,
}) async {
  final String baseDir = p.dirname(p.dirname(Platform.script.toFilePath()));
  if (runGeneration) {
    await _runGenerate(baseDir, ciMode: ciMode);
  }

  if (runFormat) {
    await _runFormat(baseDir, ciMode: ciMode);
  }

  await _runTests(testsToRun, ciMode: ciMode);

  if (includeOverflow) {
    await _runGenerate(baseDir, ciMode: ciMode, includeOverflow: true);

    // TODO(tarrinneal): Remove linux filter once overflow class is added to gobject generator.
    // https://github.com/flutter/flutter/issues/152916
    await _runTests(
        testsToRun
            .where((String test) =>
                test.contains('integration') && !test.contains('linux'))
            .toList(),
        ciMode: ciMode);

    if (!ciMode) {
      await _runGenerate(baseDir, ciMode: ciMode);
    }

    if (!ciMode && (runFormat || !runGeneration)) {
      await _runFormat(baseDir, ciMode: ciMode);
    }
  }
}

// Pre-generate the necessary common output files.
Future<void> _runGenerate(
  String baseDir, {
  required bool ciMode,
  bool includeOverflow = false,
}) async {
  // TODO(stuartmorgan): Consider making this conditional on the specific
  // tests being run, as not all of them need these files.
  _printHeading('Generating platform_test/ output', ciMode: ciMode);
  final int generateExitCode = await generateTestPigeons(
    baseDir: baseDir,
    includeOverflow: includeOverflow,
  );
  if (generateExitCode == 0) {
    print('Generation complete!');
  } else {
    print('Generation failed; see above for errors.');
  }
}

Future<void> _runFormat(String baseDir, {required bool ciMode}) async {
  _printHeading('Formatting generated output', ciMode: ciMode);
  final int formatExitCode =
      await formatAllFiles(repositoryRoot: p.dirname(p.dirname(baseDir)));
  if (formatExitCode != 0) {
    print('Formatting failed; see above for errors.');
    exit(formatExitCode);
  }
}

Future<void> _runTests(
  List<String> testsToRun, {
  required bool ciMode,
}) async {
  for (final String test in testsToRun) {
    final TestInfo? info = testSuites[test];
    if (info != null) {
      _printHeading('Running $test', ciMode: ciMode);
      final int testCode = await info.function(ciMode: ciMode);
      if (testCode != 0) {
        print('# Failed, exit code: $testCode');
        exit(testCode);
      }
      print('');
      print('');
    } else {
      print('Unknown test: $test');
      exit(1);
    }
  }
}

void _printHeading(String heading, {required bool ciMode}) {
  String timestamp = '';
  if (ciMode) {
    final DateTime now = DateTime.now();
    timestamp = ' [start time ${now.hour}:${now.minute}:${now.second}]';
  }
  print('##############################');
  print('# $heading$timestamp');
}
