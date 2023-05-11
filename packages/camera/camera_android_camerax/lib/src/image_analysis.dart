// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/services.dart' show BinaryMessenger;

import 'analyzer.dart';
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
    _api = _ImageAnalysisHostApiImpl(
        binaryMessenger: binaryMessenger, instanceManager: instanceManager);
    _api.createfromInstances(this, targetResolution);
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

  late final _ImageAnalysisHostApiImpl _api;

  /// Target resolution of the camera preview stream.
  final ResolutionInfo? targetResolution;

  /// Sets an [Analyzer] to receive and analyze images.
  Future<void> setAnalyzer(Analyzer analyzer) =>
      _api.setAnalyzerfromInstances(this, analyzer);

  /// Removes a previously set [Analyzer].
  Future<void> clearAnalyzer() => _api.clearAnalyzerfromInstances(this);
}

/// Host API implementation of [ImageAnalysis].
class _ImageAnalysisHostApiImpl extends ImageAnalysisHostApi {
  /// Constructor for [_ImageAnalysisHostApiImpl].
  ///
  /// If [binaryMessenger] is null, the default [BinaryMessenger] will be used,
  /// which routes to the host platform.
  ///
  /// An [instanceManager] is typically passed when a copy of an instance
  /// contained by an [InstanceManager] is being created. If left null, it
  /// will default to the global instance defined in [JavaObject].
  _ImageAnalysisHostApiImpl({
    this.binaryMessenger,
    InstanceManager? instanceManager,
  })  : instanceManager = instanceManager ?? JavaObject.globalInstanceManager,
        super(binaryMessenger: binaryMessenger);

  final BinaryMessenger? binaryMessenger;

  final InstanceManager instanceManager;

  /// Creates an [ImageAnalysis] instance with the specified target resolution
  /// on the native side.
  Future<void> createfromInstances(
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
      targetResolution,
    );
  }

  /// Sets the [analyzer] to receive and analyze images on the [instance].
  Future<void> setAnalyzerfromInstances(
    ImageAnalysis instance,
    Analyzer analyzer,
  ) {
    return setAnalyzer(
      instanceManager.getIdentifier(instance)!,
      instanceManager.getIdentifier(analyzer)!,
    );
  }

  /// Removes a previously set analyzer from the [instance].
  Future<void> clearAnalyzerfromInstances(
    ImageAnalysis instance,
  ) {
    return clearAnalyzer(
      instanceManager.getIdentifier(instance)!,
    );
  }
}
