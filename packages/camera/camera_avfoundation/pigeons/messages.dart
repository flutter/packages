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

// Pigeon version of ExposureMode.
enum PlatformExposureMode {
  auto,
  locked,
}

// Pigeon version of FocusMode.
enum PlatformFocusMode {
  auto,
  locked,
}

// Pigeon version of the subset of ImageFormatGroup supported on iOS.
enum PlatformImageFormatGroup {
  bgra8888,
  yuv420,
}

// Pigeon version of ResolutionPreset.
enum PlatformResolutionPreset {
  low,
  medium,
  high,
  veryHigh,
  ultraHigh,
  max,
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

// Pigeon version of the data needed for a CameraInitializedEvent.
class PlatformCameraState {
  PlatformCameraState({
    required this.previewSize,
    required this.exposureMode,
    required this.focusMode,
    required this.exposurePointSupported,
    required this.focusPointSupported,
  });

  /// The size of the preview, in pixels.
  final PlatformSize previewSize;

  /// The default exposure mode
  final PlatformExposureMode exposureMode;

  /// The default focus mode
  final PlatformFocusMode focusMode;

  /// Whether setting exposure points is supported.
  final bool exposurePointSupported;

  /// Whether setting focus points is supported.
  final bool focusPointSupported;
}

// Pigeon version of to MediaSettings.
class PlatformMediaSettings {
  PlatformMediaSettings({
    required this.resolutionPreset,
    required this.framesPerSecond,
    required this.videoBitrate,
    required this.audioBitrate,
    required this.enableAudio,
  });

  final PlatformResolutionPreset resolutionPreset;
  final int? framesPerSecond;
  final int? videoBitrate;
  final int? audioBitrate;
  final bool enableAudio;
}

// Pigeon equivalent of CGSize.
class PlatformSize {
  PlatformSize({required this.width, required this.height});

  final double width;
  final double height;
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

  /// Create a new camera with the given settings, and returns its ID.
  @async
  @ObjCSelector('createCameraWithName:settings:')
  int create(String cameraName, PlatformMediaSettings settings);

  /// Initializes the camera with the given ID.
  @async
  @ObjCSelector('initializeCamera:withImageFormat:')
  void initialize(int cameraId, PlatformImageFormatGroup imageFormat);
}

/// Handler for native callbacks that are not tied to a specific camera ID.
@FlutterApi()
abstract class CameraGlobalEventApi {
  /// Called when the device's physical orientation changes.
  void deviceOrientationChanged(PlatformDeviceOrientation orientation);
}

/// Handler for native callbacks that are tied to a specific camera ID.
///
/// This is intended to be initialized with the camera ID as a suffix.
@FlutterApi()
abstract class CameraEventApi {
  /// Called when the camera is inialitized for use.
  @ObjCSelector('initializedWithState:')
  void initialized(PlatformCameraState initialState);

  /// Called when an error occurs in the camera.
  ///
  /// This should be used for errors that occur outside of the context of
  /// handling a specific HostApi call, such as during streaming.
  @ObjCSelector('reportError:')
  void error(String message);
}
