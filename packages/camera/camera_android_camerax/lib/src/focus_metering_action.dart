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
class FocusMeteringAction extends JavaObject {
  /// Creates a [FocusMeteringAction].
  FocusMeteringAction({
    BinaryMessenger? binaryMessenger,
    InstanceManager? instanceManager,
    required MeteringPoint meteringPoint,
    int? meteringMode,
  }) : super.detached(
          binaryMessenger: binaryMessenger,
          instanceManager: instanceManager,
        ) {
    _api = _FocusMeteringActionHostApiImpl(
        binaryMessenger: binaryMessenger, instanceManager: instanceManager);
    AndroidCameraXCameraFlutterApis.instance.ensureSetUp();
    _api.createFromInstance(this, meteringPoint, meteringMode);
  }

  /// Creates a [FocusMeteringAction] that is not automatically attached to a
  /// native object.
  FocusMeteringAction.detached({
    BinaryMessenger? binaryMessenger,
    InstanceManager? instanceManager,
  }) : super.detached(
          binaryMessenger: binaryMessenger,
          instanceManager: instanceManager,
        ) {
    _api = _FocusMeteringActionHostApiImpl(
        binaryMessenger: binaryMessenger, instanceManager: instanceManager);
  }

  late final _FocusMeteringActionHostApiImpl _api;

  /// Flag for metering mode that indicates the AF (Auto Focus) region is
  /// enabled.
  ///
  /// An autofocus scan is also triggered when FLAG_AF is assigned.
  static const int flagAf = 1;

  /// Flag for metering mode that indicates the AE (Auto Exposure)
  /// region is enabled.
  static const int flagAe = 2;

  /// Flag for metering mode that indicates the AWB (Auto White Balance) region
  /// is enabled.
  static const int flagAwb = 4;

  /// something
  Future<FocusMeteringAction?> addPoint(
      MeteringPoint meteringPoint, int? meteringMode) {
    return _api.addPointFromInstance(this, meteringPoint, meteringMode);
  }
}

/// Host API implementation of [FocusMeteringAction].
class _FocusMeteringActionHostApiImpl extends FocusMeteringActionHostApi {
  /// Constructs a [_FocusMeteringActionHostApiImpl].
  ///
  /// If [binaryMessenger] is null, the default [BinaryMessenger] will be used,
  /// which routes to the host platform.
  ///
  /// An [instanceManager] is typically passed when a copy of an instance
  /// contained by an [InstanceManager] is being created. If left null, it
  /// will default to the global instance defined in [JavaObject].
  _FocusMeteringActionHostApiImpl(
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

  /// Creates an [FocusMeteringAction] instance with the flash mode and target resolution
  /// if specified.
  void createFromInstance(FocusMeteringAction instance,
      MeteringPoint meteringPoint, int? meteringMode) {
    final int identifier = instanceManager.addDartCreatedInstance(instance,
        onCopy: (FocusMeteringAction original) {
      return FocusMeteringAction.detached(
          binaryMessenger: binaryMessenger, instanceManager: instanceManager);
    });
    create(identifier, instanceManager.getIdentifier(meteringPoint)!,
        meteringMode);
  }

  /// something
  Future<FocusMeteringAction?> addPointFromInstance(
      FocusMeteringAction instance,
      MeteringPoint meteringPoint,
      int? meteringMode) async {
    final int identifier = instanceManager.getIdentifier(instance)!;
    final int meteringPointId = instanceManager.getIdentifier(meteringPoint)!;
    final int focusMeteringResultId =
        await addPoint(identifier, meteringPointId, meteringMode);
    return instanceManager.getInstanceWithWeakReference<FocusMeteringAction>(
        focusMeteringResultId);
  }
}

/// Flutter API implementation of [FocusMeteringAction].
class FocusMeteringActionFlutterApiImpl extends FocusMeteringActionFlutterApi {
  /// Constructs a [FocusMeteringActionFlutterApiImpl].
  ///
  /// If [binaryMessenger] is null, the default [BinaryMessenger] will be used,
  /// which routes to the host platform.
  ///
  /// An [instanceManager] is typically passed when a copy of an instance
  /// contained by an [InstanceManager] is being created. If left null, it
  /// will default to the global instance defined in [JavaObject].
  FocusMeteringActionFlutterApiImpl({
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
      FocusMeteringAction.detached(
          binaryMessenger: _binaryMessenger, instanceManager: _instanceManager),
      identifier,
      onCopy: (FocusMeteringAction original) {
        return FocusMeteringAction.detached(
          binaryMessenger: _binaryMessenger,
          instanceManager: _instanceManager,
        );
      },
    );
  }
}
