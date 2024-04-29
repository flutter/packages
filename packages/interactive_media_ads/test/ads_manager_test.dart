// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:interactive_media_ads/interactive_media_ads.dart';
import 'package:interactive_media_ads/src/platform_interface/platform_interface.dart';

import 'test_stubs.dart';

void main() {
  test('init', () async {
    final TestAdsManager platformManager = TestAdsManager(
      onInit: expectAsync1((_) async {}),
    );

    final AdsManager manager = createAdsManager(platformManager);
    await manager.init();
  });

  test('start', () async {
    final TestAdsManager platformManager = TestAdsManager(
      onStart: expectAsync1((_) async {}),
    );

    final AdsManager manager = createAdsManager(platformManager);
    await manager.start();
  });

  test('setAdsManagerDelegate', () async {
    final TestAdsManager platformManager = TestAdsManager(
      onSetAdsManagerDelegate: expectAsync1((_) async {}),
    );

    final AdsManager manager = createAdsManager(platformManager);
    await manager.setAdsManagerDelegate(AdsManagerDelegate.fromPlatform(
      TestPlatformAdsManagerDelegate(
        const PlatformAdsManagerDelegateCreationParams(),
      ),
    ));
  });

  test('destroy', () async {
    final TestAdsManager platformManager = TestAdsManager(
      onDestroy: expectAsync0(() async {}),
    );

    final AdsManager manager = createAdsManager(platformManager);
    await manager.destroy();
  });
}

AdsManager createAdsManager(PlatformAdsManager platformManager) {
  InteractiveMediaAdsPlatform.instance = TestInteractiveMediaAdsPlatform(
    onCreatePlatformAdsLoader: (PlatformAdsLoaderCreationParams params) {
      return TestPlatformAdsLoader(params,
          onContentComplete: () async {},
          onRequestAds: (AdsRequest request) async {});
    },
    onCreatePlatformAdsManagerDelegate:
        (PlatformAdsManagerDelegateCreationParams params) {
      throw UnimplementedError();
    },
    onCreatePlatformAdDisplayContainer:
        (PlatformAdDisplayContainerCreationParams params) {
      throw UnimplementedError();
    },
  );

  late final AdsManager manager;

  final AdsLoader loader = AdsLoader(
    container: AdDisplayContainer.fromPlatform(
      platform: TestPlatformAdDisplayContainer(
        PlatformAdDisplayContainerCreationParams(
          onContainerAdded: (_) {},
        ),
        onBuild: (_) => Container(),
      ),
    ),
    onAdsLoaded: (OnAdsLoadedData data) {
      manager = data.manager;
    },
    onAdsLoadError: (_) {},
  );

  loader.platform.params.onAdsLoaded(PlatformOnAdsLoadedData(
    manager: platformManager,
  ));

  return manager;
}
