// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/services.dart';
import 'package:meta/meta.dart' show immutable;

import 'android_camera_camerax_flutter_api_impls.dart';
import 'camera_control.dart';
import 'camerax_library.g.dart';
import 'capture_request_options.dart';
import 'instance_manager.dart';
import 'java_object.dart';
import 'system_services.dart';

/// Class that provides ability to interoperate with android.hardware.camera2
/// APIs and apply options to its specific controls like capture request
/// options.
///
/// See https://developer.android.com/reference/androidx/camera/camera2/interop/Camera2CameraControl#from(androidx.camera.core.CameraControl).
@immutable
class Camera2CameraControl extends JavaObject {
  /// Creates a [Camera2CameraControl].
  Camera2CameraControl(
      {BinaryMessenger? binaryMessenger,
      InstanceManager? instanceManager,
      required this.cameraControl})
      : super.detached(
            binaryMessenger: binaryMessenger,
            instanceManager: instanceManager) {
    _api = _Camera2CameraControlHostApiImpl(
        binaryMessenger: binaryMessenger, instanceManager: instanceManager);
    AndroidCameraXCameraFlutterApis.instance.ensureSetUp();
    _api.createFromInstances(this, cameraControl);
  }

  /// Constructs a [Camera2CameraControl] that is not automatically attached to a
  /// native object.
  Camera2CameraControl.detached(
      {BinaryMessenger? binaryMessenger,
      InstanceManager? instanceManager,
      required this.cameraControl})
      : super.detached(
            binaryMessenger: binaryMessenger,
            instanceManager: instanceManager) {
    _api = _Camera2CameraControlHostApiImpl(
        binaryMessenger: binaryMessenger, instanceManager: instanceManager);
    AndroidCameraXCameraFlutterApis.instance.ensureSetUp();
  }

  late final _Camera2CameraControlHostApiImpl _api;

  /// The [CameraControl] info that this instance is based on.
  ///
  /// Note that options specified with this [Camera2CameraControl] instance will
  /// have higher priority than [cameraControl].
  final CameraControl cameraControl;

  /// Updates capture session with options that the specified
  /// [CaptureRequestOptions] contains.
  ///
  /// Options will be merged with existing options, and if conflicting with what
  /// was previously set, these options will override those pre-existing. Once
  /// merged, these values will be submitted with every repeating and single
  /// capture request issued by CameraX.
  Future<void> addCaptureRequestOptions(
      CaptureRequestOptions captureRequestOptions) {
    return _api.addCaptureRequestOptionsFromInstances(
        this, captureRequestOptions);
  }
}

/// Host API implementation of [Camera2CameraControl].
class _Camera2CameraControlHostApiImpl extends Camera2CameraControlHostApi {
  /// Constructs a [_Camera2CameraControlHostApiImpl].
  ///
  /// If [binaryMessenger] is null, the default [BinaryMessenger] will be used,
  /// which routes to the host platform.
  ///
  /// An [instanceManager] is typically passed when a copy of an instance
  /// contained by an [InstanceManager] is being created. If left null, it
  /// will default to the global instance defined in [JavaObject].
  _Camera2CameraControlHostApiImpl({
    this.binaryMessenger,
    InstanceManager? instanceManager,
  })  : instanceManager = instanceManager ?? JavaObject.globalInstanceManager,
        super(binaryMessenger: binaryMessenger);

  /// Receives binary data across the Flutter platform barrier.
  ///
  /// If it is null, the default [BinaryMessenger] will be used which routes to
  /// the host platform.
  final BinaryMessenger? binaryMessenger;

  /// Maintains instances stored to communicate with native language objects.
  final InstanceManager instanceManager;

  /// Creates a [Camera2CameraControl] instance derived from the specified
  /// [CameraControl] instance.
  Future<void> createFromInstances(
    Camera2CameraControl instance,
    CameraControl cameraControl,
  ) {
    return create(
      instanceManager.addDartCreatedInstance(
        instance,
        onCopy: (Camera2CameraControl original) =>
            Camera2CameraControl.detached(
          cameraControl: original.cameraControl,
          binaryMessenger: binaryMessenger,
          instanceManager: instanceManager,
        ),
      ),
      instanceManager.getIdentifier(cameraControl)!,
    );
  }

  /// Updates capture session corresponding to the specified
  /// [Camera2CameraControl] instance with options that the specified
  /// [CaptureRequestOptions] contains.
  Future<void> addCaptureRequestOptionsFromInstances(
    Camera2CameraControl instance,
    CaptureRequestOptions captureRequestOptions,
  ) async {
    try {
      return addCaptureRequestOptions(
        instanceManager.getIdentifier(instance)!,
        instanceManager.getIdentifier(captureRequestOptions)!,
      );
    } on PlatformException catch (e) {
      SystemServices.cameraErrorStreamController.add(e.message ??
          'The camera was unable to set new capture request options due to new options being unavailable or the camera being closed.');
    }
  }
}
