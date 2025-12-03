// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: avoid_print

////////////////////////////////////////////////////////////////////////////////
/// CI entrypoint for running Pigeon tests.
///
/// For any use other than CI, use test.dart instead.
////////////////////////////////////////////////////////////////////////////////
library;

import 'dart:io';

import 'package:collection/collection.dart';
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
    for (final suite in missing) {
      print('  $suite');
    }
    exit(1);
  }
}

Future<void> _validateGeneratedTestFiles() async {
  await _validateGeneratedFiles(
    (String baseDir) => generateTestPigeons(baseDir: baseDir),
    generationMessage: 'Generating test output',
    incorrectFilesMessage:
        'The following files are not updated, or not formatted correctly:',
  );
}

Future<void> _validateGeneratedExampleFiles() async {
  await _validateGeneratedFiles(
    (String _) => generateExamplePigeons(),
    generationMessage: 'Generating example output',
    incorrectFilesMessage:
        'Either messages.dart and messages_test.dart have non-matching definitions or\n'
        'the following files are not updated, or not formatted correctly:',
  );
}

Future<void> _validateGeneratedFiles(
  Future<int> Function(String baseDirectory) generator, {
  required String generationMessage,
  required String incorrectFilesMessage,
}) async {
  // Generated file validation is split by platform, both to avoid duplication
  // of work, and to avoid issues if different CI configurations have different
  // setups (e.g., different clang-format versions or no clang-format at all).
  final Set<GeneratorLanguage> languagesToValidate;
  if (Platform.isLinux) {
    languagesToValidate = <GeneratorLanguage>{
      GeneratorLanguage.cpp,
      GeneratorLanguage.dart,
      GeneratorLanguage.gobject,
      GeneratorLanguage.java,
      GeneratorLanguage.kotlin,
      GeneratorLanguage.objc,
    };
  } else if (Platform.isMacOS) {
    languagesToValidate = <GeneratorLanguage>{GeneratorLanguage.swift};
  } else {
    return;
  }

  final String baseDir = p.dirname(p.dirname(Platform.script.toFilePath()));
  final String repositoryRoot = p.dirname(p.dirname(baseDir));
  final String relativePigeonPath = p.relative(baseDir, from: repositoryRoot);

  print('Validating generated files:');
  print('  $generationMessage...');

  int generateExitCode = await generateExamplePigeons();

  if (generateExitCode != 0) {
    print('Generation failed; see above for errors.');
    exit(generateExitCode);
  }

  generateExitCode = await generateTestPigeons(baseDir: baseDir);

  if (generateExitCode != 0) {
    print('Generation failed; see above for errors.');
    exit(generateExitCode);
  }

  print('  Formatting output...');
  final int formatExitCode = await formatAllFiles(
    repositoryRoot: repositoryRoot,
    languages: languagesToValidate,
  );
  if (formatExitCode != 0) {
    print('Formatting failed; see above for errors.');
    exit(formatExitCode);
  }

  print('  Checking for changes...');
  final List<String> modifiedFiles = await _modifiedFiles(
    repositoryRoot: repositoryRoot,
    relativePigeonPath: relativePigeonPath,
  );
  final Set<String> extensions = languagesToValidate
      .map((GeneratorLanguage lang) => _extensionsForLanguage(lang))
      .flattened
      .toSet();
  final Iterable<String> filteredFiles = modifiedFiles.where(
    (String path) =>
        extensions.contains(p.extension(path).replaceFirst('.', '')),
  );

  if (filteredFiles.isEmpty) {
    return;
  }

  print(incorrectFilesMessage);
  filteredFiles.map((String line) => '  $line').forEach(print);

  print(
    '\nTo fix run "dart run tool/generate.dart --format" from the pigeon/ '
    'directory, or apply the diff with the command below.\n',
  );

  final ProcessResult diffResult = await Process.run('git', <String>[
    'diff',
    ...filteredFiles,
  ], workingDirectory: repositoryRoot);
  if (diffResult.exitCode != 0) {
    print('Unable to determine diff.');
    exit(1);
  }
  print('patch -p1 <<DONE');
  print(diffResult.stdout);
  print('DONE');
  exit(1);
}

Set<String> _extensionsForLanguage(GeneratorLanguage language) {
  return switch (language) {
    GeneratorLanguage.cpp => <String>{'cc', 'cpp', 'h'},
    GeneratorLanguage.dart => <String>{'dart'},
    GeneratorLanguage.gobject => <String>{'cc', 'h'},
    GeneratorLanguage.java => <String>{'java'},
    GeneratorLanguage.kotlin => <String>{'kt'},
    GeneratorLanguage.swift => <String>{'swift'},
    GeneratorLanguage.objc => <String>{'h', 'm', 'mm'},
  };
}

Future<List<String>> _modifiedFiles({
  required String repositoryRoot,
  required String relativePigeonPath,
}) async {
  final ProcessResult result = await Process.run('git', <String>[
    'ls-files',
    '--modified',
    relativePigeonPath,
  ], workingDirectory: repositoryRoot);
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
  const linuxHostTests = <String>[
    commandLineTests,
    androidJavaUnitTests,
    androidJavaLint,
    androidKotlinUnitTests,
    androidKotlinLint,
    androidJavaIntegrationTests,
    androidKotlinIntegrationTests,
    linuxUnitTests,
    linuxIntegrationTests,
  ];
  const macOSHostTests = <String>[
    iOSObjCUnitTests,
    // Currently these are testing exactly the same thing as
    // macOS*IntegrationTests, so we don't need to run both by default. This
    // should be enabled if any iOS-only tests are added (e.g., for a feature
    // not supported by macOS).
    // iOSObjCIntegrationTests,
    // iOSSwiftIntegrationTests,
    iOSSwiftUnitTests,
    macOSObjCIntegrationTests,
    macOSSwiftUnitTests,
    macOSSwiftIntegrationTests,
  ];
  // Run Windows tests on Windows, since that's the only place they can run.
  const windowsHostTests = <String>[windowsUnitTests, windowsIntegrationTests];

  _validateTestCoverage(<List<String>>[
    linuxHostTests,
    macOSHostTests,
    windowsHostTests,
    // Tests that are deliberately not included in CI:
    <String>[
      // See comments in macOSHostTests:
      iOSObjCIntegrationTests,
      iOSSwiftIntegrationTests,
      // These are Dart unit tests, which are already run by the normal
      // test-dart repo tools command.
      dartUnitTests,
      flutterUnitTests,
    ],
  ]);

  // Ensure that all generated files are up to date.
  // Only run on master, since Dart format can change between versions.
  if (Platform.environment['CHANNEL'] == 'stable') {
    print('Skipping generated file validation on stable.');
  } else {
    await _validateGeneratedTestFiles();
    await _validateGeneratedExampleFiles();
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

  await runTests(testsToRun, ciMode: true, includeOverflow: true);
}
