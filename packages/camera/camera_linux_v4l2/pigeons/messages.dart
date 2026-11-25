// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/src/messages.g.dart',
    dartPackageName: 'camera_linux_v4l2',
    gobjectHeaderOut: 'linux/messages.g.h',
    gobjectSourceOut: 'linux/messages.g.cc',
    gobjectOptions: GObjectOptions(module: 'Fcl'),
    copyrightHeader: 'pigeons/copyright.txt',
  ),
)
/// Pigeon version of platform interface's ResolutionPreset.
enum PlatformResolutionPreset { low, medium, high, veryHigh, ultraHigh, max }

/// A frame size reported by the native camera API.
class PlatformSize {
  PlatformSize({required this.width, required this.height});

  final double width;
  final double height;
}

@HostApi()
abstract class CameraApi {
  /// Returns the device paths of all available V4L2 capture cameras.
  List<String> getAvailableCameras();

  /// Creates a camera instance and returns its texture/camera ID.
  int create(String cameraName, PlatformResolutionPreset resolutionPreset);

  /// Opens the camera device, starts streaming, and returns its negotiated size.
  PlatformSize initialize(int cameraId);

  /// Starts delivering streamed frames over [CameraEventApi.onFrameAvailable].
  void startImageStream(int cameraId);

  /// Stops delivering streamed frames over [CameraEventApi.onFrameAvailable].
  void stopImageStream(int cameraId);

  /// Releases the camera and stops capture.
  void dispose(int cameraId);
}

@FlutterApi()
abstract class CameraEventApi {
  /// Called when a new BGRA8888 image-stream frame is available.
  void onFrameAvailable(int width, int height, int bytesPerRow, Uint8List bytes);

  /// Called when the camera instance is closing on the native side.
  void cameraClosing();

  /// Called when a camera error occurs on the native side.
  void error(String errorMessage);
}
