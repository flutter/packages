// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:meta/meta.dart';

import '../platform_interface/platform_interface.dart';
import 'android_ads_rendering_settings.dart';
import 'enum_converter_utils.dart';
import 'interactive_media_ads.g.dart' as ima;
import 'interactive_media_ads_proxy.dart';

/// Android implementation of [PlatformAdsManager].
class AndroidAdsManager extends PlatformAdsManager {
  /// Constructs an [AndroidAdsManager].
  @internal
  AndroidAdsManager(
    ima.AdsManager manager, {
    InteractiveMediaAdsProxy? proxy,
  })  : _manager = manager,
        _proxy = proxy ?? const InteractiveMediaAdsProxy();

  final ima.AdsManager _manager;
  final InteractiveMediaAdsProxy _proxy;

  PlatformAdsManagerDelegate? _managerDelegate;

  @override
  Future<void> destroy() {
    return _manager.destroy();
  }

  @override
  Future<void> init({PlatformAdsRenderingSettings? settings}) async {
    ima.AdsRenderingSettings? nativeSettings;
    if (settings != null) {
      nativeSettings = settings is AndroidAdsRenderingSettings
          ? await settings.nativeSettings
          : await AndroidAdsRenderingSettings(settings.params).nativeSettings;
    }

    await _manager.init(nativeSettings);
  }

  @override
  Future<void> setAdsManagerDelegate(
    PlatformAdsManagerDelegate delegate,
  ) async {
    _managerDelegate = delegate;
    _addListeners(WeakReference<AndroidAdsManager>(this));
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

  // This value is created in a static method because the callback methods for
  // any wrapped classes must not reference the encapsulating object. This is to
  // prevent a circular reference that prevents garbage collection.
  static void _addListeners(WeakReference<AndroidAdsManager> weakThis) {
    final InteractiveMediaAdsProxy proxy = weakThis.target!._proxy;
    weakThis.target?._manager.addAdEventListener(
      proxy.newAdEventListener(
        onAdEvent: (_, ima.AdEvent event) {
          weakThis.target?._managerDelegate?.params.onAdEvent?.call(
            AdEvent(
              type: toInterfaceEventType(event.type),
              adData:
                  event.adData?.cast<String, String>() ?? <String, String>{},
            ),
          );
        },
      ),
    );
    weakThis.target?._manager.addAdErrorListener(
      proxy.newAdErrorListener(
        onAdError: (_, ima.AdErrorEvent event) {
          weakThis.target?._managerDelegate?.params.onAdErrorEvent?.call(
            AdErrorEvent(
              error: AdError(
                type: toInterfaceErrorType(event.error.errorType),
                code: toInterfaceErrorCode(event.error.errorCode),
                message: event.error.message,
              ),
            ),
          );
          weakThis.target?._manager.discardAdBreak();
        },
      ),
    );
  }
}
