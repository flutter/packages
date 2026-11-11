// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart' show immutable;

import 'camera_device.dart';
import 'video_options.dart';

/// Specifies options for picking a single video from the device's camera or
/// gallery.
///
/// This class inheritance is a byproduct of the api changing over time.
/// It exists solely to avoid breaking changes.
@immutable
base class VideoPickerOptions {
  /// Creates an instance with the given [maxDuration].
  const VideoPickerOptions({
    this.videoOptions = const VideoOptions(),
    this.preferredCameraDevice = CameraDevice.rear,
  });

  /// The video-specific options for picking.
  final VideoOptions videoOptions;

  /// Used to specify the camera to use when the `source` is [ImageSource.camera].
  ///
  /// Ignored if the source is not [ImageSource.camera], or the chosen camera is not
  /// supported on the device. Defaults to [CameraDevice.rear].
  final CameraDevice preferredCameraDevice;
}
