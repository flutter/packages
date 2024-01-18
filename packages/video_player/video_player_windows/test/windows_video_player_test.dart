// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:video_player_platform_interface/video_player_platform_interface.dart';
import 'package:video_player_windows/video_player_windows.dart';

import 'test_api.g.dart';

class _ApiLogger implements TestHostVideoPlayerApi {
  final List<String> log = <String>[];
  int? textureId;

  String? asset;
  String? uri;
  Map<String?, String?>? httpHeaders;

  int? positionValue;
  bool? isLooping;
  double? volume;
  double? speed;

  @override
  int create(String? asset, String? uri, Map<String?, String?> httpHeaders) {
    log.add('create');
    this.asset = asset;
    this.uri = uri;
    this.httpHeaders = httpHeaders;
    return 3;
  }

  @override
  void dispose(int arg) {
    log.add('dispose');
    textureId = arg;
  }

  @override
  void initialize() {
    log.add('init');
  }

  @override
  void pause(int arg) {
    log.add('pause');
    textureId = arg;
  }

  @override
  void play(int arg) {
    log.add('play');
    textureId = arg;
  }

  @override
  int getPosition(int arg) {
    log.add('position');
    textureId = arg;
    return 234;
  }

  @override
  void seekTo(int textureId, int position) {
    log.add('seekTo');
    this.textureId = textureId;
    positionValue = position;
  }

  @override
  void setLooping(int textureId, bool isLooping) {
    log.add('setLooping');
    this.textureId = textureId;
    this.isLooping = isLooping;
  }

  @override
  void setVolume(int textureId, double volume) {
    log.add('setVolume');
    this.textureId = textureId;
    this.volume = volume;
  }

  @override
  void setPlaybackSpeed(int textureId, double speed) {
    log.add('setPlaybackSpeed');
    this.textureId = textureId;
    this.speed = speed;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('registration', () async {
    WindowsVideoPlayer.registerWith();
    expect(VideoPlayerPlatform.instance, isA<WindowsVideoPlayer>());
  });

  group('$WindowsVideoPlayer', () {
    final WindowsVideoPlayer player = WindowsVideoPlayer();
    late _ApiLogger log;

    setUp(() {
      log = _ApiLogger();
      TestHostVideoPlayerApi.setup(log);
    });

    test('init', () async {
      await player.init();
      expect(
        log.log.last,
        'init',
      );
    });

    test('dispose', () async {
      await player.dispose(1);
      expect(log.log.last, 'dispose');
      expect(log.textureId, 1);
    });

    test('create with asset', () async {
      final int? textureId = await player.create(DataSource(
        sourceType: DataSourceType.asset,
        asset: 'someAsset',
      ));
      expect(log.log.last, 'create');
      expect(log.asset, 'someAsset');
      expect(textureId, 3);
    });

    test('create with asset from package', () async {
      await expectLater(
          () => player.create(DataSource(
                sourceType: DataSourceType.asset,
                asset: 'someAsset',
                package: 'somePackage',
              )),
          throwsA(isA<UnimplementedError>()));
    });

    test('create with network', () async {
      final int? textureId = await player.create(DataSource(
        sourceType: DataSourceType.network,
        uri: 'someUri',
      ));
      expect(log.log.last, 'create');
      expect(log.asset, null);
      expect(log.uri, 'someUri');
      expect(log.httpHeaders, <String, String>{});
      expect(textureId, 3);
    });

    test('create with network (some headers)', () async {
      final int? textureId = await player.create(DataSource(
        sourceType: DataSourceType.network,
        uri: 'someUri',
        httpHeaders: <String, String>{'Authorization': 'Bearer token'},
      ));
      expect(log.log.last, 'create');
      expect(log.asset, null);
      expect(log.uri, 'someUri');
      expect(
          log.httpHeaders, <String, String>{'Authorization': 'Bearer token'});
      expect(textureId, 3);
    });

    test('create with file', () async {
      final int? textureId = await player.create(DataSource(
        sourceType: DataSourceType.file,
        uri: 'someUri',
      ));
      expect(log.log.last, 'create');
      expect(log.uri, 'someUri');
      expect(textureId, 3);
    });

    test('create with file (some headers)', () async {
      final int? textureId = await player.create(DataSource(
        sourceType: DataSourceType.file,
        uri: 'someUri',
        httpHeaders: <String, String>{'Authorization': 'Bearer token'},
      ));
      expect(log.log.last, 'create');
      expect(log.uri, 'someUri');
      expect(
          log.httpHeaders, <String, String>{'Authorization': 'Bearer token'});
      expect(textureId, 3);
    });
    test('setLooping', () async {
      await player.setLooping(1, true);
      expect(log.log.last, 'setLooping');
      expect(log.textureId, 1);
      expect(log.isLooping, true);
    });

    test('play', () async {
      await player.play(1);
      expect(log.log.last, 'play');
      expect(log.textureId, 1);
    });

    test('pause', () async {
      await player.pause(1);
      expect(log.log.last, 'pause');
      expect(log.textureId, 1);
    });

    test('setVolume', () async {
      await player.setVolume(1, 0.7);
      expect(log.log.last, 'setVolume');
      expect(log.textureId, 1);
      expect(log.volume, 0.7);
    });

    test('setPlaybackSpeed', () async {
      await player.setPlaybackSpeed(1, 1.5);
      expect(log.log.last, 'setPlaybackSpeed');
      expect(log.textureId, 1);
      expect(log.speed, 1.5);
    });

    test('seekTo', () async {
      await player.seekTo(1, const Duration(milliseconds: 12345));
      expect(log.log.last, 'seekTo');
      expect(log.textureId, 1);
      expect(log.positionValue, 12345);
    });

    test('getPosition', () async {
      final Duration position = await player.getPosition(1);
      expect(log.log.last, 'position');
      expect(log.textureId, 1);
      expect(position, const Duration(milliseconds: 234));
    });

    test('videoEventsFor', () async {
      const String mockChannel = 'flutter.io/videoPlayer/videoEvents123';
      _ambiguate(TestDefaultBinaryMessengerBinding.instance)!
          .defaultBinaryMessenger
          .setMockMessageHandler(
        mockChannel,
        (ByteData? message) async {
          final MethodCall methodCall =
              const StandardMethodCodec().decodeMethodCall(message);
          if (methodCall.method == 'listen') {
            await _ambiguate(TestDefaultBinaryMessengerBinding.instance)!
                .defaultBinaryMessenger
                .handlePlatformMessage(
                    mockChannel,
                    const StandardMethodCodec()
                        .encodeSuccessEnvelope(<String, dynamic>{
                      'event': 'initialized',
                      'duration': 98765,
                      'width': 1920,
                      'height': 1080,
                    }),
                    (ByteData? data) {});

            await _ambiguate(TestDefaultBinaryMessengerBinding.instance)!
                .defaultBinaryMessenger
                .handlePlatformMessage(
                    mockChannel,
                    const StandardMethodCodec()
                        .encodeSuccessEnvelope(<String, dynamic>{
                      'event': 'initialized',
                      'duration': 98765,
                      'width': 1920,
                      'height': 1080,
                      'rotationCorrection': 180,
                    }),
                    (ByteData? data) {});

            await _ambiguate(TestDefaultBinaryMessengerBinding.instance)!
                .defaultBinaryMessenger
                .handlePlatformMessage(
                    mockChannel,
                    const StandardMethodCodec()
                        .encodeSuccessEnvelope(<String, dynamic>{
                      'event': 'completed',
                    }),
                    (ByteData? data) {});

            await _ambiguate(TestDefaultBinaryMessengerBinding.instance)!
                .defaultBinaryMessenger
                .handlePlatformMessage(
                    mockChannel,
                    const StandardMethodCodec()
                        .encodeSuccessEnvelope(<String, dynamic>{
                      'event': 'bufferingUpdate',
                      'values': <List<dynamic>>[
                        <int>[0, 1234],
                        <int>[1235, 4000],
                      ],
                    }),
                    (ByteData? data) {});

            await _ambiguate(TestDefaultBinaryMessengerBinding.instance)!
                .defaultBinaryMessenger
                .handlePlatformMessage(
                    mockChannel,
                    const StandardMethodCodec()
                        .encodeSuccessEnvelope(<String, dynamic>{
                      'event': 'bufferingStart',
                    }),
                    (ByteData? data) {});

            await _ambiguate(TestDefaultBinaryMessengerBinding.instance)!
                .defaultBinaryMessenger
                .handlePlatformMessage(
                    mockChannel,
                    const StandardMethodCodec()
                        .encodeSuccessEnvelope(<String, dynamic>{
                      'event': 'bufferingEnd',
                    }),
                    (ByteData? data) {});

            await _ambiguate(TestDefaultBinaryMessengerBinding.instance)!
                .defaultBinaryMessenger
                .handlePlatformMessage(
                    mockChannel,
                    const StandardMethodCodec()
                        .encodeSuccessEnvelope(<String, dynamic>{
                      'event': 'isPlayingStateUpdate',
                      'isPlaying': true,
                    }),
                    (ByteData? data) {});

            await _ambiguate(TestDefaultBinaryMessengerBinding.instance)!
                .defaultBinaryMessenger
                .handlePlatformMessage(
                    mockChannel,
                    const StandardMethodCodec()
                        .encodeSuccessEnvelope(<String, dynamic>{
                      'event': 'isPlayingStateUpdate',
                      'isPlaying': false,
                    }),
                    (ByteData? data) {});

            return const StandardMethodCodec().encodeSuccessEnvelope(null);
          } else if (methodCall.method == 'cancel') {
            return const StandardMethodCodec().encodeSuccessEnvelope(null);
          } else {
            fail('Expected listen or cancel');
          }
        },
      );
      expect(
          player.videoEventsFor(123),
          emitsInOrder(<dynamic>[
            VideoEvent(
              eventType: VideoEventType.initialized,
              duration: const Duration(milliseconds: 98765),
              size: const Size(1920, 1080),
              rotationCorrection: 0,
            ),
            VideoEvent(
              eventType: VideoEventType.initialized,
              duration: const Duration(milliseconds: 98765),
              size: const Size(1920, 1080),
              rotationCorrection: 180,
            ),
            VideoEvent(eventType: VideoEventType.completed),
            VideoEvent(
                eventType: VideoEventType.bufferingUpdate,
                buffered: <DurationRange>[
                  DurationRange(
                    Duration.zero,
                    const Duration(milliseconds: 1234),
                  ),
                  DurationRange(
                    const Duration(milliseconds: 1235),
                    const Duration(milliseconds: 4000),
                  ),
                ]),
            VideoEvent(eventType: VideoEventType.bufferingStart),
            VideoEvent(eventType: VideoEventType.bufferingEnd),
            VideoEvent(
              eventType: VideoEventType.isPlayingStateUpdate,
              isPlaying: true,
            ),
            VideoEvent(
              eventType: VideoEventType.isPlayingStateUpdate,
              isPlaying: false,
            ),
          ]));
    });
  });
}

/// This allows a value of type T or T? to be treated as a value of type T?.
///
/// We use this so that APIs that have become non-nullable can still be used
/// with `!` and `?` on the stable branch.
T? _ambiguate<T>(T? value) => value;
