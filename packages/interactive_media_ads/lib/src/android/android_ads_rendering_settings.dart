// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:meta/meta.dart';

import '../platform_interface/platform_interface.dart';
import 'interactive_media_ads.g.dart' as ima;
import 'interactive_media_ads_proxy.dart';

/// Android implementation of [PlatformAdsRenderingSettingsCreationParams].
final class AndroidAdsRenderingSettingsCreationParams
    extends PlatformAdsRenderingSettingsCreationParams {
  /// Constructs an [AndroidAdsRenderingSettingsCreationParams].
  const AndroidAdsRenderingSettingsCreationParams({
    super.bitrate,
    super.enablePreloading,
    super.loadVideoTimeout,
    super.mimeTypes,
    super.playAdsAfterTime,
    super.uiElements,
    this.enableCustomTabs = false,
    @visibleForTesting InteractiveMediaAdsProxy? proxy,
  })  : _proxy = proxy ?? const InteractiveMediaAdsProxy(),
        super();

  /// Creates a [AndroidAdsRenderingSettingsCreationParams] from an instance of
  /// [PlatformAdsRenderingSettingsCreationParams].
  factory AndroidAdsRenderingSettingsCreationParams.fromPlatformAdsRenderingSettingsCreationParams(
    PlatformAdsRenderingSettingsCreationParams params, {
    bool enableCustomTabs = false,
  }) {
    return AndroidAdsRenderingSettingsCreationParams(
      bitrate: params.bitrate,
      enablePreloading: params.enablePreloading,
      loadVideoTimeout: params.loadVideoTimeout,
      mimeTypes: params.mimeTypes,
      playAdsAfterTime: params.playAdsAfterTime,
      uiElements: params.uiElements,
      enableCustomTabs: enableCustomTabs,
    );
  }

  final InteractiveMediaAdsProxy _proxy;

  /// Notifies the SDK whether to launch the click-through URL using Custom Tabs
  /// feature.
  final bool enableCustomTabs;
}

/// Android implementation of [PlatformAdsRenderingSettings].
base class AndroidAdsRenderingSettings extends PlatformAdsRenderingSettings {
  /// Constructs an [AndroidAdsRenderingSettings].
  AndroidAdsRenderingSettings(super.params) : super.implementation() {
    final Completer<ima.AdsRenderingSettings> nativeSettingsCompleter =
        Completer<ima.AdsRenderingSettings>();
    nativeSettings = nativeSettingsCompleter.future;

    _androidParams._proxy
        .instanceImaSdkFactory()
        .createAdsRenderingSettings()
        .then((ima.AdsRenderingSettings nativeSettings) async {
      await Future.wait(<Future<void>>[
        if (_androidParams.bitrate != null)
          nativeSettings.setBitrateKbps(params.bitrate!),
        if (_androidParams.enablePreloading != null)
          nativeSettings.setEnablePreloading(_androidParams.enablePreloading!),
        nativeSettings.setLoadVideoTimeout(
          _androidParams.loadVideoTimeout.inMilliseconds,
        ),
        if (_androidParams.mimeTypes != null)
          nativeSettings.setMimeTypes(_androidParams.mimeTypes!),
        if (_androidParams.playAdsAfterTime != null)
          nativeSettings.setPlayAdsAfterTime(
            _androidParams.playAdsAfterTime!.inMicroseconds /
                Duration.microsecondsPerSecond,
          ),
        if (_androidParams.uiElements != null)
          nativeSettings.setUiElements(
            _androidParams.uiElements!.map(
              (AdUIElement element) {
                return switch (element) {
                  AdUIElement.adAttribution => ima.UiElement.adAttribution,
                  AdUIElement.countdown => ima.UiElement.countdown,
                };
              },
            ).toList(),
          ),
        nativeSettings.setEnableCustomTabs(_androidParams.enableCustomTabs)
      ]);

      nativeSettingsCompleter.complete(nativeSettings);
    });
  }

  /// The native Android AdsRenderingSettings.
  ///
  /// The instantiation of the native AdsRenderingSettings is asynchronous, so
  /// this provides access to the value after it is created and all params have
  /// been set.
  @internal
  late final Future<ima.AdsRenderingSettings> nativeSettings;

  late final AndroidAdsRenderingSettingsCreationParams _androidParams =
      params is AndroidAdsRenderingSettingsCreationParams
          ? params as AndroidAdsRenderingSettingsCreationParams
          : AndroidAdsRenderingSettingsCreationParams
              .fromPlatformAdsRenderingSettingsCreationParams(
              params,
            );
}
