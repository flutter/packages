// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/src/shapes/cubic.dart';
import 'package:material_ui/src/shapes/features.dart';
import 'package:material_ui/src/shapes/point.dart';
import 'package:material_ui/src/shapes/rounded_polygon.dart';
import 'package:vector_math/vector_math_64.dart';

const _epsilon = 1e-4;

bool equalish(double f0, double f1, double epsilon) {
  return (f0 - f1).abs() < epsilon;
}

bool pointsEqualish(Point p0, Point p1) {
  return equalish(p0.x, p1.x, _epsilon) && equalish(p0.y, p1.y, _epsilon);
}

bool cubicsEqualish(CubicBezier c0, CubicBezier c1) {
  return pointsEqualish(c0.anchor0, c1.anchor0) &&
      pointsEqualish(c0.anchor1, c1.anchor1) &&
      pointsEqualish(c0.control0, c1.control0) &&
      pointsEqualish(c0.control1, c1.control1);
}

// Test points equality within epsilon.
void expectPointsEqualish(Point expected, Point actual) {
  final msg = '$expected vs. $actual';
  expect(expected.x, moreOrLessEquals(actual.x, epsilon: _epsilon), reason: msg);
  expect(expected.y, moreOrLessEquals(actual.y, epsilon: _epsilon), reason: msg);
}

void expectCubicsEqualish(CubicBezier expected, CubicBezier actual) {
  expectPointsEqualish(expected.anchor0, actual.anchor0);
  expectPointsEqualish(expected.control0, actual.control0);
  expectPointsEqualish(expected.control1, actual.control1);
  expectPointsEqualish(expected.anchor1, actual.anchor1);
}

void expectCubicListsEqualish(List<CubicBezier> expected, List<CubicBezier> actual) {
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

void expectInBounds(List<CubicBezier> shape, Point minPoint, Point maxPoint) {
  for (final cubic in shape) {
    expectPointGreaterish(minPoint, cubic.anchor0);
    expectPointLessish(maxPoint, cubic.anchor0);
    expectPointGreaterish(minPoint, cubic.control0);
    expectPointLessish(maxPoint, cubic.control0);
    expectPointGreaterish(minPoint, cubic.control1);
    expectPointLessish(maxPoint, cubic.control1);
    expectPointGreaterish(minPoint, cubic.anchor1);
    expectPointLessish(maxPoint, cubic.anchor1);
  }
}

// The point a path starts drawing from.
Point pathStartPoint(Path path) => path.computeMetrics().first.getTangentForOffset(0)!.position;

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
