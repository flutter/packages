// Copyright 2013 The Flutter Authors
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
    workingDirectory: p.join(sharedPreferencesToolParent.path, 'shared_preferences_tool'),
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
    message: "Running 'flutter build web' in shared_preferences_tool\n",
    executable: 'flutter',
    arguments: <String>['build', 'web', '--release', '--no-tree-shake-icons'],
  );
  await _runCommand(
    message: "Copying built output to 'shared_preferences/extension/devtools/build'\n",
    executable: 'cp',
    arguments: <String>['-R', 'build/web/.', '../shared_preferences/extension/devtools/build'],
  );
}
