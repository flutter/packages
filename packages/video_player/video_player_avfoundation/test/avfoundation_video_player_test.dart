// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:video_player_avfoundation/src/messages.g.dart';
import 'package:video_player_avfoundation/video_player_avfoundation.dart';
import 'package:video_player_platform_interface/video_player_platform_interface.dart';

import 'test_api.g.dart';

class _ApiLogger implements TestHostVideoPlayerApi {
  final List<String> log = <String>[];
  int? playerId;
  CreationOptions? creationOptions;
  int? position;
  bool? looping;
  double? volume;
  double? playbackSpeed;
  bool? mixWithOthers;

  @override
  int create(CreationOptions options) {
    log.add('create');
    creationOptions = options;
    return 3;
  }

  @override
  void dispose(int playerId) {
    log.add('dispose');
    this.playerId = playerId;
  }

  @override
  void initialize() {
    log.add('init');
  }

  @override
  void pause(int playerId) {
    log.add('pause');
    this.playerId = playerId;
  }

  @override
  void play(int playerId) {
    log.add('play');
    this.playerId = playerId;
  }

  @override
  void setMixWithOthers(bool enabled) {
    log.add('setMixWithOthers');
    mixWithOthers = enabled;
  }

  @override
  int getPosition(int playerId) {
    log.add('position');
    this.playerId = playerId;
    return 234;
  }

  @override
  Future<void> seekTo(int position, int playerId) async {
    log.add('seekTo');
    this.position = position;
    this.playerId = playerId;
  }

  @override
  void setLooping(bool loop, int playerId) {
    log.add('setLooping');
    looping = loop;
    this.playerId = playerId;
  }

  @override
  void setVolume(double volume, int playerId) {
    log.add('setVolume');
    this.volume = volume;
    this.playerId = playerId;
  }

  @override
  void setPlaybackSpeed(double speed, int playerId) {
    log.add('setPlaybackSpeed');
    playbackSpeed = speed;
    this.playerId = playerId;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('registration', () async {
    AVFoundationVideoPlayer.registerWith();
    expect(VideoPlayerPlatform.instance, isA<AVFoundationVideoPlayer>());
  });

  group('$AVFoundationVideoPlayer', () {
    final AVFoundationVideoPlayer player = AVFoundationVideoPlayer();
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
      player.playerViewStates[1] =
          const VideoPlayerTextureViewState(textureId: 1);

      await player.dispose(1);
      expect(log.log.last, 'dispose');
      expect(log.playerId, 1);
      expect(player.playerViewStates, isEmpty);
    });

    test('create with asset', () async {
      final int? playerId = await player.create(DataSource(
        sourceType: DataSourceType.asset,
        asset: 'someAsset',
        package: 'somePackage',
      ));
      expect(log.log.last, 'create');
      expect(log.creationOptions?.asset, 'someAsset');
      expect(log.creationOptions?.packageName, 'somePackage');
      expect(playerId, 3);
      expect(player.playerViewStates[3],
          const VideoPlayerTextureViewState(textureId: 3));
    });

    test('create with network', () async {
      final int? playerId = await player.create(DataSource(
        sourceType: DataSourceType.network,
        uri: 'someUri',
        formatHint: VideoFormat.dash,
      ));
      expect(log.log.last, 'create');
      expect(log.creationOptions?.asset, null);
      expect(log.creationOptions?.uri, 'someUri');
      expect(log.creationOptions?.packageName, null);
      expect(log.creationOptions?.formatHint, 'dash');
      expect(log.creationOptions?.httpHeaders, <String, String>{});
      expect(playerId, 3);
      expect(player.playerViewStates[3],
          const VideoPlayerTextureViewState(textureId: 3));
    });

    test('create with network (some headers)', () async {
      final int? playerId = await player.create(DataSource(
        sourceType: DataSourceType.network,
        uri: 'someUri',
        httpHeaders: <String, String>{'Authorization': 'Bearer token'},
      ));
      expect(log.log.last, 'create');
      expect(log.creationOptions?.asset, null);
      expect(log.creationOptions?.uri, 'someUri');
      expect(log.creationOptions?.packageName, null);
      expect(log.creationOptions?.formatHint, null);
      expect(log.creationOptions?.httpHeaders,
          <String, String>{'Authorization': 'Bearer token'});
      expect(playerId, 3);
      expect(player.playerViewStates[3],
          const VideoPlayerTextureViewState(textureId: 3));
    });

    test('create with file', () async {
      final int? playerId = await player.create(DataSource(
        sourceType: DataSourceType.file,
        uri: 'someUri',
      ));
      expect(log.log.last, 'create');
      expect(log.creationOptions?.uri, 'someUri');
      expect(playerId, 3);
      expect(player.playerViewStates[3],
          const VideoPlayerTextureViewState(textureId: 3));
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
      expect(log.creationOptions?.asset, 'someAsset');
      expect(log.creationOptions?.packageName, 'somePackage');
      expect(playerId, 3);
      expect(player.playerViewStates[3],
          const VideoPlayerTextureViewState(textureId: 3));
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
      expect(log.creationOptions?.asset, null);
      expect(log.creationOptions?.uri, 'someUri');
      expect(log.creationOptions?.packageName, null);
      expect(log.creationOptions?.formatHint, 'dash');
      expect(log.creationOptions?.httpHeaders, <String, String>{});
      expect(playerId, 3);
      expect(player.playerViewStates[3],
          const VideoPlayerTextureViewState(textureId: 3));
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
      expect(log.creationOptions?.asset, null);
      expect(log.creationOptions?.uri, 'someUri');
      expect(log.creationOptions?.packageName, null);
      expect(log.creationOptions?.formatHint, null);
      expect(log.creationOptions?.httpHeaders,
          <String, String>{'Authorization': 'Bearer token'});
      expect(playerId, 3);
      expect(player.playerViewStates[3],
          const VideoPlayerTextureViewState(textureId: 3));
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
      expect(log.creationOptions?.uri, 'someUri');
      expect(playerId, 3);
      expect(player.playerViewStates[3],
          const VideoPlayerTextureViewState(textureId: 3));
    });

    test('createWithOptions with platform view on iOS', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
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
      expect(log.creationOptions?.viewType, PlatformVideoViewType.platformView);
      expect(playerId, 3);
      expect(player.playerViewStates[3], const VideoPlayerPlatformViewState());
    });

    test('createWithOptions with platform view uses texture view on MacOS',
        () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
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
      expect(log.creationOptions?.viewType, PlatformVideoViewType.textureView);
      expect(playerId, 3);
      expect(player.playerViewStates[3],
          const VideoPlayerTextureViewState(textureId: 3));
    });

    test('setLooping', () async {
      await player.setLooping(1, true);
      expect(log.log.last, 'setLooping');
      expect(log.playerId, 1);
      expect(log.looping, true);
    });

    test('play', () async {
      await player.play(1);
      expect(log.log.last, 'play');
      expect(log.playerId, 1);
    });

    test('pause', () async {
      await player.pause(1);
      expect(log.log.last, 'pause');
      expect(log.playerId, 1);
    });

    test('setMixWithOthers', () async {
      await player.setMixWithOthers(true);
      expect(log.log.last, 'setMixWithOthers');
      expect(log.mixWithOthers, true);

      await player.setMixWithOthers(false);
      expect(log.log.last, 'setMixWithOthers');
      expect(log.mixWithOthers, false);
    });

    test('setVolume', () async {
      await player.setVolume(1, 0.7);
      expect(log.log.last, 'setVolume');
      expect(log.playerId, 1);
      expect(log.volume, 0.7);
    });

    test('setPlaybackSpeed', () async {
      await player.setPlaybackSpeed(1, 1.5);
      expect(log.log.last, 'setPlaybackSpeed');
      expect(log.playerId, 1);
      expect(log.playbackSpeed, 1.5);
    });

    test('seekTo', () async {
      await player.seekTo(1, const Duration(milliseconds: 12345));
      expect(log.log.last, 'seekTo');
      expect(log.playerId, 1);
      expect(log.position, 12345);
    });

    test('getPosition', () async {
      final Duration position = await player.getPosition(1);
      expect(log.log.last, 'position');
      expect(log.playerId, 1);
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
