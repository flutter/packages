// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:file_selector_platform_interface/file_selector_platform_interface.dart';
import 'package:flutter/material.dart';

/// Screen that allows the user to select a directory path using
/// `getDirectoryPath`, then displays all entities in that directory in a dialog.
class GetDirectoryPathPage extends StatelessWidget {
  /// Default Constructor
  const GetDirectoryPathPage({super.key});

  Future<void> _getDirectoryPath(BuildContext context) async {
    final XDirectory? directory = await FileSelectorPlatform.instance!.getDirectory();
    if (directory == null) {
      // Operation was canceled by the user.
      return;
    }

    final entityNames = <String>[];
    await for (final XEntity entity in directory.list()) {
      if (entity is XFile) {
        final String? name = await entity.name();
        if (name != null) {
          entityNames.add(name);
        }
      } else if (entity is XDirectory) {
        // Getting a name for a directory is not supported, so this is a
        // workaround to show just the directory name.
        entityNames.add(entity.uri.split('%2F').last);
      } else {
        entityNames.add(entity.uri);
      }
    }

    if (context.mounted) {
      await showDialog<void>(
        context: context,
        builder: (BuildContext context) => DirectoryEntitiesDisplay(directory.uri, entityNames),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Open a directory')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.blue,
                backgroundColor: Colors.white,
              ),
              child: const Text('Press to open a directory and get text files'),
              onPressed: () => _getDirectoryPath(context),
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget that displays entities found in a directory in a dialog.
class DirectoryEntitiesDisplay extends StatelessWidget {
  /// Default Constructor.
  const DirectoryEntitiesDisplay(this.directoryPath, this.entityNames, {super.key});

  /// The path or URI of the selected directory.
  final String directoryPath;

  /// The list of entity names in the directory.
  final List<String> entityNames;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Directory: $directoryPath'),
      content: Scrollbar(child: SingleChildScrollView(child: Text(entityNames.join('\n')))),
      actions: <Widget>[
        TextButton(child: const Text('Close'), onPressed: () => Navigator.pop(context)),
      ],
    );
  }
}
