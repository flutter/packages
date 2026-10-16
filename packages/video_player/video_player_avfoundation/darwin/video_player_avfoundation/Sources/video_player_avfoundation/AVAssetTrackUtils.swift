// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import AVFoundation

/// Returns a standardized transform according to the orientation of a track with the given
/// information.
///
/// Note: https://stackoverflow.com/questions/64161544
/// `AVAssetTrack.preferredTransform` can have wrong `tx` and `ty`.
func standardizedTrackTransform(transform t: CGAffineTransform, size: CGSize)
  -> CGAffineTransform
{
  // Each case of control flows corresponds to a specific
  // `UIImageOrientation`, with 8 cases in total.
  var st = t
  switch (t.a, t.b, t.c, t.d) {
  case (1, 0, 0, 1):
    // UIImageOrientationUp
    st.tx = 0
    st.ty = 0
  case (-1, 0, 0, -1):
    // UIImageOrientationDown
    st.tx = size.width
    st.ty = size.height
  case (0, -1, 1, 0):
    // UIImageOrientationLeft
    st.tx = 0
    st.ty = size.width
  case (0, 1, -1, 0):
    // UIImageOrientationRight
    st.tx = size.height
    st.ty = 0
  case (-1, 0, 0, 1):
    // UIImageOrientationUpMirrored
    st.tx = size.width
    st.ty = 0
  case (1, 0, 0, -1):
    // UIImageOrientationDownMirrored
    st.tx = 0
    st.ty = size.height
  case (0, -1, -1, 0):
    // UIImageOrientationLeftMirrored
    st.tx = size.height
    st.ty = size.width
  case (0, 1, 1, 0):
    // UIImageOrientationRightMirrored
    st.tx = 0
    st.ty = 0
  default:
    break
  }
  return st
}

func frameDurationIsValid(_ duration: CMTime) -> Bool {
  return duration.isNumeric && duration > CMTime.zero
}
