// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:interactive_media_ads/src/android/android_ads_manager.dart';
import 'package:interactive_media_ads/src/android/android_ads_manager_delegate.dart';
import 'package:interactive_media_ads/src/android/android_ads_rendering_settings.dart';
import 'package:interactive_media_ads/src/android/interactive_media_ads.g.dart'
    as ima;
import 'package:interactive_media_ads/src/platform_interface/platform_interface.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'ads_manager_test.mocks.dart';

@GenerateNiceMocks(<MockSpec<Object>>[
  MockSpec<ima.AdError>(),
  MockSpec<ima.AdErrorEvent>(),
  MockSpec<ima.AdErrorListener>(),
  MockSpec<ima.AdEvent>(),
  MockSpec<ima.AdEventListener>(),
  MockSpec<ima.AdsManager>(),
  MockSpec<ima.AdsRenderingSettings>(),
  MockSpec<ima.ImaSdkFactory>(),
])
void main() {
  setUp(() {
    ima.PigeonOverrides.pigeon_reset();
  });

  group('AndroidAdsManager', () {
    test('destroy', () {
      final mockAdsManager = MockAdsManager();
      final adsManager = AndroidAdsManager(mockAdsManager);
      adsManager.destroy();

      verify(mockAdsManager.destroy());
    });

    test('init', () async {
      final mockAdsManager = MockAdsManager();

      final mockImaSdkFactory = MockImaSdkFactory();
      final mockAdsRenderingSettings = MockAdsRenderingSettings();
      when(mockImaSdkFactory.createAdsRenderingSettings()).thenAnswer(
        (_) => Future<ima.AdsRenderingSettings>.value(mockAdsRenderingSettings),
      );

      final adsManager = AndroidAdsManager(mockAdsManager);

      ima.PigeonOverrides.imaSdkFactory_instance = mockImaSdkFactory;
      final settings = AndroidAdsRenderingSettings(
        const AndroidAdsRenderingSettingsCreationParams(
          bitrate: 1000,
          enablePreloading: false,
          loadVideoTimeout: Duration(seconds: 2),
          mimeTypes: <String>['value'],
          playAdsAfterTime: Duration(seconds: 5),
          uiElements: <AdUIElement>{AdUIElement.countdown},
          enableCustomTabs: true,
        ),
      );
      await adsManager.init(settings: settings);

      verifyInOrder(<Future<void>>[
        mockAdsRenderingSettings.setBitrateKbps(1000),
        mockAdsRenderingSettings.setEnablePreloading(false),
        mockAdsRenderingSettings.setLoadVideoTimeout(2000),
        mockAdsRenderingSettings.setMimeTypes(<String>['value']),
        mockAdsRenderingSettings.setPlayAdsAfterTime(5.0),
        mockAdsRenderingSettings.setUiElements(<ima.UiElement>[
          ima.UiElement.countdown,
        ]),
        mockAdsRenderingSettings.setEnableCustomTabs(true),
        mockAdsManager.init(mockAdsRenderingSettings),
      ]);
    });

    test('start', () {
      final mockAdsManager = MockAdsManager();
      final adsManager = AndroidAdsManager(mockAdsManager);
      adsManager.start(AdsManagerStartParams());

      verify(mockAdsManager.start());
    });

    test('discardAdBreak', () {
      final mockAdsManager = MockAdsManager();
      final adsManager = AndroidAdsManager(mockAdsManager);
      adsManager.discardAdBreak();

      verify(mockAdsManager.discardAdBreak());
    });

    test('pause', () {
      final mockAdsManager = MockAdsManager();
      final adsManager = AndroidAdsManager(mockAdsManager);
      adsManager.pause();

      verify(mockAdsManager.pause());
    });

    test('skip', () {
      final mockAdsManager = MockAdsManager();
      final adsManager = AndroidAdsManager(mockAdsManager);
      adsManager.skip();

      verify(mockAdsManager.skip());
    });

    test('resume', () {
      final mockAdsManager = MockAdsManager();
      final adsManager = AndroidAdsManager(mockAdsManager);
      adsManager.resume();

      verify(mockAdsManager.resume());
    });

    test('onAdEvent', () async {
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
      ima.PigeonOverrides.adErrorListener_new = ({required dynamic onAdError}) {
        return MockAdErrorListener();
      };

      final adsManager = AndroidAdsManager(mockAdsManager);
      await adsManager.setAdsManagerDelegate(
        AndroidAdsManagerDelegate(
          PlatformAdsManagerDelegateCreationParams(
            onAdEvent: expectAsync1((PlatformAdEvent event) {
              expect(event.type, AdEventType.allAdsCompleted);
              expect(event.adData, <String, String>{'hello': 'world'});
            }),
          ),
        ),
      );

      final mockAdEvent = MockAdEvent();
      when(mockAdEvent.type).thenReturn(ima.AdEventType.allAdsCompleted);
      when(mockAdEvent.adData).thenReturn(<String, String>{'hello': 'world'});
      onAdEventCallback(MockAdEventListener(), mockAdEvent);
    });

    test('onAdErrorEvent', () async {
      final mockAdsManager = MockAdsManager();

      late final void Function(ima.AdErrorListener, ima.AdErrorEvent)
      onAdErrorCallback;

      ima.PigeonOverrides.adEventListener_new = ({required dynamic onAdEvent}) {
        return MockAdEventListener();
      };
      ima.PigeonOverrides.adErrorListener_new =
          ({
            required void Function(ima.AdErrorListener, ima.AdErrorEvent)
            onAdError,
          }) {
            onAdErrorCallback = onAdError;
            return MockAdErrorListener();
          };

      final adsManager = AndroidAdsManager(mockAdsManager);
      await adsManager.setAdsManagerDelegate(
        AndroidAdsManagerDelegate(
          PlatformAdsManagerDelegateCreationParams(
            onAdErrorEvent: expectAsync1((_) {}),
          ),
        ),
      );

      final mockErrorEvent = MockAdErrorEvent();
      final mockError = MockAdError();
      when(mockError.errorType).thenReturn(ima.AdErrorType.load);
      when(
        mockError.errorCode,
      ).thenReturn(ima.AdErrorCode.adsRequestNetworkError);
      when(mockError.message).thenReturn('error message');
      when(mockErrorEvent.error).thenReturn(mockError);
      onAdErrorCallback(MockAdErrorListener(), mockErrorEvent);
    });

    test('adCuePoints', () {
      final mockAdsManager = MockAdsManager();

      final cuePoints = <double>[1.0];
      when(mockAdsManager.adCuePoints).thenReturn(cuePoints);
      final adsManager = AndroidAdsManager(mockAdsManager);

      expect(adsManager.adCuePoints, <Duration>[const Duration(seconds: 1)]);
    });
  });
}
