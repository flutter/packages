// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(PigeonOptions(
  dartOut: 'lib/src/messages.g.dart',
  cppOptions: CppOptions(namespace: 'camera_windows'),
  cppHeaderOut: 'windows/messages.g.h',
  cppSourceOut: 'windows/messages.g.cpp',
  copyrightHeader: 'pigeons/copyright.txt',
))

/// Pigeon version of platform interface's ResolutionPreset.
enum PlatformResolutionPreset { low, medium, high, veryHigh, ultraHigh, max }

/// Pigeon version of MediaSettings.
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

/// A representation of a size from the native camera APIs.
class PlatformSize {
  PlatformSize({required this.width, required this.height});

  final double width;
  final double height;
}

@HostApi()
abstract class CameraApi {
  /// Returns the names of all of the available capture devices.
  List<String> getAvailableCameras();

  /// Creates a camera instance for the given device name and settings.
  @async
  int create(String cameraName, PlatformMediaSettings settings);

  /// Initializes a camera, and returns the size of its preview.
  @async
  PlatformSize initialize(int cameraId);

  /// Disposes a camera that is no longer in use.
  void dispose(int cameraId);

  /// Takes a picture with the given camera, and returns the path to the
  /// resulting file.
  @async
  String takePicture(int cameraId);

  /// Starts recording video with the given camera.
  @async
  void startVideoRecording(int cameraId);

  /// Finishes recording video with the given camera, and returns the path to
  /// the resulting file.
  @async
  String stopVideoRecording(int cameraId);

  /// Starts the preview stream for the given camera.
  @async
  void pausePreview(int cameraId);

  /// Resumes the preview stream for the given camera.
  @async
  void resumePreview(int cameraId);
}

@FlutterApi()
abstract class CameraEventApi {
  /// Called when the camera instance is closing on the native side.
  void cameraClosing();

  /// Called when a camera error occurs on the native side.
  void error(String errorMessage);
}
