// Copyright 2013 The Flutter Authors. All rights reserved.
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

/// Capture device types used on Apple Device. Mirror of AVCaptureDevice.DeviceType:
/// https://developer.apple.com/documentation/avfoundation/avcapturedevice/devicetype
enum AppleCaptureDeviceType {
  /// A built-in wide-angle camera device type.
  builtInWideAngleCamera,

  /// A built-in camera device type with a shorter focal length than a wide-angle camera.
  builtInUltraWideCamera,

  /// A built-in camera device type with a longer focal length than a wide-angle camera.
  builtInTelephotoCamera,

  /// A built-in camera device type that consists of a wide-angle and telephoto camera.
  builtInDualCamera,

  /// A built-in camera device type that consists of two cameras of fixed focal length, one ultrawide angle and one wide angle.
  builtInDualWideCamera,

  /// A built-in camera device type that consists of three cameras of fixed focal length, one ultrawide angle, one wide angle, and one telephoto.
  builtInTripleCamera,

  /// A Continuity Camera device type.
  continuityCamera,

  /// A microphone device type.
  microphone,

  /// An external device type.
  external,

  /// A virtual overhead camera that captures a user’s desk.
  deskViewCamera,

  /// A device that consists of two cameras, one LiDAR and one YUV.
  builtInLiDARDepthCamera,

  /// A device that consists of two cameras, one Infrared and one YUV.
  builtInTrueDepthCamera,
}

/// Properties of a camera device.
@immutable
class CameraDescription {
  /// Creates a new camera description with the given properties.
  const CameraDescription({
    required this.name,
    required this.lensDirection,
    required this.sensorOrientation,
    this.appleCaptureDeviceType,
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

  /// The type of the capture device on Apple devices.
  final AppleCaptureDeviceType? appleCaptureDeviceType;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CameraDescription &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          lensDirection == other.lensDirection;

  @override
  int get hashCode => Object.hash(name, lensDirection);

  @override
  String toString() {
    return '${objectRuntimeType(this, 'CameraDescription')}('
        '$name, $lensDirection, $sensorOrientation, $appleCaptureDeviceType)';
  }
}
