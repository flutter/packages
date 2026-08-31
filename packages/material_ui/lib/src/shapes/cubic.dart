// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// @docImport 'morph.dart';
/// @docImport 'rounded_polygon.dart';
library;

import 'dart:collection';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:vector_math/vector_math_64.dart' show Matrix4;

import 'point.dart';
import 'utils.dart';

/// This class holds the anchor and control point data for a single cubic
/// Bézier curve, with anchor points [anchor0] and [anchor1] at either end and
/// control points [control0] and [control1] determining the slope of the curve
/// between the anchor points.
@immutable
class CubicBezier {
  /// Creates a [CubicBezier] that holds the anchor and control point data for a
  /// single Bézier curve, with anchor points [anchor0] and [anchor1] at either
  /// end and control points [control0] and [control1] determining the slope of
  /// the curve between the anchor points.
  CubicBezier(Offset anchor0, Offset control0, Offset control1, Offset anchor1)
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

  /// Creates a [CubicBezier] directly from the flat list of its eight anchor
  /// and control point coordinates, in the order used by [points].
  @internal
  const CubicBezier.raw(List<double> points)
    : assert(points.length == 8, 'Points array size should be 8.'),
      _points = points;

  /// Generates a bezier curve that is a straight line between the given anchor
  /// points [p0] and [p1]. The control points lie 1/3 of the distance from
  /// their respective anchor points.
  factory CubicBezier.straightLine(Offset p0, Offset p1) {
    return CubicBezier.raw([
      p0.x,
      p0.y,
      lerp(p0.x, p1.x, 1 / 3),
      lerp(p0.y, p1.y, 1 / 3),
      lerp(p0.x, p1.x, 2 / 3),
      lerp(p0.y, p1.y, 2 / 3),
      p1.x,
      p1.y,
    ]);
  }

  /// Generates a bezier curve that approximates a circular arc around [center],
  /// with [p0] and [p1] as the starting and ending anchor points. The curve
  /// generated is the smallest of the two possible arcs around the entire
  /// 360-degree circle. Arcs of greater than 180 degrees should use more than
  /// one arc together. Note that [p0] and [p1] should be equidistant from
  /// [center].
  factory CubicBezier.circularArc(Offset center, Offset p0, Offset p1) {
    final Point p0d = directionVector(p0.x - center.x, p0.y - center.y);
    final Point p1d = directionVector(p1.x - center.x, p1.y - center.y);
    final Point rotatedP0 = p0d.rotate90();
    final Point rotatedP1 = p1d.rotate90();
    final bool clockwise = rotatedP0.dotProductXY(p1.x - center.x, p1.y - center.y) >= 0;
    final double cosa = p0d.dotProduct(p1d);

    // p0 ~= p1
    if (cosa > 0.999) {
      return CubicBezier.straightLine(p0, p1);
    }

    final double k =
        distance(p0.x - center.x, p0.y - center.y) *
        4 /
        3 *
        (math.sqrt(2 * (1 - cosa)) - math.sqrt(1 - cosa * cosa)) /
        (1 - cosa) *
        (clockwise ? 1 : -1);

    return CubicBezier.raw([
      p0.x,
      p0.y,
      p0.x + rotatedP0.x * k,
      p0.y + rotatedP0.y * k,
      p1.x - rotatedP1.x * k,
      p1.y - rotatedP1.y * k,
      p1.x,
      p1.y,
    ]);
  }

  /// Generates an empty [CubicBezier] defined at [point].
  ///
  /// Both anchor points and both control points coincide, so the curve has
  /// zero length. See [isZeroLength].
  CubicBezier.empty(Offset point)
    : this.raw([point.x, point.y, point.x, point.y, point.x, point.y, point.x, point.y]);

  final List<double> _points;

  /// The eight coordinates of this curve as a flat, unmodifiable list, ordered
  /// as anchor0, control0, control1, anchor1.
  ///
  /// Equivalent to reading [anchor0X] through [anchor1Y] in order, and more
  /// convenient when serializing a curve or handing its coordinates to code
  /// that expects a coordinate buffer.
  List<double> get points => UnmodifiableListView(_points);

  /// The anchor point at the start of the curve.
  Offset get anchor0 => Offset(_points[0], _points[1]);

  /// The control point closest to [anchor0].
  Offset get control0 => Offset(_points[2], _points[3]);

  /// The control point closest to [anchor1].
  Offset get control1 => Offset(_points[4], _points[5]);

  /// The anchor point at the end of the curve.
  Offset get anchor1 => Offset(_points[6], _points[7]);

  /// The X coordinate of the anchor point at the start of the curve.
  double get anchor0X => _points[0];

  /// The Y coordinate of the anchor point at the start of the curve.
  double get anchor0Y => _points[1];

  /// The X coordinate of the control point closest to [anchor0].
  double get control0X => _points[2];

  /// The Y coordinate of the control point closest to [anchor0].
  double get control0Y => _points[3];

  /// The X coordinate of the control point closest to [anchor1].
  double get control1X => _points[4];

  /// The Y coordinate of the control point closest to [anchor1].
  double get control1Y => _points[5];

  /// The X coordinate of the anchor point at the end of the curve.
  double get anchor1X => _points[6];

  /// The Y coordinate of the anchor point at the end of the curve.
  double get anchor1Y => _points[7];

  /// Returns a point on the curve for parameter [t], representing the
  /// proportional distance along the curve between its starting point at
  /// [anchor0] and ending point at [anchor1].
  ///
  /// [t] is the distance along the curve between the anchor points, where 0
  /// is at [anchor0] and 1 is at [anchor1].
  Offset pointAt(double t) {
    final double u = 1 - t;
    return Offset(
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

  /// Whether this curve's two anchor points coincide, and so the curve
  /// contributes nothing to an outline.
  ///
  /// Coincidence is measured with a small tolerance rather than exactly, so a
  /// curve whose anchors differ only by rounding error still counts as zero
  /// length. Note that the control points are not considered.
  bool get isZeroLength =>
      (anchor0X - anchor1X).abs() < distanceEpsilon &&
      (anchor0Y - anchor1Y).abs() < distanceEpsilon;

  /// Whether the corner formed by this curve and [next] turns convexly.
  @internal
  bool convexTo(CubicBezier next) => convex(anchor0, anchor1, next.anchor1);

  bool _zeroIsh(double value) => value.abs() < distanceEpsilon;

  /// The axis-aligned bounding box of this curve.
  ///
  /// This solves for the curve's actual extrema. See [approximateBounds] for a
  /// cheaper result that is never smaller than this one.
  Rect get bounds => _calculateBounds(approximate: false);

  /// A cheaper alternative to [bounds], which bounds the two anchor points and
  /// the two control points rather than solving for the curve's actual
  /// extrema.
  ///
  /// The result is never smaller than [bounds], but can be larger.
  Rect get approximateBounds => _calculateBounds(approximate: true);

  Rect _calculateBounds({required bool approximate}) {
    // A curve might be of zero-length, with both anchors co-lated.
    // Just return the point itself.
    if (isZeroLength) {
      return Rect.fromLTRB(anchor0X, anchor0Y, anchor0X, anchor0Y);
    }

    double minX = math.min(anchor0X, anchor1X);
    double minY = math.min(anchor0Y, anchor1Y);
    double maxX = math.max(anchor0X, anchor1X);
    double maxY = math.max(anchor0Y, anchor1Y);

    if (approximate) {
      // Approximate bounds use the bounding box of all anchors and
      // controls.
      return Rect.fromLTRB(
        math.min(minX, math.min(control0X, control1X)),
        math.min(minY, math.min(control0Y, control1Y)),
        math.max(maxX, math.max(control0X, control1X)),
        math.max(maxY, math.max(control0Y, control1Y)),
      );
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
          final double x = pointAt(t).x;
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
          final double x = pointAt(t1).x;
          if (x < minX) {
            minX = x;
          }
          if (x > maxX) {
            maxX = x;
          }
        }

        final double t2 = (-xb - math.sqrt(xs)) / (2 * xa);
        if (t2 >= 0 && t2 <= 1) {
          final double x = pointAt(t2).x;
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
          final double y = pointAt(t).y;
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
          final double y = pointAt(t1).y;
          if (y < minY) {
            minY = y;
          }
          if (y > maxY) {
            maxY = y;
          }
        }

        final double t2 = (-yb - math.sqrt(ys)) / (2 * ya);
        if (t2 >= 0 && t2 <= 1) {
          final double y = pointAt(t2).y;
          if (y < minY) {
            minY = y;
          }
          if (y > maxY) {
            maxY = y;
          }
        }
      }
    }

    return Rect.fromLTRB(minX, minY, maxX, maxY);
  }

  /// Returns two [CubicBezier]s, created by splitting this curve at the given
  /// distance of [t] between the original starting and ending anchor points.
  (CubicBezier, CubicBezier) split(double t) {
    final double u = 1 - t;
    final Point point = pointAt(t);

    return (
      CubicBezier.raw([
        anchor0X,
        anchor0Y,
        anchor0X * u + control0X * t,
        anchor0Y * u + control0Y * t,
        anchor0X * (u * u) + control0X * (2 * u * t) + control1X * (t * t),
        anchor0Y * (u * u) + control0Y * (2 * u * t) + control1Y * (t * t),
        point.x,
        point.y,
      ]),
      CubicBezier.raw([
        point.x,
        point.y,
        control0X * (u * u) + control1X * (2 * u * t) + anchor1X * (t * t),
        control0Y * (u * u) + control1Y * (2 * u * t) + anchor1Y * (t * t),
        control1X * u + anchor1X * t,
        control1Y * u + anchor1Y * t,
        anchor1X,
        anchor1Y,
      ]),
    );
  }

  /// This curve with its control and anchor points in reverse order, so it
  /// runs from [anchor1] to [anchor0].
  CubicBezier get reversed => CubicBezier.raw([
    anchor1X,
    anchor1Y,
    control1X,
    control1Y,
    control0X,
    control0Y,
    anchor0X,
    anchor0Y,
  ]);

  /// Returns a curve whose coordinates are the sums of this curve's and [o]'s
  /// corresponding coordinates.
  CubicBezier operator +(CubicBezier o) =>
      CubicBezier.raw(List.generate(8, (i) => _points[i] + o._points[i]));

  /// Returns a curve whose coordinates are this curve's multiplied by [x].
  CubicBezier operator *(double x) => CubicBezier.raw(List.generate(8, (i) => _points[i] * x));

  /// Returns a curve whose coordinates are this curve's divided by [x].
  CubicBezier operator /(double x) => this * (1.0 / x);

  /// Returns a copy of this curve with [transformer] applied to each of its
  /// anchor and control points.
  CubicBezier transformed(PointTransformer transformer) {
    final newCubic = _MutableCubicBezier();
    for (var i = 0; i < 8; i++) {
      newCubic._points[i] = _points[i];
    }
    newCubic.transform(transformer);
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

    if (other is! CubicBezier) {
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
  int get hashCode => Object.hashAll(_points);
}

/// Mutable version of [CubicBezier], used mostly for performance critical paths
/// so we can avoid creating new [CubicBezier]s
///
/// This is used in Morph.forEachCubic, reusing a [_MutableCubicBezier] instance
/// to avoid creating new [CubicBezier]s.
class _MutableCubicBezier extends CubicBezier {
  _MutableCubicBezier() : super.raw(List.filled(8, 0));

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

  void interpolate(CubicBezier c1, CubicBezier c2, double progress) {
    for (var i = 0; i < 8; i++) {
      _points[i] = lerp(c1._points[i], c2._points[i], progress);
    }
  }
}

/// Returns a [Path] built from the given [cubics].
///
/// This is the building block behind [RoundedPolygon.toPath] and
/// [Morph.toPath], and is useful when working with a list of curves obtained
/// from [Morph.toCubics] directly.
///
/// [startAngle] places the start point of the first curve at that angle, in
/// radians, around [rotationPivot], rotating the whole path to get it there.
/// Zero is to the right of the pivot and `pi / 2` below it, since y grows
/// downwards.
/// The default of zero is special: it skips the rotation entirely and leaves
/// the curves as given.
///
/// [repeatPath] is whether or not to repeat the [Path] twice before closing
/// it. This flag is useful when the caller would like to draw parts of the
/// path while offsetting the start and stop positions (for example, when
/// phasing and rotating a path to simulate a motion as a Star circular
/// progress indicator advances).
///
/// [closePath] is whether or not to close the created [Path].
///
/// [rotationPivot] is the point [startAngle] rotates the path around, and the
/// point its angle is measured from. It defaults to the origin, which suits
/// curves laid out around [Offset.zero].
Path pathFromCubics(
  List<CubicBezier> cubics, {
  double startAngle = 0,
  bool repeatPath = false,
  bool closePath = true,
  Offset rotationPivot = Offset.zero,
}) {
  var path = Path();

  var first = true;
  CubicBezier? firstCubic;

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
      cubics[0].anchor0Y - rotationPivot.dy,
      cubics[0].anchor0X - rotationPivot.dx,
    );
    // Rotate the path around the pivot so that it starts from the given angle.
    path = path.transform(
      (Matrix4.identity()
            ..translateByDouble(rotationPivot.dx, rotationPivot.dy, 0, 1)
            ..rotateZ(-angleToFirstCubic + startAngle)
            ..translateByDouble(-rotationPivot.dx, -rotationPivot.dy, 0, 1))
          .storage,
    );
  }

  return path;
}
