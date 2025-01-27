// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:math';

import 'package:camera_platform_interface/camera_platform_interface.dart';
import 'package:flutter/services.dart';

import 'messages.g.dart';

/// Converts a [PlatformCameraLensDirection] to [CameraLensDirection].
CameraLensDirection cameraLensDirectionFromPlatform(
        PlatformCameraLensDirection direction) =>
    switch (direction) {
      PlatformCameraLensDirection.front => CameraLensDirection.front,
      PlatformCameraLensDirection.back => CameraLensDirection.back,
      PlatformCameraLensDirection.external => CameraLensDirection.external,
    };

/// Converts a [PlatformDeviceOrientation] to [DeviceOrientation].
DeviceOrientation deviceOrientationFromPlatform(
        PlatformDeviceOrientation orientation) =>
    switch (orientation) {
      PlatformDeviceOrientation.portraitUp => DeviceOrientation.portraitUp,
      PlatformDeviceOrientation.portraitDown => DeviceOrientation.portraitDown,
      PlatformDeviceOrientation.landscapeLeft =>
        DeviceOrientation.landscapeLeft,
      PlatformDeviceOrientation.landscapeRight =>
        DeviceOrientation.landscapeRight,
    };

/// Converts a [DeviceOrientation] to [PlatformDeviceOrientation].
PlatformDeviceOrientation deviceOrientationToPlatform(
    DeviceOrientation orientation) {
  switch (orientation) {
    case DeviceOrientation.portraitUp:
      return PlatformDeviceOrientation.portraitUp;
    case DeviceOrientation.portraitDown:
      return PlatformDeviceOrientation.portraitDown;
    case DeviceOrientation.landscapeLeft:
      return PlatformDeviceOrientation.landscapeLeft;
    case DeviceOrientation.landscapeRight:
      return PlatformDeviceOrientation.landscapeRight;
  }
  // This enum is defined outside of this package. This fall-through case
  // ensures that the code does not break if a new value is ever added.
  // ignore: dead_code
  return PlatformDeviceOrientation.portraitUp;
}

/// Converts a [PlatformExposureMode] to [ExposureMode].
ExposureMode exposureModeFromPlatform(PlatformExposureMode exposureMode) =>
    switch (exposureMode) {
      PlatformExposureMode.auto => ExposureMode.auto,
      PlatformExposureMode.locked => ExposureMode.locked,
    };

/// Converts a [ExposureMode] to [PlatformExposureMode].
PlatformExposureMode exposureModeToPlatform(ExposureMode exposureMode) {
  switch (exposureMode) {
    case ExposureMode.auto:
      return PlatformExposureMode.auto;
    case ExposureMode.locked:
      return PlatformExposureMode.locked;
  }
  // This enum is defined outside of this package. This fall-through case
  // ensures that the code does not break if a new value is ever added.
  // ignore: dead_code
  return PlatformExposureMode.auto;
}

/// Converts a [PlatformFocusMode] to [FocusMode].
FocusMode focusModeFromPlatform(PlatformFocusMode focusMode) =>
    switch (focusMode) {
      PlatformFocusMode.auto => FocusMode.auto,
      PlatformFocusMode.locked => FocusMode.locked,
    };

/// Converts a [FocusMode] to [PlatformFocusMode].
PlatformFocusMode focusModeToPlatform(FocusMode focusMode) {
  switch (focusMode) {
    case FocusMode.auto:
      return PlatformFocusMode.auto;
    case FocusMode.locked:
      return PlatformFocusMode.locked;
  }
  // This enum is defined outside of this package. This fall-through case
  // ensures that the code does not break if a new value is ever added.
  // ignore: dead_code
  return PlatformFocusMode.auto;
}

/// Converts a [ResolutionPreset] to [PlatformResolutionPreset].
PlatformResolutionPreset resolutionPresetToPlatform(ResolutionPreset? preset) =>
    switch (preset) {
      ResolutionPreset.low => PlatformResolutionPreset.low,
      ResolutionPreset.medium => PlatformResolutionPreset.medium,
      ResolutionPreset.high => PlatformResolutionPreset.high,
      ResolutionPreset.veryHigh => PlatformResolutionPreset.veryHigh,
      ResolutionPreset.ultraHigh => PlatformResolutionPreset.ultraHigh,
      ResolutionPreset.max => PlatformResolutionPreset.max,
      _ => PlatformResolutionPreset.high,
    };

/// Converts a [MediaSettings] to [PlatformMediaSettings].
PlatformMediaSettings mediaSettingsToPlatform(MediaSettings? settings) =>
    PlatformMediaSettings(
        resolutionPreset:
            resolutionPresetToPlatform(settings?.resolutionPreset),
        enableAudio: settings?.enableAudio ?? false,
        videoBitrate: settings?.videoBitrate,
        audioBitrate: settings?.audioBitrate,
        fps: settings?.fps);

/// Converts an [ImageFormatGroup] to [PlatformImageFormatGroup].
///
/// [ImageFormatGroup.unknown] and [ImageFormatGroup.bgra8888] default to
/// [PlatformImageFormatGroup.yuv420], which is the default on Android.
PlatformImageFormatGroup imageFormatGroupToPlatform(ImageFormatGroup format) {
  switch (format) {
    case ImageFormatGroup.unknown:
      return PlatformImageFormatGroup.yuv420;
    case ImageFormatGroup.yuv420:
      return PlatformImageFormatGroup.yuv420;
    case ImageFormatGroup.bgra8888:
      return PlatformImageFormatGroup.yuv420;
    case ImageFormatGroup.jpeg:
      return PlatformImageFormatGroup.jpeg;
    case ImageFormatGroup.nv21:
      return PlatformImageFormatGroup.nv21;
  }
  // This enum is defined outside of this package. This fall-through case
  // ensures that the code does not break if a new value is ever added.
  // ignore: dead_code
  return PlatformImageFormatGroup.yuv420;
}

/// Converts a [FlashMode] to [PlatformFlashMode].
PlatformFlashMode flashModeToPlatform(FlashMode mode) {
  switch (mode) {
    case FlashMode.auto:
      return PlatformFlashMode.auto;
    case FlashMode.off:
      return PlatformFlashMode.off;
    case FlashMode.always:
      return PlatformFlashMode.always;
    case FlashMode.torch:
      return PlatformFlashMode.torch;
  }
  // This enum is defined outside of this package. This fall-through case
  // ensures that the code does not break if a new value is ever added.
  // ignore: dead_code
  return PlatformFlashMode.auto;
}

/// Converts a [Point<double>] to [PlatformPoint].
///
/// Null becomes null.
PlatformPoint? pointToPlatform(Point<double>? point) =>
    (point != null) ? PlatformPoint(x: point.x, y: point.y) : null;
