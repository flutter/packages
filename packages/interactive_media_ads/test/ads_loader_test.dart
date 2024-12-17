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
      contentProgressProvider: TestContentProgressProvider(
        const PlatformContentProgressProviderCreationParams(),
      ),
    );

    final TestPlatformAdsLoader adsLoader = TestPlatformAdsLoader(
      PlatformAdsLoaderCreationParams(
        container: createTestAdDisplayContainer(),
        onAdsLoaded: (PlatformOnAdsLoadedData data) {},
        onAdsLoadError: (AdsLoadErrorData data) {},
      ),
      onRequestAds: expectAsync1((PlatformAdsRequest request) async {
        expect(request, platformRequest);
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
