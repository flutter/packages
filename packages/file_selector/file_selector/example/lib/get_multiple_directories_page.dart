// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';

/// Screen that allows the user to select one or more directories using `getDirectoryPaths`,
/// then displays the selected directories in a dialog.
class GetMultipleDirectoriesPage extends StatelessWidget {
  /// Returns a new instance of the page.
  const GetMultipleDirectoriesPage({super.key});

  Future<void> _getDirectoryPaths(BuildContext context) async {
    const confirmButtonText = 'Choose';
    final List<String?> directoryPaths = await getDirectoryPaths(
      confirmButtonText: confirmButtonText,
    );
    if (directoryPaths.isEmpty) {
      // Operation was canceled by the user.
      return;
    }
    var paths = '';
    for (final path in directoryPaths) {
      paths += '${path!} \n';
    }
    if (context.mounted) {
      await showDialog<void>(
        context: context,
        builder: (BuildContext context) => TextDisplay(paths),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select multiple directories')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: const Text(
                'Press to ask user to choose multiple directories',
              ),
              onPressed: () => _getDirectoryPaths(context),
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget that displays a text file in a dialog.
class TextDisplay extends StatelessWidget {
  /// Creates a `TextDisplay`.
  const TextDisplay(this.directoriesPaths, {super.key});

  /// The path selected in the dialog.
  final String directoriesPaths;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Selected Directories'),
      content: Scrollbar(
        child: SingleChildScrollView(child: Text(directoriesPaths)),
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
