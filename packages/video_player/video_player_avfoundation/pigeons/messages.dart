// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(PigeonOptions(
  dartOut: 'lib/src/messages.g.dart',
  dartTestOut: 'test/test_api.dart',
  objcHeaderOut: 'ios/Classes/messages.g.h',
  objcSourceOut: 'ios/Classes/messages.g.m',
  objcOptions: ObjcOptions(
    prefix: 'FLT',
  ),
  copyrightHeader: 'pigeons/copyright.txt',
))
class TextureMessage {
  TextureMessage(this.textureId);
  int textureId;
}

class LoopingMessage {
  LoopingMessage(this.textureId, this.isLooping);
  int textureId;
  bool isLooping;
}

class VolumeMessage {
  VolumeMessage(this.textureId, this.volume);
  int textureId;
  double volume;
}

class PlaybackSpeedMessage {
  PlaybackSpeedMessage(this.textureId, this.speed);
  int textureId;
  double speed;
}

class PositionMessage {
  PositionMessage(this.textureId, this.position);
  int textureId;
  int position;
}

class DurationMessage {
  DurationMessage(this.textureId, this.duration);
  int textureId;
  int duration;
}

class StartMessage {
  StartMessage(this.textureId, this.start);
  int textureId;
  int start;
}

class CreateMessage {
  CreateMessage({required this.httpHeaders});
  String? asset;
  String? uri;
  String? packageName;
  String? formatHint;
  Map<String?, String?> httpHeaders;
}

class MixWithOthersMessage {
  MixWithOthersMessage(this.mixWithOthers);
  bool mixWithOthers;
}

class BufferMessage {
  BufferMessage(this.textureId, this.second);
  int textureId;
  int second;
}

class IsPlayingMessage {
  IsPlayingMessage(this.textureId, this.isPlaying);
  int textureId;
  bool isPlaying;
}

@HostApi(dartHostTestHandler: 'TestHostVideoPlayerApi')
abstract class AVFoundationVideoPlayerApi {
  @ObjCSelector('initialize')
  void initialize();
  @ObjCSelector('create:')
  TextureMessage create(CreateMessage msg);
  @ObjCSelector('dispose:')
  void dispose(TextureMessage msg);
  @ObjCSelector('setLooping:')
  void setLooping(LoopingMessage msg);
  @ObjCSelector('setVolume:')
  void setVolume(VolumeMessage msg);
  @ObjCSelector('setPlaybackSpeed:')
  void setPlaybackSpeed(PlaybackSpeedMessage msg);
  @ObjCSelector('play:')
  void play(TextureMessage msg);
  @ObjCSelector('position:')
  PositionMessage position(TextureMessage msg);
  @ObjCSelector('duration:')
  DurationMessage duration(TextureMessage msg);
  @ObjCSelector('start:')
  StartMessage start(TextureMessage msg);
  @ObjCSelector('seekTo:')
  @async
  void seekTo(PositionMessage msg);
  @ObjCSelector('pause:')
  void pause(TextureMessage msg);
  @ObjCSelector('setMixWithOthers:')
  void setMixWithOthers(MixWithOthersMessage msg);
  @ObjCSelector('setBuffer:')
  void setBuffer(BufferMessage msg);
  @ObjCSelector('isPlaying:')
  IsPlayingMessage isPlaying(TextureMessage msg);
}
