// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import '../platform_interface/interactive_media_ads_platform.dart';
import '../platform_interface/platform_ad_display_container.dart';
import '../platform_interface/platform_ads_loader.dart';
import '../platform_interface/platform_ads_manager_delegate.dart';
import 'ios_ad_display_container.dart';
import 'ios_ads_loader.dart';
import 'ios_ads_manager_delegate.dart';

/// Implementation of [InteractiveMediaAdsPlatform] for iOS.
final class IosInteractiveMediaAds extends InteractiveMediaAdsPlatform {
  /// Registers this class as the default instance of [InteractiveMediaAdsPlatform].
  static void registerWith() {
    InteractiveMediaAdsPlatform.instance = IosInteractiveMediaAds();
  }

  @override
  PlatformAdDisplayContainer createPlatformAdDisplayContainer(
    PlatformAdDisplayContainerCreationParams params,
  ) {
    return IosAdDisplayContainer(params);
  }

  @override
  PlatformAdsLoader createPlatformAdsLoader(
    PlatformAdsLoaderCreationParams params,
  ) {
    return IosAdsLoader(params);
  }

  @override
  PlatformAdsManagerDelegate createPlatformAdsManagerDelegate(
    PlatformAdsManagerDelegateCreationParams params,
  ) {
    return IosAdsManagerDelegate(params);
  }
}
