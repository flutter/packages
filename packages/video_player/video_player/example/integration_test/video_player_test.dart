// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';

const Duration _playDuration = Duration(seconds: 1);

// Use WebM for web to allow CI to use Chromium.
const String _videoAssetKey =
    kIsWeb ? 'assets/Butterfly-209.webm' : 'assets/Butterfly-209.mp4';

// Returns the URL to load an asset from this example app as a network source.
//
// TODO(stuartmorgan): Convert this to a local `HttpServer` that vends the
// assets directly, https://github.com/flutter/flutter/issues/95420
String getUrlForAssetAsNetworkSource(String assetKey) {
  return 'https://github.com/flutter/packages/blob/'
      // This hash can be rolled forward to pick up newly-added assets.
      '2e1673307ff7454aff40b47024eaed49a9e77e81'
      '/packages/video_player/video_player/example/'
      '$assetKey'
      '?raw=true';
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  late VideoPlayerController controller;
  tearDown(() async => controller.dispose());

  group('asset videos', () {
    setUp(() {
      controller = VideoPlayerController.asset(_videoAssetKey);
    });

    testWidgets('can be initialized', (WidgetTester tester) async {
      await controller.initialize();

      expect(controller.value.isInitialized, true);
      expect(controller.value.position, Duration.zero);
      expect(controller.value.isPlaying, false);
      // The WebM version has a slightly different duration than the MP4.
      expect(controller.value.duration,
          const Duration(seconds: 7, milliseconds: kIsWeb ? 544 : 540));
    });

    testWidgets(
      'live stream duration != 0',
      (WidgetTester tester) async {
        // This test requires network access, and won't pass until a LUCI recipe
        // change is made.
        // TODO(camsim99): Remove once https://github.com/flutter/flutter/issues/160797 is fixed.
        if (!kIsWeb && Platform.isAndroid) {
          markTestSkipped(
              'Skipping due to https://github.com/flutter/flutter/issues/160797');
          return;
        }

        final VideoPlayerController networkController =
            VideoPlayerController.networkUrl(
          Uri.parse(
              'https://flutter.github.io/assets-for-api-docs/assets/videos/hls/bee.m3u8'),
        );
        await networkController.initialize();

        expect(networkController.value.isInitialized, true);
        // Live streams should have either a positive duration or C.TIME_UNSET if the duration is unknown
        // See https://exoplayer.dev/doc/reference/com/google/android/exoplayer2/Player.html#getDuration--
        expect(networkController.value.duration,
            (Duration duration) => duration != Duration.zero);
      },
      skip: kIsWeb,
    );

    testWidgets(
      'can be played',
      (WidgetTester tester) async {
        await controller.initialize();
        // Mute to allow playing without DOM interaction on Web.
        // See https://developers.google.com/web/updates/2017/09/autoplay-policy-changes
        await controller.setVolume(0);

        await controller.play();
        await tester.pumpAndSettle(_playDuration);

        expect(controller.value.isPlaying, true);
        expect(controller.value.position,
            (Duration position) => position > Duration.zero);
      },
    );

    testWidgets(
      'can seek',
      (WidgetTester tester) async {
        await controller.initialize();

        await controller.seekTo(const Duration(seconds: 3));

        expect(controller.value.position, const Duration(seconds: 3));
      },
    );

    testWidgets(
      'can be paused',
      (WidgetTester tester) async {
        await controller.initialize();
        // Mute to allow playing without DOM interaction on Web.
        // See https://developers.google.com/web/updates/2017/09/autoplay-policy-changes
        await controller.setVolume(0);

        // Play for a second, then pause, and then wait a second.
        await controller.play();
        await tester.pumpAndSettle(_playDuration);
        await controller.pause();
        final Duration pausedPosition = controller.value.position;
        await tester.pumpAndSettle(_playDuration);

        // Verify that we stopped playing after the pause.
        expect(controller.value.isPlaying, false);
        expect(controller.value.position, pausedPosition);
      },
    );

    testWidgets(
      'stay paused when seeking after video completed',
      (WidgetTester tester) async {
        await controller.initialize();
        // Mute to allow playing without DOM interaction on Web.
        // See https://developers.google.com/web/updates/2017/09/autoplay-policy-changes
        await controller.setVolume(0);
        final Duration tenMillisBeforeEnd =
            controller.value.duration - const Duration(milliseconds: 10);
        await controller.seekTo(tenMillisBeforeEnd);
        await controller.play();
        await tester.pumpAndSettle(_playDuration);
        // Android emulators in our CI have frequent flake where the video
        // reports as still playing (usually without having advanced at all
        // past the seek position, but sometimes having advanced some); if that
        // happens, the thing being tested hasn't even had a chance to happen
        // due to CI issues, so just report it as skipped.
        // TODO(stuartmorgan): Remove once
        // https://github.com/flutter/flutter/issues/141145 is fixed.
        if ((!kIsWeb && Platform.isAndroid) && controller.value.isPlaying) {
          markTestSkipped(
              'Skipping due to https://github.com/flutter/flutter/issues/141145');
          return;
        }
        expect(controller.value.isPlaying, false);
        expect(controller.value.position, controller.value.duration);

        await controller.seekTo(tenMillisBeforeEnd);
        await tester.pumpAndSettle(_playDuration);

        expect(controller.value.isPlaying, false);
        expect(controller.value.position, tenMillisBeforeEnd);
      },
      // Flaky on web: https://github.com/flutter/flutter/issues/130147
      skip: kIsWeb,
    );

    testWidgets(
      'do not exceed duration on play after video completed',
      (WidgetTester tester) async {
        await controller.initialize();
        // Mute to allow playing without DOM interaction on Web.
        // See https://developers.google.com/web/updates/2017/09/autoplay-policy-changes
        await controller.setVolume(0);
        await controller.seekTo(
            controller.value.duration - const Duration(milliseconds: 10));
        await controller.play();
        await tester.pumpAndSettle(_playDuration);
        // Android emulators in our CI have frequent flake where the video
        // reports as still playing (usually without having advanced at all
        // past the seek position, but sometimes having advanced some); if that
        // happens, the thing being tested hasn't even had a chance to happen
        // due to CI issues, so just report it as skipped.
        // TODO(stuartmorgan): Remove once
        // https://github.com/flutter/flutter/issues/141145 is fixed.
        if ((!kIsWeb && Platform.isAndroid) && controller.value.isPlaying) {
          markTestSkipped(
              'Skipping due to https://github.com/flutter/flutter/issues/141145');
          return;
        }
        expect(controller.value.isPlaying, false);
        expect(controller.value.position, controller.value.duration);

        await controller.play();
        await tester.pumpAndSettle(_playDuration);

        expect(controller.value.position,
            lessThanOrEqualTo(controller.value.duration));
      },
      // Flaky on the web, headless browsers don't like to seek to non-buffered
      // positions of a video (and since this isn't even injecting the video
      // element on the page, the video never starts buffering with the test)
      skip: kIsWeb,
    );

    testWidgets('test video player view with local asset',
        (WidgetTester tester) async {
      final Completer<void> loaded = Completer<void>();
      Future<bool> started() async {
        await controller.initialize();
        await controller.play();
        loaded.complete();
        return true;
      }

      await tester.pumpWidget(Material(
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: Center(
            child: FutureBuilder<bool>(
              future: started(),
              builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
                if (snapshot.data ?? false) {
                  return AspectRatio(
                    aspectRatio: controller.value.aspectRatio,
                    child: VideoPlayer(controller),
                  );
                } else {
                  return const Text('waiting for video to load');
                }
              },
            ),
          ),
        ),
      ));

      await loaded.future;
      await tester.pumpAndSettle();
      expect(controller.value.isPlaying, true);
    },
        // Web does not support local assets.
        skip: kIsWeb);
  });

  group('file-based videos', () {
    setUp(() async {
      // Load the data from the asset.
      final String tempDir = (await getTemporaryDirectory()).path;
      final ByteData bytes = await rootBundle.load(_videoAssetKey);

      // Write it to a file to use as a source.
      final String filename = _videoAssetKey.split('/').last;
      final File file = File('$tempDir/$filename');
      await file.writeAsBytes(bytes.buffer.asInt8List());

      controller = VideoPlayerController.file(file);
    });

    testWidgets('test video player using static file() method as constructor',
        (WidgetTester tester) async {
      await controller.initialize();

      await controller.play();
      expect(controller.value.isPlaying, true);

      await controller.pause();
      expect(controller.value.isPlaying, false);
    }, skip: kIsWeb);
  });

  group('network videos', () {
    setUp(() {
      controller = VideoPlayerController.networkUrl(
          Uri.parse(getUrlForAssetAsNetworkSource(_videoAssetKey)));
    });

    testWidgets(
      'reports buffering status',
      (WidgetTester tester) async {
        // This test requires network access, and won't pass until a LUCI recipe
        // change is made.
        // TODO(camsim99): Remove once https://github.com/flutter/flutter/issues/160797 is fixed.
        if (!kIsWeb && Platform.isAndroid) {
          markTestSkipped(
              'Skipping due to https://github.com/flutter/flutter/issues/160797');
          return;
        }

        await controller.initialize();
        // Mute to allow playing without DOM interaction on Web.
        // See https://developers.google.com/web/updates/2017/09/autoplay-policy-changes
        await controller.setVolume(0);
        final Completer<void> started = Completer<void>();
        final Completer<void> ended = Completer<void>();
        controller.addListener(() {
          if (!started.isCompleted && controller.value.isBuffering) {
            started.complete();
          }
          if (started.isCompleted &&
              !controller.value.isBuffering &&
              !ended.isCompleted) {
            ended.complete();
          }
        });

        await controller.play();
        await controller.seekTo(const Duration(seconds: 5));
        await tester.pumpAndSettle(_playDuration);
        await controller.pause();

        expect(controller.value.isPlaying, false);
        expect(controller.value.position,
            (Duration position) => position > Duration.zero);

        await expectLater(started.future, completes);
        await expectLater(ended.future, completes);
      },
      skip: !(kIsWeb || defaultTargetPlatform == TargetPlatform.android),
    );
  });

  // Audio playback is tested to prevent accidental regression,
  // but could be removed in the future.
  group('asset audios', () {
    setUp(() {
      controller = VideoPlayerController.asset('assets/Audio.mp3');
    });

    testWidgets('can be initialized', (WidgetTester tester) async {
      await controller.initialize();

      expect(controller.value.isInitialized, true);
      expect(controller.value.position, Duration.zero);
      expect(controller.value.isPlaying, false);
      // Due to the duration calculation accuracy between platforms,
      // the milliseconds on Web will be a slightly different from natives.
      // The audio was made with 44100 Hz, 192 Kbps CBR, and 32 bits.
      expect(
        controller.value.duration,
        const Duration(seconds: 5, milliseconds: kIsWeb ? 42 : 41),
      );
    });

    testWidgets('can be played', (WidgetTester tester) async {
      await controller.initialize();
      // Mute to allow playing without DOM interaction on Web.
      // See https://developers.google.com/web/updates/2017/09/autoplay-policy-changes
      await controller.setVolume(0);

      await controller.play();
      await tester.pumpAndSettle(_playDuration);

      expect(controller.value.isPlaying, true);
      expect(
        controller.value.position,
        (Duration position) => position > Duration.zero,
      );
    });

    testWidgets('can seek', (WidgetTester tester) async {
      await controller.initialize();
      await controller.seekTo(const Duration(seconds: 3));

      expect(controller.value.position, const Duration(seconds: 3));
    });

    testWidgets('can be paused', (WidgetTester tester) async {
      await controller.initialize();
      // Mute to allow playing without DOM interaction on Web.
      // See https://developers.google.com/web/updates/2017/09/autoplay-policy-changes
      await controller.setVolume(0);

      // Play for a second, then pause, and then wait a second.
      await controller.play();
      await tester.pumpAndSettle(_playDuration);
      await controller.pause();
      final Duration pausedPosition = controller.value.position;
      await tester.pumpAndSettle(_playDuration);

      // Verify that we stopped playing after the pause.
      expect(controller.value.isPlaying, false);
      expect(controller.value.position, pausedPosition);
    });
  });
}
