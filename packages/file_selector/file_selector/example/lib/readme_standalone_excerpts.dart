// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// This file exists solely to host compiled excerpts for README.md, and is not
// intended for use as an actual example application.

// ignore_for_file: public_member_api_docs

import 'dart:typed_data';

import 'package:file_selector/file_selector.dart';
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

  Future<void> saveFile() async {
    // #docregion Save
    const String fileName = 'suggested_name.txt';
    final FileSaveLocation? result = await getSaveLocation(
      suggestedName: fileName,
    );
    if (result == null) {
      // Operation was canceled by the user.
      return;
    }

    final Uint8List fileData = Uint8List.fromList('Hello World!'.codeUnits);
    const String mimeType = 'text/plain';
    final XFile textFile = XFile.fromData(
      fileData,
      mimeType: mimeType,
      name: fileName,
    );
    await textFile.saveTo(result.path);
    // #enddocregion Save
  }

  Future<void> directoryPath() async {
    // #docregion GetDirectory
    final String? directoryPath = await getDirectoryPath();
    if (directoryPath == null) {
      // Operation was canceled by the user.
      return;
    }
    // #enddocregion GetDirectory
  }
}
