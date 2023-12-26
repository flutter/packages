// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/services.dart' show BinaryMessenger;
import 'package:meta/meta.dart' show immutable;

import 'android_camera_camerax_flutter_api_impls.dart';
import 'camerax_library.g.dart';
import 'instance_manager.dart';
import 'java_object.dart';

/// somethin
@immutable
class MeteringPoint extends JavaObject {
  /// Creates a [MeteringPoint].
  MeteringPoint({
    BinaryMessenger? binaryMessenger,
    InstanceManager? instanceManager,
    required this.x,
    required this.y,
    required this.size,
  }) : super.detached(
          binaryMessenger: binaryMessenger,
          instanceManager: instanceManager,
        ) {
    _api = _MeteringPointHostApiImpl(
        binaryMessenger: binaryMessenger, instanceManager: instanceManager);
    _api.createFromInstance(this, x, y, size);
    AndroidCameraXCameraFlutterApis.instance.ensureSetUp();
  }

  /// Creates a [MeteringPoint] that is not automatically attached to a
  /// native object.
  MeteringPoint.detached({
    BinaryMessenger? binaryMessenger,
    InstanceManager? instanceManager,
    required this.x,
    required this.y,
    required this.size,
  }) : super.detached(
          binaryMessenger: binaryMessenger,
          instanceManager: instanceManager,
        ) {
    _api = _MeteringPointHostApiImpl(
        binaryMessenger: binaryMessenger, instanceManager: instanceManager);
    AndroidCameraXCameraFlutterApis.instance.ensureSetUp();
  }

  late final _MeteringPointHostApiImpl _api;

  /// somethin
  final double x;

  /// somethin
  final double y;

  /// somethin
  final double? size;

  /// something
  static Future<double> getDefaultPointSize(
      {BinaryMessenger? binaryMessenger}) {
    final MeteringPointHostApi hostApi =
        MeteringPointHostApi(binaryMessenger: binaryMessenger);
    return hostApi.getDefaultPointSize();
  }
}

/// Host API implementation of [MeteringPoint].
class _MeteringPointHostApiImpl extends MeteringPointHostApi {
  /// Constructs a [FocusMeteringActionHostApiImpl].
  ///
  /// If [binaryMessenger] is null, the default [BinaryMessenger] will be used,
  /// which routes to the host platform.
  ///
  /// An [instanceManager] is typically passed when a copy of an instance
  /// contained by an [InstanceManager] is being created. If left null, it
  /// will default to the global instance defined in [JavaObject].
  _MeteringPointHostApiImpl(
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

  Future<void> createFromInstance(
      MeteringPoint instance, double x, double y, double? size) {
    int? identifier = instanceManager.getIdentifier(instance);
    identifier ??= instanceManager.addDartCreatedInstance(instance,
        onCopy: (MeteringPoint original) {
      return MeteringPoint.detached(
          binaryMessenger: binaryMessenger,
          instanceManager: instanceManager,
          x: original.x,
          y: original.y,
          size: original.size);
    });

    return create(identifier, x, y, size);
  }
}
