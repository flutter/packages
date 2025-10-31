// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// The possible video stabilization modes that can be capturing video.
enum VideoStabilizationMode {
  /// Video stabilization is disabled.
  off,

  /// Least stabilized video stabilization mode with the least latency.
  level1,

  /// More stabilized video with more latency.
  level2,

  /// Most stabilized video with the most latency.
  level3,
}
