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
  /// Initializes the video player.
  void initialize();

  /// Creates a new instance of the video player.
  /// Returns the textureId of the created player.
  int create(String? asset, String? uri, Map<String?, String?> httpHeaders);

  /// Disposes the video player with the given textureId.
  void dispose(int textureId);

  /// Sets the looping state of the video player with the given textureId.
  void setLooping(int textureId, bool isLooping);

  /// Sets the volume of the video player with the given textureId.
  void setVolume(int textureId, double volume);

  /// Sets the playback speed of the video player with the given textureId.
  void setPlaybackSpeed(int textureId, double speed);

  /// Starts playing the video in the video player with the given textureId.
  void play(int textureId);

  /// Gets the current position of the video player with the given textureId.
  /// Returns the position in milliseconds.
  int getPosition(int textureId);

  /// Seeks to the given position in the video player with the given textureId.
  /// The position is in milliseconds.
  void seekTo(int textureId, int position);

  /// Pauses the video in the video player with the given textureId.
  void pause(int textureId);
}
