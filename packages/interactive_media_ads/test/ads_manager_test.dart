// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:interactive_media_ads/interactive_media_ads.dart';
import 'package:interactive_media_ads/src/platform_interface/platform_interface.dart';

import 'test_stubs.dart';

void main() {
  test('init', () async {
    final AdsRenderingSettings adsRenderingSettings =
        AdsRenderingSettings.fromPlatform(
      TestAdsRenderingSettings(
        const PlatformAdsRenderingSettingsCreationParams(),
      ),
    );

    final Completer<PlatformAdsRenderingSettings> settingsCompleter =
        Completer<PlatformAdsRenderingSettings>();

    final TestAdsManager platformManager = TestAdsManager(
      onInit: ({PlatformAdsRenderingSettings? settings}) async {
        settingsCompleter.complete(settings);
      },
    );

    final AdsManager manager = createAdsManager(platformManager);
    await manager.init(settings: adsRenderingSettings);
    expect(await settingsCompleter.future, adsRenderingSettings.platform);
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

  test('discardAdBreak', () async {
    final TestAdsManager platformManager = TestAdsManager(
      onDiscardAdBreak: expectAsync0(() async {}),
    );

    final AdsManager manager = createAdsManager(platformManager);
    await manager.discardAdBreak();
  });

  test('pause', () async {
    final TestAdsManager platformManager = TestAdsManager(
      onPause: expectAsync0(() async {}),
    );

    final AdsManager manager = createAdsManager(platformManager);
    await manager.pause();
  });

  test('resume', () async {
    final TestAdsManager platformManager = TestAdsManager(
      onResume: expectAsync0(() async {}),
    );

    final AdsManager manager = createAdsManager(platformManager);
    await manager.resume();
  });

  test('skip', () async {
    final TestAdsManager platformManager = TestAdsManager(
      onSkip: expectAsync0(() async {}),
    );

    final AdsManager manager = createAdsManager(platformManager);
    await manager.skip();
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
          onRequestAds: (PlatformAdsRequest request) async {});
    },
    onCreatePlatformAdsManagerDelegate:
        (PlatformAdsManagerDelegateCreationParams params) {
      throw UnimplementedError();
    },
    onCreatePlatformAdDisplayContainer:
        (PlatformAdDisplayContainerCreationParams params) {
      throw UnimplementedError();
    },
    onCreatePlatformContentProgressProvider: (_) => throw UnimplementedError(),
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
