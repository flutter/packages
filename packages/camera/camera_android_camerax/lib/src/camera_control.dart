// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/services.dart' show BinaryMessenger, PlatformException;
import 'package:meta/meta.dart' show immutable;

import 'android_camera_camerax_flutter_api_impls.dart';
import 'camerax_library.g.dart';
import 'focus_metering_action.dart';
import 'focus_metering_result.dart';
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

  /// Starts a focus and metering action configured by the [FocusMeteringAction].
  ///
  /// Will trigger an auto focus action and enable auto focus/auto exposure/
  /// auto white balance metering regions.
  ///
  /// Only one [FocusMeteringAction] is allowed to run at a time; if multiple
  /// are executed in a row, only the latest one will work and other actions
  /// will be canceled.
  ///
  /// Returns null if focus and metering could not be started.
  Future<FocusMeteringResult?> startFocusAndMetering(
      FocusMeteringAction action) {
    return _api.startFocusAndMeteringFromInstance(this, action);
  }

  /// Cancels current [FocusMeteringAction] and clears auto focus/auto exposure/
  /// auto white balance regions.
  Future<void> cancelFocusAndMetering() =>
      _api.cancelFocusAndMeteringFromInstance(this);

  /// Sets the exposure compensation value for related [Camera] and returns the
  /// new target exposure value.
  ///
  /// The exposure compensation value set on the camera must be within the range
  /// of the current [ExposureState]'s `exposureCompensationRange` for the call
  /// to succeed.
  ///
  /// Only one [setExposureCompensationIndex] is allowed to run at a time; if
  /// multiple are executed in a row, only the latest setting will be kept in
  /// the camera.
  ///
  /// Returns null if the exposure compensation index failed to be set.
  Future<int?> setExposureCompensationIndex(int index) async {
    return _api.setExposureCompensationIndexFromInstance(this, index);
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

  /// Starts a focus and metering action configured by the [FocusMeteringAction]
  /// for the specified [CameraControl] instance.
  Future<FocusMeteringResult?> startFocusAndMeteringFromInstance(
      CameraControl instance, FocusMeteringAction action) async {
    final int cameraControlIdentifier =
        instanceManager.getIdentifier(instance)!;
    final int actionIdentifier = instanceManager.getIdentifier(action)!;
    try {
      final int? focusMeteringResultId = await startFocusAndMetering(
          cameraControlIdentifier, actionIdentifier);
      if (focusMeteringResultId == null) {
        SystemServices.cameraErrorStreamController.add(
            'Starting focus and metering was canceled due to the camera being closed or a new request being submitted.');
        return Future<FocusMeteringResult?>.value();
      }
      return instanceManager.getInstanceWithWeakReference<FocusMeteringResult>(
          focusMeteringResultId);
    } on PlatformException catch (e) {
      SystemServices.cameraErrorStreamController
          .add(e.message ?? 'Starting focus and metering failed.');
      // Surfacing error to differentiate an operation cancellation from an
      // illegal argument exception at a plugin layer.
      rethrow;
    }
  }

  /// Cancels current [FocusMeteringAction] and clears AF/AE/AWB regions for the
  /// specified [CameraControl] instance.
  Future<void> cancelFocusAndMeteringFromInstance(
      CameraControl instance) async {
    final int identifier = instanceManager.getIdentifier(instance)!;
    await cancelFocusAndMetering(identifier);
  }

  /// Sets exposure compensation index for specified [CameraControl] instance
  /// and returns the new target exposure value.
  Future<int?> setExposureCompensationIndexFromInstance(
      CameraControl instance, int index) async {
    final int identifier = instanceManager.getIdentifier(instance)!;
    try {
      final int? exposureCompensationIndex =
          await setExposureCompensationIndex(identifier, index);
      if (exposureCompensationIndex == null) {
        SystemServices.cameraErrorStreamController.add(
            'Setting exposure compensation index was canceled due to the camera being closed or a new request being submitted.');
        return Future<int?>.value();
      }
      return exposureCompensationIndex;
    } on PlatformException catch (e) {
      SystemServices.cameraErrorStreamController.add(e.message ??
          'Setting the camera exposure compensation index failed.');
      // Surfacing error to plugin layer to maintain consistency of
      // setExposureOffset implementation across platform implementations.
      rethrow;
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
