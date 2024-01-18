// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(PigeonOptions(
  dartOut: 'lib/src/messages.g.dart',
  dartTestOut: 'test/test_api.g.dart',
  cppHeaderOut: 'windows/messages.h',
  cppSourceOut: 'windows/messages.cpp',
  cppOptions: CppOptions(
    namespace: 'video_player_windows',
  ),
  copyrightHeader: 'pigeons/copyright.txt',
))
@HostApi(dartHostTestHandler: 'TestHostVideoPlayerApi')
abstract class WindowsVideoPlayerApi {
  void initialize();
  int create(String? asset, String? uri, Map<String?, String?> httpHeaders);
  void dispose(int textureId);
  void setLooping(int textureId, bool isLooping);
  void setVolume(int textureId, double volume);
  void setPlaybackSpeed(int textureId, double speed);
  void play(int textureId);
  int position(int textureId);
  void seekTo(int textureId, int position);
  void pause(int textureId);
}
