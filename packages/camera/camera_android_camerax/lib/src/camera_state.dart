// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/services.dart';
import 'package:meta/meta.dart';

import 'camera_state_error.dart';
import 'camerax_library.g.dart';
import 'instance_manager.dart';
import 'java_object.dart';

/// A snapshot of the camera state.
///
/// See https://developer.android.com/reference/androidx/camera/core/CameraState.
class CameraState extends JavaObject {
  /// Constructs a [CameraState] that is not automatically attached to a native object.
  CameraState.detached(
      {super.binaryMessenger,
      super.instanceManager,
      required this.type,
      this.error})
      : super.detached();

  /// The type of state that the camera is in.
  final CameraStateType type;

  /// The error that the camera has encountered, if any.
  final CameraStateError? error;

  /// Error code indicating that the camera device is already in use.
  ///
  /// See https://developer.android.com/reference/androidx/camera/core/CameraState#ERROR_CAMERA_IN_USE()
  static const int errorCameraInUse = 1;

  /// Error code indicating that the limit number of open cameras has been
  /// reached.
  ///
  /// See https://developer.android.com/reference/androidx/camera/core/CameraState#ERROR_MAX_CAMERAS_IN_USE()
  static const int errorMaxCamerasInUse = 2;

  /// Error code indicating that the camera device has encountered a recoverable
  /// error.
  ///
  /// See https://developer.android.com/reference/androidx/camera/core/CameraState#ERROR_OTHER_RECOVERABLE_ERROR()
  static const int errorOtherRecoverableError = 3;

  /// Error code inidcating that configuring the camera has failed.
  ///
  /// https://developer.android.com/reference/androidx/camera/core/CameraState#ERROR_STREAM_CONFIG()
  static const int errorStreamConfig = 4;

  /// Error code indicating that the camera device could not be opened due to a
  /// device policy.
  ///
  /// See https://developer.android.com/reference/androidx/camera/core/CameraState#ERROR_CAMERA_DISABLED()
  static const int errorCameraDisabled = 5;

  /// Error code indicating that the camera device was closed due to a fatal
  /// error.
  ///
  /// See https://developer.android.com/reference/androidx/camera/core/CameraState#ERROR_CAMERA_FATAL_ERROR()
  static const int errorCameraFatalError = 6;

  /// Error code indicating that the camera could not be opened because
  /// "Do Not Disturb" mode is enabled on devices affected by a bug in Android 9
  /// (API level 28).
  ///
  /// See https://developer.android.com/reference/androidx/camera/core/CameraState#ERROR_DO_NOT_DISTURB_MODE_ENABLED()
  static const int errorDoNotDisturbModeEnabled = 7;
}

/// Flutter API implementation for [CameraState].
///
/// This class may handle instantiating and adding Dart instances that are
/// attached to a native instance or receiving callback methods from an
/// overridden native class.
@protected
class CameraStateFlutterApiImpl implements CameraStateFlutterApi {
  /// Constructs a [CameraStateFlutterApiImpl].
  ///
  /// If [binaryMessenger] is null, the default [BinaryMessenger] will be used,
  /// which routes to the host platform.
  ///
  /// An [instanceManager] is typically passed when a copy of an instance
  /// contained by an [InstanceManager] is being created. If left null, it
  /// will default to the global instance defined in [JavaObject].
  CameraStateFlutterApiImpl({
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
    CameraStateTypeData type,
    int? errorIdentifier,
  ) {
    _instanceManager.addHostCreatedInstance(
      CameraState.detached(
        type: type.value,
        error: errorIdentifier == null
            ? null
            : _instanceManager.getInstanceWithWeakReference(
                errorIdentifier,
              ),
        binaryMessenger: _binaryMessenger,
        instanceManager: _instanceManager,
      ),
      identifier,
      onCopy: (CameraState original) => CameraState.detached(
        type: original.type,
        error: original.error,
        binaryMessenger: _binaryMessenger,
        instanceManager: _instanceManager,
      ),
    );
  }
}
