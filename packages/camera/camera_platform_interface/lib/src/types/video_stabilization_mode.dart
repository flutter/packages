// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// The possible video stabilization modes that can be capturing video.
enum VideoStabilizationMode {
  /// Video stabilization is disabled.
  off,

  /// Basic video stabilization is enabled.
  /// Maps to CONTROL_VIDEO_STABILIZATION_MODE_ON on Android
  /// and throws CameraException on iOS.
  on,

  /// Standard video stabilization is enabled.
  /// Maps to CONTROL_VIDEO_STABILIZATION_MODE_PREVIEW_STABILIZATION on Android
  /// (camera_android_camerax) and to AVCaptureVideoStabilizationModeStandard
  /// on iOS.
  standard,

  /// Cinematic video stabilization is enabled.
  /// Maps to CONTROL_VIDEO_STABILIZATION_MODE_PREVIEW_STABILIZATION on Android
  /// (camera_android_camerax) and to AVCaptureVideoStabilizationModeCinematic
  /// on iOS.
  cinematic,

  /// Extended cinematic video stabilization is enabled.
  /// Maps to AVCaptureVideoStabilizationModeCinematicExtended on iOS and
  /// throws CameraException on Android.
  cinematicExtended,
}

/// Returns the video stabilization mode as a String.
String serializeVideoStabilizationMode(
    VideoStabilizationMode videoStabilizationMode) {
  switch (videoStabilizationMode) {
    case VideoStabilizationMode.off:
      return 'off';
    case VideoStabilizationMode.on:
      return 'on';
    case VideoStabilizationMode.standard:
      return 'standard';
    case VideoStabilizationMode.cinematic:
      return 'cinematic';
    case VideoStabilizationMode.cinematicExtended:
      return 'cinematicExtended';
  }
}

/// Returns the video stabilization mode for a given String.
VideoStabilizationMode deserializeVideoStabilizationMode(String str) {
  switch (str) {
    case 'off':
      return VideoStabilizationMode.off;
    case 'on':
      return VideoStabilizationMode.on;
    case 'standard':
      return VideoStabilizationMode.standard;
    case 'cinematic':
      return VideoStabilizationMode.cinematic;
    case 'cinematicExtended':
      return VideoStabilizationMode.cinematicExtended;
    default:
      throw ArgumentError('"$str" is not a valid VideoStabilizationMode value');
  }
}
