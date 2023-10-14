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
