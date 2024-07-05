// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:interactive_media_ads/src/ios/interactive_media_ads.g.dart';
import 'package:interactive_media_ads/src/ios/interactive_media_ads_proxy.dart';
import 'package:interactive_media_ads/src/ios/ios_ad_display_container.dart';
import 'package:interactive_media_ads/src/ios/ios_ads_loader.dart';
import 'package:interactive_media_ads/src/platform_interface/platform_interface.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'ads_loader_test.mocks.dart';

@GenerateNiceMocks(<MockSpec<Object>>[
  MockSpec<IMAAdDisplayContainer>(),
  MockSpec<IMAAdsLoader>(),
  MockSpec<IMAAdsRequest>(),
  MockSpec<UIView>(),
  MockSpec<UIViewController>(),
])
void main() {
  group('AndroidAdsLoader', () {
    testWidgets('instantiate IOSAdsLoader', (WidgetTester tester) async {
      final IOSAdDisplayContainer container =
          await _pumpAdDisplayContainer(tester);

      IOSAdsLoader(
        IOSAdsLoaderCreationParams(
          container: container,
          onAdsLoaded: (PlatformOnAdsLoadedData data) {},
          onAdsLoadError: (AdsLoadErrorData data) {},
        ),
      );
    });

    testWidgets('contentComplete', (WidgetTester tester) async {
      final IOSAdDisplayContainer container = await _pumpAdDisplayContainer(
        tester,
      );

      final MockIMAAdsLoader mockLoader = MockIMAAdsLoader();
      final InteractiveMediaAdsProxy imaProxy = InteractiveMediaAdsProxy(
        newIMAAdsLoader: ({IMASettings? settings}) => mockLoader,
      );

      final IOSAdsLoader loader = IOSAdsLoader(
        IOSAdsLoaderCreationParams(
          container: container,
          onAdsLoaded: (PlatformOnAdsLoadedData data) {},
          onAdsLoadError: (AdsLoadErrorData data) {},
          proxy: imaProxy,
        ),
      );

      await loader.contentComplete();
      verify(mockLoader.contentComplete());
    });

    testWidgets('requestAds', (WidgetTester tester) async {
      final IOSAdDisplayContainer container = await _pumpAdDisplayContainer(
        tester,
      );

      const String adTag = 'myAdTag';

      final MockIMAAdsLoader mockLoader = MockIMAAdsLoader();
      final InteractiveMediaAdsProxy imaProxy = InteractiveMediaAdsProxy(
        newIMAAdsLoader: ({IMASettings? settings}) => mockLoader,
        newIMAAdsRequest: ({
          required String adTagUrl,
          required IMAAdDisplayContainer adDisplayContainer,
          IMAContentPlayhead? contentPlayhead,
        }) {
          expect(adTagUrl, adTag);
          expect(adDisplayContainer, container.adDisplayContainer);
          return MockIMAAdsRequest();
        },
      );

      final IOSAdsLoader loader = IOSAdsLoader(
        IOSAdsLoaderCreationParams(
          container: container,
          onAdsLoaded: (PlatformOnAdsLoadedData data) {},
          onAdsLoadError: (AdsLoadErrorData data) {},
          proxy: imaProxy,
        ),
      );

      await loader.requestAds(AdsRequest(adTagUrl: adTag));

      verify(mockLoader.requestAds(any));
    });
    //
    // testWidgets('onAdsLoaded', (WidgetTester tester) async {
    //   final AndroidAdDisplayContainer container =
    //       await _pumpAdDisplayContainer(tester);
    //
    //   final MockImaSdkFactory mockSdkFactory = MockImaSdkFactory();
    //   when(mockSdkFactory.createImaSdkSettings()).thenAnswer((_) async {
    //     return MockImaSdkSettings();
    //   });
    //
    //   final MockAdsLoader mockAdsLoader = MockAdsLoader();
    //   final Completer<void> addEventListenerCompleter = Completer<void>();
    //   when(mockAdsLoader.addAdsLoadedListener(any)).thenAnswer((_) async {
    //     addEventListenerCompleter.complete();
    //   });
    //
    //   when(mockSdkFactory.createAdsLoader(any, any)).thenAnswer((_) async {
    //     return mockAdsLoader;
    //   });
    //
    //   late final void Function(
    //     ima.AdsLoadedListener,
    //     ima.AdsManagerLoadedEvent,
    //   ) onAdsManagerLoadedCallback;
    //
    //   final InteractiveMediaAdsProxy proxy = InteractiveMediaAdsProxy(
    //     instanceImaSdkFactory: () => mockSdkFactory,
    //     newAdsLoadedListener: ({
    //       required void Function(
    //         ima.AdsLoadedListener,
    //         ima.AdsManagerLoadedEvent,
    //       ) onAdsManagerLoaded,
    //     }) {
    //       onAdsManagerLoadedCallback = onAdsManagerLoaded;
    //       return MockAdsLoadedListener();
    //     },
    //     newAdErrorListener: ({required dynamic onAdError}) {
    //       return MockAdErrorListener();
    //     },
    //   );
    //
    //   AndroidAdsLoader(
    //     AndroidAdsLoaderCreationParams(
    //       container: container,
    //       onAdsLoaded: expectAsync1((_) {}),
    //       onAdsLoadError: (_) {},
    //       proxy: proxy,
    //     ),
    //   );
    //
    //   final MockAdsManagerLoadedEvent mockLoadedEvent =
    //       MockAdsManagerLoadedEvent();
    //   when(mockLoadedEvent.manager).thenReturn(MockAdsManager());
    //
    //   await addEventListenerCompleter.future;
    //
    //   onAdsManagerLoadedCallback(MockAdsLoadedListener(), mockLoadedEvent);
    // });
    //
    // testWidgets('onAdError', (WidgetTester tester) async {
    //   final AndroidAdDisplayContainer container =
    //       await _pumpAdDisplayContainer(tester);
    //
    //   final MockImaSdkFactory mockSdkFactory = MockImaSdkFactory();
    //   when(mockSdkFactory.createImaSdkSettings()).thenAnswer((_) async {
    //     return MockImaSdkSettings();
    //   });
    //
    //   final MockAdsLoader mockAdsLoader = MockAdsLoader();
    //   final Completer<void> addErrorListenerCompleter = Completer<void>();
    //   when(mockAdsLoader.addAdErrorListener(any)).thenAnswer((_) async {
    //     addErrorListenerCompleter.complete();
    //   });
    //
    //   when(mockSdkFactory.createAdsLoader(any, any)).thenAnswer((_) async {
    //     return mockAdsLoader;
    //   });
    //
    //   late final void Function(
    //     ima.AdErrorListener,
    //     ima.AdErrorEvent,
    //   ) onAdErrorCallback;
    //
    //   final InteractiveMediaAdsProxy proxy = InteractiveMediaAdsProxy(
    //     instanceImaSdkFactory: () => mockSdkFactory,
    //     newAdsLoadedListener: ({required dynamic onAdsManagerLoaded}) {
    //       return MockAdsLoadedListener();
    //     },
    //     newAdErrorListener: ({
    //       required void Function(
    //         ima.AdErrorListener,
    //         ima.AdErrorEvent,
    //       ) onAdError,
    //     }) {
    //       onAdErrorCallback = onAdError;
    //       return MockAdErrorListener();
    //     },
    //   );
    //
    //   AndroidAdsLoader(
    //     AndroidAdsLoaderCreationParams(
    //       container: container,
    //       onAdsLoaded: (_) {},
    //       onAdsLoadError: expectAsync1((_) {}),
    //       proxy: proxy,
    //     ),
    //   );
    //
    //   final MockAdErrorEvent mockErrorEvent = MockAdErrorEvent();
    //   final MockAdError mockError = MockAdError();
    //   when(mockError.errorType).thenReturn(ima.AdErrorType.load);
    //   when(mockError.errorCode)
    //       .thenReturn(ima.AdErrorCode.adsRequestNetworkError);
    //   when(mockError.message).thenReturn('error message');
    //   when(mockErrorEvent.error).thenReturn(mockError);
    //
    //   await addErrorListenerCompleter.future;
    //
    //   onAdErrorCallback(MockAdErrorListener(), mockErrorEvent);
    // });
  });
}

Future<IOSAdDisplayContainer> _pumpAdDisplayContainer(
    WidgetTester tester) async {
  final InteractiveMediaAdsProxy imaProxy = InteractiveMediaAdsProxy(
    newUIViewController: () {
      final PigeonInstanceManager instanceManager = PigeonInstanceManager(
        onWeakReferenceRemoved: (_) {},
      );
      final UIView view =
          UIView.pigeon_detached(pigeon_instanceManager: instanceManager);
      instanceManager.addDartCreatedInstance(view);

      final MockUIViewController mockController = MockUIViewController();
      when(mockController.view).thenReturn(view);
      return mockController;
    },
    newIMAAdDisplayContainer: ({
      required UIView adContainer,
      UIViewController? adContainerViewController,
    }) =>
        MockIMAAdDisplayContainer(),
  );

  final IOSAdDisplayContainer container = IOSAdDisplayContainer(
    IOSAdDisplayContainerCreationParams(
      onContainerAdded: expectAsync1((_) {}),
      imaProxy: imaProxy,
    ),
  );

  await tester.pumpWidget(Builder(
    builder: (BuildContext context) => container.build(context),
  ));

  final UiKitView view =
      find.byType(UiKitView).evaluate().single.widget as UiKitView;
  view.onPlatformViewCreated!.call(0);

  await tester.pumpAndSettle(const Duration(seconds: 1));

  return container;
}
