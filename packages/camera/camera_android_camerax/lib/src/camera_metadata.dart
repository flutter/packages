// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:meta/meta.dart' show immutable;

/// Base class for camera controls and information.
///
/// See https://developer.android.com/reference/android/hardware/camera2/CameraMetadata.
@immutable
class CameraMetadata {
  /// Constant that specifies a camera device does not have enough to quality as
  /// a [infoSupportedHardwareLevelFull] level device or better.
  ///
  /// See https://developer.android.com/reference/android/hardware/camera2/CameraMetadata#INFO_SUPPORTED_HARDWARE_LEVEL_LIMITED.
  static const int infoSupportedHardwareLevelLimited = 0;

  /// Constant that specifies a camera device is capable of supporting advanced
  /// imaging applications.
  ///
  /// See https://developer.android.com/reference/android/hardware/camera2/CameraMetadata#INFO_SUPPORTED_HARDWARE_LEVEL_FULL.
  static const int infoSupportedHardwareLevelFull = 1;

  /// Constant that specifies a camera device is running in backward
  /// compatibility mode.
  ///
  /// See https://developer.android.com/reference/android/hardware/camera2/CameraMetadata#INFO_SUPPORTED_HARDWARE_LEVEL_LEGACY.
  static const int infoSupportedHardwareLevelLegacy = 2;

  /// Constant that specifies a camera device is capable of YUV reprocessing and
  /// RAW data capture in addition to [infoSupportedHardwareLevelFull] level
  /// capabilities.
  ///
  /// See https://developer.android.com/reference/android/hardware/camera2/CameraMetadata#INFO_SUPPORTED_HARDWARE_LEVEL_3.
  static const int infoSupportedHardwareLevel3 = 3;

  /// Constant taht specifies a camera device is backed by an external camera
  /// connected to this Android device.
  ///
  /// See https://developer.android.com/reference/android/hardware/camera2/CameraMetadata#INFO_SUPPORTED_HARDWARE_LEVEL_EXTERNAL.
  static const int infoSupportedHardwareLevelExternal = 4;
}
