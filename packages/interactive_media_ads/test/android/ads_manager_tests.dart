import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:interactive_media_ads/src/android/android_ad_display_container.dart';
import 'package:interactive_media_ads/src/android/interactive_media_ads.g.dart'
    as ima;
import 'package:interactive_media_ads/src/android/interactive_media_ads_proxy.dart';
import 'package:interactive_media_ads/src/android/platform_views_service_proxy.dart';
import 'package:interactive_media_ads/src/platform_interface/platform_interface.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'ads_manager_tests.mocks.dart';

@GenerateNiceMocks(<MockSpec<Object>>[
  MockSpec<ima.AdError>(),
  MockSpec<ima.AdErrorEvent>(),
  MockSpec<ima.AdErrorListener>(),
  MockSpec<ima.AdEvent>(),
  MockSpec<ima.AdEventListener>(),
  MockSpec<ima.AdsManager>(),
])
void main() {
  group('AndroidAdsManager', () {
    test('destroy', () {
      final MockAdsManager mockAdsManager = MockAdsManager();
      final AndroidAdsManager adsManager = AndroidAdsManager(mockAdsManager);
      adsManager.destroy();

      verify(mockAdsManager.destroy());
    });

    test('init', () {
      final MockAdsManager mockAdsManager = MockAdsManager();
      final AndroidAdsManager adsManager = AndroidAdsManager(mockAdsManager);
      adsManager.init(AdsManagerInitParams());

      verify(mockAdsManager.init());
    });

    test('start', () {
      final MockAdsManager mockAdsManager = MockAdsManager();
      final AndroidAdsManager adsManager = AndroidAdsManager(mockAdsManager);
      adsManager.start(AdsManagerStartParams());

      verify(mockAdsManager.start());
    });

    test('on add aiowejpfoij', () {
      final MockAdsManager mockAdsManager = MockAdsManager();
      final InteractiveMediaAdsProxy proxy = InteractiveMediaAdsProxy(
        newAdEventListener: ({required dynamic onAdEvent}) {
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
      adsManager.destroy();

      verify(mockAdsManager.destroy());
    });
  });
}
