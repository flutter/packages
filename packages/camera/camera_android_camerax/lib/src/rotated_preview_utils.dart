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

/// Returns the [Surface] rotation constant to use as the target rotation of
/// the camera preview so that a preview buffer copied by CameraX (e.g. for
/// stream sharing) has the same orientation as a buffer the surface receives
/// from the camera directly.
///
/// A surface that [handlesCropAndRotation] (a `SurfaceTexture`) applies the
/// camera transform to direct buffers, making them upright in the natural
/// orientation of the device, so the target rotation is
/// [Surface.rotation0]. Otherwise (an `ImageReader`), direct buffers are in
/// the orientation of the camera sensor, so the target rotation is the one for
/// which CameraX reports a relative rotation of 0 degrees.
int computePreviewTargetRotation({
  required bool handlesCropAndRotation,
  required bool cameraIsFrontFacing,
  required int sensorOrientationDegrees,
}) {
  if (handlesCropAndRotation) {
    return Surface.rotation0;
  }

  final int targetRotationDegrees = cameraIsFrontFacing
      ? (360 - sensorOrientationDegrees) % 360
      : sensorOrientationDegrees % 360;
  return switch (targetRotationDegrees) {
    0 => Surface.rotation0,
    90 => Surface.rotation90,
    180 => Surface.rotation180,
    270 => Surface.rotation270,
    int() => throw ArgumentError(
      '$sensorOrientationDegrees is not a multiple of 90, so the preview target rotation cannot be determined.',
    ),
  };
}

/// Returns the clockwise rotation in degrees needed to display a camera
/// preview buffer upright when the camera transform has not been applied to
/// it, indicated by [TransformationInfo.hasCameraTransform].
///
/// [displayRotation] and [previewTargetRotation] are [Surface] rotation
/// constants, which are clockwise quarter turns. [previewMirroringDisabled]
/// is whether the Preview was created with CameraX
/// mirroring turned off (see [untransformedBufferNeedsMirroring]).
int computeUntransformedPreviewRotation({
  required TransformationInfo? transformationInfo,
  required bool cameraIsFrontFacing,
  required int sensorOrientationDegrees,
  required int displayRotation,
  required int previewTargetRotation,
  required bool previewMirroringDisabled,
}) {
  final int displayRotationDegrees = displayRotation * 90;

  final int rotationDegrees;
  if (transformationInfo != null && !transformationInfo.hasCameraTransform) {
    // TransformationInfo.rotationDegrees is relative to the preview target
    // rotation, which never changes, so shift it by how much the display has
    // rotated since. A raw front camera buffer, which still needs mirroring,
    // turns the opposite way of one that is not.
    final int displayRotationDelta = displayRotationDegrees - previewTargetRotation * 90;
    rotationDegrees =
        untransformedBufferNeedsMirroring(
          transformationInfo: transformationInfo,
          cameraIsFrontFacing: cameraIsFrontFacing,
          previewMirroringDisabled: previewMirroringDisabled,
        )
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

/// Returns whether a camera preview buffer that does not have the camera
/// transform applied needs to be mirrored to be displayed like a mirror for
/// front cameras.
///
/// A buffer from the camera directly ([transformationInfo] is null or has the
/// camera transform) is never mirrored, so it needs to be mirrored for front
/// cameras. A buffer copied by CameraX (e.g. for stream sharing) needs to be
/// mirrored if [TransformationInfo.isMirroring] says so, unless
/// [previewMirroringDisabled] is true. In that case, the Preview was created
/// with CameraX mirroring turned off, so CameraX never mirrors the buffers
/// it copies and reports that they do not need mirroring, and front camera
/// buffers need to be mirrored like buffers from the camera directly.
bool untransformedBufferNeedsMirroring({
  required TransformationInfo? transformationInfo,
  required bool cameraIsFrontFacing,
  required bool previewMirroringDisabled,
}) {
  if (transformationInfo == null ||
      transformationInfo.hasCameraTransform ||
      previewMirroringDisabled) {
    return cameraIsFrontFacing;
  }
  return transformationInfo.isMirroring;
}

/// Rotates, and mirrors if needed, [child], a camera preview whose buffer does
/// not have the camera transform applied, so that it is upright according to
/// the current user interface orientation.
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
  required bool previewMirroringDisabled,
  required DeviceOrientation deviceOrientation,
}) {
  final int bufferRotationDegrees = computeUntransformedPreviewRotation(
    transformationInfo: transformationInfo,
    cameraIsFrontFacing: cameraIsFrontFacing,
    sensorOrientationDegrees: sensorOrientationDegrees,
    displayRotation: displayRotation,
    previewTargetRotation: previewTargetRotation,
    previewMirroringDisabled: previewMirroringDisabled,
  );

  // Subtract the rotation already applied in the CameraPreview widget
  // (see camera/camera/lib/src/camera_preview.dart) that is not correct
  // for this plugin.
  final int rotationDegrees =
      bufferRotationDegrees -
      getPreAppliedQuarterTurnsRotationFromDeviceOrientation(deviceOrientation) * 90;

  final bool shouldMirror = untransformedBufferNeedsMirroring(
    transformationInfo: transformationInfo,
    cameraIsFrontFacing: cameraIsFrontFacing,
    previewMirroringDisabled: previewMirroringDisabled,
  );
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
