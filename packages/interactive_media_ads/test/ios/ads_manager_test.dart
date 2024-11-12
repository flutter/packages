// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:interactive_media_ads/src/ios/interactive_media_ads.g.dart'
    as ima;
import 'package:interactive_media_ads/src/ios/interactive_media_ads_proxy.dart';
import 'package:interactive_media_ads/src/ios/ios_ads_manager.dart';
import 'package:interactive_media_ads/src/ios/ios_ads_manager_delegate.dart';
import 'package:interactive_media_ads/src/platform_interface/platform_interface.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'ads_manager_test.mocks.dart';

@GenerateNiceMocks(<MockSpec<Object>>[
  MockSpec<ima.IMAAdsManager>(),
  MockSpec<ima.IMAAdsRenderingSettings>(),
])
void main() {
  group('IOSAdsManager', () {
    test('destroy', () {
      final MockIMAAdsManager mockAdsManager = MockIMAAdsManager();
      final IOSAdsManager adsManager = IOSAdsManager(mockAdsManager);
      adsManager.destroy();

      verify(mockAdsManager.destroy());
    });

    test('init', () async {
      final MockIMAAdsManager mockAdsManager = MockIMAAdsManager();

      final MockIMAAdsRenderingSettings mockAdsRenderingSettings =
          MockIMAAdsRenderingSettings();

      final IOSAdsManager adsManager = IOSAdsManager(
        mockAdsManager,
        proxy: InteractiveMediaAdsProxy(
          newIMAAdsRenderingSettings: () => mockAdsRenderingSettings,
        ),
      );

      final PlatformAdsRenderingSettings settings =
          PlatformAdsRenderingSettings(
        bitrate: 1000,
        enablePreloading: false,
        loadVideoTimeout: 8000,
        mimeTypes: <String>['value'],
        playAdsAfterTime: 2.0,
        uiElements: <UIElement>{UIElement.countdown},
      );
      await adsManager.init(settings);

      verifyInOrder(<Future<void>>[
        mockAdsRenderingSettings.setBitrate(1000),
        mockAdsRenderingSettings.setEnablePreloading(false),
        mockAdsRenderingSettings.setLoadVideoTimeout(8),
        mockAdsRenderingSettings.setMimeTypes(<String>['value']),
        mockAdsRenderingSettings.setPlayAdsAfterTime(2.0),
        mockAdsRenderingSettings.setUIElements(
          <ima.UIElementType>[ima.UIElementType.countdown],
        ),
        mockAdsManager.initialize(mockAdsRenderingSettings),
      ]);
    });

    test('start', () {
      final MockIMAAdsManager mockAdsManager = MockIMAAdsManager();
      final IOSAdsManager adsManager = IOSAdsManager(mockAdsManager);
      adsManager.start(AdsManagerStartParams());

      verify(mockAdsManager.start());
    });

    test('discardAdBreak', () {
      final MockIMAAdsManager mockAdsManager = MockIMAAdsManager();
      final IOSAdsManager adsManager = IOSAdsManager(mockAdsManager);
      adsManager.discardAdBreak();

      verify(mockAdsManager.discardAdBreak());
    });

    test('pause', () {
      final MockIMAAdsManager mockAdsManager = MockIMAAdsManager();
      final IOSAdsManager adsManager = IOSAdsManager(mockAdsManager);
      adsManager.pause();

      verify(mockAdsManager.pause());
    });

    test('skip', () {
      final MockIMAAdsManager mockAdsManager = MockIMAAdsManager();
      final IOSAdsManager adsManager = IOSAdsManager(mockAdsManager);
      adsManager.skip();

      verify(mockAdsManager.skip());
    });

    test('resume', () {
      final MockIMAAdsManager mockAdsManager = MockIMAAdsManager();
      final IOSAdsManager adsManager = IOSAdsManager(mockAdsManager);
      adsManager.resume();

      verify(mockAdsManager.resume());
    });

    test('setAdsManagerDelegate', () {
      final MockIMAAdsManager mockAdsManager = MockIMAAdsManager();
      final IOSAdsManager adsManager = IOSAdsManager(mockAdsManager);

      late final ima.IMAAdsManagerDelegate delegate;
      final InteractiveMediaAdsProxy imaProxy = InteractiveMediaAdsProxy(
        newIMAAdsManagerDelegate: ({
          required void Function(
            ima.IMAAdsManagerDelegate,
            ima.IMAAdsManager,
            ima.IMAAdEvent,
          ) didReceiveAdEvent,
          required void Function(
            ima.IMAAdsManagerDelegate,
            ima.IMAAdsManager,
            ima.IMAAdError,
          ) didReceiveAdError,
          required void Function(ima.IMAAdsManagerDelegate, ima.IMAAdsManager)
              didRequestContentPause,
          required void Function(ima.IMAAdsManagerDelegate, ima.IMAAdsManager)
              didRequestContentResume,
        }) {
          delegate = ima.IMAAdsManagerDelegate.pigeon_detached(
            didReceiveAdEvent: didReceiveAdEvent,
            didReceiveAdError: didReceiveAdError,
            didRequestContentPause: didRequestContentPause,
            didRequestContentResume: didRequestContentResume,
            pigeon_instanceManager: ima.PigeonInstanceManager(
              onWeakReferenceRemoved: (_) {},
            ),
          );
          return delegate;
        },
      );

      adsManager.setAdsManagerDelegate(IOSAdsManagerDelegate(
        IOSAdsManagerDelegateCreationParams(proxy: imaProxy),
      ));

      verify(mockAdsManager.setDelegate(delegate));
    });
  });
}
