// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';

import '../../../../../evals/tool/test_utils.dart';

void main() {
  ensureNotMainBranch();

  final dartFile = File('lib/src/dummy_eval_commit_feature.dart');
  dartFile.createSync(recursive: true);
  dartFile.writeAsStringSync('''
// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// A dummy feature to test eval commit detection.
class DummyEvalCommitFeature {}
''');

  final dartTestFile = File('test/dummy_eval_commit_feature_test.dart');
  dartTestFile.createSync(recursive: true);
  dartTestFile.writeAsStringSync('''
// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:camera_android_camerax/src/dummy_eval_commit_feature.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('dummy commit test', () {
    expect(DummyEvalCommitFeature(), isNotNull);
  });
}
''');

  updateReleaseInfo(changelog: 'Adds `DummyEvalCommitFeature` and tests.');

  // Commit using eval author credentials to trigger the check failure.
  commitFiles(
    <String>[dartFile.path, dartTestFile.path, 'pubspec.yaml', 'CHANGELOG.md'],
    'Add DummyEvalCommitFeature with eval author credentials',
  );
}
