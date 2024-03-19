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
    required this.meteringPointInfos,
    this.disableAutoCancel,
  }) : super.detached(
          binaryMessenger: binaryMessenger,
          instanceManager: instanceManager,
        ) {
    _api = _FocusMeteringActionHostApiImpl(
        binaryMessenger: binaryMessenger, instanceManager: instanceManager);
    _api.createFromInstance(this, meteringPointInfos, disableAutoCancel);
  }

  /// Creates a [FocusMeteringAction] that is not automatically attached to a
  /// native object.
  FocusMeteringAction.detached({
    BinaryMessenger? binaryMessenger,
    InstanceManager? instanceManager,
    required this.meteringPointInfos,
    this.disableAutoCancel,
  }) : super.detached(
          binaryMessenger: binaryMessenger,
          instanceManager: instanceManager,
        ) {
    _api = _FocusMeteringActionHostApiImpl(
        binaryMessenger: binaryMessenger, instanceManager: instanceManager);
  }

  late final _FocusMeteringActionHostApiImpl _api;

  /// The requested [MeteringPoint]s and modes that are relevant to each of those
  /// points.
  final List<(MeteringPoint meteringPoint, int? meteringMode)>
      meteringPointInfos;

  /// Disables the auto-cancel.
  ///
  /// By default (and if set to false), auto-cancel is enabled with 5 seconds
  /// duration.
  final bool? disableAutoCancel;

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
      List<(MeteringPoint meteringPoint, int? meteringMode)> meteringPointInfos,
      bool? disableAutoCancel) {
    final int identifier = instanceManager.addDartCreatedInstance(instance,
        onCopy: (FocusMeteringAction original) {
      return FocusMeteringAction.detached(
          binaryMessenger: binaryMessenger,
          instanceManager: instanceManager,
          meteringPointInfos: original.meteringPointInfos);
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

    create(identifier, meteringPointInfosWithIds, disableAutoCancel);
  }
}
