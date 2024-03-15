// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/services.dart' show BinaryMessenger;
import 'package:meta/meta.dart' show immutable, protected;

import 'android_camera_camerax_flutter_api_impls.dart';
import 'camerax_library.g.dart';
import 'instance_manager.dart';
import 'java_object.dart';

/// Wrapper of callback for applications to filter out unsuitable sizes and sort
/// the resolution list in the preferrede order.
///
/// See https://developer.android.com/reference/androidx/camera/core/resolutionselector/ResolutionFilter.
@immutable
class ResolutionFilter extends JavaObject {
  /// Creates an [ResolutionFilter].
  ResolutionFilter(
      {BinaryMessenger? binaryMessenger,
      InstanceManager? instanceManager,
      required this.filter})
      : super.detached(
            binaryMessenger: binaryMessenger,
            instanceManager: instanceManager) {
    _api = _ResolutionFilterHostApiImpl(
        binaryMessenger: binaryMessenger, instanceManager: instanceManager);
    _api.createFromInstances(this);
    AndroidCameraXCameraFlutterApis.instance.ensureSetUp();
  }

  /// Constructs a [ResolutionFilter] that is not automatically attached to a native object.
  ResolutionFilter.detached(
      {BinaryMessenger? binaryMessenger,
      InstanceManager? instanceManager,
      required this.filter})
      : super.detached(
            binaryMessenger: binaryMessenger,
            instanceManager: instanceManager) {
    _api = _ResolutionFilterHostApiImpl(
        binaryMessenger: binaryMessenger, instanceManager: instanceManager);
    AndroidCameraXCameraFlutterApis.instance.ensureSetUp();
  }

  late final _ResolutionFilterHostApiImpl _api;

  /// Removes unsuitable sizes and sorts the resolution list in the preferred
  /// order.
  ///
  /// OEM's may make the width or height of the supported output sizes be mod 16
  /// aligned for performance reasons,e.g. supporting 1920x1088 instead of
  /// 1920x1080, so input supported sizes list also contains these aspect ratio.
  final List<ResolutionInfo> Function(
      List<ResolutionInfo?> supportedSizes, int rotationDegrees) filter;

  /// Sets the required synchronous return value for the Java method,
  /// `ResolutionFilter.filter`.
  // Future<void> setSynchronousReturnValueForFilter(
  //     List<ResolutionInfo> filteredResolutions) {
  //   return _api.setSynchronousReturnValueFromFilterForInstance(
  //       this, filteredResolutions);
  // }
}

/// Host API implementation of [ResolutionFilter].
class _ResolutionFilterHostApiImpl extends ResolutionFilterHostApi {
  _ResolutionFilterHostApiImpl({
    this.binaryMessenger,
    InstanceManager? instanceManager,
  })  : instanceManager = instanceManager ?? JavaObject.globalInstanceManager,
        super(binaryMessenger: binaryMessenger);

  final BinaryMessenger? binaryMessenger;

  final InstanceManager instanceManager;

  /// Creates an [ResolutionFilter] instance on the native side.
  Future<void> createFromInstances(
    ResolutionFilter instance,
  ) {
    return create(
      instanceManager.addDartCreatedInstance(
        instance,
        onCopy: (ResolutionFilter original) => ResolutionFilter.detached(
          filter: original.filter,
          binaryMessenger: binaryMessenger,
          instanceManager: instanceManager,
        ),
      ),
    );
  }

  // Future<void> setSynchronousReturnValueFromFilterForInstance(
  //     ResolutionFilter instance, List<ResolutionInfo> filteredResolutions) {
  //   return setSynchronousReturnValueForFilter(
  //       instanceManager.getIdentifier(instance)!, filteredResolutions);
  // }
}

/// Flutter API implementation for [ResolutionFilter].
///
/// This class may handle instantiating and adding Dart instances that are
/// attached to a native instance or receiving callback methods from an
/// overridden native class.
@protected
class ResolutionFilterFlutterApiImpl implements ResolutionFilterFlutterApi {
  /// Constructs a [ResolutionFilterFlutterApiImpl].
  ///
  /// If [binaryMessenger] is null, the default [BinaryMessenger] will be used,
  /// which routes to the host platform.
  ///
  /// An [instanceManager] is typically passed when a copy of an instance
  /// contained by an [InstanceManager] is being created. If left null, it
  /// will default to the global instance defined in [JavaObject].
  ResolutionFilterFlutterApiImpl({
    InstanceManager? instanceManager,
  }) : _instanceManager = instanceManager ?? JavaObject.globalInstanceManager;

  /// Maintains instances stored to communicate with native language objects.
  final InstanceManager _instanceManager;
  @override
  List<ResolutionInfo?> filter(int identifier,
      List<ResolutionInfo?> supportedSizes, int rotationDegrees) {
    final ResolutionFilter instance =
        _instanceManager.getInstanceWithWeakReference(identifier)!;
    return instance.filter(
      supportedSizes,
      rotationDegrees,
    );
  }
}
