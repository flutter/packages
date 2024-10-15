// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:interactive_media_ads/src/android/android_ad_display_container.dart';
import 'package:interactive_media_ads/src/android/interactive_media_ads.g.dart'
    as ima;
import 'package:interactive_media_ads/src/android/interactive_media_ads_proxy.dart';
import 'package:interactive_media_ads/src/android/platform_views_service_proxy.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'ad_display_container_test.mocks.dart';

@GenerateNiceMocks(<MockSpec<Object>>[
  MockSpec<ima.AdDisplayContainer>(),
  MockSpec<ima.AdMediaInfo>(),
  MockSpec<ima.AdPodInfo>(),
  MockSpec<ima.FrameLayout>(),
  MockSpec<ima.MediaPlayer>(),
  MockSpec<ima.VideoAdPlayer>(),
  MockSpec<ima.VideoAdPlayerCallback>(),
  MockSpec<ima.VideoProgressUpdate>(),
  MockSpec<ima.VideoView>(),
  MockSpec<SurfaceAndroidViewController>(),
  MockSpec<PlatformViewsServiceProxy>(),
])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AndroidAdDisplayContainer', () {
    testWidgets('build with key', (WidgetTester tester) async {
      final AndroidAdDisplayContainer container = AndroidAdDisplayContainer(
        AndroidAdDisplayContainerCreationParams(
          key: const Key('testKey'),
          onContainerAdded: (_) {},
        ),
      );

      await tester.pumpWidget(Builder(
        builder: (BuildContext context) => container.build(context),
      ));

      expect(find.byType(PlatformViewLink), findsOneWidget);
      expect(find.byKey(const Key('testKey')), findsOneWidget);
    });

    testWidgets('onContainerAdded is called', (WidgetTester tester) async {
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
          required dynamic addCallback,
          required dynamic loadAd,
          required dynamic pauseAd,
          required dynamic playAd,
          required dynamic release,
          required dynamic removeCallback,
          required dynamic stopAd,
        }) =>
            MockVideoAdPlayer(),
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

      final AndroidAdDisplayContainer container = AndroidAdDisplayContainer(
        AndroidAdDisplayContainerCreationParams(
          onContainerAdded: expectAsync1((_) {}),
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

      await tester.pumpAndSettle();
    });

    test('completing the ad notifies IMA SDK the ad has ended', () {
      late final void Function(
        ima.VideoAdPlayer,
        ima.AdMediaInfo,
        ima.AdPodInfo,
      ) loadAdCallback;

      late final void Function(
        ima.VideoAdPlayer,
        ima.VideoAdPlayerCallback,
      ) addCallbackCallback;

      late final void Function(
        ima.VideoView,
        ima.MediaPlayer,
      ) onCompletionCallback;

      final InteractiveMediaAdsProxy imaProxy = InteractiveMediaAdsProxy(
        newFrameLayout: () => MockFrameLayout(),
        newVideoView: ({
          required dynamic onError,
          dynamic onPrepared,
          void Function(
            ima.VideoView,
            ima.MediaPlayer,
          )? onCompletion,
        }) {
          onCompletionCallback = onCompletion!;
          return MockVideoView();
        },
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
          required void Function(
            ima.VideoAdPlayer,
            ima.AdMediaInfo,
            ima.AdPodInfo,
          ) loadAd,
          required dynamic pauseAd,
          required dynamic playAd,
          required dynamic release,
          required dynamic removeCallback,
          required dynamic stopAd,
        }) {
          loadAdCallback = loadAd;
          addCallbackCallback = addCallback;
          return MockVideoAdPlayer();
        },
      );

      AndroidAdDisplayContainer(
        AndroidAdDisplayContainerCreationParams(
          onContainerAdded: (_) {},
          imaProxy: imaProxy,
        ),
      );

      final ima.AdMediaInfo mockAdMediaInfo = MockAdMediaInfo();
      loadAdCallback(MockVideoAdPlayer(), mockAdMediaInfo, MockAdPodInfo());

      final MockVideoAdPlayerCallback mockPlayerCallback =
          MockVideoAdPlayerCallback();
      addCallbackCallback(MockVideoAdPlayer(), mockPlayerCallback);

      onCompletionCallback(MockVideoView(), MockMediaPlayer());

      verify(mockPlayerCallback.onEnded(mockAdMediaInfo));
    });

    test('error loading the ad notifies IMA SDK of error', () {
      late final void Function(
        ima.VideoAdPlayer,
        ima.AdMediaInfo,
        ima.AdPodInfo,
      ) loadAdCallback;

      late final void Function(
        ima.VideoAdPlayer,
        ima.VideoAdPlayerCallback,
      ) addCallbackCallback;

      late final void Function(
        ima.VideoView,
        ima.MediaPlayer,
        int,
        int,
      ) onErrorCallback;

      final InteractiveMediaAdsProxy imaProxy = InteractiveMediaAdsProxy(
        newFrameLayout: () => MockFrameLayout(),
        newVideoView: ({
          required void Function(
            ima.VideoView,
            ima.MediaPlayer,
            int,
            int,
          ) onError,
          dynamic onPrepared,
          dynamic onCompletion,
        }) {
          onErrorCallback = onError;
          return MockVideoView();
        },
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
          required void Function(
            ima.VideoAdPlayer,
            ima.AdMediaInfo,
            ima.AdPodInfo,
          ) loadAd,
          required dynamic pauseAd,
          required dynamic playAd,
          required dynamic release,
          required dynamic removeCallback,
          required dynamic stopAd,
        }) {
          loadAdCallback = loadAd;
          addCallbackCallback = addCallback;
          return MockVideoAdPlayer();
        },
      );

      AndroidAdDisplayContainer(
        AndroidAdDisplayContainerCreationParams(
          onContainerAdded: (_) {},
          imaProxy: imaProxy,
        ),
      );

      final ima.AdMediaInfo mockAdMediaInfo = MockAdMediaInfo();
      loadAdCallback(MockVideoAdPlayer(), mockAdMediaInfo, MockAdPodInfo());

      final MockVideoAdPlayerCallback mockPlayerCallback =
          MockVideoAdPlayerCallback();
      addCallbackCallback(MockVideoAdPlayer(), mockPlayerCallback);

      onErrorCallback(MockVideoView(), MockMediaPlayer(), 0, 0);

      verify(mockPlayerCallback.onError(mockAdMediaInfo));
    });

    test('play ad once when it is prepared', () async {
      late final void Function(
        ima.VideoAdPlayer,
        ima.AdMediaInfo,
        ima.AdPodInfo,
      ) loadAdCallback;

      late final void Function(
        ima.VideoAdPlayer,
        ima.VideoAdPlayerCallback,
      ) addCallbackCallback;

      late final Future<void> Function(
        ima.VideoView,
        ima.MediaPlayer,
      ) onPreparedCallback;

      const int adDuration = 100;
      const int adProgress = 10;

      final InteractiveMediaAdsProxy imaProxy = InteractiveMediaAdsProxy(
        newFrameLayout: () => MockFrameLayout(),
        newVideoView: ({
          dynamic onError,
          dynamic onPrepared,
          dynamic onCompletion,
        }) {
          // VideoView.onPrepared returns void, but the implementation uses an
          // async callback method.
          onPreparedCallback = onPrepared! as Future<void> Function(
            ima.VideoView,
            ima.MediaPlayer,
          );
          final MockVideoView mockVideoView = MockVideoView();
          when(mockVideoView.getCurrentPosition()).thenAnswer(
            (_) async => adProgress,
          );
          return mockVideoView;
        },
        createAdDisplayContainerImaSdkFactory: (_, __) async {
          return MockAdDisplayContainer();
        },
        newVideoAdPlayer: ({
          required void Function(
            ima.VideoAdPlayer,
            ima.VideoAdPlayerCallback,
          ) addCallback,
          required void Function(
            ima.VideoAdPlayer,
            ima.AdMediaInfo,
            ima.AdPodInfo,
          ) loadAd,
          required dynamic pauseAd,
          required dynamic playAd,
          required dynamic release,
          required dynamic removeCallback,
          required dynamic stopAd,
        }) {
          loadAdCallback = loadAd;
          addCallbackCallback = addCallback;
          return MockVideoAdPlayer();
        },
        newVideoProgressUpdate: ({
          required int currentTimeMs,
          required int durationMs,
        }) {
          expect(currentTimeMs, adProgress);
          expect(durationMs, adDuration);
          return MockVideoProgressUpdate();
        },
      );

      AndroidAdDisplayContainer(
        AndroidAdDisplayContainerCreationParams(
          onContainerAdded: (_) {},
          imaProxy: imaProxy,
        ),
      );

      final ima.AdMediaInfo mockAdMediaInfo = MockAdMediaInfo();
      loadAdCallback(MockVideoAdPlayer(), mockAdMediaInfo, MockAdPodInfo());

      final MockVideoAdPlayerCallback mockPlayerCallback =
          MockVideoAdPlayerCallback();
      addCallbackCallback(MockVideoAdPlayer(), mockPlayerCallback);

      final MockMediaPlayer mockMediaPlayer = MockMediaPlayer();
      when(mockMediaPlayer.getDuration()).thenAnswer((_) async => adDuration);

      await onPreparedCallback(MockVideoView(), mockMediaPlayer);

      verify(mockMediaPlayer.start());

      // Ad progress is updated with a reoccurring timer, so this waits for
      // at least one update.
      await Future<void>.delayed(const Duration(milliseconds: 300));
      verify(mockPlayerCallback.onAdProgress(mockAdMediaInfo, any));
    });

    test('pause ad', () async {
      late final void Function(
        ima.VideoAdPlayer,
        ima.AdMediaInfo,
        ima.AdPodInfo,
      ) loadAdCallback;

      late final Future<void> Function(
        ima.VideoView,
        ima.MediaPlayer,
      ) onPreparedCallback;

      late final Future<void> Function(
        ima.VideoAdPlayer,
        ima.AdMediaInfo,
      ) pauseAdCallback;

      final InteractiveMediaAdsProxy imaProxy = InteractiveMediaAdsProxy(
        newFrameLayout: () => MockFrameLayout(),
        newVideoView: ({
          dynamic onError,
          void Function(
            ima.VideoView,
            ima.MediaPlayer,
          )? onPrepared,
          dynamic onCompletion,
        }) {
          // VideoView.onPrepared returns void, but the implementation uses an
          // async callback method.
          onPreparedCallback = onPrepared! as Future<void> Function(
            ima.VideoView,
            ima.MediaPlayer,
          );
          final MockVideoView mockVideoView = MockVideoView();
          when(mockVideoView.getCurrentPosition()).thenAnswer((_) async => 10);
          return mockVideoView;
        },
        createAdDisplayContainerImaSdkFactory: (_, __) async {
          return MockAdDisplayContainer();
        },
        newVideoAdPlayer: ({
          required dynamic addCallback,
          required void Function(
            ima.VideoAdPlayer,
            ima.AdMediaInfo,
            ima.AdPodInfo,
          ) loadAd,
          required dynamic pauseAd,
          required dynamic playAd,
          required dynamic release,
          required dynamic removeCallback,
          required dynamic stopAd,
        }) {
          loadAdCallback = loadAd;
          // VideoAdPlayer.pauseAd returns void, but the implementation uses an
          // async callback method.
          pauseAdCallback = pauseAd as Future<void> Function(
            ima.VideoAdPlayer,
            ima.AdMediaInfo,
          );
          return MockVideoAdPlayer();
        },
        newVideoProgressUpdate: ({
          required int currentTimeMs,
          required int durationMs,
        }) {
          return MockVideoProgressUpdate();
        },
      );

      AndroidAdDisplayContainer(
        AndroidAdDisplayContainerCreationParams(
          onContainerAdded: (_) {},
          imaProxy: imaProxy,
        ),
      );

      final ima.AdMediaInfo mockAdMediaInfo = MockAdMediaInfo();
      loadAdCallback(MockVideoAdPlayer(), mockAdMediaInfo, MockAdPodInfo());

      final MockMediaPlayer mockMediaPlayer = MockMediaPlayer();
      when(mockMediaPlayer.getDuration()).thenAnswer((_) async => 100);

      await onPreparedCallback(MockVideoView(), mockMediaPlayer);

      await pauseAdCallback(MockVideoAdPlayer(), mockAdMediaInfo);

      verify(mockMediaPlayer.pause());
    });

    test('ad does not play automatically after calling pause', () async {
      late final void Function(
        ima.VideoAdPlayer,
        ima.AdMediaInfo,
        ima.AdPodInfo,
      ) loadAdCallback;

      late final Future<void> Function(
        ima.VideoView,
        ima.MediaPlayer,
      ) onPreparedCallback;

      late final Future<void> Function(
        ima.VideoAdPlayer,
        ima.AdMediaInfo,
      ) pauseAdCallback;

      late final void Function(
        ima.VideoAdPlayer,
        ima.AdMediaInfo,
      ) playAdCallback;

      final InteractiveMediaAdsProxy imaProxy = InteractiveMediaAdsProxy(
        newFrameLayout: () => MockFrameLayout(),
        newVideoView: ({
          dynamic onError,
          void Function(
            ima.VideoView,
            ima.MediaPlayer,
          )? onPrepared,
          dynamic onCompletion,
        }) {
          // VideoView.onPrepared returns void, but the implementation uses an
          // async callback method.
          onPreparedCallback = onPrepared! as Future<void> Function(
            ima.VideoView,
            ima.MediaPlayer,
          );
          final MockVideoView mockVideoView = MockVideoView();
          when(mockVideoView.getCurrentPosition()).thenAnswer((_) async => 10);
          return mockVideoView;
        },
        createAdDisplayContainerImaSdkFactory: (_, __) async {
          return MockAdDisplayContainer();
        },
        newVideoAdPlayer: ({
          required dynamic addCallback,
          required void Function(
            ima.VideoAdPlayer,
            ima.AdMediaInfo,
            ima.AdPodInfo,
          ) loadAd,
          required dynamic pauseAd,
          required void Function(
            ima.VideoAdPlayer,
            ima.AdMediaInfo,
          ) playAd,
          required dynamic release,
          required dynamic removeCallback,
          required dynamic stopAd,
        }) {
          loadAdCallback = loadAd;
          // VideoAdPlayer.pauseAd returns void, but the implementation uses an
          // async callback method.
          pauseAdCallback = pauseAd as Future<void> Function(
            ima.VideoAdPlayer,
            ima.AdMediaInfo,
          );
          playAdCallback = playAd;
          return MockVideoAdPlayer();
        },
        newVideoProgressUpdate: ({
          required int currentTimeMs,
          required int durationMs,
        }) {
          return MockVideoProgressUpdate();
        },
      );

      AndroidAdDisplayContainer(
        AndroidAdDisplayContainerCreationParams(
          onContainerAdded: (_) {},
          imaProxy: imaProxy,
        ),
      );

      final ima.AdMediaInfo mockAdMediaInfo = MockAdMediaInfo();
      when(mockAdMediaInfo.url).thenReturn('url');
      loadAdCallback(MockVideoAdPlayer(), mockAdMediaInfo, MockAdPodInfo());

      final MockMediaPlayer mockMediaPlayer = MockMediaPlayer();
      when(mockMediaPlayer.getDuration()).thenAnswer((_) async => 100);

      await onPreparedCallback(MockVideoView(), mockMediaPlayer);

      // Pausing the ad prevents Ad from starting again automatically when it is
      // prepared.
      await pauseAdCallback(MockVideoAdPlayer(), mockAdMediaInfo);
      reset(mockMediaPlayer);
      await onPreparedCallback(MockVideoView(), mockMediaPlayer);
      verifyNever(mockMediaPlayer.start());

      // The playAd callback allows the Ad to start automatically once it is
      // prepared.
      playAdCallback(MockVideoAdPlayer(), mockAdMediaInfo);
      await onPreparedCallback(MockVideoView(), mockMediaPlayer);
      verify(mockMediaPlayer.start());
    });

    test('play ad', () async {
      late final void Function(
        ima.VideoAdPlayer,
        ima.AdMediaInfo,
      ) playAdCallback;

      final MockVideoView mockVideoView = MockVideoView();
      final InteractiveMediaAdsProxy imaProxy = InteractiveMediaAdsProxy(
        newFrameLayout: () => MockFrameLayout(),
        newVideoView: ({
          dynamic onError,
          dynamic onPrepared,
          dynamic onCompletion,
        }) {
          return mockVideoView;
        },
        createAdDisplayContainerImaSdkFactory: (_, __) async {
          return MockAdDisplayContainer();
        },
        newVideoAdPlayer: ({
          required dynamic addCallback,
          required dynamic loadAd,
          required dynamic pauseAd,
          required void Function(
            ima.VideoAdPlayer,
            ima.AdMediaInfo,
          ) playAd,
          required dynamic release,
          required dynamic removeCallback,
          required dynamic stopAd,
        }) {
          playAdCallback = playAd;
          return MockVideoAdPlayer();
        },
      );

      AndroidAdDisplayContainer(
        AndroidAdDisplayContainerCreationParams(
          onContainerAdded: (_) {},
          imaProxy: imaProxy,
        ),
      );

      const String videoUrl = 'url';
      final ima.AdMediaInfo mockAdMediaInfo = MockAdMediaInfo();
      when(mockAdMediaInfo.url).thenReturn(videoUrl);
      playAdCallback(MockVideoAdPlayer(), mockAdMediaInfo);

      verify(mockVideoView.setVideoUri(videoUrl));
    });

    test('stop ad creates and sets a new VideoView', () async {
      late final void Function(
        ima.VideoAdPlayer,
        ima.AdMediaInfo,
      ) stopAdCallback;

      final MockFrameLayout mockFrameLayout = MockFrameLayout();
      late final MockVideoView mockVideoView = MockVideoView();
      late final MockVideoView mockVideoView2 = MockVideoView();
      int newViewVideoCallCount = 0;
      final InteractiveMediaAdsProxy imaProxy = InteractiveMediaAdsProxy(
        newFrameLayout: () => mockFrameLayout,
        newVideoView: ({
          dynamic onError,
          dynamic onPrepared,
          dynamic onCompletion,
        }) {
          switch (newViewVideoCallCount) {
            case 0:
              newViewVideoCallCount++;
              return mockVideoView;
            case 1:
              newViewVideoCallCount++;
              return mockVideoView2;
            default:
              fail('newVideoView was called too many times');
          }
        },
        createAdDisplayContainerImaSdkFactory: (_, __) async {
          return MockAdDisplayContainer();
        },
        newVideoAdPlayer: ({
          required dynamic addCallback,
          required dynamic loadAd,
          required dynamic pauseAd,
          required dynamic playAd,
          required dynamic release,
          required dynamic removeCallback,
          required void Function(ima.VideoAdPlayer, ima.AdMediaInfo) stopAd,
        }) {
          stopAdCallback = stopAd;
          return MockVideoAdPlayer();
        },
      );

      AndroidAdDisplayContainer(
        AndroidAdDisplayContainerCreationParams(
          onContainerAdded: (_) {},
          imaProxy: imaProxy,
        ),
      );

      stopAdCallback(MockVideoAdPlayer(), MockAdMediaInfo());

      verify(mockFrameLayout.removeView(mockVideoView));
      verify(mockFrameLayout.addView(mockVideoView2));
    });
  });
}
