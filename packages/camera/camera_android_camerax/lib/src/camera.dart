// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/services.dart' show BinaryMessenger;

import 'android_camera_camerax_flutter_api_impls.dart';
import 'camera_info.dart';
import 'camerax_library.g.dart';
import 'instance_manager.dart';
import 'java_object.dart';

/// The interface used to control the flow of data of use cases, control the
/// camera, and publich the state of the camera.
///
/// See https://developer.android.com/reference/androidx/camera/core/Camera.
class Camera extends JavaObject {
  /// Constructs a [Camera] that is not automatically attached to a native object.
  Camera.detached(
      {BinaryMessenger? binaryMessenger, InstanceManager? instanceManager})
      : super.detached(
            binaryMessenger: binaryMessenger,
            instanceManager: instanceManager) {
    _api = CameraHostApiImpl(
        binaryMessenger: binaryMessenger, instanceManager: instanceManager);
    AndroidCameraXCameraFlutterApis.instance.ensureSetUp();
  }

  late final CameraHostApiImpl _api;

  /// Retrieve the [CameraInfo] instance that contains information about this
  /// instance.
  Future<CameraInfo> getCameraInfo() async {
    return _api.getCameraInfoFromInstance(this);
  }
}

/// Host API implementation of [Camera].
class CameraHostApiImpl extends CameraHostApi {
  /// Constructs a [CameraHostApiImpl].
  ///
  /// An [instanceManager] is typically passed when a copy of an instance
  /// contained by an [InstanceManager] is being created.
  CameraHostApiImpl({this.binaryMessenger, InstanceManager? instanceManager})
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

  /// Gets the [CameraInfo] associated with the specified instance of [Camera].
  Future<CameraInfo> getCameraInfoFromInstance(Camera instance) async {
    final int identifier = instanceManager.getIdentifier(instance)!;
    final int cameraInfoId = await getCameraInfo(identifier);

    return instanceManager
        .getInstanceWithWeakReference<CameraInfo>(cameraInfoId)!;
  }
}

/// Flutter API implementation of [Camera].
class CameraFlutterApiImpl implements CameraFlutterApi {
  /// Constructs a [CameraFlutterApiImpl].
  ///
  /// If [binaryMessenger] is null, the default [BinaryMessenger] will be used,
  /// which routes to the host platform.
  ///
  /// An [instanceManager] is typically passed when a copy of an instance
  /// contained by an [InstanceManager] is being created. If left null, it
  /// will default to the global instance defined in [JavaObject].
  CameraFlutterApiImpl({
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
      Camera.detached(
          binaryMessenger: _binaryMessenger, instanceManager: _instanceManager),
      identifier,
      onCopy: (Camera original) {
        return Camera.detached(
            binaryMessenger: _binaryMessenger,
            instanceManager: _instanceManager);
      },
    );
  }
}
