part of 'shapes.dart';

// These epsilon values are used internally to determine when two points are
// the same, within some reasonable roundoff error. The distance epsilon is
// smaller, with the intention that the roundoff should not be larger than a
// pixel on any reasonable sized display.
const distanceEpsilon = 1e-5;
const angleEpsilon = 1e-6;

// This epsilon is based on the observation that people tend to see e.g.
// collinearity much more relaxed than what is mathematically correct. This
// effect is heightened on smaller displays. Use this epsilon for operations
// that allow higher tolerances.
const relaxedDistanceEpsilon = 5e-3;

const twoPi = math.pi * 2;

double distance(double x, double y) => math.sqrt(x * x + y * y);

double distanceSquared(double x, double y) => x * x + y * y;

/// Returns unit vector representing the direction to this point from (0, 0).
Point directionVector(double x, double y) {
  final d = distance(x, y);
  assert(d > 0, 'Required distance greater than zero.');
  return Point(x / d, y / d);
}

Point directionVectorFromAngle(double angleRadians) =>
    Point(math.cos(angleRadians), math.sin(angleRadians));

Point radialToCartesian(
  double radius,
  double angleRadians, [
  Point center = Point.zero,
]) =>
    directionVectorFromAngle(angleRadians) * radius + center;

double square(double x) => x * x;

/// Linearly interpolates between [start] and [stop] with [fraction] fraction
/// between them.
double lerp(double start, double stop, double fraction) {
  return start * (1 - fraction) + stop * fraction;
}

/// Similar to num % mod, but ensures the result is always positive.
///
/// For example: 4 % 3 = positiveModulo(4, 3) = 1, but: -4 % 3 = -1
/// positiveModulo(-4, 3) = 2.
double positiveModulo(double num, double mod) => (num % mod + mod) % mod;

/// Returns whether C is on the line defined by the two points AB.
bool collinearIsh(
  double aX,
  double aY,
  double bX,
  double bY,
  double cX,
  double cY, [
  double tolerance = distanceEpsilon,
]) {
  // The dot product of a perpendicular angle is 0. By rotating one of the
  // vectors, we save the calculations to convert the dot product to degrees
  // afterwards.
  final ab = Point(bX - aX, bY - aY).rotate90();
  final ac = Point(cX - aX, cY - aY);
  final dotProduct = ab.dotProduct(ac).abs();
  final relativeTolerance = tolerance * ab.getDistance() * ac.getDistance();

  return dotProduct < tolerance || dotProduct < relativeTolerance;
}

/// Approximates whether corner at this vertex is concave or convex, based on
/// the relationship of the prev->curr/curr->next vectors.
bool convex(Point previous, Point current, Point next) {
  // TODO: b/369320447 - This is a fast, but not reliable calculation.
  return (current - previous).clockwise(next - current);
}

/// Does a ternary search in [v0..v1] to find the parameter that minimizes the
/// given function.
/// Stops when the search space size is reduced below the given tolerance.
///
// NTS: Does it make sense to split the function f in 2, one to generate a
// candidate, of a custom type T (i.e. (Float) -> T), and one to evaluate it
// ( (T) -> Float )?
double findMinimum(
  double v0,
  double v1,
  double Function(double) f, {
  double tolerance = 1e-3,
}) {
  var a = v0;
  var b = v1;

  while (b - a > tolerance) {
    final c1 = (2 * a + b) / 3;
    final c2 = (2 * b + a) / 3;

    if (f(c1) < f(c2)) {
      b = c2;
    } else {
      a = c1;
    }
  }

  return (a + b) / 2;
}

/// Returns a position of the [value] in [sortedList], if it is there.
///
/// If the list isn't sorted according to the [compare] function on the [keyOf]
/// property of the elements, the result is unpredictable.
///
/// If [value] is not found, returns `-insertionIndex - 1`, where
/// `insertionIndex` is the index at which [value] should be inserted to
/// maintain sorted order.
///
/// If [start] and [end] are supplied, only that range is searched,
/// and only that range need to be sorted.
int binarySearchBy<E, K>(
  List<E> sortedList,
  K Function(E element) keyOf,
  int Function(K, K) compare,
  K value, [
  int start = 0,
  int? end,
]) {
  end = RangeError.checkValidRange(start, end, sortedList.length);
  var min = start;
  var max = end;
  final key = value;
  while (min < max) {
    final mid = min + ((max - min) >> 1);
    final element = sortedList[mid];
    final comp = compare(keyOf(element), key);
    if (comp == 0) return mid;
    if (comp < 0) {
      min = mid + 1;
    } else {
      max = mid;
    }
  }
  return -min - 1;
}

extension DoubleCoerceExtensions on double {
  double coerceAtLeast(double minimumValue) =>
      this < minimumValue ? minimumValue : this;

  double coerceAtMost(double maximumValue) {
    return this > maximumValue ? maximumValue : this;
  }

  double coerceIn(double minimumValue, double maximumValue) {
    if (this < minimumValue) return minimumValue;
    if (this > maximumValue) return maximumValue;
    return this;
  }
}

extension Matrix4PointTransformer on Matrix4 {
  PointTransformer asPointTransformer() {
    return (x, y) {
      final vector = transform3(Vector3(x, y, 0));
      return (vector.x, vector.y);
    };
  }
}

extension RoundedPolygonToPathExtension on RoundedPolygon {
  /// Returns a [Path] representation for a [RoundedPolygon] shape. Note that
  /// there is some rounding happening (to the nearest thousandth), to work
  /// around rendering artifacts introduced by some points being just slightly
  /// off from each other (far less than a pixel). This also allows for a more
  /// optimal path, as redundant curves (usually a single point) can be
  /// detected and not added to the resulting path.
  ///
  /// [path] is a [Path] to reset and set with the new path data.
  ///
  /// [startAngle] is an angle (in degrees) to rotate the [Path] to start
  /// drawing from. The rotation pivot is set to be the polygon's centerX and
  /// centerY coordinates. If [startAngle] is non zero, then caller has to use
  /// the returned [Path], as path transformation creates a new path.
  ///
  /// [repeatPath] is whether or not to repeat the [Path] twice before closing
  /// it. This flag is useful when the caller would like to draw parts of the
  /// path while offsetting the start and stop positions (for example, when
  /// phasing and rotating a path to simulate a motion as a Star circular
  /// progress indicator advances).
  ///
  /// [closePath] is whether or not to close the created [Path].
  Path toPath({
    int startAngle = 0,
    bool repeatPath = false,
    bool closePath = true,
    Path? path,
  }) {
    return pathFromCubics(
      path: path ?? Path(),
      startAngle: startAngle,
      repeatPath: repeatPath,
      closePath: closePath,
      cubics: cubics,
      rotationPivotX: centerX,
      rotationPivotY: centerY,
    );
  }
}

extension MorphToPathExtension on Morph {
  /// Returns a [Path] for a [Morph].
  ///
  /// [progress] is the [Morph]'s progress.
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
  /// [rotationPivotX] is the rotation pivot on the X axis. By default it's set
  /// to 0, and that should align with Morph instances that were created for
  /// [RoundedPolygon] with zero centerX. In case the [RoundedPolygon] were
  /// normalized (i. e. moved to (0.5, 0.5)), or where created with a different
  /// centerX coordinated, this pivot point may need to be aligned to support a
  /// proper rotation.
  ///
  /// [rotationPivotY] is the rotation pivot on the Y axis. By default it's set
  /// to 0, and that should align with Morph instances that were created for
  /// [RoundedPolygon] with zero centerY. In case the RoundedPolygon were
  /// normalized (i. e. moves to (0.5, 0.5)), or where created with a different
  /// centerY coordinated, this pivot point may need to be aligned to support a
  /// proper rotation.
  Path toPath({
    required double progress,
    int startAngle = 0,
    bool repeatPath = false,
    bool closePath = true,
    double rotationPivotX = 0,
    double rotationPivotY = 0,
    Path? path,
  }) {
    return pathFromCubics(
      path: path ?? Path(),
      startAngle: startAngle,
      repeatPath: repeatPath,
      closePath: closePath,
      cubics: asCubics(progress),
      rotationPivotX: rotationPivotX,
      rotationPivotY: rotationPivotY,
    );
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
    final angleToFirstCubic = math.atan2(
      cubics[0].anchor0Y - rotationPivotY,
      cubics[0].anchor0X - rotationPivotX,
    );
    // Rotate the Path to to start from the given angle.
    path = path.transform(
      (Matrix4.identity()
            ..rotateZ(
              -angleToFirstCubic + (startAngle * math.pi / 180),
            ))
          .storage,
    );
  }

  return path;
}
