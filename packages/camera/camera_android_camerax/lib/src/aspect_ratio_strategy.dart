// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/services.dart';
import 'package:meta/meta.dart' show immutable;

import 'camerax_library.g.dart';
import 'instance_manager.dart';
import 'java_object.dart';

/// The aspect ratio of a UseCase.
///
/// Aspect ratio is the ratio of width to height.
///
/// See https://developer.android.com/reference/androidx/camera/core/AspectRatio.
class AspectRatio {
  AspectRatio._();

  /// 4:3 standard aspect ratio.
  ///
  /// See https://developer.android.com/reference/androidx/camera/core/AspectRatio#RATIO_4_3().
  static const int ratio4To3 = 0;

  /// 16:9 standard aspect ratio.
  ///
  /// See https://developer.android.com/reference/androidx/camera/core/AspectRatio#RATIO_16_9().
  static const int ratio16To9 = 1;

  /// The aspect ratio representing no preference for aspect ratio.
  ///
  /// See https://developer.android.com/reference/androidx/camera/core/AspectRatio#RATIO_DEFAULT().
  static const int ratioDefault = -1;
}

/// The aspect ratio strategy defines the sequence of aspect ratios that are
/// used to select the best size for a particular image.
///
/// See https://developer.android.com/reference/androidx/camera/core/resolutionselector/AspectRatioStrategy.
@immutable
class AspectRatioStrategy extends JavaObject {
  /// Construct a [AspectRatioStrategy].
  AspectRatioStrategy({
    required this.preferredAspectRatio,
    required this.fallbackRule,
    super.binaryMessenger,
    super.instanceManager,
  })  : _api = _AspectRatioStrategyHostApiImpl(
          instanceManager: instanceManager,
          binaryMessenger: binaryMessenger,
        ),
        super.detached() {
    _api.createFromInstances(this, preferredAspectRatio, fallbackRule);
  }

  /// Instantiates a [AspectRatioStrategy] without creating and attaching to an
  /// instance of the associated native class.
  ///
  /// This should only be used outside of tests by subclasses created by this
  /// library or to create a copy for an [InstanceManager].
  AspectRatioStrategy.detached({
    required this.preferredAspectRatio,
    required this.fallbackRule,
    super.binaryMessenger,
    super.instanceManager,
  })  : _api = _AspectRatioStrategyHostApiImpl(
          instanceManager: instanceManager,
          binaryMessenger: binaryMessenger,
        ),
        super.detached();

  /// CameraX doesn't fall back to select sizes of any other aspect ratio when
  /// this fallback rule is used.
  ///
  /// See https://developer.android.com/reference/androidx/camera/core/resolutionselector/AspectRatioStrategy#FALLBACK_RULE_NONE().
  static const int fallbackRuleNone = 0;

  /// CameraX automatically chooses the next best aspect ratio which contains
  /// the closest field of view (FOV) of the camera sensor, from the remaining
  /// options.
  ///
  /// See https://developer.android.com/reference/androidx/camera/core/resolutionselector/AspectRatioStrategy#FALLBACK_RULE_AUTO().
  static const int fallbackRuleAuto = 1;

  final _AspectRatioStrategyHostApiImpl _api;

  /// The preferred aspect ratio captured by the camera.
  final int preferredAspectRatio;

  /// The specified fallback rule for choosing the aspect ratio when the
  /// preferred aspect ratio is not available.
  final int fallbackRule;
}

/// Host API implementation of [AspectRatioStrategy].
class _AspectRatioStrategyHostApiImpl extends AspectRatioStrategyHostApi {
  /// Constructs an [_AspectRatioStrategyHostApiImpl].
  ///
  /// If [binaryMessenger] is null, the default [BinaryMessenger] will be used,
  /// which routes to the host platform.
  ///
  /// An [instanceManager] is typically passed when a copy of an instance
  /// contained by an [InstanceManager] is being created. If left null, it
  /// will default to the global instance defined in [JavaObject].
  _AspectRatioStrategyHostApiImpl({
    this.binaryMessenger,
    InstanceManager? instanceManager,
  })  : instanceManager = instanceManager ?? JavaObject.globalInstanceManager,
        super(binaryMessenger: binaryMessenger);

  /// Receives binary data across the Flutter platform barrier.
  final BinaryMessenger? binaryMessenger;

  /// Maintains instances stored to communicate with native language objects.
  final InstanceManager instanceManager;

  /// Creates a [AspectRatioStrategy] on the native side with the preferred
  /// aspect ratio and fallback rule specified.
  Future<void> createFromInstances(
    AspectRatioStrategy instance,
    int preferredAspectRatio,
    int fallbackRule,
  ) {
    return create(
      instanceManager.addDartCreatedInstance(
        instance,
        onCopy: (AspectRatioStrategy original) => AspectRatioStrategy.detached(
          preferredAspectRatio: original.preferredAspectRatio,
          fallbackRule: original.fallbackRule,
          binaryMessenger: binaryMessenger,
          instanceManager: instanceManager,
        ),
      ),
      preferredAspectRatio,
      fallbackRule,
    );
  }
}
