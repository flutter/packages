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
/// camera transform, and for previews backed by a `SurfaceTexture` whose
/// surface is not connected to the camera directly (e.g. when CameraX copies
/// the camera stream with OpenGL for stream sharing).
///
/// The rotation is only taken from [transformationInfo] when its surface does
/// not have the camera transform (see [surfaceIsProcessedByCameraX]), as the
/// buffer may then not be in the orientation of the camera sensor. Otherwise,
/// the rotation is calculated from the orientation of the camera sensor so that
/// it is unchanged from before [TransformationInfo] was used.
///
/// [displayRotation] and [previewTargetRotation] are [Surface] rotation
/// constants. [Surface] rotation constants are clockwise quarter turns
/// (`0..3`), so their degrees are `constant * 90`.
int computeUntransformedPreviewRotation({
  required TransformationInfo? transformationInfo,
  required bool cameraIsFrontFacing,
  required int sensorOrientationDegrees,
  required int displayRotation,
  required int previewTargetRotation,
}) {
  final int displayRotationDegrees = displayRotation * 90;

  final int rotationDegrees;
  if (transformationInfo != null && surfaceIsProcessedByCameraX(transformationInfo)) {
    // rotationDegrees is computed by CameraX for the preview target rotation and
    // accounts for any rotation CameraX already applied to the buffer (e.g. under
    // stream sharing). The preview target rotation never changes, so shift
    // rotationDegrees by how much the display has rotated since then.
    //
    // The direction of the shift depends on which way the buffer content turns
    // when the device rotates: the opposite way for raw back camera buffers and
    // the same way for raw front camera buffers. A front camera buffer that
    // CameraX has already mirrored (e.g. by an OpenGL copy for stream sharing)
    // turns like a back camera buffer. With CameraX's default Preview mirror
    // mode, which this plugin does not allow changing, isMirroring is true
    // exactly for raw front camera buffers, so it determines the direction.
    final int displayRotationDelta = displayRotationDegrees - previewTargetRotation * 90;
    rotationDegrees = transformationInfo.isMirroring
        ? transformationInfo.rotationDegrees + displayRotationDelta
        : transformationInfo.rotationDegrees - displayRotationDelta;
  } else {
    // Rotate the camera preview according to
    // https://developer.android.com/media/camera/camera2/camera-preview#orientation_calculation,
    // assuming the buffer is in the orientation of the camera sensor.
    rotationDegrees = cameraIsFrontFacing
        ? sensorOrientationDegrees + displayRotationDegrees
        : sensorOrientationDegrees - displayRotationDegrees;
  }

  // Dart's % always returns a non-negative result for a positive divisor.
  return rotationDegrees % 360;
}

/// Whether or not the preview surface described by [transformationInfo] is
/// not connected to the camera directly, so CameraX may have processed (e.g.
/// rotated or mirrored) its buffer before providing it.
///
/// This is the case when CameraX copies the camera stream with OpenGL, for
/// example for stream sharing.
bool surfaceIsProcessedByCameraX(TransformationInfo transformationInfo) {
  return !transformationInfo.hasCameraTransform;
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
  final int rotationDegrees =
      computeUntransformedPreviewRotation(
        transformationInfo: transformationInfo,
        cameraIsFrontFacing: cameraIsFrontFacing,
        sensorOrientationDegrees: sensorOrientationDegrees,
        displayRotation: displayRotation,
        previewTargetRotation: previewTargetRotation,
      ) -
      // Subtract the rotation already applied in the CameraPreview widget
      // (see camera/camera/lib/src/camera_preview.dart) that is not correct
      // for this plugin.
      getPreAppliedQuarterTurnsRotationFromDeviceOrientation(deviceOrientation) * 90;

  // If CameraX may have processed the buffer, mirror the camera preview only if
  // CameraX reports that the buffer still needs to be mirrored. Otherwise, the
  // buffer comes directly from the camera, so mirror front facing camera
  // previews.
  final bool shouldMirror =
      transformationInfo != null && surfaceIsProcessedByCameraX(transformationInfo)
      ? transformationInfo.isMirroring
      : cameraIsFrontFacing;
  var cameraPreview = child;
  if (shouldMirror) {
    if (deviceOrientation == DeviceOrientation.portraitDown ||
        deviceOrientation == DeviceOrientation.portraitUp) {
      cameraPreview = Transform.scale(scaleY: -1, child: cameraPreview);
    } else {
      cameraPreview = Transform.scale(scaleX: -1, child: cameraPreview);
    }
  }

  return RotatedBox(quarterTurns: rotationDegrees ~/ 90, child: cameraPreview);
}
