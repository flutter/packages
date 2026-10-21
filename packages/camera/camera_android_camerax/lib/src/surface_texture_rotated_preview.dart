// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';

import 'camerax_library.dart' show TransformationInfo;
import 'rotated_preview_state.dart';
import 'rotated_preview_utils.dart';

/// Widget that rotates the camera preview to be upright according to the
/// current user interface orientation when the preview is backed by a
/// native Android `SurfaceTexture`.
///
/// A `SurfaceTexture` applies the camera transform automatically when its
/// surface is connected to the camera directly. When it is not (e.g. when
/// CameraX copies the camera stream with OpenGL for stream sharing), the
/// preview is corrected the same way as previews backed by an `ImageReader`.
@internal
final class SurfaceTextureRotatedPreview extends RotatedPreview {
  /// Creates [SurfaceTextureRotatedPreview] that will correct the preview
  /// rotation of a camera preview backed by a `SurfaceTexture`.
  const SurfaceTextureRotatedPreview({
    super.key,
    required super.initialDeviceOrientation,
    required super.initialDefaultDisplayRotation,
    required super.deviceOrientationStream,
    required super.deviceOrientationManager,
    required super.initialTransformationInfo,
    required super.transformationInfoStream,
    required super.previewTargetRotation,
    required super.sensorOrientationDegrees,
    required super.cameraIsFrontFacing,
    required super.child,
  });

  @override
  State<StatefulWidget> createState() => _SurfaceTextureRotatedPreviewState();
}

final class _SurfaceTextureRotatedPreviewState extends State<SurfaceTextureRotatedPreview>
    with RotatedPreviewStateMixin<SurfaceTextureRotatedPreview> {
  @override
  Widget build(BuildContext context) {
    return buildWithDefaultDisplayRotation((int defaultDisplayRotation) {
      // Until a TransformationInfo is received, assume the surface is connected
      // to the camera directly.
      final TransformationInfo? info = transformationInfo;
      if (info != null && surfaceIsProcessedByCameraX(info)) {
        // The SurfaceTexture will not apply the camera transform, so the preview
        // needs the same correction as previews backed by an ImageReader.
        return buildUntransformedPreview(
          child: widget.child,
          transformationInfo: transformationInfo,
          cameraIsFrontFacing: widget.cameraIsFrontFacing,
          sensorOrientationDegrees: widget.sensorOrientationDegrees.toInt(),
          displayRotation: defaultDisplayRotation,
          previewTargetRotation: widget.previewTargetRotation,
          deviceOrientation: deviceOrientation,
        );
      }

      // The SurfaceTexture applies the camera transform (the sensor rotation and
      // the mirroring of front camera previews), so only the display rotation
      // remains to be corrected. This relies on the Preview using CameraX's
      // default mirror mode, which the plugin API does not allow changing; see
      // getRemainingRotationDegrees() in CameraX's PreviewTransformation.
      //
      // Rotate the preview according to the current default display rotation,
      // but subtract out the rotation applied by the CameraPreview widget
      // (see camera/camera/lib/src/camera_preview.dart) that is not correct
      // for this plugin.
      final int rotationCorrection =
          getQuarterTurnsFromSurfaceRotationConstant(defaultDisplayRotation) -
          getPreAppliedQuarterTurnsRotationFromDeviceOrientation(deviceOrientation);

      return RotatedBox(quarterTurns: rotationCorrection, child: widget.child);
    });
  }
}
