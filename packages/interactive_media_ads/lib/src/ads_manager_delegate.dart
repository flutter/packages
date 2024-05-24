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
/// {@macro interactive_media_ads.AdsManagerDelegate.fromPlatformCreationParams}
///
/// Below is an example of accessing the platform-specific implementation for
/// iOS and Android:
///
/// ```dart
/// final AdsManagerDelegate delegate = AdsManagerDelegate();
///
/// if (InteractiveMediaAdsPlatform.instance is IOSInteractiveMediaAdsPlatform) {
///   final IOSAdsManagerDelegate iosDelegate = delegate.platform as IOSAdsManagerDelegate;
/// } else if (InteractiveMediaAdsPlatform.instance is AndroidInteractiveMediaAdsPlatform) {
///   final AndroidAdsManagerDelegate androidDelegate =
///       delegate.platform as AndroidAdsManagerDelegate;
/// }
/// ```
class AdsManagerDelegate {
  /// Constructs an [AdsManagerDelegate].
  ///
  /// See [AdsManagerDelegate.fromPlatformCreationParams] for setting parameters for a
  /// specific platform.
  AdsManagerDelegate({
    void Function(AdEvent event)? onAdEvent,
    void Function(AdErrorEvent event)? onAdErrorEvent,
  }) : this.fromPlatformCreationParams(
          PlatformAdsManagerDelegateCreationParams(
            onAdEvent: onAdEvent,
            onAdErrorEvent: onAdErrorEvent,
          ),
        );

  /// Constructs an [AdsManagerDelegate] from creation params for a specific platform.
  ///
  /// {@template interactive_media_ads.AdsManagerDelegate.fromPlatformCreationParams}
  /// Below is an example of setting platform-specific creation parameters for
  /// iOS and Android:
  ///
  /// ```dart
  /// PlatformAdsManagerDelegateCreationParams params =
  ///     const PlatformAdsManagerDelegateCreationParams();
  ///
  /// if (InteractiveMediaAdsPlatform.instance is IOSInteractiveMediaAdsPlatform) {
  ///   params = IOSAdsManagerDelegateCreationParams
  ///       .fromPlatformAdsManagerDelegateCreationParams(
  ///     params,
  ///   );
  /// } else if (InteractiveMediaAdsPlatform.instance is AndroidInteractiveMediaAdsPlatform) {
  ///   params = AndroidAdsManagerDelegateCreationParams
  ///       .fromPlatformAdsManagerDelegateCreationParams(
  ///     params,
  ///   );
  /// }
  ///
  /// final AdsManagerDelegate delegate = AdsManagerDelegate.fromPlatformCreationParams(
  ///   params,
  /// );
  /// ```
  /// {@endtemplate}
  AdsManagerDelegate.fromPlatformCreationParams(
    PlatformAdsManagerDelegateCreationParams params,
  ) : this.fromPlatform(PlatformAdsManagerDelegate(params));

  /// Constructs a [AdsManagerDelegate] from a specific platform implementation.
  AdsManagerDelegate.fromPlatform(this.platform);

  /// Implementation of [PlatformAdsManagerDelegate] for the current platform.
  final PlatformAdsManagerDelegate platform;

  /// Invoked when there is an [AdEvent].
  void Function(AdEvent event)? get onAdEvent => platform.params.onAdEvent;

  /// Invoked when there was an error playing the ad. Log the error and resume
  /// playing content.
  void Function(AdErrorEvent event)? get onAdErrorEvent =>
      platform.params.onAdErrorEvent;
}
