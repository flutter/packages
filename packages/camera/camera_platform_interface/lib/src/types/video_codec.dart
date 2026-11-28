// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// The codec used to encode recorded video.
enum VideoCodec {
  /// H.264 (AVC), which has the widest playback compatibility.
  h264,

  /// H.265 (HEVC), which gives smaller files at similar quality but needs a
  /// newer decoder to play back.
  hevc,
}
