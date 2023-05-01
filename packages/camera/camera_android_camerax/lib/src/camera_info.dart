// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/services.dart' show BinaryMessenger;

import 'android_camera_camerax_flutter_api_impls.dart';
import 'camerax_library.g.dart';
import 'exposure_state.dart';
import 'instance_manager.dart';
import 'java_object.dart';
import 'zoom_state.dart';

/// Represents the metadata of a camera.
///
/// See https://developer.android.com/reference/androidx/camera/core/CameraInfo.
class CameraInfo extends JavaObject {
  /// Constructs a [CameraInfo] that is not automatically attached to a native object.
  CameraInfo.detached(
      {BinaryMessenger? binaryMessenger, InstanceManager? instanceManager})
      : super.detached(
            binaryMessenger: binaryMessenger,
            instanceManager: instanceManager) {
    _api = _CameraInfoHostApiImpl(
        binaryMessenger: binaryMessenger, instanceManager: instanceManager);
    AndroidCameraXCameraFlutterApis.instance.ensureSetUp();
  }

  late final _CameraInfoHostApiImpl _api;

  /// Gets sensor orientation degrees of the camera.
  Future<int> getSensorRotationDegrees() =>
      _api.getSensorRotationDegreesFromInstance(this);

  /// Gets the exposure state of the camera.
  Future<ExposureState> getExposureState() =>
      _api.getExposureStateFromInstance(this);

  /// Gets the zoom state of the camera.
  Future<ZoomState> getZoomState() => _api.getZoomStateFromInstance(this);
}

/// Host API implementation of [CameraInfo].
class _CameraInfoHostApiImpl extends CameraInfoHostApi {
  /// Constructs a [_CameraInfoHostApiImpl].
  _CameraInfoHostApiImpl(
      {super.binaryMessenger, InstanceManager? instanceManager}) {
    this.instanceManager = instanceManager ?? JavaObject.globalInstanceManager;
  }

  /// Maintains instances stored to communicate with native language objects.
  late final InstanceManager instanceManager;

  /// Gets sensor orientation degrees of the specified [CameraInfo] instance.
  Future<int> getSensorRotationDegreesFromInstance(
    CameraInfo instance,
  ) async {
    final int sensorRotationDegrees = await getSensorRotationDegrees(
        instanceManager.getIdentifier(instance)!);
    return sensorRotationDegrees;
  }

  /// Gets the [ExposureState] of the specified [CameraInfo] instance.
  Future<ExposureState> getExposureStateFromInstance(
      CameraInfo instance) async {
    final int? identifier = instanceManager.getIdentifier(instance);
    final int exposureStateIdentifier = await getExposureState(identifier!);
    return instanceManager
        .getInstanceWithWeakReference<ExposureState>(exposureStateIdentifier)!;
  }

  /// Gets the [ZoomState] of the specified [CameraInfo] instance.
  Future<ZoomState> getZoomStateFromInstance(CameraInfo instance) async {
    final int? identifier = instanceManager.getIdentifier(instance);
    final int zoomStateIdentifier = await getZoomState(identifier!);
    return instanceManager
        .getInstanceWithWeakReference<ZoomState>(zoomStateIdentifier)!;
  }
}

/// Flutter API implementation of [CameraInfo].
class CameraInfoFlutterApiImpl extends CameraInfoFlutterApi {
  /// Constructs a [CameraInfoFlutterApiImpl].
  CameraInfoFlutterApiImpl({
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
      CameraInfo.detached(
          binaryMessenger: binaryMessenger, instanceManager: instanceManager),
      identifier,
      onCopy: (CameraInfo original) {
        return CameraInfo.detached(
            binaryMessenger: binaryMessenger, instanceManager: instanceManager);
      },
    );
  }
}
