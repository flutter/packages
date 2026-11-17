// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: avoid_equals_and_hash_code_on_mutable_classes

import 'preview_dynamic_range.dart';
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
    this.fps,
    this.videoBitrate,
    this.audioBitrate,
    this.enableAudio = false,
    this.previewDynamicRange = PreviewDynamicRange.sdr,
  }) : assert(fps == null || fps > 0, 'fps must be null or greater than zero'),
       assert(
         videoBitrate == null || videoBitrate > 0,
         'videoBitrate must be null or greater than zero',
       ),
       assert(
         audioBitrate == null || audioBitrate > 0,
         'audioBitrate must be null or greater than zero',
       );

  /// [ResolutionPreset] affect the quality of video recording and image capture.
  final ResolutionPreset? resolutionPreset;

  /// Rate at which frames should be captured by the camera in frames per second.
  final int? fps;

  /// The video encoding bit rate for recording.
  final int? videoBitrate;

  /// The audio encoding bit rate for recording.
  final int? audioBitrate;

  /// Controls audio presence in recorded video.
  final bool enableAudio;

  /// The dynamic range requested for the camera session.
  ///
  /// [PreviewDynamicRange.hlg10] shows an HDR preview, and it can also change
  /// other outputs of the session, for example the format of recorded video,
  /// image streaming, and zero-shutter-lag support. See the platform
  /// implementation for the exact behavior.
  ///
  /// This is a request: if the camera or the platform does not support it, or
  /// on some platforms the resolution preset has no HDR format, the camera
  /// uses [PreviewDynamicRange.sdr]. The applied range is set when the camera
  /// is created and does not change while it is in use; operations that
  /// cannot keep it fail with a `CameraException`, which an image stream
  /// reports as a stream error. Use
  /// `CameraPlatform.getSupportedPreviewDynamicRanges` to check support before
  /// creating the camera, and `CameraPlatform.getPreviewDynamicRange` to read
  /// the dynamic range that is applied.
  final PreviewDynamicRange previewDynamicRange;

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
        fps == other.fps &&
        videoBitrate == other.videoBitrate &&
        audioBitrate == other.audioBitrate &&
        enableAudio == other.enableAudio &&
        previewDynamicRange == other.previewDynamicRange;
  }

  @override
  int get hashCode => Object.hash(
    resolutionPreset,
    fps,
    videoBitrate,
    audioBitrate,
    enableAudio,
    previewDynamicRange,
  );

  @override
  String toString() {
    return 'MediaSettings{'
        'resolutionPreset: $resolutionPreset, '
        'fps: $fps, '
        'videoBitrate: $videoBitrate, '
        'audioBitrate: $audioBitrate, '
        'enableAudio: $enableAudio, '
        'previewDynamicRange: $previewDynamicRange}';
  }
}
