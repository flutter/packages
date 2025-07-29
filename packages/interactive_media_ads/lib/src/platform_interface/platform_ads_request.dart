// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';

import 'interactive_media_ads_platform.dart';
import 'platform_content_progress_provider.dart';

/// Creation parameters for a [PlatformAdsRequest].
@immutable
base class PlatformAdsRequestCreationParams {
  /// Creates a [PlatformAdsRequestCreationParams].
  const PlatformAdsRequestCreationParams({
    this.adTagUrl,
    this.adsResponse,
    this.contentProgressProvider,
  }) : assert(
          (adTagUrl != null && adsResponse == null) ||
              (adTagUrl == null && adsResponse != null),
          'Exactly one of `adTagUrl` or `adsResponse` must be provided.',
        );

  /// The URL from which ads will be requested.
  final String? adTagUrl;

  /// Specifies a VAST, VMAP, or ad rules response to be used instead of making
  /// a request through an ad tag URL.
  final String? adsResponse;

  /// A [PlatformContentProgressProvider] instance to allow scheduling of ad
  /// breaks based on content progress (cue points).
  final PlatformContentProgressProvider? contentProgressProvider;
}

/// An object containing the data used to request ads from the server.
abstract base class PlatformAdsRequest {
  /// Creates a new [PlatformAdsRequest].
  factory PlatformAdsRequest(PlatformAdsRequestCreationParams params) {
    assert(InteractiveMediaAdsPlatform.instance != null);
    final PlatformAdsRequest implementation =
        InteractiveMediaAdsPlatform.instance!.createPlatformAdsRequest(params);
    return implementation;
  }

  /// Used by the platform implementation to create a new [PlatformAdsRequest].
  ///
  /// Should only be used by platform implementations because they can't extend
  /// a class that only contains a factory constructor.
  @protected
  PlatformAdsRequest.implementation(this.params);

  /// The parameters used to initialize the [PlatformAdsRequest].
  final PlatformAdsRequestCreationParams params;

  /// Notifies the SDK whether the player intends to start the content and ad in
  /// response to a user action or whether it will be automatically played.
  ///
  /// Not calling this function leaves the setting as unknown. Note: Changing
  /// this setting will have no impact on ad playback.
  Future<void> setAdWillAutoPlay(bool adWillAutoPlay);

  /// Notifies the SDK whether the player intends to start the content and ad
  /// while muted.
  ///
  /// Not calling this function leaves the setting as unknown. Note: Changing
  /// this setting will have no impact on ad playback.
  Future<void> setAdWillPlayMuted(bool adWillPlayMuted);

  /// Notifies the SDK whether the player intends to continuously play the
  /// content videos one after another similar to TV broadcast.
  ///
  /// Not calling this function leaves the setting as unknown. Note: Changing
  /// this setting will have no impact on ad playback.
  Future<void> setContinuousPlayback(bool continuousPlayback);

  /// Specifies the duration of the content in seconds to be shown.
  ///
  /// This optional parameter is used by AdX requests. It is recommended for AdX
  /// users.
  Future<void> setContentDuration(double contentDuration);

  /// Specifies the keywords used to describe the content to be shown.
  ///
  -/// This optional parameter is used by AdX requests and is recommended for AdX
  /// users.
  Future<void> setContentKeywords(List<String> contentKeywords);

  /// Specifies the title of the content to be shown.
  ///
  /// Used in AdX requests. This optional parameter is used by AdX requests and
  /// is recommended for AdX users.
  Future<void> setContentTitle(String contentTitle);

  /// Specifies the universal link to the content’s screen.
  ///
  /// If provided, this parameter is passed to the OM SDK. See
  /// [Apple documentation](https://developer.apple.com/documentation/xcode/allowing-apps-and-websites-to-link-to-your-content)
  /// for more information.
  Future<void> setContentUrl(String contentUrl);

  /// Specifies the maximum amount of time to wait in seconds, after calling
  /// requestAds, before requesting the ad tag URL.
  ///
  /// This can be used to stagger requests during a live-stream event, in order
  /// to mitigate spikes in the number of requests.
  Future<void> setLiveStreamPrefetchSeconds(double liveStreamPrefetchSeconds);

  /// Specifies the VAST load timeout in milliseconds for a single wrapper.
  ///
  /// This parameter is optional and will override the default timeout,
  /// currently set to 5000ms.
  Future<void> setVastLoadTimeout(double vastLoadTimeout);
}
