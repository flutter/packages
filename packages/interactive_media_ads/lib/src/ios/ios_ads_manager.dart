// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:meta/meta.dart';

import '../platform_interface/platform_interface.dart';
import 'enum_converter_extensions.dart';
import 'interactive_media_ads.g.dart' as ima;

/// Implementation of [PlatformAdsManager] for iOS.
class IosAdsManager extends PlatformAdsManager {
  /// Constructs an [IosAdsManager].
  @internal
  IosAdsManager(ima.IMAAdsManager manager) : _manager = manager;

  final ima.IMAAdsManager _manager;

  PlatformAdsManagerDelegate? _interfaceDelegate;
  _AdsManagerDelegate? _nativeDelegate;

  @override
  Future<void> destroy() {
    return _manager.destroy();
  }

  @override
  Future<void> init(AdsManagerInitParams params) {
    return _manager.initialize(null);
  }

  @override
  Future<void> setAdsManagerDelegate(PlatformAdsManagerDelegate delegate) {
    _interfaceDelegate = delegate;
    _nativeDelegate = _AdsManagerDelegate(WeakReference<IosAdsManager>(this));
    return _manager.setDelegate(_nativeDelegate);
  }

  @override
  Future<void> start(AdsManagerStartParams params) {
    return _manager.start();
  }
}

class _AdsManagerDelegate extends ima.IMAAdsManagerDelegate {
  _AdsManagerDelegate(WeakReference<IosAdsManager> interfaceManager)
      : super(
          didReceiveAdEvent: (
            ima.IMAAdsManagerDelegate instance,
            ima.IMAAdsManager adsManager,
            ima.IMAAdEvent event,
          ) {
            late final AdEventType? eventType =
                event.type.asInterfaceAdEventType();
            if (eventType == null) {
              return;
            }

            interfaceManager.target?._interfaceDelegate?.params.onAdEvent
                ?.call(AdEvent(type: eventType));
          },
          didReceiveAdError: (
            ima.IMAAdsManagerDelegate instance,
            ima.IMAAdsManager adsManager,
            ima.IMAAdError event,
          ) {
            interfaceManager.target?._interfaceDelegate?.params.onAdErrorEvent
                ?.call(
              AdErrorEvent(
                error: AdError(
                  type: event.type.asInterfaceErrorType(),
                  code: event.code.asInterfaceErrorCode(),
                  message: event.message,
                ),
              ),
            );
          },
          didRequestContentPause: (
            ima.IMAAdsManagerDelegate instance,
            ima.IMAAdsManager adsManager,
          ) {
            interfaceManager.target?._interfaceDelegate?.params.onAdEvent?.call(
              const AdEvent(type: AdEventType.contentPauseRequested),
            );
          },
          didRequestContentResume: (
            ima.IMAAdsManagerDelegate instance,
            ima.IMAAdsManager adsManager,
          ) {
            interfaceManager.target?._interfaceDelegate?.params.onAdEvent?.call(
              const AdEvent(type: AdEventType.contentResumeRequested),
            );
          },
        );
}
