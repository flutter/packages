// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:interactive_media_ads/src/android/android_ad_display_container.dart';
import 'package:interactive_media_ads/src/android/android_ads_loader.dart';
import 'package:interactive_media_ads/src/android/android_content_progress_provider.dart';
import 'package:interactive_media_ads/src/android/android_ima_settings.dart';
import 'package:interactive_media_ads/src/android/interactive_media_ads.g.dart'
    as ima;
import 'package:interactive_media_ads/src/android/interactive_media_ads_proxy.dart';
import 'package:interactive_media_ads/src/android/platform_views_service_proxy.dart';
import 'package:interactive_media_ads/src/platform_interface/platform_interface.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'ads_loader_test.mocks.dart';

@GenerateNiceMocks(<MockSpec<Object>>[
  MockSpec<ima.AdDisplayContainer>(),
  MockSpec<ima.AdError>(),
  MockSpec<ima.AdErrorEvent>(),
  MockSpec<ima.AdErrorListener>(),
  MockSpec<ima.AdsLoadedListener>(),
  MockSpec<ima.AdsManager>(),
  MockSpec<ima.AdsManagerLoadedEvent>(),
  MockSpec<ima.AdsLoader>(),
  MockSpec<ima.AdsRequest>(),
  MockSpec<ima.FrameLayout>(),
  MockSpec<ima.ImaSdkFactory>(),
  MockSpec<ima.ImaSdkSettings>(),
  MockSpec<ima.VideoAdPlayer>(),
  MockSpec<ima.VideoAdPlayerCallback>(),
  MockSpec<ima.VideoView>(),
  MockSpec<SurfaceAndroidViewController>(),
  MockSpec<PlatformViewsServiceProxy>(),
])
void main() {
  group('AndroidAdsLoader', () {
    setUp(() {
      ima.PigeonOverrides.pigeon_reset();
    });

    testWidgets('instantiate AndroidAdsLoader', (WidgetTester tester) async {
      final AndroidAdDisplayContainer container =
          await _pumpAdDisplayContainer(tester);

      final MockImaSdkSettings mockImaSdkSettings = MockImaSdkSettings();
      final MockImaSdkFactory mockSdkFactory = _mockImaSdkFactoryInstance(
        imaSdkSettings: mockImaSdkSettings,
      );

      final AndroidImaSettings settings = AndroidImaSettings(
        const PlatformImaSettingsCreationParams(),
      );

      AndroidAdsLoader(
        AndroidAdsLoaderCreationParams(
          container: container,
          settings: settings,
          onAdsLoaded: (PlatformOnAdsLoadedData data) {},
          onAdsLoadError: (AdsLoadErrorData data) {},
        ),
      );

      expect(await settings.nativeSettingsFuture, mockImaSdkSettings);
      verify(mockSdkFactory.createAdsLoader(
        mockImaSdkSettings,
        container.adDisplayContainer,
      ));
    });

    testWidgets('contentComplete', (WidgetTester tester) async {
      final MockVideoAdPlayerCallback mockAdPlayerCallback =
          MockVideoAdPlayerCallback();
      final AndroidAdDisplayContainer container = await _pumpAdDisplayContainer(
        tester,
        mockAdPlayerCallback: mockAdPlayerCallback,
      );

      _mockImaSdkFactoryInstance();

      final AndroidAdsLoader loader = AndroidAdsLoader(
        AndroidAdsLoaderCreationParams(
          container: container,
          settings: AndroidImaSettings(
            const PlatformImaSettingsCreationParams(),
          ),
          onAdsLoaded: (PlatformOnAdsLoadedData data) {},
          onAdsLoadError: (AdsLoadErrorData data) {},
        ),
      );

      await loader.contentComplete();
      verify(mockAdPlayerCallback.onContentComplete());
    });

    testWidgets('requestAds', (WidgetTester tester) async {
      final AndroidAdDisplayContainer container =
          await _pumpAdDisplayContainer(tester);

      final MockAdsLoader mockAdsLoader = MockAdsLoader();
      final MockAdsRequest mockAdsRequest = MockAdsRequest();
      _mockImaSdkFactoryInstance(
        adsRequest: mockAdsRequest,
        adsLoader: mockAdsLoader,
      );

      final InteractiveMediaAdsProxy proxy = InteractiveMediaAdsProxy(
        newContentProgressProvider: () =>
            ima.ContentProgressProvider.pigeon_detached(),
      );

      final AndroidAdsLoader adsLoader = AndroidAdsLoader(
        AndroidAdsLoaderCreationParams(
          container: container,
          settings: AndroidImaSettings(
            const PlatformImaSettingsCreationParams(),
          ),
          onAdsLoaded: (PlatformOnAdsLoadedData data) {},
          onAdsLoadError: (AdsLoadErrorData data) {},
          proxy: proxy,
        ),
      );

      final AndroidContentProgressProvider progressProvider =
          AndroidContentProgressProvider(
        AndroidContentProgressProviderCreationParams(proxy: proxy),
      );
      await adsLoader.requestAds(
        PlatformAdsRequest.withAdTagUrl(
          adTagUrl: 'url',
          adWillAutoPlay: true,
          adWillPlayMuted: false,
          continuousPlayback: true,
          contentDuration: const Duration(seconds: 2),
          contentKeywords: <String>['keyword1', 'keyword2'],
          contentTitle: 'contentTitle',
          liveStreamPrefetchMaxWaitTime: const Duration(seconds: 3),
          vastLoadTimeout: const Duration(milliseconds: 5000),
          contentProgressProvider: progressProvider,
        ),
      );

      verifyNever(mockAdsRequest.setAdsResponse(any));
      verifyInOrder(<Future<void>>[
        mockAdsRequest.setAdTagUrl('url'),
        mockAdsRequest.setAdWillAutoPlay(true),
        mockAdsRequest.setAdWillPlayMuted(false),
        mockAdsRequest.setContinuousPlayback(true),
        mockAdsRequest.setContentDuration(2.0),
        mockAdsRequest.setContentKeywords(<String>['keyword1', 'keyword2']),
        mockAdsRequest.setContentTitle('contentTitle'),
        mockAdsRequest.setLiveStreamPrefetchSeconds(3.0),
        mockAdsRequest.setVastLoadTimeout(5000.0),
        mockAdsRequest.setContentProgressProvider(
          progressProvider.progressProvider,
        ),
        mockAdsLoader.requestAds(mockAdsRequest),
      ]);
    });

    testWidgets('requestAds with adsResponse', (WidgetTester tester) async {
      final AndroidAdDisplayContainer container =
          await _pumpAdDisplayContainer(tester);

      final MockAdsLoader mockAdsLoader = MockAdsLoader();
      final MockAdsRequest mockAdsRequest = MockAdsRequest();
      _mockImaSdkFactoryInstance(
        adsRequest: mockAdsRequest,
        adsLoader: mockAdsLoader,
      );

      final InteractiveMediaAdsProxy proxy = InteractiveMediaAdsProxy(
        newContentProgressProvider: () =>
            ima.ContentProgressProvider.pigeon_detached(),
      );

      final AndroidAdsLoader adsLoader = AndroidAdsLoader(
        AndroidAdsLoaderCreationParams(
          container: container,
          settings: AndroidImaSettings(
            const PlatformImaSettingsCreationParams(),
          ),
          onAdsLoaded: (PlatformOnAdsLoadedData data) {},
          onAdsLoadError: (AdsLoadErrorData data) {},
          proxy: proxy,
        ),
      );

      final AndroidContentProgressProvider progressProvider =
          AndroidContentProgressProvider(
        AndroidContentProgressProviderCreationParams(proxy: proxy),
      );
      await adsLoader.requestAds(
        PlatformAdsRequest.withAdsResponse(
          adsResponse: 'url',
          adWillAutoPlay: true,
          adWillPlayMuted: false,
          continuousPlayback: true,
          contentDuration: const Duration(seconds: 2),
          contentKeywords: <String>['keyword1', 'keyword2'],
          contentTitle: 'contentTitle',
          liveStreamPrefetchMaxWaitTime: const Duration(seconds: 3),
          vastLoadTimeout: const Duration(milliseconds: 5000),
          contentProgressProvider: progressProvider,
        ),
      );

      verifyNever(mockAdsRequest.setAdTagUrl(any));
      verifyInOrder(<Future<void>>[
        mockAdsRequest.setAdsResponse('url'),
        mockAdsRequest.setAdWillAutoPlay(true),
        mockAdsRequest.setAdWillPlayMuted(false),
        mockAdsRequest.setContinuousPlayback(true),
        mockAdsRequest.setContentDuration(2.0),
        mockAdsRequest.setContentKeywords(<String>['keyword1', 'keyword2']),
        mockAdsRequest.setContentTitle('contentTitle'),
        mockAdsRequest.setLiveStreamPrefetchSeconds(3.0),
        mockAdsRequest.setVastLoadTimeout(5000.0),
        mockAdsRequest.setContentProgressProvider(
          progressProvider.progressProvider,
        ),
        mockAdsLoader.requestAds(mockAdsRequest),
      ]);
    });

    testWidgets('onAdsLoaded', (WidgetTester tester) async {
      final AndroidAdDisplayContainer container =
          await _pumpAdDisplayContainer(tester);

      final MockAdsLoader mockAdsLoader = MockAdsLoader();
      final Completer<void> addEventListenerCompleter = Completer<void>();
      when(mockAdsLoader.addAdsLoadedListener(any)).thenAnswer((_) async {
        addEventListenerCompleter.complete();
      });
      _mockImaSdkFactoryInstance(adsLoader: mockAdsLoader);

      late final void Function(
        ima.AdsLoadedListener,
        ima.AdsManagerLoadedEvent,
      ) onAdsManagerLoadedCallback;

      final InteractiveMediaAdsProxy proxy = InteractiveMediaAdsProxy(
        newAdsLoadedListener: ({
          required void Function(
            ima.AdsLoadedListener,
            ima.AdsManagerLoadedEvent,
          ) onAdsManagerLoaded,
        }) {
          onAdsManagerLoadedCallback = onAdsManagerLoaded;
          return MockAdsLoadedListener();
        },
        newAdErrorListener: ({required dynamic onAdError}) {
          return MockAdErrorListener();
        },
      );

      AndroidAdsLoader(
        AndroidAdsLoaderCreationParams(
          container: container,
          settings: AndroidImaSettings(
            const PlatformImaSettingsCreationParams(),
          ),
          onAdsLoaded: expectAsync1((_) {}),
          onAdsLoadError: (_) {},
          proxy: proxy,
        ),
      );

      final MockAdsManagerLoadedEvent mockLoadedEvent =
          MockAdsManagerLoadedEvent();
      when(mockLoadedEvent.manager).thenReturn(MockAdsManager());

      await addEventListenerCompleter.future;

      onAdsManagerLoadedCallback(MockAdsLoadedListener(), mockLoadedEvent);
    });

    testWidgets('onAdError', (WidgetTester tester) async {
      final AndroidAdDisplayContainer container =
          await _pumpAdDisplayContainer(tester);

      final MockAdsLoader mockAdsLoader = MockAdsLoader();
      final Completer<void> addErrorListenerCompleter = Completer<void>();
      when(mockAdsLoader.addAdErrorListener(any)).thenAnswer((_) async {
        addErrorListenerCompleter.complete();
      });
      _mockImaSdkFactoryInstance(adsLoader: mockAdsLoader);

      late final void Function(
        ima.AdErrorListener,
        ima.AdErrorEvent,
      ) onAdErrorCallback;

      final InteractiveMediaAdsProxy proxy = InteractiveMediaAdsProxy(
        newAdsLoadedListener: ({required dynamic onAdsManagerLoaded}) {
          return MockAdsLoadedListener();
        },
        newAdErrorListener: ({
          required void Function(
            ima.AdErrorListener,
            ima.AdErrorEvent,
          ) onAdError,
        }) {
          onAdErrorCallback = onAdError;
          return MockAdErrorListener();
        },
      );

      AndroidAdsLoader(
        AndroidAdsLoaderCreationParams(
          container: container,
          settings: AndroidImaSettings(
            const PlatformImaSettingsCreationParams(),
          ),
          onAdsLoaded: (_) {},
          onAdsLoadError: expectAsync1((_) {}),
          proxy: proxy,
        ),
      );

      final MockAdErrorEvent mockErrorEvent = MockAdErrorEvent();
      final MockAdError mockError = MockAdError();
      when(mockError.errorType).thenReturn(ima.AdErrorType.load);
      when(mockError.errorCode)
          .thenReturn(ima.AdErrorCode.adsRequestNetworkError);
      when(mockError.message).thenReturn('error message');
      when(mockErrorEvent.error).thenReturn(mockError);

      await addErrorListenerCompleter.future;

      onAdErrorCallback(MockAdErrorListener(), mockErrorEvent);
    });
  });
}

MockImaSdkFactory _mockImaSdkFactoryInstance({
  MockImaSdkSettings? imaSdkSettings,
  MockAdsRequest? adsRequest,
  MockAdsLoader? adsLoader,
}) {
  final MockImaSdkFactory mockSdkFactory = MockImaSdkFactory();
  when(mockSdkFactory.createImaSdkSettings()).thenAnswer((_) async {
    return imaSdkSettings ?? MockImaSdkSettings();
  });
  when(mockSdkFactory.createAdsRequest()).thenAnswer((_) async {
    return adsRequest ?? MockAdsRequest();
  });
  when(mockSdkFactory.createAdsLoader(any, any)).thenAnswer((_) async {
    return adsLoader ?? MockAdsLoader();
  });
  ima.PigeonOverrides.imaSdkFactory_instance = mockSdkFactory;
  return mockSdkFactory;
}

Future<AndroidAdDisplayContainer> _pumpAdDisplayContainer(
  WidgetTester tester, {
  MockVideoAdPlayerCallback? mockAdPlayerCallback,
}) async {
  final InteractiveMediaAdsProxy imaProxy = InteractiveMediaAdsProxy(
    newFrameLayout: () => MockFrameLayout(),
    newVideoView: ({
      required dynamic onError,
      dynamic onPrepared,
      dynamic onCompletion,
    }) =>
        MockVideoView(),
    createAdDisplayContainerImaSdkFactory: (
      _,
      __,
    ) async {
      return MockAdDisplayContainer();
    },
    newVideoAdPlayer: ({
      required void Function(
        ima.VideoAdPlayer,
        ima.VideoAdPlayerCallback,
      ) addCallback,
      required dynamic loadAd,
      required dynamic pauseAd,
      required dynamic playAd,
      required dynamic release,
      required dynamic removeCallback,
      required dynamic stopAd,
    }) {
      if (mockAdPlayerCallback != null) {
        addCallback(MockVideoAdPlayer(), mockAdPlayerCallback);
      }
      return MockVideoAdPlayer();
    },
  );

  final MockPlatformViewsServiceProxy mockPlatformViewsProxy =
      MockPlatformViewsServiceProxy();
  final MockSurfaceAndroidViewController mockAndroidViewController =
      MockSurfaceAndroidViewController();

  late final int platformViewId;
  when(
    mockPlatformViewsProxy.initSurfaceAndroidView(
      id: anyNamed('id'),
      viewType: anyNamed('viewType'),
      layoutDirection: anyNamed('layoutDirection'),
      creationParams: anyNamed('creationParams'),
      creationParamsCodec: anyNamed('creationParamsCodec'),
      onFocus: anyNamed('onFocus'),
    ),
  ).thenAnswer((Invocation invocation) {
    platformViewId = invocation.namedArguments[const Symbol('id')] as int;
    return mockAndroidViewController;
  });

  final Completer<AndroidAdDisplayContainer> adDisplayContainerCompleter =
      Completer<AndroidAdDisplayContainer>();

  final AndroidAdDisplayContainer container = AndroidAdDisplayContainer(
    AndroidAdDisplayContainerCreationParams(
      onContainerAdded: (PlatformAdDisplayContainer container) {
        adDisplayContainerCompleter.complete(
          container as AndroidAdDisplayContainer,
        );
      },
      platformViewsProxy: mockPlatformViewsProxy,
      imaProxy: imaProxy,
    ),
  );

  await tester.pumpWidget(Builder(
    builder: (BuildContext context) => container.build(context),
  ));

  final void Function(int) onPlatformCreatedCallback = verify(
          mockAndroidViewController
              .addOnPlatformViewCreatedListener(captureAny))
      .captured[0] as void Function(int);

  onPlatformCreatedCallback(platformViewId);

  return adDisplayContainerCompleter.future;
}
