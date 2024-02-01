// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/services.dart' show BinaryMessenger;
import 'package:meta/meta.dart' show immutable;

import 'camerax_library.g.dart';
import 'instance_manager.dart';
import 'java_object.dart';
import 'metering_point.dart';

/// A configuration used to trigger a focus and/or metering action.
///
/// See https://developer.android.com/reference/androidx/camera/core/FocusMeteringAction.
@immutable
class FocusMeteringAction extends JavaObject {
  /// Creates a [FocusMeteringAction].
  FocusMeteringAction({
    BinaryMessenger? binaryMessenger,
    InstanceManager? instanceManager,
    required List<(MeteringPoint meteringPoint, int? meteringMode)>
        meteringPointInfos,
  }) : super.detached(
          binaryMessenger: binaryMessenger,
          instanceManager: instanceManager,
        ) {
    _api = _FocusMeteringActionHostApiImpl(
        binaryMessenger: binaryMessenger, instanceManager: instanceManager);
    _api.createFromInstance(this, meteringPointInfos);
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

  /// Flag for metering mode that indicates the auto focus region is enabled.
  ///
  /// An autofocus scan is also triggered when [flagAf] is assigned.
  ///
  /// See https://developer.android.com/reference/androidx/camera/core/FocusMeteringAction#FLAG_AF().
  static const int flagAf = 1;

  /// Flag for metering mode that indicates the auto exposure region is enabled.
  ///
  /// See https://developer.android.com/reference/androidx/camera/core/FocusMeteringAction#FLAG_AE().
  static const int flagAe = 2;

  /// Flag for metering mode that indicates the auto white balance region is
  /// enabled.
  ///
  /// See https://developer.android.com/reference/androidx/camera/core/FocusMeteringAction#FLAG_AWB().
  static const int flagAwb = 4;
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

  /// Creates a [FocusMeteringAction] instance with the specified list of
  /// [MeteringPoint]s and their modes in order of descending priority.
  void createFromInstance(
      FocusMeteringAction instance,
      List<(MeteringPoint meteringPoint, int? meteringMode)>
          meteringPointInfos) {
    final int identifier = instanceManager.addDartCreatedInstance(instance,
        onCopy: (FocusMeteringAction original) {
      return FocusMeteringAction.detached(
          binaryMessenger: binaryMessenger, instanceManager: instanceManager);
    });

    final List<MeteringPointInfo> meteringPointInfosWithIds =
        <MeteringPointInfo>[];
    for (final (
      MeteringPoint meteringPoint,
      int? meteringMode
    ) meteringPointInfo in meteringPointInfos) {
      meteringPointInfosWithIds.add(MeteringPointInfo(
          meteringPointId: instanceManager.getIdentifier(meteringPointInfo.$1)!,
          meteringMode: meteringPointInfo.$2));
    }

    create(identifier, meteringPointInfosWithIds);
  }
}
