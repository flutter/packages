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

/// Use case for picture taking.
///
/// See https://developer.android.com/reference/androidx/camera/core/ImageCapture.
@immutable
class ImageCapture extends UseCase {
  /// Creates an [ImageCapture].
  ImageCapture({
    BinaryMessenger? binaryMessenger,
    InstanceManager? instanceManager,
    this.initialTargetRotation,
    this.targetFlashMode,
    this.resolutionSelector,
  }) : super.detached(
          binaryMessenger: binaryMessenger,
          instanceManager: instanceManager,
        ) {
    _api = ImageCaptureHostApiImpl(
        binaryMessenger: binaryMessenger, instanceManager: instanceManager);
    _api.createFromInstance(
        this, initialTargetRotation, targetFlashMode, resolutionSelector);
  }

  /// Constructs an [ImageCapture] that is not automatically attached to a
  /// native object.
  ImageCapture.detached({
    BinaryMessenger? binaryMessenger,
    InstanceManager? instanceManager,
    this.initialTargetRotation,
    this.targetFlashMode,
    this.resolutionSelector,
  }) : super.detached(
          binaryMessenger: binaryMessenger,
          instanceManager: instanceManager,
        ) {
    _api = ImageCaptureHostApiImpl(
        binaryMessenger: binaryMessenger, instanceManager: instanceManager);
  }

  late final ImageCaptureHostApiImpl _api;

  /// Initial target rotation of the camera used for the preview stream.
  ///
  /// Should be specified in terms of one of the [Surface]
  /// rotation constants that represents the counter-clockwise degrees of
  /// rotation relative to [DeviceOrientation.portraitUp].
  ///
  // TODO(camsim99): Remove this parameter. https://github.com/flutter/flutter/issues/140664
  final int? initialTargetRotation;

  /// Flash mode used to take a picture.
  final int? targetFlashMode;

  /// Target resolution of the image output from taking a picture.
  ///
  /// If not set, this [UseCase] will default to the behavior described in:
  /// https://developer.android.com/reference/androidx/camera/core/ImageCapture.Builder#setResolutionSelector(androidx.camera.core.resolutionselector.ResolutionSelector).
  final ResolutionSelector? resolutionSelector;

  /// Constant for automatic flash mode.
  ///
  /// See https://developer.android.com/reference/androidx/camera/core/ImageCapture#FLASH_MODE_AUTO().
  static const int flashModeAuto = 0;

  /// Constant for on flash mode.
  ///
  /// See https://developer.android.com/reference/androidx/camera/core/ImageCapture#FLASH_MODE_ON().
  static const int flashModeOn = 1;

  /// Constant for no flash mode.
  ///
  /// See https://developer.android.com/reference/androidx/camera/core/ImageCapture#FLASH_MODE_OFF().
  static const int flashModeOff = 2;

  /// Dynamically sets the target rotation of this instance.
  ///
  /// [rotation] should be specified in terms of one of the [Surface]
  /// rotation constants that represents the counter-clockwise degrees of
  /// rotation relative to [DeviceOrientation.portraitUp].
  Future<void> setTargetRotation(int rotation) =>
      _api.setTargetRotationFromInstances(this, rotation);

  /// Sets the flash mode to use for image capture.
  Future<void> setFlashMode(int newFlashMode) async {
    return _api.setFlashModeFromInstances(this, newFlashMode);
  }

  /// Takes a picture and returns the absolute path of where the capture image
  /// was saved.
  ///
  /// This method is not a direct mapping of the takePicture method in the CameraX,
  /// as it also:
  ///
  ///  * Configures an instance of the ImageCapture.OutputFileOptions to specify
  ///    how to handle the captured image.
  ///  * Configures an instance of ImageCapture.OnImageSavedCallback to receive
  ///    the results of the image capture as an instance of
  ///    ImageCapture.OutputFileResults.
  ///  * Converts the ImageCapture.OutputFileResults output instance to a String
  ///    that represents the full path where the captured image was saved in
  ///    memory to return.
  ///
  /// See https://developer.android.com/reference/androidx/camera/core/ImageCapture
  /// for more information.
  Future<String> takePicture() async {
    return _api.takePictureFromInstances(this);
  }
}

/// Host API implementation of [ImageCapture].
class ImageCaptureHostApiImpl extends ImageCaptureHostApi {
  /// Constructs a [ImageCaptureHostApiImpl].
  ///
  /// If [binaryMessenger] is null, the default [BinaryMessenger] will be used,
  /// which routes to the host platform.
  ///
  /// An [instanceManager] is typically passed when a copy of an instance
  /// contained by an [InstanceManager] is being created. If left null, it
  /// will default to the global instance defined in [JavaObject].
  ImageCaptureHostApiImpl(
      {this.binaryMessenger, InstanceManager? instanceManager}) {
    this.instanceManager = instanceManager ?? JavaObject.globalInstanceManager;
  }

  /// Receives binary data across the Flutter platform barrier.
  ///
  /// If it is null, the default [BinaryMessenger] will be used which routes to
  /// the host platform.
  final BinaryMessenger? binaryMessenger;

  /// Maintains instances stored to communicate with native language objects.
  late final InstanceManager instanceManager;

  /// Creates an [ImageCapture] instance with the flash mode and target resolution
  /// if specified.
  void createFromInstance(ImageCapture instance, int? targetRotation,
      int? targetFlashMode, ResolutionSelector? resolutionSelector) {
    final int identifier = instanceManager.addDartCreatedInstance(instance,
        onCopy: (ImageCapture original) {
      return ImageCapture.detached(
          binaryMessenger: binaryMessenger,
          instanceManager: instanceManager,
          initialTargetRotation: original.initialTargetRotation,
          targetFlashMode: original.targetFlashMode,
          resolutionSelector: original.resolutionSelector);
    });
    create(
        identifier,
        targetRotation,
        targetFlashMode,
        resolutionSelector == null
            ? null
            : instanceManager.getIdentifier(resolutionSelector));
  }

  /// Dynamically sets the target rotation of [instance] to [rotation].
  Future<void> setTargetRotationFromInstances(
      ImageCapture instance, int rotation) {
    return setTargetRotation(
        instanceManager.getIdentifier(instance)!, rotation);
  }

  /// Sets the flash mode for the specified [ImageCapture] instance to take
  /// a picture with.
  Future<void> setFlashModeFromInstances(
      ImageCapture instance, int flashMode) async {
    final int? identifier = instanceManager.getIdentifier(instance);
    assert(identifier != null,
        'No ImageCapture has the identifer of that requested to get the resolution information for.');

    await setFlashMode(identifier!, flashMode);
  }

  /// Takes a picture with the specified [ImageCapture] instance.
  Future<String> takePictureFromInstances(ImageCapture instance) async {
    final int? identifier = instanceManager.getIdentifier(instance);
    assert(identifier != null,
        'No ImageCapture has the identifer of that requested to get the resolution information for.');

    final String picturePath = await takePicture(identifier!);
    return picturePath;
  }
}
