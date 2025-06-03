// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(PigeonOptions(
  dartOut: 'lib/src/messages.g.dart',
  dartTestOut: 'test/test_api.g.dart',
  objcHeaderOut:
      'darwin/video_player_avfoundation/Sources/video_player_avfoundation/include/video_player_avfoundation/messages.g.h',
  objcSourceOut:
      'darwin/video_player_avfoundation/Sources/video_player_avfoundation/messages.g.m',
  objcOptions: ObjcOptions(
    prefix: 'FVP',
    headerIncludePath: './include/video_player_avfoundation/messages.g.h',
  ),
  copyrightHeader: 'pigeons/copyright.txt',
))

/// Pigeon equivalent of VideoViewType.
enum PlatformVideoViewType {
  textureView,
  platformView,
}

/// Information passed to the platform view creation.
class PlatformVideoViewCreationParams {
  const PlatformVideoViewCreationParams({
    required this.playerId,
  });

  final int playerId;
}

class CreationOptions {
  CreationOptions({
    required this.httpHeaders,
    required this.viewType,
  });

  String? asset;
  String? uri;
  String? packageName;
  String? formatHint;
  Map<String, String> httpHeaders;
  PlatformVideoViewType viewType;
}

@HostApi(dartHostTestHandler: 'TestHostVideoPlayerApi')
abstract class AVFoundationVideoPlayerApi {
  @ObjCSelector('initialize')
  void initialize();
  @ObjCSelector('createWithOptions:')
  // Creates a new player and returns its ID.
  int create(CreationOptions creationOptions);
  @ObjCSelector('disposePlayer:')
  void dispose(int playerId);
  @ObjCSelector('setLooping:forPlayer:')
  void setLooping(bool isLooping, int playerId);
  @ObjCSelector('setVolume:forPlayer:')
  void setVolume(double volume, int playerId);
  @ObjCSelector('setPlaybackSpeed:forPlayer:')
  void setPlaybackSpeed(double speed, int playerId);
  @ObjCSelector('playPlayer:')
  void play(int playerId);
  @ObjCSelector('positionForPlayer:')
  int getPosition(int playerId);
  @async
  @ObjCSelector('seekTo:forPlayer:')
  void seekTo(int position, int playerId);
  @ObjCSelector('pausePlayer:')
  void pause(int playerId);
  @ObjCSelector('setMixWithOthers:')
  void setMixWithOthers(bool mixWithOthers);
}
