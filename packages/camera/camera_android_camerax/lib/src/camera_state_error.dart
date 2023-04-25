// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/services.dart';
import 'package:meta/meta.dart';

import 'camerax_library.g.dart';
import 'instance_manager.dart';
import 'java_object.dart';

/// The error that a camera has encountered.
///
/// See https://developer.android.com/reference/androidx/camera/core/CameraState.StateError.
class CameraStateError extends JavaObject {
  /// Constructs a [CameraStateError] that is not automatically attached to a native object.
  CameraStateError.detached(
      {super.binaryMessenger,
      super.instanceManager,
      required this.code,
      required this.description})
      : super.detached();

  /// The code of this error.
  ///
  /// Will map to one of the CameraX CameraState codes:
  /// https://developer.android.com/reference/androidx/camera/core/CameraState#constants_1.
  final int code;

  /// The description of this error corresponding to its [code].
  ///
  /// This is not directly provided by the CameraX library, but is determined on
  /// the Java side based on the error type.
  ///
  /// Descriptions are required to instantiate a [CameraStateError], as they
  /// are used in the camera plugin implementation to send camera error events
  /// to developers using the plugin.
  final String description;
}

/// Flutter API implementation for [CameraStateError].
///
/// This class may handle instantiating and adding Dart instances that are
/// attached to a native instance or receiving callback methods from an
/// overridden native class.
@protected
class CameraStateErrorFlutterApiImpl implements CameraStateErrorFlutterApi {
  /// Constructs a [CameraStateErrorFlutterApiImpl].
  CameraStateErrorFlutterApiImpl({
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
    int code,
    String description,
  ) {
    instanceManager.addHostCreatedInstance(
      CameraStateError.detached(
        code: code,
        description: description,
        binaryMessenger: binaryMessenger,
        instanceManager: instanceManager,
      ),
      identifier,
      onCopy: (CameraStateError original) => CameraStateError.detached(
        code: original.code,
        description: original.description,
        binaryMessenger: binaryMessenger,
        instanceManager: instanceManager,
      ),
    );
  }
}
