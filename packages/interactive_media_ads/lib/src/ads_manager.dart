// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'platform_interface/platform_interface.dart';

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
/// if (InteractiveMediaAdsPlatform.instance is IosInteractiveMediaAdsPlatform) {
///   final IosAdsManager iosManager = manager.platform as WebKitAdsManager;
/// } else if (InteractiveMediaAdsPlatform.instance is AndroidInteractiveMediaAdsPlatform) {
///   final AndroidAdsManager androidManager =
///       manager.platform as AndroidAdsManager;
/// }
/// ```
class AdsManager {
  /// Constructs an [AdsManager].
  ///
  /// See [AdsManager.fromPlatformCreationParams] for setting parameters for a
  /// specific platform.
  AdsManager()
      : this.fromPlatformCreationParams(
          const PlatformAdsManagerCreationParams(),
        );

  /// Constructs an [AdsManager] from creation params for a specific platform.
  ///
  /// {@template interactive_media_ads.AdsManager.fromPlatformCreationParams}
  /// Below is an example of setting platform-specific creation parameters for
  /// iOS and Android:
  ///
  /// ```dart
  /// PlatformAdsManagerCreationParams params =
  ///     const PlatformAdsManagerCreationParams();
  ///
  /// if (InteractiveMediaAdsPlatform.instance is IosInteractiveMediaAdsPlatform) {
  ///   params = IosAdsManagerCreationParams
  ///       .fromPlatformAdsManagerCreationParams(
  ///     params,
  ///   );
  /// } else if (InteractiveMediaAdsPlatform.instance is AndroidInteractiveMediaAdsPlatform) {
  ///   params = AndroidAdsManagerCreationParams
  ///       .fromPlatformAdsManagerCreationParams(
  ///     params,
  ///   );
  /// }
  ///
  /// final AdsManager manager = AdsManager.fromPlatformCreationParams(
  ///   params,
  /// );
  /// ```
  /// {@endtemplate}
  AdsManager.fromPlatformCreationParams(
    PlatformAdsManagerCreationParams params,
  ) : this.fromPlatform(PlatformAdsManager(params));

  /// Constructs a [AdsManager] from a specific platform implementation.
  AdsManager.fromPlatform(this.platform);

  /// Implementation of [PlatformAdsManager] for the current platform.
  final PlatformAdsManager platform;
}
