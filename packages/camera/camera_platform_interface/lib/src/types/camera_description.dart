// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';

/// The direction the camera is facing.
enum CameraLensDirection {
  /// Front facing camera (a user looking at the screen is seen by the camera).
  front,

  /// Back facing camera (a user looking at the screen is not seen by the camera).
  back,

  /// External camera which may not be mounted to the device.
  external,
}

/// Represents various built-in camera lens types available on a device.
///
/// Each lens type offers different focal lengths and capabilities for capturing images.
enum CameraLensType {
  /// A built-in wide-angle camera device type.
  wide,

  /// A built-in camera device type with a longer focal length than a wide-angle camera.
  telephoto,

  /// A built-in camera device type with a shorter focal length than a wide-angle camera.
  ultraWide,

  /// Unknown camera device type.
  unknown,
}

/// Properties of a camera device.
@immutable
class CameraDescription {
  /// Creates a new camera description with the given properties.
  const CameraDescription({
    required this.name,
    required this.lensDirection,
    required this.sensorOrientation,
    this.lensType = CameraLensType.unknown,
  });

  /// The name of the camera device.
  final String name;

  /// The direction the camera is facing.
  final CameraLensDirection lensDirection;

  /// Clockwise angle through which the output image needs to be rotated to be upright on the device screen in its native orientation.
  ///
  /// **Range of valid values:**
  /// 0, 90, 180, 270
  ///
  /// On Android, also defines the direction of rolling shutter readout, which
  /// is from top to bottom in the sensor's coordinate system.
  final int sensorOrientation;

  /// The type of lens the camera has.
  final CameraLensType lensType;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CameraDescription &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          lensDirection == other.lensDirection &&
          lensType == other.lensType;

  @override
  int get hashCode => Object.hash(name, lensDirection, lensType);

  @override
  String toString() {
    return '${objectRuntimeType(this, 'CameraDescription')}('
        '$name, $lensDirection, $sensorOrientation, $lensType)';
  }
}
