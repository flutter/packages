// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';
import 'dart:typed_data';

import 'package:file_selector_platform_interface/file_selector_platform_interface.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;

/// Screen that allows the user to select a save location using `getSavePath`,
/// then writes text to a file at that location.
class SaveTextPage extends StatelessWidget {
  /// Default Constructor
  SaveTextPage({super.key});

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  Future<void> _saveFile() async {
    final String fileName = _nameController.text;
    final FileSaveLocation? result = await FileSelectorPlatform.instance!.getSaveLocation(
      SaveLocationOptions(suggestedName: fileName),
    );
    if (result == null) {
      // Operation was canceled by the user.
      return;
    }
    final String text = _contentController.text;
    final fileData = Uint8List.fromList(text.codeUnits);
    // TODO(bparrishMines): Change this to use XFile.openWrite once
    // https://github.com/flutter/packages/pull/13133 lands
    final file = File(path.join(Uri.file(result.file.uri).toFilePath(), fileName));
    await file.writeAsBytes(fileData);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Save text into a file')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              width: 300,
              child: TextField(
                minLines: 1,
                maxLines: 12,
                controller: _nameController,
                decoration: const InputDecoration(hintText: '(Optional) Suggest File Name'),
              ),
            ),
            SizedBox(
              width: 300,
              child: TextField(
                minLines: 1,
                maxLines: 12,
                controller: _contentController,
                decoration: const InputDecoration(hintText: 'Enter File Contents'),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              onPressed: _saveFile,
              child: const Text('Press to save a text file'),
            ),
          ],
        ),
      ),
    );
  }
}
