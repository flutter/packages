// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// The format in which images should be returned from the camera.
enum ImageFileFormat {
  /// The JPEG format.
  jpeg,

  /// The HEIF format.
  ///
  /// HEIF is a file format name that refers to High Efficiency Image Format
  /// (HEIF). For iOS, this is only supported on versions 11+.
  heif,
}
