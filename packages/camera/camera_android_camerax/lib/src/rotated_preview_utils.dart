// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'camerax_library.dart' show Surface, TransformationInfo;

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
int getPreAppliedQuarterTurnsRotationFromDeviceOrientation(DeviceOrientation orientation) {
  return switch (orientation) {
    DeviceOrientation.portraitUp => 0,
    DeviceOrientation.landscapeRight => 1,
    DeviceOrientation.portraitDown => 2,
    DeviceOrientation.landscapeLeft => 3,
  };
}

/// Returns the clockwise rotation in degrees needed to display a camera
/// preview buffer upright when the camera transform has not been applied to
/// it.
///
/// This is the case for previews backed by an `ImageReader`, which ignores the
/// camera transform, and for previews whose surface is not connected to the
/// camera directly (e.g. when CameraX copies the camera stream with OpenGL for
/// stream sharing), indicated by [TransformationInfo.hasCameraTransform] being
/// false. Only in the latter case may the buffer not be in the orientation of
/// the camera sensor, so only then is [transformationInfo] used.
///
/// [displayRotation] and [previewTargetRotation] are [Surface] rotation
/// constants, which are clockwise quarter turns.
int computeUntransformedPreviewRotation({
  required TransformationInfo? transformationInfo,
  required bool cameraIsFrontFacing,
  required int sensorOrientationDegrees,
  required int displayRotation,
  required int previewTargetRotation,
}) {
  final int displayRotationDegrees = displayRotation * 90;

  final int rotationDegrees;
  if (transformationInfo != null && !transformationInfo.hasCameraTransform) {
    // TransformationInfo.rotationDegrees is relative to the preview target
    // rotation, which never changes, so shift it by how much the display has
    // rotated since. A buffer that is still a mirror image of the scene (a raw
    // front camera buffer, which is exactly when isMirroring is true with
    // CameraX's default mirror mode) turns the opposite way of one that is not.
    final int displayRotationDelta = displayRotationDegrees - previewTargetRotation * 90;
    rotationDegrees = transformationInfo.isMirroring
        ? transformationInfo.rotationDegrees + displayRotationDelta
        : transformationInfo.rotationDegrees - displayRotationDelta;
  } else {
    // See https://developer.android.com/media/camera/camera2/camera-preview#orientation_calculation.
    rotationDegrees = cameraIsFrontFacing
        ? sensorOrientationDegrees + displayRotationDegrees
        : sensorOrientationDegrees - displayRotationDegrees;
  }

  return rotationDegrees % 360;
}

/// Rotates, and mirrors if needed, [child], a camera preview whose buffer does
/// not have the camera transform applied, so that it is upright according to
/// the current user interface orientation.
///
/// See [computeUntransformedPreviewRotation] for the cases where the camera
/// transform is not applied.
///
/// [displayRotation] and [previewTargetRotation] are [Surface] rotation
/// constants.
Widget buildUntransformedPreview({
  required Widget child,
  required TransformationInfo? transformationInfo,
  required bool cameraIsFrontFacing,
  required int sensorOrientationDegrees,
  required int displayRotation,
  required int previewTargetRotation,
  required DeviceOrientation deviceOrientation,
}) {
  final int bufferRotationDegrees = computeUntransformedPreviewRotation(
    transformationInfo: transformationInfo,
    cameraIsFrontFacing: cameraIsFrontFacing,
    sensorOrientationDegrees: sensorOrientationDegrees,
    displayRotation: displayRotation,
    previewTargetRotation: previewTargetRotation,
  );

  // Subtract the rotation already applied in the CameraPreview widget
  // (see camera/camera/lib/src/camera_preview.dart) that is not correct
  // for this plugin.
  final int rotationDegrees =
      bufferRotationDegrees -
      getPreAppliedQuarterTurnsRotationFromDeviceOrientation(deviceOrientation) * 90;

  final bool shouldMirror = transformationInfo != null && !transformationInfo.hasCameraTransform
      ? transformationInfo.isMirroring
      : cameraIsFrontFacing;
  var cameraPreview = child;
  if (shouldMirror) {
    // The preview must be mirrored across the vertical axis after it is
    // rotated by bufferRotationDegrees in total, so before a quarter or three
    // quarter turn, it is mirrored across the horizontal axis instead.
    cameraPreview = bufferRotationDegrees % 180 == 90
        ? Transform.scale(scaleY: -1, child: cameraPreview)
        : Transform.scale(scaleX: -1, child: cameraPreview);
  }

  return RotatedBox(quarterTurns: rotationDegrees ~/ 90, child: cameraPreview);
}
