import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/src/shapes/shapes/shapes.dart';
import 'package:vector_math/vector_math_64.dart';

const _epsilon = 1e-4;

bool equalish(double f0, double f1, double epsilon) {
  return (f0 - f1).abs() < epsilon;
}

bool pointsEqualish(Point p0, Point p1) {
  return equalish(p0.x, p1.x, _epsilon) && equalish(p0.y, p1.y, _epsilon);
}

bool cubicsEqualish(Cubic c0, Cubic c1) {
  return pointsEqualish(Point(c0.anchor0X, c0.anchor0Y), Point(c1.anchor0X, c1.anchor0Y)) &&
      pointsEqualish(Point(c0.anchor1X, c0.anchor1Y), Point(c1.anchor1X, c1.anchor1Y)) &&
      pointsEqualish(Point(c0.control0X, c0.control0Y), Point(c1.control0X, c1.control0Y)) &&
      pointsEqualish(Point(c0.control1X, c0.control1Y), Point(c1.control1X, c1.control1Y));
}

// Test points equality within epsilon.
void expectPointsEqualish(Point expected, Point actual) {
  final msg = '$expected vs. $actual';
  expect(expected.x, moreOrLessEquals(actual.x, epsilon: _epsilon), reason: msg);
  expect(expected.y, moreOrLessEquals(actual.y, epsilon: _epsilon), reason: msg);
}

void expectCubicsEqualish(Cubic expected, Cubic actual) {
  expectPointsEqualish(
    Point(expected.anchor0X, expected.anchor0Y),
    Point(actual.anchor0X, actual.anchor0Y),
  );
  expectPointsEqualish(
    Point(expected.control0X, expected.control0Y),
    Point(actual.control0X, actual.control0Y),
  );
  expectPointsEqualish(
    Point(expected.control1X, expected.control1Y),
    Point(actual.control1X, actual.control1Y),
  );
  expectPointsEqualish(
    Point(expected.anchor1X, expected.anchor1Y),
    Point(actual.anchor1X, actual.anchor1Y),
  );
}

void expectCubicListsEqualish(List<Cubic> expected, List<Cubic> actual) {
  expect(expected.length, actual.length);
  for (var i = 0; i < expected.length; i++) {
    expectCubicsEqualish(expected[i], actual[i]);
  }
}

void expectFeaturesEqualish(Feature expected, Feature actual) {
  expectCubicListsEqualish(expected.cubics, actual.cubics);
  expect(expected.runtimeType, actual.runtimeType);

  if (expected is CornerFeature && actual is CornerFeature) {
    expect(expected.convex, actual.convex);
  }
}

void expectPolygonsEqualish(RoundedPolygon expected, RoundedPolygon actual) {
  expectCubicListsEqualish(expected.cubics, actual.cubics);

  expect(expected.features.length, actual.features.length);
  for (var i = 0; i < expected.features.length; i++) {
    expectFeaturesEqualish(expected.features[i], actual.features[i]);
  }
}

void expectPointGreaterish(Point expected, Point actual) {
  expect(actual.x >= expected.x - _epsilon, isTrue);
  expect(actual.y >= expected.y - _epsilon, isTrue);
}

void expectPointLessish(Point expected, Point actual) {
  expect(actual.x <= expected.x + _epsilon, isTrue);
  expect(actual.y <= expected.y + _epsilon, isTrue);
}

void expectEqualish(double expected, double actual, [String? message]) {
  expect(expected, moreOrLessEquals(actual, epsilon: _epsilon), reason: message);
}

void expectInBounds(List<Cubic> shape, Point minPoint, Point maxPoint) {
  for (final cubic in shape) {
    expectPointGreaterish(minPoint, Point(cubic.anchor0X, cubic.anchor0Y));
    expectPointLessish(maxPoint, Point(cubic.anchor0X, cubic.anchor0Y));
    expectPointGreaterish(minPoint, Point(cubic.control0X, cubic.control0Y));
    expectPointLessish(maxPoint, Point(cubic.control0X, cubic.control0Y));
    expectPointGreaterish(minPoint, Point(cubic.control1X, cubic.control1Y));
    expectPointLessish(maxPoint, Point(cubic.control1X, cubic.control1Y));
    expectPointGreaterish(minPoint, Point(cubic.anchor1X, cubic.anchor1Y));
    expectPointLessish(maxPoint, Point(cubic.anchor1X, cubic.anchor1Y));
  }
}

PointTransformer identityTransform() =>
    (x, y) => (x, y);

PointTransformer pointRotator(double angleDegrees) {
  final double angleRadians = angleDegrees * math.pi / 180;
  final matrix = Matrix4.identity()..rotateZ(angleRadians);
  return matrix.asPointTransformer();
}

PointTransformer scaleTransform(double sx, double sy) =>
    (x, y) => (x * sx, y * sy);

PointTransformer translateTransform(double dx, double dy) =>
    (x, y) => (x + dx, y + dy);
