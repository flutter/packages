// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:collection';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:vector_math/vector_math_64.dart' show Matrix4;

import 'point.dart';
import 'utils.dart';

/// This class holds the anchor and control point data for a single cubic
/// Bézier curve, with anchor points ([anchor0X], [anchor0Y]) and ([anchor1X],
/// [anchor1Y]) at either end and control points ([control0X], [control0Y])
/// and ([control1X], [control1Y]) determining the slope of the curve between
/// the anchor points.
@immutable
class Cubic {
  /// Creates a Cubic that holds the anchor and control point data for a
  /// single Bézier curve, with anchor points ([anchor0X], [anchor0Y]) and
  /// ([anchor1X], [anchor1Y]) at either end and control points ([control0X],
  /// [control0Y]) and ([control1X], [control1Y]) determining the slope of the
  /// curve between the anchor points.
  Cubic(
    double anchor0X,
    double anchor0Y,
    double control0X,
    double control0Y,
    double control1X,
    double control1Y,
    double anchor1X,
    double anchor1Y,
  ) : this.raw([
        anchor0X,
        anchor0Y,
        control0X,
        control0Y,
        control1X,
        control1Y,
        anchor1X,
        anchor1Y,
      ]);

  /// Creates a Cubic directly from the flat list of its eight anchor and
  /// control point coordinates, in the order used by [points].
  @internal
  const Cubic.raw(List<double> points)
    : assert(points.length == 8, 'Points array size should be 8.'),
      _points = points;

  @internal
  Cubic.fromPoints(Point anchor0, Point control0, Point control1, Point anchor1)
    : this.raw([
        anchor0.x,
        anchor0.y,
        control0.x,
        control0.y,
        control1.x,
        control1.y,
        anchor1.x,
        anchor1.y,
      ]);

  /// Generates a bezier curve that is a straight line between the given anchor
  /// points. The control points lie 1/3 of the distance from their respective
  /// anchor points.
  factory Cubic.straightLine(double x0, double y0, double x1, double y1) {
    return Cubic.raw([
      x0,
      y0,
      lerp(x0, x1, 1 / 3),
      lerp(y0, y1, 1 / 3),
      lerp(x0, x1, 2 / 3),
      lerp(y0, y1, 2 / 3),
      x1,
      y1,
    ]);
  }

  /// Generates a bezier curve that approximates a circular arc, with p0 and
  /// p1 as the starting and ending anchor points. The curve generated is the
  /// smallest of the two possible arcs around the entire 360-degree circle.
  /// Arcs of greater than 180 degrees should use more than one arc together.
  /// Note that p0 and p1 should be equidistant from the center.
  factory Cubic.circularArc(
    double centerX,
    double centerY,
    double x0,
    double y0,
    double x1,
    double y1,
  ) {
    final Point p0d = directionVector(x0 - centerX, y0 - centerY);
    final Point p1d = directionVector(x1 - centerX, y1 - centerY);
    final Point rotatedP0 = p0d.rotate90();
    final Point rotatedP1 = p1d.rotate90();
    final bool clockwise = rotatedP0.dotProductXY(x1 - centerX, y1 - centerY) >= 0;
    final double cosa = p0d.dotProduct(p1d);

    // p0 ~= p1
    if (cosa > 0.999) {
      return Cubic.straightLine(x0, y0, x1, y1);
    }

    final double k =
        distance(x0 - centerX, y0 - centerY) *
        4 /
        3 *
        (math.sqrt(2 * (1 - cosa)) - math.sqrt(1 - cosa * cosa)) /
        (1 - cosa) *
        (clockwise ? 1 : -1);

    return Cubic(
      x0,
      y0,
      x0 + rotatedP0.x * k,
      y0 + rotatedP0.y * k,
      x1 - rotatedP1.x * k,
      y1 - rotatedP1.y * k,
      x1,
      y1,
    );
  }

  /// Generates an empty Cubic defined at (x0, y0).
  Cubic.empty(double x0, double y0) : this.raw([x0, y0, x0, y0, x0, y0, x0, y0]);

  final List<double> _points;

  List<double> get points => UnmodifiableListView(_points);

  double get anchor0X => _points[0];

  double get anchor0Y => _points[1];

  double get control0X => _points[2];

  double get control0Y => _points[3];

  double get control1X => _points[4];

  double get control1Y => _points[5];

  double get anchor1X => _points[6];

  double get anchor1Y => _points[7];

  /// Returns a point on the curve for parameter [t], representing the
  /// proportional distance along the curve between its starting point at
  /// anchor0 and ending point at anchor1.
  ///
  /// [t] is the distance along the curve between the anchor points, where 0
  /// is at anchor0 and 1 is at anchor1
  Point pointOnCurve(double t) {
    final double u = 1 - t;
    return Point(
      anchor0X * (u * u * u) +
          control0X * (3 * t * u * u) +
          control1X * (3 * t * t * u) +
          anchor1X * (t * t * t),
      anchor0Y * (u * u * u) +
          control0Y * (3 * t * u * u) +
          control1Y * (3 * t * t * u) +
          anchor1Y * (t * t * t),
    );
  }

  bool zeroLength() =>
      (anchor0X - anchor1X).abs() < distanceEpsilon &&
      (anchor0Y - anchor1Y).abs() < distanceEpsilon;

  bool convexTo(Cubic next) {
    final prevVertex = Point(anchor0X, anchor0Y);
    final currVertex = Point(anchor1X, anchor1Y);
    final nextVertex = Point(next.anchor1X, next.anchor1Y);
    return convex(prevVertex, currVertex, nextVertex);
  }

  bool _zeroIsh(double value) => value.abs() < distanceEpsilon;

  /// Returns the true bounds of this curve, filling [bounds] with the
  /// axis-aligned bounding box values for left, top, right, and bottom,
  /// in that order.
  void calculateBounds(List<double> bounds, {bool approximate = false}) {
    assert(bounds.length == 4, 'Bounds array size should be 4.');

    // A curve might be of zero-length, with both anchors co-lated.
    // Just return the point itself.
    if (zeroLength()) {
      bounds[0] = anchor0X;
      bounds[1] = anchor0Y;
      bounds[2] = anchor0X;
      bounds[3] = anchor0Y;
      return;
    }

    double minX = math.min(anchor0X, anchor1X);
    double minY = math.min(anchor0Y, anchor1Y);
    double maxX = math.max(anchor0X, anchor1X);
    double maxY = math.max(anchor0Y, anchor1Y);

    if (approximate) {
      // Approximate bounds use the bounding box of all anchors and
      // controls.
      bounds[0] = math.min(minX, math.min(control0X, control1X));
      bounds[1] = math.min(minY, math.min(control0Y, control1Y));
      bounds[2] = math.max(maxX, math.max(control0X, control1X));
      bounds[3] = math.max(maxY, math.max(control0Y, control1Y));
      return;
    }

    // Find the derivative, which is a quadratic Bezier. Then we can solve
    // for t using the quadratic formula.
    final double xa = -anchor0X + 3 * control0X - 3 * control1X + anchor1X;
    final double xb = 2 * anchor0X - 4 * control0X + 2 * control1X;
    final double xc = -anchor0X + control0X;

    if (_zeroIsh(xa)) {
      // Try Muller's method instead; it can find a single root when a is 0.
      if (xb != 0) {
        final double t = 2 * xc / (-2 * xb);
        if (t >= 0 && t <= 1) {
          final double x = pointOnCurve(t).x;
          if (x < minX) {
            minX = x;
          }
          if (x > maxX) {
            maxX = x;
          }
        }
      }
    } else {
      final double xs = xb * xb - 4 * xa * xc;
      if (xs >= 0) {
        final double t1 = (-xb + math.sqrt(xs)) / (2 * xa);
        if (t1 >= 0 && t1 <= 1) {
          final double x = pointOnCurve(t1).x;
          if (x < minX) {
            minX = x;
          }
          if (x > maxX) {
            maxX = x;
          }
        }

        final double t2 = (-xb - math.sqrt(xs)) / (2 * xa);
        if (t2 >= 0 && t2 <= 1) {
          final double x = pointOnCurve(t2).x;
          if (x < minX) {
            minX = x;
          }
          if (x > maxX) {
            maxX = x;
          }
        }
      }
    }

    // Repeat the above for y coordinate
    final double ya = -anchor0Y + 3 * control0Y - 3 * control1Y + anchor1Y;
    final double yb = 2 * anchor0Y - 4 * control0Y + 2 * control1Y;
    final double yc = -anchor0Y + control0Y;

    if (_zeroIsh(ya)) {
      if (yb != 0) {
        final double t = 2 * yc / (-2 * yb);
        if (t >= 0 && t <= 1) {
          final double y = pointOnCurve(t).y;
          if (y < minY) {
            minY = y;
          }
          if (y > maxY) {
            maxY = y;
          }
        }
      }
    } else {
      final double ys = yb * yb - 4 * ya * yc;
      if (ys >= 0) {
        final double t1 = (-yb + math.sqrt(ys)) / (2 * ya);
        if (t1 >= 0 && t1 <= 1) {
          final double y = pointOnCurve(t1).y;
          if (y < minY) {
            minY = y;
          }
          if (y > maxY) {
            maxY = y;
          }
        }

        final double t2 = (-yb - math.sqrt(ys)) / (2 * ya);
        if (t2 >= 0 && t2 <= 1) {
          final double y = pointOnCurve(t2).y;
          if (y < minY) {
            minY = y;
          }
          if (y > maxY) {
            maxY = y;
          }
        }
      }
    }

    bounds[0] = minX;
    bounds[1] = minY;
    bounds[2] = maxX;
    bounds[3] = maxY;
  }

  /// Returns two Cubics, created by splitting this curve at the given
  /// distance of [t] between the original starting and ending anchor points.
  (Cubic, Cubic) split(double t) {
    final double u = 1 - t;
    final Point point = pointOnCurve(t);

    return (
      Cubic(
        anchor0X,
        anchor0Y,
        anchor0X * u + control0X * t,
        anchor0Y * u + control0Y * t,
        anchor0X * (u * u) + control0X * (2 * u * t) + control1X * (t * t),
        anchor0Y * (u * u) + control0Y * (2 * u * t) + control1Y * (t * t),
        point.x,
        point.y,
      ),
      Cubic(
        point.x,
        point.y,
        control0X * (u * u) + control1X * (2 * u * t) + anchor1X * (t * t),
        control0Y * (u * u) + control1Y * (2 * u * t) + anchor1Y * (t * t),
        control1X * u + anchor1X * t,
        control1Y * u + anchor1Y * t,
        anchor1X,
        anchor1Y,
      ),
    );
  }

  /// Utility function to reverse the control/anchor points for this curve.
  Cubic reverse() =>
      Cubic(anchor1X, anchor1Y, control1X, control1Y, control0X, control0Y, anchor0X, anchor0Y);

  Cubic operator +(Cubic o) => Cubic.raw(List.generate(8, (i) => _points[i] + o._points[i]));

  Cubic operator *(double x) => Cubic.raw(List.generate(8, (i) => _points[i] * x));

  Cubic operator /(double x) => this * (1.0 / x);

  Cubic transformed(PointTransformer f) {
    final newCubic = _MutableCubic();
    for (var i = 0; i < 8; i++) {
      newCubic._points[i] = _points[i];
    }
    newCubic.transform(f);
    return newCubic;
  }

  @override
  String toString() {
    return 'anchor0: ($anchor0X, $anchor0Y) '
        'control0: ($control0X, $control0Y), '
        'control1: ($control1X, $control1Y), '
        'anchor1: ($anchor1X, $anchor1Y)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) {
      return true;
    }

    if (other is! Cubic) {
      return false;
    }

    if (_points.length != other._points.length) {
      return false;
    }

    for (var index = 0; index < _points.length; index += 1) {
      if (_points[index] != other._points[index]) {
        return false;
      }
    }

    return true;
  }

  @override
  int get hashCode => _points.hashCode;
}

/// Mutable version of [Cubic], used mostly for performance critical paths so
/// we can avoid creating new [Cubic]s
///
/// This is used in Morph.forEachCubic, reusing a [_MutableCubic] instance to
/// avoid creating new [Cubic]s.
class _MutableCubic extends Cubic {
  _MutableCubic() : super.raw(List.filled(8, 0));

  void _transformOnePoint(PointTransformer f, int ix) {
    final (double, double) result = f(_points[ix], _points[ix + 1]);
    _points[ix] = result.$1;
    _points[ix + 1] = result.$2;
  }

  void transform(PointTransformer f) {
    _transformOnePoint(f, 0);
    _transformOnePoint(f, 2);
    _transformOnePoint(f, 4);
    _transformOnePoint(f, 6);
  }

  void interpolate(Cubic c1, Cubic c2, double progress) {
    for (var i = 0; i < 8; i++) {
      _points[i] = lerp(c1._points[i], c2._points[i], progress);
    }
  }
}

/// Returns a [Path] for a [Cubic] list.
///
/// [path] is a [Path] to reset and set with the new path data.
///
/// [startAngle] is an angle (in degrees) to rotate the [Path] to start
/// drawing from. If [startAngle] is non zero, then caller has to use the
/// returned [Path], as path transformation creates a new path.
///
/// [repeatPath] is whether or not to repeat the [Path] twice before closing
/// it. This flag is useful when the caller would like to draw parts of the
/// path while offsetting the start and stop positions (for example, when
/// phasing and rotating a path to simulate a motion as a Star circular
/// progress indicator advances).
///
/// [closePath] is whether or not to close the created [Path].
///
/// [cubics] is list of [Cubic]s to build path from.
///
/// [rotationPivotX] is the rotation pivot on the X axis.
///
/// [rotationPivotY] is the rotation pivot on the Y axis.
Path pathFromCubics({
  required Path path,
  required int startAngle,
  required bool repeatPath,
  required bool closePath,
  required List<Cubic> cubics,
  required double rotationPivotX,
  required double rotationPivotY,
}) {
  var first = true;
  Cubic? firstCubic;

  path.reset();

  for (final cubic in cubics) {
    if (first) {
      path.moveTo(cubic.anchor0X, cubic.anchor0Y);
      if (startAngle != 0) {
        firstCubic = cubic;
      }
      first = false;
    }

    path.cubicTo(
      cubic.control0X,
      cubic.control0Y,
      cubic.control1X,
      cubic.control1Y,
      cubic.anchor1X,
      cubic.anchor1Y,
    );
  }

  if (repeatPath) {
    var firstInRepeat = true;
    for (final cubic in cubics) {
      if (firstInRepeat) {
        path.lineTo(cubic.anchor0X, cubic.anchor0Y);
        firstInRepeat = false;
      }

      path.cubicTo(
        cubic.control0X,
        cubic.control0Y,
        cubic.control1X,
        cubic.control1Y,
        cubic.anchor1X,
        cubic.anchor1Y,
      );
    }
  }

  if (closePath) {
    path.close();
  }

  if (startAngle != 0 && firstCubic != null) {
    final double angleToFirstCubic = math.atan2(
      cubics[0].anchor0Y - rotationPivotY,
      cubics[0].anchor0X - rotationPivotX,
    );
    // Rotate the Path to to start from the given angle.
    path = path.transform(
      (Matrix4.identity()..rotateZ(-angleToFirstCubic + (startAngle * math.pi / 180))).storage,
    );
  }

  return path;
}
