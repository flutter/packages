// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'content_progress_provider.dart';
import 'platform_interface/platform_interface.dart';

/// An object containing the data used to request ads from the server.
class AdsRequest {
  /// Creates an [AdsRequest] with the given ad tag URL.
  AdsRequest({
    required String adTagUrl,
    ContentProgressProvider? contentProgressProvider,
    bool? adWillAutoPlay,
    bool? adWillPlayMuted,
    bool? continuousPlayback,
    Duration? contentDuration,
    List<String>? contentKeywords,
    String? contentTitle,
    Duration? liveStreamPrefetchMaxWaitTime,
    Duration? vastLoadTimeout,
  }) : this.fromPlatform(
          PlatformAdsRequest.withAdTagUrl(
            adTagUrl: adTagUrl,
            contentProgressProvider: contentProgressProvider?.platform,
            adWillAutoPlay: adWillAutoPlay,
            adWillPlayMuted: adWillPlayMuted,
            continuousPlayback: continuousPlayback,
            contentDuration: contentDuration,
            contentKeywords: contentKeywords,
            contentTitle: contentTitle,
            liveStreamPrefetchMaxWaitTime: liveStreamPrefetchMaxWaitTime,
            vastLoadTimeout: vastLoadTimeout,
          ),
        );

  /// Creates an [AdsRequest] with the given canned ads response.
  AdsRequest.withAdsResponse({
    required String adsResponse,
    ContentProgressProvider? contentProgressProvider,
    bool? adWillAutoPlay,
    bool? adWillPlayMuted,
    bool? continuousPlayback,
    Duration? contentDuration,
    List<String>? contentKeywords,
    String? contentTitle,
    Duration? liveStreamPrefetchMaxWaitTime,
    Duration? vastLoadTimeout,
  }) : this.fromPlatform(
          PlatformAdsRequest.withAdsResponse(
            adsResponse: adsResponse,
            contentProgressProvider: contentProgressProvider?.platform,
            adWillAutoPlay: adWillAutoPlay,
            adWillPlayMuted: adWillPlayMuted,
            continuousPlayback: continuousPlayback,
            contentDuration: contentDuration,
            contentKeywords: contentKeywords,
            contentTitle: contentTitle,
            liveStreamPrefetchMaxWaitTime: liveStreamPrefetchMaxWaitTime,
            vastLoadTimeout: vastLoadTimeout,
          ),
        );

  /// Constructs an [AdsRequest] from a specific platform implementation.
  AdsRequest.fromPlatform(this.platform);

  /// Implementation of [PlatformAdsRequest] for the current platform.
  final PlatformAdsRequest platform;

  /// The URL from which ads will be requested.
  String get adTagUrl => switch (platform) {
        final PlatformAdsRequestWithAdTagUrl request => request.adTagUrl,
        // TODO(bparrishMines): This returns an empty string rather than null
        // to prevent a breaking change. This should be updated to return null
        // on the next major release.
        PlatformAdsRequestWithAdsResponse() => '',
      };

  /// Specifies a VAST, VMAP, or ad rules response to be used instead of making
  /// a request through an ad tag URL.
  String? get adsResponse => switch (platform) {
        final PlatformAdsRequestWithAdsResponse request => request.adsResponse,
        PlatformAdsRequestWithAdTagUrl() => null,
      };

  /// A [ContentProgressProvider] instance to allow scheduling of ad breaks
  /// based on content progress (cue points).
  ContentProgressProvider? get contentProgressProvider => platform
              .contentProgressProvider !=
          null
      ? ContentProgressProvider.fromPlatform(platform.contentProgressProvider!)
      : null;

  /// Notifies the SDK whether the player intends to start the content and ad in
  /// response to a user action or whether it will be automatically played.
  bool? get adWillAutoPlay => platform.adWillAutoPlay;

  /// Notifies the SDK whether the player intends to start the content and ad
  /// while muted.
  bool? get adWillPlayMuted => platform.adWillPlayMuted;

  /// Notifies the SDK whether the player intends to continuously play the
  /// content videos one after another similar to TV broadcast.
  bool? get continuousPlayback => platform.continuousPlayback;

  /// Specifies the duration of the content to be shown.
  Duration? get contentDuration => platform.contentDuration;

  /// Specifies the keywords used to describe the content to be shown.
  List<String>? get contentKeywords => platform.contentKeywords;

  /// Specifies the title of the content to be shown.
  String? get contentTitle => platform.contentTitle;

  /// Specifies the maximum amount of time to wait, after calling requestAds,
  /// before requesting the ad tag URL.
  Duration? get liveStreamPrefetchMaxWaitTime =>
      platform.liveStreamPrefetchMaxWaitTime;

  /// Specifies the VAST load timeout in milliseconds for a single wrapper.
  Duration? get vastLoadTimeout => platform.vastLoadTimeout;
}
