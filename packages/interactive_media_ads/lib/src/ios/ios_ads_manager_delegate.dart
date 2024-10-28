// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:meta/meta.dart';

import '../platform_interface/platform_interface.dart';
import 'enum_converter_utils.dart';
import 'interactive_media_ads.g.dart' as ima;
import 'interactive_media_ads_proxy.dart';

/// Implementation of [PlatformAdsManagerDelegateCreationParams] for iOS.
final class IOSAdsManagerDelegateCreationParams
    extends PlatformAdsManagerDelegateCreationParams {
  /// Constructs an [IOSAdsManagerDelegateCreationParams].
  const IOSAdsManagerDelegateCreationParams({
    super.onAdEvent,
    super.onAdErrorEvent,
    @visibleForTesting InteractiveMediaAdsProxy? proxy,
  })  : _proxy = proxy ?? const InteractiveMediaAdsProxy(),
        super();

  /// Creates an [IOSAdsManagerDelegateCreationParams] from an instance of
  /// [PlatformAdsManagerDelegateCreationParams].
  factory IOSAdsManagerDelegateCreationParams.fromPlatformAdsManagerDelegateCreationParams(
    PlatformAdsManagerDelegateCreationParams params, {
    @visibleForTesting InteractiveMediaAdsProxy? proxy,
  }) {
    return IOSAdsManagerDelegateCreationParams(
      onAdEvent: params.onAdEvent,
      onAdErrorEvent: params.onAdErrorEvent,
      proxy: proxy,
    );
  }

  final InteractiveMediaAdsProxy _proxy;
}

/// Implementation of [PlatformAdsManagerDelegate] for iOS.
final class IOSAdsManagerDelegate extends PlatformAdsManagerDelegate {
  /// Constructs an [IOSAdsManagerDelegate].
  IOSAdsManagerDelegate(super.params) : super.implementation();

  /// The native iOS `IMAAdsManagerDelegate`.
  ///
  /// This handles ad events and errors that occur during ad or stream
  /// initialization and playback.
  @internal
  late final ima.IMAAdsManagerDelegate delegate = _createAdsManagerDelegate(
    WeakReference<IOSAdsManagerDelegate>(this),
  );

  late final IOSAdsManagerDelegateCreationParams _iosParams =
      params is IOSAdsManagerDelegateCreationParams
          ? params as IOSAdsManagerDelegateCreationParams
          : IOSAdsManagerDelegateCreationParams
              .fromPlatformAdsManagerDelegateCreationParams(params);

  // This value is created in a static method because the callback methods for
  // any wrapped classes must not reference the encapsulating object. This is to
  // prevent a circular reference that prevents garbage collection.
  static ima.IMAAdsManagerDelegate _createAdsManagerDelegate(
    WeakReference<IOSAdsManagerDelegate> interfaceDelegate,
  ) {
    return interfaceDelegate.target!._iosParams._proxy.newIMAAdsManagerDelegate(
      didReceiveAdEvent: (_, __, ima.IMAAdEvent event) {
        interfaceDelegate.target?.params.onAdEvent?.call(
          AdEvent(
            type: toInterfaceEventType(event.type),
            adData: event.adData?.map(
                  (String? key, Object? value) {
                    return MapEntry<String, String>(key!, value.toString());
                  },
                ) ??
                <String, String>{},
          ),
        );
      },
      didReceiveAdError: (_, __, ima.IMAAdError event) {
        interfaceDelegate.target?.params.onAdErrorEvent?.call(
          AdErrorEvent(
            error: AdError(
              type: toInterfaceErrorType(event.type),
              code: toInterfaceErrorCode(event.code),
              message: event.message,
            ),
          ),
        );
      },
      didRequestContentPause: (_, __) {
        interfaceDelegate.target?.params.onAdEvent?.call(
          const AdEvent(type: AdEventType.contentPauseRequested),
        );
      },
      didRequestContentResume: (_, __) {
        interfaceDelegate.target?.params.onAdEvent?.call(
          const AdEvent(type: AdEventType.contentResumeRequested),
        );
      },
    );
  }
}
