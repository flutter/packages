// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// Called from the custom-tests CI action.
//
// usage: dart run tool/run_tests.dart

// ignore_for_file: avoid_print

import 'dart:io';
import 'package:io/io.dart' as io;
import 'package:path/path.dart' as p;

/// This test runner simulates a consumption of go_router that checks if
/// the breaking changes introduced in `V7.0.0` are applied correctly.
/// This is done by copying the `test_fixes/` directory to a temp directory
/// that references `go_router`, and running `dart fix --compare-to-golden`
/// on the temp directory.
Future<void> main(List<String> args) async {
  /// The go_router directory.
  final Directory packageRoot = File.fromUri(Platform.script).parent.parent;

  // The target temp directory.
  final Directory testFixesTargetDir = await Directory.systemTemp.createTemp();

  // Cleans up the temp directory and exits with a given statusCode.
  Future<Never> cleanUpAndExit(int statusCode) async {
    await testFixesTargetDir.delete(recursive: true);
    exit(statusCode);
  }

  // Copies the test_fixes folder to the temporary testFixesTargetDir
  // This also creates the proper pubspec.yaml in the temp directory.
  await _prepareTemplate(
    packageRoot: packageRoot,
    testFixesTargetDir: testFixesTargetDir,
  );

  // Run dart pub get in the temp directory to set it up.
  final int pubGetStatusCode = await _runProcess(
    'dart',
    <String>[
      'pub',
      'get',
    ],
    workingDirectory: testFixesTargetDir.path,
  );

  if (pubGetStatusCode != 0) {
    await cleanUpAndExit(pubGetStatusCode);
  }

  // This is the actual test that runs dart fix --compare-to-golden
  // in the temp directory (the actual test).
  final int dartFixStatusCode = await _runProcess(
    'dart',
    <String>[
      'fix',
      '--compare-to-golden',
    ],
    workingDirectory: testFixesTargetDir.path,
  );

  await cleanUpAndExit(dartFixStatusCode);
}

Future<void> _prepareTemplate({
  required Directory packageRoot,
  required Directory testFixesTargetDir,
}) async {
  // The src test_fixes directory.
  final Directory testFixesSrcDir =
      Directory(p.join(packageRoot.path, 'test_fixes'));

  // Copy from src `test_fixes/` to the temp directory.
  await io.copyPath(testFixesSrcDir.path, testFixesTargetDir.path);

  // The pubspec.yaml file to create.
  final File targetPubspecFile =
      File(p.join(testFixesTargetDir.path, 'pubspec.yaml'));

  final String targetYaml = '''
name: test_fixes
publish_to: "none"
version: 1.0.0

environment:
  sdk: ">=2.18.0 <4.0.0"
  flutter: ">=3.3.0"

dependencies:
  flutter:
    sdk: flutter
  go_router:
    path: ${packageRoot.path}
''';

  await targetPubspecFile.writeAsString(targetYaml);
}

Future<Process> _streamOutput(Future<Process> processFuture) async {
  final Process process = await processFuture;
  stdout.addStream(process.stdout);
  stderr.addStream(process.stderr);
  return process;
}

Future<int> _runProcess(
  String command,
  List<String> arguments, {
  String? workingDirectory,
}) async {
  final Process process = await _streamOutput(Process.start(
    command,
    arguments,
    workingDirectory: workingDirectory,
  ));
  return process.exitCode;
}
