// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/services.dart' show BinaryMessenger;

import 'android_camera_camerax_flutter_api_impls.dart';
import 'camerax_library.g.dart';
import 'instance_manager.dart';
import 'java_object.dart';

/// Wraps a CameraX recording class.
///
/// See https://developer.android.com/reference/androidx/camera/video/Recording.
class Recording extends JavaObject {
  /// Constructs a detached [Recording]
  Recording.detached(
      {BinaryMessenger? binaryMessenger, InstanceManager? instanceManager})
      : super.detached(
          binaryMessenger: binaryMessenger,
          instanceManager: instanceManager,
        ) {
    _api = RecordingHostApiImpl(
        binaryMessenger: binaryMessenger, instanceManager: instanceManager);
    AndroidCameraXCameraFlutterApis.instance.ensureSetUp();
  }

  late final RecordingHostApiImpl _api;

  /// Closes this recording.
  Future<void> close() {
    return _api.closeFromInstance(this);
  }

  /// Pauses this recording if active.
  Future<void> pause() {
    return _api.pauseFromInstance(this);
  }

  /// Resumes the current recording if paused.
  Future<void> resume() {
    return _api.resumeFromInstance(this);
  }

  /// Stops the recording, as if calling close().
  Future<void> stop() {
    return _api.stopFromInstance(this);
  }
}

/// Host API implementation of [Recording].
class RecordingHostApiImpl extends RecordingHostApi {
  /// Creates a [RecordingHostApiImpl].
  RecordingHostApiImpl({this.binaryMessenger, InstanceManager? instanceManager})
      : super(binaryMessenger: binaryMessenger) {
    this.instanceManager = instanceManager ?? JavaObject.globalInstanceManager;
  }

  /// Receives binary data across the Flutter platform barrier.
  ///
  /// If it is null, the default BinaryMessenger will be used which routes to
  /// the host platform.
  final BinaryMessenger? binaryMessenger;

  /// Maintains instances stored to communicate with native language objects.
  late final InstanceManager instanceManager;

  /// Closes the specified recording instance.
  Future<void> closeFromInstance(Recording recording) async {
    close(instanceManager.getIdentifier(recording)!);
  }

  /// Pauses the specified recording instance if active.
  Future<void> pauseFromInstance(Recording recording) async {
    pause(instanceManager.getIdentifier(recording)!);
  }

  /// Resumes the specified recording instance if paused.
  Future<void> resumeFromInstance(Recording recording) async {
    resume(instanceManager.getIdentifier(recording)!);
  }

  /// Stops the specified recording instance, as if calling closeFromInstance().
  Future<void> stopFromInstance(Recording recording) async {
    stop(instanceManager.getIdentifier(recording)!);
  }
}

/// Flutter API implementation of [Recording].
class RecordingFlutterApiImpl extends RecordingFlutterApi {
  /// Constructs a [RecordingFlutterApiImpl].
  RecordingFlutterApiImpl({
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
        Recording.detached(
          binaryMessenger: binaryMessenger,
          instanceManager: instanceManager,
        ),
        identifier, onCopy: (Recording original) {
      return Recording.detached(
        binaryMessenger: binaryMessenger,
        instanceManager: instanceManager,
      );
    });
  }
}
