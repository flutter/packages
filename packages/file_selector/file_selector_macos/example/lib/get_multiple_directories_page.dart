// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:file_selector_platform_interface/file_selector_platform_interface.dart';
import 'package:flutter/material.dart';

/// Screen that allows the user to select one or more directories using `getDirectoryPaths`,
/// then displays the selected directories in a dialog.
class GetMultipleDirectoriesPage extends StatelessWidget {
  /// Default Constructor
  const GetMultipleDirectoriesPage({super.key});

  Future<void> _getDirectoryPaths(BuildContext context) async {
    const String confirmButtonText = 'Choose';
    final List<String?> directoriesPaths =
        await FileSelectorPlatform.instance.getDirectoryPaths(
      confirmButtonText: confirmButtonText,
    );
    if (directoriesPaths.isEmpty) {
      // Operation was canceled by the user.
      return;
    }
    if (context.mounted) {
      await showDialog<void>(
        context: context,
        builder: (BuildContext context) =>
            TextDisplay(directoriesPaths.join('\n')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select multiple directories'),
      ),
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
                  'Press to ask user to choose multiple directories'),
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
  const TextDisplay(this.directoryPaths, {super.key});

  /// The paths selected in the dialog.
  final String directoryPaths;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Selected Directories'),
      content: Scrollbar(
        child: SingleChildScrollView(
          child: Text(directoryPaths),
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
