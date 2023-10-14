// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// The format in which images should be returned from the camera.
enum ImageExtension {
  /// This is the default value. It will return the image in JPEG format.
  /// Is the widely used format for images.
  jpeg,

  /// It will return the image in HEIC format.
  /// HEIC is a file format name that refers to High Efficiency Image Format (HEIF).
  /// Will works only iOS 11+.
  heic,
}

/// Extension on [ImageExtension] to stringify the enum
extension ImageExtensionName on ImageExtension {
  /// returns a String value for [ImageExtension]
  /// returns 'jpeg' if platform is not supported
  /// or if [ImageExtension] is not supported for the platform
  String name() {
    switch (this) {
      case ImageExtension.jpeg:
        return 'jpeg';
      case ImageExtension.heic:
        return 'heic';
    }
  }
}
