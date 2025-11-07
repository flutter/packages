// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';

/// Specifies options for picking multiple videos.
@immutable
class MultiVideoPickerOptions {
  /// Creates an instance with the given options.
  const MultiVideoPickerOptions({this.maxDuration, this.limit});

  /// The maximum duration of the picked video.
  final Duration? maxDuration;

  /// The maximum number of videos that can be selected.
  ///
  /// This value may be ignored by platforms that cannot support it.
  final int? limit;
}
