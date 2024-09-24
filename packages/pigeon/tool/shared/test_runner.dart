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
    await _runGenerate(baseDir);
  }

  if (runFormat) {
    await _runFormat(baseDir);
  }

  await _runTests(testsToRun, ciMode: ciMode);

  if (includeOverflow) {
    await _runGenerate(baseDir, includeOverflow: true);

    // TODO(tarrinneal): Remove linux filter once overflow class is added to gobject generator.
    // https://github.com/flutter/flutter/issues/152916
    await _runTests(testsToRun
        .where((String test) =>
            test.contains('integration') && !test.contains('linux'))
        .toList());

    if (!ciMode) {
      await _runGenerate(baseDir);
    }

    if (!ciMode && (runFormat || !runGeneration)) {
      await _runFormat(baseDir);
    }
  }
}

// Pre-generate the necessary common output files.
Future<void> _runGenerate(String baseDir,
    {bool includeOverflow = false}) async {
  // TODO(stuartmorgan): Consider making this conditional on the specific
  // tests being run, as not all of them need these files.
  print('# Generating platform_test/ output...');
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

Future<void> _runFormat(String baseDir) async {
  print('Formatting generated output...');
  final int formatExitCode =
      await formatAllFiles(repositoryRoot: p.dirname(p.dirname(baseDir)));
  if (formatExitCode != 0) {
    print('Formatting failed; see above for errors.');
    exit(formatExitCode);
  }
}

Future<void> _runTests(
  List<String> testsToRun, {
  bool ciMode = true,
}) async {
  for (final String test in testsToRun) {
    final TestInfo? info = testSuites[test];
    if (info != null) {
      print('##############################');
      print('# Running $test');
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
