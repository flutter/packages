// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';

import 'rotated_preview_state.dart';
import 'rotated_preview_utils.dart';

/// Widget that rotates the camera preview to be upright according to the
/// current user interface orientation for devices using the `ImageReader`
/// Impeller backend, which does not automatically handle the crop and
/// rotation of the camera preview correctly.
@internal
final class ImageReaderRotatedPreview extends RotatedPreview {
  /// Creates [ImageReaderRotatedPreview] that will correct the preview
  /// rotation of a camera preview backed by an `ImageReader`.
  const ImageReaderRotatedPreview({
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
  State<StatefulWidget> createState() => _ImageReaderRotatedPreviewState();
}

final class _ImageReaderRotatedPreviewState extends State<ImageReaderRotatedPreview>
    with RotatedPreviewStateMixin<ImageReaderRotatedPreview> {
  @override
  Widget build(BuildContext context) {
    // An ImageReader ignores the camera transform, so the preview always needs
    // to be fully rotated (and mirrored, if needed).
    return buildWithDefaultDisplayRotation(
      (int defaultDisplayRotation) => buildUntransformedPreview(
        child: widget.child,
        transformationInfo: transformationInfo,
        cameraIsFrontFacing: widget.cameraIsFrontFacing,
        sensorOrientationDegrees: widget.sensorOrientationDegrees.toInt(),
        displayRotation: defaultDisplayRotation,
        previewTargetRotation: widget.previewTargetRotation,
        deviceOrientation: deviceOrientation,
      ),
    );
  }
}
