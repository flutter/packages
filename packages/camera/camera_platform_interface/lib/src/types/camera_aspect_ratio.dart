// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// The aspect ratio of the camera output, shared by the preview, photos and
/// recorded video.
///
/// Ratios are given for the landscape sensor orientation; in portrait the
/// output is rotated, for example 3:4 for [ratio4x3].
enum CameraAspectRatio {
  /// 4:3, the full sensor area of most phone cameras.
  ratio4x3,

  /// 16:9.
  ratio16x9,
}
