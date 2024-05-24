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
  ///
  /// Throws if limit is lower than 2,
  /// or allowMultiple is false and limit is not null.
  MediaOptions.createAndValidate({
    this.imageOptions = const ImageOptions(),
    required this.allowMultiple,
    this.limit,
  }) {
    _validate(allowMultiple: allowMultiple, limit: limit);
  }

  /// Options that will apply to images upon selection.
  final ImageOptions imageOptions;

  /// Whether to allow for selecting multiple media.
  final bool allowMultiple;

  /// The maximum number of images to select.
  ///
  /// Default null value means no limit.
  /// This value may be ignored by platforms that cannot support it.
  final int? limit;

  /// Validates that all values are within required ranges.
  ///
  /// Throws if limit is lower than 2,
  /// or allowMultiple is false and limit is not null.
  static void _validate({required bool allowMultiple, int? limit}) {
    if (!allowMultiple && limit != null) {
      throw ArgumentError.value(
        allowMultiple,
        'allowMultiple',
        'cannot be false, when limit is not null',
      );
    }

    if (limit != null && limit < 2) {
      throw ArgumentError.value(limit, 'limit', 'cannot be lower then 2');
    }
  }
}
