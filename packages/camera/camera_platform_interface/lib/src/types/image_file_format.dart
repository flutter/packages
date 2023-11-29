// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// The format in which images should be returned from the camera.
enum ImageFileFormat {
  /// It will return the image in JPEG format.
  ///
  /// Is the widely used format for images.
  jpeg,

  /// It will return the image in HEIF format.
  ///
  /// HEIF is a file format name that refers to High Efficiency Image Format (HEIF).
  /// Will works only iOS 11+.
  heif,
}
