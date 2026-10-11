// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import AVFoundation

/// Returns a standardized transform according to the orientation of a track with the given
/// information.
///
/// Note: https://stackoverflow.com/questions/64161544
/// `AVAssetTrack.preferredTransform` can have wrong `tx` and `ty`.
func getStandardizedTrackTransform(transform t: CGAffineTransform, size: CGSize)
  -> CGAffineTransform
{
  // Each case of control flows corresponds to a specific
  // `UIImageOrientation`, with 8 cases in total.
  var st = t
  if t.a == 1 && t.b == 0 && t.c == 0 && t.d == 1 {
    // UIImageOrientationUp
    st.tx = 0
    st.ty = 0
  } else if t.a == -1 && t.b == 0 && t.c == 0 && t.d == -1 {
    // UIImageOrientationDown
    st.tx = size.width
    st.ty = size.height
  } else if t.a == 0 && t.b == -1 && t.c == 1 && t.d == 0 {
    // UIImageOrientationLeft
    st.tx = 0
    st.ty = size.width
  } else if t.a == 0 && t.b == 1 && t.c == -1 && t.d == 0 {
    // UIImageOrientationRight
    st.tx = size.height
    st.ty = 0
  } else if t.a == -1 && t.b == 0 && t.c == 0 && t.d == 1 {
    // UIImageOrientationUpMirrored
    st.tx = size.width
    st.ty = 0
  } else if t.a == 1 && t.b == 0 && t.c == 0 && t.d == -1 {
    // UIImageOrientationDownMirrored
    st.tx = 0
    st.ty = size.height
  } else if t.a == 0 && t.b == -1 && t.c == -1 && t.d == 0 {
    // UIImageOrientationLeftMirrored
    st.tx = size.height
    st.ty = size.width
  } else if t.a == 0 && t.b == 1 && t.c == 1 && t.d == 0 {
    // UIImageOrientationRightMirrored
    st.tx = 0
    st.ty = 0
  }
  return st
}
