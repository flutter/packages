// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/services.dart';

import 'android_camera_camerax_flutter_api_impls.dart';
import 'camerax_library.g.dart';
import 'instance_manager.dart';
import 'java_object.dart';
import 'recorder.dart';
import 'use_case.dart';

/// Dart wrapping of CameraX VideoCapture class.
///
/// See https://developer.android.com/reference/androidx/camera/video/VideoCapture.
class VideoCapture extends UseCase {
  /// Creates a VideoCapture that is not automatically attached to a native object.
  VideoCapture.detached(
      {BinaryMessenger? binaryMessenger, InstanceManager? instanceManager})
      : super.detached(
            binaryMessenger: binaryMessenger,
            instanceManager: instanceManager) {
    _api = VideoCaptureHostApiImpl(
        binaryMessenger: binaryMessenger, instanceManager: instanceManager);
    AndroidCameraXCameraFlutterApis.instance.ensureSetUp();
  }

  /// Creates a [VideoCapture] associated with the given [Recorder].
  static Future<VideoCapture> withOutput(Recorder recorder,
      {BinaryMessenger? binaryMessenger, InstanceManager? instanceManager}) {
    AndroidCameraXCameraFlutterApis.instance.ensureSetUp();
    final VideoCaptureHostApiImpl api = VideoCaptureHostApiImpl(
        binaryMessenger: binaryMessenger, instanceManager: instanceManager);

    return api.withOutputFromInstance(recorder);
  }

  /// Gets the [Recorder] associated with this VideoCapture.
  Future<Recorder> getOutput() {
    return _api.getOutputFromInstance(this);
  }

  late final VideoCaptureHostApiImpl _api;
}

/// Host API implementation of [VideoCapture].
class VideoCaptureHostApiImpl extends VideoCaptureHostApi {
  /// Constructs a [VideoCaptureHostApiImpl].
  VideoCaptureHostApiImpl(
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

  /// Creates a [VideoCapture] associated with the provided [Recorder] instance.
  Future<VideoCapture> withOutputFromInstance(Recorder recorder) async {
    int? identifier = instanceManager.getIdentifier(recorder);
    identifier ??= instanceManager.addDartCreatedInstance(recorder,
        onCopy: (Recorder original) {
      return Recorder(
          binaryMessenger: binaryMessenger, instanceManager: instanceManager);
    });
    final int videoCaptureId = await withOutput(identifier);
    return instanceManager
        .getInstanceWithWeakReference<VideoCapture>(videoCaptureId)!;
  }

  /// Gets the [Recorder] associated with the provided [VideoCapture] instance.
  Future<Recorder> getOutputFromInstance(VideoCapture instance) async {
    final int? identifier = instanceManager.getIdentifier(instance);
    final int recorderId = await getOutput(identifier!);
    return instanceManager.getInstanceWithWeakReference(recorderId)!;
  }
}

/// Flutter API implementation of [VideoCapture].
class VideoCaptureFlutterApiImpl implements VideoCaptureFlutterApi {
  /// Constructs a [VideoCaptureFlutterApiImpl].
  VideoCaptureFlutterApiImpl({
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
  void create(int identifier) {
    instanceManager.addHostCreatedInstance(
        VideoCapture.detached(
          binaryMessenger: binaryMessenger,
          instanceManager: instanceManager,
        ),
        identifier, onCopy: (VideoCapture original) {
      return VideoCapture.detached(
        binaryMessenger: binaryMessenger,
        instanceManager: instanceManager,
      );
    });
  }
}
