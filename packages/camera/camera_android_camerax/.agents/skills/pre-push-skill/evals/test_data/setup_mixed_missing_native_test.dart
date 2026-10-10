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

  final dartFile = File('lib/src/dummy_eval_feature.dart');
  dartFile.createSync(recursive: true);
  dartFile.writeAsStringSync('''
// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// A dummy eval feature
class DummyEvalFeature {
  /// Do nothing
  void doNothing() {}
}
''');

  final dartTestFile = File('test/dummy_eval_feature_test.dart');
  dartTestFile.createSync(recursive: true);
  dartTestFile.writeAsStringSync('''
// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:camera_android_camerax/src/dummy_eval_feature.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('dummy', () {
    final feature = DummyEvalFeature();
    feature.doNothing();
  });
}
''');

  commitFiles(<String>[
    javaFile.path,
    dartFile.path,
    dartTestFile.path,
  ], 'Add DummyEvalFeature with Dart test but missing Java test');
}
