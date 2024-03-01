// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';

import '../../image_picker_platform_interface.dart';

/// Specifies options for selecting items when using [ImagePickerPlatform.getMedia].
@immutable
class MediaOptions {
  /// Construct a new MediaOptions instance.
  const MediaOptions({
    this.imageOptions = const ImageOptions(),
    required this.allowMultiple,
    this.limit,
  });

  /// Construct a new MediaOptions instance.
  /// Throws if limit is not valid.
  MediaOptions.createAndValidate({
    this.imageOptions = const ImageOptions(),
    required this.allowMultiple,
    this.limit,
  }) {
    _validateOptions(limit: limit);
  }

  /// Options that will apply to images upon selection.
  final ImageOptions imageOptions;

  /// Whether to allow for selecting multiple media.
  final bool allowMultiple;

  /// The maximum number of images to select. Default null value means no limit.
  final int? limit;

  /// Validates that all values are within required ranges. Throws if not.
  static void _validateOptions({int? limit}) {
    if (limit != null && limit < 2) {
      throw ArgumentError.value(limit, 'limit', 'cannot be lower then 2');
    }
  }
}
