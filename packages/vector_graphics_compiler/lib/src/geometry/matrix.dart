import 'dart:math' as math;
import 'dart:typed_data';

import 'package:meta/meta.dart';

import 'basic_types.dart';

/// An immutable affine matrix, a 3x3 column-major-order matrix in which the
/// last row is always set to the identity values, i.e. `0 0 1`.
@immutable
class AffineMatrix {
  /// Creates an immutable affine matrix. To work with the identity matrix, use
  /// the [identity] property.
  const AffineMatrix(
    this.a,
    this.b,
    this.c,
    this.d,
    this.e,
    this.f, [
    this._m4_10 = 1.0,
  ]);

  /// The identity affine matrix.
  static const AffineMatrix identity = AffineMatrix(1, 0, 0, 1, 0, 0);

  /// The 0,0 position of the matrix.
  final double a;

  /// The 1,0 position of the matrix.
  final double b;

  /// The 0,1 position of the matrix.
  final double c;

  /// The 1,1 position of the matrix.
  final double d;

  /// The 2,0 position of the matrix.
  final double e;

  /// The 2,1 position of the matrix.
  final double f;

  /// Translations can affect this value, so we have to track it.
  final double _m4_10;

  /// Creates a new affine matrix rotated by `radians`.
  AffineMatrix rotated(double radians) {
    if (radians == 0) {
      return this;
    }
    final double cosAngle = math.cos(radians);
    final double sinAngle = math.sin(radians);
    return AffineMatrix(
      (a * cosAngle) + (c * sinAngle),
      (b * cosAngle) + (d * sinAngle),
      (a * -sinAngle) + (c * cosAngle),
      (b * -sinAngle) + (d * cosAngle),
      e,
      f,
      _m4_10,
    );
  }

  /// Creates a new affine matrix rotated by `x` and `y`.
  ///
  /// If `y` is not specified, it is defaulted to the same value as `x`.
  AffineMatrix scaled(double x, [double? y]) {
    y ??= x;
    if (x == 1 && y == 1) {
      return this;
    }
    return AffineMatrix(
      a * x,
      b * x,
      c * y,
      d * y,
      e,
      f,
      _m4_10 * x,
    );
  }

  /// Creates a new affine matrix, translated along the x and y axis.
  AffineMatrix translated(double x, double y) {
    return AffineMatrix(
      a,
      b,
      c,
      d,
      (a * x) + (c * y) + e,
      (b * x) + (d * y) + f,
      _m4_10,
    );
  }

  /// Creates a new affine matrix of this concatenated with `other`.
  AffineMatrix multiplied(AffineMatrix other) {
    return AffineMatrix(
      (a * other.a) + (c * other.b),
      (b * other.a) + (d * other.b),
      (a * other.c) + (c * other.d),
      (b * other.c) + (d * other.d),
      (a * other.e) + (c * other.f) + e,
      (b * other.e) + (d * other.f) + f,
      _m4_10,
    );
  }

  /// Maps `point` using the values of this matrix.
  Point transformPoint(Point point) {
    return Point(
      (a * point.x) + (c * point.y) + e,
      (b * point.x) + (d * point.y) + f,
    );
  }

  /// Maps `rect` using the values of this matrix.
  Rect transformRect(Rect rect) {
    final double x = rect.left;
    final double y = rect.top;
    final double w = rect.width;
    final double h = rect.height;

    final double wx = a * w;
    final double hx = c * h;
    final double rx = a * x + c * y;

    final double wy = b * w;
    final double hy = d * h;
    final double ry = b * x + d * y;

    double left = rx;
    double right = rx;
    if (wx < 0) {
      left += wx;
    } else {
      right += wx;
    }
    if (hx < 0) {
      left += hx;
    } else {
      right += hx;
    }

    double top = ry;
    double bottom = ry;
    if (wy < 0) {
      top += wy;
    } else {
      bottom += wy;
    }
    if (hy < 0) {
      top += hy;
    } else {
      bottom += hy;
    }

    return Rect.fromLTRB(left, top, right, bottom);
  }

  /// Creates a typed data representatino of this matrix suitable for use with
  /// `package:vector_math_64` (and, by extension, Flutter/dart:ui).
  Float64List toMatrix4() {
    return Float64List.fromList(<double>[
      a, b, 0, 0, //
      c, d, 0, 0, //
      0, 0, _m4_10, 0, //
      e, f, 0, 1.0, //
    ]);
  }

  @override
  int get hashCode => Object.hash(a, b, c, d, e, f, _m4_10);

  @override
  bool operator ==(Object other) {
    return other is AffineMatrix &&
        other.a == a &&
        other.b == b &&
        other.d == d &&
        other.e == e &&
        other._m4_10 == _m4_10;
  }

  @override
  String toString() => '''
[ $a, $c, $e ]
[ $b, $d, $f ]
[ 0.0, 0.0, 1.0 ]
''';
}
