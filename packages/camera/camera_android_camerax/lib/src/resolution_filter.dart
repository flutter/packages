// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/services.dart';
import 'package:meta/meta.dart' show immutable;

import 'camerax_library.g.dart';
import 'instance_manager.dart';
import 'java_object.dart';

/// Filter/sorter for applications to specify preferred resolutions.
///
/// This is an indirect wrapping of the native Android `ResolutionFilter`,
/// which is an interface that requires a synchronous response, which is not
/// possible through pigeon. Thus, constructing a [ResolutionFilter] will create
/// a native `ResolutionFilter` with the characteristics as described below. If
/// these constructors do not meet your needs, feel free to add a new
/// constructor; see CONTRIBUTING.MD for more information on how to do so.
///
/// See https://developer.android.com/reference/androidx/camera/core/ResolutionFilter/ResolutionFilter.
@immutable
class ResolutionFilter extends JavaObject {
  /// Construct a [ResolutionFilter].
  ///
  /// Because this is an indirect wrapping of the native `ResolutionFilter`,
  /// this will construct a filter that will only prioritize the specified
  /// [preferredResolution] over the other resolutions, whose order of
  /// preference (according to CameraX) will remain the same.
  ResolutionFilter.onePreferredSize({
    required this.preferredResolution,
    super.binaryMessenger,
    super.instanceManager,
  })  : _api = _ResolutionFilterHostApiImpl(
          instanceManager: instanceManager,
          binaryMessenger: binaryMessenger,
        ),
        super.detached() {
    _api.createWithOnePreferredSizeFromInstances(this, preferredResolution);
  }

  /// Instantiates a [ResolutionFilter.onePreferredSize] that is not
  /// automatically attached to a native object.
  ResolutionFilter.onePreferredSizeDetached({
    required this.preferredResolution,
    super.binaryMessenger,
    super.instanceManager,
  })  : _api = _ResolutionFilterHostApiImpl(
          instanceManager: instanceManager,
          binaryMessenger: binaryMessenger,
        ),
        super.detached();

  final _ResolutionFilterHostApiImpl _api;

  /// The resolution for the filter to prioritize.
  final Size preferredResolution;
}

/// Host API implementation of [ResolutionFilter].
class _ResolutionFilterHostApiImpl extends ResolutionFilterHostApi {
  /// Constructs an [_ResolutionFilterHostApiImpl].
  ///
  /// If [binaryMessenger] is null, the default [BinaryMessenger] will be used,
  /// which routes to the host platform.
  ///
  /// An [instanceManager] is typically passed when a copy of an instance
  /// contained by an [InstanceManager] is being created. If left null, it
  /// will default to the global instance defined in [JavaObject].
  _ResolutionFilterHostApiImpl({
    this.binaryMessenger,
    InstanceManager? instanceManager,
  })  : instanceManager = instanceManager ?? JavaObject.globalInstanceManager,
        super(binaryMessenger: binaryMessenger);

  /// Receives binary data across the Flutter platform barrier.
  final BinaryMessenger? binaryMessenger;

  /// Maintains instances stored to communicate with native language objects.
  final InstanceManager instanceManager;

  /// Creates a [ResolutionFilter] on the native side that will prioritize
  /// the specified [preferredResolution].
  Future<void> createWithOnePreferredSizeFromInstances(
    ResolutionFilter instance,
    Size preferredResolution,
  ) {
    return createWithOnePreferredSize(
      instanceManager.addDartCreatedInstance(
        instance,
        onCopy: (ResolutionFilter original) =>
            ResolutionFilter.onePreferredSizeDetached(
          preferredResolution: original.preferredResolution,
          binaryMessenger: binaryMessenger,
          instanceManager: instanceManager,
        ),
      ),
      ResolutionInfo(
        width: preferredResolution.width.toInt(),
        height: preferredResolution.height.toInt(),
      ),
    );
  }
}
