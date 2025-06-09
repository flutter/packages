// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/src/messages.g.dart',
    dartTestOut: 'test/test_api.g.dart',
    javaOut:
        'android/src/main/java/io/flutter/plugins/videoplayer/Messages.java',
    javaOptions: JavaOptions(package: 'io.flutter.plugins.videoplayer'),
    copyrightHeader: 'pigeons/copyright.txt',
  ),
)
/// Pigeon equivalent of VideoViewType.
enum PlatformVideoViewType { textureView, platformView }

/// Information passed to the platform view creation.
class PlatformVideoViewCreationParams {
  const PlatformVideoViewCreationParams({required this.playerId});

  final int playerId;
}

class CreateMessage {
  CreateMessage({required this.httpHeaders});
  String? asset;
  String? uri;
  String? packageName;
  String? formatHint;
  Map<String, String> httpHeaders;
  PlatformVideoViewType? viewType;
}

@HostApi(dartHostTestHandler: 'TestHostVideoPlayerApi')
abstract class AndroidVideoPlayerApi {
  void initialize();
  int create(CreateMessage msg);
  void dispose(int playerId);
  void setLooping(int playerId, bool looping);
  void setVolume(int playerId, double volume);
  void setPlaybackSpeed(int playerId, double speed);
  void play(int playerId);
  int position(int playerId);
  void seekTo(int playerId, int position);
  void pause(int playerId);
  void setMixWithOthers(bool mixWithOthers);
}
