// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:video_player_platform_interface/video_player_platform_interface.dart';

import 'messages.g.dart';

/// An Windows implementation of [VideoPlayerPlatform] that uses the
/// Pigeon-generated [VideoPlayerApi].
class WindowsVideoPlayer extends VideoPlayerPlatform {
  final WindowsVideoPlayerApi _api = WindowsVideoPlayerApi();

  /// Registers this class as the default instance of [PathProviderPlatform].
  static void registerWith() {
    VideoPlayerPlatform.instance = WindowsVideoPlayer();
  }

  @override
  Future<void> init() {
    return _api.initialize();
  }

  @override
  Future<void> dispose(int textureId) {
    return _api.dispose(textureId);
  }

  @override
  Future<int?> create(DataSource dataSource) async {
    String? asset;
    String? uri;
    Map<String, String> httpHeaders = <String, String>{};
    switch (dataSource.sourceType) {
      case DataSourceType.asset:
        asset = dataSource.asset;
        if (dataSource.package != null) {
          // TODO(azchohfi): Support package names, https://github.com/flutter/flutter/issues/103199.
          throw UnimplementedError(
              'Loading an asset from a package is not supported on Windows');
        }
      case DataSourceType.network:
        uri = dataSource.uri;
        httpHeaders = dataSource.httpHeaders;
      case DataSourceType.file:
        uri = dataSource.uri;
        httpHeaders = dataSource.httpHeaders;
      case DataSourceType.contentUri:
        uri = dataSource.uri;
    }

    final int textureId = await _api.create(
      asset,
      uri,
      httpHeaders,
    );
    return textureId;
  }

  @override
  Future<void> setLooping(int textureId, bool looping) {
    return _api.setLooping(textureId, looping);
  }

  @override
  Future<void> play(int textureId) {
    return _api.play(textureId);
  }

  @override
  Future<void> pause(int textureId) {
    return _api.pause(textureId);
  }

  @override
  Future<void> setVolume(int textureId, double volume) {
    return _api.setVolume(textureId, volume);
  }

  @override
  Future<void> setPlaybackSpeed(int textureId, double speed) {
    assert(speed > 0);

    return _api.setPlaybackSpeed(textureId, speed);
  }

  @override
  Future<void> seekTo(int textureId, Duration position) {
    return _api.seekTo(textureId, position.inMilliseconds);
  }

  @override
  Future<Duration> getPosition(int textureId) async {
    final int position = await _api.position(textureId);
    return Duration(milliseconds: position);
  }

  @override
  Stream<VideoEvent> videoEventsFor(int textureId) {
    return _eventChannelFor(textureId)
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
  Widget buildView(int textureId) {
    return Texture(textureId: textureId);
  }

  @override
  Future<void> setMixWithOthers(bool mixWithOthers) => Future<void>.value();

  EventChannel _eventChannelFor(int textureId) {
    return EventChannel('flutter.io/videoPlayer/videoEvents$textureId');
  }

  DurationRange _toDurationRange(dynamic value) {
    final List<dynamic> pair = value as List<dynamic>;
    return DurationRange(
      Duration(milliseconds: pair[0] as int),
      Duration(milliseconds: pair[1] as int),
    );
  }
}
