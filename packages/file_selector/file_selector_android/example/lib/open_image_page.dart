// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:file_selector_platform_interface/file_selector_platform_interface.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Screen that allows the user to select an image file using
/// `openFiles`, then displays the selected images in a gallery dialog.
class OpenImagePage extends StatelessWidget {
  /// Default Constructor
  const OpenImagePage({super.key});

  Future<void> _openImageFile(BuildContext context) async {
    const XTypeGroup typeGroup = XTypeGroup(
      label: 'images',
      extensions: <String>['jpg', 'png'],
      uniformTypeIdentifiers: <String>['public.image'],
    );
    final XFile? file = await FileSelectorPlatform.instance
        .openFile(acceptedTypeGroups: <XTypeGroup>[typeGroup]);
    if (file == null) {
      // Operation was canceled by the user.
      return;
    }

    final Uint8List bytes = await file.readAsBytes();

    if (context.mounted) {
      await showDialog<void>(
        context: context,
        builder: (BuildContext context) => ImageDisplay(file.path, bytes),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Open an image'),
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
              child: const Text('Press to open an image file(png, jpg)'),
              onPressed: () => _openImageFile(context),
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget that displays an image in a dialog.
class ImageDisplay extends StatelessWidget {
  /// Default Constructor.
  const ImageDisplay(this.filePath, this.bytes, {super.key});

  /// The path to the selected file.
  final String filePath;

  /// The bytes of the selected file.
  final Uint8List bytes;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(key: const Key('result_image_name'), filePath),
      content: Image.memory(bytes),
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
