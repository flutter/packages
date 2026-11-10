// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// This file exists solely to host compiled excerpts for README.md, and is not
// intended for use as an actual example application.

// ignore_for_file: public_member_api_docs

import 'dart:typed_data';

// #docregion Save
import 'package:cross_file_web/cross_file_web_safe.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
// #enddocregion Save
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('README snippet app')),
        body: const Text('See example in main.dart'),
      ),
    );
  }

  // TODO(bparrishMines): Change to use the cross platform safe methods to
  // write to a file once https://github.com/flutter/packages/pull/13133
  // lands.
  // #docregion Save
  Future<void> saveFile() async {
    final fileData = Uint8List.fromList('Hello World!'.codeUnits);
    const fileName = 'suggested_name.txt';

    // A save location can't be retrieved on web because the platform doesn't
    // provide access to the filesystem. This instead downloads the file using
    // the web specific `download` method.
    if (kIsWeb) {
      final file = ScopedStorageXFile.fromCreationParams(
        WebScopedStorageXFileCreationParams.fromBytes(fileData),
      );
      await file.getExtension<WebScopedStorageXFileExtension>()!.download(fileName);
    }

    final FileSaveLocation? result = await getSaveLocation(suggestedName: fileName);
    if (result == null) {
      // Operation was canceled by the user.
      return;
    }

    if (result.file case final FileSystemXFile file) {
      final fileData = Uint8List.fromList('Hello World!'.codeUnits);
      await file.writeAsBytes(fileData);
    }
  }
  // #enddocregion Save

  Future<void> directory() async {
    // #docregion GetDirectory
    final XDirectory? directory = await getDirectory();
    if (directory == null) {
      // Operation was canceled by the user.
      return;
    }
    // #enddocregion GetDirectory
  }
}
