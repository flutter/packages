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

  Process.runSync('git', ['add', javaFile.path]);
  Process.runSync('git', [
    '-c',
    'user.name=Author',
    '-c',
    'user.email=author@example.com',
    'commit',
    '-m',
    'Add DummyEvalFeature.java without tests',
  ]);
}
