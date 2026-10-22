// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Screen that shows an example of openFiles
class OpenImagePage extends StatelessWidget {
  /// Default Constructor
  const OpenImagePage({super.key});

  Future<void> _openImageFile(BuildContext context) async {
    // #docregion SingleOpen
    const typeGroup = XTypeGroup(
      label: 'images',
      extensions: <String>['jpg', 'png'],
      uniformTypeIdentifiers: <String>['public.jpeg', 'public.png'],
    );
    final XFile? file = await openFile(acceptedTypeGroups: <XTypeGroup>[typeGroup]);
    // #enddocregion SingleOpen
    if (file == null) {
      // Operation was canceled by the user.
      return;
    }
    final String? fileName = await file.name();

    if (context.mounted) {
      await showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return ImageDisplay(file, fileName: fileName ?? 'Unknown Filename');
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Open an image')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
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
  const ImageDisplay(this.file, {super.key, required this.fileName});

  /// The selected file.
  final XFile file;

  /// The name of the selected file.
  final String fileName;

  Future<Image> _getImage() async {
    if (kIsWeb) {
      return Image.network(file.uri);
    } else if (defaultTargetPlatform == TargetPlatform.macOS) {
      return Image.file(File(Uri.parse(file.uri).toFilePath()));
    } else if (file case final FileSystemXFile file) {
      return Image.file(File(file.path));
    }

    return Image.memory(await file.readAsBytes());
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(key: const Key('result_image_name'), fileName),
      content: FutureBuilder<Image>(
        future: _getImage(),
        builder: (_, AsyncSnapshot<Image> snapshot) {
          if (snapshot.hasData) {
            return snapshot.data!;
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: .center,
                children: <Widget>[
                  const Icon(Icons.error_outline, color: Colors.red, size: 60),
                  Padding(padding: const .only(top: 16), child: Text('Error: ${snapshot.error}')),
                ],
              ),
            );
          }

          return const SizedBox.square(dimension: 60, child: CircularProgressIndicator());
        },
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
