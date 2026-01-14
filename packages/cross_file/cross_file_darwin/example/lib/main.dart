// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:file_selector/file_selector.dart';
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
    final XFile? file = await openFile();

    if (!context.mounted) {
      return;
    }

    if (file case final XFile file) {
      switch (mime.lookupMimeType(file.path)) {
        case final String mimeType when mimeType.startsWith('text'):
          await showDialog<void>(
            context: context,
            builder: (BuildContext context) => TextDisplay(file),
          );
        case final String mimeType when mimeType.startsWith('image'):
        case final String mimeType when mimeType.startsWith('application'):
        case null:
          debugPrint('Unsupported file type: ${file.path}');
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
  final XFile file;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(file.path),
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
