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

  /// The angle of this point in radians, measured clockwise from the positive
  /// X axis.
  double get angleRadians => direction;

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

  /// The magnitude of the [Point], which is the distance of this point from
  /// (0, 0).
  ///
  /// If you need this value to compare it to another [Point]'s distance,
  /// consider using [getDistanceSquared] instead, since it is cheaper to
  /// compute.
  double getDistance() => distance;

  /// The square of the magnitude (which is the distance of this point from
  /// (0, 0)) of the [Point].
  ///
  /// This is cheaper than computing the [getDistance] itself.
  double getDistanceSquared() => distanceSquared;

  /// The dot product of this point and [other], both taken as vectors.
  double dotProduct(Point other) => x * other.x + y * other.y;

  /// The dot product of this point and the vector ([otherX], [otherY]).
  double dotProductXY(double otherX, double otherY) => x * otherX + y * otherY;

  /// Compute the Z coordinate of the cross product of two vectors, to check
  /// if the second vector is going clockwise ( > 0 ) or counterclockwise
  /// (< 0) compared with the first one. It could also be 0, if the vectors
  /// are co-linear.
  bool clockwise(Point other) => (x * other.y - y * other.x) > 0;

  /// Returns the unit vector representing the direction to this point from
  /// (0, 0).
  Point getDirection() {
    final double d = getDistance();
    assert(d > 0, "Can't get the direction of a 0-length vector");
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
