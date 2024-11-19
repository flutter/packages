// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'platform_ad_display_container.dart';
import 'platform_ads_loader.dart';
import 'platform_ads_manager_delegate.dart';
import 'platform_ads_rendering_settings.dart';
import 'platform_content_progress_provider.dart';

/// Interface for a platform implementation of the Interactive Media Ads SDKs.
abstract base class InteractiveMediaAdsPlatform {
  /// The instance of [InteractiveMediaAdsPlatform] to use.
  ///
  /// Platform-specific plugins should set this with their own platform-specific
  /// class that extends [InteractiveMediaAdsPlatform] when they register
  /// themselves.
  static InteractiveMediaAdsPlatform? instance;

  /// Creates a new [PlatformAdsLoader].
  PlatformAdsLoader createPlatformAdsLoader(
    PlatformAdsLoaderCreationParams params,
  );

  /// Creates a new [PlatformAdsManagerDelegate].
  PlatformAdsManagerDelegate createPlatformAdsManagerDelegate(
    PlatformAdsManagerDelegateCreationParams params,
  );

  /// Creates a new [PlatformAdDisplayContainer].
  PlatformAdDisplayContainer createPlatformAdDisplayContainer(
    PlatformAdDisplayContainerCreationParams params,
  );

  /// Creates a new [PlatformContentProgressProvider].
  PlatformContentProgressProvider createPlatformContentProgressProvider(
    PlatformContentProgressProviderCreationParams params,
  );

  /// Creates a new [PlatformContentProgressProvider].
  PlatformAdsRenderingSettings createPlatformAdsRenderingSettings(
    PlatformAdsRenderingSettingsCreationParams params,
  );
}
