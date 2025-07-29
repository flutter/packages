// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'content_progress_provider.dart';
import 'platform_interface/platform_interface.dart';

/// An object containing the data used to request ads from the server.
class AdsRequest {
  /// Creates an [AdsRequest].
  AdsRequest({
    required this.adTagUrl,
    this.adsResponse,
    this.adWillAutoPlay,
    this.adWillPlayMuted,
    this.continuousPlayback,
    this.contentDuration,
    this.contentKeywords,
    this.contentTitle,
    this.liveStreamPrefetchSeconds,
    this.vastLoadTimeout,
    this.contentUrl,
    this.contentProgressProvider,
  }) : this.fromPlatform(
          PlatformAdsRequest(
            adTagUrl: adTagUrl,
            adsResponse: adsResponse,
            adWillAutoPlay: adWillAutoPlay,
            adWillPlayMuted: adWillPlayMuted,
            continuousPlayback: continuousPlayback,
            contentDuration: contentDuration,
            contentKeywords: contentKeywords,
            contentTitle: contentTitle,
            liveStreamPrefetchSeconds: liveStreamPrefetchSeconds,
            vastLoadTimeout: vastLoadTimeout,
            contentUrl: contentUrl,
            contentProgressProvider: contentProgressProvider?.platform,
          ),
        );

  /// Constructs an [AdsRequest] from a specific platform implementation.
  AdsRequest.fromPlatform(this.platform);

  /// Implementation of [PlatformAdsRequest] for the current platform.
  final PlatformAdsRequest platform;

  /// The URL from which ads will be requested.
  final String adTagUrl;

  /// Specifies a VAST, VMAP, or ad rules response to be used instead of making
  /// a request through an ad tag URL.
  final String? adsResponse;

  /// Notifies the SDK whether the player intends to start the content and ad in
  /// response to a user action or whether it will be automatically played.
  final bool? adWillAutoPlay;

  /// Notifies the SDK whether the player intends to start the content and ad
  /// while muted.
  final bool? adWillPlayMuted;

  /// Notifies the SDK whether the player intends to continuously play the
  /// content videos one after another similar to TV broadcast.
  final bool? continuousPlayback;

  /// Specifies the duration of the content in seconds to be shown.
  final double? contentDuration;

  /// Specifies the keywords used to describe the content to be shown.
  final List<String>? contentKeywords;

  /// Specifies the title of the content to be shown.
  final String? contentTitle;

  /// Specifies the maximum amount of time to wait in seconds, after calling
  /// requestAds, before requesting the ad tag URL.
  final double? liveStreamPrefetchSeconds;

  /// Specifies the VAST load timeout in milliseconds for a single wrapper.
  final double? vastLoadTimeout;

  /// Specifies the universal link to the content’s screen.
  final String? contentUrl;

  /// A [ContentProgressProvider] instance to allow scheduling of ad breaks
  /// based on content progress (cue points).
  final ContentProgressProvider? contentProgressProvider;
}
