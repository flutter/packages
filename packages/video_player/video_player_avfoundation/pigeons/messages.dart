// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/src/messages.g.dart',
    objcHeaderOut:
        'darwin/video_player_avfoundation/Sources/video_player_avfoundation/include/video_player_avfoundation/messages.g.h',
    objcSourceOut:
        'darwin/video_player_avfoundation/Sources/video_player_avfoundation/messages.g.m',
    objcOptions: ObjcOptions(
      prefix: 'FVP',
      headerIncludePath: './include/video_player_avfoundation/messages.g.h',
    ),
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

@HostApi()
abstract class AVFoundationVideoPlayerApi {
  @ObjCSelector('initialize')
  void initialize();
  // Creates a new player using a platform view for rendering and returns its
  // ID.
  @ObjCSelector('createPlatformViewPlayerWithOptions:')
  int createForPlatformView(CreationOptions params);
  // Creates a new player using a texture for rendering and returns its IDs.
  @ObjCSelector('createTexturePlayerWithOptions:')
  TexturePlayerIds createForTextureView(CreationOptions creationOptions);
  @ObjCSelector('setMixWithOthers:')
  void setMixWithOthers(bool mixWithOthers);
  @ObjCSelector('fileURLForAssetWithName:package:')
  String? getAssetUrl(String asset, String? package);
}

@HostApi()
abstract class VideoPlayerInstanceApi {
  @ObjCSelector('setLooping:')
  void setLooping(bool looping);
  @ObjCSelector('setVolume:')
  void setVolume(double volume);
  @ObjCSelector('setPlaybackSpeed:')
  void setPlaybackSpeed(double speed);
  void play();
  @ObjCSelector('position')
  int getPosition();
  @async
  @ObjCSelector('seekTo:')
  void seekTo(int position);
  void pause();
  void dispose();
  @ObjCSelector('getAudioTracks')
  List<MediaSelectionAudioTrackData> getAudioTracks();
  @ObjCSelector('selectAudioTrackAtIndex:')
  void selectAudioTrack(int trackIndex);

  /// Sets the maximum bandwidth limit in bits per second for HLS adaptive bitrate streaming.
  /// Pass 0 to remove any bandwidth limit and allow the player to select quality freely.
  /// Common values:
  ///   - 360p: 500000 bps (500 kbps)
  ///   - 480p: 800000 bps (800 kbps)
  ///   - 720p: 1200000 bps (1.2 Mbps)
  ///   - 1080p: 2500000 bps (2.5 Mbps)
  ///
  /// Note: On iOS/macOS, this sets the preferredPeakBitRate on AVPlayerItem,
  /// which influences AVPlayer's HLS variant selection.
  @ObjCSelector('setBandwidthLimit:')
  void setBandwidthLimit(int maxBandwidthBps);
}
