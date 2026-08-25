// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';

import '../../../../../evals/tool/test_utils.dart';

void main() {
  ensureNotMainBranch();

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

  updateReleaseInfo(changelog: 'Adds `DummyEvalFeature` and tests.');

  // Overrides eval author credentials so this success fixture passes the commit author check.
  // Risk: When run on a working branch, check_eval_commits.dart will not detect or prevent these test commits from being pushed.
  commitFiles(
    <String>[javaFile.path, javaTestFile.path, 'pubspec.yaml', 'CHANGELOG.md'],
    'Add DummyEvalFeature.java, tests, and changelog update',
    authorName: 'Contributor',
    authorEmail: 'contributor@example.com',
  );
}
