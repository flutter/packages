// Copyright 2013 The Flutter Authors
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
    player.ensureApiInitialized(playerId, VideoViewType.platformView);
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

    test('getPlaybackState', () async {
      final (
        AndroidVideoPlayer player,
        _,
        MockVideoPlayerInstanceApi playerApi,
      ) = setUpMockPlayer(playerId: 1);
      const int positionMilliseconds = 12345;
      when(playerApi.getPlaybackState()).thenAnswer(
        (_) async => PlaybackState(
          playPosition: positionMilliseconds,
          bufferPosition: 0,
        ),
      );

      final Duration position = await player.getPosition(1);
      expect(position, const Duration(milliseconds: positionMilliseconds));
    });

    test('videoEventsFor', () async {
      const int playerId = 1;
      const String mockChannel = 'flutter.io/videoPlayer/videoEvents$playerId';
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

      // Creating the player triggers the stream listener, so that must be done
      // after setting up the mock native handler above.
      final (
        AndroidVideoPlayer player,
        MockAndroidVideoPlayerApi api,
        _,
      ) = setUpMockPlayer(playerId: playerId);

      expect(
        player.videoEventsFor(playerId),
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
  });
}
