// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'types.dart';

/// Specifies options for picking a single image from the device's camera or gallery.
///
/// This class inheritance is a byproduct of the api changing over time.
/// It exists solely to avoid breaking changes.
class ImagePickerOptions extends ImageOptions {
  /// Creates an instance with the given [maxHeight], [maxWidth], [imageQuality],
  /// [referredCameraDevice] and [requestFullMetadata].
  const ImagePickerOptions({
    super.maxHeight,
    super.maxWidth,
    super.imageQuality,
    super.requestFullMetadata,
    this.preferredCameraDevice = CameraDevice.rear,
  }) : super();

  /// Creates an instance with the given [maxHeight], [maxWidth], [imageQuality],
  /// [referredCameraDevice] and [requestFullMetadata].
  ImagePickerOptions.createAndValidate({
    super.maxHeight,
    super.maxWidth,
    super.imageQuality,
    super.requestFullMetadata,
    this.preferredCameraDevice = CameraDevice.rear,
  }) : super.createAndValidate();

  /// Used to specify the camera to use when the `source` is [ImageSource.camera].
  ///
  /// Ignored if the source is not [ImageSource.camera], or the chosen camera is not
  /// supported on the device. Defaults to [CameraDevice.rear].
  final CameraDevice preferredCameraDevice;
}

/// Specifies image-specific options for picking.
class ImageOptions {
  /// Creates an instance with the given [maxHeight], [maxWidth], [imageQuality]
  /// and [requestFullMetadata].
  const ImageOptions({
    this.maxHeight,
    this.maxWidth,
    this.imageQuality,
    this.requestFullMetadata = true,
  });

  /// Creates an instance with the given [maxHeight], [maxWidth], [imageQuality]
  /// and [requestFullMetadata]. Throws if options are not valid.
  ImageOptions.createAndValidate({
    this.maxHeight,
    this.maxWidth,
    this.imageQuality,
    this.requestFullMetadata = true,
  }) {
    _validateOptions(
        maxWidth: maxWidth, maxHeight: maxHeight, imageQuality: imageQuality);
  }

  /// The maximum width of the image, in pixels.
  ///
  /// If null, the image will only be resized if [maxHeight] is specified.
  final double? maxWidth;

  /// The maximum height of the image, in pixels.
  ///
  /// If null, the image will only be resized if [maxWidth] is specified.
  final double? maxHeight;

  /// Modifies the quality of the image, ranging from 0-100 where 100 is the
  /// original/max quality.
  ///
  /// Compression is only supported for certain image types such as JPEG. If
  /// compression is not supported for the image that is picked, a warning
  /// message will be logged.
  ///
  /// If null, the image will be returned with the original quality.
  final int? imageQuality;

  /// If true, requests full image metadata, which may require extra permissions
  /// on some platforms, (e.g., NSPhotoLibraryUsageDescription on iOS).
  //
  // Defaults to true.
  final bool requestFullMetadata;

  /// Validates that all values are within required ranges. Throws if not.
  static void _validateOptions(
      {double? maxWidth, final double? maxHeight, int? imageQuality}) {
    if (imageQuality != null && (imageQuality < 0 || imageQuality > 100)) {
      throw ArgumentError.value(
          imageQuality, 'imageQuality', 'must be between 0 and 100');
    }
    if (maxWidth != null && maxWidth < 0) {
      throw ArgumentError.value(maxWidth, 'maxWidth', 'cannot be negative');
    }
    if (maxHeight != null && maxHeight < 0) {
      throw ArgumentError.value(maxHeight, 'maxHeight', 'cannot be negative');
    }
  }
}
