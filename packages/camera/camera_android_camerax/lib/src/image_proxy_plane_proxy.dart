// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:typed_data';

import 'package:camera_platform_interface/camera_platform_interface.dart'
    show CameraImageData, CameraImageFormat, CameraImagePlane, ImageFormatGroup;
import 'package:flutter/services.dart' show BinaryMessenger;
import 'package:meta/meta.dart' show protected;
import 'package:simple_ast/annotations.dart';

import 'android_camera_camerax_flutter_api_impls.dart';
import 'camerax_library.g.dart';
import 'instance_manager.dart';
import 'java_object.dart';
import 'use_case.dart';

@SimpleClassAnnotation()
class ImageProxyPlaneProxy extends JavaObject {
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

  ImageProxyPlaneProxy.detached(
      {BinaryMessenger? binaryMessenger, InstanceManager? instanceManager})
      : super.detached(
            binaryMessenger: binaryMessenger,
            instanceManager: instanceManager) {
    _api = _ImageProxyPlaneProxyHostApiImpl(
        binaryMessenger: binaryMessenger, instanceManager: instanceManager);
    AndroidCameraXCameraFlutterApis.instance.ensureSetUp();
  }

  late final _ImageProxyPlaneProxyHostApiImpl _api;

  Future<Uint8List> getBuffer() {}

  Future<int> getPixelStride() {}

  Future<int> getRowStride() {}
}

class _ImageProxyPlaneProxyHostApiImpl extends ImageProxyPlaneProxyHostApi {
  _ImageProxyPlaneProxyHostApiImpl({
    this.binaryMessenger,
    InstanceManager? instanceManager,
  })  : instanceManager = instanceManager ?? JavaObject.globalInstanceManager,
        super(binaryMessenger: binaryMessenger);

  final BinaryMessenger? binaryMessenger;

  final InstanceManager instanceManager;

  Future<int> getPixelStrideFromInstance(
    ImageProxyPlaneProxy instance,
  ) {
    return getPixelStride(
      instanceManager.getIdentifier(instance)!,
    );
  }

  Future<Uint8List> getBufferFromInstance(
    ImageProxyPlaneProxy instance,
  ) {
    return getBuffer(
      instanceManager.getIdentifier(instance)!,
    );
  }

  Future<int> getRowStrideFromInstance(
    ImageProxyPlaneProxy instance,
  )  async  {
    return getRowStride(
      instanceManager.getIdentifier(instance)!,
    );
  }
  
}

/// Flutter API implementation for [ImageProxyPlaneProxy].
///
/// This class may handle instantiating and adding Dart instances that are
/// attached to a native instance or receiving callback methods from an
/// overridden native class.
@protected
class ImageProxyPlaneProxyFlutterApiImpl
    implements ImageProxyPlaneProxyFlutterApi {
  /// Constructs a [ImageProxyPlaneProxyFlutterApiImpl].
  ImageProxyPlaneProxyFlutterApiImpl({
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
      ImageProxyPlaneProxy.detached(
        binaryMessenger: binaryMessenger,
        instanceManager: instanceManager,
      ),
      identifier,
      onCopy: (ImageProxyPlaneProxy original) => ImageProxyPlaneProxy.detached(
        binaryMessenger: binaryMessenger,
        instanceManager: instanceManager,
      ),
    );
  }
}
