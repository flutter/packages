// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/services.dart' show BinaryMessenger;
import 'package:meta/meta.dart' show immutable;

import 'camerax_library.g.dart';
import 'instance_manager.dart';
import 'java_object.dart';
import 'resolution_selector.dart';
import 'use_case.dart';

/// Use case that provides a camera preview stream for display.
///
/// See https://developer.android.com/reference/androidx/camera/core/Preview.
@immutable
class Preview extends UseCase {
  /// Creates a [Preview].
  Preview(
      {BinaryMessenger? binaryMessenger,
      InstanceManager? instanceManager,
      this.initialTargetRotation,
      this.resolutionSelector})
      : super.detached(
            binaryMessenger: binaryMessenger,
            instanceManager: instanceManager) {
    _api = PreviewHostApiImpl(
        binaryMessenger: binaryMessenger, instanceManager: instanceManager);
    _api.createFromInstance(this, initialTargetRotation, resolutionSelector);
  }

  /// Constructs a [Preview] that is not automatically attached to a native object.
  Preview.detached(
      {BinaryMessenger? binaryMessenger,
      InstanceManager? instanceManager,
      this.initialTargetRotation,
      this.resolutionSelector})
      : super.detached(
            binaryMessenger: binaryMessenger,
            instanceManager: instanceManager) {
    _api = PreviewHostApiImpl(
        binaryMessenger: binaryMessenger, instanceManager: instanceManager);
  }

  late final PreviewHostApiImpl _api;

  /// Target rotation of the camera used for the preview stream.
  ///
  /// Should be specified in terms of one of the [Surface]
  /// rotation constants that represents the counter-clockwise degrees of
  /// rotation relative to [DeviceOrientation.portraitUp].
  ///
  // TODO(camsim99): Remove this parameter. https://github.com/flutter/flutter/issues/140664
  final int? initialTargetRotation;

  /// Target resolution of the camera preview stream.
  ///
  /// If not set, this [UseCase] will default to the behavior described in:
  /// https://developer.android.com/reference/androidx/camera/core/Preview.Builder#setResolutionSelector(androidx.camera.core.resolutionselector.ResolutionSelector).
  final ResolutionSelector? resolutionSelector;

  /// Dynamically sets the target rotation of this instance.
  ///
  /// [rotation] should be specified in terms of one of the [Surface]
  /// rotation constants that represents the counter-clockwise degrees of
  /// rotation relative to [DeviceOrientation.portraitUp].
  Future<void> setTargetRotation(int rotation) =>
      _api.setTargetRotationFromInstances(this, rotation);

  /// Sets the surface provider for the preview stream.
  ///
  /// Returns the ID of the FlutterSurfaceTextureEntry used on the native end
  /// used to display the preview stream on a [Texture] of the same ID.
  Future<int> setSurfaceProvider() {
    return _api.setSurfaceProviderFromInstance(this);
  }

  /// Releases Flutter surface texture used to provide a surface for the preview
  /// stream.
  void releaseFlutterSurfaceTexture() {
    _api.releaseFlutterSurfaceTextureFromInstance();
  }

  /// Retrieves the selected resolution information of this [Preview].
  Future<ResolutionInfo> getResolutionInfo() {
    return _api.getResolutionInfoFromInstance(this);
  }

  /// Returns whether or not the Android surface producer automatically handles
  /// correcting the rotation of camera previews for the device this plugin runs on.
  Future<bool> surfaceProducerHandlesCropAndRotation() {
    return _api.surfaceProducerHandlesCropAndRotationFromInstance();
  }
}

/// Host API implementation of [Preview].
class PreviewHostApiImpl extends PreviewHostApi {
  /// Constructs an [PreviewHostApiImpl].
  ///
  /// If [binaryMessenger] is null, the default [BinaryMessenger] will be used,
  /// which routes to the host platform.
  ///
  /// An [instanceManager] is typically passed when a copy of an instance
  /// contained by an [InstanceManager] is being created. If left null, it
  /// will default to the global instance defined in [JavaObject].
  PreviewHostApiImpl({this.binaryMessenger, InstanceManager? instanceManager}) {
    this.instanceManager = instanceManager ?? JavaObject.globalInstanceManager;
  }

  /// Receives binary data across the Flutter platform barrier.
  final BinaryMessenger? binaryMessenger;

  /// Maintains instances stored to communicate with native language objects.
  late final InstanceManager instanceManager;

  /// Creates a [Preview] with the target rotation and target resolution if
  /// specified.
  void createFromInstance(Preview instance, int? targetRotation,
      ResolutionSelector? resolutionSelector) {
    final int identifier = instanceManager.addDartCreatedInstance(instance,
        onCopy: (Preview original) {
      return Preview.detached(
          binaryMessenger: binaryMessenger,
          instanceManager: instanceManager,
          initialTargetRotation: original.initialTargetRotation,
          resolutionSelector: original.resolutionSelector);
    });
    create(
        identifier,
        targetRotation,
        resolutionSelector == null
            ? null
            : instanceManager.getIdentifier(resolutionSelector));
  }

  /// Dynamically sets the target rotation of [instance] to [rotation].
  Future<void> setTargetRotationFromInstances(Preview instance, int rotation) {
    return setTargetRotation(
        instanceManager.getIdentifier(instance)!, rotation);
  }

  /// Sets the surface provider of the specified [Preview] instance and returns
  /// the ID corresponding to the surface it will provide.
  Future<int> setSurfaceProviderFromInstance(Preview instance) async {
    final int? identifier = instanceManager.getIdentifier(instance);
    final int surfaceTextureEntryId = await setSurfaceProvider(identifier!);

    return surfaceTextureEntryId;
  }

  /// Releases Flutter surface texture used to provide a surface for the preview
  /// stream if a surface provider was set for a [Preview] instance.
  void releaseFlutterSurfaceTextureFromInstance() {
    releaseFlutterSurfaceTexture();
  }

  /// Gets the resolution information of the specified [Preview] instance.
  Future<ResolutionInfo> getResolutionInfoFromInstance(Preview instance) async {
    final int? identifier = instanceManager.getIdentifier(instance);
    final ResolutionInfo resolutionInfo = await getResolutionInfo(identifier!);

    return resolutionInfo;
  }

  /// Returns whether or not the Android surface producer automatically handles
  /// correcting the rotation of camera previews for the device this plugin runs on.
  Future<bool> surfaceProducerHandlesCropAndRotationFromInstance() {
    return surfaceProducerHandlesCropAndRotation();
  }
}
