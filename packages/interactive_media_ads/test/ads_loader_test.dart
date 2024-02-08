// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:interactive_media_ads/interactive_media_ads.dart';
import 'package:interactive_media_ads/src/platform_interface/platform_interface.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'ads_loader_test.mocks.dart';

@GenerateMocks(<Type>[PlatformAdsLoader, PlatformAdDisplayContainer])
void main() {
  test('contentComplete', () async {
    final MockPlatformAdsLoader mockPlatformAdsLoader = MockPlatformAdsLoader();

    final AdsLoader loader = AdsLoader.fromPlatform(
      mockPlatformAdsLoader,
    );

    await loader.contentComplete();
    verify(mockPlatformAdsLoader.contentComplete());
  });

  test('requestAds', () async {
    final MockPlatformAdsLoader mockPlatformAdsLoader = MockPlatformAdsLoader();

    final AdsLoader loader = AdsLoader.fromPlatform(
      mockPlatformAdsLoader,
    );

    await loader.requestAds(AdsRequest(adTagUrl: ''));
    verify(mockPlatformAdsLoader.requestAds(any));
  });
}
