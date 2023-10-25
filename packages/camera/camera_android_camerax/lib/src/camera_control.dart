// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/services.dart' show BinaryMessenger, PlatformException;
import 'package:meta/meta.dart' show immutable;

import 'android_camera_camerax_flutter_api_impls.dart';
import 'camerax_library.g.dart';
import 'instance_manager.dart';
import 'java_object.dart';
import 'system_services.dart';

/// The interface that provides asynchronous operations like zoom and focus &
/// metering, which affects output of all [UseCase]s currently bound to the
/// corresponding [Camera] instance.
///
/// See https://developer.android.com/reference/androidx/camera/core/CameraControl.
@immutable
class CameraControl extends JavaObject {
  /// Constructs a [CameraControl] that is not automatically attached to a native object.
  CameraControl.detached(
      {BinaryMessenger? binaryMessenger, InstanceManager? instanceManager})
      : super.detached(
            binaryMessenger: binaryMessenger,
            instanceManager: instanceManager) {
    _api = _CameraControlHostApiImpl(
        binaryMessenger: binaryMessenger, instanceManager: instanceManager);
    AndroidCameraXCameraFlutterApis.instance.ensureSetUp();
  }

  late final _CameraControlHostApiImpl _api;

  /// Enables or disables the torch of related [Camera] instance.
  ///
  /// If the torch mode was unable to be changed, an error message will be
  /// added to [SystemServices.cameraErrorStreamController].
  Future<void> enableTorch(bool torch) async {
    return _api.enableTorchFromInstance(this, torch);
  }

  /// Sets zoom of related [Camera] by ratio.
  ///
  /// Ratio should be between what the `minZoomRatio` and `maxZoomRatio` of the
  /// [ZoomState] of the [CameraInfo] instance that is retrievable from the same
  /// [Camera] instance; otherwise, an error message will be added to
  /// [SystemServices.cameraErrorStreamController].
  Future<void> setZoomRatio(double ratio) async {
    return _api.setZoomRatioFromInstance(this, ratio);
  }
}

/// Host API implementation of [CameraControl].
class _CameraControlHostApiImpl extends CameraControlHostApi {
  /// Constructs a [_CameraControlHostApiImpl].
  ///
  /// An [instanceManager] is typically passed when a copy of an instance
  /// contained by an [InstanceManager] is being created.
  _CameraControlHostApiImpl(
      {this.binaryMessenger, InstanceManager? instanceManager})
      : super(binaryMessenger: binaryMessenger) {
    this.instanceManager = instanceManager ?? JavaObject.globalInstanceManager;
  }

  /// Receives binary data across the Flutter platform barrier.
  ///
  /// If it is null, the default BinaryMessenger will be used which routes to
  /// the host platform.
  final BinaryMessenger? binaryMessenger;

  /// Maintains instances stored to communicate with native language objects.
  late final InstanceManager instanceManager;

  /// Enables or disables the torch for the specified [CameraControl] instance.
  Future<void> enableTorchFromInstance(
      CameraControl instance, bool torch) async {
    final int identifier = instanceManager.getIdentifier(instance)!;
    try {
      await enableTorch(identifier, torch);
    } on PlatformException catch (e) {
      SystemServices.cameraErrorStreamController
          .add(e.message ?? 'The camera was unable to change torch modes.');
    }
  }

  /// Sets zoom of specified [CameraControl] instance by ratio.
  Future<void> setZoomRatioFromInstance(
      CameraControl instance, double ratio) async {
    final int identifier = instanceManager.getIdentifier(instance)!;
    try {
      await setZoomRatio(identifier, ratio);
    } on PlatformException catch (e) {
      SystemServices.cameraErrorStreamController.add(e.message ??
          'Zoom ratio was unable to be set. If ratio was not out of range, newer value may have been set; otherwise, the camera may be closed.');
    }
  }
}

/// Flutter API implementation of [CameraControl].
class CameraControlFlutterApiImpl extends CameraControlFlutterApi {
  /// Constructs a [CameraControlFlutterApiImpl].
  ///
  /// If [binaryMessenger] is null, the default [BinaryMessenger] will be used,
  /// which routes to the host platform.
  ///
  /// An [instanceManager] is typically passed when a copy of an instance
  /// contained by an [InstanceManager] is being created. If left null, it
  /// will default to the global instance defined in [JavaObject].
  CameraControlFlutterApiImpl({
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
      CameraControl.detached(
          binaryMessenger: _binaryMessenger, instanceManager: _instanceManager),
      identifier,
      onCopy: (CameraControl original) {
        return CameraControl.detached(
            binaryMessenger: _binaryMessenger,
            instanceManager: _instanceManager);
      },
    );
  }
}
