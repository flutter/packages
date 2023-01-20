// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: avoid_print

////////////////////////////////////////////////////////////////////////////////
/// CI entrypoint for running Pigeon tests.
///
/// For any use other than CI, use test.dart instead.
////////////////////////////////////////////////////////////////////////////////
import 'dart:io' show Platform, exit;

import 'package:path/path.dart' as p;

import 'shared/generation.dart';
import 'shared/test_suites.dart';

/// Exits with failure if any tests in [testSuites] are not included in any of
/// the given test [shards].
void _validateTestCoverage(List<List<String>> shards) {
  final Set<String> missing = testSuites.keys.toSet();
  shards.forEach(missing.removeAll);

  if (missing.isNotEmpty) {
    print('The following test suites are not being run on any host:');
    for (final String suite in missing) {
      print('  $suite');
    }
    exit(1);
  }
}

Future<void> main(List<String> args) async {
  // Run most tests on Linux, since Linux tends to be the easiest and cheapest.
  const List<String> linuxHostTests = <String>[
    dartUnitTests,
    flutterUnitTests,
    mockHandlerTests,
    commandLineTests,
    androidJavaUnitTests,
    androidKotlinUnitTests,
    // TODO(stuartmorgan): Include these once CI supports running simulator
    // tests. Currently these tests aren't run in CI.
    // See https://github.com/flutter/flutter/issues/111505.
    // androidJavaIntegrationTests,
    // androidKotlinIntegrationTests,
  ];
  // Run macOS and iOS tests on macOS, since that's the only place they can run.
  const List<String> macOSHostTests = <String>[
    // TODO(stuartmorgan): Replace this with iOSObjCUnitTests once the CI
    // issues are resolved; see https://github.com/flutter/packages/pull/2816.
    iOSObjCUnitTestsLegacy,
    // TODO(stuartmorgan): Enable by default once CI issues are solved; see
    // https://github.com/flutter/packages/pull/2816.
    // iOSObjCIntegrationTests,
    iOSSwiftUnitTests,
    // Currently these are testing exactly the same thing as
    // macos_swift_e2e_tests, so we don't need to run both by default. This
    // should be enabled if any iOS-only tests are added (e.g., for a feature
    // not supported by macOS).
    // iOSSwiftIntegrationTests,
  ];
  // Run Windows tests on Windows, since that's the only place they can run.
  const List<String> windowsHostTests = <String>[
    windowsUnitTests,
    windowsIntegrationTests,
  ];

  _validateTestCoverage(<List<String>>[
    linuxHostTests,
    macOSHostTests,
    windowsHostTests,
    // Tests that are deliberately not included in CI:
    <String>[
      // See TODO in linuxHostTests:
      androidJavaIntegrationTests,
      androidKotlinIntegrationTests,
      // See TODO in macOSHostTests:
      iOSObjCUnitTests,
    ],
  ]);

  // Pre-generate the necessary output files.
  final String baseDir = p.dirname(p.dirname(Platform.script.toFilePath()));
  print('# Generating platform_test/ output...');
  final int generateExitCode = await generatePigeons(baseDir: baseDir);
  if (generateExitCode == 0) {
    print('Generation complete!');
  } else {
    print('Generation failed; see above for errors.');
  }

  final List<String> testsToRun;
  if (Platform.isMacOS) {
    testsToRun = macOSHostTests;
  } else if (Platform.isWindows) {
    testsToRun = windowsHostTests;
  } else if (Platform.isLinux) {
    testsToRun = linuxHostTests;
  } else {
    print('Unsupported host platform.');
    exit(2);
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
