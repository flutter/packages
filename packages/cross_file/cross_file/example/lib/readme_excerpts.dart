// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:cross_file/cross_file.dart';
// #docregion platform_imports
// Import for Darwin App Sandbox features.
import 'package:cross_file_darwin/cross_file_darwin.dart';
// Import for Web features.
import 'package:cross_file_web/cross_file_web.dart';
// #enddocregion platform_imports
import 'package:flutter/foundation.dart' show debugPrint;

/// Demonstrate instantiating an XFile for the README.
Future<void> instantiateXFile() async {
  // #docregion Instantiate
  final file = XFile.fileSystem(path: 'assets/hello.txt');

  debugPrint('File information:');
  debugPrint('- URI: ${file.uri}');
  debugPrint('- Name: ${await file.name()}');

  try {
    if (await file.exists()) {
      final String fileContent = await file.readAsString();
      debugPrint('Content of the file: $fileContent');
    }
  } finally {
    await file.dispose();
  }
  // #enddocregion Instantiate
}

/// Demonstrate accessing platform features.
Future<void> accessPlatformFeatures() async {
  // #docregion platform_features
  late final XFile file;

  switch (CrossFile.implementation) {
    case CrossFileWeb():
      final params = WebScopedStorageXFileCreationParams.fromObjectUrl(
        objectUrl: 'blob:https://some/url:for/file',
      );
      file = ScopedStorageXFile.fromCreationParams(params);
    case CrossFileDarwin():
      file = ScopedStorageXFile.fromUri(Uri.file('/my/file.txt'));
    default:
      file = XFile.fileSystem(path: '/my/file.txt');
  }

  try {
    await file
        .getExtension<SecurityScopedDarwinScopedStorageXFileExtension>()
        ?.startAccessingSecurityScopedResource();

    debugPrint(await file.readAsString());
  } finally {
    await file.dispose();
  }
  // #enddocregion platform_features
}
