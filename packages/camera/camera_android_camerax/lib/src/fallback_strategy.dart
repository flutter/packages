// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/services.dart';
import 'package:meta/meta.dart' show immutable;

import 'camerax_library.g.dart';
import 'instance_manager.dart';
import 'java_object.dart';

/// Strategy that will be adopted when the device in use does not support all
/// of the desired quality specified for a particular QualitySelector instance.
///
/// See https://developer.android.com/reference/androidx/camera/video/FallbackStrategy.
@immutable
class FallbackStrategy extends JavaObject {
  /// Creates a [FallbackStrategy].
  FallbackStrategy(
      {BinaryMessenger? binaryMessenger,
      InstanceManager? instanceManager,
      required this.quality,
      required this.fallbackRule})
      : super.detached(
            binaryMessenger: binaryMessenger,
            instanceManager: instanceManager) {
    _api = _FallbackStrategyHostApiImpl(
        binaryMessenger: binaryMessenger, instanceManager: instanceManager);
    _api.createFromInstance(this, quality, fallbackRule);
  }

  /// Constructs a [FallbackStrategy] that is not automatically attached to a native object.
  FallbackStrategy.detached(
      {super.binaryMessenger,
      super.instanceManager,
      required this.quality,
      required this.fallbackRule})
      : super.detached();

  late final _FallbackStrategyHostApiImpl _api;

  /// The input quality used to specify this fallback strategy relative to.
  final VideoQuality quality;

  /// The fallback rule that this strategy will follow.
  final VideoResolutionFallbackRule fallbackRule;
}

/// Host API implementation of [FallbackStrategy].
class _FallbackStrategyHostApiImpl extends FallbackStrategyHostApi {
  /// Constructs a [FallbackStrategyHostApiImpl].
  ///
  /// If [binaryMessenger] is null, the default [BinaryMessenger] will be used,
  /// which routes to the host platform.
  ///
  /// An [instanceManager] is typically passed when a copy of an instance
  /// contained by an [InstanceManager] is being created. If left null, it
  /// will default to the global instance defined in [JavaObject].
  _FallbackStrategyHostApiImpl(
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

  /// Creates a [FallbackStrategy] instance with the specified video [quality]
  /// and [fallbackRule].
  void createFromInstance(FallbackStrategy instance, VideoQuality quality,
      VideoResolutionFallbackRule fallbackRule) {
    final int identifier = instanceManager.addDartCreatedInstance(instance,
        onCopy: (FallbackStrategy original) {
      return FallbackStrategy.detached(
        binaryMessenger: binaryMessenger,
        instanceManager: instanceManager,
        quality: original.quality,
        fallbackRule: original.fallbackRule,
      );
    });
    create(identifier, quality, fallbackRule);
  }
}
