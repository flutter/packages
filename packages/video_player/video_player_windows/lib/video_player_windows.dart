// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:video_player_platform_interface/video_player_platform_interface.dart';

import 'src/http_source.dart';
import 'src/messages.g.dart';

/// Uses the codecs installed in Windows; playback does not bundle codec binaries.
class WindowsVideoPlayer extends VideoPlayerPlatform {
  /// An injected [api] must preserve the native API's asynchronous error contracts.
  WindowsVideoPlayer({@visibleForTesting WindowsVideoPlayerApi? api})
    : _api = api ?? WindowsVideoPlayerApi();

  final WindowsVideoPlayerApi _api;
  final Map<int, HttpSource> _httpSources = <int, HttpSource>{};
  int _generation = 0;
  Future<void> _creationQueue = Future<void>.value();

  Future<T> _serializeCreation<T>(Future<T> Function() operation) {
    // Reset must wait for stale creations to release their IDs before native
    // textures can be reused by a later creation.
    final Future<T> result = _creationQueue.then((_) => operation());
    // A failed creation must not prevent later queued creations or resets.
    _creationQueue = result.then<void>((_) {}, onError: (Object _, StackTrace _) {});
    return result;
  }

  /// Called by Flutter's generated registrant before controllers are created.
  static void registerWith() {
    VideoPlayerPlatform.instance = WindowsVideoPlayer();
  }

  @override
  Future<void> init() {
    _generation++;
    return _serializeCreation(() async {
      final List<HttpSource> sources = _httpSources.values.toList();
      _httpSources.clear();
      await Future.wait(sources.map((HttpSource source) => source.close()));
      await _api.initialize();
    });
  }

  @override
  Future<int> create(DataSource dataSource) {
    return createWithOptions(
      VideoCreationOptions(dataSource: dataSource, viewType: VideoViewType.textureView),
    );
  }

  @override
  Future<int> createWithOptions(VideoCreationOptions options) {
    final int generation = _generation;
    return _serializeCreation(() => _create(options, generation));
  }

  Future<int> _create(VideoCreationOptions options, int generation) async {
    final DataSource source = options.dataSource;
    String location;
    switch (source.sourceType) {
      case DataSourceType.asset:
        final String? asset = source.asset;
        if (asset == null || asset.isEmpty) {
          throw ArgumentError.value(asset, 'asset', 'An asset path is required.');
        }
        final String key = source.package == null ? asset : 'packages/${source.package}/$asset';
        final Uri root = File(
          Platform.resolvedExecutable,
        ).parent.uri.resolve('data/flutter_assets/');
        final Uri uri = root.resolveUri(Uri(path: key));
        if (!uri.toString().startsWith(root.toString())) {
          throw ArgumentError.value(key, 'asset', 'The asset must be inside flutter_assets.');
        }
        location = uri.toFilePath(windows: true);
      case DataSourceType.file:
        location = Uri.parse(source.uri!).toFilePath(windows: true);
      case DataSourceType.network:
        final Uri? uri = Uri.tryParse(source.uri ?? '');
        if (uri == null || !uri.hasAuthority || !<String>{'http', 'https'}.contains(uri.scheme)) {
          throw ArgumentError.value(source.uri, 'uri', 'An HTTP or HTTPS URL is required.');
        }
        location = uri.toString();
      case DataSourceType.contentUri:
        throw UnsupportedError('Content URIs are only supported on Android.');
    }

    HttpSource? http;
    try {
      if (source.sourceType == DataSourceType.network) {
        http = await HttpSource.open(Uri.parse(location), source.httpHeaders);
        if (source.httpHeaders.isNotEmpty) {
          location = http.uri.toString();
        }
      }

      if (generation != _generation) {
        throw StateError('The player platform was reset.');
      }

      // Native adaptive-source detection needs the original URL and relay even
      // when the caller supplies no headers.
      final int id = await _api.create(
        location,
        http == null ? null : source.uri,
        http?.uri.toString(),
      );

      if (generation != _generation) {
        await http?.close();
        await _api.dispose(id);
        throw StateError('The player platform was reset.');
      }

      if (http != null) {
        _httpSources[id] = http;
      }
      return id;
    } on Object {
      await http?.close();
      rethrow;
    }
  }

  @override
  Future<void> dispose(int playerId) async {
    // Native shutdown may wait for reads, so abort the relay before waiting on it.
    await _httpSources.remove(playerId)?.close();
    await _api.dispose(playerId);
  }

  @override
  bool isAudioTrackSupportAvailable() => true;

  @override
  bool isVideoTrackSupportAvailable() => true;

  @override
  Future<List<VideoAudioTrack>> getAudioTracks(int playerId) async =>
      (await _api.getTracks(playerId, true))
          .map(
            (TrackData track) => VideoAudioTrack(
              id: track.id.toString(),
              isSelected: track.isSelected,
              label: track.label,
              language: track.language,
              bitrate: track.bitrate,
              sampleRate: track.sampleRate,
              channelCount: track.channelCount,
            ),
          )
          .toList();

  @override
  Future<List<VideoTrack>> getVideoTracks(int playerId) async =>
      (await _api.getTracks(playerId, false))
          .map(
            (TrackData track) => VideoTrack(
              id: track.id.toString(),
              isSelected: track.isSelected,
              label: track.label,
              bitrate: track.bitrate,
              width: track.width,
              height: track.height,
              frameRate: track.frameRate,
            ),
          )
          .toList();

  int _trackId(String id) {
    final int? index = int.tryParse(id);
    if (index == null || index < 0 || index > 0xffffffff) {
      throw ArgumentError.value(id, 'trackId', 'Invalid Windows stream index.');
    }
    return index;
  }

  @override
  Future<void> selectAudioTrack(int playerId, String trackId) async =>
      _api.selectTrack(playerId, true, _trackId(trackId));

  @override
  Future<void> selectVideoTrack(int playerId, VideoTrack? track) async =>
      _api.selectTrack(playerId, false, track == null ? null : _trackId(track.id));

  @override
  Future<void> play(int playerId) => _api.play(playerId);

  @override
  Future<void> pause(int playerId) => _api.pause(playerId);

  @override
  Future<void> setLooping(int playerId, bool looping) => _api.setLooping(playerId, looping);

  @override
  Future<void> setVolume(int playerId, double volume) => _api.setVolume(playerId, volume);

  @override
  Future<void> setPlaybackSpeed(int playerId, double speed) =>
      _api.setPlaybackSpeed(playerId, speed);

  @override
  Future<void> seekTo(int playerId, Duration position) =>
      _api.seekTo(playerId, position.inMilliseconds);

  @override
  Future<Duration> getPosition(int playerId) async {
    return Duration(milliseconds: await _api.getPosition(playerId));
  }

  @override
  Future<void> setMixWithOthers(bool mixWithOthers) async {
    // Windows uses the shared system mixer; this backend does not claim exclusive focus.
  }

  @override
  Future<void> setAllowBackgroundPlayback(bool allowBackgroundPlayback) async {
    // The controller handles app lifecycle changes; Windows needs no background audio mode.
  }

  @override
  Future<void> setPreventsDisplaySleepDuringVideoPlayback(
    int playerId,
    bool preventsDisplaySleepDuringVideoPlayback,
  ) {
    return _api.setPreventsDisplaySleep(playerId, preventsDisplaySleepDuringVideoPlayback);
  }

  @override
  Widget buildView(int playerId) => Texture(textureId: playerId);

  @override
  Widget buildViewWithOptions(VideoViewOptions options) => buildView(options.playerId);

  @override
  Stream<VideoEvent> videoEventsFor(int playerId) {
    return EventChannel('flutter.dev/video_player_windows/events/$playerId')
        .receiveBroadcastStream()
        .handleError((Object error, StackTrace stack) {
          final HttpSource? source = _httpSources.remove(playerId);
          if (source != null) {
            unawaited(source.close());
          }
          Error.throwWithStackTrace(error, stack);
        })
        .map((dynamic event) {
          final map = event as Map<dynamic, dynamic>;
          return switch (map['event']) {
            'initialized' => VideoEvent(
              eventType: VideoEventType.initialized,
              duration: Duration(milliseconds: map['duration'] as int),
              size: Size((map['width'] as num).toDouble(), (map['height'] as num).toDouble()),
            ),
            'completed' => VideoEvent(eventType: VideoEventType.completed),
            'bufferingStart' => VideoEvent(eventType: VideoEventType.bufferingStart),
            'bufferingEnd' => VideoEvent(eventType: VideoEventType.bufferingEnd),
            'isPlayingStateUpdate' => VideoEvent(
              eventType: VideoEventType.isPlayingStateUpdate,
              isPlaying: map['isPlaying'] as bool,
            ),
            'bufferingUpdate' => VideoEvent(
              eventType: VideoEventType.bufferingUpdate,
              buffered: (map['values'] as List<dynamic>).map((dynamic range) {
                final pair = range as List<dynamic>;
                return DurationRange(
                  Duration(milliseconds: pair[0] as int),
                  Duration(milliseconds: pair[1] as int),
                );
              }).toList(),
            ),
            _ => VideoEvent(eventType: VideoEventType.unknown),
          };
        });
  }
}
