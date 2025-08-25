// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';

import 'camera_image_data.dart';

/// Options wrapper for [CameraPlatform.startVideoCapturing] parameters.
@immutable
class VideoCaptureOptions {
  /// Constructs a new instance.
  const VideoCaptureOptions(
    this.cameraId, {
    @Deprecated(
      'This parameter is unused, and will be ignored on all platforms',
    )
    this.maxDuration,
    this.streamCallback,
    this.streamOptions,
    this.enableAndroidPersistentRecording = false
  }) : assert(
         streamOptions == null || streamCallback != null,
         'Must specify streamCallback if providing streamOptions.',
       );

  /// The ID of the camera to use for capturing.
  final int cameraId;

  /// The maximum time to perform capturing for.
  @Deprecated('This parameter is unused, and will be ignored on all platforms')
  // Platform implementations should not implement this, as it will never be
  // passed from the app-facing layer.
  final Duration? maxDuration;

  /// An optional callback to enable streaming.
  ///
  /// If set, then each image captured by the camera will be
  /// passed to this callback.
  final void Function(CameraImageData image)? streamCallback;

  /// Configuration options for streaming.
  ///
  /// Should only be set if a streamCallback is also present.
  final CameraImageStreamOptions? streamOptions;

  /// **Android only.**
  ///
  /// When `true`, configures the recording to be a persistent recording.
  ///
  /// A persistent recording will only be stopped by explicitly calling [CameraController.stopVideoRecording] and will ignore events that would normally cause recording to stop, such as
  /// * lifecycle events
  /// * calling [CameraController.setDescription] while a recording is in progress
  ///
  /// Defaults to `false`.
  final bool enableAndroidPersistentRecording;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VideoCaptureOptions &&
          runtimeType == other.runtimeType &&
          cameraId == other.cameraId &&
          maxDuration == other.maxDuration &&
          streamCallback == other.streamCallback &&
          streamOptions == other.streamOptions &&
          enableAndroidPersistentRecording == other.enableAndroidPersistentRecording;

  @override
  int get hashCode =>
      Object.hash(cameraId, maxDuration, streamCallback, streamOptions, enableAndroidPersistentRecording);
}
