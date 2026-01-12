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
}
