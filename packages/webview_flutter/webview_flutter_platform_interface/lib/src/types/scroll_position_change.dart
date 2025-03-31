// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// Defines the parameters of the scroll position change callback.
class ScrollPositionChange {
  /// Creates a [ScrollPositionChange].
  const ScrollPositionChange(this.x, this.y);

  /// The value of the horizontal offset with the origin being at the leftmost
  /// of the `WebView`.
  final double x;

  /// The value of the vertical offset with the origin being at the topmost of
  /// the `WebView`.
  final double y;
}
