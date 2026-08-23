// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// @docImport 'rounded_polygon.dart';
library;

/// Defines the amount and quality around a given vertex of a shape.
/// [radius] defines the radius of the circle which forms the basis of
/// the rounding for the vertex. [smoothing] defines the amount by which the
/// curve is extended from the circular arc around the corner to the
/// edge between vertices.
///
/// Each corner of a shape can be thought of as either:
///   1) unrounded (with a corner radius of 0 and no smoothing).
///   2) rounded with only a circular arc (with smoothing of 0). In this case,
///      the rounding around the corner follows an approximated circular arc
///      between the edges to adjacent vertices.
///   3) rounded with three curves: There is an inner circular arc and two
///      symmetric flanking curves. The flanking curves determine the curvature
///      from the inner curve to the edges, with a value of 0 (no smoothing)
///      meaning that it is purely a circular curve and a value of 1 meaning
///      that the flanking curves are maximized between the inner curve and
///      the edges.
class CornerRounding {
  /// Creates a [CornerRounding].
  const CornerRounding({this.radius = 0, this.smoothing = 0})
    : assert(radius >= 0, 'radius has to be greater that zero'),
      assert(smoothing >= 0 && smoothing <= 1, 'smoothing has to be in range [0, 1]');

  /// A [CornerRounding] with a radius of zero, producing a sharp corner at a
  /// vertex.
  static const unrounded = CornerRounding();

  /// The radius of the circle which defines the inner rounding arc of the
  /// corner.
  ///
  /// A value of 0 indicates that the corner is sharp, or completely unrounded.
  /// A positive value is the requested size of the radius.
  ///
  /// This is an absolute size that should relate to the overall size of the
  /// shape. If the shape is in screen coordinates, the radius should be sized
  /// accordingly; if the shape is in a canonical form, such as the bounds of
  /// (-1, -1) to (1, 1) that [RoundedPolygon.fromVerticesNum] produces by
  /// default, the radius should be relative to that size. The radius is scaled
  /// when the shape itself is transformed, since it produces curves which round
  /// the corner and so are transformed along with the overall shape.
  ///
  /// Must be greater than or equal to zero.
  final double radius;

  /// The amount by which the arc is smoothed by extending the curve from the
  /// inner circular arc to the edge between vertices.
  ///
  /// A value of 0 indicates that the corner is rounded by only a circular arc,
  /// with no flanking curves. A value of 1 indicates that there is no circular
  /// arc in the center, and the flanking curves on either side meet at the
  /// middle.
  ///
  /// Must be in the range 0.0 to 1.0, inclusive.
  final double smoothing;
}
