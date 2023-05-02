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
  if (!Platform.isMacOS /* && !Platform.isWindows*/) {
    print('This test can only be run on macOS' /*' or windows.'*/);
    exit(0);
  }
  final p.Context ctx = p.context;
  final Directory packageRoot =
      Directory(ctx.dirname(_ensureTrimLeadingSeparator(Platform.script.path)))
          .parent;

  //copy from go_router/test_fixes to temp directory
  final Directory testFixesTargetDir = await Directory.systemTemp.createTemp();
  for (final bool testPubVersion in <bool>[true, false]) {
    //testPubVersion=true will lead to failiure on go_router v7.0.0
    await _prepareTemplate(
      ctx: ctx,
      testFixesDir: ctx.join(packageRoot.path, 'test_fixes'),
      testFixesTargetDir: testFixesTargetDir.path,
      testPubVersion: testPubVersion,
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
      exit(pubGet);
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
      exit(status);
    }
  }
  exit(0);
}

Future<void> _prepareTemplate({
  required String testFixesDir,
  required String testFixesTargetDir,
  required p.Context ctx,
  required bool testPubVersion,
}) async {
  await io.copyPath(testFixesDir, testFixesTargetDir);

  final String pubspecYamlPath = ctx.join(testFixesTargetDir, 'pubspec.yaml');
  final File targetPubspecPath = File(pubspecYamlPath);

  final YamlEditor editor = YamlEditor(await targetPubspecPath.readAsString());
  if (testPubVersion) {
    editor.update(<String>['dependencies', 'go_router'], 'any');
  } else {
    editor.update(
      <String>['dependencies', 'go_router', 'path'],
      ctx.dirname(testFixesDir),
    );
  }
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
