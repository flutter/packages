// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

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
      {super.binaryMessenger,
      super.instanceManager,
      required this.buffer,
      required this.pixelStride,
      required this.rowStride})
      : super.detached() {
    AndroidCameraXCameraFlutterApis.instance.ensureSetUp();
  }

  /// Returns the pixels buffer containing frame data.
  final Uint8List buffer;

  /// Returns the pixel stride, the distance between adjacent pixel samples, in
  /// bytes.
  final int pixelStride;

  /// Returns the row stride, the distance between the start of two consecutive
  /// rows of pixels in the image, in bytes.
  final int rowStride;
}

/// Flutter API implementation for [PlaneProxy].
///
/// This class may handle instantiating and adding Dart instances that are
/// attached to a native instance or receiving callback methods from an
/// overridden native class.
@protected
class PlaneProxyFlutterApiImpl implements PlaneProxyFlutterApi {
  /// Constructs an [PlaneProxyFlutterApiImpl].
  ///
  /// If [binaryMessenger] is null, the default [BinaryMessenger] will be used,
  /// which routes to the host platform.
  ///
  /// An [instanceManager] is typically passed when a copy of an instance
  /// contained by an [InstanceManager] is being created. If left null, it
  /// will default to the global instance defined in [JavaObject].
  PlaneProxyFlutterApiImpl({
    BinaryMessenger? binaryMessenger,
    InstanceManager? instanceManager,
  })  : _binaryMessenger = binaryMessenger,
        _instanceManager = instanceManager ?? JavaObject.globalInstanceManager;

  /// Receives binary data across the Flutter platform barrier.
  final BinaryMessenger? _binaryMessenger;

  /// Maintains instances stored to communicate with native language objects.
  final InstanceManager _instanceManager;

  @override
  void create(
    int identifier,
    Uint8List buffer,
    int pixelStride,
    int rowStride,
  ) {
    _instanceManager.addHostCreatedInstance(
      PlaneProxy.detached(
        binaryMessenger: _binaryMessenger,
        instanceManager: _instanceManager,
        buffer: buffer,
        pixelStride: pixelStride,
        rowStride: rowStride,
      ),
      identifier,
      onCopy: (PlaneProxy original) => PlaneProxy.detached(
          binaryMessenger: _binaryMessenger,
          instanceManager: _instanceManager,
          buffer: buffer,
          pixelStride: pixelStride,
          rowStride: rowStride),
    );
  }
}
