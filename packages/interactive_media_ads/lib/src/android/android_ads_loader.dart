// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/widgets.dart';

import '../platform_interface/platform_interface.dart';
import 'android_ad_display_container.dart';
import 'android_ads_manager.dart';
import 'android_content_progress_provider.dart';
import 'enum_converter_utils.dart';
import 'interactive_media_ads.g.dart' as ima;
import 'interactive_media_ads_proxy.dart';

/// Android implementation of [PlatformAdsLoaderCreationParams].
final class AndroidAdsLoaderCreationParams
    extends PlatformAdsLoaderCreationParams {
  /// Constructs a [AndroidAdsLoaderCreationParams].
  const AndroidAdsLoaderCreationParams({
    required super.container,
    required super.onAdsLoaded,
    required super.onAdsLoadError,
    @visibleForTesting InteractiveMediaAdsProxy? proxy,
  })  : _proxy = proxy ?? const InteractiveMediaAdsProxy(),
        super();

  /// Creates a [AndroidAdsLoaderCreationParams] from an instance of
  /// [PlatformAdsLoaderCreationParams].
  factory AndroidAdsLoaderCreationParams.fromPlatformAdsLoaderCreationParams(
    PlatformAdsLoaderCreationParams params, {
    @visibleForTesting InteractiveMediaAdsProxy? proxy,
  }) {
    return AndroidAdsLoaderCreationParams(
      container: params.container,
      onAdsLoaded: params.onAdsLoaded,
      onAdsLoadError: params.onAdsLoadError,
      proxy: proxy,
    );
  }

  final InteractiveMediaAdsProxy _proxy;
}

/// Android implementation of [PlatformAdsLoader].
base class AndroidAdsLoader extends PlatformAdsLoader {
  /// Constructs an [AndroidAdsLoader].
  AndroidAdsLoader(super.params)
      : assert(params.container is AndroidAdDisplayContainer),
        assert(
          (params.container as AndroidAdDisplayContainer).adDisplayContainer !=
              null,
          'Ensure the AdDisplayContainer has been added to the Widget tree before creating an AdsLoader.',
        ),
        super.implementation() {
    _adsLoaderFuture = _createAdsLoader();
  }

  late final ima.ImaSdkFactory _sdkFactory =
      _androidParams._proxy.instanceImaSdkFactory();
  late Future<ima.AdsLoader> _adsLoaderFuture;

  late final AndroidAdsLoaderCreationParams _androidParams =
      params is AndroidAdsLoaderCreationParams
          ? params as AndroidAdsLoaderCreationParams
          : AndroidAdsLoaderCreationParams.fromPlatformAdsLoaderCreationParams(
              params,
            );

  @override
  Future<void> contentComplete() async {
    final Set<ima.VideoAdPlayerCallback> callbacks =
        (params.container as AndroidAdDisplayContainer).videoAdPlayerCallbacks;
    await Future.wait(
      callbacks.map(
        (ima.VideoAdPlayerCallback callback) => callback.onContentComplete(),
      ),
    );
  }

  @override
  Future<void> requestAds(PlatformAdsRequest request) async {
    final ima.AdsLoader adsLoader = await _adsLoaderFuture;

    final ima.AdsRequest androidRequest = await _sdkFactory.createAdsRequest();

    await Future.wait(<Future<void>>[
      androidRequest.setAdTagUrl(request.adTagUrl),
      if (request.contentProgressProvider != null)
        androidRequest.setContentProgressProvider(
          (request.contentProgressProvider! as AndroidContentProgressProvider)
              .progressProvider,
        ),
      adsLoader.requestAds(androidRequest),
    ]);
  }

  Future<ima.AdsLoader> _createAdsLoader() async {
    final ima.ImaSdkSettings settings =
        await _sdkFactory.createImaSdkSettings();

    final ima.AdsLoader adsLoader = await _sdkFactory.createAdsLoader(
      settings,
      (params.container as AndroidAdDisplayContainer).adDisplayContainer!,
    );

    _addListeners(WeakReference<AndroidAdsLoader>(this), adsLoader);

    return adsLoader;
  }

  // This value is created in a static method because the callback methods for
  // any wrapped classes must not reference the encapsulating object. This is to
  // prevent a circular reference that prevents garbage collection.
  static void _addListeners(
    WeakReference<AndroidAdsLoader> weakThis,
    ima.AdsLoader adsLoader,
  ) {
    final InteractiveMediaAdsProxy proxy =
        weakThis.target!._androidParams._proxy;
    adsLoader
      ..addAdsLoadedListener(proxy.newAdsLoadedListener(
        onAdsManagerLoaded: (_, ima.AdsManagerLoadedEvent event) {
          weakThis.target?.params.onAdsLoaded(
            PlatformOnAdsLoadedData(
              manager: AndroidAdsManager(
                event.manager,
                proxy: weakThis.target?._androidParams._proxy,
              ),
            ),
          );
        },
      ))
      ..addAdErrorListener(proxy.newAdErrorListener(
        onAdError: (_, ima.AdErrorEvent event) {
          weakThis.target?.params.onAdsLoadError(
            AdsLoadErrorData(
              error: AdError(
                type: toInterfaceErrorType(event.error.errorType),
                code: toInterfaceErrorCode(event.error.errorCode),
                message: event.error.message,
              ),
            ),
          );
        },
      ));
  }
}
