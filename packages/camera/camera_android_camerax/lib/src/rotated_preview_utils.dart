// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/services.dart';

import 'camerax_library.dart' show Surface;

/// Returns the number of counter-clockwise quarter turns represented by
/// [surfaceRotationConstant], a [Surface] constant representing a clockwise
/// rotation.
int getQuarterTurnsFromSurfaceRotationConstant(int surfaceRotationConstant) {
  return switch (surfaceRotationConstant) {
    Surface.rotation0 => 0,
    Surface.rotation90 => 3,
    Surface.rotation180 => 2,
    Surface.rotation270 => 1,
    int() => throw ArgumentError(
      '$surfaceRotationConstant is an unknown Surface rotation constant, so counter-clockwise quarter turns cannot be determined.',
    ),
  };
}

/// Returns the clockwise quarter turns applied by the CameraPreview widget
/// based on [orientation], the current device orientation (see
/// camera/camera/lib/src/camera_preview.dart).
int getPreAppliedQuarterTurnsRotationFromDeviceOrientation(
  DeviceOrientation orientation,
) {
  return switch (orientation) {
    DeviceOrientation.portraitUp => 0,
    DeviceOrientation.landscapeRight => 1,
    DeviceOrientation.portraitDown => 2,
    DeviceOrientation.landscapeLeft => 3,
  };
}
