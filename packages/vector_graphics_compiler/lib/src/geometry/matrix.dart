// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:math' as math;
import 'dart:typed_data';

import 'package:meta/meta.dart';
import '../../vector_graphics_compiler.dart';

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
    double? m4_10,
  ]) : _m4_10 = m4_10 ?? (1.0 * a);

  /// The identity affine matrix.
  static const AffineMatrix identity = AffineMatrix(1, 0, 0, 1, 0, 0);

  /// The 0,0 position of the matrix.
  final double a;

  /// The 0,1 position of the matrix.
  final double b;

  /// The 1,0 position of the matrix.
  final double c;

  /// The 1,1 position of the matrix.
  final double d;

  /// The 2,0 position of the matrix.
  final double e;

  /// The 1,2 position of the matrix.
  final double f;

  /// Translations can affect this value, so we have to track it.
  final double _m4_10;

  /// Calculates the scale for a stroke width based on the average of the x- and
  /// y-axis scales of this matrix.
  double? scaleStrokeWidth(double? width) {
    if (width == null || (a == 1 && d == 1)) {
      return width;
    }

    final double xScale = math.sqrt(a * a + c * c);
    final double yScale = math.sqrt(b * b + d * d);

    return (xScale + yScale) / 2 * width;
  }

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

  /// Whether this matrix can be expressed be applied to a rect without any loss
  /// of inforamtion.
  ///
  /// In other words, if this matrix is a simple translate and/or non-negative
  /// scale with no rotation or skew, this property is true. Otherwise, it is
  /// false.
  bool get encodableInRect {
    return a > 0 && b == 0 && c == 0 && d > 0 && _m4_10 == a;
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

  /// Creates a new affine matrix, skewed along the x axis.
  AffineMatrix xSkewed(double x) {
    return multiplied(AffineMatrix(
      identity.a,
      identity.b,
      math.tan(x),
      identity.d,
      identity.e,
      identity.f,
      identity._m4_10,
    ));
  }

  /// Creates a new affine matrix, skewed along the y axis.
  AffineMatrix ySkewed(double y) {
    return multiplied(AffineMatrix(
      identity.a,
      math.tan(y),
      identity.c,
      identity.d,
      identity.e,
      identity.f,
      identity._m4_10,
    ));
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
      _m4_10 * other._m4_10,
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
    return _transformRect(toMatrix4(), rect);
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
        other.c == c &&
        other.d == d &&
        other.e == e &&
        other.f == f &&
        other._m4_10 == _m4_10;
  }

  @override
  String toString() => '''
[ $a, $c, $e ]
[ $b, $d, $f ]
[ 0.0, 0.0, 1.0 ] // _m4_10 = $_m4_10
''';
}

// transformRect implementation from package:flutter.

/// Returns a rect that bounds the result of applying the given matrix as a
/// perspective transform to the given rect.
///
/// This function assumes the given rect is in the plane with z equals 0.0.
/// The transformed rect is then projected back into the plane with z equals
/// 0.0 before computing its bounding rect.
Rect _transformRect(Float64List transform, Rect rect) {
  final Float64List storage = transform;
  final double x = rect.left;
  final double y = rect.top;
  final double w = rect.right - x;
  final double h = rect.bottom - y;

  // We want to avoid turning a finite rect into an infinite one if we can.
  assert(w.isFinite && h.isFinite, '($w, $h)');

  // Transforming the 4 corners of a rectangle the straightforward way
  // incurs the cost of transforming 4 points using vector math which
  // involves 48 multiplications and 48 adds and then normalizing
  // the points using 4 inversions of the homogeneous weight factor
  // and then 12 multiplies. Once we have transformed all of the points
  // we then need to turn them into a bounding box using 4 min/max
  // operations each on 4 values yielding 12 total comparisons.
  //
  // On top of all of those operations, using the vector_math package to
  // do the work for us involves allocating several objects in order to
  // communicate the values back and forth - 4 allocating getters to extract
  // the [Offset] objects for the corners of the [Rect], 4 conversions to
  // a [Vector3] to use [Matrix4.perspectiveTransform()], and then 4 new
  // [Offset] objects allocated to hold those results, yielding 8 [Offset]
  // and 4 [Vector3] object allocations per rectangle transformed.
  //
  // But the math we really need to get our answer is actually much less
  // than that.
  //
  // First, consider that a full point transform using the vector math
  // package involves expanding it out into a vector3 with a Z coordinate
  // of 0.0 and then performing 3 multiplies and 3 adds per coordinate:
  // ```
  // xt = x*m00 + y*m10 + z*m20 + m30;
  // yt = x*m01 + y*m11 + z*m21 + m31;
  // zt = x*m02 + y*m12 + z*m22 + m32;
  // wt = x*m03 + y*m13 + z*m23 + m33;
  // ```
  // Immediately we see that we can get rid of the 3rd column of multiplies
  // since we know that Z=0.0. We can also get rid of the 3rd row because
  // we ignore the resulting Z coordinate. Finally we can get rid of the
  // last row if we don't have a perspective transform since we can verify
  // that the results are 1.0 for all points.  This gets us down to 16
  // multiplies and 16 adds in the non-perspective case and 24 of each for
  // the perspective case. (Plus the 12 comparisons to turn them back into
  // a bounding box.)
  //
  // But we can do even better than that.
  //
  // Under optimal conditions of no perspective transformation,
  // which is actually a very common condition, we can transform
  // a rectangle in as little as 3 operations:
  //
  // (rx,ry) = transform of upper left corner of rectangle
  // (wx,wy) = delta transform of the (w, 0) width relative vector
  // (hx,hy) = delta transform of the (0, h) height relative vector
  //
  // A delta transform is a transform of all elements of the matrix except
  // for the translation components. The translation components are added
  // in at the end of each transform computation so they represent a
  // constant offset for each point transformed. A delta transform of
  // a horizontal or vertical vector involves a single multiplication due
  // to the fact that it only has one non-zero coordinate and no addition
  // of the translation component.
  //
  // In the absence of a perspective transform, the transformed
  // rectangle will be mapped into a parallelogram with corners at:
  // corner1 = (rx, ry)
  // corner2 = corner1 + dTransformed width vector = (rx+wx, ry+wy)
  // corner3 = corner1 + dTransformed height vector = (rx+hx, ry+hy)
  // corner4 = corner1 + both dTransformed vectors = (rx+wx+hx, ry+wy+hy)
  // In all, this method of transforming the rectangle requires only
  // 8 multiplies and 12 additions (which we can reduce to 8 additions if
  // we only need a bounding box, see below).
  //
  // In the presence of a perspective transform, the above conditions
  // continue to hold with respect to the non-normalized coordinates so
  // we can still save a lot of multiplications by computing the 4
  // non-normalized coordinates using relative additions before we normalize
  // them and they lose their "pseudo-parallelogram" relationships.  We still
  // have to do the normalization divisions and min/max all 4 points to
  // get the resulting transformed bounding box, but we save a lot of
  // calculations over blindly transforming all 4 coordinates independently.
  // In all, we need 12 multiplies and 22 additions to construct the
  // non-normalized vectors and then 8 divisions (or 4 inversions and 8
  // multiplies) for normalization (plus the standard set of 12 comparisons
  // for the min/max bounds operations).
  //
  // Back to the non-perspective case, the optimization that lets us get
  // away with fewer additions if we only need a bounding box comes from
  // analyzing the impact of the relative vectors on expanding the
  // bounding box of the parallelogram. First, the bounding box always
  // contains the transformed upper-left corner of the rectangle. Next,
  // each relative vector either pushes on the left or right side of the
  // bounding box and also either the top or bottom side, depending on
  // whether it is positive or negative. Finally, you can consider the
  // impact of each vector on the bounding box independently. If, say,
  // wx and hx have the same sign, then the limiting point in the bounding
  // box will be the one that involves adding both of them to the origin
  // point. If they have opposite signs, then one will push one wall one
  // way and the other will push the opposite wall the other way and when
  // you combine both of them, the resulting "opposite corner" will
  // actually be between the limits they established by pushing the walls
  // away from each other, as below:
  // ```
  //         +---------(originx,originy)--------------+
  //         |            -----^----                  |
  //         |       -----          ----              |
  //         |  -----                   ----          |
  // (+hx,+hy)<                             ----      |
  //         |  ----                            ----  |
  //         |      ----                             >(+wx,+wy)
  //         |          ----                   -----  |
  //         |              ----          -----       |
  //         |                  ---- -----            |
  //         |                      v                 |
  //         +---------------(+wx+hx,+wy+hy)----------+
  // ```
  // In this diagram, consider that:
  // ```
  // wx would be a positive number
  // hx would be a negative number
  // wy and hy would both be positive numbers
  // ```
  // As a result, wx pushes out the right wall, hx pushes out the left wall,
  // and both wy and hy push down the bottom wall of the bounding box. The
  // wx,hx pair (of opposite signs) worked on opposite walls and the final
  // opposite corner had an X coordinate between the limits they established.
  // The wy,hy pair (of the same sign) both worked together to push the
  // bottom wall down by their sum.
  //
  // This relationship allows us to simply start with the point computed by
  // transforming the upper left corner of the rectangle, and then
  // conditionally adding wx, wy, hx, and hy to either the left or top
  // or right or bottom of the bounding box independently depending on sign.
  // In that case we only need 4 comparisons and 4 additions total to
  // compute the bounding box, combined with the 8 multiplications and
  // 4 additions to compute the transformed point and relative vectors
  // for a total of 8 multiplies, 8 adds, and 4 comparisons.
  //
  // An astute observer will note that we do need to do 2 subtractions at
  // the top of the method to compute the width and height.  Add those to
  // all of the relative solutions listed above.  The test for perspective
  // also adds 3 compares to the affine case and up to 3 compares to the
  // perspective case (depending on which test fails, the rest are omitted).
  //
  // The final tally:
  // basic method          = 60 mul + 48 add + 12 compare
  // optimized perspective = 12 mul + 22 add + 15 compare + 2 sub
  // optimized affine      =  8 mul +  8 add +  7 compare + 2 sub
  //
  // Since compares are essentially subtractions and subtractions are
  // the same cost as adds, we end up with:
  // basic method          = 60 mul + 60 add/sub/compare
  // optimized perspective = 12 mul + 39 add/sub/compare
  // optimized affine      =  8 mul + 17 add/sub/compare

  final double wx = storage[0] * w;
  final double hx = storage[4] * h;
  final double rx = storage[0] * x + storage[4] * y + storage[12];

  final double wy = storage[1] * w;
  final double hy = storage[5] * h;
  final double ry = storage[1] * x + storage[5] * y + storage[13];

  if (storage[3] == 0.0 && storage[7] == 0.0 && storage[15] == 1.0) {
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
  } else {
    final double ww = storage[3] * w;
    final double hw = storage[7] * h;
    final double rw = storage[3] * x + storage[7] * y + storage[15];

    final double ulx = rx / rw;
    final double uly = ry / rw;
    final double urx = (rx + wx) / (rw + ww);
    final double ury = (ry + wy) / (rw + ww);
    final double llx = (rx + hx) / (rw + hw);
    final double lly = (ry + hy) / (rw + hw);
    final double lrx = (rx + wx + hx) / (rw + ww + hw);
    final double lry = (ry + wy + hy) / (rw + ww + hw);

    return Rect.fromLTRB(
      _min4(ulx, urx, llx, lrx),
      _min4(uly, ury, lly, lry),
      _max4(ulx, urx, llx, lrx),
      _max4(uly, ury, lly, lry),
    );
  }
}

double _min4(double a, double b, double c, double d) {
  final double e = (a < b) ? a : b;
  final double f = (c < d) ? c : d;
  return (e < f) ? e : f;
}

double _max4(double a, double b, double c, double d) {
  final double e = (a > b) ? a : b;
  final double f = (c > d) ? c : d;
  return (e > f) ? e : f;
}
