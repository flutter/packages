// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:camera_platform_interface/camera_platform_interface.dart'
    show CameraImageData, CameraImageFormat, CameraImagePlane, ImageFormatGroup;
import 'package:flutter/services.dart' show BinaryMessenger;

import 'android_camera_camerax_flutter_api_impls.dart';
import 'camerax_library.g.dart';
import 'instance_manager.dart';
import 'java_object.dart';
import 'use_case.dart';

/// Use case for providing CPU accessible images for performing image analysis.
///
/// See https://developer.android.com/reference/androidx/camera/core/ImageAnalysis.
class ImageAnalysis extends UseCase {
  /// Creates an [ImageAnalysis].
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
    AndroidCameraXCameraFlutterApis.instance.ensureSetUp();
  }

  /// Constructs an [ImageAnalysis] that is not automatically attached to a native object.
  ImageAnalysis.detached(
      {BinaryMessenger? binaryMessenger,
      InstanceManager? instanceManager,
      this.targetResolution})
      : super.detached(
            binaryMessenger: binaryMessenger,
            instanceManager: instanceManager) {
    _api = ImageAnalysisHostApiImpl(
        binaryMessenger: binaryMessenger, instanceManager: instanceManager);
    AndroidCameraXCameraFlutterApis.instance.ensureSetUp();
  }

  /// Stream that emits data whenever a frame is received for image streaming.
  static final StreamController<CameraImageData>
      onStreamedFrameAvailableStreamController =
      StreamController<CameraImageData>.broadcast();

  late final ImageAnalysisHostApiImpl _api;

  /// Target resolution of the camera preview stream.
  final ResolutionInfo? targetResolution;

  /// Configures this instance for image streaming support.
  ///
  /// This is a direct wrapping of the setAnalyzer method in CameraX,
  /// but also handles the creation of the CameraX ImageAnalysis.Analyzer
  /// that is used to collect the image information required for image
  /// streaming.
  ///
  /// See [ImageAnalysisFlutterApiImpl.onImageAnalyzed] for the image
  /// information that is analyzed by the created ImageAnalysis.Analyzer
  /// instance.
  Future<void> setAnalyzer() async {
    _api.setAnalyzerFromInstance(this);
  }

  /// Clears previously set analyzer for image streaming support.
  Future<void> clearAnalyzer() async {
    _api.clearAnalyzerFromInstance(this);
  }
}

/// Host API implementation of [ImageAnalysis].
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

  /// Creates an [ImageAnalysis] instance with the specified target resolution.
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

  /// Sets analyzer for the provided instance to support image streaming.
  Future<void> setAnalyzerFromInstance(ImageAnalysis instance) async {
    final int? identifier = instanceManager.getIdentifier(instance);
    assert(identifier != null,
        'No ImageAnalysis instance in the instance manager has been found.');

    setAnalyzer(identifier!);
  }

  /// Clears analyzer of provide instance for image streaming support.
  Future<void> clearAnalyzerFromInstance(ImageAnalysis instance) async {
    final int? identifier = instanceManager.getIdentifier(instance);
    assert(identifier != null,
        'No ImageAnalysis instance in the instance manager has been found.');

    clearAnalyzer(identifier!);
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
    // Parse image plane information.
    final List<CameraImagePlane> imagePlanes = imageInformation
        .imagePlanesInformation
        .map((ImagePlaneInformation? imagePlaneInformation) {
      return CameraImagePlane(
        bytes: imagePlaneInformation!.bytes,
        bytesPerRow: imagePlaneInformation.bytesPerRow,
        bytesPerPixel: imagePlaneInformation.bytesPerPixel,
      );
    }).toList();

    // Parse general image information.
    final CameraImageData data = CameraImageData(
      format: CameraImageFormat(
          _imageFormatGroupFromFormatCode(imageInformation.format),
          raw: imageInformation.format),
      planes: imagePlanes,
      height: imageInformation.height,
      width: imageInformation.width,
    );

    // Add image information to stream for visibility by the plugin.
    ImageAnalysis.onStreamedFrameAvailableStreamController.add(data);
  }

  /// Converts Flutter supported image format codes to [ImageFormatGroup].
  ///
  /// Note that for image analysis, CameraX only currently supports YUV_420_888.
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
