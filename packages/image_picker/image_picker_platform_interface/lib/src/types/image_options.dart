// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart' show immutable;

/// Specifies image-specific options for picking.
@immutable
base class ImageOptions {
  /// Creates an instance with the given [maxHeight], [maxWidth], [imageQuality]
  /// and [requestFullMetadata].
  const ImageOptions({
    this.maxHeight,
    this.maxWidth,
    this.imageQuality,
    this.requestFullMetadata = true,
  });

  /// Creates an instance with the given [maxHeight], [maxWidth], [imageQuality]
  /// and [requestFullMetadata].
  ///
  /// Throws if options are not valid.
  ImageOptions.createAndValidate({
    this.maxHeight,
    this.maxWidth,
    this.imageQuality,
    this.requestFullMetadata = true,
  }) {
    _validateOptions(maxWidth: maxWidth, maxHeight: maxHeight, imageQuality: imageQuality);
  }

  /// The maximum width of the image, in pixels.
  ///
  /// If null, the image will only be resized if [maxHeight] is specified.
  final int? maxWidth;

  /// The maximum height of the image, in pixels.
  ///
  /// If null, the image will only be resized if [maxWidth] is specified.
  final int? maxHeight;

  /// Modifies the quality of the image, ranging from 0-100 where 100 is the
  /// original/max quality.
  ///
  /// Compression is only supported for certain image types such as JPEG. If
  /// compression is not supported for the image that is picked, a warning
  /// message will be logged.
  ///
  /// If null, the image will be returned with the original quality.
  final int? imageQuality;

  /// If true, requests full image metadata, which may require extra permissions
  /// on some platforms, (e.g., NSPhotoLibraryUsageDescription on iOS).
  ///
  /// Defaults to true.
  final bool requestFullMetadata;

  /// Validates that all values are within required ranges. Throws if not.
  static void _validateOptions({int? maxWidth, int? maxHeight, int? imageQuality}) {
    if (imageQuality != null) {
      RangeError.checkValueInInterval(imageQuality, 0, 100, 'imageQuality');
    }
    if (maxWidth != null) {
      RangeError.checkNotNegative(maxWidth, 'maxWidth');
    }
    if (maxHeight != null) {
      RangeError.checkNotNegative(maxHeight, 'maxHeight');
    }
  }
}
