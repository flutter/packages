// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// The format in which images should be returned from the camera.
/// Will works only on iOS and only iOS 11+.
enum ImageExtension {
  /// The default extension for the current platform.
  jpeg,

  /// The efficient extension for iOS.
  heic,
}

/// Returns the image extension as a String.
String serializeImageExtension(ImageExtension imageExtension) {
  switch (imageExtension) {
    case ImageExtension.jpeg:
      return 'jpeg';
    case ImageExtension.heic:
      return 'heic';
  }
}

/// Returns the image extension as a String.
ImageExtension deserializeImageExtension(String str) {
  switch (str) {
    case 'jpeg':
      return ImageExtension.jpeg;
    case 'heic':
      return ImageExtension.heic;
    default:
      throw ArgumentError('"$str" is not a valid image extension.');
  }
}
