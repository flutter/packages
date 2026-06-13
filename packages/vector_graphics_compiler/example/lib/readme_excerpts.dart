// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// This file exists solely to host compiled excerpts for README.md, and is not
// intended for use as an actual example application.

import 'package:flutter/widgets.dart';
import 'package:vector_graphics/vector_graphics.dart';

/// Builds a vector graphic from a pre-compiled asset.
// #docregion asset-loader
Widget buildIcon() {
  return const VectorGraphic(
    loader: AssetBytesLoader('assets/dart_logo.svg'),
    semanticsLabel: 'Dart logo',
  );
}

// #enddocregion asset-loader
