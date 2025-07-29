// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';

import 'content_progress_provider.dart';
import 'platform_interface/platform_interface.dart';

/// An object containing the data used to request ads from the server.
@immutable
class AdsRequest {
  /// Creates an [AdsRequest].
  AdsRequest({
    required String adTagUrl,
    ContentProgressProvider? contentProgressProvider,
  }) : this.fromPlatformCreationParams(
          PlatformAdsRequestCreationParams(
            adTagUrl: adTagUrl,
            contentProgressProvider: contentProgressProvider?.platform,
          ),
        );

  /// Creates an [AdsRequest] with a VAST, VMAP, or ad rules response to be
  /// used instead of making a request through an ad tag URL.
  AdsRequest.fromAdsResponse({
    required String adsResponse,
    ContentProgressProvider? contentProgressProvider,
  }) : this.fromPlatformCreationParams(
          PlatformAdsRequestCreationParams(
            adsResponse: adsResponse,
            contentProgressProvider: contentProgressProvider?.platform,
          ),
        );

  /// Constructs an [AdsRequest] from creation params for a specific platform.
  AdsRequest.fromPlatformCreationParams(
    PlatformAdsRequestCreationParams params,
  ) : this.fromPlatform(PlatformAdsRequest(params));

  /// Constructs an [AdsRequest] from a specific platform implementation.
  const AdsRequest.fromPlatform(this.platform);

  /// Implementation of [PlatformAdsRequest] for the current platform.
  final PlatformAdsRequest platform;

  /// Notifies the SDK whether the player intends to start the content and ad in
  /// response to a user action or whether it will be automatically played.
  ///
  /// Not calling this function leaves the setting as unknown. Note: Changing
  /// this setting will have no impact on ad playback.
  Future<void> setAdWillAutoPlay(bool adWillAutoPlay) {
    return platform.setAdWillAutoPlay(adWillAutoPlay);
  }

  /// Notifies the SDK whether the player intends to start the content and ad
  /// while muted.
  ///
  /// Not calling this function leaves the setting as unknown. Note: Changing
  /// this setting will have no impact on ad playback.
  Future<void> setAdWillPlayMuted(bool adWillPlayMuted) {
    return platform.setAdWillPlayMuted(adWillPlayMuted);
  }

  /// Notifies the SDK whether the player intends to continuously play the
  /// content videos one after another similar to TV broadcast.
  ///
  /// Not calling this function leaves the setting as unknown. Note: Changing
  /// this setting will have no impact on ad playback.
  Future<void> setContinuousPlayback(bool continuousPlayback) {
    return platform.setContinuousPlayback(continuousPlayback);
  }

  /// Specifies the duration of the content in seconds to be shown.
  ///
  /// This optional parameter is used by AdX requests. It is recommended for AdX
  /// users.
  Future<void> setContentDuration(double contentDuration) {
    return platform.setContentDuration(contentDuration);
  }

  /// Specifies the keywords used to describe the content to be shown.
  ///
  -/// This optional parameter is used by AdX requests and is recommended for AdX
  /// users.
  Future<void> setContentKeywords(List<String> contentKeywords) {
    return platform.setContentKeywords(contentKeywords);
  }

  /// Specifies the title of the content to be shown.
  ///
  /// Used in AdX requests. This optional parameter is used by AdX requests and
  /// is recommended for AdX users.
  Future<void> setContentTitle(String contentTitle) {
    return platform.setContentTitle(contentTitle);
  }

  /// Specifies the universal link to the content’s screen.
  ///
  /// If provided, this parameter is passed to the OM SDK. See
  /// [Apple documentation](https://developer.apple.com/documentation/xcode/allowing-apps-and-websites-to-link-to-your-content)
  /// for more information.
  Future<void> setContentUrl(String contentUrl) {
    return platform.setContentUrl(contentUrl);
  }

  /// Specifies the maximum amount of time to wait in seconds, after calling
  /// requestAds, before requesting the ad tag URL.
  ///
  /// This can be used to stagger requests during a live-stream event, in order
  /// to mitigate spikes in the number of requests.
  Future<void> setLiveStreamPrefetchSeconds(double liveStreamPrefetchSeconds) {
    return platform.setLiveStreamPrefetchSeconds(liveStreamPrefetchSeconds);
  }

  /// Specifies the VAST load timeout in milliseconds for a single wrapper.
  ///
  /// This parameter is optional and will override the default timeout,
  /// currently set to 5000ms.
  Future<void> setVastLoadTimeout(double vastLoadTimeout) {
    return platform.setVastLoadTimeout(vastLoadTimeout);
  }
}
