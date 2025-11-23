// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// This setting controls how the API handles camera control button on the map.
///
/// See https://developers.google.com/maps/documentation/javascript/reference/control#ControlPosition
/// for more details.
enum WebCameraControlPosition {
  /// Equivalent to BOTTOM_CENTER in both LTR and RTL.
  blockEndInlineCenter,

  /// Equivalent to BOTTOM_LEFT in LTR, or BOTTOM_RIGHT in RTL.
  blockEndInlineStart,

  /// Equivalent to BOTTOM_RIGHT in LTR, or BOTTOM_LEFT in RTL.
  blockEndInlineEnd,

  /// Equivalent to TOP_CENTER in both LTR and RTL.
  blockStartInlineCenter,

  /// Equivalent to TOP_LEFT in LTR, or TOP_RIGHT in RTL.
  blockStartInlineStart,

  /// Equivalent to TOP_RIGHT in LTR, or TOP_LEFT in RTL.
  blockStartInlineEnd,

  /// Elements are positioned in the center of the bottom row.
  ///
  /// Consider using BLOCK_END_INLINE_CENTER instead.
  bottomCenter,

  /// Elements are positioned in the bottom left and flow towards the middle.
  ///
  /// Elements are positioned to the right of the Google logo.
  ///
  /// Consider using BLOCK_END_INLINE_START instead.
  bottomLeft,

  /// Elements are positioned in the bottom right and flow towards the middle.
  ///
  /// Elements are positioned to the left of the copyrights.
  ///
  /// Consider using BLOCK_END_INLINE_END instead.
  bottomRight,

  /// Equivalent to RIGHT_CENTER in LTR, or LEFT_CENTER in RTL.
  inlineEndBlockCenter,

  /// Equivalent to RIGHT_BOTTOM in LTR, or LEFT_BOTTOM in RTL.
  inlineEndBlockEnd,

  /// Equivalent to RIGHT_TOP in LTR, or LEFT_TOP in RTL.
  inlineEndBlockStart,

  /// Equivalent to LEFT_CENTER in LTR, or RIGHT_CENTER in RTL.
  inlineStartBlockCenter,

  /// Equivalent to LEFT_BOTTOM in LTR, or RIGHT_BOTTOM in RTL.
  inlineStartBlockEnd,

  /// Equivalent to LEFT_TOP in LTR, or RIGHT_TOP in RTL.
  inlineStartBlockStart,

  /// Elements are positioned on the left, above bottom-left elements,
  /// and flow upwards.
  ///
  /// Consider using INLINE_START_BLOCK_END instead.
  leftBottom,

  /// Elements are positioned in the center of the left side.
  /// Consider using INLINE_START_BLOCK_CENTER instead.
  leftCenter,

  /// Elements are positioned on the left, below top-left elements,
  /// and flow downwards.
  ///
  /// Consider using INLINE_START_BLOCK_START instead.
  leftTop,

  /// Elements are positioned on the right, above bottom-right elements,
  /// and flow upwards.
  ///
  /// Consider using INLINE_END_BLOCK_END instead.
  rightBottom,

  /// Elements are positioned in the center of the right side.
  ///
  /// Consider using INLINE_END_BLOCK_CENTER instead.
  rightCenter,

  /// Elements are positioned on the right, below top-right elements,
  /// and flow downwards.
  ///
  /// Consider using INLINE_END_BLOCK_START instead.
  rightTop,

  /// Elements are positioned in the center of the top row.
  ///
  /// Consider using BLOCK_START_INLINE_CENTER instead.
  topCenter,

  /// Elements are positioned in the top left and flow towards the middle.
  ///
  /// Consider using BLOCK_START_INLINE_START instead.
  topLeft,

  /// Elements are positioned in the top right and flow towards the middle.
  ///
  /// Consider using BLOCK_START_INLINE_END instead.
  topRight,
}
