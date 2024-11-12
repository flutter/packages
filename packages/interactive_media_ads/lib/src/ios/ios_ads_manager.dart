// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:meta/meta.dart';

import '../platform_interface/platform_interface.dart';
import 'interactive_media_ads.g.dart';
import 'ios_ads_manager_delegate.dart';

/// Implementation of [PlatformAdsManager] for iOS.
class IOSAdsManager extends PlatformAdsManager {
  /// Constructs an [IOSAdsManager].
  @internal
  IOSAdsManager(IMAAdsManager manager) : _manager = manager;

  final IMAAdsManager _manager;

  // This must maintain a reference to the delegate because the native
  // `IMAAdsManagerDelegate.delegate` property is only a weak reference.
  // Therefore, this would be garbage collected without this explicit reference.
  // ignore: unused_field
  late IOSAdsManagerDelegate _delegate;

  @override
  Future<void> destroy() {
    return _manager.destroy();
  }

  @override
  Future<void> init([PlatformAdsRenderingSettings? settings]) {
    if (settings == null) {
      return _manager.initialize(null);
    }

    final IMAAdsRenderingSettings iosSettings = IMAAdsRenderingSettings();
    return Future.wait(<Future<void>>[
      if (settings.bitrate != null) iosSettings.setBitrate(settings.bitrate!),
      if (settings.enablePreloading != null)
        iosSettings.setEnablePreloading(settings.enablePreloading!),
      if (settings.loadVideoTimeout != null)
        // Converts milliseconds to seconds.
        iosSettings.setLoadVideoTimeout(settings.loadVideoTimeout! / 1000),
      if (settings.mimeTypes != null)
        iosSettings.setMimeTypes(settings.mimeTypes!),
      if (settings.playAdsAfterTime != null)
        iosSettings.setPlayAdsAfterTime(settings.playAdsAfterTime!),
      if (settings.uiElements != null)
        iosSettings.setUIElements(
          settings.uiElements!.map(
            (UIElement element) {
              return switch (element) {
                UIElement.adAttribution => UIElementType.adAttribution,
                UIElement.countdown => UIElementType.countdown,
              };
            },
          ).toList(),
        ),
      _manager.initialize(iosSettings)
    ]);
  }

  @override
  Future<void> setAdsManagerDelegate(PlatformAdsManagerDelegate delegate) {
    final IOSAdsManagerDelegate platformDelegate =
        delegate is IOSAdsManagerDelegate
            ? delegate
            : IOSAdsManagerDelegate(delegate.params);
    _delegate = platformDelegate;
    return _manager.setDelegate(platformDelegate.delegate);
  }

  @override
  Future<void> start(AdsManagerStartParams params) {
    return _manager.start();
  }

  @override
  Future<void> discardAdBreak() {
    return _manager.discardAdBreak();
  }

  @override
  Future<void> pause() {
    return _manager.pause();
  }

  @override
  Future<void> resume() {
    return _manager.resume();
  }

  @override
  Future<void> skip() {
    return _manager.skip();
  }
}
