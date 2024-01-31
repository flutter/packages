// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// Affect the quality of video recording and image capture:
///
/// If a preset is not available on the camera being used, a preset of lower
/// quality will be selected automatically.
///
/// For the `camera_android_camerax` platform implementation of the plugin,
/// these are treated as target resolutions and are not guaranteed. If
/// unavailable, a fallback resolution of the next highest quality will be
/// targeted.
/// See https://developer.android.com/media/camera/camerax/configuration#specify-resolution.
enum ResolutionPreset {
  /// 352x288 on iOS, 240p (320x240) on Android and Web
  low,

  /// 480p (640x480 on iOS, 720x480 on Android and Web)
  medium,

  /// 720p (1280x720)
  high,

  /// 1080p (1920x1080)
  veryHigh,

  /// 2160p (3840x2160 on Android and iOS, 4096x2160 on Web)
  ultraHigh,

  /// The highest resolution available.
  max,
}
