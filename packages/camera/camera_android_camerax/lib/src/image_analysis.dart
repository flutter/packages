// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:camera_platform_interface/camera_platform_interface.dart'
    show CameraImageData, CameraImageFormat, CameraImagePlane, ImageFormatGroup;
import 'package:flutter/services.dart' show BinaryMessenger;

import 'camerax_library.g.dart';
import 'instance_manager.dart';
import 'java_object.dart';
import 'use_case.dart';

class ImageAnalysis extends UseCase {
  /// Creates a [ImageAnalysis].
  ImageAnalysis(
      {BinaryMessenger? binaryMessenger,
      InstanceManager? instanceManager,
      this.targetResolution})
      : super.detached(
            binaryMessenger: binaryMessenger,
            instanceManager: instanceManager) {
    _api = ImageAnalysisHostApiImpl(
        binaryMessenger: binaryMessenger, instanceManager: instanceManager);
    _api.createFromInstance(this, targetResolution);
  }

  /// Stream that emits an event whenever a frame is received for image streaming.
  static final StreamController<CameraImageData> onStreamedFrameAvailableStreamController =
      StreamController<CameraImageData>.broadcast();

  late final ImageAnalysisHostApiImpl _api;

  /// Constructs a [ImageAnalysis] that is not automatically attached to a native object.
  ImageAnalysis.detached(
      {BinaryMessenger? binaryMessenger,
      InstanceManager? instanceManager,
      this.targetResolution})
      : super.detached(
            binaryMessenger: binaryMessenger,
            instanceManager: instanceManager) {
    _api = ImageAnalysisHostApiImpl(
        binaryMessenger: binaryMessenger, instanceManager: instanceManager);
  }

  /// Target resolution of the camera preview stream.
  final ResolutionInfo? targetResolution;

  Future<void> setAnalyzer() async {
    _api.setAnalyzerFromInstance(this);
  }
}

class ImageAnalysisHostApiImpl extends ImageAnalysisHostApi {
  /// Constructs a [ImageAnalysisHostApiImpl].
  ImageAnalysisHostApiImpl(
      {this.binaryMessenger, InstanceManager? instanceManager}) {
    this.instanceManager = instanceManager ?? JavaObject.globalInstanceManager;
  }

  /// Receives binary data across the Flutter platform barrier.
  ///
  /// If it is null, the default BinaryMessenger will be used which routes to
  /// the host platform.
  final BinaryMessenger? binaryMessenger;

  /// Maintains instances stored to communicate with native language objects.
  late final InstanceManager instanceManager;

  Future<void> createFromInstance(
      ImageAnalysis instance, ResolutionInfo? targetResolution) async {
    final int identifier = instanceManager.addDartCreatedInstance(instance,
        onCopy: (ImageAnalysis original) {
      return ImageAnalysis.detached(
          binaryMessenger: binaryMessenger,
          instanceManager: instanceManager,
          targetResolution: original.targetResolution);
    });
    create(identifier, targetResolution);
  }

  Future<void> setAnalyzerFromInstance(ImageAnalysis instance) async {
    final int? identifier = instanceManager.getIdentifier(instance);
    assert(identifier != null,
        'No ImageAnalysis instanced in the instance manager has been found.');

    setAnalyzer(identifier!);
  }
}

/// Flutter API implementation of [ImageAnalysis].
class ImageAnalysisFlutterApiImpl implements ImageAnalysisFlutterApi {
  /// Constructs a [ImageAnalysislutterApiImpl].
  ImageAnalysisFlutterApiImpl({
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
  void onImageAnalyzed(ImageInformation imageInformation) {
    print('HELLO?!?!?!?!?');
    List<CameraImagePlane> imagePlanes =
      imageInformation.imagePlanesInformation!
        .map((ImagePlaneInformation? imagePlaneInformation) {
          return CameraImagePlane(
            bytes: imagePlaneInformation!.bytes,
            bytesPerRow: imagePlaneInformation!.bytesPerRow,
            bytesPerPixel: imagePlaneInformation!.bytesPerPixel,
          );
    }).toList();

    CameraImageData data = CameraImageData(
      format: CameraImageFormat(_imageFormatGroupFromFormatCode(imageInformation.format), raw: imageInformation.format),
      planes: imagePlanes,
      height: imageInformation.height,
      width: imageInformation.width,
    );

    print('CAMILLE');

    ImageAnalysis.onStreamedFrameAvailableStreamController.add(data);
  }

  ImageFormatGroup _imageFormatGroupFromFormatCode(int format) {
    switch (format) {
      case 35: // android.graphics.ImageFormat.YUV_420_888
        return ImageFormatGroup.yuv420;
      case 256: // android.graphics.ImageFormat.JPEG
        return ImageFormatGroup.jpeg;
    }
    return ImageFormatGroup.unknown;
  }
}
