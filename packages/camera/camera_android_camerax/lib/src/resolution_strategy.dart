// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/services.dart';
import 'package:meta/meta.dart' show immutable;

import 'camerax_library.g.dart';
import 'instance_manager.dart';
import 'java_object.dart';

/// The resolution strategy defines the resolution selection sequence to select
/// the best size.
///
/// See https://developer.android.com/reference/androidx/camera/core/resolutionselector/ResolutionStrategy.
@immutable
class ResolutionStrategy extends JavaObject {
  /// Constructs a [ResolutionStrategy].
  ResolutionStrategy({
    required Size this.boundSize,
    this.fallbackRule,
    super.binaryMessenger,
    super.instanceManager,
  })  : _api = _ResolutionStrategyHostApiImpl(
          instanceManager: instanceManager,
          binaryMessenger: binaryMessenger,
        ),
        super.detached() {
    _api.createFromInstances(this, boundSize, fallbackRule);
  }

  /// Constructs a [ResolutionStrategy] that represents the strategy that
  /// chooses the highest available resolution.
  ///
  /// See https://developer.android.com/reference/androidx/camera/core/resolutionselector/ResolutionStrategy#HIGHEST_AVAILABLE_STRATEGY().
  ResolutionStrategy.highestAvailableStrategy({
    super.binaryMessenger,
    super.instanceManager,
  })  : _api = _ResolutionStrategyHostApiImpl(
          instanceManager: instanceManager,
          binaryMessenger: binaryMessenger,
        ),
        boundSize = null,
        fallbackRule = null,
        super.detached() {
    _api.createFromInstances(this, boundSize, fallbackRule);
  }

  /// Instantiates a [ResolutionStrategy] without creating and attaching to an
  /// instance of the associated native class.
  ///
  /// This should only be used outside of tests by subclasses created by this
  /// library or to create a copy for an [InstanceManager].
  ResolutionStrategy.detached({
    required this.boundSize,
    this.fallbackRule,
    super.binaryMessenger,
    super.instanceManager,
  })  : _api = _ResolutionStrategyHostApiImpl(
          instanceManager: instanceManager,
          binaryMessenger: binaryMessenger,
        ),
        super.detached();

  /// Instantiates a [ResolutionStrategy] that represents the strategy that
  /// chooses the highest available resolution without creating and attaching to
  /// an instance of the associated native class.
  ///
  /// This should only be used outside of tests by subclasses created by this
  /// library or to create a copy for an [InstanceManager].
  ResolutionStrategy.detachedHighestAvailableStrategy({
    super.binaryMessenger,
    super.instanceManager,
  })  : _api = _ResolutionStrategyHostApiImpl(
          instanceManager: instanceManager,
          binaryMessenger: binaryMessenger,
        ),
        boundSize = null,
        fallbackRule = null,
        super.detached();

  /// CameraX doesn't select an alternate size when the specified bound size is
  /// unavailable.
  ///
  /// Applications will receive [PlatformException] when binding the [UseCase]s
  /// with this fallback rule if the device doesn't support the specified bound
  /// size.
  ///
  /// See https://developer.android.com/reference/androidx/camera/core/resolutionselector/ResolutionStrategy#FALLBACK_RULE_NONE().
  static const int fallbackRuleNone = 0;

  /// When the specified bound size is unavailable, CameraX falls back to select
  /// the closest higher resolution size.
  ///
  /// See https://developer.android.com/reference/androidx/camera/core/resolutionselector/ResolutionStrategy#FALLBACK_RULE_CLOSEST_HIGHER_THEN_LOWER().
  static const int fallbackRuleClosestHigherThenLower = 1;

  /// When the specified bound size is unavailable, CameraX falls back to the
  /// closest higher resolution size.
  ///
  /// If CameraX still cannot find any available resolution, it will fallback to
  /// select other lower resolutions.
  ///
  /// See https://developer.android.com/reference/androidx/camera/core/resolutionselector/ResolutionStrategy#FALLBACK_RULE_CLOSEST_HIGHER().
  static const int fallbackRuleClosestHigher = 2;

  /// When the specified bound size is unavailable, CameraX falls back to select
  /// the closest lower resolution size.
  ///
  /// If CameraX still cannot find any available resolution, it will fallback to
  /// select other higher resolutions.
  ///
  /// See https://developer.android.com/reference/androidx/camera/core/resolutionselector/ResolutionStrategy#FALLBACK_RULE_CLOSEST_LOWER_THEN_HIGHER().
  static const int fallbackRuleClosestLowerThenHigher = 3;

  /// When the specified bound size is unavailable, CameraX falls back to the
  /// closest lower resolution size.
  ///
  /// See https://developer.android.com/reference/androidx/camera/core/resolutionselector/ResolutionStrategy#FALLBACK_RULE_CLOSEST_LOWER().
  static const int fallbackRuleClosestLower = 4;

  final _ResolutionStrategyHostApiImpl _api;

  /// The specified bound size for the desired resolution of the camera.
  ///
  /// If left null, [fallbackRule] must also be left null in order to create a
  /// valid [ResolutionStrategy]. This will create the [ResolutionStrategy]
  /// that chooses the highest available resolution, which can also be retrieved
  /// by calling [getHighestAvailableStrategy].
  final Size? boundSize;

  /// The fallback rule for choosing an alternate size when the specified bound
  /// size is unavailable.
  ///
  /// Must be left null if [boundSize] is specified as null. This will create
  /// the [ResolutionStrategy] that chooses the highest available resolution,
  /// which can also be retrieved by calling [getHighestAvailableStrategy].
  final int? fallbackRule;
}

/// Host API implementation of [ResolutionStrategy].
class _ResolutionStrategyHostApiImpl extends ResolutionStrategyHostApi {
  /// Constructs an [_ResolutionStrategyHostApiImpl].
  ///
  /// If [binaryMessenger] is null, the default [BinaryMessenger] will be used,
  /// which routes to the host platform.
  ///
  /// An [instanceManager] is typically passed when a copy of an instance
  /// contained by an [InstanceManager] is being created. If left null, it
  /// will default to the global instance defined in [JavaObject].
  _ResolutionStrategyHostApiImpl({
    this.binaryMessenger,
    InstanceManager? instanceManager,
  })  : instanceManager = instanceManager ?? JavaObject.globalInstanceManager,
        super(binaryMessenger: binaryMessenger);

  /// Receives binary data across the Flutter platform barrier.
  final BinaryMessenger? binaryMessenger;

  /// Maintains instances stored to communicate with native language objects.
  final InstanceManager instanceManager;

  /// Creates a [ResolutionStrategy] on the native side with the bound [Size]
  /// and fallback rule, if specified.
  Future<void> createFromInstances(
    ResolutionStrategy instance,
    Size? boundSize,
    int? fallbackRule,
  ) {
    return create(
      instanceManager.addDartCreatedInstance(
        instance,
        onCopy: (ResolutionStrategy original) => ResolutionStrategy.detached(
          boundSize: original.boundSize,
          fallbackRule: original.fallbackRule,
          binaryMessenger: binaryMessenger,
          instanceManager: instanceManager,
        ),
      ),
      boundSize == null
          ? null
          : ResolutionInfo(
              width: boundSize.width.toInt(),
              height: boundSize.height.toInt(),
            ),
      fallbackRule,
    );
  }
}
