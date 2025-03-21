// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:video_player/video_player.dart';
import 'package:video_player_platform_interface/video_player_platform_interface.dart';

// TODO(FirentisTFW): Remove the ignore and rename parameters when adding support for platform views.
// ignore_for_file: avoid_renaming_method_parameters

const String _localhost = 'https://127.0.0.1';
final Uri _localhostUri = Uri.parse(_localhost);

class FakeController extends ValueNotifier<VideoPlayerValue>
    implements VideoPlayerController {
  FakeController() : super(const VideoPlayerValue(duration: Duration.zero));

  FakeController.value(super.value);

  @override
  Future<void> dispose() async {
    super.dispose();
  }

  @override
  int textureId = VideoPlayerController.kUninitializedTextureId;

  @override
  String get dataSource => '';

  @override
  Map<String, String> get httpHeaders => <String, String>{};

  @override
  DataSourceType get dataSourceType => DataSourceType.file;

  @override
  String get package => '';

  @override
  Future<Duration> get position async => value.position;

  @override
  Future<void> seekTo(Duration moment) async {}

  @override
  Future<void> setVolume(double volume) async {}

  @override
  Future<void> setPlaybackSpeed(double speed) async {}

  @override
  Future<void> initialize() async {}

  @override
  Future<void> pause() async {}

  @override
  Future<void> play() async {}

  @override
  Future<void> setLooping(bool looping) async {}

  @override
  VideoFormat? get formatHint => null;

  @override
  Future<ClosedCaptionFile> get closedCaptionFile => _loadClosedCaption();

  @override
  VideoPlayerOptions? get videoPlayerOptions => null;

  @override
  void setCaptionOffset(Duration delay) {}

  @override
  Future<void> setClosedCaptionFile(
    Future<ClosedCaptionFile>? closedCaptionFile,
  ) async {}
}

Future<ClosedCaptionFile> _loadClosedCaption() async =>
    _FakeClosedCaptionFile();

class _FakeClosedCaptionFile extends ClosedCaptionFile {
  @override
  List<Caption> get captions {
    return <Caption>[
      const Caption(
        text: 'one',
        number: 0,
        start: Duration(milliseconds: 100),
        end: Duration(milliseconds: 200),
      ),
      const Caption(
        text: 'two',
        number: 1,
        start: Duration(milliseconds: 300),
        end: Duration(milliseconds: 400),
      ),
    ];
  }
}

void main() {
  late FakeVideoPlayerPlatform fakeVideoPlayerPlatform;

  setUp(() {
    fakeVideoPlayerPlatform = FakeVideoPlayerPlatform();
    VideoPlayerPlatform.instance = fakeVideoPlayerPlatform;
  });

  void verifyPlayStateRespondsToLifecycle(
    VideoPlayerController controller, {
    required bool shouldPlayInBackground,
  }) {
    expect(controller.value.isPlaying, true);
    WidgetsBinding.instance
        .handleAppLifecycleStateChanged(AppLifecycleState.paused);
    expect(controller.value.isPlaying, shouldPlayInBackground);
    WidgetsBinding.instance
        .handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    expect(controller.value.isPlaying, true);
  }

  testWidgets('update texture', (WidgetTester tester) async {
    final FakeController controller = FakeController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(VideoPlayer(controller));
    expect(find.byType(Texture), findsNothing);

    controller.textureId = 123;
    controller.value = controller.value.copyWith(
      duration: const Duration(milliseconds: 100),
      isInitialized: true,
    );

    await tester.pump();
    expect(find.byType(Texture), findsOneWidget);
  });

  testWidgets('update controller', (WidgetTester tester) async {
    final FakeController controller1 = FakeController();
    addTearDown(controller1.dispose);
    controller1.textureId = 101;
    await tester.pumpWidget(VideoPlayer(controller1));
    expect(
        find.byWidgetPredicate(
          (Widget widget) => widget is Texture && widget.textureId == 101,
        ),
        findsOneWidget);

    final FakeController controller2 = FakeController();
    addTearDown(controller2.dispose);
    controller2.textureId = 102;
    await tester.pumpWidget(VideoPlayer(controller2));
    expect(
        find.byWidgetPredicate(
          (Widget widget) => widget is Texture && widget.textureId == 102,
        ),
        findsOneWidget);
  });

  testWidgets('non-zero rotationCorrection value is used',
      (WidgetTester tester) async {
    final FakeController controller = FakeController.value(
        const VideoPlayerValue(
            duration: Duration.zero, rotationCorrection: 180));
    addTearDown(controller.dispose);
    controller.textureId = 1;
    await tester.pumpWidget(VideoPlayer(controller));
    final Transform actualRotationCorrection =
        find.byType(Transform).evaluate().single.widget as Transform;
    final Float64List actualRotationCorrectionStorage =
        actualRotationCorrection.transform.storage;
    final Float64List expectedMatrixStorage =
        Matrix4.rotationZ(math.pi).storage;
    expect(actualRotationCorrectionStorage.length,
        equals(expectedMatrixStorage.length));
    for (int i = 0; i < actualRotationCorrectionStorage.length; i++) {
      expect(actualRotationCorrectionStorage[i],
          moreOrLessEquals(expectedMatrixStorage[i]));
    }
  });

  testWidgets('no transform when rotationCorrection is zero',
      (WidgetTester tester) async {
    final FakeController controller =
        FakeController.value(const VideoPlayerValue(duration: Duration.zero));
    addTearDown(controller.dispose);
    controller.textureId = 1;
    await tester.pumpWidget(VideoPlayer(controller));
    expect(find.byType(Transform), findsNothing);
  });

  group('ClosedCaption widget', () {
    testWidgets('uses a default text style', (WidgetTester tester) async {
      const String text = 'foo';
      await tester
          .pumpWidget(const MaterialApp(home: ClosedCaption(text: text)));

      final Text textWidget = tester.widget<Text>(find.text(text));
      expect(textWidget.style!.fontSize, 36.0);
      expect(textWidget.style!.color, Colors.white);
    });

    testWidgets('uses given text and style', (WidgetTester tester) async {
      const String text = 'foo';
      const TextStyle textStyle = TextStyle(fontSize: 14.725);
      await tester.pumpWidget(const MaterialApp(
        home: ClosedCaption(
          text: text,
          textStyle: textStyle,
        ),
      ));
      expect(find.text(text), findsOneWidget);

      final Text textWidget = tester.widget<Text>(find.text(text));
      expect(textWidget.style!.fontSize, textStyle.fontSize);
    });

    testWidgets('handles null text', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: ClosedCaption()));
      expect(find.byType(Text), findsNothing);
    });

    testWidgets('handles empty text', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: ClosedCaption(text: '')));
      expect(find.byType(Text), findsNothing);
    });

    testWidgets('Passes text contrast ratio guidelines',
        (WidgetTester tester) async {
      const String text = 'foo';
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          backgroundColor: Colors.white,
          body: ClosedCaption(text: text),
        ),
      ));
      expect(find.text(text), findsOneWidget);

      await expectLater(tester, meetsGuideline(textContrastGuideline));
    }, skip: isBrowser);
  });

  group('VideoPlayerController', () {
    group('legacy initialize', () {
      test('network', () async {
        final VideoPlayerController controller = VideoPlayerController.network(
          'https://127.0.0.1',
        );
        await controller.initialize();

        expect(
          fakeVideoPlayerPlatform.dataSources[0].uri,
          'https://127.0.0.1',
        );
        expect(
          fakeVideoPlayerPlatform.dataSources[0].formatHint,
          null,
        );
        expect(
          fakeVideoPlayerPlatform.dataSources[0].httpHeaders,
          <String, String>{},
        );
      });

      test('network with hint', () async {
        final VideoPlayerController controller = VideoPlayerController.network(
          'https://127.0.0.1',
          formatHint: VideoFormat.dash,
        );
        await controller.initialize();

        expect(
          fakeVideoPlayerPlatform.dataSources[0].uri,
          'https://127.0.0.1',
        );
        expect(
          fakeVideoPlayerPlatform.dataSources[0].formatHint,
          VideoFormat.dash,
        );
        expect(
          fakeVideoPlayerPlatform.dataSources[0].httpHeaders,
          <String, String>{},
        );
      });

      test('network with some headers', () async {
        final VideoPlayerController controller = VideoPlayerController.network(
          'https://127.0.0.1',
          httpHeaders: <String, String>{'Authorization': 'Bearer token'},
        );
        await controller.initialize();

        expect(
          fakeVideoPlayerPlatform.dataSources[0].uri,
          'https://127.0.0.1',
        );
        expect(
          fakeVideoPlayerPlatform.dataSources[0].formatHint,
          null,
        );
        expect(
          fakeVideoPlayerPlatform.dataSources[0].httpHeaders,
          <String, String>{'Authorization': 'Bearer token'},
        );
      });
    });
    group('initialize', () {
      test('started app lifecycle observing', () async {
        final VideoPlayerController controller =
            VideoPlayerController.networkUrl(
          Uri.parse('https://127.0.0.1'),
        );
        addTearDown(controller.dispose);
        await controller.initialize();
        await controller.play();
        verifyPlayStateRespondsToLifecycle(controller,
            shouldPlayInBackground: false);
      });

      test('asset', () async {
        final VideoPlayerController controller = VideoPlayerController.asset(
          'a.avi',
        );
        await controller.initialize();

        expect(fakeVideoPlayerPlatform.dataSources[0].asset, 'a.avi');
        expect(fakeVideoPlayerPlatform.dataSources[0].package, null);
      });

      test('network url', () async {
        final VideoPlayerController controller =
            VideoPlayerController.networkUrl(Uri.parse('https://127.0.0.1'));
        addTearDown(controller.dispose);
        await controller.initialize();

        expect(
          fakeVideoPlayerPlatform.dataSources[0].uri,
          'https://127.0.0.1',
        );
        expect(
          fakeVideoPlayerPlatform.dataSources[0].formatHint,
          null,
        );
        expect(
          fakeVideoPlayerPlatform.dataSources[0].httpHeaders,
          <String, String>{},
        );
      });

      test('network url with hint', () async {
        final VideoPlayerController controller =
            VideoPlayerController.networkUrl(
          Uri.parse('https://127.0.0.1'),
          formatHint: VideoFormat.dash,
        );
        addTearDown(controller.dispose);
        await controller.initialize();

        expect(
          fakeVideoPlayerPlatform.dataSources[0].uri,
          'https://127.0.0.1',
        );
        expect(
          fakeVideoPlayerPlatform.dataSources[0].formatHint,
          VideoFormat.dash,
        );
        expect(
          fakeVideoPlayerPlatform.dataSources[0].httpHeaders,
          <String, String>{},
        );
      });

      test('network url with some headers', () async {
        final VideoPlayerController controller =
            VideoPlayerController.networkUrl(
          Uri.parse('https://127.0.0.1'),
          httpHeaders: <String, String>{'Authorization': 'Bearer token'},
        );
        addTearDown(controller.dispose);
        await controller.initialize();

        expect(
          fakeVideoPlayerPlatform.dataSources[0].uri,
          'https://127.0.0.1',
        );
        expect(
          fakeVideoPlayerPlatform.dataSources[0].formatHint,
          null,
        );
        expect(
          fakeVideoPlayerPlatform.dataSources[0].httpHeaders,
          <String, String>{'Authorization': 'Bearer token'},
        );
      });

      test(
          'when controller is initialized with invalid url it should throw VideoError',
          () async {
        final Uri invalidUrl = Uri.parse('http://testing.com/invalid_url');

        final VideoPlayerController controller =
            VideoPlayerController.networkUrl(invalidUrl);
        addTearDown(controller.dispose);

        late Object error;
        fakeVideoPlayerPlatform.forceInitError = true;
        await controller.initialize().catchError((Object e) => error = e);
        final PlatformException platformEx = error as PlatformException;
        expect(platformEx.code, equals('VideoError'));
      });

      test('file', () async {
        final VideoPlayerController controller =
            VideoPlayerController.file(File('a.avi'));
        await controller.initialize();

        final String uri = fakeVideoPlayerPlatform.dataSources[0].uri!;
        expect(uri.startsWith('file:///'), true, reason: 'Actual string: $uri');
        expect(uri.endsWith('/a.avi'), true, reason: 'Actual string: $uri');
      }, skip: kIsWeb /* Web does not support file assets. */);

      test('file with special characters', () async {
        final VideoPlayerController controller =
            VideoPlayerController.file(File('A #1 Hit.avi'));
        await controller.initialize();

        final String uri = fakeVideoPlayerPlatform.dataSources[0].uri!;
        expect(uri.startsWith('file:///'), true, reason: 'Actual string: $uri');
        expect(uri.endsWith('/A%20%231%20Hit.avi'), true,
            reason: 'Actual string: $uri');
      }, skip: kIsWeb /* Web does not support file assets. */);

      test('file with headers (m3u8)', () async {
        final VideoPlayerController controller = VideoPlayerController.file(
          File('a.avi'),
          httpHeaders: <String, String>{'Authorization': 'Bearer token'},
        );
        await controller.initialize();

        final String uri = fakeVideoPlayerPlatform.dataSources[0].uri!;
        expect(uri.startsWith('file:///'), true, reason: 'Actual string: $uri');
        expect(uri.endsWith('/a.avi'), true, reason: 'Actual string: $uri');

        expect(
          fakeVideoPlayerPlatform.dataSources[0].httpHeaders,
          <String, String>{'Authorization': 'Bearer token'},
        );
      }, skip: kIsWeb /* Web does not support file assets. */);
      test('successful initialize on controller with error clears error',
          () async {
        final VideoPlayerController controller = VideoPlayerController.network(
          'https://127.0.0.1',
        );
        fakeVideoPlayerPlatform.forceInitError = true;
        await controller.initialize().catchError((dynamic e) {});
        expect(controller.value.hasError, equals(true));
        fakeVideoPlayerPlatform.forceInitError = false;
        await controller.initialize();
        expect(controller.value.hasError, equals(false));
      });

      test(
          'given controller with error when initialization succeeds it should clear error',
          () async {
        final VideoPlayerController controller =
            VideoPlayerController.networkUrl(_localhostUri);
        addTearDown(controller.dispose);

        fakeVideoPlayerPlatform.forceInitError = true;
        await controller.initialize().catchError((dynamic e) {});
        expect(controller.value.hasError, equals(true));
        fakeVideoPlayerPlatform.forceInitError = false;
        await controller.initialize();
        expect(controller.value.hasError, equals(false));
      });
    });

    test('contentUri', () async {
      final VideoPlayerController controller =
          VideoPlayerController.contentUri(Uri.parse('content://video'));
      await controller.initialize();

      expect(fakeVideoPlayerPlatform.dataSources[0].uri, 'content://video');
    });

    test('dispose', () async {
      final VideoPlayerController controller =
          VideoPlayerController.networkUrl(_localhostUri);
      addTearDown(controller.dispose);

      expect(
          controller.textureId, VideoPlayerController.kUninitializedTextureId);
      expect(await controller.position, Duration.zero);
      await controller.initialize();

      await controller.dispose();

      expect(controller.textureId, 0);
      expect(await controller.position, isNull);
    });

    test('calling dispose() on disposed controller does not throw', () async {
      final VideoPlayerController controller =
          VideoPlayerController.networkUrl(_localhostUri);
      addTearDown(controller.dispose);

      await controller.initialize();
      await controller.dispose();

      expect(() async => controller.dispose(), returnsNormally);
    });

    test('play', () async {
      final VideoPlayerController controller =
          VideoPlayerController.networkUrl(Uri.parse('https://127.0.0.1'));
      addTearDown(controller.dispose);

      await controller.initialize();
      expect(controller.value.isPlaying, isFalse);
      await controller.play();

      expect(controller.value.isPlaying, isTrue);

      // The two last calls will be "play" and then "setPlaybackSpeed". The
      // reason for this is that "play" calls "setPlaybackSpeed" internally.
      expect(
          fakeVideoPlayerPlatform
              .calls[fakeVideoPlayerPlatform.calls.length - 2],
          'play');
      expect(fakeVideoPlayerPlatform.calls.last, 'setPlaybackSpeed');
    });

    test('play before initialized does not call platform', () async {
      final VideoPlayerController controller =
          VideoPlayerController.networkUrl(_localhostUri);
      addTearDown(controller.dispose);

      expect(controller.value.isInitialized, isFalse);

      await controller.play();

      expect(fakeVideoPlayerPlatform.calls, isEmpty);
    });

    test('play restarts from beginning if video is at end', () async {
      final VideoPlayerController controller =
          VideoPlayerController.networkUrl(_localhostUri);
      addTearDown(controller.dispose);

      await controller.initialize();
      const Duration nonzeroDuration = Duration(milliseconds: 100);
      controller.value = controller.value.copyWith(duration: nonzeroDuration);
      await controller.seekTo(nonzeroDuration);
      expect(controller.value.isPlaying, isFalse);
      expect(controller.value.position, nonzeroDuration);

      await controller.play();

      expect(controller.value.isPlaying, isTrue);
      expect(controller.value.position, Duration.zero);
    });

    test('setLooping', () async {
      final VideoPlayerController controller =
          VideoPlayerController.networkUrl(_localhostUri);
      addTearDown(controller.dispose);

      await controller.initialize();
      expect(controller.value.isLooping, isFalse);
      await controller.setLooping(true);

      expect(controller.value.isLooping, isTrue);
    });

    test('pause', () async {
      final VideoPlayerController controller =
          VideoPlayerController.networkUrl(_localhostUri);
      addTearDown(controller.dispose);

      await controller.initialize();
      await controller.play();
      expect(controller.value.isPlaying, isTrue);

      await controller.pause();

      expect(controller.value.isPlaying, isFalse);
      expect(fakeVideoPlayerPlatform.calls.last, 'pause');
    });

    group('seekTo', () {
      test('works', () async {
        final VideoPlayerController controller =
            VideoPlayerController.networkUrl(_localhostUri);
        addTearDown(controller.dispose);

        await controller.initialize();
        expect(await controller.position, Duration.zero);

        await controller.seekTo(const Duration(milliseconds: 500));

        expect(await controller.position, const Duration(milliseconds: 500));
      });

      test('before initialized does not call platform', () async {
        final VideoPlayerController controller =
            VideoPlayerController.networkUrl(_localhostUri);
        addTearDown(controller.dispose);

        expect(controller.value.isInitialized, isFalse);

        await controller.seekTo(const Duration(milliseconds: 500));

        expect(fakeVideoPlayerPlatform.calls, isEmpty);
      });

      test('clamps values that are too high or low', () async {
        final VideoPlayerController controller =
            VideoPlayerController.networkUrl(_localhostUri);
        addTearDown(controller.dispose);

        await controller.initialize();
        expect(await controller.position, Duration.zero);

        await controller.seekTo(const Duration(seconds: 100));
        expect(await controller.position, const Duration(seconds: 1));

        await controller.seekTo(const Duration(seconds: -100));
        expect(await controller.position, Duration.zero);
      });
    });

    group('setVolume', () {
      test('works', () async {
        final VideoPlayerController controller =
            VideoPlayerController.networkUrl(_localhostUri);
        addTearDown(controller.dispose);

        await controller.initialize();
        expect(controller.value.volume, 1.0);

        const double volume = 0.5;
        await controller.setVolume(volume);

        expect(controller.value.volume, volume);
      });

      test('clamps values that are too high or low', () async {
        final VideoPlayerController controller =
            VideoPlayerController.networkUrl(_localhostUri);
        addTearDown(controller.dispose);

        await controller.initialize();
        expect(controller.value.volume, 1.0);

        await controller.setVolume(-1);
        expect(controller.value.volume, 0.0);

        await controller.setVolume(11);
        expect(controller.value.volume, 1.0);
      });
    });

    group('setPlaybackSpeed', () {
      test('works', () async {
        final VideoPlayerController controller =
            VideoPlayerController.networkUrl(_localhostUri);
        addTearDown(controller.dispose);

        await controller.initialize();
        expect(controller.value.playbackSpeed, 1.0);

        const double speed = 1.5;
        await controller.setPlaybackSpeed(speed);

        expect(controller.value.playbackSpeed, speed);
      });

      test('rejects negative values', () async {
        final VideoPlayerController controller =
            VideoPlayerController.networkUrl(_localhostUri);
        addTearDown(controller.dispose);

        await controller.initialize();
        expect(controller.value.playbackSpeed, 1.0);

        expect(() => controller.setPlaybackSpeed(-1), throwsArgumentError);
      });
    });

    group('scrubbing', () {
      testWidgets('restarts on release if already playing',
          (WidgetTester tester) async {
        final VideoPlayerController controller =
            VideoPlayerController.networkUrl(_localhostUri);

        await controller.initialize();
        final VideoProgressIndicator progressWidget =
            VideoProgressIndicator(controller, allowScrubbing: true);

        await tester.pumpWidget(Directionality(
          textDirection: TextDirection.ltr,
          child: progressWidget,
        ));

        await controller.play();
        expect(controller.value.isPlaying, isTrue);

        final Rect progressRect = tester.getRect(find.byWidget(progressWidget));
        await tester.dragFrom(progressRect.center, const Offset(1.0, 0.0));
        await tester.pumpAndSettle();

        expect(controller.value.position, lessThan(controller.value.duration));
        expect(controller.value.isPlaying, isTrue);

        await controller.pause();
        await tester.runAsync(controller.dispose);
      });

      testWidgets('does not restart when dragging to end',
          (WidgetTester tester) async {
        final VideoPlayerController controller =
            VideoPlayerController.networkUrl(_localhostUri);

        await controller.initialize();
        final VideoProgressIndicator progressWidget =
            VideoProgressIndicator(controller, allowScrubbing: true);

        await tester.pumpWidget(Directionality(
          textDirection: TextDirection.ltr,
          child: progressWidget,
        ));

        await controller.play();
        expect(controller.value.isPlaying, isTrue);

        final Rect progressRect = tester.getRect(find.byWidget(progressWidget));
        await tester.dragFrom(progressRect.center, progressRect.centerRight);
        await tester.pumpAndSettle();

        expect(controller.value.position, controller.value.duration);
        expect(controller.value.isPlaying, isFalse);
        await tester.runAsync(controller.dispose);
      });
    });

    group('caption', () {
      test('works when position updates', () async {
        final VideoPlayerController controller =
            VideoPlayerController.networkUrl(
          _localhostUri,
          closedCaptionFile: _loadClosedCaption(),
        );

        await controller.initialize();
        await controller.play();

        // Optionally record caption changes for later verification.
        final Map<int, String> recordedCaptions = <int, String>{};

        controller.addListener(() {
          // Record the caption for the current position (in milliseconds).
          final int ms = controller.value.position.inMilliseconds;
          recordedCaptions[ms] = controller.value.caption.text;
        });

        const Duration updateInterval = Duration(milliseconds: 100);
        const int totalDurationMs = 350;

        // Simulate continuous playback by incrementing in 50ms steps.
        for (int ms = 0; ms <= totalDurationMs; ms += 50) {
          fakeVideoPlayerPlatform._positions[controller.textureId] =
              Duration(milliseconds: ms);
          await Future<void>.delayed(updateInterval);
        }

        // Now, given your closed caption file and the 100ms update interval,
        // you expect:
        //   • at 100ms: caption should be 'one'
        //   • at 250ms: no caption (i.e. '')
        //   • at 300ms: caption should be 'two'
        expect(recordedCaptions[100], 'one');
        expect(recordedCaptions[250], '');
        expect(recordedCaptions[300], 'two');
      });

      test('works when seeking', () async {
        final VideoPlayerController controller =
            VideoPlayerController.networkUrl(
          _localhostUri,
          closedCaptionFile: _loadClosedCaption(),
        );
        addTearDown(controller.dispose);

        await controller.initialize();
        expect(controller.value.position, Duration.zero);
        expect(controller.value.caption.text, '');

        await controller.seekTo(const Duration(milliseconds: 100));
        expect(controller.value.caption.text, 'one');

        await controller.seekTo(const Duration(milliseconds: 250));
        expect(controller.value.caption.text, '');

        await controller.seekTo(const Duration(milliseconds: 300));
        expect(controller.value.caption.text, 'two');

        await controller.seekTo(const Duration(milliseconds: 301));
        expect(controller.value.caption.text, 'two');

        await controller.seekTo(const Duration(milliseconds: 500));
        expect(controller.value.caption.text, '');

        await controller.seekTo(const Duration(milliseconds: 300));
        expect(controller.value.caption.text, 'two');

        await controller.seekTo(const Duration(milliseconds: 301));
        expect(controller.value.caption.text, 'two');
      });

      test('works when seeking with captionOffset positive', () async {
        final VideoPlayerController controller =
            VideoPlayerController.networkUrl(
          _localhostUri,
          closedCaptionFile: _loadClosedCaption(),
        );
        addTearDown(controller.dispose);

        await controller.initialize();
        controller.setCaptionOffset(const Duration(milliseconds: 100));
        expect(controller.value.position, Duration.zero);
        expect(controller.value.caption.text, '');

        await controller.seekTo(const Duration(milliseconds: 100));
        expect(controller.value.caption.text, 'one');

        await controller.seekTo(const Duration(milliseconds: 101));
        expect(controller.value.caption.text, '');

        await controller.seekTo(const Duration(milliseconds: 250));
        expect(controller.value.caption.text, 'two');

        await controller.seekTo(const Duration(milliseconds: 300));
        expect(controller.value.caption.text, 'two');

        await controller.seekTo(const Duration(milliseconds: 301));
        expect(controller.value.caption.text, '');

        await controller.seekTo(const Duration(milliseconds: 500));
        expect(controller.value.caption.text, '');

        await controller.seekTo(const Duration(milliseconds: 300));
        expect(controller.value.caption.text, 'two');

        await controller.seekTo(const Duration(milliseconds: 301));
        expect(controller.value.caption.text, '');
      });

      test('works when seeking with captionOffset negative', () async {
        final VideoPlayerController controller =
            VideoPlayerController.networkUrl(
          _localhostUri,
          closedCaptionFile: _loadClosedCaption(),
        );
        addTearDown(controller.dispose);

        await controller.initialize();
        controller.setCaptionOffset(const Duration(milliseconds: -100));
        expect(controller.value.position, Duration.zero);
        expect(controller.value.caption.text, '');

        await controller.seekTo(const Duration(milliseconds: 100));
        expect(controller.value.caption.text, '');

        await controller.seekTo(const Duration(milliseconds: 200));
        expect(controller.value.caption.text, 'one');

        await controller.seekTo(const Duration(milliseconds: 250));
        expect(controller.value.caption.text, 'one');

        await controller.seekTo(const Duration(milliseconds: 300));
        expect(controller.value.caption.text, 'one');

        await controller.seekTo(const Duration(milliseconds: 301));
        expect(controller.value.caption.text, '');

        await controller.seekTo(const Duration(milliseconds: 400));
        expect(controller.value.caption.text, 'two');

        await controller.seekTo(const Duration(milliseconds: 500));
        expect(controller.value.caption.text, 'two');

        await controller.seekTo(const Duration(milliseconds: 600));
        expect(controller.value.caption.text, '');

        await controller.seekTo(const Duration(milliseconds: 300));
        expect(controller.value.caption.text, 'one');
      });

      test('setClosedCaptionFile loads caption file', () async {
        final VideoPlayerController controller =
            VideoPlayerController.networkUrl(
          _localhostUri,
        );
        addTearDown(controller.dispose);

        await controller.initialize();
        expect(controller.closedCaptionFile, null);

        await controller.setClosedCaptionFile(_loadClosedCaption());
        expect(
          (await controller.closedCaptionFile)!.captions,
          (await _loadClosedCaption()).captions,
        );
      });

      test('setClosedCaptionFile removes/changes caption file', () async {
        final VideoPlayerController controller =
            VideoPlayerController.networkUrl(
          _localhostUri,
          closedCaptionFile: _loadClosedCaption(),
        );
        addTearDown(controller.dispose);

        await controller.initialize();
        expect(
          (await controller.closedCaptionFile)!.captions,
          (await _loadClosedCaption()).captions,
        );

        await controller.setClosedCaptionFile(null);
        expect(controller.closedCaptionFile, null);
      });
    });

    group('Platform callbacks', () {
      testWidgets('playing completed', (WidgetTester tester) async {
        final VideoPlayerController controller =
            VideoPlayerController.networkUrl(
          _localhostUri,
        );

        await controller.initialize();
        const Duration nonzeroDuration = Duration(milliseconds: 100);
        controller.value = controller.value.copyWith(duration: nonzeroDuration);
        expect(controller.value.isPlaying, isFalse);
        await controller.play();
        expect(controller.value.isPlaying, isTrue);
        final StreamController<VideoEvent> fakeVideoEventStream =
            fakeVideoPlayerPlatform.streams[controller.textureId]!;

        fakeVideoEventStream
            .add(VideoEvent(eventType: VideoEventType.completed));
        await tester.pumpAndSettle();

        expect(controller.value.isPlaying, isFalse);
        expect(controller.value.position, nonzeroDuration);
        await tester.runAsync(controller.dispose);
      });

      testWidgets('playback status', (WidgetTester tester) async {
        final VideoPlayerController controller = VideoPlayerController.network(
          'https://.0.0.1',
        );
        await controller.initialize();
        expect(controller.value.isPlaying, isFalse);
        final StreamController<VideoEvent> fakeVideoEventStream =
            fakeVideoPlayerPlatform.streams[controller.textureId]!;

        fakeVideoEventStream.add(VideoEvent(
          eventType: VideoEventType.isPlayingStateUpdate,
          isPlaying: true,
        ));
        await tester.pumpAndSettle();
        expect(controller.value.isPlaying, isTrue);

        fakeVideoEventStream.add(VideoEvent(
          eventType: VideoEventType.isPlayingStateUpdate,
          isPlaying: false,
        ));
        await tester.pumpAndSettle();
        expect(controller.value.isPlaying, isFalse);
        await tester.runAsync(controller.dispose);
      });

      testWidgets('buffering status', (WidgetTester tester) async {
        final VideoPlayerController controller =
            VideoPlayerController.networkUrl(
          _localhostUri,
        );

        await controller.initialize();
        expect(controller.value.isBuffering, false);
        expect(controller.value.buffered, isEmpty);
        final StreamController<VideoEvent> fakeVideoEventStream =
            fakeVideoPlayerPlatform.streams[controller.textureId]!;

        fakeVideoEventStream
            .add(VideoEvent(eventType: VideoEventType.bufferingStart));
        await tester.pumpAndSettle();
        expect(controller.value.isBuffering, isTrue);

        const Duration bufferStart = Duration.zero;
        const Duration bufferEnd = Duration(milliseconds: 500);
        fakeVideoEventStream.add(VideoEvent(
            eventType: VideoEventType.bufferingUpdate,
            buffered: <DurationRange>[
              DurationRange(bufferStart, bufferEnd),
            ]));
        await tester.pumpAndSettle();
        expect(controller.value.isBuffering, isTrue);
        expect(controller.value.buffered.length, 1);
        expect(controller.value.buffered[0].toString(),
            DurationRange(bufferStart, bufferEnd).toString());

        fakeVideoEventStream
            .add(VideoEvent(eventType: VideoEventType.bufferingEnd));
        await tester.pumpAndSettle();
        expect(controller.value.isBuffering, isFalse);
        await tester.runAsync(controller.dispose);
      });
    });
  });

  test('updates position', () async {
    final VideoPlayerController controller = VideoPlayerController.networkUrl(
      _localhostUri,
      videoPlayerOptions: VideoPlayerOptions(),
    );

    await controller.initialize();

    const Duration updatesInterval = Duration(milliseconds: 100);

    final List<Duration> positions = <Duration>[];
    final Completer<void> intervalUpdateCompleter = Completer<void>();

    // Listen for position updates
    controller.addListener(() {
      positions.add(controller.value.position);
      if (positions.length >= 3 && !intervalUpdateCompleter.isCompleted) {
        intervalUpdateCompleter.complete();
      }
    });
    await controller.play();
    for (int i = 0; i < 3; i++) {
      await Future<void>.delayed(updatesInterval);
      fakeVideoPlayerPlatform._positions[controller.textureId] =
          Duration(milliseconds: i * updatesInterval.inMilliseconds);
    }

    // Wait for at least 3 position updates
    await intervalUpdateCompleter.future;

    // Verify that the intervals between updates are approximately correct
    expect(positions[1] - positions[0], greaterThanOrEqualTo(updatesInterval));
    expect(positions[2] - positions[1], greaterThanOrEqualTo(updatesInterval));
  });

  group('DurationRange', () {
    test('uses given values', () {
      const Duration start = Duration(seconds: 2);
      const Duration end = Duration(seconds: 8);

      final DurationRange range = DurationRange(start, end);

      expect(range.start, start);
      expect(range.end, end);
      expect(range.toString(), contains('start: $start, end: $end'));
    });

    test('calculates fractions', () {
      const Duration start = Duration(seconds: 2);
      const Duration end = Duration(seconds: 8);
      const Duration total = Duration(seconds: 10);

      final DurationRange range = DurationRange(start, end);

      expect(range.startFraction(total), .2);
      expect(range.endFraction(total), .8);
    });
  });

  group('VideoPlayerValue', () {
    test('uninitialized()', () {
      const VideoPlayerValue uninitialized = VideoPlayerValue.uninitialized();

      expect(uninitialized.duration, equals(Duration.zero));
      expect(uninitialized.position, equals(Duration.zero));
      expect(uninitialized.caption, equals(Caption.none));
      expect(uninitialized.captionOffset, equals(Duration.zero));
      expect(uninitialized.buffered, isEmpty);
      expect(uninitialized.isPlaying, isFalse);
      expect(uninitialized.isLooping, isFalse);
      expect(uninitialized.isBuffering, isFalse);
      expect(uninitialized.volume, 1.0);
      expect(uninitialized.playbackSpeed, 1.0);
      expect(uninitialized.errorDescription, isNull);
      expect(uninitialized.size, equals(Size.zero));
      expect(uninitialized.isInitialized, isFalse);
      expect(uninitialized.hasError, isFalse);
      expect(uninitialized.aspectRatio, 1.0);
    });

    test('erroneous()', () {
      const String errorMessage = 'foo';
      const VideoPlayerValue error = VideoPlayerValue.erroneous(errorMessage);

      expect(error.duration, equals(Duration.zero));
      expect(error.position, equals(Duration.zero));
      expect(error.caption, equals(Caption.none));
      expect(error.captionOffset, equals(Duration.zero));
      expect(error.buffered, isEmpty);
      expect(error.isPlaying, isFalse);
      expect(error.isLooping, isFalse);
      expect(error.isBuffering, isFalse);
      expect(error.volume, 1.0);
      expect(error.playbackSpeed, 1.0);
      expect(error.errorDescription, errorMessage);
      expect(error.size, equals(Size.zero));
      expect(error.isInitialized, isFalse);
      expect(error.hasError, isTrue);
      expect(error.aspectRatio, 1.0);
    });

    test('toString()', () {
      const Duration duration = Duration(seconds: 5);
      const Size size = Size(400, 300);
      const Duration position = Duration(seconds: 1);
      const Caption caption = Caption(
          text: 'foo', number: 0, start: Duration.zero, end: Duration.zero);
      const Duration captionOffset = Duration(milliseconds: 250);
      final List<DurationRange> buffered = <DurationRange>[
        DurationRange(Duration.zero, const Duration(seconds: 4))
      ];
      const bool isInitialized = true;
      const bool isPlaying = true;
      const bool isLooping = true;
      const bool isBuffering = true;
      const double volume = 0.5;
      const double playbackSpeed = 1.5;

      final VideoPlayerValue value = VideoPlayerValue(
        duration: duration,
        size: size,
        position: position,
        caption: caption,
        captionOffset: captionOffset,
        buffered: buffered,
        isInitialized: isInitialized,
        isPlaying: isPlaying,
        isLooping: isLooping,
        isBuffering: isBuffering,
        volume: volume,
        playbackSpeed: playbackSpeed,
      );

      expect(
          value.toString(),
          'VideoPlayerValue(duration: 0:00:05.000000, '
          'size: Size(400.0, 300.0), '
          'position: 0:00:01.000000, '
          'caption: Caption(number: 0, start: 0:00:00.000000, end: 0:00:00.000000, text: foo), '
          'captionOffset: 0:00:00.250000, '
          'buffered: [DurationRange(start: 0:00:00.000000, end: 0:00:04.000000)], '
          'isInitialized: true, '
          'isPlaying: true, '
          'isLooping: true, '
          'isBuffering: true, '
          'volume: 0.5, '
          'playbackSpeed: 1.5, '
          'errorDescription: null, '
          'isCompleted: false),');
    });

    group('copyWith()', () {
      test('exact copy', () {
        const VideoPlayerValue original = VideoPlayerValue.uninitialized();
        final VideoPlayerValue exactCopy = original.copyWith();

        expect(exactCopy.toString(), original.toString());
      });
      test('errorDescription is not persisted when copy with null', () {
        const VideoPlayerValue original = VideoPlayerValue.erroneous('error');
        final VideoPlayerValue copy = original.copyWith(errorDescription: null);

        expect(copy.errorDescription, null);
      });
      test('errorDescription is changed when copy with another error', () {
        const VideoPlayerValue original = VideoPlayerValue.erroneous('error');
        final VideoPlayerValue copy =
            original.copyWith(errorDescription: 'new error');

        expect(copy.errorDescription, 'new error');
      });
      test('errorDescription is changed when copy with error', () {
        const VideoPlayerValue original = VideoPlayerValue.uninitialized();
        final VideoPlayerValue copy =
            original.copyWith(errorDescription: 'new error');

        expect(copy.errorDescription, 'new error');
      });
    });

    group('aspectRatio', () {
      test('640x480 -> 4:3', () {
        const VideoPlayerValue value = VideoPlayerValue(
          isInitialized: true,
          size: Size(640, 480),
          duration: Duration(seconds: 1),
        );
        expect(value.aspectRatio, 4 / 3);
      });

      test('no size -> 1.0', () {
        const VideoPlayerValue value = VideoPlayerValue(
          isInitialized: true,
          duration: Duration(seconds: 1),
        );
        expect(value.aspectRatio, 1.0);
      });

      test('height = 0 -> 1.0', () {
        const VideoPlayerValue value = VideoPlayerValue(
          isInitialized: true,
          size: Size(640, 0),
          duration: Duration(seconds: 1),
        );
        expect(value.aspectRatio, 1.0);
      });

      test('width = 0 -> 1.0', () {
        const VideoPlayerValue value = VideoPlayerValue(
          isInitialized: true,
          size: Size(0, 480),
          duration: Duration(seconds: 1),
        );
        expect(value.aspectRatio, 1.0);
      });

      test('negative aspect ratio -> 1.0', () {
        const VideoPlayerValue value = VideoPlayerValue(
          isInitialized: true,
          size: Size(640, -480),
          duration: Duration(seconds: 1),
        );
        expect(value.aspectRatio, 1.0);
      });
    });
  });

  group('VideoPlayerOptions', () {
    test('setMixWithOthers', () async {
      final VideoPlayerController controller = VideoPlayerController.networkUrl(
        _localhostUri,
        videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
      );
      addTearDown(controller.dispose);

      await controller.initialize();
      expect(controller.videoPlayerOptions!.mixWithOthers, true);
    });

    test('true allowBackgroundPlayback continues playback', () async {
      final VideoPlayerController controller = VideoPlayerController.networkUrl(
        _localhostUri,
        videoPlayerOptions: VideoPlayerOptions(
          allowBackgroundPlayback: true,
        ),
      );
      addTearDown(controller.dispose);

      await controller.initialize();
      await controller.play();
      verifyPlayStateRespondsToLifecycle(
        controller,
        shouldPlayInBackground: true,
      );
    });

    test('false allowBackgroundPlayback pauses playback', () async {
      final VideoPlayerController controller = VideoPlayerController.networkUrl(
        _localhostUri,
        videoPlayerOptions: VideoPlayerOptions(),
      );
      addTearDown(controller.dispose);

      await controller.initialize();
      await controller.play();
      verifyPlayStateRespondsToLifecycle(
        controller,
        shouldPlayInBackground: false,
      );
    });
  });

  test('VideoProgressColors', () {
    const Color playedColor = Color.fromRGBO(0, 0, 255, 0.75);
    const Color bufferedColor = Color.fromRGBO(0, 255, 0, 0.5);
    const Color backgroundColor = Color.fromRGBO(255, 255, 0, 0.25);

    const VideoProgressColors colors = VideoProgressColors(
        playedColor: playedColor,
        bufferedColor: bufferedColor,
        backgroundColor: backgroundColor);

    expect(colors.playedColor, playedColor);
    expect(colors.bufferedColor, bufferedColor);
    expect(colors.backgroundColor, backgroundColor);
  });

  test('isCompleted updates on video end', () async {
    final VideoPlayerController controller = VideoPlayerController.networkUrl(
      _localhostUri,
      videoPlayerOptions: VideoPlayerOptions(),
    );
    addTearDown(controller.dispose);

    await controller.initialize();

    final StreamController<VideoEvent> fakeVideoEventStream =
        fakeVideoPlayerPlatform.streams[controller.textureId]!;

    bool currentIsCompleted = controller.value.isCompleted;

    final void Function() isCompletedTest = expectAsync0(() {});

    controller.addListener(() async {
      if (currentIsCompleted != controller.value.isCompleted) {
        currentIsCompleted = controller.value.isCompleted;
        if (controller.value.isCompleted) {
          isCompletedTest();
        }
      }
    });

    fakeVideoEventStream.add(VideoEvent(eventType: VideoEventType.completed));
  });

  test('isCompleted updates on video play after completed', () async {
    final VideoPlayerController controller = VideoPlayerController.networkUrl(
      _localhostUri,
      videoPlayerOptions: VideoPlayerOptions(),
    );
    addTearDown(controller.dispose);

    await controller.initialize();

    final StreamController<VideoEvent> fakeVideoEventStream =
        fakeVideoPlayerPlatform.streams[controller.textureId]!;

    bool currentIsCompleted = controller.value.isCompleted;

    final void Function() isCompletedTest = expectAsync0(() {}, count: 2);
    final void Function() isNoLongerCompletedTest = expectAsync0(() {});
    bool hasLooped = false;

    controller.addListener(() async {
      if (currentIsCompleted != controller.value.isCompleted) {
        currentIsCompleted = controller.value.isCompleted;
        if (controller.value.isCompleted) {
          isCompletedTest();
          if (!hasLooped) {
            fakeVideoEventStream.add(VideoEvent(
                eventType: VideoEventType.isPlayingStateUpdate,
                isPlaying: true));
            hasLooped = !hasLooped;
          }
        } else {
          isNoLongerCompletedTest();
        }
      }
    });

    fakeVideoEventStream.add(VideoEvent(eventType: VideoEventType.completed));
  });

  test('isCompleted updates on video seek to end', () async {
    final VideoPlayerController controller = VideoPlayerController.networkUrl(
      _localhostUri,
      videoPlayerOptions: VideoPlayerOptions(),
    );
    addTearDown(controller.dispose);

    await controller.initialize();

    bool currentIsCompleted = controller.value.isCompleted;

    final void Function() isCompletedTest = expectAsync0(() {});

    controller.value =
        controller.value.copyWith(duration: const Duration(seconds: 10));

    controller.addListener(() async {
      if (currentIsCompleted != controller.value.isCompleted) {
        currentIsCompleted = controller.value.isCompleted;
        if (controller.value.isCompleted) {
          isCompletedTest();
        }
      }
    });

    // This call won't update isCompleted.
    // The test will fail if `isCompletedTest` is called more than once.
    await controller.seekTo(const Duration(seconds: 10));

    await controller.seekTo(const Duration(seconds: 20));
  });
}

class FakeVideoPlayerPlatform extends VideoPlayerPlatform {
  Completer<bool> initialized = Completer<bool>();
  List<String> calls = <String>[];
  List<DataSource> dataSources = <DataSource>[];
  final Map<int, StreamController<VideoEvent>> streams =
      <int, StreamController<VideoEvent>>{};
  bool forceInitError = false;
  int nextTextureId = 0;
  final Map<int, Duration> _positions = <int, Duration>{};
  final Map<int, VideoPlayerWebOptions> webOptions =
      <int, VideoPlayerWebOptions>{};

  @override
  Future<int?> create(DataSource dataSource) async {
    calls.add('create');
    final StreamController<VideoEvent> stream = StreamController<VideoEvent>();
    streams[nextTextureId] = stream;
    if (forceInitError) {
      stream.addError(PlatformException(
          code: 'VideoError', message: 'Video player had error XYZ'));
    } else {
      stream.add(VideoEvent(
          eventType: VideoEventType.initialized,
          size: const Size(100, 100),
          duration: const Duration(seconds: 1)));
    }
    dataSources.add(dataSource);
    return nextTextureId++;
  }

  @override
  Future<void> dispose(int textureId) async {
    calls.add('dispose');
  }

  @override
  Future<void> init() async {
    calls.add('init');
    initialized.complete(true);
  }

  @override
  Stream<VideoEvent> videoEventsFor(int textureId) {
    return streams[textureId]!.stream;
  }

  @override
  Future<void> pause(int textureId) async {
    calls.add('pause');
  }

  @override
  Future<void> play(int textureId) async {
    calls.add('play');
  }

  @override
  Future<Duration> getPosition(int textureId) async {
    calls.add('position');
    return _positions[textureId] ?? Duration.zero;
  }

  @override
  Future<void> seekTo(int textureId, Duration position) async {
    calls.add('seekTo');
    _positions[textureId] = position;
  }

  @override
  Future<void> setLooping(int textureId, bool looping) async {
    calls.add('setLooping');
  }

  @override
  Future<void> setVolume(int textureId, double volume) async {
    calls.add('setVolume');
  }

  @override
  Future<void> setPlaybackSpeed(int textureId, double speed) async {
    calls.add('setPlaybackSpeed');
  }

  @override
  Future<void> setMixWithOthers(bool mixWithOthers) async {
    calls.add('setMixWithOthers');
  }

  @override
  Widget buildView(int textureId) {
    return Texture(textureId: textureId);
  }

  @override
  Future<void> setWebOptions(
      int textureId, VideoPlayerWebOptions options) async {
    if (!kIsWeb) {
      throw UnimplementedError('setWebOptions() is only available in the web.');
    }
    calls.add('setWebOptions');
    webOptions[textureId] = options;
  }
}
