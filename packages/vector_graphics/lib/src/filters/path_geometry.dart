// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui';

/// Path segments retained for tight SVG object bounds in any ancestor space.
/// Flutter Path.getBounds includes off-curve control points.
class FilterPathGeometry {
  final List<List<Offset>> _segments = <List<Offset>>[];
  Offset _position = Offset.zero;
  Offset _start = Offset.zero;

  /// Starts a contour, retaining its position even for a zero-length subpath.
  void moveTo(double x, double y) {
    _position = _start = Offset(x, y);
    _segments.add(<Offset>[_position]);
  }

  /// Adds a straight segment.
  void lineTo(double x, double y) {
    final point = Offset(x, y);
    _segments.add(<Offset>[_position, point]);
    _position = point;
  }

  /// Adds a cubic segment.
  void cubicTo(double x1, double y1, double x2, double y2, double x3, double y3) {
    final point = Offset(x3, y3);
    _segments.add(<Offset>[_position, Offset(x1, y1), Offset(x2, y2), point]);
    _position = point;
  }

  /// Closes the current contour.
  void close() => lineTo(_start.dx, _start.dy);

  /// Finds extrema after transforming the curve, not its bounding rectangle.
  Rect? bounds(Float64List transform) {
    Rect? result;
    Offset map(Offset p) => Offset(
      transform[0] * p.dx + transform[4] * p.dy + transform[12],
      transform[1] * p.dx + transform[5] * p.dy + transform[13],
    );
    void include(Offset point) {
      final rect = Rect.fromLTRB(point.dx, point.dy, point.dx, point.dy);
      result = result?.expandToInclude(rect) ?? rect;
    }

    for (final List<Offset> segment in _segments) {
      final List<Offset> points = segment.map(map).toList();
      include(points.first);
      include(points.last);
      if (points.length == 4) {
        final Offset p0 = points[0];
        final Offset p1 = points[1];
        final Offset p2 = points[2];
        final Offset p3 = points[3];
        void extrema(double v0, double v1, double v2, double v3) {
          // The derivative divided by three is a*t^2 + b*t + c.
          final double a = -v0 + 3 * v1 - 3 * v2 + v3;
          final double b = 2 * (v0 - 2 * v1 + v2);
          final double c = v1 - v0;
          void root(double t) {
            if (t > 0 && t < 1) {
              final double u = 1 - t;
              include(
                p0 * (u * u * u) + p1 * (3 * u * u * t) + p2 * (3 * u * t * t) + p3 * (t * t * t),
              );
            }
          }

          if (a == 0) {
            if (b != 0) {
              root(-c / b);
            }
          } else {
            final double discriminant = b * b - 4 * a * c;
            if (discriminant >= 0) {
              final double d = math.sqrt(discriminant);
              // This form avoids cancellation for a root close to zero.
              final double q = -.5 * (b + (b < 0 ? -d : d));
              root(q / a);
              if (q != 0) {
                root(c / q);
              }
            }
          }
        }

        extrema(p0.dx, p1.dx, p2.dx, p3.dx);
        extrema(p0.dy, p1.dy, p2.dy, p3.dy);
      }
    }
    return result;
  }
}
