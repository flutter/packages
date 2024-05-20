import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:interactive_media_ads/src/android/android_ad_display_container.dart';
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
    testWidgets('instantiate AndroidAdsLoader', (WidgetTester tester) async {
      final AndroidAdDisplayContainer container =
          await _pumpAdDisplayContainer(tester);

      AndroidAdsLoader(
        AndroidAdsLoaderCreationParams(
          container: container,
          onAdsLoaded: (PlatformOnAdsLoadedData data) {},
          onAdsLoadError: (AdsLoadErrorData data) {},
        ),
      );
    });

    testWidgets('contentComplete', (WidgetTester tester) async {
      final MockVideoAdPlayerCallback mockAdPlayerCallback =
          MockVideoAdPlayerCallback();
      final AndroidAdDisplayContainer container = await _pumpAdDisplayContainer(
          tester,
          mockAdPlayerCallback: mockAdPlayerCallback);

      final AndroidAdsLoader loader = AndroidAdsLoader(
        AndroidAdsLoaderCreationParams(
          container: container,
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

      final MockImaSdkFactory mockSdkFactory = MockImaSdkFactory();
      when(mockSdkFactory.createImaSdkSettings()).thenAnswer((_) async {
        return MockImaSdkSettings();
      });

      final MockAdsLoader mockAdsLoader = MockAdsLoader();
      when(mockSdkFactory.createAdsLoader(any, any)).thenAnswer((_) async {
        return mockAdsLoader;
      });

      final MockAdsRequest mockAdsRequest = MockAdsRequest();
      when(mockSdkFactory.createAdsRequest()).thenAnswer((_) async {
        return mockAdsRequest;
      });

      final InteractiveMediaAdsProxy proxy = InteractiveMediaAdsProxy(
        instanceImaSdkFactory: () => mockSdkFactory,
      );

      final AndroidAdsLoader adsLoader = AndroidAdsLoader(
        AndroidAdsLoaderCreationParams(
          container: container,
          onAdsLoaded: (PlatformOnAdsLoadedData data) {},
          onAdsLoadError: (AdsLoadErrorData data) {},
          proxy: proxy,
        ),
      );

      await adsLoader.requestAds(AdsRequest(adTagUrl: 'url'));

      verifyInOrder(<Future<void>>[
        mockAdsRequest.setAdTagUrl('url'),
        mockAdsLoader.requestAds(mockAdsRequest),
      ]);
    });

    testWidgets('onAdsLoaded', (WidgetTester tester) async {
      final AndroidAdDisplayContainer container =
          await _pumpAdDisplayContainer(tester);

      final MockImaSdkFactory mockSdkFactory = MockImaSdkFactory();
      when(mockSdkFactory.createImaSdkSettings()).thenAnswer((_) async {
        return MockImaSdkSettings();
      });

      final MockAdsLoader mockAdsLoader = MockAdsLoader();
      final Completer<void> addEventListenerCompleter = Completer<void>();
      when(mockAdsLoader.addAdsLoadedListener(any)).thenAnswer((_) async {
        addEventListenerCompleter.complete();
      });

      when(mockSdkFactory.createAdsLoader(any, any)).thenAnswer((_) async {
        return mockAdsLoader;
      });

      late final void Function(
        ima.AdsLoadedListener,
        ima.AdsManagerLoadedEvent,
      ) onAdsManagerLoadedCallback;

      final InteractiveMediaAdsProxy proxy = InteractiveMediaAdsProxy(
        instanceImaSdkFactory: () => mockSdkFactory,
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
          onAdsLoaded: expectAsync1((_) {}),
          onAdsLoadError: (AdsLoadErrorData data) {},
          proxy: proxy,
        ),
      );

      final MockAdsManagerLoadedEvent mockLoadedEvent = MockAdsManagerLoadedEvent();
      when(mockLoadedEvent.manager).thenReturn(MockAdsManager());

      await addEventListenerCompleter.future;

      onAdsManagerLoadedCallback(MockAdsLoadedListener(), mockLoadedEvent);
    });
  });
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
