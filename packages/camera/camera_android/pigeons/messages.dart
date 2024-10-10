// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
import 'package:camera_platform_interface/camera_platform_interface.dart';
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

@HostApi()
abstract class CameraApi {
  /// Returns the list of available cameras.
  List<PlatformCameraDescription> getAvailableCameras();
}
