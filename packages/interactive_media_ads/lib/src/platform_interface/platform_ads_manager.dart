// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';

import 'platform_ads_manager_delegate.dart';
import 'platform_ads_rendering_settings.dart';

/// Additional parameter passed to an [PlatformAdsManager] when starting to play
/// ads.
base class AdsManagerStartParams {}

/// Interface for a platform implementation of an `AdsManager`.
abstract class PlatformAdsManager {
  /// Creates a [PlatformAdsManager].
  @protected
  PlatformAdsManager();

  /// Initializes the ad experience using default rendering settings.
  Future<void> init({PlatformAdsRenderingSettings? settings});

  /// Starts playing the ads.
  Future<void> start(AdsManagerStartParams params);

  /// /// The [AdsManagerDelegate] to notify with events during ad playback.
  Future<void> setAdsManagerDelegate(PlatformAdsManagerDelegate delegate);

  /// Pauses the current ad.
  Future<void> pause();

  /// Resumes the current ad.
  Future<void> resume();

  /// Skips the current ad.
  ///
  /// This only skips ads if IMA does not render the 'Skip ad' button.
  Future<void> skip();

  /// Discards current ad break and resumes content.
  ///
  /// If there is no current ad then the next ad break is discarded.
  Future<void> discardAdBreak();

  /// Stops the ad and all tracking, then releases all assets that were loaded
  /// to play the ad.
  Future<void> destroy();
}
