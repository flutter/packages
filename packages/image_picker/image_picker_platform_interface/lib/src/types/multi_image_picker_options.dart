// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'image_options.dart';

/// Specifies options for picking multiple images from the device's gallery.
class MultiImagePickerOptions {
  /// Creates an instance with the given [imageOptions] and [limit].
  const MultiImagePickerOptions({
    this.imageOptions = const ImageOptions(),
    this.limit,
  });

  /// Creates an instance with the given [imageOptions] and [limit].
  ///
  /// Throws if limit is lower than 2.
  MultiImagePickerOptions.createAndValidate({
    this.imageOptions = const ImageOptions(),
    this.limit,
  }) {
    _validate(limit: limit);
  }

  /// The image-specific options for picking.
  final ImageOptions imageOptions;

  /// The maximum number of images to select.
  ///
  /// Default null value means no limit.
  /// This value may be ignored by platforms that cannot support it.
  final int? limit;

  /// Validates that all values are within required ranges.
  ///
  /// Throws if limit is lower than 2.
  static void _validate({int? limit}) {
    if (limit != null && limit < 2) {
      throw ArgumentError.value(limit, 'limit', 'cannot be lower then 2');
    }
  }
}
