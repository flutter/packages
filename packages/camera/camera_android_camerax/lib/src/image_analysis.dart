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
import 'image_analysis_analyzer.dart';
import 'instance_manager.dart';
import 'java_object.dart';
import 'use_case.dart';

/// Use case for providing CPU accessible images for performing image analysis.
///
/// See https://developer.android.com/reference/androidx/camera/core/ImageAnalysis.
@SimpleClassAnnotation()
class ImageAnalysis extends UseCase {
  /// Creates an [ImageAnalysis].
  ImageAnalysis(
      {BinaryMessenger? binaryMessenger,
      InstanceManager? instanceManager,
      this.targetResolution})
      : super.detached(
            binaryMessenger: binaryMessenger,
            instanceManager: instanceManager) {
    _api = _ImageAnalysisHostApiImpl(
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
    _api = _ImageAnalysisHostApiImpl(
        binaryMessenger: binaryMessenger, instanceManager: instanceManager);
    AndroidCameraXCameraFlutterApis.instance.ensureSetUp();
  }

  // /// Stream that emits data whenever a frame is received for image streaming.
  // static final StreamController<CameraImageData>
  //     onStreamedFrameAvailableStreamController =
  //     StreamController<CameraImageData>.broadcast();

  late final _ImageAnalysisHostApiImpl _api;

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
  Future<void> setAnalyzer(ImageAnalysisAnalyzer analyzer) async {
    _api.setAnalyzerFromInstance(this, analyzer);
  }

  /// Clears previously set analyzer for image streaming support.
  Future<void> clearAnalyzer() async {
    _api.clearAnalyzerFromInstance(this);
  }
}

class _ImageAnalysisHostApiImpl extends ImageAnalysisHostApi {
  _ImageAnalysisHostApiImpl({
    this.binaryMessenger,
    InstanceManager? instanceManager,
  })  : instanceManager = instanceManager ?? JavaObject.globalInstanceManager,
        super(binaryMessenger: binaryMessenger);

  final BinaryMessenger? binaryMessenger;

  final InstanceManager instanceManager;

  Future<void> createFromInstance(
    ImageAnalysis instance,
    ResolutionInfo? targetResolution,
  ) {
    return create(
      instanceManager.addDartCreatedInstance(
        instance,
        onCopy: (ImageAnalysis original) => ImageAnalysis.detached(
          targetResolution: original.targetResolution,
          binaryMessenger: binaryMessenger,
          instanceManager: instanceManager,
        ),
      ),
      targetResolution == null
          ? null
          : instanceManager.getIdentifier(targetResolution)!,
    );
  }

  // StreamController attachOnStreamedFrameAvailableStreamControllerFromInstances(
  //   StreamController onStreamedFrameAvailableStreamController,
  // ) {
  //   attachOnStreamedFrameAvailableStreamController(
  //     instanceManager.addDartCreatedInstance(
  //       onStreamedFrameAvailableStreamController,
  //       onCopy: (StreamController original) => StreamController.detached(
  //         // TODO(bparrishMines): This should include the missing params.
  //         binaryMessenger: binaryMessenger,
  //         instanceManager: instanceManager,
  //       ),
  //     ),
  //   );
  //   return onStreamedFrameAvailableStreamController;
  // }

  Future<void> setAnalyzerFromInstance(
    ImageAnalysis instance,
    ImageAnalysisAnalyzer analyzer,
  ) {
    return setAnalyzer(
      instanceManager.getIdentifier(instance)!,
      instanceManager.getIdentifier(analyzer)!,
    );
  }

  Future<void> clearAnalyzerFromInstance(
    ImageAnalysis instance,
  ) {
    return clearAnalyzer(
      instanceManager.getIdentifier(instance)!,
    );
  }
}

/// Flutter API implementation for [ImageAnalysis].
///
/// This class may handle instantiating and adding Dart instances that are
/// attached to a native instance or receiving callback methods from an
/// overridden native class.
@protected
class ImageAnalysisFlutterApiImpl implements ImageAnalysisFlutterApi {
  /// Constructs a [ImageAnalysisFlutterApiImpl].
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
  void create(
    int identifier,
    int? targetResolutionIdentifier,
  ) {
    instanceManager.addHostCreatedInstance(
      ImageAnalysis.detached(
        targetResolution: targetResolutionIdentifier == null
            ? null
            : instanceManager.getInstanceWithWeakReference(
                targetResolutionIdentifier,
              ),
        binaryMessenger: binaryMessenger,
        instanceManager: instanceManager,
      ),
      identifier,
      onCopy: (ImageAnalysis original) => ImageAnalysis.detached(
        targetResolution: original.targetResolution,
        binaryMessenger: binaryMessenger,
        instanceManager: instanceManager,
      ),
    );
  }
}
