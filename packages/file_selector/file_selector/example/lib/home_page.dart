// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Home Page of the application
class HomePage extends StatelessWidget {
  /// Default Constructor
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final ButtonStyle style = ElevatedButton.styleFrom(
      backgroundColor: Colors.blue,
      foregroundColor: Colors.white,
    );
    return Scaffold(
      appBar: AppBar(title: const Text('File Selector Demo Home Page')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              style: style,
              child: const Text('Open a text file'),
              onPressed: () => Navigator.pushNamed(context, '/open/text'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              style: style,
              child: const Text('Open an image'),
              onPressed: () => Navigator.pushNamed(context, '/open/image'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              style: style,
              child: const Text('Open multiple images'),
              onPressed: () => Navigator.pushNamed(context, '/open/images'),
            ),
            // TODO(stuartmorgan): Replace these checks with support queries once
            // https://github.com/flutter/flutter/issues/127328 is implemented.
            if (kIsWeb || !(Platform.isAndroid || Platform.isIOS)) ...<Widget>[
              const SizedBox(height: 10),
              ElevatedButton(
                style: style,
                child: const Text('Save a file'),
                onPressed: () => Navigator.pushNamed(context, '/save/text'),
              ),
            ],
            if (!(kIsWeb || Platform.isIOS)) ...<Widget>[
              const SizedBox(height: 10),
              ElevatedButton(
                style: style,
                child: const Text('Open a get directory dialog'),
                onPressed: () => Navigator.pushNamed(context, '/directory'),
              ),
            ],
            if (!(kIsWeb || Platform.isAndroid || Platform.isIOS)) ...<Widget>[
              const SizedBox(height: 10),
              ElevatedButton(
                style: style,
                child: const Text('Open a get multi directories dialog'),
                onPressed:
                    () => Navigator.pushNamed(context, '/multi-directories'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
