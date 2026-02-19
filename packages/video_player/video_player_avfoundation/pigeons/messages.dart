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

  /// Gets the available video tracks for the video.
  @async
  @ObjCSelector('getVideoTracks')
  NativeVideoTrackData getVideoTracks();

  /// Selects a video track by setting preferredPeakBitRate.
  /// Pass 0 to enable auto quality selection.
  @ObjCSelector('selectVideoTrackWithBitrate:')
  void selectVideoTrack(int bitrate);
}
