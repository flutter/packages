// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/services.dart';

import 'android_camera_camerax_flutter_api_impls.dart';
import 'camerax_library.g.dart';
import 'instance_manager.dart';
import 'java_object.dart';

/// The live state of the camera.
///
/// This is the LiveData of type CameraState that Android tracks in relation
/// to a CameraInfo instance. See
/// https://developer.android.com/reference/androidx/camera/core/CameraInfo#getCameraState().
class LiveCameraState extends JavaObject {
  /// Creates a detached [LiveCameraState].
  LiveCameraState.detached({
    BinaryMessenger? binaryMessenger,
    InstanceManager? instanceManager,
  }) : super.detached(
            binaryMessenger: binaryMessenger,
            instanceManager: instanceManager) {
    _api = LiveCameraStateHostApiImpl(
        binaryMessenger: binaryMessenger, instanceManager: instanceManager);
    AndroidCameraXCameraFlutterApis.instance.ensureSetUp();
  }

  /// Stream that emits an event when the related [Camera] instance starts
  /// to close.
  static final StreamController<bool> cameraClosingStreamController =
      StreamController<bool>.broadcast();

  late final LiveCameraStateHostApiImpl _api;

  /// Adds an observer to the live camera state this instance represents.
  ///
  /// This observer will (i) send a notification to a previously set up
  /// [LiveCameraStateFlutterApiImpl] whenever the camera begins to close
  /// and (ii) send a notification to a previously set up
  /// [SystemServicesFlutterApiImpl] whenever a camera error occurs while
  /// transitioning between states.
  Future<void> addObserver() => _api.addObserverFromInstance(this);

  /// Removes any observers added to the live camera state this instance
  /// represents.
  Future<void> removeObservers() => _api.removeObserversFromInstance(this);
}

/// Host API implementation of [LiveCameraState].
class LiveCameraStateHostApiImpl extends LiveCameraStateHostApi {
  /// Constructs a [LiveCameraStateHostApiImpl].
  LiveCameraStateHostApiImpl(
      {super.binaryMessenger, InstanceManager? instanceManager}) {
    this.instanceManager = instanceManager ?? JavaObject.globalInstanceManager;
  }

  /// Maintains instances stored to communicate with native language objects.
  late final InstanceManager instanceManager;

  /// Adds an observer to the life camera state represented by the specified
  /// [instance].
  Future<void> addObserverFromInstance(LiveCameraState instance) async {
    final int? identifier = instanceManager.getIdentifier(instance);
    assert(identifier != null,
        'No LiveCameraState has the identifer of that which was requested.');
    addObserver(identifier!);
  }

  /// Removes any observers added to the life camera state represented by the
  /// specified [instance].
  Future<void> removeObserversFromInstance(LiveCameraState instance) async {
    final int? identifier = instanceManager.getIdentifier(instance);
    assert(identifier != null,
        'No LiveCameraState has the identifer of that which was requested.');
    removeObservers(identifier!);
  }
}

/// Flutter API implementation of [LiveCameraState].
class LiveCameraStateFlutterApiImpl extends LiveCameraStateFlutterApi {
  /// Constructs a [LiveCameraStateFlutterApiImpl].
  LiveCameraStateFlutterApiImpl({
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
      LiveCameraState.detached(
          binaryMessenger: binaryMessenger, instanceManager: instanceManager),
      identifier,
      onCopy: (LiveCameraState original) {
        return LiveCameraState.detached(
            binaryMessenger: binaryMessenger, instanceManager: instanceManager);
      },
    );
  }

  @override
  void onCameraClosing() {
    LiveCameraState.cameraClosingStreamController.add(true);
  }
}
