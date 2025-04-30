// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import '../platform_interface/interactive_media_ads_platform.dart';
import '../platform_interface/platform_ad_display_container.dart';
import '../platform_interface/platform_ads_loader.dart';
import '../platform_interface/platform_ads_manager_delegate.dart';
import '../platform_interface/platform_ads_rendering_settings.dart';
import '../platform_interface/platform_companion_ad_slot.dart';
import '../platform_interface/platform_content_progress_provider.dart';
import 'android_ad_display_container.dart';
import 'android_ads_loader.dart';
import 'android_ads_manager_delegate.dart';
import 'android_ads_rendering_settings.dart';
import 'android_companion_ad_slot.dart';
import 'android_content_progress_provider.dart';

/// Android implementation of [InteractiveMediaAdsPlatform].
final class AndroidInteractiveMediaAds extends InteractiveMediaAdsPlatform {
  /// Registers this class as the default instance of [InteractiveMediaAdsPlatform].
  static void registerWith() {
    InteractiveMediaAdsPlatform.instance = AndroidInteractiveMediaAds();
  }

  @override
  PlatformAdDisplayContainer createPlatformAdDisplayContainer(
    PlatformAdDisplayContainerCreationParams params,
  ) {
    return AndroidAdDisplayContainer(params);
  }

  @override
  PlatformAdsLoader createPlatformAdsLoader(
    PlatformAdsLoaderCreationParams params,
  ) {
    return AndroidAdsLoader(params);
  }

  @override
  PlatformAdsManagerDelegate createPlatformAdsManagerDelegate(
    PlatformAdsManagerDelegateCreationParams params,
  ) {
    return AndroidAdsManagerDelegate(params);
  }

  @override
  PlatformContentProgressProvider createPlatformContentProgressProvider(
    PlatformContentProgressProviderCreationParams params,
  ) {
    return AndroidContentProgressProvider(params);
  }

  @override
  AndroidAdsRenderingSettings createPlatformAdsRenderingSettings(
    PlatformAdsRenderingSettingsCreationParams params,
  ) {
    return AndroidAdsRenderingSettings(params);
  }

  @override
  AndroidCompanionAdSlot createPlatformCompanionAdSlot(
    PlatformCompanionAdSlotCreationParams params,
  ) {
    return AndroidCompanionAdSlot(params);
  }
}
