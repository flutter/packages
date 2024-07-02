// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/widgets.dart';

import '../platform_interface/platform_interface.dart';
import 'enum_converter_extensions.dart';
import 'interactive_media_ads.g.dart' as ima;
import 'interactive_media_ads_proxy.dart';
import 'ios_ad_display_container.dart';
import 'ios_ads_manager.dart';

/// Implementation of [PlatformAdsLoaderCreationParams] for iOS.
final class IOSAdsLoaderCreationParams extends PlatformAdsLoaderCreationParams {
  /// Constructs a [IOSAdsLoaderCreationParams].
  const IOSAdsLoaderCreationParams({
    required super.container,
    required super.onAdsLoaded,
    required super.onAdsLoadError,
    @visibleForTesting InteractiveMediaAdsProxy? proxy,
  })  : _proxy = proxy ?? const InteractiveMediaAdsProxy(),
        super();

  /// Creates a [IOSAdsLoaderCreationParams] from an instance of
  /// [PlatformAdsLoaderCreationParams].
  factory IOSAdsLoaderCreationParams.fromPlatformAdsLoaderCreationParams(
    PlatformAdsLoaderCreationParams params, {
    @visibleForTesting InteractiveMediaAdsProxy? proxy,
  }) {
    return IOSAdsLoaderCreationParams(
      container: params.container,
      onAdsLoaded: params.onAdsLoaded,
      onAdsLoadError: params.onAdsLoadError,
      proxy: proxy,
    );
  }

  final InteractiveMediaAdsProxy _proxy;
}

/// Implementation of [PlatformAdsLoader] for iOS.
base class IosAdsLoader extends PlatformAdsLoader {
  /// Constructs an [IosAdsLoader].
  IosAdsLoader(super.params)
      : assert(params.container is IOSAdDisplayContainer),
        assert(
          (params.container as IOSAdDisplayContainer).adDisplayContainer !=
              null,
          'Ensure the AdDisplayContainer has been added to the Widget tree before creating an AdsLoader.',
        ),
        super.implementation() {
    _adsLoader = _iosParams._proxy.newIMAAdsLoader();
    _adsLoader.setDelegate(_delegate);
  }

  late final ima.IMAAdsLoader _adsLoader;
  late final _AdsLoaderDelegate _delegate = _AdsLoaderDelegate(
    WeakReference<IosAdsLoader>(this),
  );

  late final IOSAdsLoaderCreationParams _iosParams = params
          is IOSAdsLoaderCreationParams
      ? params as IOSAdsLoaderCreationParams
      : IOSAdsLoaderCreationParams.fromPlatformAdsLoaderCreationParams(params);

  @override
  Future<void> contentComplete() {
    return _adsLoader.contentComplete();
  }

  @override
  Future<void> requestAds(AdsRequest request) async {
    return _adsLoader.requestAds(_iosParams._proxy.newIMAAdsRequest(
      adTagUrl: request.adTagUrl,
      adDisplayContainer:
          (_iosParams.container as IOSAdDisplayContainer).adDisplayContainer!,
    ));
  }
}

class _AdsLoaderDelegate extends ima.IMAAdsLoaderDelegate {
  _AdsLoaderDelegate(WeakReference<IosAdsLoader> interfaceLoader)
      : super(
          adLoaderLoadedWith: (
            ima.IMAAdsLoaderDelegate instance,
            ima.IMAAdsLoader loader,
            ima.IMAAdsLoadedData adsLoadedData,
          ) {
            interfaceLoader.target?._iosParams.onAdsLoaded(
              PlatformOnAdsLoadedData(
                manager: IOSAdsManager(adsLoadedData.adsManager!),
              ),
            );
          },
          adsLoaderFailedWithErrorData: (
            ima.IMAAdsLoaderDelegate instance,
            ima.IMAAdsLoader loader,
            ima.IMAAdLoadingErrorData adErrorData,
          ) {
            interfaceLoader.target?._iosParams.onAdsLoadError(
              AdsLoadErrorData(
                error: AdError(
                  type: adErrorData.adError.type.asInterfaceErrorType(),
                  code: adErrorData.adError.code.asInterfaceErrorCode(),
                  message: adErrorData.adError.message,
                ),
              ),
            );
          },
        );
}
