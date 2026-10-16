// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: avoid_equals_and_hash_code_on_mutable_classes

import 'resolution_preset.dart';

/// Recording media settings.
///
/// Used in [CameraPlatform.createCameraWithSettings].
/// Allows to tune recorded video parameters, such as resolution, frame rate, bitrate.
/// If [fps], [videoBitrate] or [audioBitrate] are passed, they must be greater than zero.
class MediaSettings {
  /// Creates a [MediaSettings].
  const MediaSettings({
    this.resolutionPreset,
    this.photoResolutionPreset,
    this.videoResolutionPreset,
    this.fps,
    this.videoBitrate,
    this.audioBitrate,
    this.enableAudio = false,
  }) : assert(fps == null || fps > 0, 'fps must be null or greater than zero'),
       assert(
         videoBitrate == null || videoBitrate > 0,
         'videoBitrate must be null or greater than zero',
       ),
       assert(
         audioBitrate == null || audioBitrate > 0,
         'audioBitrate must be null or greater than zero',
       );

  /// [ResolutionPreset] affects the quality of video recording and image capture.
  ///
  /// Acts as the default fallback preset if [photoResolutionPreset] or
  /// [videoResolutionPreset] are not set.
  final ResolutionPreset? resolutionPreset;

  /// [ResolutionPreset] specifically targeting still photo capture (`takePicture`).
  ///
  /// When null, platforms fall back to [resolutionPreset].
  ///
  /// Note: On platforms with a single underlying capture session (such as iOS
  /// AVFoundation), photo capture dimensions correspond to the active capture
  /// session format (governed by [videoResolutionPreset]) unless
  /// [photoResolutionPreset] is set to [ResolutionPreset.max], which enables
  /// maximum high-resolution photo dimensions.
  final ResolutionPreset? photoResolutionPreset;

  /// [ResolutionPreset] specifically targeting video recording and camera preview.
  ///
  /// When null, platforms fall back to [resolutionPreset].
  final ResolutionPreset? videoResolutionPreset;

  /// Rate at which frames should be captured by the camera in frames per second.
  final int? fps;

  /// The video encoding bit rate for recording.
  final int? videoBitrate;

  /// The audio encoding bit rate for recording.
  final int? audioBitrate;

  /// Controls audio presence in recorded video.
  final bool enableAudio;

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is MediaSettings &&
        resolutionPreset == other.resolutionPreset &&
        photoResolutionPreset == other.photoResolutionPreset &&
        videoResolutionPreset == other.videoResolutionPreset &&
        fps == other.fps &&
        videoBitrate == other.videoBitrate &&
        audioBitrate == other.audioBitrate &&
        enableAudio == other.enableAudio;
  }

  @override
  int get hashCode => Object.hash(
    resolutionPreset,
    photoResolutionPreset,
    videoResolutionPreset,
    fps,
    videoBitrate,
    audioBitrate,
    enableAudio,
  );

  @override
  String toString() {
    return 'MediaSettings{'
        'resolutionPreset: $resolutionPreset, '
        'photoResolutionPreset: $photoResolutionPreset, '
        'videoResolutionPreset: $videoResolutionPreset, '
        'fps: $fps, '
        'videoBitrate: $videoBitrate, '
        'audioBitrate: $audioBitrate, '
        'enableAudio: $enableAudio}';
  }
}
