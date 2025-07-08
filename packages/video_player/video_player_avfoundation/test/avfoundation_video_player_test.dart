// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:video_player_avfoundation/src/messages.g.dart';
import 'package:video_player_avfoundation/video_player_avfoundation.dart';
import 'package:video_player_platform_interface/video_player_platform_interface.dart';

import 'avfoundation_video_player_test.mocks.dart';

@GenerateNiceMocks(<MockSpec<Object>>[
  MockSpec<AVFoundationVideoPlayerApi>(),
  MockSpec<VideoPlayerInstanceApi>(),
])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  (
    AVFoundationVideoPlayer,
    MockAVFoundationVideoPlayerApi,
    MockVideoPlayerInstanceApi
  ) setUpMockPlayer({required int playerId}) {
    final MockAVFoundationVideoPlayerApi pluginApi =
        MockAVFoundationVideoPlayerApi();
    final MockVideoPlayerInstanceApi instanceApi = MockVideoPlayerInstanceApi();
    final AVFoundationVideoPlayer player = AVFoundationVideoPlayer(
      pluginApi: pluginApi,
      playerProvider: (_) => instanceApi,
    );
    player.ensureApiInitialized(playerId);
    return (player, pluginApi, instanceApi);
  }

  test('registration', () async {
    AVFoundationVideoPlayer.registerWith();
    expect(VideoPlayerPlatform.instance, isA<AVFoundationVideoPlayer>());
  });

  group('AVFoundationVideoPlayer', () {
    test('init', () async {
      final (
        AVFoundationVideoPlayer player,
        MockAVFoundationVideoPlayerApi api,
        _,
      ) = setUpMockPlayer(playerId: 1);
      await player.init();

      verify(api.initialize());
    });

    test('dispose', () async {
      final (
        AVFoundationVideoPlayer player,
        MockAVFoundationVideoPlayerApi api,
        _,
      ) = setUpMockPlayer(playerId: 1);
      await player.dispose(1);

      verify(api.dispose(1));
      expect(player.playerViewStates, isEmpty);
    });

    test('create with asset', () async {
      final (
        AVFoundationVideoPlayer player,
        MockAVFoundationVideoPlayerApi api,
        _,
      ) = setUpMockPlayer(playerId: 1);
      const int newPlayerId = 2;
      when(api.create(any)).thenAnswer((_) async => newPlayerId);

      const String asset = 'someAsset';
      const String package = 'somePackage';
      final int? playerId = await player.create(
        DataSource(
          sourceType: DataSourceType.asset,
          asset: asset,
          package: package,
        ),
      );

      final VerificationResult verification = verify(api.create(captureAny));
      final CreationOptions creationOptions =
          verification.captured[0] as CreationOptions;
      expect(creationOptions.asset, asset);
      expect(creationOptions.packageName, package);
      expect(playerId, newPlayerId);
      expect(player.playerViewStates[newPlayerId],
          const VideoPlayerTextureViewState(textureId: newPlayerId));
    });

    test('create with network', () async {
      final (
        AVFoundationVideoPlayer player,
        MockAVFoundationVideoPlayerApi api,
        _,
      ) = setUpMockPlayer(playerId: 1);
      const int newPlayerId = 2;
      when(api.create(any)).thenAnswer((_) async => newPlayerId);

      const String uri = 'https://example.com';
      final int? playerId = await player.create(
        DataSource(
          sourceType: DataSourceType.network,
          uri: uri,
          formatHint: VideoFormat.dash,
        ),
      );

      final VerificationResult verification = verify(api.create(captureAny));
      final CreationOptions creationOptions =
          verification.captured[0] as CreationOptions;
      expect(creationOptions.asset, null);
      expect(creationOptions.uri, uri);
      expect(creationOptions.packageName, null);
      expect(creationOptions.formatHint, 'dash');
      expect(creationOptions.httpHeaders, <String, String>{});
      expect(playerId, newPlayerId);
      expect(player.playerViewStates[newPlayerId],
          const VideoPlayerTextureViewState(textureId: newPlayerId));
    });

    test('create with network passes headers', () async {
      final (
        AVFoundationVideoPlayer player,
        MockAVFoundationVideoPlayerApi api,
        _,
      ) = setUpMockPlayer(playerId: 1);
      when(api.create(any)).thenAnswer((_) async => 2);

      const Map<String, String> headers = <String, String>{
        'Authorization': 'Bearer token',
      };
      await player.create(
        DataSource(
          sourceType: DataSourceType.network,
          uri: 'https://example.com',
          httpHeaders: headers,
        ),
      );
      final VerificationResult verification = verify(api.create(captureAny));
      final CreationOptions creationOptions =
          verification.captured[0] as CreationOptions;
      expect(creationOptions.httpHeaders, headers);
    });

    test('create with file', () async {
      final (
        AVFoundationVideoPlayer player,
        MockAVFoundationVideoPlayerApi api,
        _,
      ) = setUpMockPlayer(playerId: 1);
      const int newPlayerId = 2;
      when(api.create(any)).thenAnswer((_) async => newPlayerId);

      const String fileUri = 'file:///foo/bar';
      final int? playerId = await player.create(
        DataSource(sourceType: DataSourceType.file, uri: fileUri),
      );
      final VerificationResult verification = verify(api.create(captureAny));
      final CreationOptions creationOptions =
          verification.captured[0] as CreationOptions;
      expect(creationOptions.uri, fileUri);
      expect(playerId, newPlayerId);
      expect(player.playerViewStates[newPlayerId],
          const VideoPlayerTextureViewState(textureId: newPlayerId));
    });

    test('createWithOptions with asset', () async {
      final (
        AVFoundationVideoPlayer player,
        MockAVFoundationVideoPlayerApi api,
        _,
      ) = setUpMockPlayer(playerId: 1);
      const int newPlayerId = 2;
      when(api.create(any)).thenAnswer((_) async => newPlayerId);

      const String asset = 'someAsset';
      const String package = 'somePackage';
      final int? playerId = await player.createWithOptions(
        VideoCreationOptions(
          dataSource: DataSource(
            sourceType: DataSourceType.asset,
            asset: asset,
            package: package,
          ),
          viewType: VideoViewType.textureView,
        ),
      );

      final VerificationResult verification = verify(api.create(captureAny));
      final CreationOptions creationOptions =
          verification.captured[0] as CreationOptions;
      expect(creationOptions.asset, asset);
      expect(creationOptions.packageName, package);
      expect(playerId, newPlayerId);
      expect(player.playerViewStates[newPlayerId],
          const VideoPlayerTextureViewState(textureId: newPlayerId));
    });

    test('createWithOptions with network', () async {
      final (
        AVFoundationVideoPlayer player,
        MockAVFoundationVideoPlayerApi api,
        _,
      ) = setUpMockPlayer(playerId: 1);
      const int newPlayerId = 2;
      when(api.create(any)).thenAnswer((_) async => newPlayerId);

      const String uri = 'https://example.com';
      final int? playerId = await player.createWithOptions(
        VideoCreationOptions(
          dataSource: DataSource(
            sourceType: DataSourceType.network,
            uri: uri,
            formatHint: VideoFormat.dash,
          ),
          viewType: VideoViewType.textureView,
        ),
      );

      final VerificationResult verification = verify(api.create(captureAny));
      final CreationOptions creationOptions =
          verification.captured[0] as CreationOptions;
      expect(creationOptions.asset, null);
      expect(creationOptions.uri, uri);
      expect(creationOptions.packageName, null);
      expect(creationOptions.formatHint, 'dash');
      expect(creationOptions.httpHeaders, <String, String>{});
      expect(playerId, newPlayerId);
      expect(player.playerViewStates[newPlayerId],
          const VideoPlayerTextureViewState(textureId: newPlayerId));
    });

    test('createWithOptions with network passes headers', () async {
      final (
        AVFoundationVideoPlayer player,
        MockAVFoundationVideoPlayerApi api,
        _,
      ) = setUpMockPlayer(playerId: 1);
      const int newPlayerId = 2;
      when(api.create(any)).thenAnswer((_) async => newPlayerId);

      const Map<String, String> headers = <String, String>{
        'Authorization': 'Bearer token',
      };
      final int? playerId = await player.createWithOptions(
        VideoCreationOptions(
          dataSource: DataSource(
            sourceType: DataSourceType.network,
            uri: 'https://example.com',
            httpHeaders: headers,
          ),
          viewType: VideoViewType.textureView,
        ),
      );

      final VerificationResult verification = verify(api.create(captureAny));
      final CreationOptions creationOptions =
          verification.captured[0] as CreationOptions;
      expect(creationOptions.httpHeaders, headers);
      expect(playerId, newPlayerId);
    });

    test('createWithOptions with file', () async {
      final (
        AVFoundationVideoPlayer player,
        MockAVFoundationVideoPlayerApi api,
        _,
      ) = setUpMockPlayer(playerId: 1);
      const int newPlayerId = 2;
      when(api.create(any)).thenAnswer((_) async => newPlayerId);

      const String fileUri = 'file:///foo/bar';
      final int? playerId = await player.createWithOptions(
        VideoCreationOptions(
          dataSource: DataSource(sourceType: DataSourceType.file, uri: fileUri),
          viewType: VideoViewType.textureView,
        ),
      );

      final VerificationResult verification = verify(api.create(captureAny));
      final CreationOptions creationOptions =
          verification.captured[0] as CreationOptions;
      expect(creationOptions.uri, fileUri);
      expect(playerId, newPlayerId);
      expect(player.playerViewStates[newPlayerId],
          const VideoPlayerTextureViewState(textureId: newPlayerId));
    });

    test('createWithOptions with platform view', () async {
      final (
        AVFoundationVideoPlayer player,
        MockAVFoundationVideoPlayerApi api,
        _,
      ) = setUpMockPlayer(playerId: 1);
      const int newPlayerId = 2;
      when(api.create(any)).thenAnswer((_) async => newPlayerId);

      final int? playerId = await player.createWithOptions(
        VideoCreationOptions(
          dataSource: DataSource(
            sourceType: DataSourceType.file,
            uri: 'file:///foo/bar',
          ),
          viewType: VideoViewType.platformView,
        ),
      );

      final VerificationResult verification = verify(api.create(captureAny));
      final CreationOptions creationOptions =
          verification.captured[0] as CreationOptions;
      expect(creationOptions.viewType, PlatformVideoViewType.platformView);
      expect(playerId, newPlayerId);
      expect(player.playerViewStates[newPlayerId],
          const VideoPlayerPlatformViewState());
    });

    test('setLooping', () async {
      final (
        AVFoundationVideoPlayer player,
        _,
        MockVideoPlayerInstanceApi playerApi,
      ) = setUpMockPlayer(playerId: 1);
      await player.setLooping(1, true);

      verify(playerApi.setLooping(true));
    });

    test('play', () async {
      final (
        AVFoundationVideoPlayer player,
        _,
        MockVideoPlayerInstanceApi playerApi,
      ) = setUpMockPlayer(playerId: 1);
      await player.play(1);

      verify(playerApi.play());
    });

    test('pause', () async {
      final (
        AVFoundationVideoPlayer player,
        _,
        MockVideoPlayerInstanceApi playerApi,
      ) = setUpMockPlayer(playerId: 1);
      await player.pause(1);

      verify(playerApi.pause());
    });

    group('setMixWithOthers', () {
      test('passes true', () async {
        final (
          AVFoundationVideoPlayer player,
          MockAVFoundationVideoPlayerApi api,
          _,
        ) = setUpMockPlayer(playerId: 1);
        await player.setMixWithOthers(true);

        verify(api.setMixWithOthers(true));
      });

      test('passes false', () async {
        final (
          AVFoundationVideoPlayer player,
          MockAVFoundationVideoPlayerApi api,
          _,
        ) = setUpMockPlayer(playerId: 1);
        await player.setMixWithOthers(false);

        verify(api.setMixWithOthers(false));
      });
    });

    test('setVolume', () async {
      final (
        AVFoundationVideoPlayer player,
        _,
        MockVideoPlayerInstanceApi playerApi,
      ) = setUpMockPlayer(playerId: 1);
      const double volume = 0.7;
      await player.setVolume(1, volume);

      verify(playerApi.setVolume(volume));
    });

    test('setPlaybackSpeed', () async {
      final (
        AVFoundationVideoPlayer player,
        _,
        MockVideoPlayerInstanceApi playerApi,
      ) = setUpMockPlayer(playerId: 1);
      const double speed = 1.5;
      await player.setPlaybackSpeed(1, speed);

      verify(playerApi.setPlaybackSpeed(speed));
    });

    test('seekTo', () async {
      final (
        AVFoundationVideoPlayer player,
        _,
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
        AVFoundationVideoPlayer player,
        _,
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
      final (
        AVFoundationVideoPlayer player,
        MockAVFoundationVideoPlayerApi api,
        _,
      ) = setUpMockPlayer(playerId: 1);
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
