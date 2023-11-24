// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// The mode the controller should operate in.
///
/// This capture mode determines whether the capture session is optimized for
/// video recording or photo capture.
///
/// Defaults to [CaptureMode.video] as the camera plugin configuration is
/// currently geared towards video recording.
enum CaptureMode {
  /// Capture a photo.
  photo,

  /// Capture a video, however this allows the user to take photos while recording.
  video;

  /// Deserializes the [captureMode] string argument to the corresponding CaptureMode enum.
  factory CaptureMode.deserialize(String captureMode) {
    switch (captureMode) {
      case 'photo':
        return CaptureMode.photo;
      case 'video':
        return CaptureMode.video;
    }

    throw ArgumentError('"$captureMode" is not a valid CaptureMode value');
  }
}
