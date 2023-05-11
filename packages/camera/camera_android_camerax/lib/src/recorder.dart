// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/services.dart';

import 'android_camera_camerax_flutter_api_impls.dart';
import 'camerax_library.g.dart';
import 'instance_manager.dart';
import 'java_object.dart';
import 'pending_recording.dart';

/// A dart wrapping of the CameraX Recorder class.
///
/// See https://developer.android.com/reference/androidx/camera/video/Recorder.
class Recorder extends JavaObject {
  /// Creates a [Recorder].
  Recorder(
      {BinaryMessenger? binaryMessenger,
      InstanceManager? instanceManager,
      this.aspectRatio,
      this.bitRate})
      : super.detached(
            binaryMessenger: binaryMessenger,
            instanceManager: instanceManager) {
    AndroidCameraXCameraFlutterApis.instance.ensureSetUp();
    _api = RecorderHostApiImpl(
        binaryMessenger: binaryMessenger, instanceManager: instanceManager);
    _api.createFromInstance(this, aspectRatio, bitRate);
  }

  /// Creates a [Recorder] that is not automatically attached to a native object
  Recorder.detached(
      {BinaryMessenger? binaryMessenger,
      InstanceManager? instanceManager,
      this.aspectRatio,
      this.bitRate})
      : super.detached(
            binaryMessenger: binaryMessenger,
            instanceManager: instanceManager) {
    _api = RecorderHostApiImpl(
        binaryMessenger: binaryMessenger, instanceManager: instanceManager);
    AndroidCameraXCameraFlutterApis.instance.ensureSetUp();
  }

  late final RecorderHostApiImpl _api;

  /// The video aspect ratio of this Recorder.
  final int? aspectRatio;

  /// The intended video encoding bitrate for recording.
  final int? bitRate;

  /// Prepare a recording that will be saved to a file.
  Future<PendingRecording> prepareRecording(String path) {
    return _api.prepareRecordingFromInstance(this, path);
  }
}

/// Host API implementation of [Recorder].
class RecorderHostApiImpl extends RecorderHostApi {
  /// Constructs a [RecorderHostApiImpl].
  RecorderHostApiImpl(
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

  /// Creates a [Recorder] with the provided aspect ratio and bitrate if specified.
  void createFromInstance(Recorder instance, int? aspectRatio, int? bitRate) {
    int? identifier = instanceManager.getIdentifier(instance);
    identifier ??= instanceManager.addDartCreatedInstance(instance,
        onCopy: (Recorder original) {
      return Recorder.detached(
          binaryMessenger: binaryMessenger,
          instanceManager: instanceManager,
          aspectRatio: aspectRatio,
          bitRate: bitRate);
    });
    create(identifier, aspectRatio, bitRate);
  }

  /// Prepares a [Recording] using this recorder. The output file will be saved
  /// at the provided path.
  Future<PendingRecording> prepareRecordingFromInstance(
      Recorder instance, String path) async {
    final int pendingRecordingId =
        await prepareRecording(instanceManager.getIdentifier(instance)!, path);

    return instanceManager.getInstanceWithWeakReference(pendingRecordingId)!;
  }
}

/// Flutter API implementation of [Recorder].
class RecorderFlutterApiImpl extends RecorderFlutterApi {
  /// Constructs a [RecorderFlutterApiImpl].
  RecorderFlutterApiImpl({
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
  void create(int identifier, int? aspectRatio, int? bitRate) {
    instanceManager.addHostCreatedInstance(
        Recorder.detached(
          binaryMessenger: binaryMessenger,
          instanceManager: instanceManager,
          aspectRatio: aspectRatio,
          bitRate: bitRate,
        ),
        identifier, onCopy: (Recorder original) {
      return Recorder.detached(
        binaryMessenger: binaryMessenger,
        instanceManager: instanceManager,
        aspectRatio: aspectRatio,
        bitRate: bitRate,
      );
    });
  }
}
