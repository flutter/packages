// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/services.dart' show BinaryMessenger;
import 'package:meta/meta.dart' show immutable;

import 'android_camera_camerax_flutter_api_impls.dart';
import 'camerax_library.g.dart';
import 'instance_manager.dart';
import 'java_object.dart';
import 'recording.dart';

/// Dart wrapping of PendingRecording CameraX class.
///
/// See https://developer.android.com/reference/androidx/camera/video/PendingRecording
@immutable
class PendingRecording extends JavaObject {
  /// Creates a [PendingRecording] that is not automatically attached to
  /// a native object.
  PendingRecording.detached(
      {BinaryMessenger? binaryMessenger, InstanceManager? instanceManager})
      : super.detached(
            binaryMessenger: binaryMessenger,
            instanceManager: instanceManager) {
    _api = PendingRecordingHostApiImpl(
        binaryMessenger: binaryMessenger, instanceManager: instanceManager);
    AndroidCameraXCameraFlutterApis.instance.ensureSetUp();
  }

  late final PendingRecordingHostApiImpl _api;

  /// Stream that emits an event when the corresponding video recording is finalized.
  static final StreamController<VideoRecordEvent>
      videoRecordingEventStreamController =
      StreamController<VideoRecordEvent>.broadcast();

  /// Starts the recording, making it an active recording.
  Future<Recording> start() {
    return _api.startFromInstance(this);
  }
}

/// Host API implementation of [PendingRecording].
class PendingRecordingHostApiImpl extends PendingRecordingHostApi {
  /// Constructs a PendingRecordingHostApiImpl.
  PendingRecordingHostApiImpl(
      {this.binaryMessenger, InstanceManager? instanceManager})
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

  /// Starts the recording, making it an active recording.
  Future<Recording> startFromInstance(PendingRecording pendingRecording) async {
    int? instanceId = instanceManager.getIdentifier(pendingRecording);
    instanceId ??= instanceManager.addDartCreatedInstance(pendingRecording,
        onCopy: (PendingRecording original) {
      return PendingRecording.detached(
        binaryMessenger: binaryMessenger,
        instanceManager: instanceManager,
      );
    });
    return instanceManager
        .getInstanceWithWeakReference(await start(instanceId))! as Recording;
  }
}

/// Flutter API implementation of [PendingRecording].
class PendingRecordingFlutterApiImpl extends PendingRecordingFlutterApi {
  /// Constructs a [PendingRecordingFlutterApiImpl].
  PendingRecordingFlutterApiImpl({
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
        PendingRecording.detached(
          binaryMessenger: binaryMessenger,
          instanceManager: instanceManager,
        ),
        identifier, onCopy: (PendingRecording original) {
      return PendingRecording.detached(
        binaryMessenger: binaryMessenger,
        instanceManager: instanceManager,
      );
    });
  }

  @override
  void onVideoRecordingEvent(VideoRecordEventData event) {
    PendingRecording.videoRecordingEventStreamController.add(event.value);
  }
}
