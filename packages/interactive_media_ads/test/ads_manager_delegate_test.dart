// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:interactive_media_ads/interactive_media_ads.dart';
import 'package:interactive_media_ads/src/platform_interface/platform_interface.dart';

import 'test_stubs.dart';

void main() {
  test('passes params to platform instance', () async {
    InteractiveMediaAdsPlatform.instance = TestInteractiveMediaAdsPlatform(
      onCreatePlatformAdsManagerDelegate:
          (PlatformAdsManagerDelegateCreationParams params) {
            return TestPlatformAdsManagerDelegate(params);
          },
      onCreatePlatformAdsLoader: (PlatformAdsLoaderCreationParams params) {
        throw UnimplementedError();
      },
      onCreatePlatformAdDisplayContainer:
          (PlatformAdDisplayContainerCreationParams params) {
            throw UnimplementedError();
          },
      onCreatePlatformContentProgressProvider: (_) =>
          throw UnimplementedError(),
    );

    void onAdErrorEvent(AdErrorEvent event) {}

    final delegate = AdsManagerDelegate(
      onAdEvent: expectAsync1((AdEvent event) {
        expect(event.type, AdEventType.adBreakEnded);
        expect(event.ad, isNotNull);
      }),
      onAdErrorEvent: onAdErrorEvent,
    );

    delegate.platform.params.onAdEvent!(
      PlatformAdEvent(
        type: AdEventType.adBreakEnded,
        ad: PlatformAd(
          adId: '',
          adPodInfo: PlatformAdPodInfo(
            adPosition: 0,
            maxDuration: Duration.zero,
            podIndex: 0,
            timeOffset: Duration.zero,
            totalAds: 0,
            isBumper: true,
          ),
          adSystem: '',
          wrapperCreativeIds: const <String>[],
          wrapperIds: const <String>[],
          wrapperSystems: const <String>[],
          advertiserName: '',
          companionAds: const <PlatformCompanionAd>[],
          contentType: '',
          creativeAdId: '',
          creativeId: '',
          dealId: '',
          description: '',
          duration: Duration.zero,
          height: 9,
          skipTimeOffset: Duration.zero,
          surveyUrl: '',
          title: '',
          traffickingParameters: '',
          uiElements: const <AdUIElement>{},
          universalAdIds: const <PlatformUniversalAdId>[],
          vastMediaBitrate: 0,
          vastMediaHeight: 0,
          vastMediaWidth: 0,
          width: 0,
          isLinear: true,
          isSkippable: false,
        ),
      ),
    );
    expect(delegate.platform.params.onAdErrorEvent, onAdErrorEvent);
  });
}
