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
import 'package:yaml_edit/yaml_edit.dart';

Future<void> main(List<String> args) async {
  if (!Platform.isMacOS && !Platform.isWindows) {
    print('This test can only be run on macOS or windows.');
    exit(0);
  }
  final p.Context ctx = p.context;
  final Directory packageRoot =
      Directory(ctx.dirname(_ensureTrimLeadingSeparator(Platform.script.path)))
          .parent;

  // Copy test_fixes/ to be tested in a temp directory.
  // This ensures the dart fix can be applied to projects
  // outside of this package.
  final Directory testFixesTargetDir = await Directory.systemTemp.createTemp();

  await _prepareTemplate(
    ctx: ctx,
    testFixesDir: ctx.join(packageRoot.path, 'test_fixes'),
    testFixesTargetDir: testFixesTargetDir.path,
  );
  final int pubGet = await _runProcess(
    'dart',
    <String>[
      'pub',
      'upgrade',
    ],
    workingDirectory: testFixesTargetDir.path,
  );
  if (pubGet != 0) {
    await cleanUpAndExit(statusCode: pubGet, toDelete: testFixesTargetDir);
  }
  final int status = await _runProcess(
    'dart',
    <String>[
      'fix',
      '--compare-to-golden',
    ],
    workingDirectory: testFixesTargetDir.path,
  );
  if (status != 0) {
    await cleanUpAndExit(statusCode: status, toDelete: testFixesTargetDir);
  }
  await cleanUpAndExit(statusCode: 0, toDelete: testFixesTargetDir);
}

Future<Never> cleanUpAndExit({
  required int statusCode,
  required Directory toDelete,
}) async {
  await toDelete.delete(recursive: true);
  exit(statusCode);
}

Future<void> _prepareTemplate({
  required String testFixesDir,
  required String testFixesTargetDir,
  required p.Context ctx,
}) async {
  await io.copyPath(testFixesDir, testFixesTargetDir);

  final String pubspecYamlPath = ctx.join(testFixesTargetDir, 'pubspec.yaml');
  final File targetPubspecPath = File(pubspecYamlPath);
  const String initialYaml = '''
name: test_fixes
publish_to: "none"
version: 1.0.0+1

environment:
  sdk: ">=2.18.0 <4.0.0"
  flutter: ">=3.3.0"

dependencies:
  flutter:
    sdk: flutter
  go_router:
    path:
''';
  final YamlEditor editor = YamlEditor(initialYaml);
  editor.update(
    <String>['dependencies', 'go_router', 'path'],
    ctx.dirname(testFixesDir),
  );
  final String newYaml = editor.toString();
  await targetPubspecPath.writeAsString(newYaml);
}

String _ensureTrimLeadingSeparator(String path) {
  if (Platform.isWindows) {
    if (path.startsWith('/')) {
      return path.substring(1);
    }
  }
  return path;
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
