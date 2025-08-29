// Copyright 2013 The Flutter Authors. All rights reserved.
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

/// Represents an audio track in a video.
class AudioTrackMessage {
  AudioTrackMessage({
    required this.id,
    required this.label,
    required this.language,
    required this.isSelected,
    this.bitrate,
    this.sampleRate,
    this.channelCount,
    this.codec,
  });

  String id;
  String label;
  String language;
  bool isSelected;
  int? bitrate;
  int? sampleRate;
  int? channelCount;
  String? codec;
}

/// Raw audio track data from ExoPlayer Format objects.
class ExoPlayerAudioTrackData {
  ExoPlayerAudioTrackData({
    required this.trackId,
    this.label,
    this.language,
    required this.isSelected,
    this.bitrate,
    this.sampleRate,
    this.channelCount,
    this.codec,
  });

  String trackId;
  String? label;
  String? language;
  bool isSelected;
  int? bitrate;
  int? sampleRate;
  int? channelCount;
  String? codec;
}

/// Container for raw audio track data from Android ExoPlayer.
class NativeAudioTrackData {
  NativeAudioTrackData({
    this.exoPlayerTracks,
  });

  /// ExoPlayer-based tracks
  List<ExoPlayerAudioTrackData>? exoPlayerTracks;
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

  /// Gets the available audio tracks for the video.
  NativeAudioTrackData getAudioTracks();

  /// Selects an audio track by its ID.
  void selectAudioTrack(String trackId);
}
