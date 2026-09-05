// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// @docImport 'cubic.dart';
/// @docImport 'features.dart';
/// @docImport 'morph.dart';
/// @docImport 'rounded_polygon.dart';
library;

import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:vector_math/vector_math_64.dart' show Matrix4, Vector3;

/// Transforms the point (x, y) and returns the transformed coordinates.
///
/// This is used by [CubicBezier.transformed], [Feature.transformed] and
/// [RoundedPolygon.transformed] to apply arbitrary transformations to a shape.
typedef PointTransformer = (double, double) Function(double x, double y);

/// A two dimensional coordinate pair used by the shape algorithms.
@internal
typedef Point = Offset;

/// The geometry [Offset] does not provide.
@internal
extension PointGeometry on Offset {
  /// The horizontal coordinate of this point.
  double get x => dx;

  /// The vertical coordinate of this point.
  double get y => dy;

  /// Returns this point rotated a quarter turn counterclockwise around (0, 0).
  Point rotate90() => Point(-y, x);

  /// Returns this point rotated by [degrees] around [center].
  Point rotate(double degrees, {Point center = Point.zero}) {
    final double radians = degrees * math.pi / 180;
    final Point off = this - center;
    final double cos = math.cos(radians);
    final double sin = math.sin(radians);
    return Point(off.x * cos - off.y * sin, off.x * sin + off.y * cos) + center;
  }

  /// The dot product of this point and [other], both taken as vectors.
  double dotProduct(Point other) => x * other.x + y * other.y;

  /// Whether turning from this point to [other], both taken as vectors, is a
  /// clockwise turn.
  ///
  /// This tests the sign of the Z coordinate of the cross product of the two,
  /// which is zero when they are collinear, so collinear vectors are not
  /// considered a clockwise turn.
  bool turnsClockwiseTo(Point other) => (x * other.y - y * other.x) > 0;

  /// The unit vector pointing from (0, 0) towards this point.
  Point get unitVector {
    final double d = distance;
    assert(d > 0, "Can't compute the unit vector of a zero-length vector");
    return this / d;
  }

  /// Returns a copy of this point with [f] applied to it.
  Point transformed(PointTransformer f) {
    final (double, double) result = f(x, y);
    return Point(result.$1, result.$2);
  }
}

/// Adapts a [Matrix4] into a [PointTransformer].
extension Matrix4PointTransformer on Matrix4 {
  /// Returns a [PointTransformer] that applies this matrix.
  ///
  /// This is the bridge between the transformation types Flutter already uses
  /// and the shape transformation methods, so that a matrix built with the
  /// usual [Matrix4] helpers can be passed straight to
  /// [RoundedPolygon.transformed], [Morph], [Feature.transformed] or
  /// [CubicBezier.transformed]:
  ///
  /// ```dart
  /// final RoundedPolygon rotated = polygon.transformed(
  ///   Matrix4.rotationZ(math.pi / 4).asPointTransformer(),
  /// );
  /// ```
  ///
  /// Only the X and Y components of the result are used, so the Z translation
  /// and perspective rows of the matrix have no effect.
  PointTransformer asPointTransformer() {
    return (x, y) {
      final Vector3 vector = transform3(Vector3(x, y, 0));
      return (vector.x, vector.y);
    };
  }
}
