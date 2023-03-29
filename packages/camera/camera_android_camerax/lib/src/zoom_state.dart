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
      {BinaryMessenger? binaryMessenger, InstanceManager? instanceManager})
      : super.detached(
            binaryMessenger: binaryMessenger,
            instanceManager: instanceManager) {
    _api = ZoomStateHostApiImpl(
        binaryMessenger: binaryMessenger, instanceManager: instanceManager);
    AndroidCameraXCameraFlutterApis.instance.ensureSetUp();
  }

  late final ZoomStateHostApiImpl _api;

/// Gets the maximum zoom ratio of the camera represented by this instance.
Future<double> getMaxZoomRatio() => _api.getMaxZoomRatioFromInstance(this);

/// Gets the minimum zoom ratio of the camera represented by this instance.
Future<double> getMinZoomRatio() => _api.getMinZoomRatioFromInstance(this);
}

/// Host API implementation of [ZoomState].
class ZoomStateHostApiImpl extends ZoomStateHostApi {
  /// Constructs a [ZoomStateHostApiImpl].
  ZoomStateHostApiImpl(
      {super.binaryMessenger, InstanceManager? instanceManager}) {
    this.instanceManager = instanceManager ?? JavaObject.globalInstanceManager;
  }

  /// Maintains instances stored to communicate with native language objects.
  late final InstanceManager instanceManager;

  /// Gets the maximum zoom ratio of the camera represented by the specified
  /// [ZoomState] instance.
  Future<double> getMaxZoomRatioFromInstance(
    ZoomState instance,
  ) async {
    final int? identifier = instanceManager.getIdentifier(instance);
    assert(identifier != null,
        'No ZoomState has the identifer of that requested to get the resolution information for.');

    final double maxZoomRatio = await getMaxZoomRatio(identifier);
    return maxZoomRatio;
  }

  /// Gets the minimum zoom ratio of the camera represented by the specified
  /// [ZoomState] instance.
  Future<double> getMinZoomRatioFromInstance(ZoomState instance) async {
    final int? identifier = instanceManager.getIdentifier(instance);
    assert(identifier != null,
        'No ZoomState has the identifer of that requested to get the resolution information for.');

    final double minZoomRatio = await getMinZoomRatio(identifier);
    return minZoomRatio;
  }
}


/// Flutter API implementation of [ZoomState].
class ZoomStateFlutterApiImpl implements ZoomStateFlutterApi {
  /// Constructs a [ZoomStateFlutterApiImpl].
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
  void create(int identifier) {
    instanceManager.addHostCreatedInstance(
      ZoomState.detached(
          binaryMessenger: binaryMessenger, instanceManager: instanceManager),
      identifier,
      onCopy: (ZoomState original) {
        return ZoomState.detached(
            binaryMessenger: binaryMessenger, instanceManager: instanceManager);
      },
    );
  }
}
