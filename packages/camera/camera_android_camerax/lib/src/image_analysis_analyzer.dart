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
import 'image_proxy.dart';
import 'instance_manager.dart';
import 'java_object.dart';
import 'use_case.dart';

@SimpleClassAnnotation()
class ImageAnalysisAnalyzer extends JavaObject {
  ImageAnalysisAnalyzer(
      {BinaryMessenger? binaryMessenger,
      InstanceManager? instanceManager,
      required this.analyze})
      : super.detached(
            binaryMessenger: binaryMessenger,
            instanceManager: instanceManager) {
    _api = _ImageAnalysisAnalyzerHostApiImpl(
        binaryMessenger: binaryMessenger, instanceManager: instanceManager);
    _api.createFromInstance(this);
    AndroidCameraXCameraFlutterApis.instance.ensureSetUp();
  }

  ImageAnalysisAnalyzer.detached(
      {BinaryMessenger? binaryMessenger,
      InstanceManager? instanceManager,
      required this.analyze})
      : super.detached(
            binaryMessenger: binaryMessenger,
            instanceManager: instanceManager) {
    _api = _ImageAnalysisAnalyzerHostApiImpl(
        binaryMessenger: binaryMessenger, instanceManager: instanceManager);
    AndroidCameraXCameraFlutterApis.instance.ensureSetUp();
  }

  late final _ImageAnalysisAnalyzerHostApiImpl _api;

  final void Function(ImageProxy imageProxy) analyze;
}

class _ImageAnalysisAnalyzerHostApiImpl extends ImageAnalysisAnalyzerHostApi {
  _ImageAnalysisAnalyzerHostApiImpl({
    this.binaryMessenger,
    InstanceManager? instanceManager,
  })  : instanceManager = instanceManager ?? JavaObject.globalInstanceManager,
        super(binaryMessenger: binaryMessenger);

  final BinaryMessenger? binaryMessenger;

  final InstanceManager instanceManager;

  Future<void> createFromInstance(
    ImageAnalysisAnalyzer instance,
  ) {
    return create(
      instanceManager.addDartCreatedInstance(
        instance,
        onCopy: (ImageAnalysisAnalyzer original) =>
            ImageAnalysisAnalyzer.detached(
          analyze: original.analyze,
          binaryMessenger: binaryMessenger,
          instanceManager: instanceManager,
        ),
      ),
    );
  }
}

/// Flutter API implementation for [ImageAnalysisAnalyzer].
///
/// This class may handle instantiating and adding Dart instances that are
/// attached to a native instance or receiving callback methods from an
/// overridden native class.
@protected
class ImageAnalysisAnalyzerFlutterApiImpl
    implements ImageAnalysisAnalyzerFlutterApi {
  /// Constructs a [ImageAnalysisAnalyzerFlutterApiImpl].
  ImageAnalysisAnalyzerFlutterApiImpl({
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
      ImageAnalysisAnalyzer.detached(
        analyze: (ImageProxy imageProxy) {},
        binaryMessenger: binaryMessenger,
        instanceManager: instanceManager,
      ),
      identifier,
      onCopy: (ImageAnalysisAnalyzer original) =>
          ImageAnalysisAnalyzer.detached(
        analyze: original.analyze,
        binaryMessenger: binaryMessenger,
        instanceManager: instanceManager,
      ),
    );
  }

  @override
  void analyze(
    int identifier,
    int imageProxyIdentifier,
  ) {
    final ImageAnalysisAnalyzer instance =
        instanceManager.getInstanceWithWeakReference(identifier)!;
    final ImageProxy imageProxy =  instanceManager.getInstanceWithWeakReference(imageProxyIdentifier)!;
    return instance.analyze(
      imageProxy,

    );
  }
}
