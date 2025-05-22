// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:video_player_platform_interface/video_player_platform_interface.dart';
import 'package:video_player_web/src/duration_utils.dart';
import 'package:video_player_web/src/video_player.dart';
import 'package:web/web.dart' as web;

import 'pkg_web_tweaks.dart';
import 'utils.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('VideoPlayer', () {
    late web.HTMLVideoElement video;

    setUp(() {
      // Never set "src" on the video, so this test doesn't hit the network!
      video = web.HTMLVideoElement()
        ..controls = true
        ..playsInline = false;
    });

    testWidgets('initialize() calls load', (WidgetTester _) async {
      bool loadCalled = false;

      video['load'] = () {
        loadCalled = true;
      }.toJS;

      VideoPlayer(videoElement: video).initialize();

      expect(loadCalled, isTrue);
    });

    testWidgets('fixes critical video element config', (WidgetTester _) async {
      VideoPlayer(videoElement: video).initialize();

      expect(video.controls, isFalse,
          reason: 'Video is controlled through code');
      expect(video.autoplay, isFalse,
          reason: 'autoplay attribute on HTMLVideoElement MUST be false');
      // see: https://developer.mozilla.org/en-US/docs/Glossary/Boolean/HTML
      expect(video.getAttribute('autoplay'), isNull,
          reason: 'autoplay attribute on video tag must NOT be set');
      expect(video.playsInline, true, reason: 'Needed by safari iOS');
    });

    testWidgets('setVolume', (WidgetTester tester) async {
      final VideoPlayer player = VideoPlayer(videoElement: video)..initialize();

      player.setVolume(0);
      expect(video.muted, isTrue, reason: 'muted attribute should be true');
      // If the volume is set to zero, pressing unmute
      // button may not restore the audio as expected.
      expect(video.volume, greaterThan(0),
          reason: 'Volume should not be set to zero when muted');
      player.setVolume(0.5);
      expect(video.volume, 0.5, reason: 'Volume should be set to 0.5');
      expect(video.muted, isFalse, reason: 'Muted attribute should be false');

      expect(() {
        player.setVolume(-0.0001);
      }, throwsAssertionError, reason: 'Volume cannot be < 0');

      expect(() {
        player.setVolume(1.0001);
      }, throwsAssertionError, reason: 'Volume cannot be > 1');
    });

    testWidgets('setPlaybackSpeed', (WidgetTester tester) async {
      final VideoPlayer player = VideoPlayer(videoElement: video)..initialize();

      expect(() {
        player.setPlaybackSpeed(-1);
      }, throwsAssertionError, reason: 'Playback speed cannot be < 0');

      expect(() {
        player.setPlaybackSpeed(0);
      }, throwsAssertionError, reason: 'Playback speed cannot be == 0');
    });

    group('seekTo', () {
      testWidgets('negative time - throws assert', (WidgetTester tester) async {
        final VideoPlayer player = VideoPlayer(videoElement: video)
          ..initialize();

        expect(() {
          player.seekTo(const Duration(seconds: -1));
        }, throwsAssertionError, reason: 'Cannot seek into negative numbers');
      });

      testWidgets('setting currentTime to its current value - noop',
          (WidgetTester tester) async {
        makeSetCurrentTimeThrow(video);
        final VideoPlayer player = VideoPlayer(videoElement: video)
          ..initialize();

        expect(() {
          // Self-test...
          video.currentTime = 123;
        }, throwsException, reason: 'Setting currentTime must throw!');

        expect(() {
          // Should not set currentTime (and throw) when seekTo current time.
          player.seekTo(Duration(seconds: video.currentTime.toInt()));
        }, returnsNormally);
      });
    });

    // The events tested in this group do *not* represent the actual sequence
    // of events from a real "video" element. They're crafted to test the
    // behavior of the VideoPlayer in different states with different events.
    group('events', () {
      late StreamController<VideoEvent> streamController;
      late VideoPlayer player;
      late Stream<VideoEvent> timedStream;

      final Set<VideoEventType> bufferingEvents = <VideoEventType>{
        VideoEventType.bufferingStart,
        VideoEventType.bufferingEnd,
      };

      setUp(() {
        streamController = StreamController<VideoEvent>();
        player =
            VideoPlayer(videoElement: video, eventController: streamController)
              ..initialize();

        // This stream will automatically close after 100 ms without seeing any events
        timedStream = streamController.stream.timeout(
          const Duration(milliseconds: 100),
          onTimeout: (EventSink<VideoEvent> sink) {
            sink.close();
          },
        );
      });

      tearDown(() {
        streamController.close();
        player.dispose();
      });

      testWidgets('buffering dispatches only when it changes',
          (WidgetTester tester) async {
        // Take all the "buffering" events that we see during the next few seconds
        final Future<List<bool>> stream = timedStream
            .where(
                (VideoEvent event) => bufferingEvents.contains(event.eventType))
            .map((VideoEvent event) =>
                event.eventType == VideoEventType.bufferingStart)
            .toList();

        // Simulate some events coming from the player...
        player.setBuffering(true);
        player.setBuffering(true);
        player.setBuffering(true);
        player.setBuffering(false);
        player.setBuffering(false);
        player.setBuffering(true);
        player.setBuffering(false);
        player.setBuffering(true);
        player.setBuffering(false);

        final List<bool> events = await stream;

        expect(events, hasLength(6));
        expect(events, <bool>[true, false, true, false, true, false]);
      });

      testWidgets('canplay event does not change buffering state',
          (WidgetTester tester) async {
        // Take all the "buffering" events that we see during the next few seconds
        final Future<List<bool>> stream = timedStream
            .where(
                (VideoEvent event) => bufferingEvents.contains(event.eventType))
            .map((VideoEvent event) =>
                event.eventType == VideoEventType.bufferingStart)
            .toList();

        player.setBuffering(true);

        // Simulate "canplay" event...
        video.dispatchEvent(web.Event('canplay'));

        final List<bool> events = await stream;

        expect(events, hasLength(1));
        expect(events, <bool>[true]);
      });

      testWidgets('canplaythrough event does change buffering state',
          (WidgetTester tester) async {
        // Take all the "buffering" events that we see during the next few seconds
        final Future<List<bool>> stream = timedStream
            .where(
                (VideoEvent event) => bufferingEvents.contains(event.eventType))
            .map((VideoEvent event) =>
                event.eventType == VideoEventType.bufferingStart)
            .toList();

        player.setBuffering(true);

        // Simulate "canplaythrough" event...
        video.dispatchEvent(web.Event('canplaythrough'));

        final List<bool> events = await stream;

        expect(events, hasLength(2));
        expect(events, <bool>[true, false]);
      });

      testWidgets('initialized dispatches only once',
          (WidgetTester tester) async {
        // Dispatch some bogus "canplay" events from the video object
        video.dispatchEvent(web.Event('canplay'));
        video.dispatchEvent(web.Event('canplay'));
        video.dispatchEvent(web.Event('canplay'));

        // Take all the "initialized" events that we see during the next few seconds
        final Future<List<VideoEvent>> stream = timedStream
            .where((VideoEvent event) =>
                event.eventType == VideoEventType.initialized)
            .toList();

        video.dispatchEvent(web.Event('canplay'));
        video.dispatchEvent(web.Event('canplay'));
        video.dispatchEvent(web.Event('canplay'));

        final List<VideoEvent> events = await stream;

        expect(events, hasLength(1));
        expect(events[0].eventType, VideoEventType.initialized);
      });

      testWidgets('loadedmetadata does not dispatch initialized',
          (WidgetTester tester) async {
        video.dispatchEvent(web.Event('loadedmetadata'));
        video.dispatchEvent(web.Event('loadedmetadata'));

        final Future<List<VideoEvent>> stream = timedStream
            .where((VideoEvent event) =>
                event.eventType == VideoEventType.initialized)
            .toList();

        final List<VideoEvent> events = await stream;

        expect(events, isEmpty);
      });

      testWidgets('loadeddata does not dispatch initialized',
          (WidgetTester tester) async {
        video.dispatchEvent(web.Event('loadeddata'));
        video.dispatchEvent(web.Event('loadeddata'));

        final Future<List<VideoEvent>> stream = timedStream
            .where((VideoEvent event) =>
                event.eventType == VideoEventType.initialized)
            .toList();

        final List<VideoEvent> events = await stream;

        expect(events, isEmpty);
      });

      // Issue: https://github.com/flutter/flutter/issues/105649
      testWidgets('supports `Infinity` duration', (WidgetTester _) async {
        setInfinityDuration(video);
        expect(video.duration.isInfinite, isTrue);

        final Future<List<VideoEvent>> stream = timedStream
            .where((VideoEvent event) =>
                event.eventType == VideoEventType.initialized)
            .toList();

        video.dispatchEvent(web.Event('canplay'));

        final List<VideoEvent> events = await stream;

        expect(events, hasLength(1));
        expect(events[0].eventType, VideoEventType.initialized);
        expect(events[0].duration, equals(jsCompatibleTimeUnset));
      });
    });

    group('VideoPlayerWebOptions', () {
      late VideoPlayer player;

      setUp(() {
        video = web.HTMLVideoElement();
        player = VideoPlayer(videoElement: video)..initialize();
      });

      group('VideoPlayerWebOptionsControls', () {
        testWidgets('when disabled expect no controls',
            (WidgetTester tester) async {
          await player.setOptions(
            const VideoPlayerWebOptions(
              // ignore: avoid_redundant_argument_values
              controls: VideoPlayerWebOptionsControls.disabled(),
            ),
          );

          expect(video.controls, isFalse);
          expect(video.controlsList, isNotNull);
          expect(video.controlsList?.length, isZero);
        });

        group('when enabled', () {
          testWidgets('expect controls', (WidgetTester tester) async {
            await player.setOptions(
              const VideoPlayerWebOptions(
                controls: VideoPlayerWebOptionsControls.enabled(),
              ),
            );

            expect(video.controls, isTrue);
            expect(video.controlsList, isNotNull);
            expect(video.controlsList?.length, isZero);
            expect(video.controlsList?.contains('nodownload'), isFalse);
            expect(video.controlsList?.contains('nofullscreen'), isFalse);
            expect(video.controlsList?.contains('noplaybackrate'), isFalse);
            expect(video.disablePictureInPicture, isFalse);
          });

          testWidgets('and no download expect correct controls',
              (WidgetTester tester) async {
            await player.setOptions(
              const VideoPlayerWebOptions(
                controls: VideoPlayerWebOptionsControls.enabled(
                  allowDownload: false,
                ),
              ),
            );

            expect(video.controls, isTrue);
            expect(video.controlsList, isNotNull);
            expect(video.controlsList?.length, 1);
            expect(video.controlsList?.contains('nodownload'), isTrue);
            expect(video.controlsList?.contains('nofullscreen'), isFalse);
            expect(video.controlsList?.contains('noplaybackrate'), isFalse);
            expect(video.disablePictureInPicture, isFalse);
          });

          testWidgets('and no fullscreen expect correct controls',
              (WidgetTester tester) async {
            await player.setOptions(
              const VideoPlayerWebOptions(
                controls: VideoPlayerWebOptionsControls.enabled(
                  allowFullscreen: false,
                ),
              ),
            );

            expect(video.controls, isTrue);
            expect(video.controlsList, isNotNull);
            expect(video.controlsList?.length, 1);
            expect(video.controlsList?.contains('nodownload'), isFalse);
            expect(video.controlsList?.contains('nofullscreen'), isTrue);
            expect(video.controlsList?.contains('noplaybackrate'), isFalse);
            expect(video.disablePictureInPicture, isFalse);
          });

          testWidgets('and no playback rate expect correct controls',
              (WidgetTester tester) async {
            await player.setOptions(
              const VideoPlayerWebOptions(
                controls: VideoPlayerWebOptionsControls.enabled(
                  allowPlaybackRate: false,
                ),
              ),
            );

            expect(video.controls, isTrue);
            expect(video.controlsList, isNotNull);
            expect(video.controlsList?.length, 1);
            expect(video.controlsList?.contains('nodownload'), isFalse);
            expect(video.controlsList?.contains('nofullscreen'), isFalse);
            expect(video.controlsList?.contains('noplaybackrate'), isTrue);
            expect(video.disablePictureInPicture, isFalse);
          });

          testWidgets('and no picture in picture expect correct controls',
              (WidgetTester tester) async {
            await player.setOptions(
              const VideoPlayerWebOptions(
                controls: VideoPlayerWebOptionsControls.enabled(
                  allowPictureInPicture: false,
                ),
              ),
            );

            expect(video.controls, isTrue);
            expect(video.controlsList, isNotNull);
            expect(video.controlsList?.length, 0);
            expect(video.controlsList?.contains('nodownload'), isFalse);
            expect(video.controlsList?.contains('nofullscreen'), isFalse);
            expect(video.controlsList?.contains('noplaybackrate'), isFalse);
            expect(video.disablePictureInPicture, isTrue);
          });
        });
      });

      group('allowRemotePlayback', () {
        testWidgets('when enabled expect no attribute',
            (WidgetTester tester) async {
          await player.setOptions(
            const VideoPlayerWebOptions(
              // ignore: avoid_redundant_argument_values
              allowRemotePlayback: true,
            ),
          );

          expect(video.disableRemotePlayback, isFalse);
        });

        testWidgets('when disabled expect attribute',
            (WidgetTester tester) async {
          await player.setOptions(
            const VideoPlayerWebOptions(
              allowRemotePlayback: false,
            ),
          );

          expect(video.disableRemotePlayback, isTrue);
        });
      });

      group('when called first time', () {
        testWidgets('expect correct options', (WidgetTester tester) async {
          await player.setOptions(
            const VideoPlayerWebOptions(
              controls: VideoPlayerWebOptionsControls.enabled(
                allowDownload: false,
                allowFullscreen: false,
                allowPlaybackRate: false,
                allowPictureInPicture: false,
              ),
              allowContextMenu: false,
              allowRemotePlayback: false,
            ),
          );

          expect(video.controls, isTrue);
          expect(video.controlsList, isNotNull);
          expect(video.controlsList?.length, 3);
          expect(video.controlsList?.contains('nodownload'), isTrue);
          expect(video.controlsList?.contains('nofullscreen'), isTrue);
          expect(video.controlsList?.contains('noplaybackrate'), isTrue);
          expect(video.disablePictureInPicture, isTrue);
          expect(video.disableRemotePlayback, isTrue);
        });

        group('when called once more', () {
          testWidgets('expect correct options', (WidgetTester tester) async {
            await player.setOptions(
              const VideoPlayerWebOptions(
                // ignore: avoid_redundant_argument_values
                controls: VideoPlayerWebOptionsControls.disabled(),
                // ignore: avoid_redundant_argument_values
                allowContextMenu: true,
                // ignore: avoid_redundant_argument_values
                allowRemotePlayback: true,
              ),
            );

            expect(video.controls, isFalse);
            expect(video.controlsList, isNotNull);
            expect(video.controlsList?.length, 0);
            expect(video.controlsList?.contains('nodownload'), isFalse);
            expect(video.controlsList?.contains('nofullscreen'), isFalse);
            expect(video.controlsList?.contains('noplaybackrate'), isFalse);
            expect(video.disablePictureInPicture, isFalse);
            expect(video.disableRemotePlayback, isFalse);
          });
        });
      });
    });
  });
}
