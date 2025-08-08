// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'platform_content_progress_provider.dart';

/// An object containing the data used to request ads from the server.
sealed class PlatformAdsRequest {
  PlatformAdsRequest._({
    this.contentProgressProvider,
    this.adWillAutoPlay,
    this.adWillPlayMuted,
    this.continuousPlayback,
    this.contentDuration,
    this.contentKeywords,
    this.contentTitle,
    this.liveStreamPrefetchMaxWaitTime,
    this.vastLoadTimeout,
  });

  /// Creates a [PlatformAdsRequest] with the given ad tag URL.
  factory PlatformAdsRequest.withAdTagUrl({
    required String adTagUrl,
    PlatformContentProgressProvider? contentProgressProvider,
    bool? adWillAutoPlay,
    bool? adWillPlayMuted,
    bool? continuousPlayback,
    Duration? contentDuration,
    List<String>? contentKeywords,
    String? contentTitle,
    Duration? liveStreamPrefetchMaxWaitTime,
    Duration? vastLoadTimeout,
  }) =>
      PlatformAdsRequestWithAdTagUrl._(
        adTagUrl: adTagUrl,
        contentProgressProvider: contentProgressProvider,
        adWillAutoPlay: adWillAutoPlay,
        adWillPlayMuted: adWillPlayMuted,
        continuousPlayback: continuousPlayback,
        contentDuration: contentDuration,
        contentKeywords: contentKeywords,
        contentTitle: contentTitle,
        liveStreamPrefetchMaxWaitTime: liveStreamPrefetchMaxWaitTime,
        vastLoadTimeout: vastLoadTimeout,
      );

  /// Creates a [PlatformAdsRequest] with the given canned ads response.
  factory PlatformAdsRequest.withAdsResponse({
    required String adsResponse,
    PlatformContentProgressProvider? contentProgressProvider,
    bool? adWillAutoPlay,
    bool? adWillPlayMuted,
    bool? continuousPlayback,
    Duration? contentDuration,
    List<String>? contentKeywords,
    String? contentTitle,
    Duration? liveStreamPrefetchMaxWaitTime,
    Duration? vastLoadTimeout,
  }) =>
      PlatformAdsRequestWithAdsResponse._(
        adsResponse: adsResponse,
        contentProgressProvider: contentProgressProvider,
        adWillAutoPlay: adWillAutoPlay,
        adWillPlayMuted: adWillPlayMuted,
        continuousPlayback: continuousPlayback,
        contentDuration: contentDuration,
        contentKeywords: contentKeywords,
        contentTitle: contentTitle,
        liveStreamPrefetchMaxWaitTime: liveStreamPrefetchMaxWaitTime,
        vastLoadTimeout: vastLoadTimeout,
      );

  /// A [PlatformContentProgressProvider] instance to allow scheduling of ad
  /// breaks based on content progress (cue points).
  final PlatformContentProgressProvider? contentProgressProvider;

  /// Notifies the SDK whether the player intends to start the content and ad in
  /// response to a user action or whether it will be automatically played.
  final bool? adWillAutoPlay;

  /// Notifies the SDK whether the player intends to start the content and ad
  /// while muted.
  final bool? adWillPlayMuted;

  /// Notifies the SDK whether the player intends to continuously play the
  /// content videos one after another similar to TV broadcast.
  final bool? continuousPlayback;

  /// Specifies the duration of the content to be shown.
  final Duration? contentDuration;

  /// Specifies the keywords used to describe the content to be shown.
  final List<String>? contentKeywords;

  /// Specifies the title of the content to be shown.
  final String? contentTitle;

  /// Specifies the maximum amount of time to wait, after calling requestAds,
  /// before requesting the ad tag URL.
  final Duration? liveStreamPrefetchMaxWaitTime;

  /// Specifies the VAST load timeout for a single wrapper.
  final Duration? vastLoadTimeout;
}

/// An object containing the data used to request ads from the server with an
/// ad tag URL.
base class PlatformAdsRequestWithAdTagUrl extends PlatformAdsRequest {
  /// Constructs a [PlatformAdsRequestWithAdTagUrl].
  PlatformAdsRequestWithAdTagUrl._({
    required this.adTagUrl,
    super.contentProgressProvider,
    super.adWillAutoPlay,
    super.adWillPlayMuted,
    super.continuousPlayback,
    super.contentDuration,
    super.contentKeywords,
    super.contentTitle,
    super.liveStreamPrefetchMaxWaitTime,
    super.vastLoadTimeout,
  }) : super._();

  /// The URL from which ads will be requested.
  final String adTagUrl;
}

/// An object containing the data used to request ads from the server with an
/// ad rules response.
base class PlatformAdsRequestWithAdsResponse extends PlatformAdsRequest {
  /// Constructs a [PlatformAdsRequestWithAdsResponse].
  PlatformAdsRequestWithAdsResponse._({
    required this.adsResponse,
    super.contentProgressProvider,
    super.adWillAutoPlay,
    super.adWillPlayMuted,
    super.continuousPlayback,
    super.contentDuration,
    super.contentKeywords,
    super.contentTitle,
    super.liveStreamPrefetchMaxWaitTime,
    super.vastLoadTimeout,
  }) : super._();

  /// Specifies a VAST, VMAP, or ad rules response to be used instead of making
  /// a request through an ad tag URL.
  final String adsResponse;
}
