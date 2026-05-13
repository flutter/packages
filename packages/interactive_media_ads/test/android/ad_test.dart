// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:interactive_media_ads/src/android/android_ads_manager.dart';
import 'package:interactive_media_ads/src/android/android_ads_manager_delegate.dart';
import 'package:interactive_media_ads/src/android/interactive_media_ads.g.dart'
    as ima;
import 'package:interactive_media_ads/src/platform_interface/platform_interface.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'ad_test.mocks.dart';

@GenerateNiceMocks(<MockSpec<Object>>[
  MockSpec<ima.AdsManager>(),
  MockSpec<ima.AdEvent>(),
  MockSpec<ima.AdEventListener>(),
  MockSpec<ima.AdErrorListener>(),
])
void main() {
  group('Ad', () {
    setUp(() {
      ima.PigeonOverrides.pigeon_reset();
    });

    test('UniversalAdId sets unknown values to null', () async {
      final mockAdsManager = MockAdsManager();

      late final void Function(ima.AdEventListener, ima.AdEvent)
      onAdEventCallback;

      ima.PigeonOverrides.adEventListener_new =
          ({
            required void Function(ima.AdEventListener, ima.AdEvent) onAdEvent,
          }) {
            onAdEventCallback = onAdEvent;
            return MockAdEventListener();
          };

      ima.PigeonOverrides.adErrorListener_new =
          ({
            required void Function(ima.AdErrorListener, ima.AdErrorEvent)
            onAdError,
          }) {
            return MockAdErrorListener();
          };

      final adsManager = AndroidAdsManager(mockAdsManager);

      await adsManager.setAdsManagerDelegate(
        AndroidAdsManagerDelegate(
          PlatformAdsManagerDelegateCreationParams(
            onAdEvent: expectAsync1((PlatformAdEvent event) {
              expect(event.ad!.universalAdIds.single.adIdValue, isNull);
              expect(event.ad!.universalAdIds.single.adIdRegistry, isNull);
            }),
          ),
        ),
      );

      final mockAdEvent = MockAdEvent();
      when(mockAdEvent.type).thenReturn(ima.AdEventType.allAdsCompleted);
      when(mockAdEvent.ad).thenReturn(
        createTestAd(
          universalAdIds: <ima.UniversalAdId>[
            ima.UniversalAdId.pigeon_detached(
              adIdRegistry: 'unknown',
              adIdValue: 'unknown',
            ),
          ],
        ),
      );

      onAdEventCallback(MockAdEventListener(), mockAdEvent);
    });

    test('CompanionAd sets 0 values for height/width to null', () async {
      final mockAdsManager = MockAdsManager();

      late final void Function(ima.AdEventListener, ima.AdEvent)
      onAdEventCallback;

      ima.PigeonOverrides.adEventListener_new =
          ({
            required void Function(ima.AdEventListener, ima.AdEvent) onAdEvent,
          }) {
            onAdEventCallback = onAdEvent;
            return MockAdEventListener();
          };

      ima.PigeonOverrides.adErrorListener_new =
          ({
            required void Function(ima.AdErrorListener, ima.AdErrorEvent)
            onAdError,
          }) {
            return MockAdErrorListener();
          };

      final adsManager = AndroidAdsManager(mockAdsManager);

      await adsManager.setAdsManagerDelegate(
        AndroidAdsManagerDelegate(
          PlatformAdsManagerDelegateCreationParams(
            onAdEvent: expectAsync1((PlatformAdEvent event) {
              expect(event.ad!.companionAds.single.width, isNull);
              expect(event.ad!.companionAds.single.height, isNull);
            }),
          ),
        ),
      );

      final mockAdEvent = MockAdEvent();
      when(mockAdEvent.type).thenReturn(ima.AdEventType.allAdsCompleted);
      when(mockAdEvent.ad).thenReturn(
        createTestAd(
          companionAds: <ima.CompanionAd>[
            ima.CompanionAd.pigeon_detached(height: 0, width: 0),
          ],
        ),
      );

      onAdEventCallback(MockAdEventListener(), mockAdEvent);
    });

    test('Ad sets durations of -1 to null', () async {
      final mockAdsManager = MockAdsManager();

      late final void Function(ima.AdEventListener, ima.AdEvent)
      onAdEventCallback;

      ima.PigeonOverrides.adEventListener_new =
          ({
            required void Function(ima.AdEventListener, ima.AdEvent) onAdEvent,
          }) {
            onAdEventCallback = onAdEvent;
            return MockAdEventListener();
          };

      ima.PigeonOverrides.adErrorListener_new =
          ({
            required void Function(ima.AdErrorListener, ima.AdErrorEvent)
            onAdError,
          }) {
            return MockAdErrorListener();
          };

      final adsManager = AndroidAdsManager(mockAdsManager);

      await adsManager.setAdsManagerDelegate(
        AndroidAdsManagerDelegate(
          PlatformAdsManagerDelegateCreationParams(
            onAdEvent: expectAsync1((PlatformAdEvent event) {
              expect(event.ad!.duration, isNull);
              expect(event.ad!.skipTimeOffset, isNull);
              expect(event.ad!.adPodInfo.maxDuration, isNull);
            }),
          ),
        ),
      );

      final mockAdEvent = MockAdEvent();
      when(mockAdEvent.type).thenReturn(ima.AdEventType.allAdsCompleted);
      when(mockAdEvent.ad).thenReturn(
        createTestAd(
          duration: -1,
          skipTimeOffset: -1,
          adPodInfo: ima.AdPodInfo.pigeon_detached(
            adPosition: 0,
            maxDuration: -1,
            podIndex: 0,
            timeOffset: 0,
            totalAds: 0,
            isBumper: true,
          ),
        ),
      );

      onAdEventCallback(MockAdEventListener(), mockAdEvent);
    });
  });
}

ima.Ad createTestAd({
  List<ima.UniversalAdId>? universalAdIds,
  List<ima.CompanionAd>? companionAds,
  ima.AdPodInfo? adPodInfo,
  double? duration,
  double? skipTimeOffset,
}) {
  return ima.Ad.pigeon_detached(
    adId: '',
    adPodInfo:
        adPodInfo ??
        ima.AdPodInfo.pigeon_detached(
          adPosition: 0,
          maxDuration: 0,
          podIndex: 0,
          timeOffset: 0,
          totalAds: 0,
          isBumper: false,
        ),
    adSystem: '',
    adWrapperCreativeIds: const <String>[],
    adWrapperIds: const <String>[],
    adWrapperSystems: const <String>[],
    advertiserName: '',
    companionAds: companionAds ?? const <ima.CompanionAd>[],
    creativeAdId: '',
    creativeId: '',
    dealId: '',
    duration: duration ?? 0,
    height: 0,
    skipTimeOffset: skipTimeOffset ?? 0,
    traffickingParameters: '',
    uiElements: const <ima.UiElement>[],
    universalAdIds: universalAdIds ?? const <ima.UniversalAdId>[],
    vastMediaBitrate: 0,
    vastMediaHeight: 0,
    vastMediaWidth: 0,
    width: 0,
    isLinear: true,
    isSkippable: true,
  );
}
