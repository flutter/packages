// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';

import 'ad_display_container.dart';
import 'ads_manager_delegate.dart';
import 'ads_rendering_settings.dart';
import 'ads_request.dart';
import 'platform_interface/platform_interface.dart';

/// Allows publishers to request ads from ad servers or a dynamic ad insertion
/// stream.
///
/// ## Platform-Specific Features
/// This class contains an underlying implementation provided by the current
/// platform. Once a platform implementation is imported, the examples below
/// can be followed to use features provided by a platform's implementation.
///
/// {@macro interactive_media_ads.AdsLoader.fromPlatformCreationParams}
///
/// Below is an example of accessing the platform-specific implementation for
/// iOS and Android:
///
/// ```dart
/// final AdsLoader loader = AdsLoader();
///
/// if (InteractiveMediaAdsPlatform.instance is IOSInteractiveMediaAdsPlatform) {
///   final IOSAdsLoader iosLoader = loader.platform as IOSAdsLoader;
/// } else if (InteractiveMediaAdsPlatform.instance is AndroidInteractiveMediaAdsPlatform) {
///   final AndroidAdsLoader androidLoader =
///       loader.platform as AndroidAdsLoader;
/// }
/// ```
class AdsLoader {
  /// Constructs an [AdsLoader].
  ///
  /// See [AdsLoader.fromPlatformCreationParams] for setting parameters for a
  /// specific platform.
  AdsLoader({
    required AdDisplayContainer container,
    required void Function(OnAdsLoadedData data) onAdsLoaded,
    required void Function(AdsLoadErrorData data) onAdsLoadError,
  }) : this.fromPlatformCreationParams(
          PlatformAdsLoaderCreationParams(
            container: container.platform,
            onAdsLoaded: (PlatformOnAdsLoadedData data) {
              onAdsLoaded(OnAdsLoadedData._(platform: data));
            },
            onAdsLoadError: onAdsLoadError,
          ),
        );

  /// Constructs an [AdsLoader] from creation params for a specific platform.
  ///
  /// {@template interactive_media_ads.AdsLoader.fromPlatformCreationParams}
  /// Below is an example of setting platform-specific creation parameters for
  /// iOS and Android:
  ///
  /// ```dart
  /// PlatformAdsLoaderCreationParams params =
  ///     const PlatformAdsLoaderCreationParams();
  ///
  /// if (InteractiveMediaAdsPlatform.instance is IOSInteractiveMediaAdsPlatform) {
  ///   params = IOSAdsLoaderCreationParams
  ///       .fromPlatformAdsLoaderCreationParams(
  ///     params,
  ///   );
  /// } else if (InteractiveMediaAdsPlatform.instance is AndroidInteractiveMediaAdsPlatform) {
  ///   params = AndroidAdsLoaderCreationParams
  ///       .fromPlatformAdsLoaderCreationParams(
  ///     params,
  ///   );
  /// }
  ///
  /// final AdsLoader loader = AdsLoader.fromPlatformCreationParams(
  ///   params,
  /// );
  /// ```
  /// {@endtemplate}
  AdsLoader.fromPlatformCreationParams(
    PlatformAdsLoaderCreationParams params,
  ) : this.fromPlatform(PlatformAdsLoader(params));

  /// Constructs a [AdsLoader] from a specific platform implementation.
  AdsLoader.fromPlatform(this.platform);

  /// Implementation of [PlatformAdsLoader] for the current platform.
  final PlatformAdsLoader platform;

  /// Signals to the SDK that the content has completed.
  Future<void> contentComplete() {
    return platform.contentComplete();
  }

  /// Requests ads from a server.
  ///
  /// Ads cannot be requested until the `AdDisplayContainer` has been added to
  /// the native View hierarchy. See [AdDisplayContainer.onContainerAdded].
  Future<void> requestAds(AdsRequest request) {
    return platform.requestAds(request.platform);
  }
}

/// Data when ads are successfully loaded from the ad server through an
/// [AdsLoader].
@immutable
class OnAdsLoadedData {
  OnAdsLoadedData._({required this.platform});

  /// Implementation of [PlatformOnAdsLoadedData] for the current platform.
  final PlatformOnAdsLoadedData platform;

  /// The ads manager instance created by the ads loader.
  late final AdsManager manager = AdsManager._fromPlatform(platform.manager);
}

/// Handles playing ads after they've been received from the server.
///
/// ## Platform-Specific Features
/// This class contains an underlying implementation provided by the current
/// platform. Once a platform implementation is imported, the examples below
/// can be followed to use features provided by a platform's implementation.
///
/// {@macro interactive_media_ads.AdsManager.fromPlatformCreationParams}
///
/// Below is an example of accessing the platform-specific implementation for
/// iOS and Android:
///
/// ```dart
/// final AdsManager manager = AdsManager();
///
/// if (InteractiveMediaAdsPlatform.instance is IOSInteractiveMediaAdsPlatform) {
///   final IOSAdsManager iosManager = manager.platform as IOSAdsManager;
/// } else if (InteractiveMediaAdsPlatform.instance is AndroidInteractiveMediaAdsPlatform) {
///   final AndroidAdsManager androidManager =
///       manager.platform as AndroidAdsManager;
/// }
/// ```
class AdsManager {
  /// Constructs a [AdsManager] from a specific platform implementation.
  AdsManager._fromPlatform(this.platform);

  /// Implementation of [PlatformAdsManager] for the current platform.
  final PlatformAdsManager platform;

  /// Initializes the ad experience using default rendering settings.
  Future<void> init({AdsRenderingSettings? settings}) {
    return platform.init(settings: settings?.platform);
  }

  /// Starts playing the ads.
  Future<void> start() {
    return platform.start(AdsManagerStartParams());
  }

  /// The [AdsManagerDelegate] to notify with events during ad playback.
  Future<void> setAdsManagerDelegate(AdsManagerDelegate delegate) {
    return platform.setAdsManagerDelegate(delegate.platform);
  }

  /// Pauses the current ad.
  Future<void> pause() {
    return platform.pause();
  }

  /// Resumes the current ad.
  Future<void> resume() {
    return platform.resume();
  }

  /// Skips the current ad.
  ///
  /// This only skips ads if IMA does not render the 'Skip ad' button.
  Future<void> skip() {
    return platform.skip();
  }

  /// Discards current ad break and resumes content.
  ///
  /// If there is no current ad then the next ad break is discarded.
  Future<void> discardAdBreak() {
    return platform.discardAdBreak();
  }

  /// Stops the ad and all tracking, then releases all assets that were loaded
  /// to play the ad.
  Future<void> destroy() {
    return platform.destroy();
  }
}
