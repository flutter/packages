// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'platform_content_progress_provider.dart';

/// An object containing the data used to request ads from the server.
class AdsRequest {
  /// Creates an [AdsRequest].
  AdsRequest({
    required this.adTagUrl,
    this.contentDuration,
    this.contentProgressProvider,
  });

  /// The URL from which ads will be requested.
  final String adTagUrl;

  /// The duration of the content video to be shown.
  final Duration? contentDuration;

  /// A [PlatformContentProgressProvider] instance to allow scheduling of ad
  /// breaks based on content progress (cue points).
  final PlatformContentProgressProvider? contentProgressProvider;
}
