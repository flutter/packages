// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:interactive_media_ads/interactive_media_ads.dart';
import 'package:interactive_media_ads/src/platform_interface/platform_interface.dart';

import 'test_stubs.dart';

void main() {
  test('contentComplete', () async {
    final TestPlatformAdsLoader adsLoader = TestPlatformAdsLoader(
      PlatformAdsLoaderCreationParams(
        container: createTestAdDisplayContainer(),
        settings: TestImaSettings(const PlatformImaSettingsCreationParams()),
        onAdsLoaded: (PlatformOnAdsLoadedData data) {},
        onAdsLoadError: (AdsLoadErrorData data) {},
      ),
      onContentComplete: expectAsync0(() async {}),
      onRequestAds: (PlatformAdsRequest request) async {},
    );

    final AdsLoader loader = AdsLoader.fromPlatform(adsLoader);
    await loader.contentComplete();
  });

  test('requestAds', () async {
    final PlatformAdsRequest platformRequest = PlatformAdsRequest(
      adTagUrl: 'adTagUrl',
      adsResponse: 'adsResponse',
      adWillAutoPlay: true,
      adWillPlayMuted: false,
      continuousPlayback: true,
      contentDuration: 2.0,
      contentKeywords: <String>['keyword1', 'keyword2'],
      contentTitle: 'contentTitle',
      liveStreamPrefetchSeconds: 3.0,
      vastLoadTimeout: 4.0,
      contentUrl: 'contentUrl',
      contentProgressProvider: TestContentProgressProvider(
        const PlatformContentProgressProviderCreationParams(),
      ),
    );

    final TestPlatformAdsLoader adsLoader = TestPlatformAdsLoader(
      PlatformAdsLoaderCreationParams(
        container: createTestAdDisplayContainer(),
        settings: TestImaSettings(const PlatformImaSettingsCreationParams()),
        onAdsLoaded: (PlatformOnAdsLoadedData data) {},
        onAdsLoadError: (AdsLoadErrorData data) {},
      ),
      onRequestAds: expectAsync1((PlatformAdsRequest request) async {
        expect(request.adTagUrl, platformRequest.adTagUrl);
        expect(request.adsResponse, platformRequest.adsResponse);
        expect(request.adWillAutoPlay, platformRequest.adWillAutoPlay);
        expect(request.adWillPlayMuted, platformRequest.adWillPlayMuted);
        expect(request.continuousPlayback, platformRequest.continuousPlayback);
        expect(request.contentDuration, platformRequest.contentDuration);
        expect(request.contentKeywords, platformRequest.contentKeywords);
        expect(request.contentTitle, platformRequest.contentTitle);
        expect(request.liveStreamPrefetchSeconds,
            platformRequest.liveStreamPrefetchSeconds);
        expect(request.vastLoadTimeout, platformRequest.vastLoadTimeout);
        expect(request.contentUrl, platformRequest.contentUrl);
        expect(request.contentProgressProvider,
            platformRequest.contentProgressProvider);
      }),
      onContentComplete: () async {},
    );

    final AdsLoader loader = AdsLoader.fromPlatform(adsLoader);
    await loader.requestAds(AdsRequest.fromPlatform(platformRequest));
  });
}

TestPlatformAdDisplayContainer createTestAdDisplayContainer() {
  return TestPlatformAdDisplayContainer(
    PlatformAdDisplayContainerCreationParams(
      onContainerAdded: (_) {},
    ),
    onBuild: (_) => Container(),
  );
}
