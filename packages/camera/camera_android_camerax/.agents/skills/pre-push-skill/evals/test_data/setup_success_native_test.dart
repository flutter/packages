// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';

void main() {
  final ProcessResult branchResult = Process.runSync('git', ['branch', '--show-current']);
  final String branch = branchResult.stdout.toString().trim();
  if (branch == 'main') {
    stdout.writeln('Error: Cannot run setup scripts on main branch.');
    exit(1);
  }

  final javaFile = File('android/src/main/java/io/flutter/plugins/camerax/DummyEvalFeature.java');
  javaFile.createSync(recursive: true);
  javaFile.writeAsStringSync('''
// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

public class DummyEvalFeature {
    public void doNothing() {}
}
''');

  final javaTestFile = File(
    'android/src/test/java/io/flutter/plugins/camerax/DummyEvalFeatureTest.java',
  );
  javaTestFile.createSync(recursive: true);
  javaTestFile.writeAsStringSync('''
// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

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

  Process.runSync('git', ['add', javaFile.path, javaTestFile.path]);
  Process.runSync('git', [
    '-c',
    'user.name=Author',
    '-c',
    'user.email=author@example.com',
    'commit',
    '-m',
    'Add DummyEvalFeature.java and tests',
  ]);
}
