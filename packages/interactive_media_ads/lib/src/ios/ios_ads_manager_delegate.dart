// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:meta/meta.dart';

import '../platform_interface/platform_interface.dart';
import 'enum_converter_utils.dart';
import 'interactive_media_ads.g.dart' as ima;

/// Implementation of [PlatformAdsManagerDelegateCreationParams] for iOS.
final class IOSAdsManagerDelegateCreationParams
    extends PlatformAdsManagerDelegateCreationParams {
  /// Constructs an [IOSAdsManagerDelegateCreationParams].
  const IOSAdsManagerDelegateCreationParams({
    super.onAdEvent,
    super.onAdErrorEvent,
  }) : super();

  /// Creates an [IOSAdsManagerDelegateCreationParams] from an instance of
  /// [PlatformAdsManagerDelegateCreationParams].
  factory IOSAdsManagerDelegateCreationParams.fromPlatformAdsManagerDelegateCreationParams(
    PlatformAdsManagerDelegateCreationParams params,
  ) {
    return IOSAdsManagerDelegateCreationParams(
      onAdEvent: params.onAdEvent,
      onAdErrorEvent: params.onAdErrorEvent,
    );
  }
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

  // This value is created in a static method because the callback methods for
  // any wrapped classes must not reference the encapsulating object. This is to
  // prevent a circular reference that prevents garbage collection.
  static ima.IMAAdsManagerDelegate _createAdsManagerDelegate(
    WeakReference<IOSAdsManagerDelegate> interfaceDelegate,
  ) {
    return ima.IMAAdsManagerDelegate(
      didReceiveAdEvent: (_, __, ima.IMAAdEvent event) {
        interfaceDelegate.target?.params.onAdEvent?.call(
          PlatformAdEvent(
            type: toInterfaceEventType(event.type),
            adData:
                event.adData?.map((String? key, Object? value) {
                  return MapEntry<String, String>(key!, value.toString());
                }) ??
                <String, String>{},
            ad: event.ad != null ? _asPlatformAd(event.ad!) : null,
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
          const PlatformAdEvent(type: AdEventType.contentPauseRequested),
        );
      },
      didRequestContentResume: (_, __) {
        interfaceDelegate.target?.params.onAdEvent?.call(
          const PlatformAdEvent(type: AdEventType.contentResumeRequested),
        );
      },
    );
  }
}

PlatformAd _asPlatformAd(ima.IMAAd ad) {
  return PlatformAd(
    adId: ad.adId,
    adPodInfo: _asPlatformAdInfo(ad.adPodInfo),
    adSystem: ad.adSystem,
    wrapperCreativeIds: ad.wrapperCreativeIDs,
    wrapperIds: ad.wrapperAdIDs,
    wrapperSystems: ad.wrapperSystems,
    advertiserName: ad.advertiserName,
    companionAds: List<PlatformCompanionAd>.unmodifiable(
      ad.companionAds.map(_asPlatformCompanionAd),
    ),
    contentType: ad.contentType,
    creativeAdId: ad.creativeAdID,
    creativeId: ad.creativeID,
    dealId: ad.dealID,
    description: ad.adDescription,
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
    surveyUrl: ad.surveyURL,
    title: ad.adTitle,
    traffickingParameters: ad.traffickingParameters,
    uiElements: ad.uiElements
        .map((ima.UIElementType element) {
          return switch (element) {
            ima.UIElementType.adAttribution => AdUIElement.adAttribution,
            ima.UIElementType.countdown => AdUIElement.countdown,
            ima.UIElementType.unknown => null,
          };
        })
        .whereType<AdUIElement>()
        .toSet(),
    universalAdIds: ad.universalAdIDs.map(_asPlatformUniversalAdId).toList(),
    vastMediaBitrate: ad.vastMediaBitrate,
    vastMediaHeight: ad.vastMediaHeight,
    vastMediaWidth: ad.vastMediaWidth,
    width: ad.width,
    isLinear: ad.isLinear,
    isSkippable: ad.isSkippable,
  );
}

PlatformAdPodInfo _asPlatformAdInfo(ima.IMAAdPodInfo adPodInfo) {
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

PlatformCompanionAd _asPlatformCompanionAd(ima.IMACompanionAd ad) {
  return PlatformCompanionAd(
    apiFramework: ad.apiFramework,
    height: ad.height == 0 ? null : ad.height,
    resourceValue: ad.resourceValue,
    width: ad.width == 0 ? null : ad.width,
  );
}

PlatformUniversalAdId _asPlatformUniversalAdId(
  ima.IMAUniversalAdID universalAdId,
) {
  return PlatformUniversalAdId(
    adIdValue: universalAdId.adIDValue == 'unknown'
        ? null
        : universalAdId.adIDValue,
    adIdRegistry: universalAdId.adIDRegistry == 'unknown'
        ? null
        : universalAdId.adIDRegistry,
  );
}
