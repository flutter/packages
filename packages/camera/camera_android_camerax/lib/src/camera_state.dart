// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/services.dart';
import 'package:meta/meta.dart';

import 'camera_state_error.dart';
import 'camerax_library.g.dart';
import 'instance_manager.dart';
import 'java_object.dart';

/// The state of a camera.
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
}

/// Flutter API implementation for [CameraState].
///
/// This class may handle instantiating and adding Dart instances that are
/// attached to a native instance or receiving callback methods from an
/// overridden native class.
@protected
class CameraStateFlutterApiImpl implements CameraStateFlutterApi {
  /// Constructs a [CameraStateFlutterApiImpl].
  CameraStateFlutterApiImpl({
    this.binaryMessenger,
    InstanceManager? instanceManager,
  }) : instanceManager = instanceManager ?? JavaObject.globalInstanceManager;

  /// Receives binary data across the Flutter platform barrier.
  ///
  /// If it is null, the default BinaryMessenger will be used which routes to
  /// the host platform.
  final BinaryMessenger? binaryMessenger;

  /// Maintains instances stored to communicate with native language objects.
  final InstanceManager instanceManager;

  @override
  void create(
    int identifier,
    CameraStateTypeData type,
    int? errorIdentifier,
  ) {
    instanceManager.addHostCreatedInstance(
      CameraState.detached(
        type: type.value,
        error: errorIdentifier == null
            ? null
            : instanceManager.getInstanceWithWeakReference(
                errorIdentifier,
              ),
        binaryMessenger: binaryMessenger,
        instanceManager: instanceManager,
      ),
      identifier,
      onCopy: (CameraState original) => CameraState.detached(
        type: original.type,
        error: original.error,
        binaryMessenger: binaryMessenger,
        instanceManager: instanceManager,
      ),
    );
  }
}
