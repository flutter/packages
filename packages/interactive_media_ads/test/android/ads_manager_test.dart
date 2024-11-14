// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:interactive_media_ads/src/android/android_ads_manager.dart';
import 'package:interactive_media_ads/src/android/android_ads_manager_delegate.dart';
import 'package:interactive_media_ads/src/android/android_ads_rendering_settings.dart';
import 'package:interactive_media_ads/src/android/interactive_media_ads.g.dart'
    as ima;
import 'package:interactive_media_ads/src/android/interactive_media_ads_proxy.dart';
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
  group('AndroidAdsManager', () {
    test('destroy', () {
      final MockAdsManager mockAdsManager = MockAdsManager();
      final AndroidAdsManager adsManager = AndroidAdsManager(mockAdsManager);
      adsManager.destroy();

      verify(mockAdsManager.destroy());
    });

    test('init', () async {
      final MockAdsManager mockAdsManager = MockAdsManager();

      final MockImaSdkFactory mockImaSdkFactory = MockImaSdkFactory();
      final MockAdsRenderingSettings mockAdsRenderingSettings =
          MockAdsRenderingSettings();
      when(mockImaSdkFactory.createAdsRenderingSettings()).thenAnswer(
        (_) => Future<ima.AdsRenderingSettings>.value(mockAdsRenderingSettings),
      );

      final AndroidAdsManager adsManager = AndroidAdsManager(mockAdsManager);

      final AndroidAdsRenderingSettings settings = AndroidAdsRenderingSettings(
        AndroidAdsRenderingSettingsCreationParams(
          bitrate: 1000,
          enablePreloading: false,
          loadVideoTimeout: const Duration(seconds: 2),
          mimeTypes: const <String>['value'],
          playAdsAfterTime: const Duration(seconds: 5),
          uiElements: const <AdUIElement>{AdUIElement.countdown},
          enableCustomTabs: true,
          proxy: InteractiveMediaAdsProxy(
            instanceImaSdkFactory: () => mockImaSdkFactory,
          ),
        ),
      );
      await adsManager.init(settings: settings);

      verifyInOrder(<Future<void>>[
        mockAdsRenderingSettings.setBitrateKbps(1000),
        mockAdsRenderingSettings.setEnablePreloading(false),
        mockAdsRenderingSettings.setLoadVideoTimeout(2000),
        mockAdsRenderingSettings.setMimeTypes(<String>['value']),
        mockAdsRenderingSettings.setPlayAdsAfterTime(5.0),
        mockAdsRenderingSettings.setUiElements(
          <ima.UiElement>[ima.UiElement.countdown],
        ),
        mockAdsRenderingSettings.setEnableCustomTabs(true),
        mockAdsManager.init(mockAdsRenderingSettings),
      ]);
    });

    test('start', () {
      final MockAdsManager mockAdsManager = MockAdsManager();
      final AndroidAdsManager adsManager = AndroidAdsManager(mockAdsManager);
      adsManager.start(AdsManagerStartParams());

      verify(mockAdsManager.start());
    });

    test('discardAdBreak', () {
      final MockAdsManager mockAdsManager = MockAdsManager();
      final AndroidAdsManager adsManager = AndroidAdsManager(mockAdsManager);
      adsManager.discardAdBreak();

      verify(mockAdsManager.discardAdBreak());
    });

    test('pause', () {
      final MockAdsManager mockAdsManager = MockAdsManager();
      final AndroidAdsManager adsManager = AndroidAdsManager(mockAdsManager);
      adsManager.pause();

      verify(mockAdsManager.pause());
    });

    test('skip', () {
      final MockAdsManager mockAdsManager = MockAdsManager();
      final AndroidAdsManager adsManager = AndroidAdsManager(mockAdsManager);
      adsManager.skip();

      verify(mockAdsManager.skip());
    });

    test('resume', () {
      final MockAdsManager mockAdsManager = MockAdsManager();
      final AndroidAdsManager adsManager = AndroidAdsManager(mockAdsManager);
      adsManager.resume();

      verify(mockAdsManager.resume());
    });

    test('onAdEvent', () async {
      final MockAdsManager mockAdsManager = MockAdsManager();

      late final void Function(
        ima.AdEventListener,
        ima.AdEvent,
      ) onAdEventCallback;

      final InteractiveMediaAdsProxy proxy = InteractiveMediaAdsProxy(
        newAdEventListener: ({
          required void Function(
            ima.AdEventListener,
            ima.AdEvent,
          ) onAdEvent,
        }) {
          onAdEventCallback = onAdEvent;
          return MockAdEventListener();
        },
        newAdErrorListener: ({required dynamic onAdError}) {
          return MockAdErrorListener();
        },
      );

      final AndroidAdsManager adsManager = AndroidAdsManager(
        mockAdsManager,
        proxy: proxy,
      );
      await adsManager.setAdsManagerDelegate(
        AndroidAdsManagerDelegate(
          PlatformAdsManagerDelegateCreationParams(
            onAdEvent: expectAsync1((AdEvent event) {
              expect(event.type, AdEventType.allAdsCompleted);
              expect(event.adData, <String, String>{'hello': 'world'});
            }),
          ),
        ),
      );

      final MockAdEvent mockAdEvent = MockAdEvent();
      when(mockAdEvent.type).thenReturn(ima.AdEventType.allAdsCompleted);
      when(mockAdEvent.adData).thenReturn(<String, String>{'hello': 'world'});
      onAdEventCallback(MockAdEventListener(), mockAdEvent);
    });

    test('onAdErrorEvent', () async {
      final MockAdsManager mockAdsManager = MockAdsManager();

      late final void Function(
        ima.AdErrorListener,
        ima.AdErrorEvent,
      ) onAdErrorCallback;

      final InteractiveMediaAdsProxy proxy = InteractiveMediaAdsProxy(
        newAdEventListener: ({required dynamic onAdEvent}) {
          return MockAdEventListener();
        },
        newAdErrorListener: ({
          required void Function(
            ima.AdErrorListener,
            ima.AdErrorEvent,
          ) onAdError,
        }) {
          onAdErrorCallback = onAdError;
          return MockAdErrorListener();
        },
      );

      final AndroidAdsManager adsManager = AndroidAdsManager(
        mockAdsManager,
        proxy: proxy,
      );
      await adsManager.setAdsManagerDelegate(
        AndroidAdsManagerDelegate(
          PlatformAdsManagerDelegateCreationParams(
            onAdErrorEvent: expectAsync1((_) {}),
          ),
        ),
      );

      final MockAdErrorEvent mockErrorEvent = MockAdErrorEvent();
      final MockAdError mockError = MockAdError();
      when(mockError.errorType).thenReturn(ima.AdErrorType.load);
      when(mockError.errorCode)
          .thenReturn(ima.AdErrorCode.adsRequestNetworkError);
      when(mockError.message).thenReturn('error message');
      when(mockErrorEvent.error).thenReturn(mockError);
      onAdErrorCallback(MockAdErrorListener(), mockErrorEvent);
    });
  });
}
