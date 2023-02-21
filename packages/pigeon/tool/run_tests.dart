// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: avoid_print

////////////////////////////////////////////////////////////////////////////////
/// CI entrypoint for running Pigeon tests.
///
/// For any use other than CI, use test.dart instead.
////////////////////////////////////////////////////////////////////////////////
import 'dart:io';

import 'package:path/path.dart' as p;

import 'shared/generation.dart';
import 'shared/test_runner.dart';
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

Future<void> _validateGeneratedTestFiles() async {
  final String baseDir = p.dirname(p.dirname(Platform.script.toFilePath()));
  final String repositoryRoot = p.dirname(p.dirname(baseDir));
  final String relativePigeonPath = p.relative(baseDir, from: repositoryRoot);

  print('Validating generated files:');
  print('  Generating output...');
  final int generateExitCode = await generatePigeons(baseDir: baseDir);
  if (generateExitCode != 0) {
    print('Generation failed; see above for errors.');
    exit(generateExitCode);
  }

  print('  Formatting output...');
  final int formatExitCode =
      await formatAllFiles(repositoryRoot: repositoryRoot);
  if (formatExitCode != 0) {
    print('Formatting failed; see above for errors.');
    exit(formatExitCode);
  }

  print('  Checking for changes...');
  final List<String> modifiedFiles = await _modifiedFiles(
      repositoryRoot: repositoryRoot, relativePigeonPath: relativePigeonPath);

  if (modifiedFiles.isEmpty) {
    return;
  }

  print('The following files are not updated, or not formatted correctly:');
  modifiedFiles.map((String line) => '  $line').forEach(print);

  print('\nTo fix run "dart run tool/generate.dart --format" from the pigeon/ '
      'directory, or apply the diff with the command below.\n');

  final ProcessResult diffResult = await Process.run(
    'git',
    <String>['diff', relativePigeonPath],
    workingDirectory: repositoryRoot,
  );
  if (diffResult.exitCode != 0) {
    print('Unable to determine diff.');
    exit(1);
  }
  print('patch -p1 <<DONE');
  print(diffResult.stdout);
  print('DONE');
  exit(1);
}

Future<List<String>> _modifiedFiles(
    {required String repositoryRoot,
    required String relativePigeonPath}) async {
  final ProcessResult result = await Process.run(
    'git',
    <String>['ls-files', '--modified', relativePigeonPath],
    workingDirectory: repositoryRoot,
  );
  if (result.exitCode != 0) {
    print('Unable to determine changed files.');
    print(result.stdout);
    print(result.stderr);
    exit(1);
  }
  return (result.stdout as String)
      .split('\n')
      .map((String line) => line.trim())
      .where((String line) => line.isNotEmpty)
      .toList();
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
  // TODO(stuartmorgan): Move everything to LUCI, and eliminate the LUCI/Cirrus
  // separation. See https://github.com/flutter/flutter/issues/120231.
  const List<String> macOSHostLuciTests = <String>[
    iOSObjCUnitTests,
    // TODO(stuartmorgan): Enable by default once CI issues are solved; see
    // https://github.com/flutter/packages/pull/2816.
    //iOSObjCIntegrationTests,
    // Currently these are testing exactly the same thing as
    // macOSSwiftIntegrationTests, so we don't need to run both by default. This
    // should be enabled if any iOS-only tests are added (e.g., for a feature
    // not supported by macOS).
    // iOSSwiftIntegrationTests,
  ];
  const List<String> macOSHostCirrusTests = <String>[
    iOSSwiftUnitTests,
    macOSSwiftUnitTests,
    macOSSwiftIntegrationTests,
  ];
  // Run Windows tests on Windows, since that's the only place they can run.
  const List<String> windowsHostTests = <String>[
    windowsUnitTests,
    windowsIntegrationTests,
  ];

  _validateTestCoverage(<List<String>>[
    linuxHostTests,
    macOSHostLuciTests,
    macOSHostCirrusTests,
    windowsHostTests,
    // Tests that are deliberately not included in CI:
    <String>[
      // See comment in linuxHostTests:
      androidJavaIntegrationTests,
      androidKotlinIntegrationTests,
      // See comments in macOSHostTests:
      iOSObjCIntegrationTests,
      iOSSwiftIntegrationTests,
    ],
  ]);

  // Ensure that all generated files are up to date. This is run only on Linux
  // both to avoid duplication of work, and to avoid issues if different CI
  // configurations have different setups (e.g., different clang-format versions
  // or no clang-format at all).
  if (Platform.isLinux) {
    await _validateGeneratedTestFiles();
  }

  final List<String> testsToRun;
  if (Platform.isMacOS) {
    if (Platform.environment['LUCI_CI'] != null) {
      testsToRun = macOSHostLuciTests;
    } else {
      testsToRun = macOSHostCirrusTests;
    }
  } else if (Platform.isWindows) {
    testsToRun = windowsHostTests;
  } else if (Platform.isLinux) {
    testsToRun = linuxHostTests;
  } else {
    print('Unsupported host platform.');
    exit(2);
  }

  await runTests(testsToRun);
}
