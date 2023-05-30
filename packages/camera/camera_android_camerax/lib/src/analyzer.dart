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
  ///
  /// If [binaryMessenger] is null, the default [BinaryMessenger] will be used,
  /// which routes to the host platform.
  ///
  /// An [instanceManager] is typically passed when a copy of an instance
  /// contained by an [InstanceManager] is being created. If left null, it
  /// will default to the global instance defined in [JavaObject].
  AnalyzerFlutterApiImpl({
    BinaryMessenger? binaryMessenger,
    InstanceManager? instanceManager,
  })  : _binaryMessenger = binaryMessenger,
        _instanceManager = instanceManager ?? JavaObject.globalInstanceManager;

  /// Receives binary data across the Flutter platform barrier.
  final BinaryMessenger? _binaryMessenger;

  /// Maintains instances stored to communicate with native language objects.
  final InstanceManager _instanceManager;

  @override
  void create(
    int identifier,
  ) {
    _instanceManager.addHostCreatedInstance(
      Analyzer.detached(
        analyze: (ImageProxy imageProxy) async {},
        binaryMessenger: _binaryMessenger,
        instanceManager: _instanceManager,
      ),
      identifier,
      onCopy: (Analyzer original) => Analyzer.detached(
        analyze: original.analyze,
        binaryMessenger: _binaryMessenger,
        instanceManager: _instanceManager,
      ),
    );
  }

  @override
  void analyze(
    int identifier,
    int imageProxyIdentifier,
  ) {
    final Analyzer instance =
        _instanceManager.getInstanceWithWeakReference(identifier)!;
    final ImageProxy imageProxy =
        _instanceManager.getInstanceWithWeakReference(imageProxyIdentifier)!;
    instance.analyze(
      imageProxy,
    );
  }
}
