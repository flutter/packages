// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// Affect the quality of video recording and image capture:
///
/// If a preset is not available on the camera being used a preset of lower quality will be selected automatically.
/// If the [CaptureMode] is [CaptureMode.photo] the selected resolution will be a 4:3 resolution.
/// If the [CaptureMode] is [CaptureMode.video] the selected resolution will generally be a 16:9 resolution.
enum ResolutionPreset {
  /// 352x288 on iOS, 240p (320x240) on Android and Web
  low,

  /// 480p (640x480 on iOS, 720x480 on Android and Web)
  medium,

  /// 720p or 768p (1280x720, 1024x768 or 960x720)
  high,

  /// 1080p (1920x1080 or 1440x1080)
  veryHigh,

  /// 2160p (3840x2160 on Android and iOS, 4096x2160 on Web or 2880x2160)
  ultraHigh,

  /// The highest resolution available. When CaptureMode is video, this is the same as [ultraHigh].
  /// When CaptureMode is photo, this is the maximum resolution of the camera which is typically
  /// a 4:3 resolution.
  max,
}
