// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/services.dart' show BinaryMessenger;
import 'package:meta/meta.dart' show protected;

import 'android_camera_camerax_flutter_api_impls.dart';
import 'camerax_library.g.dart';
import 'instance_manager.dart';
import 'java_object.dart';
import 'plane_proxy.dart';

/// Representation of a single complete image buffer.
///
/// See https://developer.android.com/reference/androidx/camera/core/ImageProxy.
class ImageProxy extends JavaObject {
  /// Constructs a [ImageProxy] that is not automatically attached to a native object.
  ImageProxy.detached(
      {BinaryMessenger? binaryMessenger,
      InstanceManager? instanceManager,
      required this.format,
      required this.height,
      required this.width})
      : super.detached(
            binaryMessenger: binaryMessenger,
            instanceManager: instanceManager) {
    _api = _ImageProxyHostApiImpl(
        binaryMessenger: binaryMessenger, instanceManager: instanceManager);
    AndroidCameraXCameraFlutterApis.instance.ensureSetUp();
  }

  /// The image format.
  final int format;

  /// The image height.
  final int height;

  /// The image width.
  final int width;

  late final _ImageProxyHostApiImpl _api;

  /// Returns the list of color planes of image data.
  Future<List<PlaneProxy>> getPlanes() => _api.getPlanesFromInstances(this);

  /// Closes the underlying image.
  Future<void> close() => _api.closeFromInstances(this);
}

/// Host API implementation of [ImageProxy].
class _ImageProxyHostApiImpl extends ImageProxyHostApi {
  /// Constructor for [_ImageProxyHostApiImpl].
  ///
  /// An [instanceManager] is typically passed when a copy of an instance
  /// contained by an `InstanceManager` is being created.
  _ImageProxyHostApiImpl({
    this.binaryMessenger,
    InstanceManager? instanceManager,
  })  : instanceManager = instanceManager ?? JavaObject.globalInstanceManager,
        super(binaryMessenger: binaryMessenger);

  final BinaryMessenger? binaryMessenger;

  final InstanceManager instanceManager;

  /// Returns the list of color planes of the image data represnted by the
  /// [instance].
  Future<List<PlaneProxy>> getPlanesFromInstances(
    ImageProxy instance,
  ) async {
    final List<int?> planesAsObjects = await getPlanes(
      instanceManager.getIdentifier(instance)!,
    );

    return planesAsObjects.map((int? planeIdentifier) {
      return instanceManager
          .getInstanceWithWeakReference<PlaneProxy>(planeIdentifier!)!;
    }).toList();
  }

  /// Closes the underlying image of the [instance].
  Future<void> closeFromInstances(
    ImageProxy instance,
  ) {
    return close(
      instanceManager.getIdentifier(instance)!,
    );
  }
}

/// Flutter API implementation for [ImageProxy].
///
/// This class may handle instantiating and adding Dart instances that are
/// attached to a native instance or receiving callback methods from an
/// overridden native class.
@protected
class ImageProxyFlutterApiImpl implements ImageProxyFlutterApi {
  /// Constructs a [ImageProxyFlutterApiImpl].
  ///
  /// If [binaryMessenger] is null, the default [BinaryMessenger] will be used,
  /// which routes to the host platform.
  ///
  /// An [instanceManager] is typically passed when a copy of an instance
  /// contained by an [InstanceManager] is being created. If left null, it
  /// will default to the global instance defined in [JavaObject].
  ImageProxyFlutterApiImpl({
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
    int format,
    int height,
    int width,
  ) {
    _instanceManager.addHostCreatedInstance(
      ImageProxy.detached(
        binaryMessenger: _binaryMessenger,
        instanceManager: _instanceManager,
        format: format,
        height: height,
        width: width,
      ),
      identifier,
      onCopy: (ImageProxy original) => ImageProxy.detached(
          binaryMessenger: _binaryMessenger,
          instanceManager: _instanceManager,
          format: original.format,
          height: original.height,
          width: original.width),
    );
  }
}
