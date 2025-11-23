// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:file_selector_platform_interface/file_selector_platform_interface.dart';
import 'package:flutter/material.dart';

/// Screen that allows the user to select any file file using `openFile`, then
/// displays its path in a dialog.
class OpenAnyPage extends StatelessWidget {
  /// Default Constructor
  const OpenAnyPage({super.key});

  Future<void> _openTextFile(BuildContext context) async {
    final XFile? file = await FileSelectorPlatform.instance.openFile();
    if (file == null) {
      // Operation was canceled by the user.
      return;
    }

    if (context.mounted) {
      await showDialog<void>(
        context: context,
        builder: (BuildContext context) => PathDisplay(file.name, file.path),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Open a file')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: const Text('Press to open a file of any type'),
              onPressed: () => _openTextFile(context),
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget that displays a text file in a dialog.
class PathDisplay extends StatelessWidget {
  /// Default Constructor.
  const PathDisplay(this.fileName, this.filePath, {super.key});

  /// The name of the selected file.
  final String fileName;

  /// The contents of the text file.
  final String filePath;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(fileName),
      content: Text(filePath),
      actions: <Widget>[
        TextButton(
          child: const Text('Close'),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }
}
