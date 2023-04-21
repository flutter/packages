// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/services.dart' show BinaryMessenger;
import 'package:meta/meta.dart' show protected;

import 'android_camera_camerax_flutter_api_impls.dart';
import 'camerax_library.g.dart';
import 'image_proxy.dart';
import 'instance_manager.dart';
import 'java_object.dart';

/// Wrapper of callback for analyzing images.
///
/// See https://developer.android.com/reference/androidx/camera/core/ImageAnalysis.Analyzer.
class Analyzer extends JavaObject {
  /// Creates an [Analyzer].
  Analyzer(
      {BinaryMessenger? binaryMessenger,
      InstanceManager? instanceManager,
      required this.analyze})
      : super.detached(
            binaryMessenger: binaryMessenger,
            instanceManager: instanceManager) {
    _api = _AnalyzerHostApiImpl(
        binaryMessenger: binaryMessenger, instanceManager: instanceManager);
    _api.createfromInstances(this);
    AndroidCameraXCameraFlutterApis.instance.ensureSetUp();
  }

  /// Constructs a [Analyzer] that is not automatically attached to a native object.
  Analyzer.detached(
      {BinaryMessenger? binaryMessenger,
      InstanceManager? instanceManager,
      required this.analyze})
      : super.detached(
            binaryMessenger: binaryMessenger,
            instanceManager: instanceManager) {
    _api = _AnalyzerHostApiImpl(
        binaryMessenger: binaryMessenger, instanceManager: instanceManager);
    AndroidCameraXCameraFlutterApis.instance.ensureSetUp();
  }

  late final _AnalyzerHostApiImpl _api;

  /// Analyzes an image to produce a result.
  final Future<void> Function(ImageProxy imageProxy) analyze;
}

/// Host API implementation of [Analyzer].
class _AnalyzerHostApiImpl extends AnalyzerHostApi {
  _AnalyzerHostApiImpl({
    this.binaryMessenger,
    InstanceManager? instanceManager,
  })  : instanceManager = instanceManager ?? JavaObject.globalInstanceManager,
        super(binaryMessenger: binaryMessenger);

  final BinaryMessenger? binaryMessenger;

  final InstanceManager instanceManager;

  /// Creates an [Analyzer] instance on the native side.
  Future<void> createfromInstances(
    Analyzer instance,
  ) {
    return create(
      instanceManager.addDartCreatedInstance(
        instance,
        onCopy: (Analyzer original) => Analyzer.detached(
          analyze: original.analyze,
          binaryMessenger: binaryMessenger,
          instanceManager: instanceManager,
        ),
      ),
    );
  }
}

/// Flutter API implementation for [Analyzer].
///
/// This class may handle instantiating and adding Dart instances that are
/// attached to a native instance or receiving callback methods from an
/// overridden native class.
@protected
class AnalyzerFlutterApiImpl implements AnalyzerFlutterApi {
  /// Constructs a [AnalyzerFlutterApiImpl].
  AnalyzerFlutterApiImpl({
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
      Analyzer.detached(
        analyze: (ImageProxy imageProxy) async {},
        binaryMessenger: binaryMessenger,
        instanceManager: instanceManager,
      ),
      identifier,
      onCopy: (Analyzer original) => Analyzer.detached(
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
    final Analyzer instance =
        instanceManager.getInstanceWithWeakReference(identifier)!;
    final ImageProxy imageProxy =
        instanceManager.getInstanceWithWeakReference(imageProxyIdentifier)!;
    instance.analyze(
      imageProxy,
    );
  }
}
