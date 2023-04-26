// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/src/camerax_library.g.dart',
    dartTestOut: 'test/test_camerax_library.g.dart',
    dartOptions: DartOptions(copyrightHeader: <String>[
      'Copyright 2013 The Flutter Authors. All rights reserved.',
      'Use of this source code is governed by a BSD-style license that can be',
      'found in the LICENSE file.',
    ]),
    javaOut:
        'android/src/main/java/io/flutter/plugins/camerax/GeneratedCameraXLibrary.java',
    javaOptions: JavaOptions(
      package: 'io.flutter.plugins.camerax',
      className: 'GeneratedCameraXLibrary',
      copyrightHeader: <String>[
        'Copyright 2013 The Flutter Authors. All rights reserved.',
        'Use of this source code is governed by a BSD-style license that can be',
        'found in the LICENSE file.',
      ],
    ),
  ),
)
class ResolutionInfo {
  ResolutionInfo({
    required this.width,
    required this.height,
  });

  int width;
  int height;
}

class CameraPermissionsErrorData {
  CameraPermissionsErrorData({
    required this.errorCode,
    required this.description,
  });

  String errorCode;
  String description;
}

class CameraSize {
  CameraSize(this.width, this.height);

  int width;
  int height;
}

@HostApi(dartHostTestHandler: 'TestInstanceManagerHostApi')
abstract class InstanceManagerHostApi {
  /// Clear the native `InstanceManager`.
  ///
  /// This is typically only used after a hot restart.
  void clear();
}

@HostApi(dartHostTestHandler: 'TestJavaObjectHostApi')
abstract class JavaObjectHostApi {
  void dispose(int identifier);
}

@FlutterApi()
abstract class JavaObjectFlutterApi {
  void dispose(int identifier);
}

@HostApi(dartHostTestHandler: 'TestCameraInfoHostApi')
abstract class CameraInfoHostApi {
  int getSensorRotationDegrees(int identifier);
}

@FlutterApi()
abstract class CameraInfoFlutterApi {
  void create(int identifier);
}

@HostApi(dartHostTestHandler: 'TestCameraSelectorHostApi')
abstract class CameraSelectorHostApi {
  void create(int identifier, int? lensFacing);

  List<int> filter(int identifier, List<int> cameraInfoIds);
}

@FlutterApi()
abstract class CameraSelectorFlutterApi {
  void create(int identifier, int? lensFacing);
}

@HostApi(dartHostTestHandler: 'TestProcessCameraProviderHostApi')
abstract class ProcessCameraProviderHostApi {
  @async
  int getInstance();

  List<int> getAvailableCameraInfos(int identifier);

  int bindToLifecycle(
      int identifier, int cameraSelectorIdentifier, List<int> useCaseIds);

  bool isBound(int identifier, int useCaseIdentifier);

  void unbind(int identifier, List<int> useCaseIds);

  void unbindAll(int identifier);
}

@FlutterApi()
abstract class ProcessCameraProviderFlutterApi {
  void create(int identifier);
}

@FlutterApi()
abstract class CameraFlutterApi {
  void create(int identifier);
}

@HostApi(dartHostTestHandler: 'TestSystemServicesHostApi')
abstract class SystemServicesHostApi {
  @async
  CameraPermissionsErrorData? requestCameraPermissions(bool enableAudio);

  void startListeningForDeviceOrientationChange(
      bool isFrontFacing, int sensorOrientation);

  void stopListeningForDeviceOrientationChange();
}

@FlutterApi()
abstract class SystemServicesFlutterApi {
  void onDeviceOrientationChanged(String orientation);

  void onCameraError(String errorDescription);
}

@HostApi(dartHostTestHandler: 'TestPreviewHostApi')
abstract class PreviewHostApi {
  void create(int identifier, int? rotation, ResolutionInfo? targetResolution);

  int setSurfaceProvider(int identifier);

  void releaseFlutterSurfaceTexture();

  ResolutionInfo getResolutionInfo(int identifier);
}

@HostApi(dartHostTestHandler: 'TestImageCaptureHostApi')
abstract class ImageCaptureHostApi {
  void create(int identifier, int? flashMode, ResolutionInfo? targetResolution);

  void setFlashMode(int identifier, int flashMode);

  @async
  String takePicture(int identifier);
}

/// Host API for `ResolutionStrategy`.
///
/// This class may handle instantiating and adding native object instances that
/// are attached to a Dart instance or handle method calls on the associated
/// native class or an instance of the class.
@HostApi(dartHostTestHandler: 'TestResolutionStrategyHostApi')
abstract class ResolutionStrategyHostApi {
  /// Create a new native instance and add it to the `InstanceManager`.
  void create(int identifier, CameraSize size, int fallbackRule);
}

/// Host API for `ResolutionSelector`.
///
/// This class may handle instantiating and adding native object instances that
/// are attached to a Dart instance or handle method calls on the associated
/// native class or an instance of the class.
@HostApi(dartHostTestHandler: 'TestResolutionSelectorHostApi')
abstract class ResolutionSelectorHostApi {
  /// Create a new native instance and add it to the `InstanceManager`.
  void create(
    int identifier,
    int? resolutionStrategyIdentifier,
    int? aspectRatioStrategyIdentifier,
  );
}

/// Host API for `AspectRatioStrategy`.
///
/// This class may handle instantiating and adding native object instances that
/// are attached to a Dart instance or handle method calls on the associated
/// native class or an instance of the class.
@HostApi(dartHostTestHandler: 'TestAspectRatioStrategyHostApi')
abstract class AspectRatioStrategyHostApi {
  /// Create a new native instance and add it to the `InstanceManager`.
  void create(int identifier, int preferredAspectRatio, int fallbackRule);
}
