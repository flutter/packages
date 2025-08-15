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
    final PlatformAdsRequest platformRequest = PlatformAdsRequest.withAdTagUrl(
      adTagUrl: 'adTagUrl',
      adWillAutoPlay: true,
      adWillPlayMuted: false,
      continuousPlayback: true,
      contentDuration: const Duration(seconds: 2),
      contentKeywords: <String>['keyword1', 'keyword2'],
      contentTitle: 'contentTitle',
      liveStreamPrefetchMaxWaitTime: const Duration(seconds: 3),
      vastLoadTimeout: const Duration(milliseconds: 5000),
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
        expect(
          (request as PlatformAdsRequestWithAdTagUrl).adTagUrl,
          (platformRequest as PlatformAdsRequestWithAdTagUrl).adTagUrl,
        );
        expect(request.adWillAutoPlay, platformRequest.adWillAutoPlay);
        expect(request.adWillPlayMuted, platformRequest.adWillPlayMuted);
        expect(request.continuousPlayback, platformRequest.continuousPlayback);
        expect(request.contentDuration, platformRequest.contentDuration);
        expect(request.contentKeywords, platformRequest.contentKeywords);
        expect(request.contentTitle, platformRequest.contentTitle);
        expect(
          request.liveStreamPrefetchMaxWaitTime,
          platformRequest.liveStreamPrefetchMaxWaitTime,
        );
        expect(request.vastLoadTimeout, platformRequest.vastLoadTimeout);
        expect(
          request.contentProgressProvider,
          platformRequest.contentProgressProvider,
        );
      }),
      onContentComplete: () async {},
    );

    final AdsLoader loader = AdsLoader.fromPlatform(adsLoader);
    await loader.requestAds(AdsRequest(
      adTagUrl: (platformRequest as PlatformAdsRequestWithAdTagUrl).adTagUrl,
      adWillAutoPlay: platformRequest.adWillAutoPlay,
      adWillPlayMuted: platformRequest.adWillPlayMuted,
      continuousPlayback: platformRequest.continuousPlayback,
      contentDuration: platformRequest.contentDuration,
      contentKeywords: platformRequest.contentKeywords,
      contentTitle: platformRequest.contentTitle,
      liveStreamPrefetchMaxWaitTime:
          platformRequest.liveStreamPrefetchMaxWaitTime,
      vastLoadTimeout: platformRequest.vastLoadTimeout,
      contentProgressProvider: ContentProgressProvider.fromPlatform(
        platformRequest.contentProgressProvider!,
      ),
    ));
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
