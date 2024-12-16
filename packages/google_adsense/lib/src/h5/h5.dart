// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import '../core/js_interop/adsbygoogle.dart';
import 'h5_js_interop.dart';

export 'enums.dart'
    show BreakFormat, BreakStatus, BreakType, PreloadAdBreaks, SoundEnabled;
export 'h5_js_interop.dart'
    show
        AdBreakDonePlacementInfo,
        AdBreakPlacement,
        AdConfigParameters,
        H5AdBreakDoneCallback,
        H5AdDismissedCallback,
        H5AdViewedCallback,
        H5AfterAdCallback,
        H5BeforeAdCallback,
        H5BeforeRewardCallback,
        H5OnReadyCallback,
        H5ShowAdFn;

/// A client to request H5 Games Ads (Ad Placement API).
class H5GamesAdsClient {
  /// Requests an ad placement to the Ad Placement API.
  ///
  /// The [placementConfig] defines the configuration of the ad.
  void adBreak(
    AdBreakPlacement placementConfig,
  ) {
    // Delay the call to `adBreak` so tap users don't trigger a click on the ad
    // on pointerup. This should leaves enough time for Flutter to settle its
    // tap events, before triggering the H5 ad.
    Timer(const Duration(milliseconds: 100), () {
      adsbygoogle.adBreak(placementConfig);
    });
  }

  /// Communicates the app's current configuration to the Ad Placement API.
  ///
  /// The Ad Placement API can use this to tune the way it preloads ads and to
  /// filter the kinds of ads it requests so they're suitable (eg. video ads
  /// that require sound).
  ///
  /// Call this function as soon as the sound state of your game changes, as the
  /// Ad Placement API may have to request new creatives, and this gives it the
  /// maximum amount of time to do so. See `sound` in [AdConfigParameters].
  void adConfig(
    AdConfigParameters parameters,
  ) {
    adsbygoogle.adConfig(parameters);
  }
}

/// The singleton instance of the H5 Games Ads client.
final H5GamesAdsClient h5GamesAds = H5GamesAdsClient();
