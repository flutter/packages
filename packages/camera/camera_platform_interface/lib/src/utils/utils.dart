// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/services.dart';

import '../../camera_platform_interface.dart';

/// Parses a string into a corresponding CameraLensDirection.
CameraLensDirection parseCameraLensDirection(String string) {
  switch (string) {
    case 'front':
      return CameraLensDirection.front;
    case 'back':
      return CameraLensDirection.back;
    case 'external':
      return CameraLensDirection.external;
  }
  throw ArgumentError('Unknown CameraLensDirection value');
}

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
}

/// Returns the device orientation for a given String.
DeviceOrientation deserializeDeviceOrientation(String str) {
  switch (str) {
    case 'portraitUp':
      return DeviceOrientation.portraitUp;
    case 'portraitDown':
      return DeviceOrientation.portraitDown;
    case 'landscapeRight':
      return DeviceOrientation.landscapeRight;
    case 'landscapeLeft':
      return DeviceOrientation.landscapeLeft;
    default:
      throw ArgumentError('"$str" is not a valid DeviceOrientation value');
  }
}
