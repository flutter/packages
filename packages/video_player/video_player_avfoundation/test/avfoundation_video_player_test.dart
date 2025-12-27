// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
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
    MockVideoPlayerInstanceApi,
  )
  setUpMockPlayer({required int playerId, int? textureId}) {
    final pluginApi = MockAVFoundationVideoPlayerApi();
    final instanceApi = MockVideoPlayerInstanceApi();
    final player = AVFoundationVideoPlayer(
      pluginApi: pluginApi,
      playerApiProvider: (_) => instanceApi,
    );
    player.ensurePlayerInitialized(
      playerId,
      textureId == null
          ? const VideoPlayerPlatformViewState()
          : VideoPlayerTextureViewState(textureId: textureId),
    );
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
      ) = setUpMockPlayer(
        playerId: 1,
        textureId: 101,
      );
      await player.init();

      verify(api.initialize());
    });

    test('dispose', () async {
      final (
        AVFoundationVideoPlayer player,
        _,
        MockVideoPlayerInstanceApi playerApi,
      ) = setUpMockPlayer(
        playerId: 1,
        textureId: 101,
      );
      await player.dispose(1);

      verify(playerApi.dispose());
    });

    test('create with asset', () async {
      final (
        AVFoundationVideoPlayer player,
        MockAVFoundationVideoPlayerApi api,
        _,
      ) = setUpMockPlayer(
        playerId: 1,
        textureId: 101,
      );
      const newPlayerId = 2;
      when(api.createForTextureView(any)).thenAnswer(
        (_) async => TexturePlayerIds(playerId: newPlayerId, textureId: 102),
      );

      const asset = 'someAsset';
      const package = 'somePackage';
      const assetUrl = 'file:///some/asset/path';
      when(api.getAssetUrl(asset, package)).thenAnswer((_) async => assetUrl);

      final int? playerId = await player.create(
        DataSource(
          sourceType: DataSourceType.asset,
          asset: asset,
          package: package,
        ),
      );

      final VerificationResult verification = verify(
        api.createForTextureView(captureAny),
      );
      final creationOptions = verification.captured[0] as CreationOptions;
      expect(creationOptions.uri, assetUrl);
      expect(playerId, newPlayerId);
      expect(
        player.buildViewWithOptions(VideoViewOptions(playerId: playerId!)),
        isA<Texture>(),
      );
    });

    test(
      'create with asset throws PlatformException for missing asset',
      () async {
        final (
          AVFoundationVideoPlayer player,
          MockAVFoundationVideoPlayerApi api,
          _,
        ) = setUpMockPlayer(
          playerId: 1,
          textureId: 101,
        );

        const asset = 'someAsset';
        const package = 'somePackage';
        when(api.getAssetUrl(asset, package)).thenAnswer((_) async => null);

        expect(
          player.create(
            DataSource(
              sourceType: DataSourceType.asset,
              asset: asset,
              package: package,
            ),
          ),
          throwsA(isA<PlatformException>()),
        );
      },
    );

    test('create with network', () async {
      final (
        AVFoundationVideoPlayer player,
        MockAVFoundationVideoPlayerApi api,
        _,
      ) = setUpMockPlayer(
        playerId: 1,
        textureId: 101,
      );
      const newPlayerId = 2;
      when(api.createForTextureView(any)).thenAnswer(
        (_) async => TexturePlayerIds(playerId: newPlayerId, textureId: 102),
      );

      const uri = 'https://example.com';
      final int? playerId = await player.create(
        DataSource(
          sourceType: DataSourceType.network,
          uri: uri,
          formatHint: VideoFormat.dash,
        ),
      );

      final VerificationResult verification = verify(
        api.createForTextureView(captureAny),
      );
      final creationOptions = verification.captured[0] as CreationOptions;
      expect(creationOptions.uri, uri);
      expect(creationOptions.httpHeaders, <String, String>{});
      expect(playerId, newPlayerId);
      expect(
        player.buildViewWithOptions(VideoViewOptions(playerId: playerId!)),
        isA<Texture>(),
      );
    });

    test('create with network passes headers', () async {
      final (
        AVFoundationVideoPlayer player,
        MockAVFoundationVideoPlayerApi api,
        _,
      ) = setUpMockPlayer(
        playerId: 1,
        textureId: 101,
      );
      when(
        api.createForTextureView(any),
      ).thenAnswer((_) async => TexturePlayerIds(playerId: 2, textureId: 102));

      const headers = <String, String>{'Authorization': 'Bearer token'};
      await player.create(
        DataSource(
          sourceType: DataSourceType.network,
          uri: 'https://example.com',
          httpHeaders: headers,
        ),
      );
      final VerificationResult verification = verify(
        api.createForTextureView(captureAny),
      );
      final creationOptions = verification.captured[0] as CreationOptions;
      expect(creationOptions.httpHeaders, headers);
    });

    test('create with file', () async {
      final (
        AVFoundationVideoPlayer player,
        MockAVFoundationVideoPlayerApi api,
        _,
      ) = setUpMockPlayer(
        playerId: 1,
        textureId: 101,
      );
      const newPlayerId = 2;
      when(api.createForTextureView(any)).thenAnswer(
        (_) async => TexturePlayerIds(playerId: newPlayerId, textureId: 102),
      );

      const fileUri = 'file:///foo/bar';
      final int? playerId = await player.create(
        DataSource(sourceType: DataSourceType.file, uri: fileUri),
      );
      final VerificationResult verification = verify(
        api.createForTextureView(captureAny),
      );
      final creationOptions = verification.captured[0] as CreationOptions;
      expect(creationOptions.uri, fileUri);
      expect(playerId, newPlayerId);
      expect(
        player.buildViewWithOptions(VideoViewOptions(playerId: playerId!)),
        isA<Texture>(),
      );
    });

    test('createWithOptions with asset', () async {
      final (
        AVFoundationVideoPlayer player,
        MockAVFoundationVideoPlayerApi api,
        _,
      ) = setUpMockPlayer(
        playerId: 1,
        textureId: 101,
      );
      const newPlayerId = 2;
      when(api.createForTextureView(any)).thenAnswer(
        (_) async => TexturePlayerIds(playerId: newPlayerId, textureId: 102),
      );

      const asset = 'someAsset';
      const package = 'somePackage';
      const assetUrl = 'file:///some/asset/path';
      when(api.getAssetUrl(asset, package)).thenAnswer((_) async => assetUrl);
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

      final VerificationResult verification = verify(
        api.createForTextureView(captureAny),
      );
      final creationOptions = verification.captured[0] as CreationOptions;
      expect(creationOptions.uri, assetUrl);
      expect(playerId, newPlayerId);
      expect(
        player.buildViewWithOptions(VideoViewOptions(playerId: playerId!)),
        isA<Texture>(),
      );
    });

    test('createWithOptions with network', () async {
      final (
        AVFoundationVideoPlayer player,
        MockAVFoundationVideoPlayerApi api,
        _,
      ) = setUpMockPlayer(
        playerId: 1,
        textureId: 101,
      );
      const newPlayerId = 2;
      when(api.createForTextureView(any)).thenAnswer(
        (_) async => TexturePlayerIds(playerId: newPlayerId, textureId: 102),
      );

      const uri = 'https://example.com';
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

      final VerificationResult verification = verify(
        api.createForTextureView(captureAny),
      );
      final creationOptions = verification.captured[0] as CreationOptions;
      expect(creationOptions.uri, uri);
      expect(creationOptions.httpHeaders, <String, String>{});
      expect(playerId, newPlayerId);
      expect(
        player.buildViewWithOptions(VideoViewOptions(playerId: playerId!)),
        isA<Texture>(),
      );
    });

    test('createWithOptions with network passes headers', () async {
      final (
        AVFoundationVideoPlayer player,
        MockAVFoundationVideoPlayerApi api,
        _,
      ) = setUpMockPlayer(
        playerId: 1,
        textureId: 101,
      );
      const newPlayerId = 2;
      when(api.createForTextureView(any)).thenAnswer(
        (_) async => TexturePlayerIds(playerId: newPlayerId, textureId: 102),
      );

      const headers = <String, String>{'Authorization': 'Bearer token'};
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

      final VerificationResult verification = verify(
        api.createForTextureView(captureAny),
      );
      final creationOptions = verification.captured[0] as CreationOptions;
      expect(creationOptions.httpHeaders, headers);
      expect(playerId, newPlayerId);
    });

    test('createWithOptions with file', () async {
      final (
        AVFoundationVideoPlayer player,
        MockAVFoundationVideoPlayerApi api,
        _,
      ) = setUpMockPlayer(
        playerId: 1,
      );
      const newPlayerId = 2;
      const textureId = 100;
      when(api.createForTextureView(any)).thenAnswer(
        (_) async =>
            TexturePlayerIds(playerId: newPlayerId, textureId: textureId),
      );

      const fileUri = 'file:///foo/bar';
      final int? playerId = await player.createWithOptions(
        VideoCreationOptions(
          dataSource: DataSource(sourceType: DataSourceType.file, uri: fileUri),
          viewType: VideoViewType.textureView,
        ),
      );

      final VerificationResult verification = verify(
        api.createForTextureView(captureAny),
      );
      final creationOptions = verification.captured[0] as CreationOptions;
      expect(creationOptions.uri, fileUri);
      expect(playerId, newPlayerId);
      expect(
        player.buildViewWithOptions(VideoViewOptions(playerId: playerId!)),
        isA<Texture>(),
      );
    });

    test('createWithOptions with platform view', () async {
      final (
        AVFoundationVideoPlayer player,
        MockAVFoundationVideoPlayerApi api,
        _,
      ) = setUpMockPlayer(
        playerId: 1,
      );
      const newPlayerId = 2;
      when(api.createForPlatformView(any)).thenAnswer((_) async => newPlayerId);

      final int? playerId = await player.createWithOptions(
        VideoCreationOptions(
          dataSource: DataSource(
            sourceType: DataSourceType.file,
            uri: 'file:///foo/bar',
          ),
          viewType: VideoViewType.platformView,
        ),
      );

      expect(playerId, newPlayerId);
      expect(
        player.buildViewWithOptions(VideoViewOptions(playerId: playerId!)),
        isA<IgnorePointer>(),
      );
    });

    test('setLooping', () async {
      final (
        AVFoundationVideoPlayer player,
        _,
        MockVideoPlayerInstanceApi playerApi,
      ) = setUpMockPlayer(
        playerId: 1,
      );
      await player.setLooping(1, true);

      verify(playerApi.setLooping(true));
    });

    test('play', () async {
      final (
        AVFoundationVideoPlayer player,
        _,
        MockVideoPlayerInstanceApi playerApi,
      ) = setUpMockPlayer(
        playerId: 1,
      );
      await player.play(1);

      verify(playerApi.play());
    });

    test('pause', () async {
      final (
        AVFoundationVideoPlayer player,
        _,
        MockVideoPlayerInstanceApi playerApi,
      ) = setUpMockPlayer(
        playerId: 1,
      );
      await player.pause(1);

      verify(playerApi.pause());
    });

    group('setMixWithOthers', () {
      test('passes true', () async {
        final (
          AVFoundationVideoPlayer player,
          MockAVFoundationVideoPlayerApi api,
          _,
        ) = setUpMockPlayer(
          playerId: 1,
        );
        await player.setMixWithOthers(true);

        verify(api.setMixWithOthers(true));
      });

      test('passes false', () async {
        final (
          AVFoundationVideoPlayer player,
          MockAVFoundationVideoPlayerApi api,
          _,
        ) = setUpMockPlayer(
          playerId: 1,
        );
        await player.setMixWithOthers(false);

        verify(api.setMixWithOthers(false));
      });
    });

    test('setVolume', () async {
      final (
        AVFoundationVideoPlayer player,
        _,
        MockVideoPlayerInstanceApi playerApi,
      ) = setUpMockPlayer(
        playerId: 1,
      );
      const volume = 0.7;
      await player.setVolume(1, volume);

      verify(playerApi.setVolume(volume));
    });

    test('setPlaybackSpeed', () async {
      final (
        AVFoundationVideoPlayer player,
        _,
        MockVideoPlayerInstanceApi playerApi,
      ) = setUpMockPlayer(
        playerId: 1,
      );
      const speed = 1.5;
      await player.setPlaybackSpeed(1, speed);

      verify(playerApi.setPlaybackSpeed(speed));
    });

    test('seekTo', () async {
      final (
        AVFoundationVideoPlayer player,
        _,
        MockVideoPlayerInstanceApi playerApi,
      ) = setUpMockPlayer(
        playerId: 1,
      );
      const positionMilliseconds = 12345;
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
      ) = setUpMockPlayer(
        playerId: 1,
      );
      const positionMilliseconds = 12345;
      when(
        playerApi.getPosition(),
      ).thenAnswer((_) async => positionMilliseconds);

      final Duration position = await player.getPosition(1);
      expect(position, const Duration(milliseconds: positionMilliseconds));
    });

    test('videoEventsFor', () async {
      const playerId = 1;
      final (
        AVFoundationVideoPlayer player,
        MockAVFoundationVideoPlayerApi api,
        _,
      ) = setUpMockPlayer(
        playerId: playerId,
      );
      const mockChannel = 'flutter.dev/videoPlayer/videoEvents$playerId';
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
        player.videoEventsFor(playerId),
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
              DurationRange(Duration.zero, const Duration(milliseconds: 1234)),
              DurationRange(
                const Duration(milliseconds: 1235),
                const Duration(milliseconds: 1235 + 4000),
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

    group('video tracks', () {
      test('isVideoTrackSupportAvailable returns true', () {
        final (AVFoundationVideoPlayer player, _, _) = setUpMockPlayer(
          playerId: 1,
          textureId: 101,
        );

        expect(player.isVideoTrackSupportAvailable(), true);
      });

      test('getVideoTracks returns empty list when no tracks', () async {
        final (
          AVFoundationVideoPlayer player,
          _,
          MockVideoPlayerInstanceApi api,
        ) = setUpMockPlayer(
          playerId: 1,
          textureId: 101,
        );
        when(
          api.getVideoTracks(),
        ).thenAnswer((_) async => NativeVideoTrackData());

        final List<VideoTrack> tracks = await player.getVideoTracks(1);

        expect(tracks, isEmpty);
      });

      test(
        'getVideoTracks converts HLS variant tracks to VideoTrack',
        () async {
          final (
            AVFoundationVideoPlayer player,
            _,
            MockVideoPlayerInstanceApi api,
          ) = setUpMockPlayer(
            playerId: 1,
            textureId: 101,
          );
          when(api.getVideoTracks()).thenAnswer(
            (_) async => NativeVideoTrackData(
              mediaSelectionTracks: <MediaSelectionVideoTrackData>[
                MediaSelectionVideoTrackData(
                  variantIndex: 0,
                  label: '1080p',
                  isSelected: true,
                  bitrate: 5000000,
                  width: 1920,
                  height: 1080,
                  frameRate: 30.0,
                  codec: 'avc1',
                ),
                MediaSelectionVideoTrackData(
                  variantIndex: 1,
                  label: '720p',
                  isSelected: false,
                  bitrate: 2500000,
                  width: 1280,
                  height: 720,
                  frameRate: 30.0,
                  codec: 'avc1',
                ),
              ],
            ),
          );

          final List<VideoTrack> tracks = await player.getVideoTracks(1);

          expect(tracks.length, 2);

          expect(tracks[0].id, 'variant_5000000');
          expect(tracks[0].label, '1080p');
          expect(tracks[0].isSelected, true);
          expect(tracks[0].bitrate, 5000000);
          expect(tracks[0].width, 1920);
          expect(tracks[0].height, 1080);
          expect(tracks[0].frameRate, 30.0);
          expect(tracks[0].codec, 'avc1');

          expect(tracks[1].id, 'variant_2500000');
          expect(tracks[1].label, '720p');
          expect(tracks[1].isSelected, false);
        },
      );

      test(
        'getVideoTracks generates label from resolution if not provided',
        () async {
          final (
            AVFoundationVideoPlayer player,
            _,
            MockVideoPlayerInstanceApi api,
          ) = setUpMockPlayer(
            playerId: 1,
            textureId: 101,
          );
          when(api.getVideoTracks()).thenAnswer(
            (_) async => NativeVideoTrackData(
              mediaSelectionTracks: <MediaSelectionVideoTrackData>[
                MediaSelectionVideoTrackData(
                  variantIndex: 0,
                  isSelected: true,
                  bitrate: 5000000,
                  width: 1920,
                  height: 1080,
                ),
              ],
            ),
          );

          final List<VideoTrack> tracks = await player.getVideoTracks(1);

          expect(tracks.length, 1);
          expect(tracks[0].label, '1080p');
        },
      );

      test(
        'selectVideoTrack with null sets auto quality (bitrate 0)',
        () async {
          final (
            AVFoundationVideoPlayer player,
            _,
            MockVideoPlayerInstanceApi api,
          ) = setUpMockPlayer(
            playerId: 1,
            textureId: 101,
          );
          when(api.selectVideoTrack(0)).thenAnswer((_) async {});

          await player.selectVideoTrack(1, null);

          verify(api.selectVideoTrack(0));
        },
      );

      test('selectVideoTrack with track uses bitrate', () async {
        final (
          AVFoundationVideoPlayer player,
          _,
          MockVideoPlayerInstanceApi api,
        ) = setUpMockPlayer(
          playerId: 1,
          textureId: 101,
        );
        when(api.selectVideoTrack(5000000)).thenAnswer((_) async {});

        const track = VideoTrack(
          id: 'variant_5000000',
          isSelected: false,
          bitrate: 5000000,
        );
        await player.selectVideoTrack(1, track);

        verify(api.selectVideoTrack(5000000));
      });

      test('selectVideoTrack ignores track without bitrate', () async {
        final (
          AVFoundationVideoPlayer player,
          _,
          MockVideoPlayerInstanceApi api,
        ) = setUpMockPlayer(
          playerId: 1,
          textureId: 101,
        );

        const track = VideoTrack(id: 'asset_123', isSelected: false);
        await player.selectVideoTrack(1, track);

        verifyNever(api.selectVideoTrack(any));
      });
    });
  });
}
