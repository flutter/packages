// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// Creates a new native Java file without a corresponding test file,
// and commits the change to test that pre-push-skill detects missing native tests.

import 'dart:io';

void main() {
  final scriptDir = File(Platform.script.toFilePath()).parent.path;
  final packageDir = Directory(scriptDir).parent.parent.parent.parent.parent.path;
  final javaFile = File('$packageDir/android/src/main/java/io/flutter/plugins/camerax/DummyEvalFeature.java');

  Directory.current = packageDir;

  final branchResult = Process.runSync('git', ['rev-parse', '--abbrev-ref', 'HEAD']);
  if (branchResult.stdout.toString().trim() == 'main') {
    print('Error: Cannot run evals on the main branch. Please run in a separate branch.');
    exit(1);
  }

  javaFile.createSync(recursive: true);
  javaFile.writeAsStringSync('''
package io.flutter.plugins.camerax;

public class DummyEvalFeature {
    public void doNothing() {}
}
''');

  Process.runSync('git', ['add', javaFile.path]);
  final commitResult = Process.runSync('git', [
    '-c', 'user.name=Author',
    '-c', 'user.email=author@example.com',
    'commit',
    '-m', 'eval: temporary commit with new Java file and no test update'
  ]);
  
  if (commitResult.exitCode != 0) {
    print('Commit failed: \${commitResult.stderr}');
    exit(1);
  }
}
