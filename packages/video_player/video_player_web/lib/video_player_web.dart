// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:video_player_platform_interface/video_player_platform_interface.dart';
import 'package:web/web.dart' as web;

import 'src/video_player.dart';

/// The web implementation of [VideoPlayerPlatform].
///
/// This class implements the `package:video_player` functionality for the web.
class VideoPlayerPlugin extends VideoPlayerPlatform {
  /// Registers this class as the default instance of [VideoPlayerPlatform].
  static void registerWith(Registrar registrar) {
    VideoPlayerPlatform.instance = VideoPlayerPlugin();
  }

  // Map of playerId -> VideoPlayer instances.
  final Map<int, VideoPlayer> _videoPlayers = <int, VideoPlayer>{};

  int _playerCounter = 1;

  @override
  Future<void> init() async {
    return _disposeAllPlayers();
  }

  @override
  Future<void> dispose(int playerId) async {
    _player(playerId).dispose();
    _videoPlayers.remove(playerId);
    return;
  }

  void _disposeAllPlayers() {
    for (final VideoPlayer videoPlayer in _videoPlayers.values) {
      videoPlayer.dispose();
    }
    _videoPlayers.clear();
  }

  @override
  Future<int> create(DataSource dataSource) {
    return createWithOptions(
      VideoCreationOptions(
        dataSource: dataSource,
        // Web only supports platform views.
        viewType: VideoViewType.platformView,
      ),
    );
  }

  @override
  Future<int> createWithOptions(VideoCreationOptions options) async {
    // Parameter options.viewType is ignored because web only supports platform views.

    final DataSource dataSource = options.dataSource;
    final int playerId = _playerCounter++;

    late String uri;
    switch (dataSource.sourceType) {
      case DataSourceType.network:
        // Do NOT modify the incoming uri, it can be a Blob, and Safari doesn't
        // like blobs that have changed.
        uri = dataSource.uri ?? '';
      case DataSourceType.asset:
        String assetUrl = dataSource.asset!;
        if (dataSource.package != null && dataSource.package!.isNotEmpty) {
          assetUrl = 'packages/${dataSource.package}/$assetUrl';
        }
        assetUrl = ui_web.assetManager.getAssetUrl(assetUrl);
        uri = assetUrl;
      case DataSourceType.file:
        return Future<int>.error(UnimplementedError(
            'web implementation of video_player cannot play local files'));
      case DataSourceType.contentUri:
        return Future<int>.error(UnimplementedError(
            'web implementation of video_player cannot play content uri'));
    }

    final web.HTMLVideoElement videoElement = web.HTMLVideoElement()
      ..id = 'videoElement-$playerId'
      ..style.border = 'none'
      ..style.height = '100%'
      ..style.width = '100%';

    // TODO(hterkelsen): Use initialization parameters once they are available
    ui_web.platformViewRegistry.registerViewFactory(
        'videoPlayer-$playerId', (int viewId) => videoElement);

    final VideoPlayer player = VideoPlayer(videoElement: videoElement)
      ..initialize(
        src: uri,
      );

    _videoPlayers[playerId] = player;

    return playerId;
  }

  @override
  Future<void> setLooping(int playerId, bool looping) async {
    return _player(playerId).setLooping(looping);
  }

  @override
  Future<void> play(int playerId) async {
    return _player(playerId).play();
  }

  @override
  Future<void> pause(int playerId) async {
    return _player(playerId).pause();
  }

  @override
  Future<void> setVolume(int playerId, double volume) async {
    return _player(playerId).setVolume(volume);
  }

  @override
  Future<void> setPlaybackSpeed(int playerId, double speed) async {
    return _player(playerId).setPlaybackSpeed(speed);
  }

  @override
  Future<void> seekTo(int playerId, Duration position) async {
    return _player(playerId).seekTo(position);
  }

  @override
  Future<Duration> getPosition(int playerId) async {
    return _player(playerId).getPosition();
  }

  @override
  Stream<VideoEvent> videoEventsFor(int playerId) {
    return _player(playerId).events;
  }

  @override
  Future<void> setWebOptions(int playerId, VideoPlayerWebOptions options) {
    return _player(playerId).setOptions(options);
  }

  // Retrieves a [VideoPlayer] by its internal `id`.
  // It must have been created earlier from the [create] method.
  VideoPlayer _player(int id) {
    return _videoPlayers[id]!;
  }

  @override
  Widget buildView(int playerId) {
    return HtmlElementView(viewType: 'videoPlayer-$playerId');
  }

  /// Sets the audio mode to mix with other sources (ignored).
  @override
  Future<void> setMixWithOthers(bool mixWithOthers) => Future<void>.value();
}
