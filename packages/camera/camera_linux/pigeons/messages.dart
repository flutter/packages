// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(PigeonOptions(
  dartOut: 'lib/src/messages.g.dart',
  gobjectHeaderOut: 'linux/messages.g.h',
  gobjectSourceOut: 'linux/messages.g.cc',
  gobjectOptions: GObjectOptions(),
  copyrightHeader: 'pigeons/copyright.txt',
))

// Pigeon equivalent of CGSize.
class PlatformSize {
  PlatformSize({required this.width, required this.height});

  final double width;
  final double height;
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

// Pigeon version of FlashMode.
enum PlatformFlashMode {
  off,
  auto,
  always,
  torch,
}

// Pigeon version of FocusMode.
enum PlatformFocusMode {
  auto,
  locked,
}

// Pigeon version of the subset of ImageFormatGroup supported on iOS.
enum PlatformImageFormatGroup {
  rgb8,
  mono8,
}

enum PlatformResolutionPreset {
  low, // 352x288 on iOS, ~240p on Android and Web
  medium, // ~480p
  high, // ~720p
  veryHigh, // ~1080p
  ultraHigh, // ~2160p
  max, // The highest resolution available.
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

// Pigeon equivalent of CGPoint.
class PlatformPoint {
  PlatformPoint({required this.x, required this.y});

  final double x;
  final double y;
}

@HostApi()
abstract class CameraApi {
  /// Returns the list of available cameras.
  @async
  List<String> getAvailableCamerasNames();

  /// Create a new camera with the given settings, and returns its ID.
  @async
  int create(String cameraName, PlatformResolutionPreset resolutionPreset);

  /// Initializes the camera with the given ID.
  @async
  void initialize(int cameraId, PlatformImageFormatGroup imageFormat);

  /// Get the texture ID for the camera with the given ID.
  @async
  int? getTextureId(int cameraId);

  /// Indicates that the given camera is no longer being used on the Dart side,
  /// and any associated resources can be cleaned up.
  @async
  void dispose(int cameraId);

  /// Takes a picture with the current settings, and returns the path to the
  /// resulting file.
  @async
  void takePicture(int cameraId, String path);

  /// Begins recording video, optionally enabling streaming to Dart at the same
  /// time.
  @async
  void startVideoRecording(int cameraId, String path);

  /// Stops recording video, and results the path to the resulting file.
  @async
  String stopVideoRecording(int cameraId);

  /// Switches the camera to the given exposure mode.
  @async
  void setExposureMode(int cameraId, PlatformExposureMode mode);

  /// Switches the camera to the given focus mode.
  @async
  void setFocusMode(int cameraId, PlatformFocusMode mode);

  //Sets the ImageFormatGroup.
  @async
  void setImageFormatGroup(
      int cameraId, PlatformImageFormatGroup imageFormatGroup);
}

/// Handler for native callbacks that are tied to a specific camera ID.
///
/// This is intended to be initialized with the camera ID as a suffix.
@FlutterApi()
abstract class CameraEventApi {
  /// Called when the camera is inialitized for use.
  void initialized(PlatformCameraState initialState);

  void textureId(int textureId);

  /// Called when an error occurs in the camera.
  ///
  /// This should be used for errors that occur outside of the context of
  /// handling a specific HostApi call, such as during streaming.
  void error(String message);
}
