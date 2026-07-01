// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: avoid_print

import 'dart:typed_data';

import 'package:cross_file/cross_file.dart';

// `dart:io` (used by the path-based XFile implementation) is not available on
// web, so the disk-based excerpt is only executed on non-web platforms.
const bool _kIsWeb = bool.fromEnvironment('dart.library.js_interop');

/// Demonstrate instantiating an XFile for the README.
Future<XFile> instantiateXFile() async {
  // #docregion Instantiate
  final file = XFile('assets/hello.txt');

  print('XFile from disk:');
  print('- Path: ${file.path}');
  print('- Name: ${file.name}');
  print('- Length: ${await file.length()} bytes');
  print('- Content: ${await file.readAsString()}');
  // #enddocregion Instantiate

  return file;
}

/// Demonstrate constructing an XFile directly from in-memory bytes, which is
/// useful when the file contents are generated at runtime or received from a
/// network source rather than read from disk.
Future<XFile> instantiateXFileFromData() async {
  // #docregion InstantiateFromData
  final bytes = Uint8List.fromList([
    72, 101, 108, 108, 111, 33, // 'Hello!'
  ]);
  final file = XFile.fromData(bytes, mimeType: 'text/plain');

  print('XFile from in-memory bytes:');
  print('- MIME type: ${file.mimeType}');
  print('- Length: ${await file.length()} bytes');
  print('- Content: ${await file.readAsString()}');
  // #enddocregion InstantiateFromData

  return file;
}

/// Runs the example excerpts, demonstrating the [XFile] API.
Future<void> main() async {
  if (!_kIsWeb) {
    print('=== Creating an XFile from disk ===');
    await instantiateXFile();
    print('');
  }

  print('=== Creating an XFile from in-memory bytes ===');
  await instantiateXFileFromData();
}
