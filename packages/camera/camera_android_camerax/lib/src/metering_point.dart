// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/services.dart' show BinaryMessenger;
import 'package:meta/meta.dart' show immutable;

import 'android_camera_camerax_flutter_api_impls.dart';
import 'camera_info.dart';
import 'camerax_library.g.dart';
import 'instance_manager.dart';
import 'java_object.dart';

/// Representation for a region which can be converted to sensor coordinate
/// system for focus and metering purpose.
///
/// See https://developer.android.com/reference/androidx/camera/core/MeteringPoint.
@immutable
class MeteringPoint extends JavaObject {
  /// Creates a [MeteringPoint].
  MeteringPoint({
    BinaryMessenger? binaryMessenger,
    InstanceManager? instanceManager,
    required this.x,
    required this.y,
    this.size,
    required this.cameraInfo,
  }) : super.detached(
          binaryMessenger: binaryMessenger,
          instanceManager: instanceManager,
        ) {
    _api = _MeteringPointHostApiImpl(
        binaryMessenger: binaryMessenger, instanceManager: instanceManager);
    _api.createFromInstance(this, x, y, size, cameraInfo);
    AndroidCameraXCameraFlutterApis.instance.ensureSetUp();
  }

  /// Creates a [MeteringPoint] that is not automatically attached to a
  /// native object.
  MeteringPoint.detached({
    BinaryMessenger? binaryMessenger,
    InstanceManager? instanceManager,
    required this.x,
    required this.y,
    this.size,
    required this.cameraInfo,
  }) : super.detached(
          binaryMessenger: binaryMessenger,
          instanceManager: instanceManager,
        ) {
    _api = _MeteringPointHostApiImpl(
        binaryMessenger: binaryMessenger, instanceManager: instanceManager);
    AndroidCameraXCameraFlutterApis.instance.ensureSetUp();
  }

  late final _MeteringPointHostApiImpl _api;

  /// X coordinate.
  final double x;

  /// Y coordinate.
  final double y;

  /// The size of the [MeteringPoint] width and height (ranging from 0 to 1),
  /// which is a normalized percentage of the sensor width/height (or crop
  /// region width/height if crop region is set).
  final double? size;

  /// The [CameraInfo] used to construct the metering point with a display-
  /// oriented metering point factory.
  final CameraInfo cameraInfo;

  /// The default size of the [MeteringPoint] width and height (ranging from 0
  /// to 1) which is a (normalized) percentage of the sensor width/height (or
  /// crop region width/height if crop region is set).
  static Future<double> getDefaultPointSize(
      {BinaryMessenger? binaryMessenger}) {
    final MeteringPointHostApi hostApi =
        MeteringPointHostApi(binaryMessenger: binaryMessenger);
    return hostApi.getDefaultPointSize();
  }
}

/// Host API implementation of [MeteringPoint].
class _MeteringPointHostApiImpl extends MeteringPointHostApi {
  /// Constructs a [_MeteringPointHostApiImpl].
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

  /// Creates a [MeteringPoint] instance with the specified [x] and [y]
  /// coordinates as well as [size] if non-null.
  Future<void> createFromInstance(MeteringPoint instance, double x, double y,
      double? size, CameraInfo cameraInfo) {
    int? identifier = instanceManager.getIdentifier(instance);
    identifier ??= instanceManager.addDartCreatedInstance(instance,
        onCopy: (MeteringPoint original) {
      return MeteringPoint.detached(
          binaryMessenger: binaryMessenger,
          instanceManager: instanceManager,
          x: original.x,
          y: original.y,
          cameraInfo: original.cameraInfo,
          size: original.size);
    });
    final int? camInfoId = instanceManager.getIdentifier(cameraInfo);

    return create(identifier, x, y, size, camInfoId!);
  }
}
