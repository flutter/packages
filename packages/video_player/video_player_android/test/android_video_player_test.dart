// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:video_player_android/src/messages.g.dart';
import 'package:video_player_android/src/platform_view_player.dart';
import 'package:video_player_android/video_player_android.dart';
import 'package:video_player_platform_interface/video_player_platform_interface.dart';

import 'test_api.g.dart';

class _ApiLogger implements TestHostVideoPlayerApi {
  final List<String> log = <String>[];
  int? passedPlayerId;
  CreateMessage? passedCreateMessage;
  int? passedPosition;
  bool? passedLooping;
  double? passedVolume;
  double? passedPlaybackSpeed;
  bool? passedMixWithOthers;

  @override
  int create(CreateMessage arg) {
    log.add('create');
    passedCreateMessage = arg;
    return 3;
  }

  @override
  void dispose(int playerId) {
    log.add('dispose');
    passedPlayerId = playerId;
  }

  @override
  void initialize() {
    log.add('init');
  }

  @override
  void pause(int playerId) {
    log.add('pause');
    passedPlayerId = playerId;
  }

  @override
  void play(int playerId) {
    log.add('play');
    passedPlayerId = playerId;
  }

  @override
  void setMixWithOthers(bool mixWithOthers) {
    log.add('setMixWithOthers');
    passedMixWithOthers = mixWithOthers;
  }

  @override
  int position(int playerId) {
    log.add('position');
    passedPlayerId = playerId;
    return 234;
  }

  @override
  void seekTo(int playerId, int position) {
    log.add('seekTo');
    passedPlayerId = playerId;
    passedPosition = position;
  }

  @override
  void setLooping(int playerId, bool looping) {
    log.add('setLooping');
    passedPlayerId = playerId;
    passedLooping = looping;
  }

  @override
  void setVolume(int playerId, double volume) {
    log.add('setVolume');
    passedPlayerId = playerId;
    passedVolume = volume;
  }

  @override
  void setPlaybackSpeed(int playerId, double speed) {
    log.add('setPlaybackSpeed');
    passedPlayerId = playerId;
    passedPlaybackSpeed = speed;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('registration', () async {
    AndroidVideoPlayer.registerWith();
    expect(VideoPlayerPlatform.instance, isA<AndroidVideoPlayer>());
  });

  group('$AndroidVideoPlayer', () {
    final AndroidVideoPlayer player = AndroidVideoPlayer();
    late _ApiLogger log;

    setUp(() {
      log = _ApiLogger();
      TestHostVideoPlayerApi.setUp(log);
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
      expect(log.passedPlayerId, 1);
    });

    test('create with asset', () async {
      final int? playerId = await player.create(DataSource(
        sourceType: DataSourceType.asset,
        asset: 'someAsset',
        package: 'somePackage',
      ));
      expect(log.log.last, 'create');
      expect(log.passedCreateMessage?.asset, 'someAsset');
      expect(log.passedCreateMessage?.packageName, 'somePackage');
      expect(playerId, 3);
      expect(player.buildViewWithOptions(VideoViewOptions(playerId: playerId!)),
          isA<Texture>());
    });

    test('create with network', () async {
      final int? playerId = await player.create(DataSource(
        sourceType: DataSourceType.network,
        uri: 'someUri',
        formatHint: VideoFormat.dash,
      ));
      expect(log.log.last, 'create');
      expect(log.passedCreateMessage?.asset, null);
      expect(log.passedCreateMessage?.uri, 'someUri');
      expect(log.passedCreateMessage?.packageName, null);
      expect(log.passedCreateMessage?.formatHint, 'dash');
      expect(log.passedCreateMessage?.httpHeaders, <String, String>{});
      expect(playerId, 3);
      expect(player.buildViewWithOptions(VideoViewOptions(playerId: playerId!)),
          isA<Texture>());
    });

    test('create with network (some headers)', () async {
      final int? playerId = await player.create(DataSource(
        sourceType: DataSourceType.network,
        uri: 'someUri',
        httpHeaders: <String, String>{'Authorization': 'Bearer token'},
      ));
      expect(log.log.last, 'create');
      expect(log.passedCreateMessage?.asset, null);
      expect(log.passedCreateMessage?.uri, 'someUri');
      expect(log.passedCreateMessage?.packageName, null);
      expect(log.passedCreateMessage?.formatHint, null);
      expect(log.passedCreateMessage?.httpHeaders,
          <String, String>{'Authorization': 'Bearer token'});
      expect(playerId, 3);
      expect(player.buildViewWithOptions(VideoViewOptions(playerId: playerId!)),
          isA<Texture>());
    });

    test('create with file', () async {
      final int? playerId = await player.create(DataSource(
        sourceType: DataSourceType.file,
        uri: 'someUri',
      ));
      expect(log.log.last, 'create');
      expect(log.passedCreateMessage?.uri, 'someUri');
      expect(playerId, 3);
      expect(player.buildViewWithOptions(VideoViewOptions(playerId: playerId!)),
          isA<Texture>());
    });

    test('create with file (some headers)', () async {
      final int? playerId = await player.create(DataSource(
        sourceType: DataSourceType.file,
        uri: 'someUri',
        httpHeaders: <String, String>{'Authorization': 'Bearer token'},
      ));
      expect(log.log.last, 'create');
      expect(log.passedCreateMessage?.uri, 'someUri');
      expect(log.passedCreateMessage?.httpHeaders,
          <String, String>{'Authorization': 'Bearer token'});
      expect(playerId, 3);
      expect(player.buildViewWithOptions(VideoViewOptions(playerId: playerId!)),
          isA<Texture>());
    });

    test('createWithOptions with asset', () async {
      final int? playerId = await player.createWithOptions(
        VideoCreationOptions(
          dataSource: DataSource(
            sourceType: DataSourceType.asset,
            asset: 'someAsset',
            package: 'somePackage',
          ),
          viewType: VideoViewType.textureView,
        ),
      );
      expect(log.log.last, 'create');
      expect(log.passedCreateMessage?.asset, 'someAsset');
      expect(log.passedCreateMessage?.packageName, 'somePackage');
      expect(playerId, 3);
      expect(player.buildViewWithOptions(const VideoViewOptions(playerId: 3)),
          isA<Texture>());
    });

    test('createWithOptions with network', () async {
      final int? playerId = await player.createWithOptions(
        VideoCreationOptions(
          dataSource: DataSource(
            sourceType: DataSourceType.network,
            uri: 'someUri',
            formatHint: VideoFormat.dash,
          ),
          viewType: VideoViewType.textureView,
        ),
      );
      expect(log.log.last, 'create');
      expect(log.passedCreateMessage?.asset, null);
      expect(log.passedCreateMessage?.uri, 'someUri');
      expect(log.passedCreateMessage?.packageName, null);
      expect(log.passedCreateMessage?.formatHint, 'dash');
      expect(log.passedCreateMessage?.httpHeaders, <String, String>{});
      expect(playerId, 3);
      expect(player.buildViewWithOptions(VideoViewOptions(playerId: playerId!)),
          isA<Texture>());
    });

    test('createWithOptions with network (some headers)', () async {
      final int? playerId = await player.createWithOptions(
        VideoCreationOptions(
          dataSource: DataSource(
            sourceType: DataSourceType.network,
            uri: 'someUri',
            httpHeaders: <String, String>{'Authorization': 'Bearer token'},
          ),
          viewType: VideoViewType.textureView,
        ),
      );
      expect(log.log.last, 'create');
      expect(log.passedCreateMessage?.asset, null);
      expect(log.passedCreateMessage?.uri, 'someUri');
      expect(log.passedCreateMessage?.packageName, null);
      expect(log.passedCreateMessage?.formatHint, null);
      expect(log.passedCreateMessage?.httpHeaders,
          <String, String>{'Authorization': 'Bearer token'});
      expect(playerId, 3);
      expect(player.buildViewWithOptions(VideoViewOptions(playerId: playerId!)),
          isA<Texture>());
    });

    test('createWithOptions with file', () async {
      final int? playerId = await player.createWithOptions(
        VideoCreationOptions(
          dataSource: DataSource(
            sourceType: DataSourceType.file,
            uri: 'someUri',
          ),
          viewType: VideoViewType.textureView,
        ),
      );
      expect(log.log.last, 'create');
      expect(log.passedCreateMessage?.uri, 'someUri');
      expect(playerId, 3);
      expect(player.buildViewWithOptions(VideoViewOptions(playerId: playerId!)),
          isA<Texture>());
    });

    test('createWithOptions with file (some headers)', () async {
      final int? playerId = await player.createWithOptions(
        VideoCreationOptions(
          dataSource: DataSource(
            sourceType: DataSourceType.file,
            uri: 'someUri',
            httpHeaders: <String, String>{'Authorization': 'Bearer token'},
          ),
          viewType: VideoViewType.textureView,
        ),
      );
      expect(log.log.last, 'create');
      expect(log.passedCreateMessage?.uri, 'someUri');
      expect(log.passedCreateMessage?.httpHeaders,
          <String, String>{'Authorization': 'Bearer token'});
      expect(playerId, 3);
      expect(player.buildViewWithOptions(VideoViewOptions(playerId: playerId!)),
          isA<Texture>());
    });

    test('createWithOptions with platform view', () async {
      final int? playerId = await player.createWithOptions(
        VideoCreationOptions(
          dataSource: DataSource(
            sourceType: DataSourceType.file,
            uri: 'someUri',
          ),
          viewType: VideoViewType.platformView,
        ),
      );
      expect(log.log.last, 'create');
      expect(log.passedCreateMessage?.viewType,
          PlatformVideoViewType.platformView);
      expect(playerId, 3);
      expect(player.buildViewWithOptions(VideoViewOptions(playerId: playerId!)),
          isA<PlatformViewPlayer>());
    });

    test('setLooping', () async {
      await player.setLooping(1, true);
      expect(log.log.last, 'setLooping');
      expect(log.passedPlayerId, 1);
      expect(log.passedLooping, true);
    });

    test('play', () async {
      await player.play(1);
      expect(log.log.last, 'play');
      expect(log.passedPlayerId, 1);
    });

    test('pause', () async {
      await player.pause(1);
      expect(log.log.last, 'pause');
      expect(log.passedPlayerId, 1);
    });

    test('setMixWithOthers', () async {
      await player.setMixWithOthers(true);
      expect(log.log.last, 'setMixWithOthers');
      expect(log.passedMixWithOthers, true);

      await player.setMixWithOthers(false);
      expect(log.log.last, 'setMixWithOthers');
      expect(log.passedMixWithOthers, false);
    });

    test('setVolume', () async {
      await player.setVolume(1, 0.7);
      expect(log.log.last, 'setVolume');
      expect(log.passedPlayerId, 1);
      expect(log.passedVolume, 0.7);
    });

    test('setPlaybackSpeed', () async {
      await player.setPlaybackSpeed(1, 1.5);
      expect(log.log.last, 'setPlaybackSpeed');
      expect(log.passedPlayerId, 1);
      expect(log.passedPlaybackSpeed, 1.5);
    });

    test('seekTo', () async {
      await player.seekTo(1, const Duration(milliseconds: 12345));
      expect(log.log.last, 'seekTo');
      expect(log.passedPlayerId, 1);
      expect(log.passedPosition, 12345);
    });

    test('getPosition', () async {
      final Duration position = await player.getPosition(1);
      expect(log.log.last, 'position');
      expect(log.passedPlayerId, 1);
      expect(position, const Duration(milliseconds: 234));
    });

    test('videoEventsFor', () async {
      const String mockChannel = 'flutter.io/videoPlayer/videoEvents123';
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMessageHandler(
        mockChannel,
        (ByteData? message) async {
          final MethodCall methodCall =
              const StandardMethodCodec().decodeMethodCall(message);
          if (methodCall.method == 'listen') {
            await TestDefaultBinaryMessengerBinding
                .instance.defaultBinaryMessenger
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

            await TestDefaultBinaryMessengerBinding
                .instance.defaultBinaryMessenger
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

            await TestDefaultBinaryMessengerBinding
                .instance.defaultBinaryMessenger
                .handlePlatformMessage(
                    mockChannel,
                    const StandardMethodCodec()
                        .encodeSuccessEnvelope(<String, dynamic>{
                      'event': 'completed',
                    }),
                    (ByteData? data) {});

            await TestDefaultBinaryMessengerBinding
                .instance.defaultBinaryMessenger
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

            await TestDefaultBinaryMessengerBinding
                .instance.defaultBinaryMessenger
                .handlePlatformMessage(
                    mockChannel,
                    const StandardMethodCodec()
                        .encodeSuccessEnvelope(<String, dynamic>{
                      'event': 'bufferingStart',
                    }),
                    (ByteData? data) {});

            await TestDefaultBinaryMessengerBinding
                .instance.defaultBinaryMessenger
                .handlePlatformMessage(
                    mockChannel,
                    const StandardMethodCodec()
                        .encodeSuccessEnvelope(<String, dynamic>{
                      'event': 'bufferingEnd',
                    }),
                    (ByteData? data) {});

            await TestDefaultBinaryMessengerBinding
                .instance.defaultBinaryMessenger
                .handlePlatformMessage(
                    mockChannel,
                    const StandardMethodCodec()
                        .encodeSuccessEnvelope(<String, dynamic>{
                      'event': 'isPlayingStateUpdate',
                      'isPlaying': true,
                    }),
                    (ByteData? data) {});

            await TestDefaultBinaryMessengerBinding
                .instance.defaultBinaryMessenger
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
