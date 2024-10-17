// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

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

/// Converts a [PlatformExposureMode] to [ExposureMode].
ExposureMode exposureModeFromPlatform(PlatformExposureMode exposureMode) =>
    switch (exposureMode) {
      PlatformExposureMode.auto => ExposureMode.auto,
      PlatformExposureMode.locked => ExposureMode.locked,
    };

/// Converts a [PlatformFocusMode] to [FocusMode].
FocusMode focusModeFromPlatform(PlatformFocusMode focusMode) =>
    switch (focusMode) {
      PlatformFocusMode.auto => FocusMode.auto,
      PlatformFocusMode.locked => FocusMode.locked,
    };

/// Returns the device orientation as a String.
String serializeDeviceOrientation(DeviceOrientation orientation) {
  switch (orientation) {
    case DeviceOrientation.portraitUp:
      return 'portraitUp';
    case DeviceOrientation.portraitDown:
      return 'portraitDown';
    case DeviceOrientation.landscapeRight:
      return 'landscapeRight';
    case DeviceOrientation.landscapeLeft:
      return 'landscapeLeft';
  }
  // The enum comes from a different package, which could get a new value at
  // any time, so provide a fallback that ensures this won't break when used
  // with a version that contains new values. This is deliberately outside
  // the switch rather than a `default` so that the linter will flag the
  // switch as needing an update.
  // ignore: dead_code
  return 'portraitUp';
}
