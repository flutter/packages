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

/// Demonstrate accessing platform features.
Future<XFile> accessPlatformFeatures() async {
  // #docregion platform_features
  late final XFile file;

  if (CrossFilePlatform.instance is CrossFileWeb) {
    final params = WebXFileCreationParams.fromObjectUrl(
      objectUrl: 'blob:https://some/url:for/file',
    );
    file = XFile.fromCreationParams(params);
  } else if (CrossFilePlatform.instance is CrossFileDarwin) {
    final params = PlatformScopedStorageXFileCreationParams(
      uri: Uri.file('/my/file.txt').toString(),
    );
    file = ScopedStorageXFile.fromCreationParams(params);

    await file
        .getExtension<DarwinScopedStorageXFileExtension>()
        .startAccessingSecurityScopedResource();
  } else {
    file = XFile.fromUri(Uri.file('/my/file.txt'));
  }

  debugPrint(await file.readAsString());
  await file
      .maybeGetExtension<DarwinScopedStorageXFileExtension>()
      ?.stopAccessingSecurityScopedResource();
  // #enddocregion platform_features

  return file;
}
