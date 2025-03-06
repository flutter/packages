// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(PigeonOptions(
  dartOut: 'lib/src/messages.g.dart',
  objcHeaderOut:
      'ios/camera_avfoundation/Sources/camera_avfoundation/include/camera_avfoundation/messages.g.h',
  objcSourceOut:
      'ios/camera_avfoundation/Sources/camera_avfoundation/messages.g.m',
  objcOptions: ObjcOptions(
    prefix: 'FCP',
    headerIncludePath: './include/camera_avfoundation/messages.g.h',
  ),
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

/// Pigeon version of ImageFileFormat.
enum PlatformImageFileFormat {
  jpeg,
  heif,
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

// Pigeon equivalent of CGPoint.
class PlatformPoint {
  PlatformPoint({required this.x, required this.y});

  final double x;
  final double y;
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
  List<PlatformCameraDescription> getAvailableCameras();

  /// Create a new camera with the given settings, and returns its ID.
  @async
  @ObjCSelector('createCameraWithName:settings:')
  int create(String cameraName, PlatformMediaSettings settings);

  /// Initializes the camera with the given ID.
  @async
  @ObjCSelector('initializeCamera:withImageFormat:')
  void initialize(int cameraId, PlatformImageFormatGroup imageFormat);

  /// Begins streaming frames from the camera.
  @async
  void startImageStream();

  /// Stops streaming frames from the camera.
  @async
  void stopImageStream();

  /// Called by the Dart side of the plugin when it has received the last image
  /// frame sent.
  ///
  /// This is used to throttle sending frames across the channel.
  @async
  void receivedImageStreamData();

  /// Indicates that the given camera is no longer being used on the Dart side,
  /// and any associated resources can be cleaned up.
  @async
  @ObjCSelector('disposeCamera:')
  void dispose(int cameraId);

  /// Locks the camera capture to the current device orientation.
  @async
  @ObjCSelector('lockCaptureOrientation:')
  void lockCaptureOrientation(PlatformDeviceOrientation orientation);

  /// Unlocks camera capture orientation, allowing it to automatically adapt to
  /// device orientation.
  @async
  void unlockCaptureOrientation();

  /// Takes a picture with the current settings, and returns the path to the
  /// resulting file.
  @async
  String takePicture();

  /// Does any preprocessing necessary before beginning to record video.
  @async
  void prepareForVideoRecording();

  /// Begins recording video, optionally enabling streaming to Dart at the same
  /// time.
  @async
  @ObjCSelector('startVideoRecordingWithStreaming:')
  void startVideoRecording(bool enableStream);

  /// Stops recording video, and results the path to the resulting file.
  @async
  String stopVideoRecording();

  /// Pauses video recording.
  @async
  void pauseVideoRecording();

  /// Resumes a previously paused video recording.
  @async
  void resumeVideoRecording();

  /// Switches the camera to the given flash mode.
  @async
  @ObjCSelector('setFlashMode:')
  void setFlashMode(PlatformFlashMode mode);

  /// Switches the camera to the given exposure mode.
  @async
  @ObjCSelector('setExposureMode:')
  void setExposureMode(PlatformExposureMode mode);

  /// Anchors auto-exposure to the given point in (0,1) coordinate space.
  ///
  /// A null value resets to the default exposure point.
  @async
  @ObjCSelector('setExposurePoint:')
  void setExposurePoint(PlatformPoint? point);

  /// Returns the minimum exposure offset supported by the camera.
  @async
  @ObjCSelector('getMinimumExposureOffset')
  double getMinExposureOffset();

  /// Returns the maximum exposure offset supported by the camera.
  @async
  @ObjCSelector('getMaximumExposureOffset')
  double getMaxExposureOffset();

  /// Sets the exposure offset manually to the given value.
  @async
  @ObjCSelector('setExposureOffset:')
  void setExposureOffset(double offset);

  /// Switches the camera to the given focus mode.
  @async
  @ObjCSelector('setFocusMode:')
  void setFocusMode(PlatformFocusMode mode);

  /// Anchors auto-focus to the given point in (0,1) coordinate space.
  ///
  /// A null value resets to the default focus point.
  @async
  @ObjCSelector('setFocusPoint:')
  void setFocusPoint(PlatformPoint? point);

  /// Returns the minimum zoom level supported by the camera.
  @async
  @ObjCSelector('getMinimumZoomLevel')
  double getMinZoomLevel();

  /// Returns the maximum zoom level supported by the camera.
  @async
  @ObjCSelector('getMaximumZoomLevel')
  double getMaxZoomLevel();

  /// Sets the zoom factor.
  @async
  @ObjCSelector('setZoomLevel:')
  void setZoomLevel(double zoom);

  /// Pauses streaming of preview frames.
  @async
  void pausePreview();

  /// Resumes a previously paused preview stream.
  @async
  void resumePreview();

  /// Changes the camera used while recording video.
  ///
  /// This should only be called while video recording is active.
  @async
  void updateDescriptionWhileRecording(String cameraName);

  /// Sets the file format used for taking pictures.
  @async
  @ObjCSelector('setImageFileFormat:')
  void setImageFileFormat(PlatformImageFileFormat format);
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
