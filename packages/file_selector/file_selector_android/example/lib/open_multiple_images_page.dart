// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:file_selector_platform_interface/file_selector_platform_interface.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Screen that allows the user to select multiple image files using
/// `openFiles`, then displays the selected images in a gallery dialog.
class OpenMultipleImagesPage extends StatelessWidget {
  /// Default Constructor
  const OpenMultipleImagesPage({super.key});

  Future<void> _openImageFile(BuildContext context) async {
    const XTypeGroup jpgsTypeGroup = XTypeGroup(
      label: 'JPEGs',
      extensions: <String>['jpg', 'jpeg'],
      uniformTypeIdentifiers: <String>['public.jpeg'],
    );
    const XTypeGroup pngTypeGroup = XTypeGroup(
      label: 'PNGs',
      extensions: <String>['png'],
      uniformTypeIdentifiers: <String>['public.png'],
    );
    final List<XFile> files = await FileSelectorPlatform.instance
        .openFiles(acceptedTypeGroups: <XTypeGroup>[
      jpgsTypeGroup,
      pngTypeGroup,
    ]);
    if (files.isEmpty) {
      // Operation was canceled by the user.
      return;
    }

    final List<Uint8List> imageBytes = <Uint8List>[];
    for (final XFile file in files) {
      imageBytes.add(await file.readAsBytes());
    }
    if (context.mounted) {
      await showDialog<void>(
        context: context,
        builder: (BuildContext context) => MultipleImagesDisplay(imageBytes),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Open multiple images'),
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
              child: const Text('Press to open multiple images (png, jpg)'),
              onPressed: () => _openImageFile(context),
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget that displays a text file in a dialog.
class MultipleImagesDisplay extends StatelessWidget {
  /// Default Constructor.
  const MultipleImagesDisplay(this.fileBytes, {super.key});

  /// The bytes containing the images.
  final List<Uint8List> fileBytes;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Gallery'),
      // On web the filePath is a blob url
      // while on other platforms it is a system path.
      content: Center(
        child: Row(
          children: <Widget>[
            for (int i = 0; i < fileBytes.length; i++)
              Flexible(
                key: Key('result_image_name$i'),
                child: Image.memory(fileBytes[i]),
              )
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Close'),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ],
    );
  }
}
