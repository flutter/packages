// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'ads_loader.dart';
import 'platform_interface/platform_interface.dart';

/// Defines parameters that control the rendering of ads.
class AdsRenderingSettings {
  /// Creates an [AdsRenderingSettings].
  AdsRenderingSettings({
    int? bitrate,
    bool? enablePreloading,
    Duration loadVideoTimeout = const Duration(seconds: 8),
    List<String>? mimeTypes,
    Duration? playAdsAfterTime,
    Set<AdUIElement>? uiElements,
  }) : this.fromPlatform(PlatformAdsRenderingSettings(
          PlatformAdsRenderingSettingsCreationParams(
            bitrate: bitrate,
            enablePreloading: enablePreloading,
            loadVideoTimeout: loadVideoTimeout,
            mimeTypes: mimeTypes,
            playAdsAfterTime: playAdsAfterTime,
            uiElements: uiElements,
          ),
        ));

  /// Constructs an [AdsRenderingSettings] from a specific platform
  /// implementation.
  AdsRenderingSettings.fromPlatform(this.platform);

  /// Implementation of [PlatformAdsRenderingSettings] for the current platform.
  final PlatformAdsRenderingSettings platform;

  /// Maximum recommended bitrate.
  ///
  /// The value is in kbit/s.
  ///
  /// The SDK will select media which has a bitrate below the specified max or
  /// the closest bitrate if there is no media with a lower bitrate found.
  ///
  /// If null, the bitrate will be selected by the SDK, using the currently
  /// detected network speed (cellular or Wi-Fi).
  int? get bitrate => platform.params.bitrate;

  /// If set, the SDK will instruct the player to load the creative in response
  /// to [AdsManager.init].
  ///
  /// This allows the player to preload the ad at any point before
  /// [AdsManager.start].
  ///
  /// If null, the platform will decide the default value.
  bool? get enablePreloading => platform.params.enablePreloading;

  /// Specifies a non-default amount of time to wait for media to load before
  /// timing out.
  ///
  /// This only applies to the IMA client-side SDK.
  Duration get loadVideoTimeout => platform.params.loadVideoTimeout;

  /// The SDK will prioritize the media with MIME type on the list.
  ///
  /// This only refers to the mime types of videos to be selected for linear
  /// ads.
  ///
  /// If null, the platform will decide the default value.
  List<String>? get mimeTypes => platform.params.mimeTypes;

  /// For VMAP and ad rules playlists, only play ad breaks scheduled after this
  /// time.
  ///
  /// This setting is strictly after the specified time. For example, setting
  /// `playAdsAfterTime` to 15s will ignore an ad break scheduled to play at
  /// 15s.
  Duration? get playAdsAfterTime => platform.params.playAdsAfterTime;

  /// The ad UI elements to be rendered by the IMA SDK.
  ///
  /// Some modifications to the uiElements list may have no effect for specific
  /// ads.
  ///
  /// If null, the platform will decide the default value.
  Set<AdUIElement>? get uiElements => platform.params.uiElements;
}
