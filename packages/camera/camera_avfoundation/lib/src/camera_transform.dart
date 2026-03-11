// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// A normalized rectangle within the (0,1) coordinate space used to describe
/// a crop region for [CameraTransform].
///
/// The origin (0,0) is the top-left corner of the image.
class CameraTransformRect {
  /// Creates a normalized crop rectangle.
  const CameraTransformRect({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
  }) : assert(x >= 0 && x <= 1, 'x must be in [0, 1]'),
       assert(y >= 0 && y <= 1, 'y must be in [0, 1]'),
       assert(width > 0 && width <= 1, 'width must be in (0, 1]'),
       assert(height > 0 && height <= 1, 'height must be in (0, 1]'),
       assert(x + width <= 1, 'x + width must be <= 1'),
       assert(y + height <= 1, 'y + height must be <= 1');

  /// Left edge in normalized [0,1] coordinates.
  final double x;

  /// Top edge in normalized [0,1] coordinates.
  final double y;

  /// Width in normalized [0,1] coordinates.
  final double width;

  /// Height in normalized [0,1] coordinates.
  final double height;
}

/// A geometric transform to apply to all camera outputs simultaneously:
/// the preview texture, the image stream, captured photos, and recorded video.
///
/// On iOS 17+ rotation and mirroring are applied at the hardware
/// `AVCaptureConnection` level (zero CPU / GPU cost). Crop uses Core Image on
/// the GPU (~1–3 ms per frame).
class CameraTransform {
  /// Creates a camera transform.
  ///
  /// Defaults to identity (no rotation, no flip, no crop).
  const CameraTransform({
    this.rotationDegrees = 0,
    this.flipHorizontally = false,
    this.flipVertically = false,
    this.cropRect,
  }) : assert(
         rotationDegrees == 0 ||
             rotationDegrees == 90 ||
             rotationDegrees == 180 ||
             rotationDegrees == 270,
         'rotationDegrees must be 0, 90, 180, or 270',
       );

  /// Clockwise rotation in degrees.
  ///
  /// Must be one of: `0`, `90`, `180`, `270`.
  final double rotationDegrees;

  /// Flip the image left–right (horizontal mirror).
  final bool flipHorizontally;

  /// Flip the image upside-down (vertical mirror).
  ///
  /// Implemented as a horizontal flip composed with a 180° rotation.
  final bool flipVertically;

  /// Optional crop region in normalized (0,1) coordinate space.
  ///
  /// Applied after rotation and mirroring. `null` means no crop.
  final CameraTransformRect? cropRect;
}
