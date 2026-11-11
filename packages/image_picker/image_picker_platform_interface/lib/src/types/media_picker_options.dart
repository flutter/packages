// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart' show immutable;

import 'image_options.dart';
import 'video_options.dart';

/// Specifies options for selecting items when using
/// [ImagePickerPlatform.pickMedia].
@immutable
base class MediaPickerOptions {
  /// Construct a new MediaPickerOptions instance.
  const MediaPickerOptions({
    this.imageOptions = const ImageOptions(),
    this.videoOptions = const VideoOptions(),
    required this.allowMultiple,
    this.limit,
  });

  /// Construct a new MediaOptions instance.
  ///
  /// Throws if limit is lower than 2,
  /// or allowMultiple is false and limit is not null.
  MediaPickerOptions.createAndValidate({
    this.imageOptions = const ImageOptions(),
    this.videoOptions = const VideoOptions(),
    required this.allowMultiple,
    this.limit,
  }) {
    _validate(allowMultiple: allowMultiple, limit: limit);
  }

  /// Options that will apply to images upon selection.
  final ImageOptions imageOptions;

  /// Options that will apply to video upon selection.
  final VideoOptions videoOptions;

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
      throw ArgumentError.value(limit, 'limit', 'cannot be lower than 2');
    }
  }
}
