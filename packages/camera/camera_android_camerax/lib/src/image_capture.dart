// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/services.dart' show BinaryMessenger;

import 'camerax_library.g.dart';
import 'instance_manager.dart';
import 'java_object.dart';
import 'use_case.dart';

/// Use case for picture taking.
///
/// See https://developer.android.com/reference/androidx/camera/core/ImageCapture.
class ImageCapture extends UseCase {
  /// Creates a [ImageCapture].
  ImageCapture(
      {BinaryMessenger? binaryMessenger,
      InstanceManager? instanceManager,
      this.targetFlashMode,
      this.targetResolution})
      : super.detached(
            binaryMessenger: binaryMessenger,
            instanceManager: instanceManager) {
    _api = ImageCaptureHostApiImpl(
        binaryMessenger: binaryMessenger, instanceManager: instanceManager);
    _api.createFromInstance(this, targetFlashMode, targetResolution);
  }

  /// Constructs a [ImageCapture] that is not automatically attached to a native object.
  ImageCapture.detached(
      {BinaryMessenger? binaryMessenger,
      InstanceManager? instanceManager,
      this.targetFlashMode,
      this.targetResolution})
      : super.detached(
            binaryMessenger: binaryMessenger,
            instanceManager: instanceManager) {
    _api = ImageCaptureHostApiImpl(
        binaryMessenger: binaryMessenger, instanceManager: instanceManager);
  }

  late final ImageCaptureHostApiImpl _api;

  /// Flash mode used to take a picture.
  final int? targetFlashMode;

  /// Target resolution of the image output from taking a picture.
  final ResolutionInfo? targetResolution;

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

  /// Sets the flash mode to use for image capture.
  void setFlashMode(int newFlashMode) {
    _api.setFlashModeFromInstance(this, newFlashMode);
  }

  /// Takes a picture and returns the absolute path of where the capture image
  /// was saved.
  Future<String> takePicture() async {
    final String pictureFile = await _api.takePictureFromInstance(this);
    return pictureFile;
  }
}

/// Host API implementation of [ImageCapture].
class ImageCaptureHostApiImpl extends ImageCaptureHostApi {
  /// Constructs a [ImageCaptureHostApiImpl].
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

  /// Creates a [ImageCapture] instance with the flash mode and target resolution
  /// if specified.
  void createFromInstance(ImageCapture instance, int? targetFlashMode,
      ResolutionInfo? targetResolution) {
    final int identifier = instanceManager.addDartCreatedInstance(instance,
        onCopy: (ImageCapture original) {
      return ImageCapture.detached(
          binaryMessenger: binaryMessenger,
          instanceManager: instanceManager,
          targetFlashMode: original.targetFlashMode,
          targetResolution: original.targetResolution);
    });
    create(identifier, targetFlashMode, targetResolution);
  }

  /// Sets the flash mode for the specified [ImageCapture] instance to take
  /// a picture with.
  void setFlashModeFromInstance(ImageCapture instance, int flashMode) {
    final int? identifier = instanceManager.getIdentifier(instance);
    assert(identifier != null,
        'No ImageCapture has the identifer of that requested to get the resolution information for.');

    setFlashMode(identifier!, flashMode);
  }

  /// Takes a picture with the specified [ImageCapture] instance.
  Future<String> takePictureFromInstance(ImageCapture instance) async {
    final int? identifier = instanceManager.getIdentifier(instance);
    assert(identifier != null,
        'No ImageCapture has the identifer of that requested to get the resolution information for.');

    final String picturePath = await takePicture(identifier!);
    return picturePath;
  }
}
