// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(PigeonOptions(
  dartOut: 'lib/src/messages.g.dart',
  dartTestOut: 'test/test_api.g.dart',
  javaOut: 'android/src/main/java/io/flutter/plugins/videoplayer/Messages.java',
  javaOptions: JavaOptions(
    package: 'io.flutter.plugins.videoplayer',
  ),
  copyrightHeader: 'pigeons/copyright.txt',
))
class CreateMessage {
  CreateMessage({required this.httpHeaders});
  String? asset;
  String? uri;
  String? packageName;
  String? formatHint;
  Map<String, String> httpHeaders;
}

@HostApi(dartHostTestHandler: 'TestHostVideoPlayerApi')
abstract class AndroidVideoPlayerApi {
  void initialize();
  int create(CreateMessage msg);
  void dispose(int textureId);
  void setLooping(int textureId, bool looping);
  void setVolume(int textureId, double volume);
  void setPlaybackSpeed(int textureId, double speed);
  void play(int textureId);
  int position(int textureId);
  void seekTo(int textureId, int position);
  void pause(int textureId);
  void setMixWithOthers(bool mixWithOthers);
}
