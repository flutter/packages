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

/// Pigeon version of pltaform interface's ResolutionPreset.
enum ResolutionPreset { low, medium, high, veryHigh, ultraHigh, max }

/// A representation of a size from the native camera APIs.
class PlatformSize {
  PlatformSize({required this.width, required this.height});

  final double width;
  final double height;
}

// Pigeon version of the relevant subset of VideoCaptureOptions.
class PlatformVideoCaptureOptions {
  PlatformVideoCaptureOptions({required this.maxDurationMilliseconds});

  final int maxDurationMilliseconds;
}

@HostApi()
abstract class CameraApi {
  /// Returns the names of all of the available capture devices.
  List<String> availableCameras();

  /// Creates a camera instance for the given device name and settings.
  @async
  String create(
      String cameraName, ResolutionPreset? resolutionPreset, bool enableAudio);

  /// Initializes a camera, and returns the size of its preview.
  @async
  PlatformSize initialize(int cameraId);

  /// Disposes a camera that is no longer in use.
  PlatformSize dispose(int cameraId);

  /// Takes a picture with the given camera, and returns the path to the
  /// resulting file.
  @async
  String takePicture(int cameraId);

  /// Starts recording video with the given camera.
  @async
  void startVideoRecording(int cameraId, PlatformVideoCaptureOptions options);

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
