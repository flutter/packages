// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:cross_file/cross_file.dart';

import 'image_picker_options.dart';
import 'video_picker_options.dart';

/// A delegate for `ImagePickerPlatform` implementations that do not provide
/// a camera implementation, or that have a default but allow substituting an
/// alternate implementation.
abstract base class ImagePickerCameraDelegate {
  /// Takes a photo with the given [options] and returns an [XFile] to the
  /// resulting image file.
  ///
  /// Returns null if the photo could not be taken, or the user cancelled.
  Future<XFile?> takePhoto({ImagePickerOptions options = const ImagePickerOptions()});

  /// Records a video with the given [options] and returns an [XFile] to the
  /// resulting video file.
  ///
  /// Returns null if the video could not be recorded, or the user cancelled.
  Future<XFile?> takeVideo({VideoPickerOptions options = const VideoPickerOptions()});
}
