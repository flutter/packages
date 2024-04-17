// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(PigeonOptions(
  dartOut: 'lib/src/messages.g.dart',
  objcHeaderOut: 'ios/Classes/messages.g.h',
  objcSourceOut: 'ios/Classes/messages.g.m',
  objcOptions: ObjcOptions(prefix: 'FCP'),
  copyrightHeader: 'pigeons/copyright.txt',
))

// Pigeon version of CameraLensDirection.
enum PlatformCameraLensDirection {
  /// Front facing camera (a user looking at the screen is seen by the camera).
  front,

  /// Back facing camera (a user looking at the screen is not seen by the camera).
  back,

  /// External camera which may not be mounted to the device.
  external,
}

// Pigeon version of DeviceOrientation.
enum PlatformDeviceOrientation {
  portraitUp,
  landscapeLeft,
  portraitDown,
  landscapeRight,
}

// Pigeon version of CameraDescription.
class PlatformCameraDescription {
  PlatformCameraDescription({
    required this.name,
    required this.lensDirection,
  });

  /// The name of the camera device.
  final String name;

  /// The direction the camera is facing.
  final PlatformCameraLensDirection lensDirection;
}

@HostApi()
abstract class CameraApi {
  /// Returns the list of available cameras.
  // TODO(stuartmorgan): Make the generic type non-nullable once supported.
  // https://github.com/flutter/flutter/issues/97848
  // The consuming code treats it as non-nullable.
  @async
  @ObjCSelector('availableCamerasWithCompletion')
  List<PlatformCameraDescription?> getAvailableCameras();
}

/// Handler for native callbacks that are not tied to a specific camera ID.
@FlutterApi()
abstract class CameraGlobalEventApi {
  /// Called when the device's physical orientation changes.
  void deviceOrientationChanged(PlatformDeviceOrientation orientation);
}
