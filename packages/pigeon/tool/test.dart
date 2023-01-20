// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: avoid_print

////////////////////////////////////////////////////////////////////////////////
/// Script for executing the Pigeon tests
///
/// usage: dart run tool/run_tests.dart
////////////////////////////////////////////////////////////////////////////////
import 'dart:io' show Platform, exit;
import 'dart:math';

import 'package:args/args.dart';
import 'package:path/path.dart' as p;

import 'shared/generation.dart';
import 'shared/test_suites.dart';

const String _testFlag = 'test';
const String _listFlag = 'list';
const String _skipGenerationFlag = 'skip-generation';

Future<void> main(List<String> args) async {
  final ArgParser parser = ArgParser()
    ..addMultiOption(_testFlag, abbr: 't', help: 'Only run specified tests.')
    ..addFlag(_listFlag,
        negatable: false, abbr: 'l', help: 'List available tests.')
    // Temporarily provide a way for run_test.sh to bypass generation, since
    // it generates before doing anything else.
    // TODO(stuartmorgan): Remove this once run_test.sh is fully migrated to
    // this script.
    ..addFlag(_skipGenerationFlag, negatable: false, hide: true)
    ..addFlag('help',
        negatable: false, abbr: 'h', help: 'Print this reference.');

  final ArgResults argResults = parser.parse(args);
  List<String> testsToRun = <String>[];
  if (argResults.wasParsed(_listFlag)) {
    print('available tests:');

    final int columnWidth =
        testSuites.keys.map((String key) => key.length).reduce(max) + 4;

    for (final MapEntry<String, TestInfo> info in testSuites.entries) {
      print('${info.key.padRight(columnWidth)}- ${info.value.description}');
    }
    exit(0);
  } else if (argResults.wasParsed('help')) {
    print('''
Pigeon run_tests
usage: dart run tool/run_tests.dart [-l | -t <test name>]

${parser.usage}''');
    exit(0);
  } else if (argResults.wasParsed(_testFlag)) {
    testsToRun = argResults[_testFlag];
  }

  if (!argResults.wasParsed(_skipGenerationFlag)) {
    final String baseDir = p.dirname(p.dirname(Platform.script.toFilePath()));
    print('# Generating platform_test/ output...');
    final int generateExitCode = await generatePigeons(baseDir: baseDir);
    if (generateExitCode == 0) {
      print('Generation complete!');
    } else {
      print('Generation failed; see above for errors.');
    }
  }

  // If no tests are provided, run a default based on the host platform. This is
  // the mode used by CI.
  if (testsToRun.isEmpty) {
    const List<String> androidTests = <String>[
      androidJavaUnitTests,
      androidKotlinUnitTests,
      // TODO(stuartmorgan): Include these once CI supports running simulator
      // tests. Currently these tests aren't run in CI.
      // See https://github.com/flutter/flutter/issues/111505.
      // androidJavaIntegrationTests,
      // androidKotlinIntegrationTests,
    ];
    const List<String> macOSTests = <String>[
      macOSSwiftUnitTests,
      macOSSwiftIntegrationTests
    ];
    const List<String> iOSTests = <String>[
      // TODO(stuartmorgan): Replace this with iOSObjCUnitTests once the CI
      // issues are resolved; see https://github.com/flutter/packages/pull/2816.
      iOSObjCUnitTestsLegacy,
      iOSObjCIntegrationTests,
      iOSSwiftUnitTests,
      iOSSwiftIntegrationTests,
    ];
    const List<String> windowsTests = <String>[
      windowsUnitTests,
      windowsIntegrationTests,
    ];
    const List<String> dartTests = <String>[
      dartUnitTests,
      flutterUnitTests,
      mockHandlerTests,
      commandLineTests,
    ];

    if (Platform.isMacOS) {
      testsToRun = <String>[
        ...dartTests,
        ...androidTests,
        ...iOSTests,
        ...macOSTests,
      ];
    } else if (Platform.isWindows) {
      testsToRun = windowsTests;
    } else {
      // TODO(stuartmorgan): Make a new entrypoint for developers that runs
      // all tests their host supports by default, and move some of the tests
      // above here. See https://github.com/flutter/flutter/issues/115393
    }
  }

  for (final String test in testsToRun) {
    final TestInfo? info = testSuites[test];
    if (info != null) {
      print('# Running $test');
      final int testCode = await info.function();
      if (testCode != 0) {
        exit(testCode);
      }
    } else {
      print('unknown test: $test');
      exit(1);
    }
  }
  exit(0);
}
