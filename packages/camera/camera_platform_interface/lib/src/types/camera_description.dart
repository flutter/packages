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

/// The camera's device type in ios
/// IOS only
enum AVCaptureDeviceType {
  /// A built-in wide angle camera device.
  /// These devices are suitable for general purpose use.
  wideAngleCamera(name: 'AVCaptureDeviceTypeBuiltInWideAngleCamera'),

  /// A built-in camera device with a longer focal length than a wide angle camera.
  telephotoCamera(name: 'AVCaptureDeviceTypeBuiltInTelephotoCamera'),

  /// A built-in camera device with a shorter focal length than a wide angle camera.
  ultraWideCamera(name: 'AVCaptureDeviceTypeBuiltInUltraWideCamera'),

  /// A device that consists of two fixed focal length cameras,
  /// one wide and one telephoto.
  dualCamera(name: 'AVCaptureDeviceTypeBuiltInDualCamera'),

  /// A device that consists of two fixed focal length cameras,
  /// one ultra wide and one wide angle.
  dualWideCamera(name: 'AVCaptureDeviceTypeBuiltInDualWideCamera'),

  /// A device that consists of three fixed focal length cameras,
  /// one ultra wide, one wide angle, and one telephoto.
  tripleCamera(name: 'AVCaptureDeviceTypeBuiltInTripleCamera'),

  /// A device that consists of two cameras, one YUV and one Infrared.
  /// The infrared camera provides high quality depth information
  /// that is synchronized and perspective corrected to frames produced by the YUV camera.
  /// While the resolution of the depth data and YUV frames may differ,
  /// their field of view and aspect ratio always match.
  trueDepthCamera(name: 'AVCaptureDeviceTypeBuiltInTrueDepthCamera'),

  /// A device that consists of two cameras, one YUV and one LiDAR.
  /// The LiDAR camera provides high quality, high accuracy depth information by
  /// measuring the round trip of an artificial light signal emitted by a laser.
  /// The depth is synchronized and perspective corrected to frames produced by
  /// the paired YUV camera. While the resolution of the depth data and YUV frames may differ,
  /// their field of view and aspect ratio always match.
  liDARDepthCamera(name: 'AVCaptureDeviceTypeBuiltInLiDARDepthCamera'),

  /// An unknown device type.
  unknown;

  /// AVCaptureDeviceType
  const AVCaptureDeviceType({this.name});

  /// The device type string from IOS
  final String? name;

  /// Parse device type from string
  static AVCaptureDeviceType parseFromString(String? deviceType) {
    return AVCaptureDeviceType.values.singleWhere(
      (AVCaptureDeviceType element) => element.name == deviceType,
      orElse: () => AVCaptureDeviceType.unknown,
    );
  }
}

/// Properties of a camera device.
@immutable
class CameraDescription {
  /// Creates a new camera description with the given properties.
  const CameraDescription({
    required this.name,
    required this.lensDirection,
    required this.sensorOrientation,
    this.cameraType = AVCaptureDeviceType.unknown,
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

  /// Camera type,IOS only
  /// TrueDepthCamera  DualCamera  TripleCamera  LiDARDepthCamera  DeskViewCamera DualWideCamera ExternalUnknown WideAngleCamera TelephotoCamera UltraWideCamera
  final AVCaptureDeviceType cameraType;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CameraDescription &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          lensDirection == other.lensDirection &&
          cameraType == other.cameraType;

  @override
  int get hashCode => Object.hash(name, lensDirection, cameraType);

  @override
  String toString() {
    return '${objectRuntimeType(this, 'CameraDescription')}('
        '$name, $lensDirection, $sensorOrientation, $cameraType)';
  }
}
