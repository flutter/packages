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
    VideoPlayerInstanceApi Function(int playerId)? playerApiProvider,
  }) : _api = pluginApi ?? AVFoundationVideoPlayerApi(),
       _playerApiProvider = playerApiProvider ?? _productionApiProvider;

  final AVFoundationVideoPlayerApi _api;
  // A method to create VideoPlayerInstanceApi instances, which can be
  // overridden for testing.
  final VideoPlayerInstanceApi Function(int mapId) _playerApiProvider;

  final Map<int, _PlayerInstance> _players = <int, _PlayerInstance>{};

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
    final _PlayerInstance? player = _players.remove(playerId);
    await player?.dispose();
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
    final pigeonCreationOptions = CreationOptions(
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
    ensurePlayerInitialized(playerId, state);

    return playerId;
  }

  /// Returns the API instance for [playerId], creating it if it doesn't already
  /// exist.
  @visibleForTesting
  void ensurePlayerInitialized(int playerId, VideoPlayerViewState viewState) {
    _players.putIfAbsent(playerId, () {
      return _PlayerInstance(
        _playerApiProvider(playerId),
        viewState,
        eventChannel: EventChannel(
          // This must match the channel name used in FVPVideoPlayerPlugin.m.
          'flutter.dev/videoPlayer/videoEvents$playerId',
        ),
      );
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
    return _playerWith(id: playerId).seekTo(position);
  }

  @override
  Future<Duration> getPosition(int playerId) async {
    return _playerWith(id: playerId).getPosition();
  }

  @override
  Stream<VideoEvent> videoEventsFor(int playerId) {
    return _playerWith(id: playerId).videoEvents;
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
    final VideoPlayerViewState viewState = _playerWith(id: playerId).viewState;

    return switch (viewState) {
      VideoPlayerTextureViewState(:final int textureId) => Texture(
        textureId: textureId,
      ),
      VideoPlayerPlatformViewState() => _buildPlatformView(playerId),
    };
  }

  Widget _buildPlatformView(int playerId) {
    final creationParams = PlatformVideoViewCreationParams(playerId: playerId);

    return IgnorePointer(
      // IgnorePointer so that GestureDetector can be used above the platform view.
      child: UiKitView(
        viewType: 'plugins.flutter.dev/video_player_ios',
        creationParams: creationParams,
        creationParamsCodec: AVFoundationVideoPlayerApi.pigeonChannelCodec,
      ),
    );
  }

  _PlayerInstance _playerWith({required int id}) {
    final _PlayerInstance? player = _players[id];
    return player ?? (throw StateError('No active player with ID $id.'));
  }
}

/// An instance of a video player, corresponding to a single player ID in
/// [AVFoundationVideoPlayer].
class _PlayerInstance {
  _PlayerInstance(
    this._api,
    this.viewState, {
    required EventChannel eventChannel,
  }) : _eventChannel = eventChannel;

  final VideoPlayerInstanceApi _api;
  final VideoPlayerViewState viewState;
  final EventChannel _eventChannel;
  final StreamController<VideoEvent> _eventStreamController =
      StreamController<VideoEvent>.broadcast();
  StreamSubscription<dynamic>? _eventSubscription;

  Future<void> play() => _api.play();

  Future<void> pause() => _api.pause();

  Future<void> setLooping(bool looping) => _api.setLooping(looping);

  Future<void> setVolume(double volume) => _api.setVolume(volume);

  Future<void> setPlaybackSpeed(double speed) => _api.setPlaybackSpeed(speed);

  Future<void> seekTo(Duration position) {
    return _api.seekTo(position.inMilliseconds);
  }

  Future<Duration> getPosition() async {
    return Duration(milliseconds: await _api.getPosition());
  }

  Stream<VideoEvent> get videoEvents {
    _eventSubscription ??= _eventChannel.receiveBroadcastStream().listen(
      _onStreamEvent,
      onError: (Object e) {
        _eventStreamController.addError(e);
      },
    );

    return _eventStreamController.stream;
  }

  Future<void> dispose() async {
    await _eventSubscription?.cancel();
    unawaited(_eventStreamController.close());
    await _api.dispose();
  }

  void _onStreamEvent(dynamic event) {
    final map = event as Map<dynamic, dynamic>;
    // The strings here must all match the strings in FVPEventBridge.m.
    _eventStreamController.add(switch (map['event']) {
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
        buffered: (map['values'] as List<dynamic>)
            .map<DurationRange>(_toDurationRange)
            .toList(),
        eventType: VideoEventType.bufferingUpdate,
      ),
      'bufferingStart' => VideoEvent(eventType: VideoEventType.bufferingStart),
      'bufferingEnd' => VideoEvent(eventType: VideoEventType.bufferingEnd),
      'isPlayingStateUpdate' => VideoEvent(
        eventType: VideoEventType.isPlayingStateUpdate,
        isPlaying: map['isPlaying'] as bool,
      ),
      _ => VideoEvent(eventType: VideoEventType.unknown),
    });
  }

  DurationRange _toDurationRange(dynamic value) {
    final pair = value as List<dynamic>;
    final startMilliseconds = pair[0] as int;
    final durationMilliseconds = pair[1] as int;
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
