// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// Video quality setting for video recording/picking.
///
/// This enum corresponds to `UIImagePickerControllerQualityType` on iOS.
enum VideoQuality {
  /// Low quality video.
  ///
  /// Corresponds to `UIImagePickerControllerQualityTypeLow` on iOS.
  low,

  /// Medium quality video.
  ///
  /// Corresponds to `UIImagePickerControllerQualityTypeMedium` on iOS.
  medium,

  /// High quality video.
  ///
  /// Corresponds to `UIImagePickerControllerQualityTypeHigh` on iOS.
  /// This is the default quality setting.
  high,
}
