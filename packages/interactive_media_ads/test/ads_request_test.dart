// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:interactive_media_ads/interactive_media_ads.dart';
import 'package:interactive_media_ads/src/platform_interface/platform_interface.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'ads_request_test.mocks.dart';
import 'test_stubs.dart';

@GenerateMocks(<Type>[
  PlatformAdsRequest,
  TestInteractiveMediaAdsPlatform,
])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AdsRequest', () {
    late MockTestInteractiveMediaAdsPlatform platform;

    setUp(() {
      platform = MockTestInteractiveMediaAdsPlatform();
      InteractiveMediaAdsPlatform.instance = platform;
    });

    test('fromAdsResponse uses ads response in creation params', () {
      final AdsRequest request = AdsRequest.fromAdsResponse(
        adsResponse: 'adsResponse',
      );

      final PlatformAdsRequestCreationParams params =
          request.platform.params as PlatformAdsRequestCreationParams;
      expect(params.adsResponse, 'adsResponse');
      expect(params.adTagUrl, isNull);
    });

    test('setAdWillAutoPlay calls through to platform', () {
      const AdsRequest request = AdsRequest(adTagUrl: 'adTagUrl');
      request.setAdWillAutoPlay(true);
      verify(request.platform.setAdWillAutoPlay(true));
    });

    test('setAdWillPlayMuted calls through to platform', () {
      const AdsRequest request = AdsRequest(adTagUrl: 'adTagUrl');
      request.setAdWillPlayMuted(true);
      verify(request.platform.setAdWillPlayMuted(true));
    });

    test('setContinuousPlayback calls through to platform', () {
      const AdsRequest request = AdsRequest(adTagUrl: 'adTagUrl');
      request.setContinuousPlayback(true);
      verify(request.platform.setContinuousPlayback(true));
    });

    test('setContentDuration calls through to platform', () {
      const AdsRequest request = AdsRequest(adTagUrl: 'adTagUrl');
      request.setContentDuration(1.0);
      verify(request.platform.setContentDuration(1.0));
    });

    test('setContentKeywords calls through to platform', () {
      const AdsRequest request = AdsRequest(adTagUrl: 'adTagUrl');
      request.setContentKeywords(<String>['keyword']);
      verify(request.platform.setContentKeywords(<String>['keyword']));
    });

    test('setContentTitle calls through to platform', () {
      const AdsRequest request = AdsRequest(adTagUrl: 'adTagUrl');
      request.setContentTitle('title');
      verify(request.platform.setContentTitle('title'));
    });

    test('setContentUrl calls through to platform', () {
      const AdsRequest request = AdsRequest(adTagUrl: 'adTagUrl');
      request.setContentUrl('url');
      verify(request.platform.setContentUrl('url'));
    });

    test('setLiveStreamPrefetchSeconds calls through to platform', () {
      const AdsRequest request = AdsRequest(adTagUrl: 'adTagUrl');
      request.setLiveStreamPrefetchSeconds(1.0);
      verify(request.platform.setLiveStreamPrefetchSeconds(1.0));
    });

    test('setVastLoadTimeout calls through to platform', () {
      const AdsRequest request = AdsRequest(adTagUrl: 'adTagUrl');
      request.setVastLoadTimeout(1.0);
      verify(request.platform.setVastLoadTimeout(1.0));
    });
  });
}
