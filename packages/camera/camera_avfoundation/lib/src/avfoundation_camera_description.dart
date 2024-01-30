import 'package:camera_platform_interface/camera_platform_interface.dart';
import 'package:flutter/foundation.dart';

/// Capture device types used on Apple Device. Mirror of AVCaptureDevice.DeviceType:
/// https://developer.apple.com/documentation/avfoundation/avcapturedevice/devicetype
enum AVCaptureDeviceType {
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

  /// An external device type.
  external,

  /// A device that consists of two cameras, one LiDAR and one YUV.
  builtInLiDARDepthCamera,

  /// A device that consists of two cameras, one Infrared and one YUV.
  builtInTrueDepthCamera,
}

/// Properties of an Apple camera device.
@immutable
class AVCameraDescription extends CameraDescription {
  /// Creates a new camera description with the given properties.
  const AVCameraDescription({
    required super.name,
    required super.lensDirection,
    required super.sensorOrientation,
    this.captureDeviceType,
  });

  /// The type of the capture device on Apple devices.
  final AVCaptureDeviceType? captureDeviceType;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AVCameraDescription &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          lensDirection == other.lensDirection &&
          sensorOrientation == other.sensorOrientation &&
          captureDeviceType == other.captureDeviceType;

  @override
  int get hashCode =>
      Object.hash(name, lensDirection, sensorOrientation, captureDeviceType);

  @override
  String toString() {
    return '${objectRuntimeType(this, 'AVCameraDescription')}('
        '$name, $lensDirection, $sensorOrientation, $captureDeviceType)';
  }
}
