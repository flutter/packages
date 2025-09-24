// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/src/messages.g.dart',
    javaOut:
        'android/src/main/java/io/flutter/plugins/videoplayer/Messages.java',
    javaOptions: JavaOptions(package: 'io.flutter.plugins.videoplayer'),
    copyrightHeader: 'pigeons/copyright.txt',
  ),
)
/// Pigeon equivalent of VideoViewType.
enum PlatformVideoViewType { textureView, platformView }

/// Pigeon equivalent of video_platform_interface's VideoFormat.
enum PlatformVideoFormat { dash, hls, ss }

/// Information passed to the platform view creation.
class PlatformVideoViewCreationParams {
  const PlatformVideoViewCreationParams({required this.playerId});

  final int playerId;
}

class CreateMessage {
  CreateMessage({required this.uri, required this.httpHeaders});
  String uri;
  PlatformVideoFormat? formatHint;
  Map<String, String> httpHeaders;
  String? userAgent;
  PlatformVideoViewType? viewType;
}

class PlaybackState {
  PlaybackState({required this.playPosition, required this.bufferPosition});

  /// The current playback position, in milliseconds.
  final int playPosition;

  /// The current buffer position, in milliseconds.
  final int bufferPosition;
}

@HostApi()
abstract class AndroidVideoPlayerApi {
  void initialize();
  int create(CreateMessage msg);
  void dispose(int playerId);
  void setMixWithOthers(bool mixWithOthers);
  String getLookupKeyForAsset(String asset, String? packageName);
}

@HostApi()
abstract class VideoPlayerInstanceApi {
  /// Sets whether to automatically loop playback of the video.
  void setLooping(bool looping);

  /// Sets the volume, with 0.0 being muted and 1.0 being full volume.
  void setVolume(double volume);

  /// Sets the playback speed as a multiple of normal speed.
  void setPlaybackSpeed(double speed);

  /// Begins playback if the video is not currently playing.
  void play();

  /// Pauses playback if the video is currently playing.
  void pause();

  /// Seeks to the given playback position, in milliseconds.
  void seekTo(int position);

  /// Returns the current playback state.
  ///
  /// This is combined into a single call to minimize platform channel calls for
  /// state that needs to be polled frequently.
  PlaybackState getPlaybackState();
}
