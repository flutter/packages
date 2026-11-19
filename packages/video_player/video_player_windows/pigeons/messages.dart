// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:pigeon/pigeon.dart';

class TrackData {
  TrackData({
    required this.id,
    required this.isSelected,
    this.label,
    this.language,
    this.bitrate,
    this.sampleRate,
    this.channelCount,
    this.width,
    this.height,
    this.frameRate,
  });
  int id;
  bool isSelected;
  String? label;
  String? language;
  int? bitrate;
  int? sampleRate;
  int? channelCount;
  int? width;
  int? height;
  double? frameRate;
}

@ConfigurePigeon(
  PigeonOptions(
    dartPackageName: 'video_player_windows',
    dartOut: 'lib/src/messages.g.dart',
    cppOptions: CppOptions(namespace: 'video_player_windows'),
    cppHeaderOut: 'windows/messages.g.h',
    cppSourceOut: 'windows/messages.g.cpp',
    copyrightHeader: 'pigeons/copyright.txt',
  ),
)
@HostApi()
abstract class WindowsVideoPlayerApi {
  void initialize();
  int create(String source, String? networkSource, String? networkRelay);
  void dispose(int playerId);
  void play(int playerId);
  void pause(int playerId);
  void setLooping(int playerId, bool looping);
  void setVolume(int playerId, double volume);
  void setPlaybackSpeed(int playerId, double speed);
  void seekTo(int playerId, int milliseconds);
  int getPosition(int playerId);
  void setPreventsDisplaySleep(int playerId, bool preventsDisplaySleep);
  List<TrackData> getTracks(int playerId, bool audio);
  void selectTrack(int playerId, bool audio, int? trackId);
}
