// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:camera_platform_interface/camera_platform_interface.dart'
    show CameraImageData, CameraImageFormat, CameraImagePlane, ImageFormatGroup;
import 'package:flutter/services.dart' show BinaryMessenger;
import 'package:meta/meta.dart' show protected;
import 'package:simple_ast/annotations.dart';

import 'android_camera_camerax_flutter_api_impls.dart';
import 'camerax_library.g.dart';
import 'image_proxy_plane_proxy.dart';
import 'instance_manager.dart';
import 'java_object.dart';
import 'use_case.dart';

@SimpleClassAnnotation()
class ImageProxy extends JavaObject {
//   ImageProxyPlaneProxy(
//       {BinaryMessenger? binaryMessenger,
//       InstanceManager? instanceManager})
//       : super.detached(
//             binaryMessenger: binaryMessenger,
//             instanceManager: instanceManager) {
//     _api = ImageProxyPlaneProxyHostApiImpl(
//         binaryMessenger: binaryMessenger, instanceManager: instanceManager);
//     _api.createFromInstance(this);
//     AndroidCameraXCameraFlutterApis.instance.ensureSetUp();
//   }

  ImageProxy.detached(
      {BinaryMessenger? binaryMessenger, InstanceManager? instanceManager})
      : super.detached(
            binaryMessenger: binaryMessenger,
            instanceManager: instanceManager) {
    _api = _ImageProxyHostApiImpl(
        binaryMessenger: binaryMessenger, instanceManager: instanceManager);
    AndroidCameraXCameraFlutterApis.instance.ensureSetUp();
  }

  late final _ImageProxyHostApiImpl _api;

  Future<List<ImageProxyPlaneProxy>> getPlanes() {}

  Future<int> getFormat() {}

  Future<int> getHeight() {}

  Future<int> getWidth() {}

  Future<void> close() {}
}

class _ImageProxyHostApiImpl extends ImageProxyHostApi {
  _ImageProxyHostApiImpl({
    this.binaryMessenger,
    InstanceManager? instanceManager,
  })  : instanceManager = instanceManager ?? JavaObject.globalInstanceManager,
        super(binaryMessenger: binaryMessenger);

  final BinaryMessenger? binaryMessenger;

  final InstanceManager instanceManager;

  Future<List<Object?>> getPlanesFromInstances(
    ImageProxy instance,
  ) {
    return getPlanes(
      instanceManager.getIdentifier(instance)!,
    );
  }

  Future<int> getFormatFromInstances(
    ImageProxy instance,
  ) {
    return getFormat(
      instanceManager.getIdentifier(instance)!,
    );
  }

  Future<int> getHeightFromInstances(
    ImageProxy instance,
  ) {
    return getHeight(
      instanceManager.getIdentifier(instance)!,
    );
  }

  Future<int> getWidthFromInstances(
    ImageProxy instance,
  ) {
    return getWidth(
      instanceManager.getIdentifier(instance)!,
    );
  }

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
  ImageProxyFlutterApiImpl({
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
      ImageProxy.detached(
        binaryMessenger: binaryMessenger,
        instanceManager: instanceManager,
      ),
      identifier,
      onCopy: (ImageProxy original) => ImageProxy.detached(
        binaryMessenger: binaryMessenger,
        instanceManager: instanceManager,
      ),
    );
  }
}
