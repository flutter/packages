// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// @docImport 'cubic.dart';
/// @docImport 'features.dart';
/// @docImport 'morph.dart';
/// @docImport 'rounded_polygon.dart';
library;

import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:vector_math/vector_math_64.dart' show Matrix4, Vector3;

/// Transforms the point (x, y) and returns the transformed coordinates.
///
/// This is used by [CubicBezier.transformed], [Feature.transformed] and
/// [RoundedPolygon.transformed] to apply arbitrary transformations to a shape.
typedef PointTransformer = (double, double) Function(double x, double y);

@internal
@immutable
class Point {
  const Point(this.x, this.y);

  static const zero = Point(0, 0);

  final double x;

  final double y;

  Point copy() => Point(x, y);

  Point rotate90() => Point(-y, x);

  Point rotate(double degrees, {Point center = Point.zero}) {
    final double radians = degrees * math.pi / 180;
    final Point off = this - center;
    final double cos = math.cos(radians);
    final double sin = math.sin(radians);
    return Point(off.x * cos - off.y * sin, off.x * sin + off.y * cos) + center;
  }

  Point translate(double dx, double dy) => Point(x + dx, y + dy);

  Point scale(double sx, double sy) => Point(x * sx, y * sy);

  double get angleDegrees => angleRadians * math.pi / 180;

  double get angleRadians => math.atan2(y, x);

  /// The magnitude of the [Point], which is the distance of this point from
  /// (0, 0).
  ///
  /// If you need this value to compare it to another [Point]'s distance,
  /// consider using [getDistanceSquared] instead, since it is cheaper to
  /// compute.
  double getDistance() => math.sqrt(x * x + y * y);

  /// The square of the magnitude (which is the distance of this point from
  /// (0, 0)) of the [Point].
  ///
  /// This is cheaper than computing the [getDistance] itself.
  double getDistanceSquared() => x * x + y * y;

  double dotProduct(Point other) => x * other.x + y * other.y;

  double dotProductXY(double otherX, double otherY) => x * otherX + y * otherY;

  /// Compute the Z coordinate of the cross product of two vectors, to check
  /// if the second vector is going clockwise ( > 0 ) or counterclockwise
  /// (< 0) compared with the first one. It could also be 0, if the vectors
  /// are co-linear.
  bool clockwise(Point other) => (x * other.y - y * other.x) > 0;

  Point getDirection() {
    final double d = getDistance();
    assert(d > 0, "Can't get the direction of a 0-length vector");
    return this / d;
  }

  /// Unary negation operator.
  ///
  /// Returns a [Point] with the coordinates negated.
  ///
  /// If the [Point] represents an arrow on a plane, this operator returns the
  /// same arrow but pointing in the reverse direction.
  Point operator -() => Point(-x, -y);

  /// Binary subtraction operator.
  ///
  /// Returns a Point whose [x] value is the left-hand-side operand's [x]
  /// minus the right-hand-side operand's [x] and whose [y] value is the
  /// left-hand-side operand's [y] minus the right-hand-side operand's [y].
  Point operator -(Point operand) => Point(x - operand.x, y - operand.y);

  /// Binary addition operator.
  ///
  /// Returns a Point whose [x] value is the sum of the [x] values of the two
  /// operands, and whose [y] value is the sum of the [y] values of the two
  /// operands.
  Point operator +(Point operand) => Point(x + operand.x, y + operand.y);

  /// Multiplication operator.
  ///
  /// Returns a Point whose coordinates are the coordinates of the
  /// left-hand-side operand (a [Point]) multiplied by the scalar
  /// right-hand-side operand (a [double]).
  Point operator *(double operand) => Point(x * operand, y * operand);

  /// Division operator.
  ///
  /// Returns a Point whose coordinates are the coordinates of the
  /// left-hand-side operand (a [Point]) divided by the scalar
  /// right-hand-side operand (a [double]).
  Point operator /(double operand) => Point(x / operand, y / operand);

  /// Modulo (remainder) operator.
  ///
  /// Returns a Point whose coordinates are the remainder of dividing the
  /// coordinates of the left-hand-side operand (a [Point]) by the scalar
  /// right-hand-side operand (a [double]).
  Point operator %(double operand) => Point(x % operand, y % operand);

  Point transformed(PointTransformer f) {
    final (double, double) result = f(x, y);
    return Point(result.$1, result.$2);
  }

  @override
  String toString() => 'Point($x, $y)';

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) {
      return true;
    }

    if (other is! Point) {
      return false;
    }

    return other.x == x && other.y == y;
  }

  @override
  int get hashCode => Object.hashAll([x, y]);
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
