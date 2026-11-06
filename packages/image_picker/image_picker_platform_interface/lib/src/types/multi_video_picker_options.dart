// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart' show immutable;

import 'video_options.dart';

/// Specifies options for picking multiple videos.
@immutable
base class MultiVideoPickerOptions {
  /// Creates an instance with the given [videoOptions] and [limit].
  const MultiVideoPickerOptions({this.videoOptions = const VideoOptions(), this.limit});

  /// Creates an instance with the given [videoOptions] and [limit].
  ///
  /// Throws if limit is lower than 2.
  MultiVideoPickerOptions.createAndValidate({
    this.videoOptions = const VideoOptions(),
    this.limit,
  }) {
    _validate(limit: limit);
  }

  /// The video-specific options for picking.
  final VideoOptions videoOptions;

  /// The maximum number of videos that can be selected.
  ///
  /// This value may be ignored by platforms that cannot support it.
  final int? limit;

  /// Validates that all values are within required ranges.
  ///
  /// Throws if limit is lower than 2.
  static void _validate({int? limit}) {
    if (limit != null && limit < 2) {
      throw RangeError.range(limit, 2, null, 'limit');
    }
  }
}
