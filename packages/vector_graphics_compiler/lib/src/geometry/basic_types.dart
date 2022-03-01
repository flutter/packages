import 'dart:math' as math;
import 'package:meta/meta.dart';

/// An immutable position in two-dimensional space.
///
/// This class is roughly compatible with dart:ui's Offset.
@immutable
class Point {
  /// Creates a point object with x,y coordinates.
  const Point(this.x, this.y);

  static const Point zero = Point(0, 0);

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

  Point operator /(double divisor) {
    return Point(x / divisor, y / divisor);
  }

  Point operator *(double multiplicand) {
    return Point(x * multiplicand, y * multiplicand);
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

  /// The top left corner of the rect.
  Point get topLeft => Point(left, top);

  /// The top right corner of the rect.
  Point get topRight => Point(right, top);

  /// The bottom left corner of the rect.
  Point get bottomLeft => Point(bottom, left);

  /// The bottom right corner of the rect.
  Point get bottomRight => Point(bottom, right);

  /// The size of the rectangle, expressed as a [Point].
  Point get size => Point(width, height);

  /// Creates the smallest rectangle that covers the edges of this and `other`.
  Rect expanded(Rect other) {
    return Rect.fromLTRB(
      math.min(left, other.left),
      math.min(top, other.top),
      math.max(right, other.right),
      math.max(bottom, other.bottom),
    );
  }

  @override
  String toString() => 'Rect.fromLTRB($left, $top, $right, $bottom)';

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
}
