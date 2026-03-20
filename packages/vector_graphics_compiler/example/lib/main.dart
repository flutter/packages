// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:vector_graphics/vector_graphics.dart';

void main() {
  runApp(const ExampleApp());
}

/// An example app demonstrating `vector_graphics_compiler` as a build-time
/// SVG asset transformer.
///
/// The SVG file at `assets/dart_logo.svg` is automatically compiled to the
/// vector_graphics binary format at build time via the `transformers`
/// configuration in this app's `pubspec.yaml`. At runtime, the pre-compiled
/// asset is loaded using [AssetBytesLoader] and rendered with [VectorGraphic].
class ExampleApp extends StatelessWidget {
  /// Creates a new [ExampleApp].
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'vector_graphics_compiler Example',
      home: Scaffold(
        appBar: AppBar(title: const Text('Build-time SVG Transformer')),
        body: const Center(
          child: SizedBox(
            width: 200,
            height: 200,
            child: VectorGraphic(
              loader: AssetBytesLoader('assets/dart_logo.svg'),
              semanticsLabel: 'Dart logo',
            ),
          ),
        ),
      ),
    );
  }
}
