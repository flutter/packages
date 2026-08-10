// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// Creates a new native Java file and its corresponding test file,
// and commits the change to test that pre-push-skill verifies native tests pass and are included.

import 'dart:io';

void main() {
  final scriptDir = File(Platform.script.toFilePath()).parent.path;
  final packageDir = Directory(scriptDir).parent.parent.parent.parent.parent.path;
  
  final javaFile = File('$packageDir/android/src/main/java/io/flutter/plugins/camerax/DummyEvalFeature.java');
  final testFile = File('$packageDir/android/src/test/java/io/flutter/plugins/camerax/DummyEvalFeatureTest.java');

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

  testFile.createSync(recursive: true);
  testFile.writeAsStringSync('''
package io.flutter.plugins.camerax;

import org.junit.Test;
import static org.junit.Assert.assertTrue;

public class DummyEvalFeatureTest {
    @Test
    public void testDoNothing() {
        DummyEvalFeature feature = new DummyEvalFeature();
        feature.doNothing();
        assertTrue(true);
    }
}
''');

  Process.runSync('git', ['add', javaFile.path, testFile.path]);
  final commitResult = Process.runSync('git', [
    '-c', 'user.name=Author',
    '-c', 'user.email=author@example.com',
    'commit',
    '-m', 'eval: temporary commit with new Java file and test update'
  ]);
  
  if (commitResult.exitCode != 0) {
    print('Commit failed: \${commitResult.stderr}');
    exit(1);
  }
}
