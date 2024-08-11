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
final class IOSInteractiveMediaAds extends InteractiveMediaAdsPlatform {
  /// Registers this class as the default instance of [InteractiveMediaAdsPlatform].
  static void registerWith() {
    InteractiveMediaAdsPlatform.instance = IOSInteractiveMediaAds();
  }

  @override
  IOSAdDisplayContainer createPlatformAdDisplayContainer(
    PlatformAdDisplayContainerCreationParams params,
  ) {
    return IOSAdDisplayContainer(params);
  }

  @override
  IOSAdsLoader createPlatformAdsLoader(PlatformAdsLoaderCreationParams params) {
    return IOSAdsLoader(params);
  }

  @override
  IOSAdsManagerDelegate createPlatformAdsManagerDelegate(
    PlatformAdsManagerDelegateCreationParams params,
  ) {
    return IOSAdsManagerDelegate(params);
  }
}
