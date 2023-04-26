// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/services.dart';

import 'aspect_ratio_strategy.dart';
import 'camerax_library.g.dart';
import 'instance_manager.dart';
import 'java_object.dart';
import 'resolution_strategy.dart';

/// A set of requirements and priorities used to select a resolution for the
/// UseCase.
///
/// See https://developer.android.com/reference/androidx/camera/core/resolutionselector/ResolutionSelector.
class ResolutionSelector extends JavaObject {
  /// Construct a [ResolutionSelector].
  ResolutionSelector({
    this.resolutionStrategy,
    this.aspectRatioStrategy,
    super.binaryMessenger,
    super.instanceManager,
  })  : _api = _ResolutionSelectorHostApiImpl(
          instanceManager: instanceManager,
          binaryMessenger: binaryMessenger,
        ),
        super.detached() {
    _api.createFromInstances(this, resolutionStrategy, aspectRatioStrategy);
  }

  /// Instantiates a [ResolutionSelector] without creating and attaching to an
  /// instance of the associated native class.
  ///
  /// This should only be used outside of tests by subclasses created by this
  /// library or to create a copy for an [InstanceManager].
  ResolutionSelector.detached({
    this.resolutionStrategy,
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

  /// Determines how the UseCase will choose the aspect ratio of the captured
  /// image.
  final AspectRatioStrategy? aspectRatioStrategy;
}

class _ResolutionSelectorHostApiImpl extends ResolutionSelectorHostApi {
  _ResolutionSelectorHostApiImpl({
    this.binaryMessenger,
    InstanceManager? instanceManager,
  })  : instanceManager = instanceManager ?? JavaObject.globalInstanceManager,
        super(binaryMessenger: binaryMessenger);

  final BinaryMessenger? binaryMessenger;

  final InstanceManager instanceManager;

  Future<void> createFromInstances(
    ResolutionSelector instance,
    ResolutionStrategy? resolutionStrategy,
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
      aspectRatioStrategy == null
          ? null
          : instanceManager.getIdentifier(aspectRatioStrategy)!,
    );
  }
}
