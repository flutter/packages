// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart' show immutable;

/// Specifies video-specific options for picking.
@immutable
base class VideoOptions {
  /// Creates an instance with the given [maxDuration].
  const VideoOptions({this.maxDuration});

  /// Creates an instance with the given [maxDuration]. Throws if options are
  /// not valid.
  VideoOptions.createAndValidate({this.maxDuration}) {
    _validateOptions(maxDuration: maxDuration);
  }

  /// Specifies the maximum duration of the captured video.
  ///
  /// If no [maxDuration] is specified, the maximum duration will be infinite.
  final Duration? maxDuration;

  /// Validates that all values are within required ranges.
  ///
  /// Throws if maxDuration is lower than [Duration.zero].
  static void _validateOptions({Duration? maxDuration}) {
    if (maxDuration != null && (maxDuration.isNegative || maxDuration == Duration.zero)) {
      throw ArgumentError.value(maxDuration, 'maxDuration', 'must be greater than zero.');
    }
  }
}
