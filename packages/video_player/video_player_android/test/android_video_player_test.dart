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

@GenerateNiceMocks(<MockSpec<Object>>[
  MockSpec<AndroidVideoPlayerApi>(),
  MockSpec<VideoPlayerInstanceApi>(),
])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  (AndroidVideoPlayer, MockAndroidVideoPlayerApi, MockVideoPlayerInstanceApi)
  setUpMockPlayer({required int playerId}) {
    final MockAndroidVideoPlayerApi pluginApi = MockAndroidVideoPlayerApi();
    final MockVideoPlayerInstanceApi instanceApi = MockVideoPlayerInstanceApi();
    final AndroidVideoPlayer player = AndroidVideoPlayer(
      pluginApi: pluginApi,
      playerProvider: (_) => instanceApi,
    );
    player.ensureApiInitialized(playerId);
    return (player, pluginApi, instanceApi);
  }

  test('registration', () async {
    AndroidVideoPlayer.registerWith();
    expect(VideoPlayerPlatform.instance, isA<AndroidVideoPlayer>());
  });

  group('AndroidVideoPlayer', () {
    test('init', () async {
      final (
        AndroidVideoPlayer player,
        MockAndroidVideoPlayerApi api,
        _,
      ) = setUpMockPlayer(playerId: 1);
      await player.init();

      verify(api.initialize());
    });

    test('dispose', () async {
      final (
        AndroidVideoPlayer player,
        MockAndroidVideoPlayerApi api,
        _,
      ) = setUpMockPlayer(playerId: 1);
      await player.dispose(1);

      verify(api.dispose(1));
    });

    test('create with asset', () async {
      final (
        AndroidVideoPlayer player,
        MockAndroidVideoPlayerApi api,
        _,
      ) = setUpMockPlayer(playerId: 1);
      const int newPlayerId = 2;
      when(api.create(any)).thenAnswer((_) async => newPlayerId);

      const String asset = 'someAsset';
      const String package = 'somePackage';
      const String assetKey = 'resultingAssetKey';
      when(
        api.getLookupKeyForAsset(asset, package),
      ).thenAnswer((_) async => assetKey);

      final int? playerId = await player.create(
        DataSource(
          sourceType: DataSourceType.asset,
          asset: asset,
          package: package,
        ),
      );

      final VerificationResult verification = verify(api.create(captureAny));
      final CreateMessage createMessage =
          verification.captured[0] as CreateMessage;
      expect(createMessage.uri, 'asset:///$assetKey');
      expect(playerId, newPlayerId);
      expect(
        player.buildViewWithOptions(VideoViewOptions(playerId: playerId!)),
        isA<Texture>(),
      );
    });

    test('create with network', () async {
      final (
        AndroidVideoPlayer player,
        MockAndroidVideoPlayerApi api,
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
      final CreateMessage createMessage =
          verification.captured[0] as CreateMessage;
      expect(createMessage.uri, uri);
      expect(createMessage.formatHint, PlatformVideoFormat.dash);
      expect(createMessage.httpHeaders, <String, String>{});
      expect(playerId, newPlayerId);
      expect(
        player.buildViewWithOptions(VideoViewOptions(playerId: playerId!)),
        isA<Texture>(),
      );
    });

    test('create with network passes headers', () async {
      final (
        AndroidVideoPlayer player,
        MockAndroidVideoPlayerApi api,
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
      final CreateMessage createMessage =
          verification.captured[0] as CreateMessage;
      expect(createMessage.httpHeaders, headers);
    });

    test('create with network sets a default user agent', () async {
      final (
        AndroidVideoPlayer player,
        MockAndroidVideoPlayerApi api,
        _,
      ) = setUpMockPlayer(playerId: 1);
      when(api.create(any)).thenAnswer((_) async => 2);

      await player.create(
        DataSource(
          sourceType: DataSourceType.network,
          uri: 'https://example.com',
          httpHeaders: <String, String>{},
        ),
      );
      final VerificationResult verification = verify(api.create(captureAny));
      final CreateMessage createMessage =
          verification.captured[0] as CreateMessage;
      expect(createMessage.userAgent, 'ExoPlayer');
    });

    test('create with network uses user agent from headers', () async {
      final (
        AndroidVideoPlayer player,
        MockAndroidVideoPlayerApi api,
        _,
      ) = setUpMockPlayer(playerId: 1);
      when(api.create(any)).thenAnswer((_) async => 2);

      const String userAgent = 'Test User Agent';
      const Map<String, String> headers = <String, String>{
        'User-Agent': userAgent,
      };
      await player.create(
        DataSource(
          sourceType: DataSourceType.network,
          uri: 'https://example.com',
          httpHeaders: headers,
        ),
      );
      final VerificationResult verification = verify(api.create(captureAny));
      final CreateMessage createMessage =
          verification.captured[0] as CreateMessage;
      expect(createMessage.userAgent, userAgent);
    });

    test('create with file', () async {
      final (
        AndroidVideoPlayer player,
        MockAndroidVideoPlayerApi api,
        _,
      ) = setUpMockPlayer(playerId: 1);
      when(api.create(any)).thenAnswer((_) async => 2);

      const String fileUri = 'file:///foo/bar';
      final int? playerId = await player.create(
        DataSource(sourceType: DataSourceType.file, uri: fileUri),
      );
      final VerificationResult verification = verify(api.create(captureAny));
      final CreateMessage createMessage =
          verification.captured[0] as CreateMessage;
      expect(createMessage.uri, fileUri);
      expect(
        player.buildViewWithOptions(VideoViewOptions(playerId: playerId!)),
        isA<Texture>(),
      );
    });

    test('create with file passes headers', () async {
      final (
        AndroidVideoPlayer player,
        MockAndroidVideoPlayerApi api,
        _,
      ) = setUpMockPlayer(playerId: 1);
      when(api.create(any)).thenAnswer((_) async => 2);

      const String fileUri = 'file:///foo/bar';
      const Map<String, String> headers = <String, String>{
        'Authorization': 'Bearer token',
      };
      await player.create(
        DataSource(
          sourceType: DataSourceType.file,
          uri: fileUri,
          httpHeaders: headers,
        ),
      );
      final VerificationResult verification = verify(api.create(captureAny));
      final CreateMessage createMessage =
          verification.captured[0] as CreateMessage;
      expect(createMessage.httpHeaders, headers);
    });

    test('createWithOptions with asset', () async {
      final (
        AndroidVideoPlayer player,
        MockAndroidVideoPlayerApi api,
        _,
      ) = setUpMockPlayer(playerId: 1);
      const int newPlayerId = 2;
      when(api.create(any)).thenAnswer((_) async => newPlayerId);

      const String asset = 'someAsset';
      const String package = 'somePackage';
      const String assetKey = 'resultingAssetKey';
      when(
        api.getLookupKeyForAsset(asset, package),
      ).thenAnswer((_) async => assetKey);

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
      final CreateMessage createMessage =
          verification.captured[0] as CreateMessage;
      expect(createMessage.uri, 'asset:///$assetKey');
      expect(playerId, newPlayerId);
      expect(
        player.buildViewWithOptions(VideoViewOptions(playerId: playerId!)),
        isA<Texture>(),
      );
    });

    test('createWithOptions with network', () async {
      final (
        AndroidVideoPlayer player,
        MockAndroidVideoPlayerApi api,
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
      final CreateMessage createMessage =
          verification.captured[0] as CreateMessage;
      expect(createMessage.uri, uri);
      expect(createMessage.formatHint, PlatformVideoFormat.dash);
      expect(createMessage.httpHeaders, <String, String>{});
      expect(playerId, newPlayerId);
      expect(
        player.buildViewWithOptions(VideoViewOptions(playerId: playerId!)),
        isA<Texture>(),
      );
    });

    test('createWithOptions with network passes headers', () async {
      final (
        AndroidVideoPlayer player,
        MockAndroidVideoPlayerApi api,
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
      final CreateMessage createMessage =
          verification.captured[0] as CreateMessage;
      expect(createMessage.httpHeaders, headers);
      expect(playerId, newPlayerId);
    });

    test('createWithOptions with file', () async {
      final (
        AndroidVideoPlayer player,
        MockAndroidVideoPlayerApi api,
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
      final CreateMessage createMessage =
          verification.captured[0] as CreateMessage;
      expect(createMessage.uri, fileUri);
      expect(playerId, newPlayerId);
      expect(
        player.buildViewWithOptions(VideoViewOptions(playerId: playerId!)),
        isA<Texture>(),
      );
    });

    test('createWithOptions with file passes headers', () async {
      final (
        AndroidVideoPlayer player,
        MockAndroidVideoPlayerApi api,
        _,
      ) = setUpMockPlayer(playerId: 1);
      when(api.create(any)).thenAnswer((_) async => 2);

      const String fileUri = 'file:///foo/bar';
      const Map<String, String> headers = <String, String>{
        'Authorization': 'Bearer token',
      };
      await player.createWithOptions(
        VideoCreationOptions(
          dataSource: DataSource(
            sourceType: DataSourceType.file,
            uri: fileUri,
            httpHeaders: headers,
          ),
          viewType: VideoViewType.textureView,
        ),
      );

      final VerificationResult verification = verify(api.create(captureAny));
      final CreateMessage createMessage =
          verification.captured[0] as CreateMessage;
      expect(createMessage.httpHeaders, headers);
    });

    test('createWithOptions with platform view', () async {
      final (
        AndroidVideoPlayer player,
        MockAndroidVideoPlayerApi api,
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
      final CreateMessage createMessage =
          verification.captured[0] as CreateMessage;
      expect(createMessage.viewType, PlatformVideoViewType.platformView);
      expect(playerId, newPlayerId);
      expect(
        player.buildViewWithOptions(VideoViewOptions(playerId: playerId!)),
        isA<PlatformViewPlayer>(),
      );
    });

    test('setLooping', () async {
      final (
        AndroidVideoPlayer player,
        _,
        MockVideoPlayerInstanceApi playerApi,
      ) = setUpMockPlayer(playerId: 1);
      await player.setLooping(1, true);

      verify(playerApi.setLooping(true));
    });

    test('play', () async {
      final (
        AndroidVideoPlayer player,
        _,
        MockVideoPlayerInstanceApi playerApi,
      ) = setUpMockPlayer(playerId: 1);
      await player.play(1);

      verify(playerApi.play());
    });

    test('pause', () async {
      final (
        AndroidVideoPlayer player,
        _,
        MockVideoPlayerInstanceApi playerApi,
      ) = setUpMockPlayer(playerId: 1);
      await player.pause(1);

      verify(playerApi.pause());
    });

    group('setMixWithOthers', () {
      test('passes true', () async {
        final (
          AndroidVideoPlayer player,
          MockAndroidVideoPlayerApi api,
          _,
        ) = setUpMockPlayer(playerId: 1);
        await player.setMixWithOthers(true);

        verify(api.setMixWithOthers(true));
      });

      test('passes false', () async {
        final (
          AndroidVideoPlayer player,
          MockAndroidVideoPlayerApi api,
          _,
        ) = setUpMockPlayer(playerId: 1);
        await player.setMixWithOthers(false);

        verify(api.setMixWithOthers(false));
      });
    });

    test('setVolume', () async {
      final (
        AndroidVideoPlayer player,
        _,
        MockVideoPlayerInstanceApi playerApi,
      ) = setUpMockPlayer(playerId: 1);
      const double volume = 0.7;
      await player.setVolume(1, volume);

      verify(playerApi.setVolume(volume));
    });

    test('setPlaybackSpeed', () async {
      final (
        AndroidVideoPlayer player,
        _,
        MockVideoPlayerInstanceApi playerApi,
      ) = setUpMockPlayer(playerId: 1);
      const double speed = 1.5;
      await player.setPlaybackSpeed(1, speed);

      verify(playerApi.setPlaybackSpeed(speed));
    });

    test('seekTo', () async {
      final (
        AndroidVideoPlayer player,
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
        AndroidVideoPlayer player,
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
        AndroidVideoPlayer player,
        MockAndroidVideoPlayerApi api,
        _,
      ) = setUpMockPlayer(playerId: 1);
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
                        'position': 1234,
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

    group('getAudioTracks', () {
      test('returns audio tracks with complete metadata', () async {
        final (
          AndroidVideoPlayer player,
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
            label: 'Spanish',
            language: 'es',
            isSelected: false,
            bitrate: 96000,
            sampleRate: 44100,
            channelCount: 2,
            codec: 'mp3',
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
        expect(tracks[1].label, 'Spanish');
        expect(tracks[1].language, 'es');
        expect(tracks[1].isSelected, false);
        expect(tracks[1].bitrate, 96000);
        expect(tracks[1].sampleRate, 44100);
        expect(tracks[1].channelCount, 2);
        expect(tracks[1].codec, 'mp3');

        verify(instanceApi.getAudioTracks()).called(1);
      });

      test('returns audio tracks with partial metadata', () async {
        final (
          AndroidVideoPlayer player,
          _,
          MockVideoPlayerInstanceApi instanceApi,
        ) = setUpMockPlayer(playerId: 1);

        final List<AudioTrackMessage> mockTracks = <AudioTrackMessage>[
          AudioTrackMessage(
            id: 'track1',
            label: 'Default',
            language: 'und',
            isSelected: true,
          ),
          AudioTrackMessage(
            id: 'track2',
            label: 'High Quality',
            language: 'en',
            isSelected: false,
            bitrate: 256000,
            sampleRate: 48000,
            codec: 'aac',
          ),
        ];

        when(instanceApi.getAudioTracks()).thenAnswer((_) async => mockTracks);

        final List<VideoAudioTrack> tracks = await player.getAudioTracks(1);

        expect(tracks, hasLength(2));
        
        expect(tracks[0].id, 'track1');
        expect(tracks[0].label, 'Default');
        expect(tracks[0].language, 'und');
        expect(tracks[0].isSelected, true);
        expect(tracks[0].bitrate, null);
        expect(tracks[0].sampleRate, null);
        expect(tracks[0].channelCount, null);
        expect(tracks[0].codec, null);

        expect(tracks[1].id, 'track2');
        expect(tracks[1].label, 'High Quality');
        expect(tracks[1].language, 'en');
        expect(tracks[1].isSelected, false);
        expect(tracks[1].bitrate, 256000);
        expect(tracks[1].sampleRate, 48000);
        expect(tracks[1].channelCount, null);
        expect(tracks[1].codec, 'aac');

        verify(instanceApi.getAudioTracks()).called(1);
      });

      test('returns empty list when no audio tracks available', () async {
        final (
          AndroidVideoPlayer player,
          _,
          MockVideoPlayerInstanceApi instanceApi,
        ) = setUpMockPlayer(playerId: 1);

        when(instanceApi.getAudioTracks()).thenAnswer((_) async => <AudioTrackMessage>[]);

        final List<VideoAudioTrack> tracks = await player.getAudioTracks(1);

        expect(tracks, isEmpty);
        verify(instanceApi.getAudioTracks()).called(1);
      });

      test('handles different channel configurations', () async {
        final (
          AndroidVideoPlayer player,
          _,
          MockVideoPlayerInstanceApi instanceApi,
        ) = setUpMockPlayer(playerId: 1);

        final List<AudioTrackMessage> mockTracks = <AudioTrackMessage>[
          AudioTrackMessage(
            id: 'mono',
            label: 'Mono Track',
            language: 'en',
            isSelected: false,
            bitrate: 64000,
            sampleRate: 22050,
            channelCount: 1,
            codec: 'aac',
          ),
          AudioTrackMessage(
            id: 'stereo',
            label: 'Stereo Track',
            language: 'en',
            isSelected: true,
            bitrate: 128000,
            sampleRate: 44100,
            channelCount: 2,
            codec: 'aac',
          ),
          AudioTrackMessage(
            id: 'surround',
            label: '5.1 Surround',
            language: 'en',
            isSelected: false,
            bitrate: 384000,
            sampleRate: 48000,
            channelCount: 6,
            codec: 'ac3',
          ),
          AudioTrackMessage(
            id: 'surround71',
            label: '7.1 Surround',
            language: 'en',
            isSelected: false,
            bitrate: 512000,
            sampleRate: 48000,
            channelCount: 8,
            codec: 'eac3',
          ),
        ];

        when(instanceApi.getAudioTracks()).thenAnswer((_) async => mockTracks);

        final List<VideoAudioTrack> tracks = await player.getAudioTracks(1);

        expect(tracks, hasLength(4));
        expect(tracks[0].channelCount, 1);
        expect(tracks[1].channelCount, 2);
        expect(tracks[2].channelCount, 6);
        expect(tracks[3].channelCount, 8);

        verify(instanceApi.getAudioTracks()).called(1);
      });

      test('handles different codec types', () async {
        final (
          AndroidVideoPlayer player,
          _,
          MockVideoPlayerInstanceApi instanceApi,
        ) = setUpMockPlayer(playerId: 1);

        final List<AudioTrackMessage> mockTracks = <AudioTrackMessage>[
          AudioTrackMessage(
            id: 'aac_track',
            label: 'AAC Track',
            language: 'en',
            isSelected: true,
            bitrate: 128000,
            sampleRate: 48000,
            channelCount: 2,
            codec: 'aac',
          ),
          AudioTrackMessage(
            id: 'mp3_track',
            label: 'MP3 Track',
            language: 'en',
            isSelected: false,
            bitrate: 320000,
            sampleRate: 44100,
            channelCount: 2,
            codec: 'mp3',
          ),
          AudioTrackMessage(
            id: 'opus_track',
            label: 'Opus Track',
            language: 'en',
            isSelected: false,
            bitrate: 96000,
            sampleRate: 48000,
            channelCount: 2,
            codec: 'opus',
          ),
        ];

        when(instanceApi.getAudioTracks()).thenAnswer((_) async => mockTracks);

        final List<VideoAudioTrack> tracks = await player.getAudioTracks(1);

        expect(tracks, hasLength(3));
        expect(tracks[0].codec, 'aac');
        expect(tracks[1].codec, 'mp3');
        expect(tracks[2].codec, 'opus');

        verify(instanceApi.getAudioTracks()).called(1);
      });

      test('throws PlatformException when native method fails', () async {
        final (
          AndroidVideoPlayer player,
          _,
          MockVideoPlayerInstanceApi instanceApi,
        ) = setUpMockPlayer(playerId: 1);

        when(instanceApi.getAudioTracks()).thenThrow(
          PlatformException(
            code: 'AUDIO_TRACKS_ERROR',
            message: 'Failed to retrieve audio tracks',
          ),
        );

        expect(
          () => player.getAudioTracks(1),
          throwsA(isA<PlatformException>()),
        );

        verify(instanceApi.getAudioTracks()).called(1);
      });
    });
  });
}
