// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: avoid_print

// Generates the pigeon output files needed for platform_test tests.
//
// Eventually this may get more options to control which files are generated,
// but for now it always generates everything needed for the platform unit
// tests.

import 'dart:io' show Platform, exit;

import 'package:path/path.dart' as p;

import 'shared/generation.dart';

Future<void> main(List<String> args) async {
  final String baseDir = p.dirname(p.dirname(Platform.script.toFilePath()));

  print('Generating platform_test/ output...');
  final int exitCode = await generatePigeons(baseDir: baseDir);
  if (exitCode == 0) {
    print('Generation complete!');
  } else {
    print('Generation failed; see above for errors.');
  }
  exit(exitCode);
}
