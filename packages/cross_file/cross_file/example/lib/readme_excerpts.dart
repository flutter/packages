// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:cross_file/cross_file.dart';
import 'package:flutter/foundation.dart' show debugPrint;

/// Demonstrate instantiating an XFile for the README.
Future<XFile> instantiateXFile() async {
  // #docregion Instantiate
  final file = XFile.fromUri(Uri.file('assets/hello.txt'));

  debugPrint('File information:');
  debugPrint('- URI: ${file.uri}');
  debugPrint('- Name: ${await file.name()}');

  if (await file.canRead()) {
    final String fileContent = await file.readAsString();
    debugPrint('Content of the file: $fileContent');
  }
  // #enddocregion Instantiate

  return file;
}
