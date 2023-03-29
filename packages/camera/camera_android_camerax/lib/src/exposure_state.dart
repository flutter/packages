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
  /// Constructs a [CameraInfo] that is not automatically attached to a native object.
  ExposureState.detached(
      {BinaryMessenger? binaryMessenger, InstanceManager? instanceManager})
      : super.detached(
            binaryMessenger: binaryMessenger,
            instanceManager: instanceManager) {
    _api = ExposureStateHostApiImpl(
        binaryMessenger: binaryMessenger, instanceManager: instanceManager);
    AndroidCameraXCameraFlutterApis.instance.ensureSetUp();
  }

  late final ExposureStateHostApiImpl _api;

/// Gets the maximum and minimum exposure compensation values for the camera
/// represented by this instance.
Future<ExposureRange> getExposureCompensationRange() => _api.getExposureCompensationRangeFromInstance(this);

/// Gets the smallest step by which the exposure compensation can be changed for
/// the camera represented by this instance. 
Future<double> getExposureCompensationStep() => _api.getExposureCompensationStepFromInstance(this);
}

/// Host API implementation of [ExposureState].
class ExposureStateHostApiImpl extends ExposureStateHostApi {
  /// Constructs a [ExposureStateHostApiImpl].
  ExposureStateHostApiImpl(
      {super.binaryMessenger, InstanceManager? instanceManager}) {
    this.instanceManager = instanceManager ?? JavaObject.globalInstanceManager;
  }

  /// Maintains instances stored to communicate with native language objects.
  late final InstanceManager instanceManager;

 /// Gets the maximum and minimum exposure compensation values for the camera
 /// represented by the specified [ExposureState] instance.
  Future<ExposureRange> getExposureCompensationRange(
    ExposureState instance,
  ) async {
    final int? identifier = instanceManager.getIdentifier(instance);
    assert(identifier != null,
        'No ExposureState has the identifer of that requested to get the resolution information for.');

    final ExposureRange exposureCompensationRange = await getExposureCompensationRange(identifier);
    return exposureCompensationRange;
  }

  /// Gets the smallest step by which the exposure compensation can be changed for
  /// the camera represented by the specified [ExposureState] instance.
  Future<double> getExposureCompensationStepFromInstance(ExposureState instance) async {
    final int? identifier = instanceManager.getIdentifier(instance);
    assert(identifier != null,
        'No ExposureState has the identifer of that requested to get the resolution information for.');

    final double exposureCompensationState = await getExposureCompensationRange(identifier);
    return exposureCompensationState;
  }
}


/// Flutter API implementation of [ExposureState].
class ExposureStateFlutterApiImpl implements ExposureStateFlutterApi {
  /// Constructs a [ExposureStateFlutterApiImpl].
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
  void create(int identifier) {
    instanceManager.addHostCreatedInstance(
      ExposureState.detached(
          binaryMessenger: binaryMessenger, instanceManager: instanceManager),
      identifier,
      onCopy: (ExposureState original) {
        return ExposureState.detached(
            binaryMessenger: binaryMessenger, instanceManager: instanceManager);
      },
    );
  }
}
