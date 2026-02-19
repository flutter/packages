// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

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

  // Provide dummy values for audio track types
  provideDummy<NativeAudioTrackData>(
    NativeAudioTrackData(exoPlayerTracks: <ExoPlayerAudioTrackData>[]),
  );
  provideDummy<Future<NativeAudioTrackData>>(
    Future<NativeAudioTrackData>.value(
      NativeAudioTrackData(exoPlayerTracks: <ExoPlayerAudioTrackData>[]),
    ),
  );
  provideDummy<Future<void>>(Future<void>.value());

  (AndroidVideoPlayer, MockAndroidVideoPlayerApi, MockVideoPlayerInstanceApi)
  setUpMockPlayer({required int playerId, int? textureId}) {
    final pluginApi = MockAndroidVideoPlayerApi();
    final instanceApi = MockVideoPlayerInstanceApi();
    final player = AndroidVideoPlayer(
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

  (
    AndroidVideoPlayer,
    MockAndroidVideoPlayerApi,
    MockVideoPlayerInstanceApi,
    StreamController<PlatformVideoEvent>,
  )
  setUpMockPlayerWithStream({required int playerId, int? textureId}) {
    final pluginApi = MockAndroidVideoPlayerApi();
    final instanceApi = MockVideoPlayerInstanceApi();
    final streamController = StreamController<PlatformVideoEvent>();
    final player = AndroidVideoPlayer(
      pluginApi: pluginApi,
      playerApiProvider: (_) => instanceApi,
      videoEventStreamProvider: (_) =>
          streamController.stream.asBroadcastStream(),
    );
    player.ensurePlayerInitialized(
      playerId,
      textureId == null
          ? const VideoPlayerPlatformViewState()
          : VideoPlayerTextureViewState(textureId: textureId),
    );
    return (player, pluginApi, instanceApi, streamController);
  }

  test('registration', () async {
    AndroidVideoPlayer.registerWith();
    expect(VideoPlayerPlatform.instance, isA<AndroidVideoPlayer>());
  });

  group('AndroidVideoPlayer', () {
    test('init', () async {
      final (AndroidVideoPlayer player, MockAndroidVideoPlayerApi api, _) =
          setUpMockPlayer(playerId: 1);
      await player.init();

      verify(api.initialize());
    });

    test('dispose', () async {
      final (AndroidVideoPlayer player, MockAndroidVideoPlayerApi api, _) =
          setUpMockPlayer(playerId: 1);
      await player.dispose(1);

      verify(api.dispose(1));
    });

    test('create with asset', () async {
      final (AndroidVideoPlayer player, MockAndroidVideoPlayerApi api, _) =
          setUpMockPlayer(playerId: 1, textureId: 100);
      const newPlayerId = 2;
      when(api.createForTextureView(any)).thenAnswer(
        (_) async => TexturePlayerIds(playerId: newPlayerId, textureId: 100),
      );

      const asset = 'someAsset';
      const package = 'somePackage';
      const assetKey = 'resultingAssetKey';
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

      final VerificationResult verification = verify(
        api.createForTextureView(captureAny),
      );
      final creationOptions = verification.captured[0] as CreationOptions;
      expect(creationOptions.uri, 'asset:///$assetKey');
      expect(playerId, newPlayerId);
      expect(
        player.buildViewWithOptions(VideoViewOptions(playerId: playerId!)),
        isA<Texture>(),
      );
    });

    test('create with network', () async {
      final (AndroidVideoPlayer player, MockAndroidVideoPlayerApi api, _) =
          setUpMockPlayer(playerId: 1, textureId: 100);
      const newPlayerId = 2;
      when(api.createForTextureView(any)).thenAnswer(
        (_) async => TexturePlayerIds(playerId: newPlayerId, textureId: 100),
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
      expect(creationOptions.formatHint, PlatformVideoFormat.dash);
      expect(creationOptions.httpHeaders, <String, String>{});
      expect(playerId, newPlayerId);
      expect(
        player.buildViewWithOptions(VideoViewOptions(playerId: playerId!)),
        isA<Texture>(),
      );
    });

    test('create with network passes headers', () async {
      final (AndroidVideoPlayer player, MockAndroidVideoPlayerApi api, _) =
          setUpMockPlayer(playerId: 1, textureId: 100);
      when(
        api.createForTextureView(any),
      ).thenAnswer((_) async => TexturePlayerIds(playerId: 2, textureId: 100));

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

    test('create with network sets a default user agent', () async {
      final (AndroidVideoPlayer player, MockAndroidVideoPlayerApi api, _) =
          setUpMockPlayer(playerId: 1, textureId: 100);
      when(
        api.createForTextureView(any),
      ).thenAnswer((_) async => TexturePlayerIds(playerId: 2, textureId: 100));

      await player.create(
        DataSource(
          sourceType: DataSourceType.network,
          uri: 'https://example.com',
          httpHeaders: <String, String>{},
        ),
      );
      final VerificationResult verification = verify(
        api.createForTextureView(captureAny),
      );
      final creationOptions = verification.captured[0] as CreationOptions;
      expect(creationOptions.userAgent, 'ExoPlayer');
    });

    test('create with network uses user agent from headers', () async {
      final (AndroidVideoPlayer player, MockAndroidVideoPlayerApi api, _) =
          setUpMockPlayer(playerId: 1, textureId: 100);
      when(
        api.createForTextureView(any),
      ).thenAnswer((_) async => TexturePlayerIds(playerId: 2, textureId: 100));

      const userAgent = 'Test User Agent';
      const headers = <String, String>{'User-Agent': userAgent};
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
      expect(creationOptions.userAgent, userAgent);
    });

    test('create with file', () async {
      final (AndroidVideoPlayer player, MockAndroidVideoPlayerApi api, _) =
          setUpMockPlayer(playerId: 1, textureId: 100);
      when(
        api.createForTextureView(any),
      ).thenAnswer((_) async => TexturePlayerIds(playerId: 2, textureId: 100));

      const fileUri = 'file:///foo/bar';
      final int? playerId = await player.create(
        DataSource(sourceType: DataSourceType.file, uri: fileUri),
      );
      final VerificationResult verification = verify(
        api.createForTextureView(captureAny),
      );
      final creationOptions = verification.captured[0] as CreationOptions;
      expect(creationOptions.uri, fileUri);
      expect(
        player.buildViewWithOptions(VideoViewOptions(playerId: playerId!)),
        isA<Texture>(),
      );
    });

    test('create with file passes headers', () async {
      final (AndroidVideoPlayer player, MockAndroidVideoPlayerApi api, _) =
          setUpMockPlayer(playerId: 1, textureId: 100);
      when(
        api.createForTextureView(any),
      ).thenAnswer((_) async => TexturePlayerIds(playerId: 2, textureId: 100));

      const fileUri = 'file:///foo/bar';
      const headers = <String, String>{'Authorization': 'Bearer token'};
      await player.create(
        DataSource(
          sourceType: DataSourceType.file,
          uri: fileUri,
          httpHeaders: headers,
        ),
      );
      final VerificationResult verification = verify(
        api.createForTextureView(captureAny),
      );
      final creationOptions = verification.captured[0] as CreationOptions;
      expect(creationOptions.httpHeaders, headers);
    });

    test('createWithOptions with asset', () async {
      final (AndroidVideoPlayer player, MockAndroidVideoPlayerApi api, _) =
          setUpMockPlayer(playerId: 1, textureId: 100);
      const newPlayerId = 2;
      when(api.createForTextureView(any)).thenAnswer(
        (_) async => TexturePlayerIds(playerId: newPlayerId, textureId: 100),
      );

      const asset = 'someAsset';
      const package = 'somePackage';
      const assetKey = 'resultingAssetKey';
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

      final VerificationResult verification = verify(
        api.createForTextureView(captureAny),
      );
      final creationOptions = verification.captured[0] as CreationOptions;
      expect(creationOptions.uri, 'asset:///$assetKey');
      expect(playerId, newPlayerId);
      expect(
        player.buildViewWithOptions(VideoViewOptions(playerId: playerId!)),
        isA<Texture>(),
      );
    });

    test('createWithOptions with network', () async {
      final (AndroidVideoPlayer player, MockAndroidVideoPlayerApi api, _) =
          setUpMockPlayer(playerId: 1, textureId: 100);
      const newPlayerId = 2;
      when(api.createForTextureView(any)).thenAnswer(
        (_) async => TexturePlayerIds(playerId: newPlayerId, textureId: 100),
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
      expect(creationOptions.formatHint, PlatformVideoFormat.dash);
      expect(creationOptions.httpHeaders, <String, String>{});
      expect(playerId, newPlayerId);
      expect(
        player.buildViewWithOptions(VideoViewOptions(playerId: playerId!)),
        isA<Texture>(),
      );
    });

    test('createWithOptions with network passes headers', () async {
      final (AndroidVideoPlayer player, MockAndroidVideoPlayerApi api, _) =
          setUpMockPlayer(playerId: 1, textureId: 100);
      const newPlayerId = 2;
      when(api.createForTextureView(any)).thenAnswer(
        (_) async => TexturePlayerIds(playerId: newPlayerId, textureId: 100),
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
      final (AndroidVideoPlayer player, MockAndroidVideoPlayerApi api, _) =
          setUpMockPlayer(playerId: 1, textureId: 100);
      const newPlayerId = 2;
      when(api.createForTextureView(any)).thenAnswer(
        (_) async => TexturePlayerIds(playerId: newPlayerId, textureId: 100),
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

    test('createWithOptions with file passes headers', () async {
      final (AndroidVideoPlayer player, MockAndroidVideoPlayerApi api, _) =
          setUpMockPlayer(playerId: 1, textureId: 100);
      when(
        api.createForTextureView(any),
      ).thenAnswer((_) async => TexturePlayerIds(playerId: 2, textureId: 100));

      const fileUri = 'file:///foo/bar';
      const headers = <String, String>{'Authorization': 'Bearer token'};
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

      final VerificationResult verification = verify(
        api.createForTextureView(captureAny),
      );
      final creationOptions = verification.captured[0] as CreationOptions;
      expect(creationOptions.httpHeaders, headers);
    });

    test('createWithOptions with platform view', () async {
      final (AndroidVideoPlayer player, MockAndroidVideoPlayerApi api, _) =
          setUpMockPlayer(playerId: 1);
      const newPlayerId = 2;
      when(api.createForPlatformView(any)).thenAnswer((_) async => newPlayerId);

      const uri = 'file:///foo/bar';
      final int? playerId = await player.createWithOptions(
        VideoCreationOptions(
          dataSource: DataSource(sourceType: DataSourceType.file, uri: uri),
          viewType: VideoViewType.platformView,
        ),
      );

      final VerificationResult verification = verify(
        api.createForPlatformView(captureAny),
      );
      final creationOptions = verification.captured[0] as CreationOptions;
      expect(creationOptions.uri, uri);
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
      ) = setUpMockPlayer(
        playerId: 1,
      );
      await player.setLooping(1, true);

      verify(playerApi.setLooping(true));
    });

    test('play', () async {
      final (
        AndroidVideoPlayer player,
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
        AndroidVideoPlayer player,
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
        final (AndroidVideoPlayer player, MockAndroidVideoPlayerApi api, _) =
            setUpMockPlayer(playerId: 1);
        await player.setMixWithOthers(true);

        verify(api.setMixWithOthers(true));
      });

      test('passes false', () async {
        final (AndroidVideoPlayer player, MockAndroidVideoPlayerApi api, _) =
            setUpMockPlayer(playerId: 1);
        await player.setMixWithOthers(false);

        verify(api.setMixWithOthers(false));
      });
    });

    test('setVolume', () async {
      final (
        AndroidVideoPlayer player,
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
        AndroidVideoPlayer player,
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
        AndroidVideoPlayer player,
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
        AndroidVideoPlayer player,
        _,
        MockVideoPlayerInstanceApi playerApi,
      ) = setUpMockPlayer(
        playerId: 1,
      );
      const positionMilliseconds = 12345;
      when(
        playerApi.getCurrentPosition(),
      ).thenAnswer((_) async => positionMilliseconds);

      final Duration position = await player.getPosition(1);
      expect(position, const Duration(milliseconds: positionMilliseconds));
    });

    group('video events', () {
      // Sets up a mock player that emits the given event structure as a success
      // callback on the internal platform channel event stream, and returns
      // the player's videoEventsFor(...) stream.
      Stream<VideoEvent> mockPlayerEmitingEvents(
        List<PlatformVideoEvent> events,
      ) {
        const playerId = 1;
        final (
          AndroidVideoPlayer player,
          _,
          _,
          StreamController<PlatformVideoEvent> streamController,
        ) = setUpMockPlayerWithStream(
          playerId: playerId,
        );

        events.forEach(streamController.add);

        return player.videoEventsFor(playerId);
      }

      test('initialize', () async {
        final Stream<VideoEvent> eventStream =
            mockPlayerEmitingEvents(<PlatformVideoEvent>[
              InitializationEvent(
                duration: 98765,
                width: 1920,
                height: 1080,
                rotationCorrection: 90,
              ),
            ]);

        expect(
          eventStream,
          emitsInOrder(<dynamic>[
            VideoEvent(
              eventType: VideoEventType.initialized,
              duration: const Duration(milliseconds: 98765),
              size: const Size(1920, 1080),
              rotationCorrection: 90,
            ),
          ]),
        );
      });

      test('initialization triggers buffer update polling', () async {
        final Stream<VideoEvent> eventStream =
            mockPlayerEmitingEvents(<PlatformVideoEvent>[
              InitializationEvent(
                duration: 98765,
                width: 1920,
                height: 1080,
                rotationCorrection: 90,
              ),
            ]);

        expect(
          eventStream,
          emitsInOrder(<dynamic>[
            VideoEvent(
              eventType: VideoEventType.initialized,
              duration: const Duration(milliseconds: 98765),
              size: const Size(1920, 1080),
              rotationCorrection: 90,
            ),
            VideoEvent(
              eventType: VideoEventType.bufferingUpdate,
              buffered: <DurationRange>[
                DurationRange(Duration.zero, Duration.zero),
              ],
            ),
          ]),
        );
      });

      test('completed', () async {
        final Stream<VideoEvent> eventStream = mockPlayerEmitingEvents(
          <PlatformVideoEvent>[
            PlaybackStateChangeEvent(state: PlatformPlaybackState.ended),
          ],
        );

        expect(
          eventStream,
          emitsInOrder(<dynamic>[
            VideoEvent(eventType: VideoEventType.completed),
          ]),
        );
      });

      test('buffering start', () async {
        final Stream<VideoEvent> eventStream = mockPlayerEmitingEvents(
          <PlatformVideoEvent>[
            PlaybackStateChangeEvent(state: PlatformPlaybackState.buffering),
          ],
        );

        expect(
          eventStream,
          emitsInOrder(<dynamic>[
            VideoEvent(eventType: VideoEventType.bufferingStart),
            // A buffer start should trigger a buffer update as well.
            VideoEvent(
              eventType: VideoEventType.bufferingUpdate,
              buffered: <DurationRange>[
                DurationRange(Duration.zero, Duration.zero),
              ],
            ),
          ]),
        );
      });

      test('buffering end for ready', () async {
        final Stream<VideoEvent> eventStream = mockPlayerEmitingEvents(
          <PlatformVideoEvent>[
            // Trigger a start first, since end is only emitted if it's
            // started.
            PlaybackStateChangeEvent(state: PlatformPlaybackState.buffering),
            PlaybackStateChangeEvent(state: PlatformPlaybackState.ready),
          ],
        );

        expect(
          eventStream,
          emitsInOrder(<dynamic>[
            // Emitted by buffering.
            VideoEvent(eventType: VideoEventType.bufferingStart),
            VideoEvent(
              eventType: VideoEventType.bufferingUpdate,
              buffered: <DurationRange>[
                DurationRange(Duration.zero, Duration.zero),
              ],
            ),
            // Emitted by ready.
            VideoEvent(eventType: VideoEventType.bufferingEnd),
          ]),
        );
      });

      test('buffering end for idle', () async {
        final Stream<VideoEvent> eventStream = mockPlayerEmitingEvents(
          <PlatformVideoEvent>[
            // Trigger a start first, since end is only emitted if it's
            // started.
            PlaybackStateChangeEvent(state: PlatformPlaybackState.buffering),
            PlaybackStateChangeEvent(state: PlatformPlaybackState.idle),
          ],
        );

        expect(
          eventStream,
          emitsInOrder(<dynamic>[
            // Emitted by buffering.
            VideoEvent(eventType: VideoEventType.bufferingStart),
            VideoEvent(
              eventType: VideoEventType.bufferingUpdate,
              buffered: <DurationRange>[
                DurationRange(Duration.zero, Duration.zero),
              ],
            ),
            // Emitted by ready.
            VideoEvent(eventType: VideoEventType.bufferingEnd),
          ]),
        );
      });

      test('buffering end for ended', () async {
        final Stream<VideoEvent> eventStream = mockPlayerEmitingEvents(
          <PlatformVideoEvent>[
            // Trigger a start first, since end is only emitted if it's
            // started.
            PlaybackStateChangeEvent(state: PlatformPlaybackState.buffering),
            PlaybackStateChangeEvent(state: PlatformPlaybackState.ended),
          ],
        );

        expect(
          eventStream,
          emitsInOrder(<dynamic>[
            // Emitted by buffering.
            VideoEvent(eventType: VideoEventType.bufferingStart),
            VideoEvent(
              eventType: VideoEventType.bufferingUpdate,
              buffered: <DurationRange>[
                DurationRange(Duration.zero, Duration.zero),
              ],
            ),
            // Emitted by ended.
            VideoEvent(eventType: VideoEventType.completed),
            VideoEvent(eventType: VideoEventType.bufferingEnd),
          ]),
        );
      });

      test('playback start', () async {
        final Stream<VideoEvent> eventStream = mockPlayerEmitingEvents(
          <PlatformVideoEvent>[IsPlayingStateEvent(isPlaying: true)],
        );

        expect(
          eventStream,
          emitsInOrder(<dynamic>[
            VideoEvent(
              eventType: VideoEventType.isPlayingStateUpdate,
              isPlaying: true,
            ),
          ]),
        );
      });

      test('playback stop', () async {
        final Stream<VideoEvent> eventStream = mockPlayerEmitingEvents(
          <PlatformVideoEvent>[IsPlayingStateEvent(isPlaying: false)],
        );

        expect(
          eventStream,
          emitsInOrder(<dynamic>[
            VideoEvent(
              eventType: VideoEventType.isPlayingStateUpdate,
              isPlaying: false,
            ),
          ]),
        );
      });
    });

    group('audio tracks', () {
      test('isAudioTrackSupportAvailable returns true', () {
        final (AndroidVideoPlayer player, _, _) = setUpMockPlayer(playerId: 1);

        expect(player.isAudioTrackSupportAvailable(), true);
      });

      test('getAudioTracks returns empty list when no tracks', () async {
        final (AndroidVideoPlayer player, _, MockVideoPlayerInstanceApi api) =
            setUpMockPlayer(playerId: 1);
        when(api.getAudioTracks()).thenAnswer(
          (_) async => NativeAudioTrackData(
            exoPlayerTracks: <ExoPlayerAudioTrackData>[],
          ),
        );

        final List<VideoAudioTrack> tracks = await player.getAudioTracks(1);

        expect(tracks, isEmpty);
        verify(api.getAudioTracks());
      });

      test(
        'getAudioTracks converts native tracks to VideoAudioTrack',
        () async {
          final (AndroidVideoPlayer player, _, MockVideoPlayerInstanceApi api) =
              setUpMockPlayer(playerId: 1);
          when(api.getAudioTracks()).thenAnswer(
            (_) async => NativeAudioTrackData(
              exoPlayerTracks: <ExoPlayerAudioTrackData>[
                ExoPlayerAudioTrackData(
                  groupIndex: 0,
                  trackIndex: 1,
                  label: 'English',
                  language: 'en',
                  isSelected: true,
                  bitrate: 128000,
                  sampleRate: 44100,
                  channelCount: 2,
                  codec: 'mp4a.40.2',
                ),
                ExoPlayerAudioTrackData(
                  groupIndex: 0,
                  trackIndex: 2,
                  label: 'Spanish',
                  language: 'es',
                  isSelected: false,
                  bitrate: 128000,
                  sampleRate: 44100,
                  channelCount: 2,
                  codec: 'mp4a.40.2',
                ),
              ],
            ),
          );

          final List<VideoAudioTrack> tracks = await player.getAudioTracks(1);

          expect(tracks.length, 2);

          expect(tracks[0].id, '0_1');
          expect(tracks[0].label, 'English');
          expect(tracks[0].language, 'en');
          expect(tracks[0].isSelected, true);
          expect(tracks[0].bitrate, 128000);
          expect(tracks[0].sampleRate, 44100);
          expect(tracks[0].channelCount, 2);
          expect(tracks[0].codec, 'mp4a.40.2');

          expect(tracks[1].id, '0_2');
          expect(tracks[1].label, 'Spanish');
          expect(tracks[1].language, 'es');
          expect(tracks[1].isSelected, false);
        },
      );

      test('getAudioTracks handles null exoPlayerTracks', () async {
        final (AndroidVideoPlayer player, _, MockVideoPlayerInstanceApi api) =
            setUpMockPlayer(playerId: 1);
        when(
          api.getAudioTracks(),
        ).thenAnswer((_) async => NativeAudioTrackData());

        final List<VideoAudioTrack> tracks = await player.getAudioTracks(1);

        expect(tracks, isEmpty);
      });

      test('selectAudioTrack parses trackId and calls API', () async {
        final (
          AndroidVideoPlayer player,
          _,
          MockVideoPlayerInstanceApi api,
          StreamController<PlatformVideoEvent> streamController,
        ) = setUpMockPlayerWithStream(
          playerId: 1,
        );
        when(api.selectAudioTrack(2, 3)).thenAnswer((_) async {});

        // Start the selection and immediately send the track changed event
        final Future<void> selectionFuture = player.selectAudioTrack(1, '2_3');
        streamController.add(AudioTrackChangedEvent());
        await selectionFuture;

        verify(api.selectAudioTrack(2, 3));
      });

      test('selectAudioTrack throws on invalid trackId format', () async {
        final (AndroidVideoPlayer player, _, _) = setUpMockPlayer(playerId: 1);

        expect(
          () => player.selectAudioTrack(1, 'invalid'),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('selectAudioTrack throws on trackId with too many parts', () async {
        final (AndroidVideoPlayer player, _, _) = setUpMockPlayer(playerId: 1);

        expect(
          () => player.selectAudioTrack(1, '1_2_3'),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('selectAudioTrack completes on AudioTrackChangedEvent', () async {
        final (
          AndroidVideoPlayer player,
          _,
          MockVideoPlayerInstanceApi api,
          StreamController<PlatformVideoEvent> streamController,
        ) = setUpMockPlayerWithStream(
          playerId: 1,
        );
        when(api.selectAudioTrack(0, 1)).thenAnswer((_) async {});

        // Start selection
        final Future<void> selectionFuture = player.selectAudioTrack(1, '0_1');

        // Simulate the track changed event from ExoPlayer
        streamController.add(AudioTrackChangedEvent());

        // Should complete without timeout
        await selectionFuture;

        verify(api.selectAudioTrack(0, 1));
      });
    });
  });
}
