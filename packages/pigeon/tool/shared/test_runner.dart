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
Future<void> runTests(List<String> testsToRun) async {
  // Pre-generate the necessary common output files.
  // TODO(stuartmorgan): Consider making this conditional on the specific
  // tests being run, as not all of them need these files.
  final String baseDir = p.dirname(p.dirname(Platform.script.toFilePath()));
  print('# Generating platform_test/ output...');
  final int generateExitCode = await generatePigeons(baseDir: baseDir);
  if (generateExitCode == 0) {
    print('Generation complete!');
  } else {
    print('Generation failed; see above for errors.');
  }

  for (final String test in testsToRun) {
    final TestInfo? info = testSuites[test];
    if (info != null) {
      print('##############################');
      print('# Running $test');
      final int testCode = await info.function();
      if (testCode != 0) {
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
