// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'image_options.dart';

/// Specifies options for picking multiple images from the device's gallery.
class MultiImagePickerOptions {
  /// Creates an instance with the given [imageOptions].
  const MultiImagePickerOptions({
    this.imageOptions = const ImageOptions(),
    this.limit,
  });

  /// The image-specific options for picking.
  final ImageOptions imageOptions;

  /// The maximum number of images to select. Default null value means no limit.
  final int? limit;
}
