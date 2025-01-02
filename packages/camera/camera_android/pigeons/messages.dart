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

/// Pigeon equivalent of [Point].
class PlatformPoint {
  PlatformPoint({required this.x, required this.y});

  final double x;
  final double y;
}

/// Pigeon equivalent of [ResolutionPreset].
enum PlatformResolutionPreset {
  low,
  medium,
  high,
  veryHigh,
  ultraHigh,
  max,
}

/// Pigeon equivalent of [MediaSettings].
class PlatformMediaSettings {
  PlatformMediaSettings(
      {required this.resolutionPreset,
      required this.enableAudio,
      this.fps,
      this.videoBitrate,
      this.audioBitrate});
  final PlatformResolutionPreset resolutionPreset;
  final int? fps;
  final int? videoBitrate;
  final int? audioBitrate;
  final bool enableAudio;
}

/// Pigeon equivalent of [ImageFormatGroup].
enum PlatformImageFormatGroup {
  /// The default for Android.
  yuv420,
  jpeg,
  nv21,
}

/// Pigeon equivalent of [FlashMode].
enum PlatformFlashMode {
  off,
  auto,
  always,
  torch,
}

/// Handles calls from Dart to the native side.
@HostApi()
abstract class CameraApi {
  /// Returns the list of available cameras.
  List<PlatformCameraDescription> getAvailableCameras();

  /// Creates a new camera with the given name and settings and returns its ID.
  @async
  int create(String cameraName, PlatformMediaSettings mediaSettings);

  /// Initializes the camera with the given ID for the given image format.
  void initialize(PlatformImageFormatGroup imageFormat);

  /// Disposes of the camera with the given ID.
  void dispose();

  /// Locks the camera with the given ID to the given orientation.
  void lockCaptureOrientation(PlatformDeviceOrientation orientation);

  /// Unlocks the orientation for the camera with the given ID.
  void unlockCaptureOrientation();

  /// Takes a picture on the camera with the given ID and returns a path to the
  /// resulting file.
  @async
  String takePicture();

  /// Starts recording a video on the camera with the given ID.
  void startVideoRecording(bool enableStream);

  /// Ends video recording on the camera with the given ID and returns the path
  /// to the resulting file.
  String stopVideoRecording();

  /// Pauses video recording on the camera with the given ID.
  void pauseVideoRecording();

  /// Resumes previously paused video recording on the camera with the given ID.
  void resumeVideoRecording();

  /// Begins streaming frames from the camera.
  void startImageStream();

  /// Stops streaming frames from the camera.
  void stopImageStream();

  /// Sets the flash mode of the camera with the given ID.
  @async
  void setFlashMode(PlatformFlashMode flashMode);

  /// Sets the exposure mode of the camera with the given ID.
  @async
  void setExposureMode(PlatformExposureMode exposureMode);

  /// Sets the exposure point of the camera with the given ID.
  ///
  /// A null value resets to the default exposure point.
  @async
  void setExposurePoint(PlatformPoint? point);

  /// Returns the minimum exposure offset of the camera with the given ID.
  double getMinExposureOffset();

  /// Returns the maximum exposure offset of the camera with the given ID.
  double getMaxExposureOffset();

  /// Returns the exposure step size of the camera with the given ID.
  double getExposureOffsetStepSize();

  /// Sets the exposure offset of the camera with the given ID and returns the
  /// actual exposure offset.
  @async
  double setExposureOffset(double offset);

  /// Sets the focus mode of the camera with the given ID.
  void setFocusMode(PlatformFocusMode focusMode);

  /// Sets the focus point of the camera with the given ID.
  ///
  /// A null value resets to the default focus point.
  @async
  void setFocusPoint(PlatformPoint? point);

  /// Returns the maximum zoom level of the camera with the given ID.
  double getMaxZoomLevel();

  /// Returns the minimum zoom level of the camera with the given ID.
  double getMinZoomLevel();

  /// Sets the zoom level of the camera with the given ID.
  @async
  void setZoomLevel(double zoom);

  /// Pauses streaming of preview frames.
  void pausePreview();

  /// Resumes previously paused streaming of preview frames.
  void resumePreview();

  /// Changes the camera while recording video.
  ///
  /// This should be called only while video recording is active.
  void setDescriptionWhileRecording(String description);
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
