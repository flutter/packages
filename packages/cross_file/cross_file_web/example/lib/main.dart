// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:cross_file_platform_interface/cross_file_platform_interface.dart';
import 'package:flutter/material.dart';
import 'package:mime/mime.dart' as mime;

void main() {
  runApp(const MaterialApp(home: FileOpenScreen()));
}

/// Example screen to open a file selector and display it.
class FileOpenScreen extends StatelessWidget {
  /// Constructs a [FileOpenScreen].
  const FileOpenScreen({super.key});

  Future<PlatformXFile?> _getTextFile() async {
    // Implement this method to retrieve a text file.
    return null;
  }

  Future<void> _openTextFile(BuildContext context) async {
    final PlatformXFile? file = await _getTextFile();

    if (file != null) {
      final String filename = await file.name() ?? file.params.uri;

      switch (mime.lookupMimeType(filename)) {
        case final String mimeType when mimeType.startsWith('text'):
          final String fileContents = await file.readAsString();
          if (context.mounted) {
            await showDialog<void>(
              context: context,
              builder: (BuildContext context) =>
                  TextDisplay(filename: filename, fileContents: fileContents),
            );
          }
        case _:
          debugPrint('File Uri: ${file.params.uri}');
          debugPrint('Filename: $filename');
          debugPrint('File Length: ${await file.length()}');
          debugPrint('File Last Modified: ${await file.lastModified()}');
          return;
      }
    } else {
      debugPrint('No file selected.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Open a Text File'), backgroundColor: Colors.blue),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.blue,
                backgroundColor: Colors.white,
              ),
              child: const Text('Open Text File'),
              onPressed: () => _openTextFile(context),
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget that displays a text file in a dialog.
class TextDisplay extends StatelessWidget {
  /// Default Constructor.
  const TextDisplay({super.key, required this.filename, required this.fileContents});

  /// The name of the file.
  final String filename;

  /// The contents of the file.
  final String fileContents;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(filename),
      content: Scrollbar(child: SingleChildScrollView(child: Text(fileContents))),
      actions: <Widget>[
        TextButton(child: const Text('Close'), onPressed: () => Navigator.pop(context)),
      ],
    );
  }
}
