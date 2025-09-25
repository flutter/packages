// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:typed_data';
import 'package:flutter/foundation.dart' show immutable;

/// Contains information about a Tile that is returned by a [TileProvider].
@immutable
class Tile {
  /// Creates an immutable representation of a [Tile] to draw by [TileProvider].
  const Tile(this.width, this.height, this.data);

  /// The width of the image encoded by data in logical pixels.
  final int width;

  /// The height of the image encoded by data in logical pixels.
  final int height;

  /// A byte array containing the image data.
  ///
  /// The image data format must be natively supported for decoding by the platform.
  /// e.g on Android it can only be one of the [supported image formats for decoding](https://developer.android.com/guide/topics/media/media-formats#image-formats).
  final Uint8List? data;

  /// Converts this object to JSON.
  Object toJson() {
    final Map<String, Object> json = <String, Object>{};

    void addIfPresent(String fieldName, Object? value) {
      if (value != null) {
        json[fieldName] = value;
      }
    }

    addIfPresent('width', width);
    addIfPresent('height', height);
    addIfPresent('data', data);

    return json;
  }
}
