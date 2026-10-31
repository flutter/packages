// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Widget that builds an [Image] from an XFile.
class ImageBuilder extends StatelessWidget {
  /// Default Constructor.
  const ImageBuilder(this.file, {super.key});

  /// The selected file.
  final XFile file;

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
    return FutureBuilder<Image>(
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
    );
  }
}
