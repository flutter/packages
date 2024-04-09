// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/services.dart' show BinaryMessenger;
import 'package:meta/meta.dart' show immutable;

import 'analyzer.dart';
import 'android_camera_camerax_flutter_api_impls.dart';
import 'camerax_library.g.dart';
import 'instance_manager.dart';
import 'java_object.dart';
import 'resolution_selector.dart';
import 'use_case.dart';

/// Use case for providing CPU accessible images for performing image analysis.
///
/// See https://developer.android.com/reference/androidx/camera/core/ImageAnalysis.
@immutable
class ImageAnalysis extends UseCase {
  /// Creates an [ImageAnalysis].
  ImageAnalysis(
      {BinaryMessenger? binaryMessenger,
      InstanceManager? instanceManager,
      this.initialTargetRotation,
      this.resolutionSelector})
      : super.detached(
            binaryMessenger: binaryMessenger,
            instanceManager: instanceManager) {
    _api = _ImageAnalysisHostApiImpl(
        binaryMessenger: binaryMessenger, instanceManager: instanceManager);
    _api.createFromInstances(this, initialTargetRotation, resolutionSelector);
    AndroidCameraXCameraFlutterApis.instance.ensureSetUp();
  }

  /// Constructs an [ImageAnalysis] that is not automatically attached to a
  /// native object.
  ImageAnalysis.detached(
      {BinaryMessenger? binaryMessenger,
      InstanceManager? instanceManager,
      this.initialTargetRotation,
      this.resolutionSelector})
      : super.detached(
            binaryMessenger: binaryMessenger,
            instanceManager: instanceManager) {
    _api = _ImageAnalysisHostApiImpl(
        binaryMessenger: binaryMessenger, instanceManager: instanceManager);
    AndroidCameraXCameraFlutterApis.instance.ensureSetUp();
  }

  late final _ImageAnalysisHostApiImpl _api;

  /// Initial target rotation of the camera used for the preview stream.
  ///
  /// Should be specified in terms of one of the [Surface]
  /// rotation constants that represents the counter-clockwise degrees of
  /// rotation relative to [DeviceOrientation.portraitUp].
  // TODO(camsim99): Remove this parameter. https://github.com/flutter/flutter/issues/140664
  final int? initialTargetRotation;

  /// Target resolution of the camera preview stream.
  ///
  /// If not set, this [UseCase] will default to the behavior described in:
  /// https://developer.android.com/reference/androidx/camera/core/ImageAnalysis.Builder#setResolutionSelector(androidx.camera.core.resolutionselector.ResolutionSelector).
  final ResolutionSelector? resolutionSelector;

  /// Dynamically sets the target rotation of this instance.
  ///
  /// [rotation] should be specified in terms of one of the [Surface]
  /// rotation constants that represents the counter-clockwise degrees of
  /// rotation relative to [DeviceOrientation.portraitUp].
  Future<void> setTargetRotation(int rotation) =>
      _api.setTargetRotationFromInstances(this, rotation);

  /// Sets an [Analyzer] to receive and analyze images.
  Future<void> setAnalyzer(Analyzer analyzer) =>
      _api.setAnalyzerFromInstances(this, analyzer);

  /// Removes a previously set [Analyzer].
  Future<void> clearAnalyzer() => _api.clearAnalyzerFromInstances(this);
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
  Future<void> createFromInstances(
    ImageAnalysis instance,
    int? targetRotation,
    ResolutionSelector? resolutionSelector,
  ) {
    return create(
      instanceManager.addDartCreatedInstance(
        instance,
        onCopy: (ImageAnalysis original) => ImageAnalysis.detached(
          initialTargetRotation: original.initialTargetRotation,
          resolutionSelector: original.resolutionSelector,
          binaryMessenger: binaryMessenger,
          instanceManager: instanceManager,
        ),
      ),
      targetRotation,
      resolutionSelector == null
          ? null
          : instanceManager.getIdentifier(resolutionSelector),
    );
  }

  /// Dynamically sets the target rotation of [instance] to [rotation].
  Future<void> setTargetRotationFromInstances(
      ImageAnalysis instance, int rotation) {
    return setTargetRotation(
        instanceManager.getIdentifier(instance)!, rotation);
  }

  /// Sets the [analyzer] to receive and analyze images on the [instance].
  Future<void> setAnalyzerFromInstances(
    ImageAnalysis instance,
    Analyzer analyzer,
  ) {
    return setAnalyzer(
      instanceManager.getIdentifier(instance)!,
      instanceManager.getIdentifier(analyzer)!,
    );
  }

  /// Removes a previously set analyzer from the [instance].
  Future<void> clearAnalyzerFromInstances(
    ImageAnalysis instance,
  ) {
    return clearAnalyzer(
      instanceManager.getIdentifier(instance)!,
    );
  }
}
