// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart' show immutable;

import 'camera_device.dart';
import 'image_options.dart';

/// Specifies options for picking a single image from the device's camera or
/// gallery.
@immutable
base class ImagePickerOptions {
  /// Creates an instance with the given [imageOptions] and
  /// [preferredCameraDevice].
  const ImagePickerOptions({
    this.imageOptions = const ImageOptions(),
    this.preferredCameraDevice = CameraDevice.rear,
  });

  /// The image-specific options for picking.
  final ImageOptions imageOptions;

  /// Used to specify the camera to use when the `source` is [ImageSource.camera].
  ///
  /// Ignored if the source is not [ImageSource.camera], or the chosen camera is not
  /// supported on the device. Defaults to [CameraDevice.rear].
  final CameraDevice preferredCameraDevice;
}
