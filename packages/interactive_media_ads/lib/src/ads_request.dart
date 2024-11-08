// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'content_progress_provider.dart';
import 'platform_interface/platform_interface.dart';

/// An object containing the data used to request ads from the server.
class AdsRequest {
  /// Creates an [AdsRequest].
  AdsRequest({
    required String adTagUrl,
    ContentProgressProvider? contentProgressProvider,
  }) : this.fromPlatform(
          PlatformAdsRequest(
            adTagUrl: adTagUrl,
            contentProgressProvider: contentProgressProvider?.platform,
          ),
        );

  /// Constructs an [AdsRequest] from a specific platform implementation.
  AdsRequest.fromPlatform(this.platform);

  /// Implementation of [PlatformAdsRequest] for the current platform.
  final PlatformAdsRequest platform;

  /// The URL from which ads will be requested.
  String get adTagUrl => platform.adTagUrl;

  /// A [ContentProgressProvider] instance to allow scheduling of ad breaks
  /// based on content progress (cue points).
  ContentProgressProvider? get contentProgressProvider => platform
              .contentProgressProvider !=
          null
      ? ContentProgressProvider.fromPlatform(platform.contentProgressProvider!)
      : null;
}
