// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:video_player_android/src/messages.g.dart';
import 'package:video_player_android/src/platform_view_player.dart';
import 'package:video_player_android/video_player_android.dart';
import 'package:video_player_platform_interface/video_player_platform_interface.dart';

import 'android_video_player_test.mocks.dart';
import 'test_api.g.dart';

class _ApiLogger implements TestHostVideoPlayerApi {
  final List<String> log = <String>[];
  int? passedPlayerId;
  CreateMessage? passedCreateMessage;
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
  void setMixWithOthers(bool mixWithOthers) {
    log.add('setMixWithOthers');
    passedMixWithOthers = mixWithOthers;
  }
}

@GenerateNiceMocks(<MockSpec<Object>>[MockSpec<VideoPlayerInstanceApi>()])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  (AndroidVideoPlayer, MockVideoPlayerInstanceApi) setUpMockPlayer({
    required int playerId,
  }) {
    final MockVideoPlayerInstanceApi api = MockVideoPlayerInstanceApi();
    final AndroidVideoPlayer player = AndroidVideoPlayer(
      apiProvider: (_) => api,
    );
    player.ensureApiInitialized(playerId);
    return (player, api);
  }

  test('registration', () async {
    AndroidVideoPlayer.registerWith();
    expect(VideoPlayerPlatform.instance, isA<AndroidVideoPlayer>());
  });

  group('AndroidVideoPlayer', () {
    late _ApiLogger log;

    setUp(() {
      log = _ApiLogger();
      TestHostVideoPlayerApi.setUp(log);
    });

    test('init', () async {
      final (AndroidVideoPlayer player, _) = setUpMockPlayer(playerId: 1);
      await player.init();
      expect(log.log.last, 'init');
    });

    test('dispose', () async {
      final (AndroidVideoPlayer player, _) = setUpMockPlayer(playerId: 1);
      await player.dispose(1);
      expect(log.log.last, 'dispose');
      expect(log.passedPlayerId, 1);
    });

    test('create with asset', () async {
      final (AndroidVideoPlayer player, _) = setUpMockPlayer(playerId: 1);
      final int? playerId = await player.create(
        DataSource(
          sourceType: DataSourceType.asset,
          asset: 'someAsset',
          package: 'somePackage',
        ),
      );
      expect(log.log.last, 'create');
      expect(log.passedCreateMessage?.asset, 'someAsset');
      expect(log.passedCreateMessage?.packageName, 'somePackage');
      expect(playerId, 3);
      expect(
        player.buildViewWithOptions(VideoViewOptions(playerId: playerId!)),
        isA<Texture>(),
      );
    });

    test('create with network', () async {
      final (AndroidVideoPlayer player, _) = setUpMockPlayer(playerId: 1);
      final int? playerId = await player.create(
        DataSource(
          sourceType: DataSourceType.network,
          uri: 'someUri',
          formatHint: VideoFormat.dash,
        ),
      );
      expect(log.log.last, 'create');
      expect(log.passedCreateMessage?.asset, null);
      expect(log.passedCreateMessage?.uri, 'someUri');
      expect(log.passedCreateMessage?.packageName, null);
      expect(log.passedCreateMessage?.formatHint, 'dash');
      expect(log.passedCreateMessage?.httpHeaders, <String, String>{});
      expect(playerId, 3);
      expect(
        player.buildViewWithOptions(VideoViewOptions(playerId: playerId!)),
        isA<Texture>(),
      );
    });

    test('create with network (some headers)', () async {
      final (AndroidVideoPlayer player, _) = setUpMockPlayer(playerId: 1);
      final int? playerId = await player.create(
        DataSource(
          sourceType: DataSourceType.network,
          uri: 'someUri',
          httpHeaders: <String, String>{'Authorization': 'Bearer token'},
        ),
      );
      expect(log.log.last, 'create');
      expect(log.passedCreateMessage?.asset, null);
      expect(log.passedCreateMessage?.uri, 'someUri');
      expect(log.passedCreateMessage?.packageName, null);
      expect(log.passedCreateMessage?.formatHint, null);
      expect(log.passedCreateMessage?.httpHeaders, <String, String>{
        'Authorization': 'Bearer token',
      });
      expect(playerId, 3);
      expect(
        player.buildViewWithOptions(VideoViewOptions(playerId: playerId!)),
        isA<Texture>(),
      );
    });

    test('create with file', () async {
      final (AndroidVideoPlayer player, _) = setUpMockPlayer(playerId: 1);
      final int? playerId = await player.create(
        DataSource(sourceType: DataSourceType.file, uri: 'someUri'),
      );
      expect(log.log.last, 'create');
      expect(log.passedCreateMessage?.uri, 'someUri');
      expect(playerId, 3);
      expect(
        player.buildViewWithOptions(VideoViewOptions(playerId: playerId!)),
        isA<Texture>(),
      );
    });

    test('create with file (some headers)', () async {
      final (AndroidVideoPlayer player, _) = setUpMockPlayer(playerId: 1);
      final int? playerId = await player.create(
        DataSource(
          sourceType: DataSourceType.file,
          uri: 'someUri',
          httpHeaders: <String, String>{'Authorization': 'Bearer token'},
        ),
      );
      expect(log.log.last, 'create');
      expect(log.passedCreateMessage?.uri, 'someUri');
      expect(log.passedCreateMessage?.httpHeaders, <String, String>{
        'Authorization': 'Bearer token',
      });
      expect(playerId, 3);
      expect(
        player.buildViewWithOptions(VideoViewOptions(playerId: playerId!)),
        isA<Texture>(),
      );
    });

    test('createWithOptions with asset', () async {
      final (AndroidVideoPlayer player, _) = setUpMockPlayer(playerId: 1);
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
      expect(
        player.buildViewWithOptions(const VideoViewOptions(playerId: 3)),
        isA<Texture>(),
      );
    });

    test('createWithOptions with network', () async {
      final (AndroidVideoPlayer player, _) = setUpMockPlayer(playerId: 1);
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
      expect(
        player.buildViewWithOptions(VideoViewOptions(playerId: playerId!)),
        isA<Texture>(),
      );
    });

    test('createWithOptions with network (some headers)', () async {
      final (AndroidVideoPlayer player, _) = setUpMockPlayer(playerId: 1);
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
      expect(log.passedCreateMessage?.httpHeaders, <String, String>{
        'Authorization': 'Bearer token',
      });
      expect(playerId, 3);
      expect(
        player.buildViewWithOptions(VideoViewOptions(playerId: playerId!)),
        isA<Texture>(),
      );
    });

    test('createWithOptions with file', () async {
      final (AndroidVideoPlayer player, _) = setUpMockPlayer(playerId: 1);
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
      expect(
        player.buildViewWithOptions(VideoViewOptions(playerId: playerId!)),
        isA<Texture>(),
      );
    });

    test('createWithOptions with file (some headers)', () async {
      final (AndroidVideoPlayer player, _) = setUpMockPlayer(playerId: 1);
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
      expect(log.passedCreateMessage?.httpHeaders, <String, String>{
        'Authorization': 'Bearer token',
      });
      expect(playerId, 3);
      expect(
        player.buildViewWithOptions(VideoViewOptions(playerId: playerId!)),
        isA<Texture>(),
      );
    });

    test('createWithOptions with platform view', () async {
      final (AndroidVideoPlayer player, _) = setUpMockPlayer(playerId: 1);
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
      expect(
        log.passedCreateMessage?.viewType,
        PlatformVideoViewType.platformView,
      );
      expect(playerId, 3);
      expect(
        player.buildViewWithOptions(VideoViewOptions(playerId: playerId!)),
        isA<PlatformViewPlayer>(),
      );
    });

    test('setLooping', () async {
      final (
        AndroidVideoPlayer player,
        MockVideoPlayerInstanceApi playerApi,
      ) = setUpMockPlayer(playerId: 1);
      await player.setLooping(1, true);

      verify(playerApi.setLooping(true));
    });

    test('play', () async {
      final (
        AndroidVideoPlayer player,
        MockVideoPlayerInstanceApi playerApi,
      ) = setUpMockPlayer(playerId: 1);
      await player.play(1);

      verify(playerApi.play());
    });

    test('pause', () async {
      final (
        AndroidVideoPlayer player,
        MockVideoPlayerInstanceApi playerApi,
      ) = setUpMockPlayer(playerId: 1);
      await player.pause(1);

      verify(playerApi.pause());
    });

    test('setMixWithOthers', () async {
      final (AndroidVideoPlayer player, _) = setUpMockPlayer(playerId: 1);
      await player.setMixWithOthers(true);
      expect(log.log.last, 'setMixWithOthers');
      expect(log.passedMixWithOthers, true);

      await player.setMixWithOthers(false);
      expect(log.log.last, 'setMixWithOthers');
      expect(log.passedMixWithOthers, false);
    });

    test('setVolume', () async {
      final (
        AndroidVideoPlayer player,
        MockVideoPlayerInstanceApi playerApi,
      ) = setUpMockPlayer(playerId: 1);
      const double volume = 0.7;
      await player.setVolume(1, volume);

      verify(playerApi.setVolume(volume));
    });

    test('setPlaybackSpeed', () async {
      final (
        AndroidVideoPlayer player,
        MockVideoPlayerInstanceApi playerApi,
      ) = setUpMockPlayer(playerId: 1);
      const double speed = 1.5;
      await player.setPlaybackSpeed(1, speed);

      verify(playerApi.setPlaybackSpeed(speed));
    });

    test('seekTo', () async {
      final (
        AndroidVideoPlayer player,
        MockVideoPlayerInstanceApi playerApi,
      ) = setUpMockPlayer(playerId: 1);
      const int positionMilliseconds = 12345;
      await player.seekTo(
        1,
        const Duration(milliseconds: positionMilliseconds),
      );

      verify(playerApi.seekTo(positionMilliseconds));
    });

    test('getPosition', () async {
      final (
        AndroidVideoPlayer player,
        MockVideoPlayerInstanceApi playerApi,
      ) = setUpMockPlayer(playerId: 1);
      const int positionMilliseconds = 12345;
      when(
        playerApi.getPosition(),
      ).thenAnswer((_) async => positionMilliseconds);

      final Duration position = await player.getPosition(1);
      expect(position, const Duration(milliseconds: positionMilliseconds));
    });

    test('videoEventsFor', () async {
      final (AndroidVideoPlayer player, _) = setUpMockPlayer(playerId: 1);
      const String mockChannel = 'flutter.io/videoPlayer/videoEvents123';
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMessageHandler(mockChannel, (ByteData? message) async {
            final MethodCall methodCall = const StandardMethodCodec()
                .decodeMethodCall(message);
            if (methodCall.method == 'listen') {
              await TestDefaultBinaryMessengerBinding
                  .instance
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
                    (ByteData? data) {},
                  );

              await TestDefaultBinaryMessengerBinding
                  .instance
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
                    (ByteData? data) {},
                  );

              await TestDefaultBinaryMessengerBinding
                  .instance
                  .defaultBinaryMessenger
                  .handlePlatformMessage(
                    mockChannel,
                    const StandardMethodCodec().encodeSuccessEnvelope(
                      <String, dynamic>{'event': 'completed'},
                    ),
                    (ByteData? data) {},
                  );

              await TestDefaultBinaryMessengerBinding
                  .instance
                  .defaultBinaryMessenger
                  .handlePlatformMessage(
                    mockChannel,
                    const StandardMethodCodec().encodeSuccessEnvelope(
                      <String, dynamic>{
                        'event': 'bufferingUpdate',
                        'values': <List<dynamic>>[
                          <int>[0, 1234],
                          <int>[1235, 4000],
                        ],
                      },
                    ),
                    (ByteData? data) {},
                  );

              await TestDefaultBinaryMessengerBinding
                  .instance
                  .defaultBinaryMessenger
                  .handlePlatformMessage(
                    mockChannel,
                    const StandardMethodCodec().encodeSuccessEnvelope(
                      <String, dynamic>{'event': 'bufferingStart'},
                    ),
                    (ByteData? data) {},
                  );

              await TestDefaultBinaryMessengerBinding
                  .instance
                  .defaultBinaryMessenger
                  .handlePlatformMessage(
                    mockChannel,
                    const StandardMethodCodec().encodeSuccessEnvelope(
                      <String, dynamic>{'event': 'bufferingEnd'},
                    ),
                    (ByteData? data) {},
                  );

              await TestDefaultBinaryMessengerBinding
                  .instance
                  .defaultBinaryMessenger
                  .handlePlatformMessage(
                    mockChannel,
                    const StandardMethodCodec().encodeSuccessEnvelope(
                      <String, dynamic>{
                        'event': 'isPlayingStateUpdate',
                        'isPlaying': true,
                      },
                    ),
                    (ByteData? data) {},
                  );

              await TestDefaultBinaryMessengerBinding
                  .instance
                  .defaultBinaryMessenger
                  .handlePlatformMessage(
                    mockChannel,
                    const StandardMethodCodec().encodeSuccessEnvelope(
                      <String, dynamic>{
                        'event': 'isPlayingStateUpdate',
                        'isPlaying': false,
                      },
                    ),
                    (ByteData? data) {},
                  );

              return const StandardMethodCodec().encodeSuccessEnvelope(null);
            } else if (methodCall.method == 'cancel') {
              return const StandardMethodCodec().encodeSuccessEnvelope(null);
            } else {
              fail('Expected listen or cancel');
            }
          });
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
              DurationRange(Duration.zero, const Duration(milliseconds: 1234)),
              DurationRange(
                const Duration(milliseconds: 1235),
                const Duration(milliseconds: 4000),
              ),
            ],
          ),
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
        ]),
      );
    });
  });
}
