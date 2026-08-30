// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/src/shapes/corner_rounding.dart';
import 'package:material_ui/src/shapes/cubic.dart';
import 'package:material_ui/src/shapes/point.dart';
import 'package:material_ui/src/shapes/rounded_polygon.dart';

import 'test_utils.dart';

void main() {
  group('Shapes', () {
    const Point zero = Point.zero;
    const epsilon = 0.01;

    double distance(Point start, Point end) {
      final Point vector = end - start;
      return math.sqrt(vector.x * vector.x + vector.y * vector.y);
    }

    // Test that the given point is radius distance away from [center]. If
    // two radii are provided it is sufficient to lie on either one (used for
    // testing points on stars).
    void expectPointOnRadii(Point point, double radius1, [double? radius2, Point center = zero]) {
      radius2 ??= radius1;
      final double dist = distance(center, point);
      try {
        expect(radius1, moreOrLessEquals(dist, epsilon: epsilon));
      } on TestFailure catch (_) {
        expect(radius2, moreOrLessEquals(dist, epsilon: epsilon));
      }
    }

    void expectCubicOnRadii(
      CubicBezier cubic,
      double radius1, [
      double? radius2,
      Point center = zero,
    ]) {
      expectPointOnRadii(Point(cubic.anchor0X, cubic.anchor0Y), radius1, radius2, center);
      expectPointOnRadii(Point(cubic.anchor1X, cubic.anchor1Y), radius1, radius2, center);
    }

    // Tests points along the curve of the cubic by comparing the distance
    // from that point to the center, compared to the requested radius. The
    // test is very lenient since the Circle shape is only a 4x cubic
    // approximation of the circle and varies from the true circle.
    void expectCircularCubic(CubicBezier cubic, double radius, Point center) {
      var t = 0.0;
      while (t <= 1) {
        final Point pointOnCurve = cubic.pointOnCurve(t);
        final double distanceToPoint = distance(center, pointOnCurve);
        expect(radius, moreOrLessEquals(distanceToPoint, epsilon: epsilon));
        t += 0.1;
      }
    }

    void expectCircleShape(List<CubicBezier> shape, {double radius = 1, Point center = zero}) {
      for (final cubic in shape) {
        expectCircularCubic(cubic, radius, center);
      }
    }

    test('circle', () {
      expect(() => RoundedPolygon.circle(numVertices: 2), throwsArgumentError);

      final circle = RoundedPolygon.circle();
      expectCircleShape(circle.cubics);

      final simpleCircle = RoundedPolygon.circle(numVertices: 3);
      expectCircleShape(simpleCircle.cubics);

      final complexCircle = RoundedPolygon.circle(numVertices: 20);
      expectCircleShape(complexCircle.cubics);

      final bigCircle = RoundedPolygon.circle(radius: 3);
      expectCircleShape(bigCircle.cubics, radius: 3);

      const center = Point(1, 2);
      final offsetCircle = RoundedPolygon.circle(center: center);
      expectCircleShape(offsetCircle.cubics, center: center);
    });

    // Stars are complicated. For the unrounded version, we can check whether
    // the vertices are the right distance from the center. For the rounded
    // versions, just check that the shape is within the appropriate bounds.
    test('star', () {
      var star = RoundedPolygon.star(numVerticesPerRadius: 4);
      List<CubicBezier> shape = star.cubics;
      var radius = 1.0;
      var innerRadius = 0.5;

      for (final cubic in shape) {
        expectCubicOnRadii(cubic, radius, innerRadius);
      }

      const center = Point(1, 2);
      star = RoundedPolygon.star(numVerticesPerRadius: 4, innerRadius: innerRadius, center: center);
      shape = star.cubics;
      for (final cubic in shape) {
        expectCubicOnRadii(cubic, radius, innerRadius, center);
      }

      radius = 4;
      innerRadius = 2;
      star = RoundedPolygon.star(numVerticesPerRadius: 4, radius: radius, innerRadius: innerRadius);
      shape = star.cubics;
      for (final cubic in shape) {
        expectCubicOnRadii(cubic, radius, innerRadius);
      }
    });

    test('rounded star', () {
      const rounding = CornerRounding(radius: 0.1);
      const innerRounding = CornerRounding(radius: 0.2);
      final perVtxRounded = [
        rounding,
        innerRounding,
        rounding,
        innerRounding,
        rounding,
        innerRounding,
        rounding,
        innerRounding,
      ];
      const min = Point(-1, -1);
      const max = Point(1, 1);

      var star = RoundedPolygon.star(numVerticesPerRadius: 4, rounding: rounding);
      expectInBounds(star.cubics, min, max);

      star = RoundedPolygon.star(numVerticesPerRadius: 4, innerRounding: innerRounding);
      expectInBounds(star.cubics, min, max);

      star = RoundedPolygon.star(
        numVerticesPerRadius: 4,
        rounding: rounding,
        innerRounding: innerRounding,
      );
      expectInBounds(star.cubics, min, max);

      star = RoundedPolygon.star(numVerticesPerRadius: 4, perVertexRounding: perVtxRounded);
      expectInBounds(star.cubics, min, max);

      expect(
        () => RoundedPolygon.star(numVerticesPerRadius: 6, perVertexRounding: perVtxRounded),
        throwsArgumentError,
      );
    });
  });
}
