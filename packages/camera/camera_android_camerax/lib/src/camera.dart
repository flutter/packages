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
  Camera.detached({super.binaryMessenger, super.instanceManager})
      : super.detached() {
    _api = CameraHostApiImpl();
    AndroidCameraXCameraFlutterApis.instance.ensureSetUp();
  }

  late final CameraHostApiImpl _api;

  Future<CameraInfo> getCameraInfo() async {
    return _api.getCameraInfoFromInstance(this);
  }
}

/// Host API implementation of [Camera].
class CameraHostApiImpl extends CameraHostApi {
  /// Constructs a [CameraHostApiImpl].
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
    final int? identifier = instanceManager.getIdentifier(instance);

    assert(identifier != null,
        'No Camera has the identifer of that which was requested.');
    final int? cameraInfoId = await getCameraInfo(identifier!);
    return instanceManager
        .getInstanceWithWeakReference<CameraInfo>(cameraInfoId!)! as CameraInfo;
  }
}

/// Flutter API implementation of [Camera].
class CameraFlutterApiImpl implements CameraFlutterApi {
  /// Constructs a [CameraSelectorFlutterApiImpl].
  CameraFlutterApiImpl({
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
      Camera.detached(
          binaryMessenger: binaryMessenger, instanceManager: instanceManager),
      identifier,
      onCopy: (Camera original) {
        return Camera.detached(
            binaryMessenger: binaryMessenger, instanceManager: instanceManager);
      },
    );
  }
}
