// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/services.dart' show BinaryMessenger;
import 'package:meta/meta.dart' show protected;

import 'android_camera_camerax_flutter_api_impls.dart';
import 'camerax_library.g.dart';
import 'instance_manager.dart';
import 'java_object.dart';

/// A single color plane of image data.
///
/// See https://developer.android.com/reference/androidx/camera/core/ImageProxy.PlaneProxy.
class PlaneProxy extends JavaObject {
  /// Constructs a [PlaneProxy] that is not automatically attached to a native object.
  PlaneProxy.detached(
      {BinaryMessenger? binaryMessenger, InstanceManager? instanceManager})
      : super.detached(
            binaryMessenger: binaryMessenger,
            instanceManager: instanceManager) {
    _api = _PlaneProxyHostApiImpl(
        binaryMessenger: binaryMessenger, instanceManager: instanceManager);
    AndroidCameraXCameraFlutterApis.instance.ensureSetUp();
  }

  late final _PlaneProxyHostApiImpl _api;

  /// Returns the pixels buffer containing frame data.
  Future<Uint8List> getBuffer() {
    return _api.getBufferfromInstances(this);
  }

  /// Returns the pixel stride, the distance between adjacent pixel samples, in
  /// bytes.
  Future<int> getPixelStride() {
    return _api.getPixelStridefromInstances(this);
  }

  /// Returns the row stride, the distance between the start of two consecutive
  /// rows of pixels in the image, in bytes.
  Future<int> getRowStride() {
    return _api.getRowStridefromInstances(this);
  }
}

/// Host API implementation of [PlaneProxy].
class _PlaneProxyHostApiImpl extends PlaneProxyHostApi {
  _PlaneProxyHostApiImpl({
    this.binaryMessenger,
    InstanceManager? instanceManager,
  })  : instanceManager = instanceManager ?? JavaObject.globalInstanceManager,
        super(binaryMessenger: binaryMessenger);

  final BinaryMessenger? binaryMessenger;

  final InstanceManager instanceManager;

  /// Returns the pixel stride of the [instance].
  Future<int> getPixelStridefromInstances(
    PlaneProxy instance,
  ) {
    return getPixelStride(
      instanceManager.getIdentifier(instance)!,
    );
  }

  /// Returns the pixels buffer of the [instance].
  Future<Uint8List> getBufferfromInstances(
    PlaneProxy instance,
  ) {
    return getBuffer(
      instanceManager.getIdentifier(instance)!,
    );
  }

  /// Returns the row stride of the [instance].
  Future<int> getRowStridefromInstances(
    PlaneProxy instance,
  ) async {
    return getRowStride(
      instanceManager.getIdentifier(instance)!,
    );
  }
}

/// Flutter API implementation for [PlaneProxy].
///
/// This class may handle instantiating and adding Dart instances that are
/// attached to a native instance or receiving callback methods from an
/// overridden native class.
@protected
class PlaneProxyFlutterApiImpl implements PlaneProxyFlutterApi {
  /// Constructs a [PlaneProxyFlutterApiImpl].
  PlaneProxyFlutterApiImpl({
    this.binaryMessenger,
    InstanceManager? instanceManager,
  }) : instanceManager = instanceManager ?? JavaObject.globalInstanceManager;

  /// Receives binary data across the Flutter platform barrier.
  ///
  /// If it is null, the default BinaryMessenger will be used which routes to
  /// the host platform.
  final BinaryMessenger? binaryMessenger;

  /// Maintains instances stored to communicate with native language objects.
  final InstanceManager instanceManager;

  @override
  void create(
    int identifier,
  ) {
    instanceManager.addHostCreatedInstance(
      PlaneProxy.detached(
        binaryMessenger: binaryMessenger,
        instanceManager: instanceManager,
      ),
      identifier,
      onCopy: (PlaneProxy original) => PlaneProxy.detached(
        binaryMessenger: binaryMessenger,
        instanceManager: instanceManager,
      ),
    );
  }
}
