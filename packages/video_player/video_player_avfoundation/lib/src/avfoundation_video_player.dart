// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:video_player_platform_interface/video_player_platform_interface.dart';

import 'messages.g.dart';

/// The non-test implementation of `_apiProvider`.
VideoPlayerInstanceApi _productionApiProvider(int playerId) {
  return VideoPlayerInstanceApi(messageChannelSuffix: playerId.toString());
}

/// An iOS implementation of [VideoPlayerPlatform] that uses the
/// Pigeon-generated [VideoPlayerApi].
class AVFoundationVideoPlayer extends VideoPlayerPlatform {
  /// Creates a new AVFoundation-based video player implementation instance.
  AVFoundationVideoPlayer({
    @visibleForTesting AVFoundationVideoPlayerApi? pluginApi,
    @visibleForTesting
    VideoPlayerInstanceApi Function(int playerId)? playerProvider,
  }) : _api = pluginApi ?? AVFoundationVideoPlayerApi(),
       _playerProvider = playerProvider ?? _productionApiProvider;

  final AVFoundationVideoPlayerApi _api;
  // A method to create VideoPlayerInstanceApi instances, which can be
  // overridden for testing.
  final VideoPlayerInstanceApi Function(int mapId) _playerProvider;

  /// A map that associates player ID with a view state.
  /// This is used to determine which view type to use when building a view.
  @visibleForTesting
  final Map<int, VideoPlayerViewState> playerViewStates =
      <int, VideoPlayerViewState>{};

  final Map<int, VideoPlayerInstanceApi> _players =
      <int, VideoPlayerInstanceApi>{};

  /// Registers this class as the default instance of [VideoPlayerPlatform].
  static void registerWith() {
    VideoPlayerPlatform.instance = AVFoundationVideoPlayer();
  }

  @override
  Future<void> init() {
    return _api.initialize();
  }

  @override
  Future<void> dispose(int playerId) async {
    final VideoPlayerInstanceApi? player = _players.remove(playerId);
    await player?.dispose();
    playerViewStates.remove(playerId);
  }

  @override
  Future<int?> create(DataSource dataSource) async {
    return createWithOptions(
      VideoCreationOptions(
        dataSource: dataSource,
        // Texture view was the only supported view type before
        // createWithOptions was introduced.
        viewType: VideoViewType.textureView,
      ),
    );
  }

  @override
  Future<int?> createWithOptions(VideoCreationOptions options) async {
    final DataSource dataSource = options.dataSource;
    final VideoViewType viewType = options.viewType;

    String? uri;
    switch (dataSource.sourceType) {
      case DataSourceType.asset:
        final String? asset = dataSource.asset;
        if (asset == null) {
          throw ArgumentError(
            '"asset" must be non-null for an asset data source',
          );
        }
        uri = await _api.getAssetUrl(asset, dataSource.package);
        if (uri == null) {
          // Throw a platform exception for compatibility with the previous
          // implementation, which threw on the native side.
          throw PlatformException(
            code: 'video_player',
            message: 'Asset $asset not found in package ${dataSource.package}.',
          );
        }
      case DataSourceType.network:
      case DataSourceType.file:
      case DataSourceType.contentUri:
        uri = dataSource.uri;
    }
    if (uri == null) {
      throw ArgumentError('Unable to construct a video asset from $options');
    }
    final CreationOptions pigeonCreationOptions = CreationOptions(
      uri: uri,
      httpHeaders: dataSource.httpHeaders,
    );

    final int playerId;
    final VideoPlayerViewState state;
    switch (viewType) {
      case VideoViewType.textureView:
        final TexturePlayerIds ids = await _api.createForTextureView(
          pigeonCreationOptions,
        );
        playerId = ids.playerId;
        state = VideoPlayerTextureViewState(textureId: ids.textureId);
      case VideoViewType.platformView:
        playerId = await _api.createForPlatformView(pigeonCreationOptions);
        state = const VideoPlayerPlatformViewState();
    }
    playerViewStates[playerId] = state;
    ensureApiInitialized(playerId);

    return playerId;
  }

  /// Returns the API instance for [playerId], creating it if it doesn't already
  /// exist.
  @visibleForTesting
  VideoPlayerInstanceApi ensureApiInitialized(int playerId) {
    return _players.putIfAbsent(playerId, () {
      return _playerProvider(playerId);
    });
  }

  @override
  Future<void> setLooping(int playerId, bool looping) {
    return _playerWith(id: playerId).setLooping(looping);
  }

  @override
  Future<void> play(int playerId) {
    return _playerWith(id: playerId).play();
  }

  @override
  Future<void> pause(int playerId) {
    return _playerWith(id: playerId).pause();
  }

  @override
  Future<void> setVolume(int playerId, double volume) {
    return _playerWith(id: playerId).setVolume(volume);
  }

  @override
  Future<void> setPlaybackSpeed(int playerId, double speed) {
    assert(speed > 0);

    return _playerWith(id: playerId).setPlaybackSpeed(speed);
  }

  @override
  Future<void> seekTo(int playerId, Duration position) {
    return _playerWith(id: playerId).seekTo(position.inMilliseconds);
  }

  @override
  Future<Duration> getPosition(int playerId) async {
    final int position = await _playerWith(id: playerId).getPosition();
    return Duration(milliseconds: position);
  }

  @override
  Stream<VideoEvent> videoEventsFor(int playerId) {
    return _eventChannelFor(playerId).receiveBroadcastStream().map((
      dynamic event,
    ) {
      final Map<dynamic, dynamic> map = event as Map<dynamic, dynamic>;
      return switch (map['event']) {
        'initialized' => VideoEvent(
          eventType: VideoEventType.initialized,
          duration: Duration(milliseconds: map['duration'] as int),
          size: Size(
            (map['width'] as num?)?.toDouble() ?? 0.0,
            (map['height'] as num?)?.toDouble() ?? 0.0,
          ),
        ),
        'completed' => VideoEvent(eventType: VideoEventType.completed),
        'bufferingUpdate' => VideoEvent(
          buffered:
              (map['values'] as List<dynamic>)
                  .map<DurationRange>(_toDurationRange)
                  .toList(),
          eventType: VideoEventType.bufferingUpdate,
        ),
        'bufferingStart' => VideoEvent(
          eventType: VideoEventType.bufferingStart,
        ),
        'bufferingEnd' => VideoEvent(eventType: VideoEventType.bufferingEnd),
        'isPlayingStateUpdate' => VideoEvent(
          eventType: VideoEventType.isPlayingStateUpdate,
          isPlaying: map['isPlaying'] as bool,
        ),
        _ => VideoEvent(eventType: VideoEventType.unknown),
      };
    });
  }

  @override
  Future<void> setMixWithOthers(bool mixWithOthers) {
    return _api.setMixWithOthers(mixWithOthers);
  }

  @override
  Widget buildView(int playerId) {
    return buildViewWithOptions(VideoViewOptions(playerId: playerId));
  }

  @override
  Widget buildViewWithOptions(VideoViewOptions options) {
    final int playerId = options.playerId;
    final VideoPlayerViewState? viewState = playerViewStates[playerId];

    return switch (viewState) {
      VideoPlayerTextureViewState(:final int textureId) => Texture(
        textureId: textureId,
      ),
      VideoPlayerPlatformViewState() => _buildPlatformView(playerId),
      null =>
        throw Exception(
          'Could not find corresponding view type for playerId: $playerId',
        ),
    };
  }

  Widget _buildPlatformView(int playerId) {
    final PlatformVideoViewCreationParams creationParams =
        PlatformVideoViewCreationParams(playerId: playerId);

    return IgnorePointer(
      // IgnorePointer so that GestureDetector can be used above the platform view.
      child: UiKitView(
        viewType: 'plugins.flutter.dev/video_player_ios',
        creationParams: creationParams,
        creationParamsCodec: AVFoundationVideoPlayerApi.pigeonChannelCodec,
      ),
    );
  }

  EventChannel _eventChannelFor(int playerId) {
    return EventChannel('flutter.io/videoPlayer/videoEvents$playerId');
  }

  VideoPlayerInstanceApi _playerWith({required int id}) {
    final VideoPlayerInstanceApi? player = _players[id];
    return player ?? (throw StateError('No active player with ID $id.'));
  }

  DurationRange _toDurationRange(dynamic value) {
    final List<dynamic> pair = value as List<dynamic>;
    final int startMilliseconds = pair[0] as int;
    final int durationMilliseconds = pair[1] as int;
    return DurationRange(
      Duration(milliseconds: startMilliseconds),
      Duration(milliseconds: startMilliseconds + durationMilliseconds),
    );
  }
}

/// Base class representing the state of a video player view.
@visibleForTesting
@immutable
sealed class VideoPlayerViewState {
  const VideoPlayerViewState();
}

/// Represents the state of a video player view that uses a texture.
@visibleForTesting
final class VideoPlayerTextureViewState extends VideoPlayerViewState {
  /// Creates a new instance of [VideoPlayerTextureViewState].
  const VideoPlayerTextureViewState({required this.textureId});

  /// The ID of the texture used by the video player.
  final int textureId;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VideoPlayerTextureViewState && other.textureId == textureId;

  @override
  int get hashCode => textureId.hashCode;
}

/// Represents the state of a video player view that uses a platform view.
@visibleForTesting
final class VideoPlayerPlatformViewState extends VideoPlayerViewState {
  /// Creates a new instance of [VideoPlayerPlatformViewState].
  const VideoPlayerPlatformViewState();
}
