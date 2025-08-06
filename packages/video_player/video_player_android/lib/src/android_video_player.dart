// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:video_player_platform_interface/video_player_platform_interface.dart';

import 'messages.g.dart';
import 'platform_view_player.dart';

/// The non-test implementation of `_apiProvider`.
VideoPlayerInstanceApi _productionApiProvider(int playerId) {
  return VideoPlayerInstanceApi(messageChannelSuffix: playerId.toString());
}

/// An Android implementation of [VideoPlayerPlatform] that uses the
/// Pigeon-generated [VideoPlayerApi].
class AndroidVideoPlayer extends VideoPlayerPlatform {
  /// Creates a new Android video player implementation instance.
  AndroidVideoPlayer({
    @visibleForTesting AndroidVideoPlayerApi? pluginApi,
    @visibleForTesting
    VideoPlayerInstanceApi Function(int playerId)? playerProvider,
  }) : _api = pluginApi ?? AndroidVideoPlayerApi(),
       _playerProvider = playerProvider ?? _productionApiProvider;

  final AndroidVideoPlayerApi _api;
  // A method to create VideoPlayerInstanceApi instances, which can be
  //overridden for testing.
  final VideoPlayerInstanceApi Function(int playerId) _playerProvider;

  final Map<int, _PlayerInstance> _players = <int, _PlayerInstance>{};

  /// Registers this class as the default instance of [PathProviderPlatform].
  static void registerWith() {
    VideoPlayerPlatform.instance = AndroidVideoPlayer();
  }

  @override
  Future<void> init() {
    return _api.initialize();
  }

  @override
  Future<void> dispose(int playerId) async {
    await _api.dispose(playerId);
    _players.remove(playerId);
  }

  @override
  Future<int?> create(DataSource dataSource) {
    return createWithOptions(
      VideoCreationOptions(
        dataSource: dataSource,
        // Compatibility; "create" is always a textureView (createWithOptions
        // allows selecting).
        viewType: VideoViewType.textureView,
      ),
    );
  }

  @override
  Future<int?> createWithOptions(VideoCreationOptions options) async {
    final DataSource dataSource = options.dataSource;

    String? uri;
    PlatformVideoFormat? formatHint;
    final Map<String, String> httpHeaders = dataSource.httpHeaders;
    final String? userAgent = _userAgentFromHeaders(httpHeaders);
    switch (dataSource.sourceType) {
      case DataSourceType.asset:
        final String? asset = dataSource.asset;
        if (asset == null) {
          throw ArgumentError(
            '"asset" must be non-null for an asset data source',
          );
        }
        final String key = await _api.getLookupKeyForAsset(
          asset,
          dataSource.package,
        );
        uri = 'asset:///$key';
      case DataSourceType.network:
        uri = dataSource.uri;
        formatHint = _platformVideoFormatFromVideoFormat(dataSource.formatHint);
      case DataSourceType.file:
      case DataSourceType.contentUri:
        uri = dataSource.uri;
    }
    if (uri == null) {
      throw ArgumentError('Unable to construct a video asset from $options');
    }
    final CreateMessage message = CreateMessage(
      uri: uri,
      httpHeaders: httpHeaders,
      userAgent: userAgent,
      formatHint: formatHint,
      viewType: _platformVideoViewTypeFromVideoViewType(options.viewType),
    );

    final int playerId = await _api.create(message);
    ensureApiInitialized(playerId, options.viewType);

    return playerId;
  }

  // Returns the user agent to use with ExoPlayer for the given headers.
  String? _userAgentFromHeaders(Map<String, String> httpHeaders) {
    // TODO(stuartmorgan): HTTP headers are case-insensitive, so this should be
    //  adjusted to find any entry where the key has a case-insensitive match.
    const String userAgentKey = 'User-Agent';
    // TODO(stuartmorgan): Investigate removing this. The use of a hard-coded
    //  default agent dates back to the original ExoPlayer implementation of the
    //  plugin, but it's not clear why the default isn't null, which would let
    //  ExoPlayer use its own default value.
    const String defaultUserAgent = 'ExoPlayer';
    return httpHeaders[userAgentKey] ?? defaultUserAgent;
  }

  /// Returns the player instance for [playerId], creating it if it doesn't
  /// already exist.
  @visibleForTesting
  void ensureApiInitialized(int playerId, VideoViewType viewType) {
    _players.putIfAbsent(playerId, () {
      final _VideoPlayerViewState viewState = switch (viewType) {
        // playerId is also the textureId when using texture view.
        VideoViewType.textureView => _VideoPlayerTextureViewState(
          textureId: playerId,
        ),
        VideoViewType.platformView => const _VideoPlayerPlatformViewState(),
      };
      return _PlayerInstance(_playerProvider(playerId), viewState);
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
          rotationCorrection: map['rotationCorrection'] as int? ?? 0,
        ),
        'completed' => VideoEvent(eventType: VideoEventType.completed),
        'bufferingUpdate' => VideoEvent(
          eventType: VideoEventType.bufferingUpdate,
          buffered: <DurationRange>[
            DurationRange(
              Duration.zero,
              Duration(milliseconds: map['position'] as int),
            ),
          ],
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
  Widget buildView(int playerId) {
    return buildViewWithOptions(VideoViewOptions(playerId: playerId));
  }

  @override
  Widget buildViewWithOptions(VideoViewOptions options) {
    final int playerId = options.playerId;
    final _VideoPlayerViewState viewState = _playerWith(id: playerId).viewState;

    return switch (viewState) {
      _VideoPlayerTextureViewState(:final int textureId) => Texture(
        textureId: textureId,
      ),
      _VideoPlayerPlatformViewState() => PlatformViewPlayer(playerId: playerId),
    };
  }

  @override
  Future<void> setMixWithOthers(bool mixWithOthers) {
    return _api.setMixWithOthers(mixWithOthers);
  }

  EventChannel _eventChannelFor(int playerId) {
    return EventChannel('flutter.io/videoPlayer/videoEvents$playerId');
  }

  _PlayerInstance _playerWith({required int id}) {
    final _PlayerInstance? player = _players[id];
    return player ?? (throw StateError('No active player with ID $id.'));
  }

  PlatformVideoFormat? _platformVideoFormatFromVideoFormat(
    VideoFormat? format,
  ) {
    return switch (format) {
      VideoFormat.dash => PlatformVideoFormat.dash,
      VideoFormat.hls => PlatformVideoFormat.hls,
      VideoFormat.ss => PlatformVideoFormat.ss,
      VideoFormat.other => null,
      // Include a catch-all, since the enum comes from another package, so
      // this code must handle the possibility of a new enum value.
      _ => null,
    };
  }
}

PlatformVideoViewType _platformVideoViewTypeFromVideoViewType(
  VideoViewType viewType,
) {
  return switch (viewType) {
    VideoViewType.textureView => PlatformVideoViewType.textureView,
    VideoViewType.platformView => PlatformVideoViewType.platformView,
  };
}

/// An instance of a video player, corresponding to a single player ID in
/// [AndroidVideoPlayer].
class _PlayerInstance {
  /// Creates a new instance of [_PlayerInstance] corresponding to the given
  /// API instance.
  _PlayerInstance(this._api, this.viewState);

  final VideoPlayerInstanceApi _api;

  final _VideoPlayerViewState viewState;

  Future<void> setLooping(bool looping) {
    return _api.setLooping(looping);
  }

  Future<void> play() {
    return _api.play();
  }

  Future<void> pause() {
    return _api.pause();
  }

  Future<void> setVolume(double volume) {
    return _api.setVolume(volume);
  }

  Future<void> setPlaybackSpeed(double speed) {
    return _api.setPlaybackSpeed(speed);
  }

  Future<void> seekTo(int position) {
    return _api.seekTo(position);
  }

  Future<int> getPosition() {
    return _api.getPosition();
  }
}

/// Base class representing the state of a video player view.
@immutable
sealed class _VideoPlayerViewState {
  const _VideoPlayerViewState();
}

/// Represents the state of a video player view that uses a texture.
final class _VideoPlayerTextureViewState extends _VideoPlayerViewState {
  /// Creates a new instance of [_VideoPlayerTextureViewState].
  const _VideoPlayerTextureViewState({required this.textureId});

  /// The ID of the texture used by the video player.
  final int textureId;
}

/// Represents the state of a video player view that uses a platform view.
final class _VideoPlayerPlatformViewState extends _VideoPlayerViewState {
  /// Creates a new instance of [_VideoPlayerPlatformViewState].
  const _VideoPlayerPlatformViewState();
}
