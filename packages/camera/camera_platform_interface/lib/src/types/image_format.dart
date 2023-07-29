// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// The format in which images should be returned from the camera.
/// Will works only on iOS and only iOS 11+.
enum ImageFormat {
  /// The default format for the device.
  jpeg,

  /// The efficient format for iOS devices.
  heic,
}

/// Returns the image format as a String.
String serializeImageFormat(ImageFormat imageFormat) {
  switch (imageFormat) {
    case ImageFormat.jpeg:
      return 'jpeg';
    case ImageFormat.heic:
      return 'heic';
  }
}

/// Returns the image format as a String.
ImageFormat deserializeImageFormat(String str) {
  switch (str) {
    case 'jpeg':
      return ImageFormat.jpeg;
    case 'heic':
      return ImageFormat.heic;
    default:
      throw ArgumentError('"$str" is not a valid image format.');
  }
}
