// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/services.dart';
import 'package:meta/meta.dart' show immutable;

import 'camera_info.dart';
import 'camerax_library.g.dart';
import 'fallback_strategy.dart';
import 'instance_manager.dart';
import 'java_object.dart';

/// Quality setting used to configure components with quality setting
/// requirements such as creating a Recorder.
@immutable
class QualitySelector extends JavaObject {
  /// to do
  QualitySelector.from(
      {BinaryMessenger? binaryMessenger,
      InstanceManager? instanceManager,
      required QualityConstraint quality,
      this.fallbackStrategy})
      : qualityList = <QualityConstraint>[quality],
        super.detached(
            binaryMessenger: binaryMessenger,
            instanceManager: instanceManager) {
    _api = _QualitySelectorHostApiImpl(
        binaryMessenger: binaryMessenger, instanceManager: instanceManager);
    _api.createFromInstance(this, qualityList, fallbackStrategy);
  }

  /// to do
  QualitySelector.fromOrderedList(
      {BinaryMessenger? binaryMessenger,
      InstanceManager? instanceManager,
      required this.qualityList,
      this.fallbackStrategy})
      : super.detached(
            binaryMessenger: binaryMessenger,
            instanceManager: instanceManager) {
    _api = _QualitySelectorHostApiImpl(
        binaryMessenger: binaryMessenger, instanceManager: instanceManager);
    _api.createFromInstance(this, qualityList, fallbackStrategy);
  }

  /// Creates a [QualitySelector] that is not automatically attached to a
  /// native object.
  QualitySelector.detached({
    super.binaryMessenger,
    super.instanceManager,
    required this.qualityList,
    this.fallbackStrategy,
  }) : super.detached();

  late final _QualitySelectorHostApiImpl _api;

  /// to do
  final List<QualityConstraint> qualityList;

  /// to do
  final FallbackStrategy? fallbackStrategy;

  /// to do
  static Future<ResolutionInfo> getResolution(
      CameraInfo cameraInfo, QualityConstraint quality,
      {BinaryMessenger? binaryMessenger, InstanceManager? instanceManager}) {
    final _QualitySelectorHostApiImpl api = _QualitySelectorHostApiImpl(
        binaryMessenger: binaryMessenger, instanceManager: instanceManager);
    return api.getResolutionFromInstance(cameraInfo, quality);
  }
}

/// Host API implementation of [QualitySelector].
class _QualitySelectorHostApiImpl extends QualitySelectorHostApi {
  /// Constructs a [QualitySelectorHostApiImpl].
  ///
  /// If [binaryMessenger] is null, the default [BinaryMessenger] will be used,
  /// which routes to the host platform.
  ///
  /// An [instanceManager] is typically passed when a copy of an instance
  /// contained by an [InstanceManager] is being created. If left null, it
  /// will default to the global instance defined in [JavaObject].
  _QualitySelectorHostApiImpl(
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

  /// Creates an [QualitySelector] instance with the...
  void createFromInstance(QualitySelector instance,
      List<QualityConstraint> qualityList, FallbackStrategy? fallbackStrategy) {
    final int identifier = instanceManager.addDartCreatedInstance(instance,
        onCopy: (QualitySelector original) {
      return QualitySelector.detached(
        binaryMessenger: binaryMessenger,
        instanceManager: instanceManager,
        qualityList: original.qualityList,
        fallbackStrategy: original.fallbackStrategy,
      );
    });
    final List<int> qualityIndices = qualityList
        .map<int>((QualityConstraint quality) => quality.index)
        .toList();

    create(
        identifier,
        qualityIndices,
        fallbackStrategy == null
            ? null
            : instanceManager.getIdentifier(fallbackStrategy));
  }

  /// to do
  Future<ResolutionInfo> getResolutionFromInstance(
      CameraInfo cameraInfo, QualityConstraint quality) async {
    final int? cameraInfoIdentifier = instanceManager.getIdentifier(cameraInfo);
    final ResolutionInfo resolution =
        await getResolution(cameraInfoIdentifier!, quality);
    return resolution;
  }
}
