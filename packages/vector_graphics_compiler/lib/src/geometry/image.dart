// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:typed_data';

import 'basic_types.dart';

/// The encoded image data and its format.
class ImageData {
  /// Create a new [ImageData].
  const ImageData(
    this.data,
    this.format,
  );

  /// An encoded image.
  final Uint8List data;

  /// The encoding format of the [data].
  ///
  /// Currently only `0` - corresponding to PNG encoding is
  /// supported.
  final int format;
}

/// A command to draw an image at a particular location.
class DrawImageData {
  /// Create a new [DrawImageData].
  const DrawImageData(
    this.id,
    this.rect,
  );

  /// The corresponding encoding image to draw.
  final int id;

  /// The x position of the image in pixels.
  final Rect rect;
}
