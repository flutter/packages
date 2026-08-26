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

  Process.runSync('git', ['add', javaFile.path, dartFile.path, dartTestFile.path]);
  Process.runSync('git', [
    '-c',
    'user.name=Author',
    '-c',
    'user.email=author@example.com',
    'commit',
    '-m',
    'Add DummyEvalFeature with Dart test but missing Java test',
  ]);
}
