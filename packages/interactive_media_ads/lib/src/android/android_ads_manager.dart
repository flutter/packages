// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:meta/meta.dart';

import '../platform_interface/platform_interface.dart';
import 'android_ads_rendering_settings.dart';
import 'enum_converter_utils.dart';
import 'interactive_media_ads.g.dart' as ima;

/// Android implementation of [PlatformAdsManager].
class AndroidAdsManager extends PlatformAdsManager {
  /// Constructs an [AndroidAdsManager].
  @internal
  AndroidAdsManager(ima.AdsManager manager)
    : _manager = manager,
      super(
        adCuePoints: List<Duration>.unmodifiable(
          manager.adCuePoints.map((double seconds) {
            return Duration(
              milliseconds: (seconds * Duration.millisecondsPerSecond).round(),
            );
          }),
        ),
      );

  final ima.AdsManager _manager;

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
    weakThis.target?._manager.addAdEventListener(
      ima.AdEventListener(
        onAdEvent: (_, ima.AdEvent event) {
          weakThis.target?._managerDelegate?.params.onAdEvent?.call(
            PlatformAdEvent(
              type: toInterfaceEventType(event.type),
              adData:
                  event.adData?.cast<String, String>() ?? <String, String>{},
              ad: event.ad != null ? _asPlatformAd(event.ad!) : null,
            ),
          );
        },
      ),
    );
    weakThis.target?._manager.addAdErrorListener(
      ima.AdErrorListener(
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

PlatformAd _asPlatformAd(ima.Ad ad) {
  return PlatformAd(
    adId: ad.adId,
    adPodInfo: _asPlatformAdInfo(ad.adPodInfo),
    adSystem: ad.adSystem,
    wrapperCreativeIds: ad.adWrapperCreativeIds,
    wrapperIds: ad.adWrapperIds,
    wrapperSystems: ad.adWrapperSystems,
    advertiserName: ad.advertiserName,
    companionAds: List<PlatformCompanionAd>.unmodifiable(
      ad.companionAds.map(_asPlatformCompanionAd),
    ),
    contentType: ad.contentType,
    creativeAdId: ad.creativeAdId,
    creativeId: ad.creativeId,
    dealId: ad.dealId,
    description: ad.description,
    duration: ad.duration == -1
        ? null
        : Duration(
            milliseconds: (ad.duration * Duration.millisecondsPerSecond)
                .round(),
          ),
    height: ad.height,
    skipTimeOffset: ad.skipTimeOffset == -1
        ? null
        : Duration(
            milliseconds: (ad.skipTimeOffset * Duration.millisecondsPerSecond)
                .round(),
          ),
    surveyUrl: ad.surveyUrl,
    title: ad.title,
    traffickingParameters: ad.traffickingParameters,
    uiElements: ad.uiElements
        .map((ima.UiElement element) {
          return switch (element) {
            ima.UiElement.adAttribution => AdUIElement.adAttribution,
            ima.UiElement.countdown => AdUIElement.countdown,
            ima.UiElement.unknown => null,
          };
        })
        .whereType<AdUIElement>()
        .toSet(),
    universalAdIds: ad.universalAdIds.map(_asPlatformUniversalAdId).toList(),
    vastMediaBitrate: ad.vastMediaBitrate,
    vastMediaHeight: ad.vastMediaHeight,
    vastMediaWidth: ad.vastMediaWidth,
    width: ad.width,
    isLinear: ad.isLinear,
    isSkippable: ad.isSkippable,
  );
}

PlatformAdPodInfo _asPlatformAdInfo(ima.AdPodInfo adPodInfo) {
  return PlatformAdPodInfo(
    adPosition: adPodInfo.adPosition,
    maxDuration: adPodInfo.maxDuration == -1
        ? null
        : Duration(
            milliseconds:
                (adPodInfo.maxDuration * Duration.millisecondsPerSecond)
                    .round(),
          ),
    podIndex: adPodInfo.podIndex,
    timeOffset: Duration(
      milliseconds: (adPodInfo.timeOffset * Duration.millisecondsPerSecond)
          .round(),
    ),
    totalAds: adPodInfo.totalAds,
    isBumper: adPodInfo.isBumper,
  );
}

PlatformCompanionAd _asPlatformCompanionAd(ima.CompanionAd ad) {
  return PlatformCompanionAd(
    apiFramework: ad.apiFramework,
    height: ad.height == 0 ? null : ad.height,
    resourceValue: ad.resourceValue,
    width: ad.width == 0 ? null : ad.width,
  );
}

PlatformUniversalAdId _asPlatformUniversalAdId(
  ima.UniversalAdId universalAdId,
) {
  return PlatformUniversalAdId(
    adIdValue: universalAdId.adIdValue == 'unknown'
        ? null
        : universalAdId.adIdValue,
    adIdRegistry: universalAdId.adIdRegistry == 'unknown'
        ? null
        : universalAdId.adIdRegistry,
  );
}
