// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:meta/meta.dart';

import '../platform_interface/platform_interface.dart';
import 'interactive_media_ads.g.dart';
import 'interactive_media_ads_proxy.dart';

/// Implementation of [PlatformAdsRenderingSettingsCreationParams] for iOS.
final class IOSAdsRenderingSettingsCreationParams
    extends PlatformAdsRenderingSettingsCreationParams {
  /// Constructs an [IOSAdsRenderingSettingsCreationParams].
  const IOSAdsRenderingSettingsCreationParams({
    super.bitrate,
    super.enablePreloading,
    super.loadVideoTimeout,
    super.mimeTypes,
    super.playAdsAfterTime,
    super.uiElements,
    @visibleForTesting InteractiveMediaAdsProxy? proxy,
  })  : _proxy = proxy ?? const InteractiveMediaAdsProxy(),
        super();

  /// Creates a [IOSAdsRenderingSettingsCreationParams] from an instance of
  /// [PlatformAdsRenderingSettingsCreationParams].
  factory IOSAdsRenderingSettingsCreationParams.fromPlatformAdsRenderingSettingsCreationParams(
    PlatformAdsRenderingSettingsCreationParams params,
  ) {
    return IOSAdsRenderingSettingsCreationParams(
      bitrate: params.bitrate,
      enablePreloading: params.enablePreloading,
      loadVideoTimeout: params.loadVideoTimeout,
      mimeTypes: params.mimeTypes,
      playAdsAfterTime: params.playAdsAfterTime,
      uiElements: params.uiElements,
    );
  }

  final InteractiveMediaAdsProxy _proxy;
}

/// Implementation of [PlatformAdsRenderingSettings] for iOS.
base class IOSAdsRenderingSettings extends PlatformAdsRenderingSettings {
  /// Constructs an [IOSAdsRenderingSettings].
  IOSAdsRenderingSettings(super.params) : super.implementation() {
    if (_iosParams.bitrate != null) {
      nativeSettings.setBitrate(params.bitrate!);
    }
    if (_iosParams.enablePreloading != null) {
      nativeSettings.setEnablePreloading(_iosParams.enablePreloading!);
    }
    nativeSettings.setLoadVideoTimeout(
      _iosParams.loadVideoTimeout.inMicroseconds /
          Duration.microsecondsPerSecond,
    );
    if (_iosParams.mimeTypes != null) {
      nativeSettings.setMimeTypes(_iosParams.mimeTypes);
    }
    if (_iosParams.playAdsAfterTime != null) {
      nativeSettings.setPlayAdsAfterTime(
        _iosParams.playAdsAfterTime!.inMicroseconds /
            Duration.microsecondsPerSecond,
      );
    }
    if (_iosParams.uiElements != null) {
      nativeSettings.setUIElements(
        _iosParams.uiElements!.map(
          (AdUIElement element) {
            return switch (element) {
              AdUIElement.adAttribution => UIElementType.adAttribution,
              AdUIElement.countdown => UIElementType.countdown,
            };
          },
        ).toList(),
      );
    }
  }

  /// The native iOS IMAAdsRenderingSettings.
  @internal
  late final IMAAdsRenderingSettings nativeSettings =
      _iosParams._proxy.newIMAAdsRenderingSettings();

  late final IOSAdsRenderingSettingsCreationParams _iosParams =
      params is IOSAdsRenderingSettingsCreationParams
          ? params as IOSAdsRenderingSettingsCreationParams
          : IOSAdsRenderingSettingsCreationParams
              .fromPlatformAdsRenderingSettingsCreationParams(
              params,
            );
}
