// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:math' as math;
import 'package:meta/meta.dart';

import '../util.dart';

/// An immutable position in two-dimensional space.
///
/// This class is roughly compatible with dart:ui's Offset.
@immutable
class Point {
  /// Creates a point object with x,y coordinates.
  const Point(this.x, this.y);

  /// The point at the origin of coordinate space.
  static const Point zero = Point(0, 0);

  /// Linearly interpolate between two points.
  ///
  /// The [t] argument represents a position on the timeline, with 0.0 meaning
  /// interpolation has not started and 1.0 meaning interpolation has finished.
  ///
  /// At the start the returned value equals [a], and at the end it equals [b]. As
  /// the number advances from 0 to 1 it returns a value closer to a or b
  /// respectively.
  static Point lerp(Point a, Point b, double t) {
    return Point(
      lerpDouble(a.x, b.x, t),
      lerpDouble(a.y, b.y, t),
    );
  }

  /// The distance between points [a] and [b].
  static double distance(Point a, Point b) {
    final double x = a.x - b.x;
    final double y = a.y - b.y;
    return math.sqrt((x * x) + (y * y));
  }

  /// The offset along the x-axis of this point.
  final double x;

  /// The offset along the y-axis of this point.
  final double y;

  @override
  int get hashCode => Object.hash(x, y);

  @override
  bool operator ==(Object other) {
    return other is Point && other.x == x && other.y == y;
  }

  /// Returns a point whose coordinates are the coordinates of the
  /// left-hand-side operand (a Point) divided by the scalar right-hand-side
  /// operand (a double).
  Point operator /(double divisor) {
    return Point(x / divisor, y / divisor);
  }

  /// Returns a point whose coordinates are the coordinates of the
  /// left-hand-side operand (a Point) multiplied by the scalar right-hand-side
  /// operand (a double).
  Point operator *(double multiplicand) {
    return Point(x * multiplicand, y * multiplicand);
  }

  /// Returns a point whose coordinates are the coordinates of the
  /// left-hand-side operand (a Point) added to the right-hand-side
  /// coordinates (a Point).
  Point operator +(Point other) {
    return Point(x + other.x, y + other.y);
  }

  @override
  String toString() => 'Point($x, $y)';
}

/// An immutable, 2D, axis-aligned, floating-point rectangle whose coordinates
/// are relative to a given origin.
@immutable
class Rect {
  /// Creates a rectangle from the specified left, top, right, and bottom
  /// positions.
  const Rect.fromLTRB(this.left, this.top, this.right, this.bottom);

  /// Creates a rectangle from the specified left and top positions with width
  /// and height dimensions.
  const Rect.fromLTWH(double left, double top, double width, double height)
      : this.fromLTRB(left, top, left + width, top + height);

  /// Creates a rectangle representing a circle with centerpoint `x,`y` and
  /// radius `r`.
  const Rect.fromCircle(double x, double y, double r)
      : this.fromLTRB(x - r, y - r, x + r, y + r);

  /// A rectangle covering the entire coordinate space, equal to dart:ui's
  /// definition.
  static const Rect largest = Rect.fromLTRB(-1e9, -1e9, 1e9, 1e9);

  /// A rectangle with the top, left, right, and bottom edges all at zero.
  static const Rect zero = Rect.fromLTRB(0, 0, 0, 0);

  /// The x-axis offset of left edge.
  final double left;

  /// The y-axis offset of the top edge.
  final double top;

  /// The x-axis offset of the right edge.
  final double right;

  /// The y-axis offset of the bottom edge.
  final double bottom;

  /// The width of the rectangle.
  double get width => right - left;

  /// The height of the rectangle.
  double get height => bottom - top;

  /// Creates the smallest rectangle that covers the edges of this and `other`.
  Rect expanded(Rect other) {
    return Rect.fromLTRB(
      math.min(left, other.left),
      math.min(top, other.top),
      math.max(right, other.right),
      math.max(bottom, other.bottom),
    );
  }

  /// Whether or not the rect has any contents.
  bool get isEmpty => width == 0 || height == 0;

  /// Whether or not [other] intersect this rectangle.
  ///
  /// This only works for sorted rectangles.
  bool intersects(Rect other) {
    assert(other.left <= other.right && other.top <= other.bottom);
    assert(left <= right && top <= bottom);
    if (isEmpty || other.isEmpty) {
      return false;
    }
    return math.max(left, other.left) < math.min(right, other.right) &&
        math.max(top, other.top) < math.min(bottom, other.bottom);
  }

  @override
  int get hashCode => Object.hash(left, top, right, bottom);

  @override
  bool operator ==(Object other) {
    return other is Rect &&
        other.left == left &&
        other.top == top &&
        other.right == right &&
        other.bottom == bottom;
  }

  @override
  String toString() => 'Rect.fromLTRB($left, $top, $right, $bottom)';
}
