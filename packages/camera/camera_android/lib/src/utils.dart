// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:math';

import 'package:camera_platform_interface/camera_platform_interface.dart';
import 'package:flutter/services.dart';

import 'messages.g.dart';

/// Converts a [PlatformCameraLensDirection] to [CameraLensDirection].
CameraLensDirection cameraLensDirectionFromPlatform(
    PlatformCameraLensDirection direction) {
  return switch (direction) {
    PlatformCameraLensDirection.front => CameraLensDirection.front,
    PlatformCameraLensDirection.back => CameraLensDirection.back,
    PlatformCameraLensDirection.external => CameraLensDirection.external,
  };
}

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
        DeviceOrientation orientation) =>
    switch (orientation) {
      DeviceOrientation.portraitUp => PlatformDeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown => PlatformDeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft =>
        PlatformDeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight =>
        PlatformDeviceOrientation.landscapeRight,
    };

/// Converts a [PlatformExposureMode] to [ExposureMode].
ExposureMode exposureModeFromPlatform(PlatformExposureMode exposureMode) =>
    switch (exposureMode) {
      PlatformExposureMode.auto => ExposureMode.auto,
      PlatformExposureMode.locked => ExposureMode.locked,
    };

/// Converts a [ExposureMode] to [PlatformExposureMode].
PlatformExposureMode exposureModeToPlatform(ExposureMode exposureMode) =>
    switch (exposureMode) {
      ExposureMode.auto => PlatformExposureMode.auto,
      ExposureMode.locked => PlatformExposureMode.locked,
    };

/// Converts a [PlatformFocusMode] to [FocusMode].
FocusMode focusModeFromPlatform(PlatformFocusMode focusMode) =>
    switch (focusMode) {
      PlatformFocusMode.auto => FocusMode.auto,
      PlatformFocusMode.locked => FocusMode.locked,
    };

/// Converts a [FocusMode] to [PlatformFocusMode].
PlatformFocusMode focusModeToPlatform(FocusMode focusMode) =>
    switch (focusMode) {
      FocusMode.auto => PlatformFocusMode.auto,
      FocusMode.locked => PlatformFocusMode.locked,
    };

/// Converts a [ResolutionPreset] to [PlatformResolutionPreset].
PlatformResolutionPreset resolutionPresetToPlatform(ResolutionPreset? preset) =>
    switch (preset) {
      ResolutionPreset.low => PlatformResolutionPreset.low,
      ResolutionPreset.medium => PlatformResolutionPreset.medium,
      ResolutionPreset.high => PlatformResolutionPreset.high,
      ResolutionPreset.veryHigh => PlatformResolutionPreset.veryHigh,
      ResolutionPreset.ultraHigh => PlatformResolutionPreset.ultraHigh,
      ResolutionPreset.max => PlatformResolutionPreset.max,
      null => PlatformResolutionPreset.high,
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
PlatformImageFormatGroup imageFormatGroupToPlatform(ImageFormatGroup format) =>
    switch (format) {
      ImageFormatGroup.unknown => PlatformImageFormatGroup.yuv420,
      ImageFormatGroup.yuv420 => PlatformImageFormatGroup.yuv420,
      ImageFormatGroup.bgra8888 => PlatformImageFormatGroup.yuv420,
      ImageFormatGroup.jpeg => PlatformImageFormatGroup.jpeg,
      ImageFormatGroup.nv21 => PlatformImageFormatGroup.nv21,
    };

/// Converts a [FlashMode] to [PlatformFlashMode].
PlatformFlashMode flashModeToPlatform(FlashMode mode) => switch (mode) {
      FlashMode.auto => PlatformFlashMode.auto,
      FlashMode.off => PlatformFlashMode.off,
      FlashMode.always => PlatformFlashMode.always,
      FlashMode.torch => PlatformFlashMode.torch,
    };

/// Converts a [Point<double>] to [PlatformPoint].
///
/// Null becomes null.
PlatformPoint? pointToPlatform(Point<double>? point) =>
    (point != null) ? PlatformPoint(x: point.x, y: point.y) : null;
