// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:interactive_media_ads/interactive_media_ads.dart';
import 'package:interactive_media_ads/src/platform_interface/platform_interface.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'ads_manager_test.mocks.dart';
import 'test_stubs.dart';

@GenerateMocks(<Type>[
  PlatformAdsManager,
  PlatformAdsManagerDelegate,
  PlatformAdsLoader,
  PlatformAdDisplayContainer,
])
void main() {
  AdsManager createAdsManagerWithMockPlatform(
    MockPlatformAdsManager mockManager,
  ) {
    InteractiveMediaAdsPlatform.instance = TestInteractiveMediaAdsPlatform(
      onCreatePlatformAdsLoader: (PlatformAdsLoaderCreationParams params) {
        return TestPlatformAdsLoader(params);
      },
    );

    late final AdsManager manager;

    final AdsLoader loader = AdsLoader(
      container: AdDisplayContainer.fromPlatform(
        platform: MockPlatformAdDisplayContainer(),
      ),
      onAdsLoaded: (OnAdsLoadedData data) {
        manager = data.manager;
      },
      onAdsLoadError: (_) {},
    );

    loader.platform.params.onAdsLoaded(PlatformOnAdsLoadedData(
      manager: mockManager,
    ));

    return manager;
  }

  test('init', () async {
    final MockPlatformAdsManager mockPlatformAdsManager =
        MockPlatformAdsManager();
    final AdsManager manager = createAdsManagerWithMockPlatform(
      mockPlatformAdsManager,
    );

    await manager.init();
    verify(mockPlatformAdsManager.init(any));
  });

  test('start', () async {
    final MockPlatformAdsManager mockPlatformAdsManager =
        MockPlatformAdsManager();
    final AdsManager manager = createAdsManagerWithMockPlatform(
      mockPlatformAdsManager,
    );

    await manager.start();
    verify(mockPlatformAdsManager.start(any));
  });

  test('setAdsManagerDelegate', () async {
    final MockPlatformAdsManager mockPlatformAdsManager =
        MockPlatformAdsManager();
    final AdsManager manager = createAdsManagerWithMockPlatform(
      mockPlatformAdsManager,
    );

    await manager.setAdsManagerDelegate(AdsManagerDelegate.fromPlatform(
      MockPlatformAdsManagerDelegate(),
    ));
    verify(mockPlatformAdsManager.setAdsManagerDelegate(any));
  });

  test('destroy', () async {
    final MockPlatformAdsManager mockPlatformAdsManager =
        MockPlatformAdsManager();
    final AdsManager manager = createAdsManagerWithMockPlatform(
      mockPlatformAdsManager,
    );

    await manager.destroy();
    verify(mockPlatformAdsManager.destroy());
  });
}
