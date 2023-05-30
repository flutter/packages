// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// Defines the parameters of the content offset change callback.
class ContentOffsetChange {
  /// Creates a [ContentOffsetChange].
  const ContentOffsetChange(this.x, this.y);

  /// The value of horizontal offset with the origin begin at the leftmost of the [WebView]
  final int x;

  /// The value of vertical offset with the origin begin at the topmost of the [WebView]
  final int y;
}
