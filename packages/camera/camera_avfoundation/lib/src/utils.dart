// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:camera_platform_interface/camera_platform_interface.dart';
import 'package:flutter/services.dart';

import '../camera_avfoundation.dart';

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

/// Parses the [type] into an [AVCaptureDeviceType].
AVCaptureDeviceType? parseAVCaptureDeviceType(String type) {
  switch (type) {
    case 'builtInWideAngleCamera':
      return AVCaptureDeviceType.builtInWideAngleCamera;
    case 'builtInUltraWideCamera':
      return AVCaptureDeviceType.builtInUltraWideCamera;
    case 'builtInTelephotoCamera':
      return AVCaptureDeviceType.builtInTelephotoCamera;
    case 'builtInDualCamera':
      return AVCaptureDeviceType.builtInDualCamera;
    case 'builtInDualWideCamera':
      return AVCaptureDeviceType.builtInDualWideCamera;
    case 'builtInTripleCamera':
      return AVCaptureDeviceType.builtInTripleCamera;
    case 'continuityCamera':
      return AVCaptureDeviceType.continuityCamera;
    case 'external':
      return AVCaptureDeviceType.external;
    case 'builtInLiDARDepthCamera':
      return AVCaptureDeviceType.builtInLiDARDepthCamera;
    case 'builtInTrueDepthCamera':
      return AVCaptureDeviceType.builtInTrueDepthCamera;
  }
  // unknown type
  return null;
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
  // The enum comes from a different package, which could get a new value at
  // any time, so provide a fallback that ensures this won't break when used
  // with a version that contains new values. This is deliberately outside
  // the switch rather than a `default` so that the linter will flag the
  // switch as needing an update.
  // ignore: dead_code
  return 'portraitUp';
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
