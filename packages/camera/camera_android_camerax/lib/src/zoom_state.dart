// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/services.dart' show BinaryMessenger;

import 'android_camera_camerax_flutter_api_impls.dart';
import 'camerax_library.g.dart';
import 'instance_manager.dart';
import 'java_object.dart';

/// Represents zoom related information of a camera.
///
/// See https://developer.android.com/reference/androidx/camera/core/ZoomState.
class ZoomState extends JavaObject {
  /// Constructs a [CameraInfo] that is not automatically attached to a native object.
  ZoomState.detached(
      {super.binaryMessenger,
      super.instanceManager,
      required this.minZoomRatio,
      required this.maxZoomRatio})
      : super.detached() {
    AndroidCameraXCameraFlutterApis.instance.ensureSetUp();
  }

  /// The minimum zoom ratio of the camera represented by this instance.
  final double minZoomRatio;

  /// The maximum zoom ratio of the camera represented by this instance.
  final double maxZoomRatio;
}

/// Flutter API implementation of [ZoomState].
class ZoomStateFlutterApiImpl implements ZoomStateFlutterApi {
  /// Constructs a [ZoomStateFlutterApiImpl].
  ///
  /// An [instanceManager] is typically passed when a copy of an instance
  /// contained by an [InstanceManager] is being created.
  ZoomStateFlutterApiImpl({
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
  void create(int identifier, double minZoomRatio, double maxZoomRatio) {
    instanceManager.addHostCreatedInstance(
      ZoomState.detached(
          binaryMessenger: binaryMessenger,
          instanceManager: instanceManager,
          minZoomRatio: minZoomRatio,
          maxZoomRatio: maxZoomRatio),
      identifier,
      onCopy: (ZoomState original) {
        return ZoomState.detached(
            binaryMessenger: binaryMessenger,
            instanceManager: instanceManager,
            minZoomRatio: original.minZoomRatio,
            maxZoomRatio: original.maxZoomRatio);
      },
    );
  }
}
