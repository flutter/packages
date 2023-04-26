// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: avoid_equals_and_hash_code_on_mutable_classes

import 'resolution_preset.dart';

/// recording media settings.
class MediaSettings {
  /// Creates a [MediaSettings].
  const MediaSettings({
    this.resolutionPreset,
    this.fps,
    this.videoBitrate,
    this.audioBitrate,
    this.enableAudio = false,
  });

  /// resolution preset
  final ResolutionPreset? resolutionPreset;

  /// camera fps
  final int? fps;

  /// recording video bitrate
  final int? videoBitrate;

  /// recording audio bitrate
  final int? audioBitrate;

  /// enable audio
  final bool enableAudio;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MediaSettings &&
          runtimeType == other.runtimeType &&
          resolutionPreset == other.resolutionPreset &&
          fps == other.fps &&
          videoBitrate == other.videoBitrate &&
          audioBitrate == other.audioBitrate &&
          enableAudio == other.enableAudio;

  @override
  int get hashCode =>
      resolutionPreset.hashCode ^
      fps.hashCode ^
      videoBitrate.hashCode ^
      audioBitrate.hashCode ^
      enableAudio.hashCode;

  @override
  String toString() =>
      'MediaSettings{resolutionPreset: $resolutionPreset, fps: $fps, videoBitrate: $videoBitrate, audioBitrate: $audioBitrate, enableAudio: $enableAudio}';
}
