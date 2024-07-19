// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/services.dart' show BinaryMessenger;
import 'package:meta/meta.dart' show immutable;

import 'android_camera_camerax_flutter_api_impls.dart';
import 'camera_info.dart';
import 'camerax_library.g.dart';
import 'instance_manager.dart';
import 'java_object.dart';

/// Interface for retrieving Camera2-related camera information.
///
/// See https://developer.android.com/reference/androidx/camera/camera2/interop/Camera2CameraInfo.
@immutable
class Camera2CameraInfo extends JavaObject {
  /// Constructs a [Camera2CameraInfo] that is not automatically attached to a native object.
  Camera2CameraInfo.detached(
      {BinaryMessenger? binaryMessenger, InstanceManager? instanceManager})
      : super.detached(
            binaryMessenger: binaryMessenger,
            instanceManager: instanceManager) {
    _api = _Camera2CameraInfoHostApiImpl(
        binaryMessenger: binaryMessenger, instanceManager: instanceManager);
    AndroidCameraXCameraFlutterApis.instance.ensureSetUp();
  }

  late final _Camera2CameraInfoHostApiImpl _api;

  /// Retrieves [Camera2CameraInfo] instance from [cameraInfo].
  static Future<Camera2CameraInfo> from(CameraInfo cameraInfo,
      {BinaryMessenger? binaryMessenger, InstanceManager? instanceManager}) {
    final _Camera2CameraInfoHostApiImpl api = _Camera2CameraInfoHostApiImpl(
        binaryMessenger: binaryMessenger, instanceManager: instanceManager);
    AndroidCameraXCameraFlutterApis.instance.ensureSetUp();
    return api.fromInstances(cameraInfo);
  }

  /// Retrieves the value of `CameraCharacteristics.INFO_SUPPORTED_HARDWARE_LEVEL`
  /// for the device to which this instance pertains to.
  ///
  /// See https://developer.android.com/reference/android/hardware/camera2/CameraCharacteristics#INFO_SUPPORTED_HARDWARE_LEVEL
  /// for more information.
  Future<int> getSupportedHardwareLevel() =>
      _api.getSupportedHardwareLevelFromInstance(this);

  /// Gets the camera ID.
  ///
  /// The ID may change based on the internal configuration of the camera to which
  /// this instances pertains.
  Future<String> getCameraId() => _api.getCameraIdFromInstance(this);

  /// Retrieves the orientation of the camera sensor.
  Future<int> getSensorOrientation() =>
      _api.getSensorOrientationFromInstance(this);
}

/// Host API implementation of [Camera2CameraInfo].
class _Camera2CameraInfoHostApiImpl extends Camera2CameraInfoHostApi {
  /// Constructs a [_Camera2CameraInfoHostApiImpl].
  _Camera2CameraInfoHostApiImpl(
      {this.binaryMessenger, InstanceManager? instanceManager})
      : instanceManager = instanceManager ?? JavaObject.globalInstanceManager,
        super(binaryMessenger: binaryMessenger);

  /// Maintains instances stored to communicate with native language objects.
  late final InstanceManager instanceManager;

  /// Receives binary data across the Flutter platform barrier.
  ///
  /// If it is null, the default [BinaryMessenger] will be used which routes to
  /// the host platform.
  final BinaryMessenger? binaryMessenger;

  /// Gets sensor orientation degrees of the specified [CameraInfo] instance.
  Future<Camera2CameraInfo> fromInstances(
    CameraInfo cameraInfo,
  ) async {
    final int? cameraInfoIdentifier = instanceManager.getIdentifier(cameraInfo);
    return instanceManager.getInstanceWithWeakReference<Camera2CameraInfo>(
        await createFrom(cameraInfoIdentifier!))!;
  }

  Future<int> getSupportedHardwareLevelFromInstance(
      Camera2CameraInfo instance) {
    final int? identifier = instanceManager.getIdentifier(instance);
    return getSupportedHardwareLevel(identifier!);
  }

  Future<String> getCameraIdFromInstance(Camera2CameraInfo instance) {
    final int? identifier = instanceManager.getIdentifier(instance);
    return getCameraId(identifier!);
  }

  Future<int> getSensorOrientationFromInstance(Camera2CameraInfo instance) {
    final int? identifier = instanceManager.getIdentifier(instance);
    return getSensorOrientation(identifier!);
  }
}

/// Flutter API Implementation of [Camera2CameraInfo].
class Camera2CameraInfoFlutterApiImpl implements Camera2CameraInfoFlutterApi {
  /// Constructs an [Camera2CameraInfoFlutterApiImpl].
  ///
  /// If [binaryMessenger] is null, the default [BinaryMessenger] will be used,
  /// which routes to the host platform.
  ///
  /// An [instanceManager] is typically passed when a copy of an instance
  /// contained by an [InstanceManager] is being created. If left null, it
  /// will default to the global instance defined in [JavaObject].
  Camera2CameraInfoFlutterApiImpl({
    BinaryMessenger? binaryMessenger,
    InstanceManager? instanceManager,
  })  : _binaryMessenger = binaryMessenger,
        _instanceManager = instanceManager ?? JavaObject.globalInstanceManager;

  /// Receives binary data across the Flutter platform barrier.
  final BinaryMessenger? _binaryMessenger;

  /// Maintains instances stored to communicate with native language objects.
  final InstanceManager _instanceManager;

  @override
  void create(int identifier) {
    _instanceManager.addHostCreatedInstance(
      Camera2CameraInfo.detached(
          binaryMessenger: _binaryMessenger, instanceManager: _instanceManager),
      identifier,
      onCopy: (Camera2CameraInfo original) {
        return Camera2CameraInfo.detached(
            binaryMessenger: _binaryMessenger,
            instanceManager: _instanceManager);
      },
    );
  }
}
