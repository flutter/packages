// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'platform_ad_display_container.dart';
import 'platform_ads_loader.dart';
import 'platform_ads_manager.dart';
import 'platform_ads_manager_delegate.dart';

/// Interface for a platform implementation of the Interactive Media Ads SDKs.
abstract class InteractiveMediaAdsPlatform extends PlatformInterface {
  /// Creates a new [InteractiveMediaAdsPlatform].
  InteractiveMediaAdsPlatform() : super(token: _token);

  static final Object _token = Object();

  static InteractiveMediaAdsPlatform? _instance;

  /// The instance of [InteractiveMediaAdsPlatform] to use.
  static InteractiveMediaAdsPlatform? get instance => _instance;

  /// Platform-specific plugins should set this with their own platform-specific
  /// class that extends [InteractiveMediaAdsPlatform] when they register
  /// themselves.
  static set instance(InteractiveMediaAdsPlatform? instance) {
    if (instance == null) {
      throw AssertionError(
        'Platform interfaces can only be set to a non-null instance',
      );
    }

    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// Creates a new [PlatformAdsManager].
  PlatformAdsManager createPlatformAdsManager(
    PlatformAdsManagerCreationParams params,
  ) {
    throw UnimplementedError(
      'createPlatformAdsManager is not implemented on the current platform.',
    );
  }

  /// Creates a new [PlatformAdsLoader].
  PlatformAdsLoader createPlatformAdsLoader(
    PlatformAdsLoaderCreationParams params,
  ) {
    throw UnimplementedError(
      'createPlatformAdsLoader is not implemented on the current platform.',
    );
  }

  /// Creates a new [PlatformAdsManagerDelegate].
  PlatformAdsManagerDelegate createPlatformAdsManagerDelegate(
    PlatformAdsManagerDelegateCreationParams params,
  ) {
    throw UnimplementedError(
      'createPlatformAdsManagerDelegate is not implemented on the current platform.',
    );
  }

  /// Creates a new [PlatformAdDisplayContainer].
  PlatformAdDisplayContainer createPlatformAdDisplayContainer(
    PlatformAdDisplayContainerCreationParams params,
  ) {
    throw UnimplementedError(
      'createPlatformAdDisplayContainer is not implemented on the current platform.',
    );
  }
}
