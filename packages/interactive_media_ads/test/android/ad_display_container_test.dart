// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:interactive_media_ads/src/android/android_ad_display_container.dart';
import 'package:interactive_media_ads/src/android/android_companion_ad_slot.dart';
import 'package:interactive_media_ads/src/android/interactive_media_ads.g.dart'
    as ima;
import 'package:interactive_media_ads/src/android/platform_views_service_proxy.dart';
import 'package:interactive_media_ads/src/platform_interface/platform_interface.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'ad_display_container_test.mocks.dart';

@GenerateNiceMocks(<MockSpec<Object>>[
  MockSpec<ima.AdDisplayContainer>(),
  MockSpec<ima.AdMediaInfo>(),
  MockSpec<ima.AdPodInfo>(),
  MockSpec<ima.CompanionAdSlot>(),
  MockSpec<ima.FrameLayout>(),
  MockSpec<ima.ImaSdkFactory>(),
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

  setUp(() {
    ima.PigeonOverrides.pigeon_reset();
  });

  group('AndroidAdDisplayContainer', () {
    testWidgets('build with key', (WidgetTester tester) async {
      final container = AndroidAdDisplayContainer(
        AndroidAdDisplayContainerCreationParams(
          key: const Key('testKey'),
          onContainerAdded: (_) {},
        ),
      );

      await tester.pumpWidget(
        Builder(builder: (BuildContext context) => container.build(context)),
      );

      expect(find.byType(PlatformViewLink), findsOneWidget);
      expect(find.byKey(const Key('testKey')), findsOneWidget);
    });

    testWidgets('onContainerAdded is called', (WidgetTester tester) async {
      ima.PigeonOverrides.frameLayout_new = () => MockFrameLayout();
      ima.PigeonOverrides.videoView_new =
          ({
            required dynamic onError,
            dynamic onPrepared,
            dynamic onCompletion,
          }) => MockVideoView();
      ima.PigeonOverrides.imaSdkFactory_createAdDisplayContainer =
          (_, __) async {
            return MockAdDisplayContainer();
          };
      ima.PigeonOverrides.videoAdPlayer_new =
          ({
            required dynamic addCallback,
            required dynamic loadAd,
            required dynamic pauseAd,
            required dynamic playAd,
            required dynamic release,
            required dynamic removeCallback,
            required dynamic stopAd,
          }) => MockVideoAdPlayer();

      final mockPlatformViewsProxy = MockPlatformViewsServiceProxy();
      final mockAndroidViewController = MockSurfaceAndroidViewController();

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

      final container = AndroidAdDisplayContainer(
        AndroidAdDisplayContainerCreationParams(
          onContainerAdded: expectAsync1((_) {}),
          platformViewsProxy: mockPlatformViewsProxy,
        ),
      );

      await tester.pumpWidget(
        Builder(builder: (BuildContext context) => container.build(context)),
      );

      final onPlatformCreatedCallback =
          verify(
                mockAndroidViewController.addOnPlatformViewCreatedListener(
                  captureAny,
                ),
              ).captured[0]
              as void Function(int);

      onPlatformCreatedCallback(platformViewId);

      await tester.pumpAndSettle();
    });

    test('completing the ad notifies IMA SDK the ad has ended', () {
      late final void Function(
        ima.VideoAdPlayer,
        ima.AdMediaInfo,
        ima.AdPodInfo,
      )
      loadAdCallback;

      late final void Function(ima.VideoAdPlayer, ima.VideoAdPlayerCallback)
      addCallbackCallback;

      late final void Function(ima.VideoView, ima.MediaPlayer)
      onCompletionCallback;

      ima.PigeonOverrides.frameLayout_new = () => MockFrameLayout();
      ima.PigeonOverrides.videoView_new =
          ({
            required dynamic onError,
            dynamic onPrepared,
            void Function(ima.VideoView, ima.MediaPlayer)? onCompletion,
          }) {
            onCompletionCallback = onCompletion!;
            return MockVideoView();
          };
      ima.PigeonOverrides.imaSdkFactory_createAdDisplayContainer =
          (_, __) async {
            return MockAdDisplayContainer();
          };
      ima.PigeonOverrides.videoAdPlayer_new =
          ({
            required void Function(ima.VideoAdPlayer, ima.VideoAdPlayerCallback)
            addCallback,
            required void Function(
              ima.VideoAdPlayer,
              ima.AdMediaInfo,
              ima.AdPodInfo,
            )
            loadAd,
            required dynamic pauseAd,
            required dynamic playAd,
            required dynamic release,
            required dynamic removeCallback,
            required dynamic stopAd,
          }) {
            loadAdCallback = loadAd;
            addCallbackCallback = addCallback;
            return MockVideoAdPlayer();
          };

      AndroidAdDisplayContainer(
        AndroidAdDisplayContainerCreationParams(onContainerAdded: (_) {}),
      );

      final ima.AdMediaInfo mockAdMediaInfo = MockAdMediaInfo();
      loadAdCallback(MockVideoAdPlayer(), mockAdMediaInfo, MockAdPodInfo());

      final mockPlayerCallback = MockVideoAdPlayerCallback();
      addCallbackCallback(MockVideoAdPlayer(), mockPlayerCallback);

      onCompletionCallback(MockVideoView(), MockMediaPlayer());

      verify(mockPlayerCallback.onEnded(mockAdMediaInfo));
    });

    test('error loading the ad notifies IMA SDK of error', () {
      late final void Function(
        ima.VideoAdPlayer,
        ima.AdMediaInfo,
        ima.AdPodInfo,
      )
      loadAdCallback;

      late final void Function(ima.VideoAdPlayer, ima.VideoAdPlayerCallback)
      addCallbackCallback;

      late final void Function(ima.VideoView, ima.MediaPlayer, int, int)
      onErrorCallback;

      ima.PigeonOverrides.frameLayout_new = () => MockFrameLayout();
      ima.PigeonOverrides.videoView_new =
          ({
            required void Function(ima.VideoView, ima.MediaPlayer, int, int)
            onError,
            dynamic onPrepared,
            dynamic onCompletion,
          }) {
            onErrorCallback = onError;
            return MockVideoView();
          };
      ima.PigeonOverrides.imaSdkFactory_createAdDisplayContainer =
          (_, __) async {
            return MockAdDisplayContainer();
          };
      ima.PigeonOverrides.videoAdPlayer_new =
          ({
            required void Function(ima.VideoAdPlayer, ima.VideoAdPlayerCallback)
            addCallback,
            required void Function(
              ima.VideoAdPlayer,
              ima.AdMediaInfo,
              ima.AdPodInfo,
            )
            loadAd,
            required dynamic pauseAd,
            required dynamic playAd,
            required dynamic release,
            required dynamic removeCallback,
            required dynamic stopAd,
          }) {
            loadAdCallback = loadAd;
            addCallbackCallback = addCallback;
            return MockVideoAdPlayer();
          };

      AndroidAdDisplayContainer(
        AndroidAdDisplayContainerCreationParams(onContainerAdded: (_) {}),
      );

      final ima.AdMediaInfo mockAdMediaInfo = MockAdMediaInfo();
      loadAdCallback(MockVideoAdPlayer(), mockAdMediaInfo, MockAdPodInfo());

      final mockPlayerCallback = MockVideoAdPlayerCallback();
      addCallbackCallback(MockVideoAdPlayer(), mockPlayerCallback);

      onErrorCallback(MockVideoView(), MockMediaPlayer(), 0, 0);

      verify(mockPlayerCallback.onError(mockAdMediaInfo));
    });

    test('play ad once when it is prepared', () async {
      late final void Function(
        ima.VideoAdPlayer,
        ima.AdMediaInfo,
        ima.AdPodInfo,
      )
      loadAdCallback;

      late final void Function(ima.VideoAdPlayer, ima.VideoAdPlayerCallback)
      addCallbackCallback;

      late final Future<void> Function(ima.VideoView, ima.MediaPlayer)
      onPreparedCallback;

      late final void Function(ima.VideoAdPlayer, ima.AdMediaInfo)
      playAdCallback;

      const adDuration = 100;
      const adProgress = 10;

      ima.PigeonOverrides.frameLayout_new = () => MockFrameLayout();
      ima.PigeonOverrides.videoView_new =
          ({
            dynamic onError,
            Future<void> Function(ima.VideoView, ima.MediaPlayer)? onPrepared,
            dynamic onCompletion,
          }) {
            onPreparedCallback = onPrepared!;
            final mockVideoView = MockVideoView();
            when(
              mockVideoView.getCurrentPosition(),
            ).thenAnswer((_) async => adProgress);
            return mockVideoView;
          };
      ima.PigeonOverrides.imaSdkFactory_createAdDisplayContainer =
          (_, __) async {
            return MockAdDisplayContainer();
          };
      ima.PigeonOverrides.videoAdPlayer_new =
          ({
            required void Function(ima.VideoAdPlayer, ima.VideoAdPlayerCallback)
            addCallback,
            required void Function(
              ima.VideoAdPlayer,
              ima.AdMediaInfo,
              ima.AdPodInfo,
            )
            loadAd,
            required dynamic pauseAd,
            required void Function(ima.VideoAdPlayer, ima.AdMediaInfo) playAd,
            required dynamic release,
            required dynamic removeCallback,
            required dynamic stopAd,
          }) {
            loadAdCallback = loadAd;
            addCallbackCallback = addCallback;
            playAdCallback = playAd;
            return MockVideoAdPlayer();
          };
      ima.PigeonOverrides.videoProgressUpdate_new =
          ({required int currentTimeMs, required int durationMs}) {
            expect(currentTimeMs, adProgress);
            expect(durationMs, adDuration);
            return MockVideoProgressUpdate();
          };

      AndroidAdDisplayContainer(
        AndroidAdDisplayContainerCreationParams(onContainerAdded: (_) {}),
      );

      final ima.AdMediaInfo mockAdMediaInfo = MockAdMediaInfo();
      loadAdCallback(MockVideoAdPlayer(), mockAdMediaInfo, MockAdPodInfo());
      playAdCallback(MockVideoAdPlayer(), mockAdMediaInfo);

      final mockPlayerCallback = MockVideoAdPlayerCallback();
      addCallbackCallback(MockVideoAdPlayer(), mockPlayerCallback);

      final mockMediaPlayer = MockMediaPlayer();
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
      )
      loadAdCallback;

      late final Future<void> Function(ima.VideoView, ima.MediaPlayer)
      onPreparedCallback;

      late final Future<void> Function(ima.VideoAdPlayer, ima.AdMediaInfo)
      pauseAdCallback;

      ima.PigeonOverrides.frameLayout_new = () => MockFrameLayout();
      ima.PigeonOverrides.videoView_new =
          ({
            dynamic onError,
            void Function(ima.VideoView, ima.MediaPlayer)? onPrepared,
            dynamic onCompletion,
          }) {
            // VideoView.onPrepared returns void, but the implementation uses an
            // async callback method.
            onPreparedCallback =
                onPrepared!
                    as Future<void> Function(ima.VideoView, ima.MediaPlayer);
            final mockVideoView = MockVideoView();
            when(
              mockVideoView.getCurrentPosition(),
            ).thenAnswer((_) async => 10);
            return mockVideoView;
          };
      ima.PigeonOverrides.imaSdkFactory_createAdDisplayContainer =
          (_, __) async {
            return MockAdDisplayContainer();
          };
      ima.PigeonOverrides.videoAdPlayer_new =
          ({
            required dynamic addCallback,
            required void Function(
              ima.VideoAdPlayer,
              ima.AdMediaInfo,
              ima.AdPodInfo,
            )
            loadAd,
            required dynamic pauseAd,
            required dynamic playAd,
            required dynamic release,
            required dynamic removeCallback,
            required dynamic stopAd,
          }) {
            loadAdCallback = loadAd;
            // VideoAdPlayer.pauseAd returns void, but the implementation uses an
            // async callback method.
            pauseAdCallback =
                pauseAd
                    as Future<void> Function(
                      ima.VideoAdPlayer,
                      ima.AdMediaInfo,
                    );
            return MockVideoAdPlayer();
          };
      ima.PigeonOverrides.videoProgressUpdate_new =
          ({required int currentTimeMs, required int durationMs}) {
            return MockVideoProgressUpdate();
          };

      AndroidAdDisplayContainer(
        AndroidAdDisplayContainerCreationParams(onContainerAdded: (_) {}),
      );

      final ima.AdMediaInfo mockAdMediaInfo = MockAdMediaInfo();
      loadAdCallback(MockVideoAdPlayer(), mockAdMediaInfo, MockAdPodInfo());

      final mockMediaPlayer = MockMediaPlayer();
      when(mockMediaPlayer.getDuration()).thenAnswer((_) async => 100);

      await onPreparedCallback(MockVideoView(), mockMediaPlayer);

      await pauseAdCallback(MockVideoAdPlayer(), mockAdMediaInfo);

      verify(mockMediaPlayer.pause());
    });

    test('pauseAd does not call pause on null media player', () async {
      late final void Function(ima.VideoAdPlayer) releaseCallback;

      late final void Function(
        ima.VideoAdPlayer,
        ima.AdMediaInfo,
        ima.AdPodInfo,
      )
      loadAdCallback;

      late Future<void> Function(ima.VideoView, ima.MediaPlayer)
      onPreparedCallback;

      late final Future<void> Function(ima.VideoAdPlayer, ima.AdMediaInfo)
      pauseAdCallback;

      ima.PigeonOverrides.frameLayout_new = () => MockFrameLayout();
      ima.PigeonOverrides.videoView_new =
          ({
            dynamic onError,
            void Function(ima.VideoView, ima.MediaPlayer)? onPrepared,
            dynamic onCompletion,
          }) {
            // VideoView.onPrepared returns void, but the implementation uses an
            // async callback method.
            onPreparedCallback =
                onPrepared!
                    as Future<void> Function(ima.VideoView, ima.MediaPlayer);
            final mockVideoView = MockVideoView();
            when(
              mockVideoView.getCurrentPosition(),
            ).thenAnswer((_) async => 10);
            return mockVideoView;
          };
      ima.PigeonOverrides.imaSdkFactory_createAdDisplayContainer =
          (_, __) async {
            return MockAdDisplayContainer();
          };
      ima.PigeonOverrides.videoAdPlayer_new =
          ({
            required dynamic addCallback,
            required void Function(
              ima.VideoAdPlayer,
              ima.AdMediaInfo,
              ima.AdPodInfo,
            )
            loadAd,
            required dynamic pauseAd,
            required dynamic playAd,
            required dynamic release,
            required dynamic removeCallback,
            required dynamic stopAd,
          }) {
            loadAdCallback = loadAd;
            // VideoAdPlayer.pauseAd returns void, but the implementation uses an
            // async callback method.
            pauseAdCallback =
                pauseAd
                    as Future<void> Function(
                      ima.VideoAdPlayer,
                      ima.AdMediaInfo,
                    );
            releaseCallback = release as void Function(ima.VideoAdPlayer);
            return MockVideoAdPlayer();
          };
      ima.PigeonOverrides.videoProgressUpdate_new =
          ({required int currentTimeMs, required int durationMs}) {
            return MockVideoProgressUpdate();
          };

      AndroidAdDisplayContainer(
        AndroidAdDisplayContainerCreationParams(onContainerAdded: (_) {}),
      );

      final ima.AdMediaInfo mockAdMediaInfo = MockAdMediaInfo();
      loadAdCallback(MockVideoAdPlayer(), mockAdMediaInfo, MockAdPodInfo());

      final mockMediaPlayer = MockMediaPlayer();
      when(mockMediaPlayer.getDuration()).thenAnswer((_) async => 100);

      await onPreparedCallback(MockVideoView(), mockMediaPlayer);
      releaseCallback(MockVideoAdPlayer());
      await pauseAdCallback(MockVideoAdPlayer(), mockAdMediaInfo);

      verifyNever(mockMediaPlayer.pause());
    });

    test('ad does not play automatically after calling pause', () async {
      late final void Function(
        ima.VideoAdPlayer,
        ima.AdMediaInfo,
        ima.AdPodInfo,
      )
      loadAdCallback;

      late final Future<void> Function(ima.VideoView, ima.MediaPlayer)
      onPreparedCallback;

      late final Future<void> Function(ima.VideoAdPlayer, ima.AdMediaInfo)
      pauseAdCallback;

      late final void Function(ima.VideoAdPlayer, ima.AdMediaInfo)
      playAdCallback;

      ima.PigeonOverrides.frameLayout_new = () => MockFrameLayout();
      ima.PigeonOverrides.videoView_new =
          ({
            dynamic onError,
            void Function(ima.VideoView, ima.MediaPlayer)? onPrepared,
            dynamic onCompletion,
          }) {
            // VideoView.onPrepared returns void, but the implementation uses an
            // async callback method.
            onPreparedCallback =
                onPrepared!
                    as Future<void> Function(ima.VideoView, ima.MediaPlayer);
            final mockVideoView = MockVideoView();
            when(
              mockVideoView.getCurrentPosition(),
            ).thenAnswer((_) async => 10);
            return mockVideoView;
          };
      ima.PigeonOverrides.imaSdkFactory_createAdDisplayContainer =
          (_, __) async {
            return MockAdDisplayContainer();
          };
      ima.PigeonOverrides.videoAdPlayer_new =
          ({
            required dynamic addCallback,
            required void Function(
              ima.VideoAdPlayer,
              ima.AdMediaInfo,
              ima.AdPodInfo,
            )
            loadAd,
            required dynamic pauseAd,
            required void Function(ima.VideoAdPlayer, ima.AdMediaInfo) playAd,
            required dynamic release,
            required dynamic removeCallback,
            required dynamic stopAd,
          }) {
            loadAdCallback = loadAd;
            // VideoAdPlayer.pauseAd returns void, but the implementation uses an
            // async callback method.
            pauseAdCallback =
                pauseAd
                    as Future<void> Function(
                      ima.VideoAdPlayer,
                      ima.AdMediaInfo,
                    );
            playAdCallback = playAd;
            return MockVideoAdPlayer();
          };
      ima.PigeonOverrides.videoProgressUpdate_new =
          ({required int currentTimeMs, required int durationMs}) {
            return MockVideoProgressUpdate();
          };

      AndroidAdDisplayContainer(
        AndroidAdDisplayContainerCreationParams(onContainerAdded: (_) {}),
      );

      final ima.AdMediaInfo mockAdMediaInfo = MockAdMediaInfo();
      when(mockAdMediaInfo.url).thenReturn('url');
      loadAdCallback(MockVideoAdPlayer(), mockAdMediaInfo, MockAdPodInfo());

      final mockMediaPlayer = MockMediaPlayer();
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
        ima.AdPodInfo,
      )
      loadAdCallback;

      late final void Function(ima.VideoAdPlayer, ima.AdMediaInfo)
      playAdCallback;

      final mockVideoView = MockVideoView();
      ima.PigeonOverrides.frameLayout_new = () => MockFrameLayout();
      ima.PigeonOverrides.videoView_new =
          ({dynamic onError, dynamic onPrepared, dynamic onCompletion}) {
            return mockVideoView;
          };
      ima.PigeonOverrides.imaSdkFactory_createAdDisplayContainer =
          (_, __) async {
            return MockAdDisplayContainer();
          };
      ima.PigeonOverrides.videoAdPlayer_new =
          ({
            required dynamic addCallback,
            required void Function(
              ima.VideoAdPlayer,
              ima.AdMediaInfo,
              ima.AdPodInfo,
            )
            loadAd,
            required dynamic pauseAd,
            required void Function(ima.VideoAdPlayer, ima.AdMediaInfo) playAd,
            required dynamic release,
            required dynamic removeCallback,
            required dynamic stopAd,
          }) {
            loadAdCallback = loadAd;
            playAdCallback = playAd;
            return MockVideoAdPlayer();
          };

      AndroidAdDisplayContainer(
        AndroidAdDisplayContainerCreationParams(onContainerAdded: (_) {}),
      );

      const videoUrl = 'url';
      final ima.AdMediaInfo mockAdMediaInfo = MockAdMediaInfo();
      when(mockAdMediaInfo.url).thenReturn(videoUrl);
      loadAdCallback(MockVideoAdPlayer(), mockAdMediaInfo, MockAdPodInfo());
      playAdCallback(MockVideoAdPlayer(), mockAdMediaInfo);

      verify(mockVideoView.setVideoUri(videoUrl));
    });

    test('stop ad creates and sets a new VideoView', () async {
      late final void Function(ima.VideoAdPlayer, ima.AdMediaInfo)
      stopAdCallback;

      final mockFrameLayout = MockFrameLayout();
      late final mockVideoView = MockVideoView();
      late final mockVideoView2 = MockVideoView();
      var newViewVideoCallCount = 0;
      ima.PigeonOverrides.frameLayout_new = () => mockFrameLayout;
      ima.PigeonOverrides.videoView_new =
          ({dynamic onError, dynamic onPrepared, dynamic onCompletion}) {
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
          };
      ima.PigeonOverrides.imaSdkFactory_createAdDisplayContainer =
          (_, __) async {
            return MockAdDisplayContainer();
          };
      ima.PigeonOverrides.videoAdPlayer_new =
          ({
            required dynamic addCallback,
            required void Function(
              ima.VideoAdPlayer,
              ima.AdMediaInfo,
              ima.AdPodInfo,
            )
            loadAd,
            required dynamic pauseAd,
            required dynamic playAd,
            required dynamic release,
            required dynamic removeCallback,
            required void Function(ima.VideoAdPlayer, ima.AdMediaInfo) stopAd,
          }) {
            loadAd(MockVideoAdPlayer(), MockAdMediaInfo(), MockAdPodInfo());
            stopAdCallback = stopAd;
            return MockVideoAdPlayer();
          };

      AndroidAdDisplayContainer(
        AndroidAdDisplayContainerCreationParams(onContainerAdded: (_) {}),
      );

      stopAdCallback(MockVideoAdPlayer(), MockAdMediaInfo());

      verify(mockFrameLayout.removeView(mockVideoView));
      verify(mockFrameLayout.addView(mockVideoView2));
    });

    test('release resets state and sets a new VideoView', () async {
      late final void Function(ima.VideoAdPlayer) releaseCallback;

      final mockFrameLayout = MockFrameLayout();
      late final mockVideoView = MockVideoView();
      late final mockVideoView2 = MockVideoView();
      var newViewVideoCallCount = 0;
      ima.PigeonOverrides.frameLayout_new = () => mockFrameLayout;
      ima.PigeonOverrides.videoView_new =
          ({dynamic onError, dynamic onPrepared, dynamic onCompletion}) {
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
          };
      ima.PigeonOverrides.imaSdkFactory_createAdDisplayContainer =
          (_, __) async {
            return MockAdDisplayContainer();
          };
      ima.PigeonOverrides.videoAdPlayer_new =
          ({
            required dynamic addCallback,
            required void Function(
              ima.VideoAdPlayer,
              ima.AdMediaInfo,
              ima.AdPodInfo,
            )
            loadAd,
            required dynamic pauseAd,
            required dynamic playAd,
            required void Function(ima.VideoAdPlayer) release,
            required dynamic removeCallback,
            required dynamic stopAd,
          }) {
            loadAd(MockVideoAdPlayer(), MockAdMediaInfo(), MockAdPodInfo());
            releaseCallback = release;
            return MockVideoAdPlayer();
          };

      AndroidAdDisplayContainer(
        AndroidAdDisplayContainerCreationParams(onContainerAdded: (_) {}),
      );

      releaseCallback(MockVideoAdPlayer());

      verify(mockFrameLayout.removeView(mockVideoView));
      verify(mockFrameLayout.addView(mockVideoView2));
    });

    testWidgets('AdDisplayContainer adds CompanionAdSlots', (
      WidgetTester tester,
    ) async {
      final mockAdDisplayContainer = MockAdDisplayContainer();
      final mockCompanionAdSlot = MockCompanionAdSlot();
      ima.PigeonOverrides.frameLayout_new = () => MockFrameLayout();
      ima.PigeonOverrides.videoView_new =
          ({
            required dynamic onError,
            dynamic onPrepared,
            dynamic onCompletion,
          }) => MockVideoView();
      ima.PigeonOverrides.imaSdkFactory_createAdDisplayContainer =
          (_, __) async {
            return mockAdDisplayContainer;
          };
      ima.PigeonOverrides.videoAdPlayer_new =
          ({
            required dynamic addCallback,
            required dynamic loadAd,
            required dynamic pauseAd,
            required dynamic playAd,
            required dynamic release,
            required dynamic removeCallback,
            required dynamic stopAd,
          }) => MockVideoAdPlayer();
      final mockFactory = MockImaSdkFactory();
      when(
        mockFactory.createCompanionAdSlot(),
      ).thenAnswer((_) async => mockCompanionAdSlot);
      ima.PigeonOverrides.imaSdkFactory_instance = mockFactory;

      final mockPlatformViewsProxy = MockPlatformViewsServiceProxy();
      final mockAndroidViewController = MockSurfaceAndroidViewController();

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

      final onContainerAddedCompleter = Completer<void>();

      final container = AndroidAdDisplayContainer(
        AndroidAdDisplayContainerCreationParams(
          onContainerAdded: (_) => onContainerAddedCompleter.complete(),
          platformViewsProxy: mockPlatformViewsProxy,
          companionSlots: <PlatformCompanionAdSlot>[
            AndroidCompanionAdSlot(
              AndroidCompanionAdSlotCreationParams(
                size: CompanionAdSlotSize.fixed(width: 300, height: 444),
              ),
            ),
          ],
        ),
      );

      await tester.pumpWidget(
        Builder(builder: (BuildContext context) => container.build(context)),
      );

      final onPlatformCreatedCallback =
          verify(
                mockAndroidViewController.addOnPlatformViewCreatedListener(
                  captureAny,
                ),
              ).captured[0]
              as void Function(int);

      onPlatformCreatedCallback(platformViewId);

      await tester.pumpAndSettle();

      await onContainerAddedCompleter.future;

      verify(
        mockAdDisplayContainer.setCompanionSlots(<ima.CompanionAdSlot>[
          mockCompanionAdSlot,
        ]),
      );
    });

    test('AdDisplayContainer handles preloaded ads', () async {
      late void Function(ima.VideoView, ima.MediaPlayer) onCompletionCallback;

      late final void Function(ima.VideoAdPlayer, ima.VideoAdPlayerCallback)
      addCallbackCallback;
      late final void Function(
        ima.VideoAdPlayer,
        ima.AdMediaInfo,
        ima.AdPodInfo,
      )
      loadAdCallback;
      late final void Function(ima.VideoAdPlayer, ima.AdMediaInfo)
      stopAdCallback;

      final mockVideoView = MockVideoView();
      ima.PigeonOverrides.frameLayout_new = () => MockFrameLayout();
      ima.PigeonOverrides.videoView_new =
          ({
            dynamic onError,
            dynamic onPrepared,
            void Function(ima.VideoView, ima.MediaPlayer)? onCompletion,
          }) {
            onCompletionCallback = onCompletion!;
            return mockVideoView;
          };
      ima.PigeonOverrides.imaSdkFactory_createAdDisplayContainer =
          (_, __) async {
            return MockAdDisplayContainer();
          };
      ima.PigeonOverrides.videoAdPlayer_new =
          ({
            required void Function(ima.VideoAdPlayer, ima.VideoAdPlayerCallback)
            addCallback,
            required void Function(
              ima.VideoAdPlayer,
              ima.AdMediaInfo,
              ima.AdPodInfo,
            )
            loadAd,
            required dynamic pauseAd,
            required dynamic playAd,
            required dynamic release,
            required dynamic removeCallback,
            required void Function(ima.VideoAdPlayer, ima.AdMediaInfo) stopAd,
          }) {
            addCallbackCallback = addCallback;
            loadAdCallback = loadAd;
            stopAdCallback = stopAd;
            return MockVideoAdPlayer();
          };

      AndroidAdDisplayContainer(
        AndroidAdDisplayContainerCreationParams(onContainerAdded: (_) {}),
      );

      final mockPlayerCallback = MockVideoAdPlayerCallback();
      addCallbackCallback(MockVideoAdPlayer(), mockPlayerCallback);

      // Load first Ad
      final ima.AdMediaInfo firstAdMediaInfo = MockAdMediaInfo();
      loadAdCallback(MockVideoAdPlayer(), firstAdMediaInfo, MockAdPodInfo());

      // Load second Ad before first Ad is completed
      final ima.AdMediaInfo secondAdMediaInfo = MockAdMediaInfo();
      loadAdCallback(MockVideoAdPlayer(), secondAdMediaInfo, MockAdPodInfo());

      // Complete current ad which should be the first
      onCompletionCallback(mockVideoView, MockMediaPlayer());
      verify(mockPlayerCallback.onEnded(firstAdMediaInfo));

      // Stop current ad to reset state
      stopAdCallback(MockVideoAdPlayer(), MockAdMediaInfo());

      // Complete current ad which should be the second
      onCompletionCallback(mockVideoView, MockMediaPlayer());
      verify(mockPlayerCallback.onEnded(secondAdMediaInfo));
    });
  });
}
