// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/services.dart';
import 'package:meta/meta.dart';

import 'camera_state.dart';
import 'camerax_library.g.dart';
import 'instance_manager.dart';
import 'java_object.dart';

/// The error that a camera has encountered.
///
/// See https://developer.android.com/reference/androidx/camera/core/CameraState.StateError.
class CameraStateError extends JavaObject {
  /// Constructs a [CameraStateError] that is not automatically attached to a native object.
  CameraStateError.detached(
      {super.binaryMessenger, super.instanceManager, required this.code})
      : super.detached();

  /// The code of this error.
  ///
  /// Will map to one of the [CameraState] error codes that map to the CameraX
  /// CameraState codes:
  /// https://developer.android.com/reference/androidx/camera/core/CameraState#constants_1.
  final int code;

  /// Gets a description of this error corresponding to its [code].
  ///
  /// This is not directly provided by the CameraX library, but is determined
  /// based on the description of the [code].
  ///
  /// Provided for developers to use for error handling.
  String getDescription() {
    String description = '';
    switch (code) {
      case CameraState.errorCameraInUse:
        description =
            'The camera was already in use, possibly by a higher-priority camera client.';
        break;
      case CameraState.errorMaxCamerasInUse:
        description =
            'The limit number of open cameras has been reached, and more cameras cannot be opened until other instances are closed.';
        break;
      case CameraState.errorOtherRecoverableError:
        description =
            'The camera device has encountered a recoverable error. CameraX will attempt to recover from the error.';
        break;
      case CameraState.errorStreamConfig:
        description = 'Configuring the camera has failed.';
        break;
      case CameraState.errorCameraDisabled:
        description =
            'The camera device could not be opened due to a device policy. Thia may be caused by a client from a background process attempting to open the camera.';
        break;
      case CameraState.errorCameraFatalError:
        description =
            'The camera was closed due to a fatal error. This may require the Android device be shut down and restarted to restore camera function or may indicate a persistent camera hardware problem.';
        break;
      case CameraState.errorDoNotDisturbModeEnabled:
        description =
            'The camera could not be opened because "Do Not Disturb" mode is enabled. Please disable this mode, and try opening the camera again.';
        break;
      default:
        description =
            'There was an unspecified issue with the current camera state.';
        break;
    }

    return '$code : $description';
  }
}

/// Flutter API implementation for [CameraStateError].
///
/// This class may handle instantiating and adding Dart instances that are
/// attached to a native instance or receiving callback methods from an
/// overridden native class.
@protected
class CameraStateErrorFlutterApiImpl implements CameraStateErrorFlutterApi {
  /// Constructs a [CameraStateErrorFlutterApiImpl].
  ///
  /// If [binaryMessenger] is null, the default [BinaryMessenger] will be used,
  /// which routes to the host platform.
  ///
  /// An [instanceManager] is typically passed when a copy of an instance
  /// contained by an [InstanceManager] is being created. If left null, it
  /// will default to the global instance defined in [JavaObject]. If left null, it
  /// will default to the global instance defined in [JavaObject].
  CameraStateErrorFlutterApiImpl({
    BinaryMessenger? binaryMessenger,
    InstanceManager? instanceManager,
  })  : _binaryMessenger = binaryMessenger,
        _instanceManager = instanceManager ?? JavaObject.globalInstanceManager;

  /// Receives binary data across the Flutter platform barrier.
  final BinaryMessenger? _binaryMessenger;

  /// Maintains instances stored to communicate with native language objects.
  final InstanceManager _instanceManager;

  @override
  void create(
    int identifier,
    int code,
  ) {
    _instanceManager.addHostCreatedInstance(
      CameraStateError.detached(
        code: code,
        binaryMessenger: _binaryMessenger,
        instanceManager: _instanceManager,
      ),
      identifier,
      onCopy: (CameraStateError original) => CameraStateError.detached(
        code: original.code,
        binaryMessenger: _binaryMessenger,
        instanceManager: _instanceManager,
      ),
    );
  }
}
