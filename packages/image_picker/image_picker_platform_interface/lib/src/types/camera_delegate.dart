// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:cross_file/cross_file.dart';
import 'package:flutter/foundation.dart' show immutable;

import 'camera_device.dart';

/// Options for [ImagePickerCameraDelegate] methods.
///
/// New options may be added in the future.
@immutable
class ImagePickerCameraDelegateOptions {
  /// Creates a new set of options for taking an image or video.
  const ImagePickerCameraDelegateOptions({
    this.preferredCameraDevice = CameraDevice.rear,
    this.maxVideoDuration,
  });

  /// The camera device to default to, if available.
  ///
  /// Defaults to [CameraDevice.rear].
  final CameraDevice preferredCameraDevice;

  /// The maximum duration to allow when recording a video.
  ///
  /// Defaults to null, meaning no maximum duration.
  final Duration? maxVideoDuration;
}

/// A delegate for `ImagePickerPlatform` implementations that do not provide
/// a camera implementation, or that have a default but allow substituting an
/// alternate implementation.
abstract class ImagePickerCameraDelegate {
  /// Takes a photo with the given [options] and returns an [XFile] to the
  /// resulting image file.
  ///
  /// Returns null if the photo could not be taken, or the user cancelled.
  Future<XFile?> takePhoto({
    ImagePickerCameraDelegateOptions options =
        const ImagePickerCameraDelegateOptions(),
  });

  /// Records a video with the given [options] and returns an [XFile] to the
  /// resulting video file.
  ///
  /// Returns null if the video could not be recorded, or the user cancelled.
  Future<XFile?> takeVideo({
    ImagePickerCameraDelegateOptions options =
        const ImagePickerCameraDelegateOptions(),
  });
}
