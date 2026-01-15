// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';

import 'package:jnigen/jnigen.dart';

void main() {
  final Uri packageRoot = Platform.script.resolve('../');
  generateJniBindings(
    Config(
      outputConfig: OutputConfig(
        dartConfig: DartCodeOutputConfig(
          path: packageRoot.resolve('lib/src/path_provider.g.dart'),
          structure: OutputStructure.singleFile,
        ),
      ),
      androidSdkConfig: AndroidSdkConfig(
        addGradleDeps: true,
        androidExample: 'example/',
      ),
      sourcePath: [packageRoot.resolve('android/src/main/java')],
      classes: <String>[
        'android.app.Application',
        'android.content.Context',
        'io.flutter.util.PathUtils',
        'java.io.File',
        'android.os.Environment',
      ],
    ),
  );
}
