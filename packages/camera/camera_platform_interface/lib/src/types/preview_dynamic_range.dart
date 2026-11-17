// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// The dynamic range of a camera session, which determines whether its preview
/// is shown in HDR.
enum PreviewDynamicRange {
  /// Standard dynamic range (8-bit).
  sdr,

  /// High dynamic range using 10-bit Hybrid Log-Gamma (HLG).
  ///
  /// On a display that supports HDR, the preview is shown brighter than SDR
  /// content where the scene is bright, as in the system camera app.
  hlg10,
}
