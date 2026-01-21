// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:cross_file_ios/cross_file_ios.dart';
import 'package:file_selector_ios/file_selector_ios.dart';
import 'package:flutter/material.dart';
import 'package:mime/mime.dart' as mime;

void main() {
  runApp(const MaterialApp(home: FileOpenScreen()));
}

/// Example screen to open a file selector and display it.
class FileOpenScreen extends StatelessWidget {
  /// Constructs a [FileOpenScreen].
  const FileOpenScreen({super.key});

  Future<void> _openFile(BuildContext context) async {
    final IOSXFile? file = await FileSelectorIOS().openFile2();

    if (!context.mounted) {
      return;
    }

    print(file?.params.uri);

    if (file case final IOSXFile file) {
      switch (mime.lookupMimeType(file.params.uri)) {
        case final String mimeType when mimeType.startsWith('text'):
          await showDialog<void>(
            context: context,
            builder: (BuildContext context) => TextDisplay(file),
          );
        case final String mimeType when mimeType.startsWith('image'):
        case final String mimeType when mimeType.startsWith('application'):
        case null:
          debugPrint('Unsupported file type: ${file.params.uri}');
          return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Open a File'),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.blue,
                backgroundColor: Colors.white,
              ),
              child: const Text('Open File'),
              onPressed: () => _openFile(context),
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
  const TextDisplay(this.file, {super.key});

  /// The file.
  final IOSXFile file;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(file.params.uri),
      content: Scrollbar(
        child: SingleChildScrollView(
          child: FutureBuilder<String>(
            future: file.readAsString(),
            builder: (_, AsyncSnapshot<String> snapshot) {
              if (snapshot.hasData) {
                return Text(snapshot.data!);
              } else {
                return const CircularProgressIndicator();
              }
            },
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Close'),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }
}
