// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// Contains plugin-class-level APIs.

import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/src/messages.g.dart',
    swiftOut: 'darwin/video_player_avfoundation/Sources/video_player_avfoundation/Messages.g.swift',
    copyrightHeader: 'pigeons/copyright.txt',
  ),
)
/// Information passed to the platform view creation.
class PlatformVideoViewCreationParams {
  const PlatformVideoViewCreationParams({required this.playerId});

  final int playerId;
}

class CreationOptions {
  CreationOptions({required this.uri, required this.httpHeaders});

  String uri;
  Map<String, String> httpHeaders;
}

class TexturePlayerIds {
  TexturePlayerIds({required this.playerId, required this.textureId});

  final int playerId;
  final int textureId;
}

/// Raw audio track data from AVMediaSelectionOption (for HLS streams).
class MediaSelectionAudioTrackData {
  MediaSelectionAudioTrackData({
    required this.index,
    this.displayName,
    this.languageCode,
    required this.isSelected,
    this.commonMetadataTitle,
  });

  int index;
  String? displayName;
  String? languageCode;
  bool isSelected;
  String? commonMetadataTitle;
}

/// Video track data from AVAssetVariant (HLS variants) for iOS 15+.
class MediaSelectionVideoTrackData {
  MediaSelectionVideoTrackData({
    required this.variantIndex,
    this.label,
    this.bitrate,
    this.width,
    this.height,
    this.frameRate,
    this.codec,
    required this.isSelected,
  });

  int variantIndex;
  String? label;
  int? bitrate;
  int? width;
  int? height;
  double? frameRate;
  String? codec;
  bool isSelected;
}

/// Video track data from AVAssetTrack (regular videos).
class AssetVideoTrackData {
  AssetVideoTrackData({
    required this.trackId,
    this.label,
    this.width,
    this.height,
    this.frameRate,
    this.codec,
    required this.isSelected,
  });

  int trackId;
  String? label;
  int? width;
  int? height;
  double? frameRate;
  String? codec;
  bool isSelected;
}

/// Container for video track data from iOS.
class NativeVideoTrackData {
  NativeVideoTrackData({this.assetTracks, this.mediaSelectionTracks});

  /// Asset-based tracks (for regular videos)
  List<AssetVideoTrackData>? assetTracks;

  /// Media selection tracks (for HLS variants on iOS 15+)
  List<MediaSelectionVideoTrackData>? mediaSelectionTracks;
}

sealed class PlatformVideoEvent {}

/// Sent when the video is initialized and ready to play.
class InitializationEvent extends PlatformVideoEvent {
  /// The video duration in milliseconds.
  late final int durationMilliseconds;

  /// The width of the video in pixels.
  late final double width;

  /// The height of the video in pixels.
  late final double height;
}

/// Sent when the video starts buffering.
class BufferingStartEvent extends PlatformVideoEvent {}

/// Sent when the video ends buffering.
class BufferingEndEvent extends PlatformVideoEvent {}

class PlatformDurationRange {
  late final int startMilliseconds;
  late final int durationMilliseconds;
}

/// Sent when the video buffering position updates.
class BufferingUpdateEvent extends PlatformVideoEvent {
  late final List<PlatformDurationRange> bufferedRanges;
}

/// Sent when playback completes.
class PlaybackCompleteEvent extends PlatformVideoEvent {}

/// Sent when the video starts or stops playing.
class IsPlayingStateEvent extends PlatformVideoEvent {
  late final bool isPlaying;
}

@HostApi()
abstract class AVFoundationVideoPlayerApi {
  void initialize();
  // Creates a new player using a platform view for rendering and returns its
  // ID.
  @async
  @SwiftFunction('createPlatformViewPlayer(options:)')
  int createForPlatformView(CreationOptions creationOptions);
  // Creates a new player using a texture for rendering and returns its IDs.
  @async
  @SwiftFunction('createTexturePlayer(options:)')
  TexturePlayerIds createForTextureView(CreationOptions creationOptions);
  @SwiftFunction('setMixWithOthers(_:)')
  void setMixWithOthers(bool mixWithOthers);
  @SwiftFunction('fileURLForAsset(name:package:)')
  String? getAssetUrl(String asset, String? package);
}

@HostApi()
abstract class VideoPlayerInstanceApi {
  @SwiftFunction('setLooping(_:)')
  void setLooping(bool looping);
  @SwiftFunction('setVolume(_:)')
  void setVolume(double volume);
  @SwiftFunction('setPlaybackSpeed(_:)')
  void setPlaybackSpeed(double speed);
  void play();
  int getPosition();
  @async
  @SwiftFunction('seek(to:)')
  void seekTo(int position);
  void pause();
  void dispose();
  @async
  List<MediaSelectionAudioTrackData> getAudioTracks();
  @async
  @SwiftFunction('selectAudioTrack(atIndex:)')
  void selectAudioTrack(int trackIndex);

  /// Gets the available video tracks for the video.
  @async
  NativeVideoTrackData getVideoTracks();

  /// Selects a video track by setting preferredPeakBitRate.
  /// Pass 0 to enable auto quality selection.
  @SwiftFunction('selectVideoTrack(withBitrate:)')
  void selectVideoTrack(int bitrate);

  @SwiftFunction('setPreventsDisplaySleepDuringVideoPlayback(_:)')
  void setPreventsDisplaySleepDuringVideoPlayback(bool preventsDisplaySleepDuringVideoPlayback);
}

@EventChannelApi()
abstract class VideoEventChannel {
  PlatformVideoEvent videoEvents();
}
