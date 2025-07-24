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

  /// A map that associates player ID with a view state.
  /// This is used to determine which view type to use when building a view.
  final Map<int, _VideoPlayerViewState> _playerViewStates =
      <int, _VideoPlayerViewState>{};

  final Map<int, VideoPlayerInstanceApi> _players =
      <int, VideoPlayerInstanceApi>{};

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
    _playerViewStates.remove(playerId);
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
    Map<String, String> httpHeaders = <String, String>{};
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
        httpHeaders = dataSource.httpHeaders;
      case DataSourceType.file:
        uri = dataSource.uri;
        httpHeaders = dataSource.httpHeaders;
      case DataSourceType.contentUri:
        uri = dataSource.uri;
    }
    if (uri == null) {
      throw ArgumentError('Unable to construct a video asset from $options');
    }
    final CreateMessage message = CreateMessage(
      uri: uri,
      httpHeaders: httpHeaders,
      formatHint: formatHint,
      viewType: _platformVideoViewTypeFromVideoViewType(options.viewType),
    );

    final int playerId = await _api.create(message);
    _playerViewStates[playerId] = switch (options.viewType) {
      // playerId is also the textureId when using texture view.
      VideoViewType.textureView => _VideoPlayerTextureViewState(
        textureId: playerId,
      ),
      VideoViewType.platformView => const _VideoPlayerPlatformViewState(),
    };
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
      switch (map['event']) {
        case 'initialized':
          return VideoEvent(
            eventType: VideoEventType.initialized,
            duration: Duration(milliseconds: map['duration'] as int),
            size: Size(
              (map['width'] as num?)?.toDouble() ?? 0.0,
              (map['height'] as num?)?.toDouble() ?? 0.0,
            ),
            rotationCorrection: map['rotationCorrection'] as int? ?? 0,
          );
        case 'completed':
          return VideoEvent(eventType: VideoEventType.completed);
        case 'bufferingUpdate':
          final List<dynamic> values = map['values'] as List<dynamic>;

          return VideoEvent(
            buffered: values.map<DurationRange>(_toDurationRange).toList(),
            eventType: VideoEventType.bufferingUpdate,
          );
        case 'bufferingStart':
          return VideoEvent(eventType: VideoEventType.bufferingStart);
        case 'bufferingEnd':
          return VideoEvent(eventType: VideoEventType.bufferingEnd);
        case 'isPlayingStateUpdate':
          return VideoEvent(
            eventType: VideoEventType.isPlayingStateUpdate,
            isPlaying: map['isPlaying'] as bool,
          );
        default:
          return VideoEvent(eventType: VideoEventType.unknown);
      }
    });
  }

  @override
  Widget buildView(int playerId) {
    return buildViewWithOptions(VideoViewOptions(playerId: playerId));
  }

  @override
  Widget buildViewWithOptions(VideoViewOptions options) {
    final int playerId = options.playerId;
    final _VideoPlayerViewState? viewState = _playerViewStates[playerId];

    return switch (viewState) {
      _VideoPlayerTextureViewState(:final int textureId) => Texture(
        textureId: textureId,
      ),
      _VideoPlayerPlatformViewState() => PlatformViewPlayer(playerId: playerId),
      null =>
        throw Exception(
          'Could not find corresponding view type for playerId: $playerId',
        ),
    };
  }

  @override
  Future<void> setMixWithOthers(bool mixWithOthers) {
    return _api.setMixWithOthers(mixWithOthers);
  }

  EventChannel _eventChannelFor(int playerId) {
    return EventChannel('flutter.io/videoPlayer/videoEvents$playerId');
  }

  VideoPlayerInstanceApi _playerWith({required int id}) {
    final VideoPlayerInstanceApi? player = _players[id];
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

  DurationRange _toDurationRange(dynamic value) {
    final List<dynamic> pair = value as List<dynamic>;
    return DurationRange(
      Duration(milliseconds: pair[0] as int),
      Duration(milliseconds: pair[1] as int),
    );
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
