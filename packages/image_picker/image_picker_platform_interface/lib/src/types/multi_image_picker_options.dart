// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'image_options.dart';

/// Specifies options for picking multiple images from the device's gallery.
class MultiImagePickerOptions {
  /// Creates an instance with the given [imageOptions].
  const MultiImagePickerOptions({
    this.imageOptions = const ImageOptions(),
    this.maxImages,
  });

  /// Creates an instance with the given [imageOptions] and [maxImages].
  /// Throws if options are not valid.
  MultiImagePickerOptions.createAndValidate({
    this.imageOptions = const ImageOptions(),
    this.maxImages,
  }) {
    _validateOptions(
      maxImages: maxImages,
    );
  }

  /// The image-specific options for picking.
  final ImageOptions imageOptions;

  /// Maximum number of images that can be picked.
  ///
  /// If null, the platform limits the maximum number of images.
  final int? maxImages;

  /// Validates that all values are within required ranges. Throws if not.
  static void _validateOptions({int? maxImages}) {
    if (maxImages != null && maxImages < 1) {
      throw ArgumentError.value(maxImages, 'maxImages', 'must be positive');
    }
  }
}
