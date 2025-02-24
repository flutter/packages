// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:video_player_platform_interface/video_player_platform_interface.dart';

import 'messages.g.dart';

/// An Android implementation of [VideoPlayerPlatform] that uses the
/// Pigeon-generated [VideoPlayerApi].
class AndroidVideoPlayer extends VideoPlayerPlatform {
  final AndroidVideoPlayerApi _api = AndroidVideoPlayerApi();

  /// A map that associates player ID with a view state.
  /// This is used to determine which view type to use when building a view.
  @visibleForTesting
  final Map<int, VideoPlayerViewState> playerViewStates =
      <int, VideoPlayerViewState>{};

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
    playerViewStates.remove(playerId);
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

    String? asset;
    String? packageName;
    String? uri;
    String? formatHint;
    Map<String, String> httpHeaders = <String, String>{};
    switch (dataSource.sourceType) {
      case DataSourceType.asset:
        asset = dataSource.asset;
        packageName = dataSource.package;
      case DataSourceType.network:
        uri = dataSource.uri;
        formatHint = _videoFormatStringMap[dataSource.formatHint];
        httpHeaders = dataSource.httpHeaders;
      case DataSourceType.file:
        uri = dataSource.uri;
        httpHeaders = dataSource.httpHeaders;
      case DataSourceType.contentUri:
        uri = dataSource.uri;
    }
    final CreateMessage message = CreateMessage(
      asset: asset,
      packageName: packageName,
      uri: uri,
      httpHeaders: httpHeaders,
      formatHint: formatHint,
      viewType: _platformVideoViewTypeFromVideoViewType(options.viewType),
    );

    final int playerId = await _api.create(message);
    playerViewStates[playerId] = switch (options.viewType) {
      // playerId is also the textureId when using texture view.
      VideoViewType.textureView =>
        VideoPlayerTextureViewState(textureId: playerId),
      VideoViewType.platformView => const VideoPlayerPlatformViewState(),
    };

    return playerId;
  }

  @override
  Future<void> setLooping(int playerId, bool looping) {
    return _api.setLooping(playerId, looping);
  }

  @override
  Future<void> play(int playerId) {
    return _api.play(playerId);
  }

  @override
  Future<void> pause(int playerId) {
    return _api.pause(playerId);
  }

  @override
  Future<void> setVolume(int playerId, double volume) {
    return _api.setVolume(playerId, volume);
  }

  @override
  Future<void> setPlaybackSpeed(int playerId, double speed) {
    assert(speed > 0);

    return _api.setPlaybackSpeed(playerId, speed);
  }

  @override
  Future<void> seekTo(int playerId, Duration position) {
    return _api.seekTo(playerId, position.inMilliseconds);
  }

  @override
  Future<Duration> getPosition(int playerId) async {
    final int position = await _api.position(playerId);
    return Duration(milliseconds: position);
  }

  @override
  Stream<VideoEvent> videoEventsFor(int playerId) {
    return _eventChannelFor(playerId)
        .receiveBroadcastStream()
        .map((dynamic event) {
      final Map<dynamic, dynamic> map = event as Map<dynamic, dynamic>;
      switch (map['event']) {
        case 'initialized':
          return VideoEvent(
            eventType: VideoEventType.initialized,
            duration: Duration(milliseconds: map['duration'] as int),
            size: Size((map['width'] as num?)?.toDouble() ?? 0.0,
                (map['height'] as num?)?.toDouble() ?? 0.0),
            rotationCorrection: map['rotationCorrection'] as int? ?? 0,
          );
        case 'completed':
          return VideoEvent(
            eventType: VideoEventType.completed,
          );
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
    return buildViewWithOptions(
      VideoViewOptions(playerId: playerId),
    );
  }

  @override
  Widget buildViewWithOptions(VideoViewOptions options) {
    final int playerId = options.playerId;
    final VideoPlayerViewState? viewState = playerViewStates[playerId];

    return switch (viewState) {
      VideoPlayerTextureViewState(:final int textureId) =>
        Texture(textureId: textureId),
      VideoPlayerPlatformViewState() => _buildPlatformView(playerId),
      null => throw Exception(
          'Could not find corresponding view type for playerId: $playerId',
        ),
    };
  }

  Widget _buildPlatformView(int playerId) {
    const String viewType = 'plugins.flutter.dev/video_player_android';
    final PlatformVideoViewCreationParams creationParams =
        PlatformVideoViewCreationParams(playerId: playerId);

    return Builder(
      // IgnorePointer so that GestureDetector can be used above the platform view.
      builder: (BuildContext context) => IgnorePointer(
        child: PlatformViewLink(
          viewType: viewType,
          surfaceFactory: (
            BuildContext context,
            PlatformViewController controller,
          ) {
            return AndroidViewSurface(
              controller: controller as AndroidViewController,
              gestureRecognizers: const <Factory<
                  OneSequenceGestureRecognizer>>{},
              hitTestBehavior: PlatformViewHitTestBehavior.opaque,
            );
          },
          onCreatePlatformView: (PlatformViewCreationParams params) {
            return PlatformViewsService.initSurfaceAndroidView(
              id: params.id,
              viewType: viewType,
              layoutDirection:
                  Directionality.maybeOf(context) ?? TextDirection.ltr,
              creationParams: creationParams,
              creationParamsCodec: AndroidVideoPlayerApi.pigeonChannelCodec,
              onFocus: () => params.onFocusChanged(true),
            )
              ..addOnPlatformViewCreatedListener(params.onPlatformViewCreated)
              ..create();
          },
        ),
      ),
    );
  }

  @override
  Future<void> setMixWithOthers(bool mixWithOthers) {
    return _api.setMixWithOthers(mixWithOthers);
  }

  EventChannel _eventChannelFor(int playerId) {
    return EventChannel('flutter.io/videoPlayer/videoEvents$playerId');
  }

  static const Map<VideoFormat, String> _videoFormatStringMap =
      <VideoFormat, String>{
    VideoFormat.ss: 'ss',
    VideoFormat.hls: 'hls',
    VideoFormat.dash: 'dash',
    VideoFormat.other: 'other',
  };

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
@visibleForTesting
@immutable
sealed class VideoPlayerViewState {
  const VideoPlayerViewState();
}

/// Represents the state of a video player view that uses a texture.
@visibleForTesting
final class VideoPlayerTextureViewState extends VideoPlayerViewState {
  /// Creates a new instance of [VideoPlayerTextureViewState].
  const VideoPlayerTextureViewState({
    required this.textureId,
  });

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
