// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:meta/meta.dart';

import '../platform_interface/platform_interface.dart';
import 'interactive_media_ads.g.dart';
import 'ios_ads_manager_delegate.dart';
import 'ios_ads_rendering_settings.dart';

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
  Future<void> init({PlatformAdsRenderingSettings? settings}) {
    IMAAdsRenderingSettings? nativeSettings;
    if (settings != null) {
      nativeSettings = settings is IOSAdsRenderingSettings
          ? settings.nativeSettings
          : IOSAdsRenderingSettings(settings.params).nativeSettings;
    }

    return _manager.initialize(nativeSettings);
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
