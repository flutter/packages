// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/services.dart' show BinaryMessenger;
import 'package:meta/meta.dart' show immutable;

import 'android_camera_camerax_flutter_api_impls.dart';
import 'camerax_library.g.dart';
import 'instance_manager.dart';
import 'java_object.dart';

/// The result of [CameraControl.startFocusAndMetering].
///
/// See https://developer.android.com/reference/kotlin/androidx/camera/core/FocusMeteringResult.
@immutable
class FocusMeteringResult extends JavaObject {
  /// Creates a [FocusMeteringResult] that is not automatically attached to a
  /// native object.
  FocusMeteringResult.detached({
    BinaryMessenger? binaryMessenger,
    InstanceManager? instanceManager,
  }) : super.detached(
          binaryMessenger: binaryMessenger,
          instanceManager: instanceManager,
        ) {
    _api = _FocusMeteringResultHostApiImpl(
        binaryMessenger: binaryMessenger, instanceManager: instanceManager);
    AndroidCameraXCameraFlutterApis.instance.ensureSetUp();
  }

  late final _FocusMeteringResultHostApiImpl _api;

  /// Returns whether or not auto focus is successful.
  ///
  /// If the current camera does not support auto focus, it will return true. If
  /// auto focus is not requested, it will return false.
  Future<bool> isFocusSuccessful() => _api.isFocusSuccessfulFromInstance(this);
}

/// Host API implementation of [FocusMeteringResult].
class _FocusMeteringResultHostApiImpl extends FocusMeteringResultHostApi {
  /// Constructs a [FocusMeteringActionHostApiImpl].
  ///
  /// If [binaryMessenger] is null, the default [BinaryMessenger] will be used,
  /// which routes to the host platform.
  ///
  /// An [instanceManager] is typically passed when a copy of an instance
  /// contained by an [InstanceManager] is being created. If left null, it
  /// will default to the global instance defined in [JavaObject].
  _FocusMeteringResultHostApiImpl(
      {this.binaryMessenger, InstanceManager? instanceManager}) {
    this.instanceManager = instanceManager ?? JavaObject.globalInstanceManager;
  }

  /// Receives binary data across the Flutter platform barrier.
  ///
  /// If it is null, the default [BinaryMessenger] will be used which routes to
  /// the host platform.
  final BinaryMessenger? binaryMessenger;

  /// Maintains instances stored to communicate with native language objects.
  late final InstanceManager instanceManager;

  /// Returns whether or not the [instance] indicates that auto focus was
  /// successful.
  Future<bool> isFocusSuccessfulFromInstance(FocusMeteringResult instance) {
    final int identifier = instanceManager.getIdentifier(instance)!;
    return isFocusSuccessful(identifier);
  }
}

/// Flutter API implementation of [FocusMeteringResult].
class FocusMeteringResultFlutterApiImpl extends FocusMeteringResultFlutterApi {
  /// Constructs a [FocusMeteringResultFlutterApiImpl].
  ///
  /// If [binaryMessenger] is null, the default [BinaryMessenger] will be used,
  /// which routes to the host platform.
  ///
  /// An [instanceManager] is typically passed when a copy of an instance
  /// contained by an [InstanceManager] is being created. If left null, it
  /// will default to the global instance defined in [JavaObject].
  FocusMeteringResultFlutterApiImpl({
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
      FocusMeteringResult.detached(
          binaryMessenger: _binaryMessenger, instanceManager: _instanceManager),
      identifier,
      onCopy: (FocusMeteringResult original) {
        return FocusMeteringResult.detached(
            binaryMessenger: _binaryMessenger,
            instanceManager: _instanceManager);
      },
    );
  }
}
