// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';

import 'ad_ui_element.dart';
import 'interactive_media_ads_platform.dart';

/// Object specifying creation parameters for creating a
/// [PlatformAdsRenderingSettings].
///
/// Platform specific implementations can add additional fields by extending
/// this class.
///
/// This example demonstrates how to extend the
/// [PlatformAdsRenderingSettingsCreationParams] to provide additional platform
/// specific parameters.
///
/// When extending [PlatformAdsRenderingSettingsCreationParams], additional
/// parameters should always accept `null` or have a default value to prevent
/// breaking changes.
///
/// ```dart
/// final class AndroidPlatformAdsRenderingSettingsCreationParams
///     extends PlatformAdsRenderingSettingsCreationParams {
///   const AndroidPlatformAdsRenderingSettingsCreationParams({
///     super.bitrate,
///     this.enableCustomTabs,
///   }) : super();
///
///   factory AndroidPlatformAdsRenderingSettingsCreationParams.fromPlatformAdsRenderingSettingsCreationParams(
///     PlatformAdsRenderingSettingsCreationParams params, {
///     bool? enableCustomTabs,
///   }) {
///     return AndroidPlatformAdsRenderingSettingsCreationParams(
///       bitrate: params.bitrate,
///       enableCustomTabs: enableCustomTabs,
///     );
///   }
///
///   final bool? enableCustomTabs;
/// }
/// ```
@immutable
base class PlatformAdsRenderingSettingsCreationParams {
  /// Used by the platform implementation to create a new
  /// [PlatformAdsRenderingSettings].
  const PlatformAdsRenderingSettingsCreationParams({
    this.bitrate,
    this.enablePreloading,
    this.loadVideoTimeout = const Duration(seconds: 8),
    this.mimeTypes,
    this.playAdsAfterTime,
    this.uiElements,
  });

  /// Maximum recommended bitrate.
  ///
  /// The value is in kbit/s.
  ///
  /// The SDK will select media which has a bitrate below the specified max or
  /// the closest bitrate if there is no media with a lower bitrate found.
  ///
  /// If null, the bitrate will be selected by the SDK, using the currently
  /// detected network speed (cellular or Wi-Fi).
  final int? bitrate;

  /// If set, the SDK will instruct the player to load the creative in response
  /// initializing the ads manager.
  ///
  /// This allows the player to preload the ad at any point before starting the
  /// ads manager.
  ///
  /// If null, the platform will decide the default value.
  final bool? enablePreloading;

  /// Specifies a non-default amount of time to wait for media to load before
  /// timing out.
  ///
  /// This only applies to the IMA client-side SDK.
  final Duration loadVideoTimeout;

  /// The SDK will prioritize the media with MIME type on the list.
  ///
  /// This only refers to the mime types of videos to be selected for linear
  /// ads.
  ///
  /// If null, the platform will decide the default value.
  final List<String>? mimeTypes;

  /// For VMAP and ad rules playlists, only play ad breaks scheduled after this
  /// time.
  ///
  /// This setting is strictly after the specified time. For example, setting
  /// `playAdsAfterTime` to 15s will ignore an ad break scheduled to play at
  /// 15s.
  final Duration? playAdsAfterTime;

  /// Sets the ad UI elements to be rendered by the IMA SDK.
  ///
  /// Some modifications to the uiElements set may have no effect for specific
  /// ads.
  ///
  /// If null, the platform will decide the default value.
  final Set<AdUIElement>? uiElements;
}

/// Defines parameters that control the rendering of ads.
abstract base class PlatformAdsRenderingSettings {
  /// Creates a new [PlatformAdsRenderingSettings]
  factory PlatformAdsRenderingSettings(
    PlatformAdsRenderingSettingsCreationParams params,
  ) {
    assert(
      InteractiveMediaAdsPlatform.instance != null,
      'A platform implementation for `interactive_media_ads` has not been set. '
      'Please ensure that an implementation of `InteractiveMediaAdsPlatform` '
      'has been set to `InteractiveMediaAdsPlatform.instance` before use. For '
      'unit testing, `InteractiveMediaAdsPlatform.instance` can be set with '
      'your own test implementation.',
    );
    final PlatformAdsRenderingSettings implementation =
        InteractiveMediaAdsPlatform.instance!
            .createPlatformAdsRenderingSettings(params);
    return implementation;
  }

  /// Used by the platform implementation to create a new
  /// [PlatformAdsRenderingSettings].
  ///
  /// Should only be used by platform implementations because they can't extend
  /// a class that only contains a factory constructor.
  @protected
  PlatformAdsRenderingSettings.implementation(this.params);

  /// The parameters used to initialize the [PlatformAdsRenderingSettings].
  final PlatformAdsRenderingSettingsCreationParams params;
}
