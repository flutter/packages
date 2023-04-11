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

enum CameraStateType {
  closed,
  closing,
  open,
  opening,
  pendingOpen,
}

class CameraStateTypeData {
  late CameraStateType value;
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

  int getLiveCameraState(int identifier);
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

@HostApi(dartHostTestHandler: 'TestCameraHostApi')
abstract class CameraHostApi {
  int getCameraInfo(int identifier);
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

@HostApi(dartHostTestHandler: 'TestLiveCameraStateHostApi')
abstract class LiveCameraStateHostApi {
  void addObserver(int identifier);

  void removeObservers(int identifier);
}

@FlutterApi()
abstract class LiveCameraStateFlutterApi {
  void create(int identifier);

  void onCameraClosing();
}

/// Host API for `CameraState`.
///
/// This class may handle instantiating and adding native object instances that
/// are attached to a Dart instance or handle method calls on the associated
/// native class or an instance of the class.
///
/// See <link-to-docs>.
@HostApi(dartHostTestHandler: 'TestCameraStateHostApi')
abstract class CameraStateHostApi {}

/// Flutter API for `CameraState`.
///
/// This class may handle instantiating and adding Dart instances that are
/// attached to a native instance or receiving callback methods from an
/// overridden native class.
///
/// See <link-to-docs>.
@FlutterApi()
abstract class CameraStateFlutterApi {
  /// Create a new Dart instance and add it to the `InstanceManager`.

  void create(
    int identifier,
    CameraStateTypeData type,
    int errorIdentifier,
  );
}

// TODO(bparrishMines): Copy these classes into pigeon file and run pigeon
// TODO(bparrishMines): Fix documentation spacing over class methods if this is for iOS

/// Host API for `Observer`.
///
/// This class may handle instantiating and adding native object instances that
/// are attached to a Dart instance or handle method calls on the associated
/// native class or an instance of the class.
///
/// See <link-to-docs>.
@HostApi(dartHostTestHandler: 'TestObserverHostApi')
abstract class ObserverHostApi {
  /// Create a new native instance and add it to the `InstanceManager`.

  void create(
    int identifier,
  );
}

/// Flutter API for `Observer`.
///
/// This class may handle instantiating and adding Dart instances that are
/// attached to a native instance or receiving callback methods from an
/// overridden native class.
///
/// See <link-to-docs>.
@FlutterApi()
abstract class ObserverFlutterApi {
  /// Callback to Dart function `Observer.onChanged`.

  void onChanged(
    int identifier,
    int valueIdentifier,
  );
}

// TODO(bparrishMines): Copy these classes into pigeon file and run pigeon
// TODO(bparrishMines): Fix documentation spacing over class methods if this is for iOS

/// Host API for `CameraStateError`.
///
/// This class may handle instantiating and adding native object instances that
/// are attached to a Dart instance or handle method calls on the associated
/// native class or an instance of the class.
///
/// See <link-to-docs>.
@HostApi(dartHostTestHandler: 'TestCameraStateErrorHostApi')
abstract class CameraStateErrorHostApi {}

/// Flutter API for `CameraStateError`.
///
/// This class may handle instantiating and adding Dart instances that are
/// attached to a native instance or receiving callback methods from an
/// overridden native class.
///
/// See <link-to-docs>.
@FlutterApi()
abstract class CameraStateErrorFlutterApi {
  /// Create a new Dart instance and add it to the `InstanceManager`.

  void create(
    int identifier,
    int code,
    String description,
  );
}

// TODO(bparrishMines): Copy these classes into pigeon file and run pigeon
// TODO(bparrishMines): Fix documentation spacing over class methods if this is for iOS

/// Host API for `LiveData`.
///
/// This class may handle instantiating and adding native object instances that
/// are attached to a Dart instance or handle method calls on the associated
/// native class or an instance of the class.
///
/// See <link-to-docs>.
@HostApi(dartHostTestHandler: 'TestLiveDataHostApi')
abstract class LiveDataHostApi {
  /// Handles Dart method `LiveData.observe`.

  void observe(
    int identifier,
    int observerIdentifier,
  );

  /// Handles Dart method `LiveData.removeObservers`.

  void removeObservers(
    int identifier,
  );
}

/// Flutter API for `LiveData`.
///
/// This class may handle instantiating and adding Dart instances that are
/// attached to a native instance or receiving callback methods from an
/// overridden native class.
///
/// See <link-to-docs>.
@FlutterApi()
abstract class LiveDataFlutterApi {
  /// Create a new Dart instance and add it to the `InstanceManager`.

  void create(
    int identifier,
  );
}
