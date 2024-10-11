// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(PigeonOptions(
  dartOut: 'lib/src/messages.g.dart',
  javaOptions: JavaOptions(package: 'io.flutter.plugins.camera'),
  javaOut: 'android/src/main/java/io/flutter/plugins/camera/Messages.java',
  copyrightHeader: 'pigeons/copyright.txt',
))

/// Pigeon equivalent of [CameraLensDirection].
enum PlatformCameraLensDirection {
  front,
  back,
  external,
}

/// Pigeon equivalent of [CameraDescription].
class PlatformCameraDescription {
  PlatformCameraDescription(
      {required this.name,
      required this.lensDirection,
      required this.sensorOrientation});
  final String name;
  final PlatformCameraLensDirection lensDirection;
  final int sensorOrientation;
}

/// Pigeon equivalent of [DeviceOrientation].
enum PlatformDeviceOrientation {
  portraitUp,
  portraitDown,
  landscapeLeft,
  landscapeRight,
}

/// Pigeon equivalent of [ExposureMode].
enum PlatformExposureMode {
  auto,
  locked,
}

/// Pigeon equivalent of [FocusMode].
enum PlatformFocusMode {
  auto,
  locked,
}

/// Data needed for [CameraInitializedEvent].
class PlatformCameraState {
  PlatformCameraState(
      {required this.previewSize,
      required this.exposureMode,
      required this.focusMode,
      required this.exposurePointSupported,
      required this.focusPointSupported});
  final PlatformSize previewSize;
  final PlatformExposureMode exposureMode;
  final PlatformFocusMode focusMode;
  final bool exposurePointSupported;
  final bool focusPointSupported;
}

/// Pigeon equivalent of [Size].
class PlatformSize {
  PlatformSize({required this.width, required this.height});
  final double width;
  final double height;
}

/// Handles calls from Dart to the native side.
@HostApi()
abstract class CameraApi {
  /// Returns the list of available cameras.
  List<PlatformCameraDescription> getAvailableCameras();
}

/// Handles calls from native side to Dart that are not camera-specific.
@FlutterApi()
abstract class CameraGlobalEventApi {
  /// Called when the device's physical orientation changes.
  void deviceOrientationChanged(PlatformDeviceOrientation orientation);
}

/// Handles device-specific calls from native side to Dart.
@FlutterApi()
abstract class CameraEventApi {
  /// Called when the camera is initialized.
  void initialized(PlatformCameraState initialState);

  /// Called when an error occurs in the camera.
  void error(String message);

  /// Called when the camera closes.
  void closed();
}
