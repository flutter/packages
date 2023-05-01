// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/services.dart' show BinaryMessenger;

import 'android_camera_camerax_flutter_api_impls.dart';
import 'camerax_library.g.dart';
import 'instance_manager.dart';
import 'java_object.dart';

/// Represents exposure related information of a camera.
///
/// See https://developer.android.com/reference/androidx/camera/core/ExposureState.
class ExposureState extends JavaObject {
  /// Constructs a [ExposureState] that is not automatically attached to a native object.
  ExposureState.detached(
      {super.binaryMessenger,
      super.instanceManager,
      required this.exposureCompensationRange,
      required this.exposureCompensationStep})
      : super.detached() {
    AndroidCameraXCameraFlutterApis.instance.ensureSetUp();
  }

  /// Gets the maximum and minimum exposure compensation values for the camera
  /// represented by this instance.
  final ExposureCompensationRange exposureCompensationRange;

  /// Gets the smallest step by which the exposure compensation can be changed for
  /// the camera represented by this instance.
  final double exposureCompensationStep;
}

/// Flutter API implementation of [ExposureState].
class ExposureStateFlutterApiImpl implements ExposureStateFlutterApi {
  /// Constructs a [ExposureStateFlutterApiImpl].
  ///
  /// An [instanceManager] is typically passed when a copy of an instance
  /// contained by an [InstanceManager] is being created.
  ExposureStateFlutterApiImpl({
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
      ExposureCompensationRange exposureCompensationRange,
      double exposureCompensationStep) {
    instanceManager.addHostCreatedInstance(
      ExposureState.detached(
          binaryMessenger: binaryMessenger,
          instanceManager: instanceManager,
          exposureCompensationRange: exposureCompensationRange,
          exposureCompensationStep: exposureCompensationStep),
      identifier,
      onCopy: (ExposureState original) {
        return ExposureState.detached(
            binaryMessenger: binaryMessenger,
            instanceManager: instanceManager,
            exposureCompensationRange: original.exposureCompensationRange,
            exposureCompensationStep: original.exposureCompensationStep);
      },
    );
  }
}
