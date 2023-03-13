// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

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
