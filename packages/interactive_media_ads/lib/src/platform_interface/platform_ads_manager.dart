// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';

import 'platform_ads_manager_delegate.dart';

/// Additional parameter passed to an [PlatformAdsManager] on initialization.
base class AdsManagerInitParams {}

/// Additional parameter passed to an [PlatformAdsManager] when starting to play
/// ads.
base class AdsManagerStartParams {}

/// Interface for a platform implementation of a `AdsManager`.
abstract class PlatformAdsManager {
  /// Creates a [PlatformAdsManager].
  @protected
  PlatformAdsManager();

  /// Initializes the ad experience using default rendering settings.
  Future<void> init(AdsManagerInitParams params);

  /// Starts playing the ads.
  Future<void> start(AdsManagerStartParams params);

  /// /// The [AdsManagerDelegate] to notify with events during ad playback.
  Future<void> setAdsManagerDelegate(PlatformAdsManagerDelegate delegate);

  /// Stops the ad and all tracking, then releases all assets that were loaded
  /// to play the ad.
  Future<void> destroy();
}
