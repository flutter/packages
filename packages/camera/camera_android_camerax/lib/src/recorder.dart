// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/services.dart';
import 'package:meta/meta.dart' show immutable;

import 'android_camera_camerax_flutter_api_impls.dart';
import 'camerax_library.g.dart';
import 'fallback_strategy.dart';
import 'instance_manager.dart';
import 'java_object.dart';
import 'pending_recording.dart';
import 'quality_selector.dart';

/// A dart wrapping of the CameraX Recorder class.
///
/// See https://developer.android.com/reference/androidx/camera/video/Recorder.
@immutable
class Recorder extends JavaObject {
  /// Creates a [Recorder].
  Recorder(
      {BinaryMessenger? binaryMessenger,
      InstanceManager? instanceManager,
      this.aspectRatio,
      this.bitRate,
      this.qualitySelector})
      : super.detached(
            binaryMessenger: binaryMessenger,
            instanceManager: instanceManager) {
    AndroidCameraXCameraFlutterApis.instance.ensureSetUp();
    _api = RecorderHostApiImpl(
        binaryMessenger: binaryMessenger, instanceManager: instanceManager);
    _api.createFromInstance(this, aspectRatio, bitRate, qualitySelector);
  }

  /// Creates a [Recorder] that is not automatically attached to a native object
  Recorder.detached(
      {BinaryMessenger? binaryMessenger,
      InstanceManager? instanceManager,
      this.aspectRatio,
      this.bitRate,
      this.qualitySelector})
      : super.detached(
            binaryMessenger: binaryMessenger,
            instanceManager: instanceManager) {
    _api = RecorderHostApiImpl(
        binaryMessenger: binaryMessenger, instanceManager: instanceManager);
    AndroidCameraXCameraFlutterApis.instance.ensureSetUp();
  }

  /// Returns default [QualitySelector] for recordings.
  ///
  /// See https://developer.android.com/reference/androidx/camera/video/Recorder#DEFAULT_QUALITY_SELECTOR().
  static QualitySelector getDefaultQualitySelector({
    BinaryMessenger? binaryMessenger,
    InstanceManager? instanceManager,
  }) {
    return QualitySelector.fromOrderedList(
      binaryMessenger: binaryMessenger,
      instanceManager: instanceManager,
      qualityList: <VideoQualityData>[
        VideoQualityData(quality: VideoQuality.FHD),
        VideoQualityData(quality: VideoQuality.HD),
        VideoQualityData(quality: VideoQuality.SD),
      ],
      fallbackStrategy: FallbackStrategy(
          quality: VideoQuality.FHD,
          fallbackRule: VideoResolutionFallbackRule.higherQualityOrLowerThan),
    );
  }

  late final RecorderHostApiImpl _api;

  /// The video aspect ratio of this [Recorder].
  final int? aspectRatio;

  /// The intended video encoding bitrate for recording.
  final int? bitRate;

  /// The [QualitySelector] of this [Recorder] used to select the resolution of
  /// the recording depending on the resoutions supported by the camera.
  ///
  /// Default selector is that returned by [getDefaultQualitySelector], and it
  /// is compatible with setting the aspect ratio.
  final QualitySelector? qualitySelector;

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
  void createFromInstance(Recorder instance, int? aspectRatio, int? bitRate,
      QualitySelector? qualitySelector) {
    int? identifier = instanceManager.getIdentifier(instance);
    identifier ??= instanceManager.addDartCreatedInstance(instance,
        onCopy: (Recorder original) {
      return Recorder.detached(
          binaryMessenger: binaryMessenger,
          instanceManager: instanceManager,
          aspectRatio: aspectRatio,
          bitRate: bitRate,
          qualitySelector: qualitySelector);
    });
    create(
        identifier,
        aspectRatio,
        bitRate,
        qualitySelector == null
            ? null
            : instanceManager.getIdentifier(qualitySelector)!);
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
