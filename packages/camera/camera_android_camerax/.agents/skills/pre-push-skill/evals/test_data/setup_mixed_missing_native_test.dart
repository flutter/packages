// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// Creates a new Dart source/test pair and a native Java source file (without its native test),
// and commits the change to test that pre-push-skill detects the missing native test in a mixed PR.

import 'dart:io';

void main() {
  final scriptDir = File(Platform.script.toFilePath()).parent.path;
  final packageDir = Directory(scriptDir).parent.parent.parent.parent.parent.path;
  
  final dartFile = File('$packageDir/lib/src/dummy_eval_feature.dart');
  final dartTest = File('$packageDir/test/dummy_eval_feature_test.dart');
  final javaFile = File('$packageDir/android/src/main/java/io/flutter/plugins/camerax/DummyEvalFeature.java');

  Directory.current = packageDir;

  final branchResult = Process.runSync('git', ['rev-parse', '--abbrev-ref', 'HEAD']);
  if (branchResult.stdout.toString().trim() == 'main') {
    print('Error: Cannot run evals on the main branch. Please run in a separate branch.');
    exit(1);
  }

  dartFile.createSync(recursive: true);
  dartFile.writeAsStringSync('''
class DummyEvalFeature {
  void doNothing() {}
}
''');

  dartTest.createSync(recursive: true);
  dartTest.writeAsStringSync('''
import 'package:flutter_test/flutter_test.dart';
import 'package:camera_android_camerax/src/dummy_eval_feature.dart';

void main() {
  test('dummy', () {
    final feature = DummyEvalFeature();
    feature.doNothing();
  });
}
''');

  javaFile.createSync(recursive: true);
  javaFile.writeAsStringSync('''
package io.flutter.plugins.camerax;

public class DummyEvalFeature {
    public void doNothing() {}
}
''');

  Process.runSync('git', ['add', dartFile.path, dartTest.path, javaFile.path]);
  final commitResult = Process.runSync('git', [
    '-c', 'user.name=Author',
    '-c', 'user.email=author@example.com',
    'commit',
    '-m', 'eval: mixed Dart and Java changes without native unit test'
  ]);
  
  if (commitResult.exitCode != 0) {
    print('Commit failed: \${commitResult.stderr}');
    exit(1);
  }
}
