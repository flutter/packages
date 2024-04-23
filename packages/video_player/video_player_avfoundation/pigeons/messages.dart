// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(PigeonOptions(
  dartOut: 'lib/src/messages.g.dart',
  dartTestOut: 'test/test_api.g.dart',
  objcHeaderOut: 'darwin/Classes/messages.g.h',
  objcSourceOut: 'darwin/Classes/messages.g.m',
  objcOptions: ObjcOptions(
    prefix: 'FVP',
  ),
  copyrightHeader: 'pigeons/copyright.txt',
))
class CreationOptions {
  CreationOptions({required this.httpHeaders});
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

class AutomaticallyStartsPictureInPictureMessage {
  AutomaticallyStartsPictureInPictureMessage(
    this.textureId,
    this.enableStartPictureInPictureAutomaticallyFromInline,
  );

  int textureId;
  bool enableStartPictureInPictureAutomaticallyFromInline;
}

class SetPictureInPictureOverlaySettingsMessage {
  SetPictureInPictureOverlaySettingsMessage(
    this.textureId,
    this.settings,
  );

  int textureId;
  PictureInPictureOverlaySettingsMessage? settings;
}

class PictureInPictureOverlaySettingsMessage {
  PictureInPictureOverlaySettingsMessage({
    required this.top,
    required this.left,
    required this.width,
    required this.height,
  });

  double top;
  double left;
  double width;
  double height;
}

class StartPictureInPictureMessage {
  StartPictureInPictureMessage(this.textureId);

  int textureId;
}

class StopPictureInPictureMessage {
  StopPictureInPictureMessage(this.textureId);

  int textureId;
}

@HostApi(dartHostTestHandler: 'TestHostVideoPlayerApi')
abstract class AVFoundationVideoPlayerApi {
  @ObjCSelector('initialize')
  void initialize();
  @ObjCSelector('createWithOptions:')
  // Creates a new player and returns its ID.
  int create(CreationOptions creationOptions);
  @ObjCSelector('disposePlayer:')
  void dispose(int textureId);
  @ObjCSelector('setLooping:forPlayer:')
  void setLooping(bool isLooping, int textureId);
  @ObjCSelector('setVolume:forPlayer:')
  void setVolume(double volume, int textureId);
  @ObjCSelector('setPlaybackSpeed:forPlayer:')
  void setPlaybackSpeed(double speed, int textureId);
  @ObjCSelector('playPlayer:')
  void play(int textureId);
  @ObjCSelector('positionForPlayer:')
  int getPosition(int textureId);
  @async
  @ObjCSelector('seekTo:forPlayer:')
  void seekTo(int position, int textureId);
  @ObjCSelector('pausePlayer:')
  void pause(int textureId);
  @ObjCSelector('setMixWithOthers:')
  void setMixWithOthers(bool mixWithOthers);
  @ObjCSelector('isPictureInPictureSupported')
  bool isPictureInPictureSupported();
  @ObjCSelector('setPictureInPictureOverlaySettings:')
  void setPictureInPictureOverlaySettings(
      SetPictureInPictureOverlaySettingsMessage msg);
  @ObjCSelector('setAutomaticallyStartsPictureInPicture:')
  void setAutomaticallyStartsPictureInPicture(
      AutomaticallyStartsPictureInPictureMessage msg);
  @ObjCSelector('startPictureInPicture:')
  void startPictureInPicture(StartPictureInPictureMessage msg);
  @ObjCSelector('stopPictureInPicture:')
  void stopPictureInPicture(StopPictureInPictureMessage msg);
}
