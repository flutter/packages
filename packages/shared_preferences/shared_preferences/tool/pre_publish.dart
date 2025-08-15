// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';

import 'package:path/path.dart' as p;

Future<void> _runCommand({
  required String message,
  required String executable,
  required List<String> arguments,
}) async {
  stdout.write(message);
  // The `packages/shared_preferences` directory.
  final Directory sharedPreferencesToolParent = Directory(
    p.dirname(Platform.script.path),
  ).parent.parent;

  final ProcessResult pubGetResult = await Process.run(
    executable,
    arguments,
    workingDirectory: p.join(
      sharedPreferencesToolParent.path,
      'shared_preferences_tool',
    ),
  );

  stdout.write(pubGetResult.stdout);

  if (pubGetResult.stderr != null) {
    stderr.write(pubGetResult.stderr);
  }
}

Future<void> main() async {
  await _runCommand(
    message: "Running 'flutter pub get' in shared_preferences_tool\n",
    executable: 'flutter',
    arguments: <String>['pub', 'get'],
  );
  await _runCommand(
    message: "Running 'build_and_copy' in shared_preferences_tool\n",
    executable: 'dart',
    arguments: <String>[
      'run',
      'devtools_extensions',
      'build_and_copy',
      '--source=.',
      '--dest=../shared_preferences/extension/devtools',
    ],
  );
}
