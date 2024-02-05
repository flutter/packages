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
/// {@macro interactive_media_ads.AdsLoader.fromPlatformCreationParams}
///
/// Below is an example of accessing the platform-specific implementation for
/// iOS and Android:
///
/// ```dart
/// final AdsLoader loader = AdsLoader();
///
/// if (InteractiveMediaAdsPlatform.instance is IosInteractiveMediaAdsPlatform) {
///   final IosAdsLoader iosLoader = loader.platform as IosAdsLoader;
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
  AdsLoader()
      : this.fromPlatformCreationParams(
          const PlatformAdsLoaderCreationParams(),
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
  /// if (InteractiveMediaAdsPlatform.instance is IosInteractiveMediaAdsPlatform) {
  ///   params = IosAdsLoaderCreationParams
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
}
