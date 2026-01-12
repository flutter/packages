// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: avoid_print

import 'package:cross_file/cross_file.dart';

/// Demonstrate instantiating an XFile for the README.
Future<XFile> instantiateXFile() async {
  // #docregion Instantiate
  final XFile file = XFile('assets/hello.txt');

  print('File information:');
  print('- Path: ${file.path}');
  print('- Name: ${file.name}');
  print('- MIME type: ${file.mimeType}');

  final String fileContent = await file.readAsString();
  print('Content of the file: $fileContent');
  // #enddocregion Instantiate

  return file;
}
