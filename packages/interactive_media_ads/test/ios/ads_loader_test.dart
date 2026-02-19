// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:interactive_media_ads/src/ios/interactive_media_ads.g.dart'
    as ima;
import 'package:interactive_media_ads/src/ios/ios_ad_display_container.dart';
import 'package:interactive_media_ads/src/ios/ios_ads_loader.dart';
import 'package:interactive_media_ads/src/ios/ios_content_progress_provider.dart';
import 'package:interactive_media_ads/src/ios/ios_ima_settings.dart';
import 'package:interactive_media_ads/src/platform_interface/platform_interface.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'ads_loader_test.mocks.dart';

@GenerateNiceMocks(<MockSpec<Object>>[
  MockSpec<ima.IMAAdDisplayContainer>(),
  MockSpec<ima.IMAAdsLoader>(),
  MockSpec<ima.IMAAdsLoaderDelegate>(),
  MockSpec<ima.IMAAdsManager>(),
  MockSpec<ima.IMAAdsRequest>(),
  MockSpec<ima.IMASettings>(),
  MockSpec<ima.UIView>(),
  MockSpec<ima.UIViewController>(),
])
void main() {
  setUp(() {
    ima.PigeonOverrides.pigeon_reset();
  });

  group('IOSAdsLoader', () {
    setUp(() {
      ima.PigeonOverrides.pigeon_reset();
    });

    testWidgets('instantiate IOSAdsLoader', (WidgetTester tester) async {
      final IOSAdDisplayContainer container = await _pumpAdDisplayContainer(
        tester,
      );

      IOSAdsLoader(
        IOSAdsLoaderCreationParams(
          container: container,
          settings: IOSImaSettings(const PlatformImaSettingsCreationParams()),
          onAdsLoaded: (PlatformOnAdsLoadedData data) {},
          onAdsLoadError: (AdsLoadErrorData data) {},
        ),
      );
    });

    testWidgets('contentComplete', (WidgetTester tester) async {
      final IOSAdDisplayContainer container = await _pumpAdDisplayContainer(
        tester,
      );

      ima.PigeonOverrides.iMASettings_new = () => MockIMASettings();

      final mockLoader = MockIMAAdsLoader();
      ima.PigeonOverrides.iMAAdsLoader_new = ({ima.IMASettings? settings}) =>
          mockLoader;

      final loader = IOSAdsLoader(
        IOSAdsLoaderCreationParams(
          container: container,
          settings: IOSImaSettings(const PlatformImaSettingsCreationParams()),
          onAdsLoaded: (PlatformOnAdsLoadedData data) {},
          onAdsLoadError: (AdsLoadErrorData data) {},
        ),
      );

      await loader.contentComplete();
      verify(mockLoader.contentComplete());
    });

    testWidgets('requestAds', (WidgetTester tester) async {
      final IOSAdDisplayContainer container = await _pumpAdDisplayContainer(
        tester,
      );

      ima.PigeonOverrides.iMASettings_new = () => MockIMASettings();

      const adTag = 'myAdTag';

      final mockLoader = MockIMAAdsLoader();
      final contentPlayheadInstance = ima.IMAContentPlayhead();
      final mockRequest = MockIMAAdsRequest();
      ima.PigeonOverrides.iMAAdsLoader_new = ({ima.IMASettings? settings}) =>
          mockLoader;
      ima.PigeonOverrides.iMAContentPlayhead_new = () =>
          contentPlayheadInstance;

      ima.PigeonOverrides.iMAAdsRequest_new =
          ({
            required String adTagUrl,
            required ima.IMAAdDisplayContainer adDisplayContainer,
            ima.IMAContentPlayhead? contentPlayhead,
          }) {
            expect(adTagUrl, adTag);
            expect(adDisplayContainer, container.adDisplayContainer);
            expect(contentPlayhead, contentPlayheadInstance);
            return mockRequest;
          };

      final loader = IOSAdsLoader(
        IOSAdsLoaderCreationParams(
          container: container,
          settings: IOSImaSettings(const PlatformImaSettingsCreationParams()),
          onAdsLoaded: (PlatformOnAdsLoadedData data) {},
          onAdsLoadError: (AdsLoadErrorData data) {},
        ),
      );

      final provider = IOSContentProgressProvider(
        const PlatformContentProgressProviderCreationParams(),
      );

      await loader.requestAds(
        PlatformAdsRequest.withAdTagUrl(
          adTagUrl: adTag,
          adWillAutoPlay: true,
          adWillPlayMuted: false,
          continuousPlayback: true,
          contentDuration: const Duration(seconds: 2),
          contentKeywords: <String>['keyword1', 'keyword2'],
          contentTitle: 'contentTitle',
          liveStreamPrefetchMaxWaitTime: const Duration(seconds: 3),
          vastLoadTimeout: const Duration(milliseconds: 5000),
          contentProgressProvider: provider,
        ),
      );

      verify(mockRequest.setAdWillAutoPlay(true));
      verify(mockRequest.setAdWillPlayMuted(false));
      verify(mockRequest.setContinuousPlayback(true));
      verify(mockRequest.setContentDuration(2.0));
      verify(mockRequest.setContentKeywords(<String>['keyword1', 'keyword2']));
      verify(mockRequest.setContentTitle('contentTitle'));
      verify(mockRequest.setLiveStreamPrefetchSeconds(3.0));
      verify(mockRequest.setVastLoadTimeout(5000.0));

      verify(mockLoader.requestAds(any));
    });

    testWidgets('onAdsLoaded', (WidgetTester tester) async {
      final IOSAdDisplayContainer container = await _pumpAdDisplayContainer(
        tester,
      );

      ima.PigeonOverrides.iMASettings_new = () => MockIMASettings();

      late final void Function(
        ima.IMAAdsLoaderDelegate,
        ima.IMAAdsLoader,
        ima.IMAAdsLoadedData,
      )
      adLoaderLoadedWithCallback;

      ima.PigeonOverrides.iMAAdsLoader_new = ({ima.IMASettings? settings}) =>
          MockIMAAdsLoader();
      ima.PigeonOverrides.iMAAdsLoaderDelegate_new =
          ({
            required void Function(
              ima.IMAAdsLoaderDelegate,
              ima.IMAAdsLoader,
              ima.IMAAdsLoadedData,
            )
            adLoaderLoadedWith,
            required dynamic adsLoaderFailedWithErrorData,
          }) {
            adLoaderLoadedWithCallback = adLoaderLoadedWith;
            return MockIMAAdsLoaderDelegate();
          };

      final adsLoader = IOSAdsLoader(
        IOSAdsLoaderCreationParams(
          container: container,
          settings: IOSImaSettings(const PlatformImaSettingsCreationParams()),
          onAdsLoaded: expectAsync1((_) {}),
          onAdsLoadError: (AdsLoadErrorData data) {},
        ),
      );
      // Trigger lazy initialization of native IMAAdsLoader
      await adsLoader.contentComplete();

      adLoaderLoadedWithCallback(
        MockIMAAdsLoaderDelegate(),
        MockIMAAdsLoader(),
        ima.IMAAdsLoadedData.pigeon_detached(adsManager: MockIMAAdsManager()),
      );
    });

    testWidgets('onAdsLoadError', (WidgetTester tester) async {
      final IOSAdDisplayContainer container = await _pumpAdDisplayContainer(
        tester,
      );

      ima.PigeonOverrides.iMASettings_new = () => MockIMASettings();

      late final void Function(
        ima.IMAAdsLoaderDelegate,
        ima.IMAAdsLoader,
        ima.IMAAdLoadingErrorData,
      )
      adsLoaderFailedWithErrorDataCallback;

      ima.PigeonOverrides.iMAAdsLoader_new = ({ima.IMASettings? settings}) =>
          MockIMAAdsLoader();
      ima.PigeonOverrides.iMAAdsLoaderDelegate_new =
          ({
            required dynamic adLoaderLoadedWith,
            required void Function(
              ima.IMAAdsLoaderDelegate,
              ima.IMAAdsLoader,
              ima.IMAAdLoadingErrorData,
            )
            adsLoaderFailedWithErrorData,
          }) {
            adsLoaderFailedWithErrorDataCallback = adsLoaderFailedWithErrorData;
            return MockIMAAdsLoaderDelegate();
          };

      final adsLoader = IOSAdsLoader(
        IOSAdsLoaderCreationParams(
          container: container,
          settings: IOSImaSettings(const PlatformImaSettingsCreationParams()),
          onAdsLoaded: (PlatformOnAdsLoadedData data) {},
          onAdsLoadError: expectAsync1((AdsLoadErrorData data) {
            expect(data.error.type, AdErrorType.loading);
            expect(data.error.code, AdErrorCode.apiError);
          }),
        ),
      );
      // Trigger lazy initialization of native IMAAdsLoader
      await adsLoader.contentComplete();

      adsLoaderFailedWithErrorDataCallback(
        MockIMAAdsLoaderDelegate(),
        MockIMAAdsLoader(),
        ima.IMAAdLoadingErrorData.pigeon_detached(
          adError: ima.IMAAdError.pigeon_detached(
            type: ima.AdErrorType.loadingFailed,
            code: ima.AdErrorCode.apiError,
          ),
        ),
      );
    });
  });
}

Future<IOSAdDisplayContainer> _pumpAdDisplayContainer(
  WidgetTester tester,
) async {
  ima.PigeonOverrides.uIViewController_new =
      ({void Function(ima.UIViewController, bool)? viewDidAppear}) {
        final view = ima.UIView.pigeon_detached();
        ima.PigeonInstanceManager.instance.addDartCreatedInstance(view);

        final mockController = MockUIViewController();
        viewDidAppear!.call(mockController, true);
        when(mockController.view).thenReturn(view);
        return mockController;
      };
  ima.PigeonOverrides.iMAAdDisplayContainer_new =
      ({
        required ima.UIView adContainer,
        ima.UIViewController? adContainerViewController,
        List<ima.IMACompanionAdSlot>? companionSlots,
      }) => MockIMAAdDisplayContainer();

  final container = IOSAdDisplayContainer(
    IOSAdDisplayContainerCreationParams(onContainerAdded: expectAsync1((_) {})),
  );

  await tester.pumpWidget(
    Builder(builder: (BuildContext context) => container.build(context)),
  );

  final view = find.byType(UiKitView).evaluate().single.widget as UiKitView;
  view.onPlatformViewCreated!.call(0);

  await tester.pumpAndSettle(const Duration(seconds: 1));

  return container;
}
