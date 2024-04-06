// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/services.dart';
import 'package:meta/meta.dart' show immutable;

import 'aspect_ratio_strategy.dart';
import 'camerax_library.g.dart';
import 'instance_manager.dart';
import 'java_object.dart';
import 'resolution_filter.dart';
import 'resolution_strategy.dart';

/// A set of requirements and priorities used to select a resolution for a
/// UseCase.
///
/// See https://developer.android.com/reference/androidx/camera/core/resolutionselector/ResolutionSelector.
@immutable
class ResolutionSelector extends JavaObject {
  /// Construct a [ResolutionSelector].
  ResolutionSelector({
    this.resolutionStrategy,
    this.resolutionFilter,
    this.aspectRatioStrategy,
    super.binaryMessenger,
    super.instanceManager,
  })  : _api = _ResolutionSelectorHostApiImpl(
          instanceManager: instanceManager,
          binaryMessenger: binaryMessenger,
        ),
        super.detached() {
    _api.createFromInstances(
        this, resolutionStrategy, resolutionFilter, aspectRatioStrategy);
  }

  /// Instantiates a [ResolutionSelector] without creating and attaching to an
  /// instance of the associated native class.
  ///
  /// This should only be used outside of tests by subclasses created by this
  /// library or to create a copy for an [InstanceManager].
  ResolutionSelector.detached({
    this.resolutionStrategy,
    this.resolutionFilter,
    this.aspectRatioStrategy,
    super.binaryMessenger,
    super.instanceManager,
  })  : _api = _ResolutionSelectorHostApiImpl(
          instanceManager: instanceManager,
          binaryMessenger: binaryMessenger,
        ),
        super.detached();

  final _ResolutionSelectorHostApiImpl _api;

  /// Determines how the UseCase will choose the resolution of the captured
  /// image.
  final ResolutionStrategy? resolutionStrategy;

  /// Filter for CameraX to automatically select a desirable resolution.
  final ResolutionFilter? resolutionFilter;

  /// Determines how the UseCase will choose the aspect ratio of the captured
  /// image.
  final AspectRatioStrategy? aspectRatioStrategy;
}

/// Host API implementation of [ResolutionSelector].
class _ResolutionSelectorHostApiImpl extends ResolutionSelectorHostApi {
  /// Constructs an [_ResolutionSelectorHostApiImpl].
  ///
  /// If [binaryMessenger] is null, the default [BinaryMessenger] will be used,
  /// which routes to the host platform.
  ///
  /// An [instanceManager] is typically passed when a copy of an instance
  /// contained by an [InstanceManager] is being created. If left null, it
  /// will default to the global instance defined in [JavaObject].
  _ResolutionSelectorHostApiImpl({
    this.binaryMessenger,
    InstanceManager? instanceManager,
  })  : instanceManager = instanceManager ?? JavaObject.globalInstanceManager,
        super(binaryMessenger: binaryMessenger);

  /// Receives binary data across the Flutter platform barrier.
  final BinaryMessenger? binaryMessenger;

  /// Maintains instances stored to communicate with native language objects.
  final InstanceManager instanceManager;

  /// Creates a [ResolutionSelector] on the native side with the
  /// [ResolutionStrategy], [ResolutionFilter], and [AspectRatioStrategy] if
  /// specified.
  Future<void> createFromInstances(
    ResolutionSelector instance,
    ResolutionStrategy? resolutionStrategy,
    ResolutionFilter? resolutionFilter,
    AspectRatioStrategy? aspectRatioStrategy,
  ) {
    return create(
      instanceManager.addDartCreatedInstance(
        instance,
        onCopy: (ResolutionSelector original) => ResolutionSelector.detached(
          resolutionStrategy: original.resolutionStrategy,
          aspectRatioStrategy: original.aspectRatioStrategy,
          binaryMessenger: binaryMessenger,
          instanceManager: instanceManager,
        ),
      ),
      resolutionStrategy == null
          ? null
          : instanceManager.getIdentifier(resolutionStrategy)!,
      resolutionFilter == null
          ? null
          : instanceManager.getIdentifier(resolutionFilter)!,
      aspectRatioStrategy == null
          ? null
          : instanceManager.getIdentifier(aspectRatioStrategy)!,
    );
  }
}
