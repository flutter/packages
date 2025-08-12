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
      const String assetUrl = 'file:///some/asset/path';
      when(
        api.getAssetUrl(asset, package),
      ).thenAnswer((_) async => assetUrl);

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
      expect(creationOptions.uri, assetUrl);
      expect(playerId, newPlayerId);
      expect(player.playerViewStates[newPlayerId],
          const VideoPlayerTextureViewState(textureId: newPlayerId));
    });

    test('create with asset throws PlatformException for missing asset',
        () async {
      final (
        AVFoundationVideoPlayer player,
        MockAVFoundationVideoPlayerApi api,
        _,
      ) = setUpMockPlayer(playerId: 1);

      const String asset = 'someAsset';
      const String package = 'somePackage';
      when(
        api.getAssetUrl(asset, package),
      ).thenAnswer((_) async => null);

      expect(
          player.create(
            DataSource(
              sourceType: DataSourceType.asset,
              asset: asset,
              package: package,
            ),
          ),
          throwsA(isA<PlatformException>()));
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
      expect(creationOptions.uri, uri);
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
      const String assetUrl = 'file:///some/asset/path';
      when(
        api.getAssetUrl(asset, package),
      ).thenAnswer((_) async => assetUrl);
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
      expect(creationOptions.uri, assetUrl);
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
      expect(creationOptions.uri, uri);
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
                    const Duration(milliseconds: 1235 + 4000),
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

    group('getAudioTracks', () {
      test('returns audio tracks with complete metadata', () async {
        final (
          AVFoundationVideoPlayer player,
          _,
          MockVideoPlayerInstanceApi instanceApi,
        ) = setUpMockPlayer(playerId: 1);

        final List<AudioTrackMessage> mockTracks = <AudioTrackMessage>[
          AudioTrackMessage(
            id: 'track1',
            label: 'English',
            language: 'en',
            isSelected: true,
            bitrate: 128000,
            sampleRate: 48000,
            channelCount: 2,
            codec: 'aac',
          ),
          AudioTrackMessage(
            id: 'track2',
            label: 'French',
            language: 'fr',
            isSelected: false,
            bitrate: 96000,
            sampleRate: 44100,
            channelCount: 2,
            codec: 'aac',
          ),
        ];

        when(instanceApi.getAudioTracks()).thenAnswer((_) async => mockTracks);

        final List<VideoAudioTrack> tracks = await player.getAudioTracks(1);

        expect(tracks, hasLength(2));
        
        expect(tracks[0].id, 'track1');
        expect(tracks[0].label, 'English');
        expect(tracks[0].language, 'en');
        expect(tracks[0].isSelected, true);
        expect(tracks[0].bitrate, 128000);
        expect(tracks[0].sampleRate, 48000);
        expect(tracks[0].channelCount, 2);
        expect(tracks[0].codec, 'aac');

        expect(tracks[1].id, 'track2');
        expect(tracks[1].label, 'French');
        expect(tracks[1].language, 'fr');
        expect(tracks[1].isSelected, false);
        expect(tracks[1].bitrate, 96000);
        expect(tracks[1].sampleRate, 44100);
        expect(tracks[1].channelCount, 2);
        expect(tracks[1].codec, 'aac');

        verify(instanceApi.getAudioTracks()).called(1);
      });

      test('returns audio tracks with partial metadata from HLS streams', () async {
        final (
          AVFoundationVideoPlayer player,
          _,
          MockVideoPlayerInstanceApi instanceApi,
        ) = setUpMockPlayer(playerId: 1);

        final List<AudioTrackMessage> mockTracks = <AudioTrackMessage>[
          AudioTrackMessage(
            id: 'hls_track1',
            label: 'Default Audio',
            language: 'und',
            isSelected: true,
          ),
          AudioTrackMessage(
            id: 'hls_track2',
            label: 'High Quality',
            language: 'en',
            isSelected: false,
            bitrate: 256000,
            sampleRate: 48000,
            channelCount: 2,
            codec: 'aac',
          ),
        ];

        when(instanceApi.getAudioTracks()).thenAnswer((_) async => mockTracks);

        final List<VideoAudioTrack> tracks = await player.getAudioTracks(1);

        expect(tracks, hasLength(2));
        
        expect(tracks[0].id, 'hls_track1');
        expect(tracks[0].label, 'Default Audio');
        expect(tracks[0].language, 'und');
        expect(tracks[0].isSelected, true);
        expect(tracks[0].bitrate, null);
        expect(tracks[0].sampleRate, null);
        expect(tracks[0].channelCount, null);
        expect(tracks[0].codec, null);

        expect(tracks[1].id, 'hls_track2');
        expect(tracks[1].label, 'High Quality');
        expect(tracks[1].language, 'en');
        expect(tracks[1].isSelected, false);
        expect(tracks[1].bitrate, 256000);
        expect(tracks[1].sampleRate, 48000);
        expect(tracks[1].channelCount, 2);
        expect(tracks[1].codec, 'aac');

        verify(instanceApi.getAudioTracks()).called(1);
      });

      test('returns empty list when no audio tracks available', () async {
        final (
          AVFoundationVideoPlayer player,
          _,
          MockVideoPlayerInstanceApi instanceApi,
        ) = setUpMockPlayer(playerId: 1);

        when(instanceApi.getAudioTracks()).thenAnswer((_) async => <AudioTrackMessage>[]);

        final List<VideoAudioTrack> tracks = await player.getAudioTracks(1);

        expect(tracks, isEmpty);
        verify(instanceApi.getAudioTracks()).called(1);
      });

      test('handles AVFoundation specific channel configurations', () async {
        final (
          AVFoundationVideoPlayer player,
          _,
          MockVideoPlayerInstanceApi instanceApi,
        ) = setUpMockPlayer(playerId: 1);

        final List<AudioTrackMessage> mockTracks = <AudioTrackMessage>[
          AudioTrackMessage(
            id: 'mono_track',
            label: 'Mono Commentary',
            language: 'en',
            isSelected: false,
            bitrate: 64000,
            sampleRate: 22050,
            channelCount: 1,
            codec: 'aac',
          ),
          AudioTrackMessage(
            id: 'stereo_track',
            label: 'Stereo Music',
            language: 'en',
            isSelected: true,
            bitrate: 128000,
            sampleRate: 44100,
            channelCount: 2,
            codec: 'aac',
          ),
          AudioTrackMessage(
            id: 'surround_track',
            label: '5.1 Surround',
            language: 'en',
            isSelected: false,
            bitrate: 384000,
            sampleRate: 48000,
            channelCount: 6,
            codec: 'ac-3',
          ),
        ];

        when(instanceApi.getAudioTracks()).thenAnswer((_) async => mockTracks);

        final List<VideoAudioTrack> tracks = await player.getAudioTracks(1);

        expect(tracks, hasLength(3));
        expect(tracks[0].channelCount, 1);
        expect(tracks[1].channelCount, 2);
        expect(tracks[2].channelCount, 6);
        expect(tracks[2].codec, 'ac-3'); // AVFoundation specific codec format

        verify(instanceApi.getAudioTracks()).called(1);
      });

      test('handles different sample rates common in iOS', () async {
        final (
          AVFoundationVideoPlayer player,
          _,
          MockVideoPlayerInstanceApi instanceApi,
        ) = setUpMockPlayer(playerId: 1);

        final List<AudioTrackMessage> mockTracks = <AudioTrackMessage>[
          AudioTrackMessage(
            id: 'low_quality',
            label: 'Low Quality',
            language: 'en',
            isSelected: false,
            bitrate: 32000,
            sampleRate: 22050,
            channelCount: 1,
            codec: 'aac',
          ),
          AudioTrackMessage(
            id: 'cd_quality',
            label: 'CD Quality',
            language: 'en',
            isSelected: true,
            bitrate: 128000,
            sampleRate: 44100,
            channelCount: 2,
            codec: 'aac',
          ),
          AudioTrackMessage(
            id: 'high_res',
            label: 'High Resolution',
            language: 'en',
            isSelected: false,
            bitrate: 256000,
            sampleRate: 48000,
            channelCount: 2,
            codec: 'aac',
          ),
          AudioTrackMessage(
            id: 'studio_quality',
            label: 'Studio Quality',
            language: 'en',
            isSelected: false,
            bitrate: 320000,
            sampleRate: 96000,
            channelCount: 2,
            codec: 'alac',
          ),
        ];

        when(instanceApi.getAudioTracks()).thenAnswer((_) async => mockTracks);

        final List<VideoAudioTrack> tracks = await player.getAudioTracks(1);

        expect(tracks, hasLength(4));
        expect(tracks[0].sampleRate, 22050);
        expect(tracks[1].sampleRate, 44100);
        expect(tracks[2].sampleRate, 48000);
        expect(tracks[3].sampleRate, 96000);
        expect(tracks[3].codec, 'alac'); // Apple Lossless codec

        verify(instanceApi.getAudioTracks()).called(1);
      });

      test('handles multilingual tracks typical in iOS apps', () async {
        final (
          AVFoundationVideoPlayer player,
          _,
          MockVideoPlayerInstanceApi instanceApi,
        ) = setUpMockPlayer(playerId: 1);

        final List<AudioTrackMessage> mockTracks = <AudioTrackMessage>[
          AudioTrackMessage(
            id: 'en_track',
            label: 'English',
            language: 'en',
            isSelected: true,
            bitrate: 128000,
            sampleRate: 48000,
            channelCount: 2,
            codec: 'aac',
          ),
          AudioTrackMessage(
            id: 'es_track',
            label: 'Español',
            language: 'es',
            isSelected: false,
            bitrate: 128000,
            sampleRate: 48000,
            channelCount: 2,
            codec: 'aac',
          ),
          AudioTrackMessage(
            id: 'fr_track',
            label: 'Français',
            language: 'fr',
            isSelected: false,
            bitrate: 128000,
            sampleRate: 48000,
            channelCount: 2,
            codec: 'aac',
          ),
          AudioTrackMessage(
            id: 'ja_track',
            label: '日本語',
            language: 'ja',
            isSelected: false,
            bitrate: 128000,
            sampleRate: 48000,
            channelCount: 2,
            codec: 'aac',
          ),
        ];

        when(instanceApi.getAudioTracks()).thenAnswer((_) async => mockTracks);

        final List<VideoAudioTrack> tracks = await player.getAudioTracks(1);

        expect(tracks, hasLength(4));
        expect(tracks[0].language, 'en');
        expect(tracks[1].language, 'es');
        expect(tracks[2].language, 'fr');
        expect(tracks[3].language, 'ja');
        expect(tracks[3].label, '日本語'); // Unicode support

        verify(instanceApi.getAudioTracks()).called(1);
      });

      test('throws PlatformException when AVFoundation method fails', () async {
        final (
          AVFoundationVideoPlayer player,
          _,
          MockVideoPlayerInstanceApi instanceApi,
        ) = setUpMockPlayer(playerId: 1);

        when(instanceApi.getAudioTracks()).thenThrow(
          PlatformException(
            code: 'AVFOUNDATION_ERROR',
            message: 'Failed to retrieve audio tracks from AVAsset',
          ),
        );

        expect(
          () => player.getAudioTracks(1),
          throwsA(isA<PlatformException>()),
        );

        verify(instanceApi.getAudioTracks()).called(1);
      });

      test('handles tracks with AVFoundation specific codec identifiers', () async {
        final (
          AVFoundationVideoPlayer player,
          _,
          MockVideoPlayerInstanceApi instanceApi,
        ) = setUpMockPlayer(playerId: 1);

        final List<AudioTrackMessage> mockTracks = <AudioTrackMessage>[
          AudioTrackMessage(
            id: 'aac_track',
            label: 'AAC Audio',
            language: 'en',
            isSelected: true,
            bitrate: 128000,
            sampleRate: 48000,
            channelCount: 2,
            codec: 'mp4a.40.2', // AAC-LC in AVFoundation format
          ),
          AudioTrackMessage(
            id: 'alac_track',
            label: 'Apple Lossless',
            language: 'en',
            isSelected: false,
            bitrate: 1000000,
            sampleRate: 48000,
            channelCount: 2,
            codec: 'alac',
          ),
          AudioTrackMessage(
            id: 'ac3_track',
            label: 'Dolby Digital',
            language: 'en',
            isSelected: false,
            bitrate: 384000,
            sampleRate: 48000,
            channelCount: 6,
            codec: 'ac-3',
          ),
        ];

        when(instanceApi.getAudioTracks()).thenAnswer((_) async => mockTracks);

        final List<VideoAudioTrack> tracks = await player.getAudioTracks(1);

        expect(tracks, hasLength(3));
        expect(tracks[0].codec, 'mp4a.40.2');
        expect(tracks[1].codec, 'alac');
        expect(tracks[2].codec, 'ac-3');

        verify(instanceApi.getAudioTracks()).called(1);
      });
    });
  });
}
