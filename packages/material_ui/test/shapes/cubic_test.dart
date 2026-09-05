// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/src/shapes/cubic.dart';
import 'package:material_ui/src/shapes/point.dart';

import 'test_utils.dart';

void main() {
  group('$CubicBezier', () {
    // These points create a roughly circular arc in the upper-right quadrant
    // around (0,0).
    const Point zero = Point.zero;
    const p0 = Point(1, 0);
    const p1 = Point(1, 0.5);
    const p2 = Point(0.5, 1);
    const p3 = Point(0, 1);
    final cubic = CubicBezier(p0, p1, p2, p3);

    test('anchors and controls', () {
      expect(p0, cubic.anchor0);
      expect(p1, cubic.control0);
      expect(p2, cubic.control1);
      expect(p3, cubic.anchor1);
    });

    test('circularArc', () {
      final arcCubic = CubicBezier.circularArc(zero, p0, p3);
      expect(p0, arcCubic.anchor0);
      expect(p3, arcCubic.anchor1);
    });

    test('div', () {
      CubicBezier divCubic = cubic / 1;
      expectCubicsEqualish(cubic, divCubic);
      divCubic = cubic / 1;
      expectCubicsEqualish(cubic, divCubic);
      divCubic = cubic / 2;
      expectPointsEqualish(p0 / 2, divCubic.anchor0);
      expectPointsEqualish(p1 / 2, divCubic.control0);
      expectPointsEqualish(p2 / 2, divCubic.control1);
      expectPointsEqualish(p3 / 2, divCubic.anchor1);
      divCubic = cubic / 2;
      expectPointsEqualish(p0 / 2, divCubic.anchor0);
      expectPointsEqualish(p1 / 2, divCubic.control0);
      expectPointsEqualish(p2 / 2, divCubic.control1);
      expectPointsEqualish(p3 / 2, divCubic.anchor1);
    });

    test('times', () {
      CubicBezier timesCubic = cubic * 1;
      expect(p0, timesCubic.anchor0);
      expect(p1, timesCubic.control0);
      expect(p2, timesCubic.control1);
      expect(p3, timesCubic.anchor1);
      timesCubic = cubic * 1;
      expect(p0, timesCubic.anchor0);
      expect(p1, timesCubic.control0);
      expect(p2, timesCubic.control1);
      expect(p3, timesCubic.anchor1);
      timesCubic = cubic * 2;
      expectPointsEqualish(p0 * 2, timesCubic.anchor0);
      expectPointsEqualish(p1 * 2, timesCubic.control0);
      expectPointsEqualish(p2 * 2, timesCubic.control1);
      expectPointsEqualish(p3 * 2, timesCubic.anchor1);
      timesCubic = cubic * 2;
      expectPointsEqualish(p0 * 2, timesCubic.anchor0);
      expectPointsEqualish(p1 * 2, timesCubic.control0);
      expectPointsEqualish(p2 * 2, timesCubic.control1);
      expectPointsEqualish(p3 * 2, timesCubic.anchor1);
    });

    test('plus', () {
      final CubicBezier offsetCubic = cubic * 2;
      final CubicBezier plusCubic = cubic + offsetCubic;
      expectPointsEqualish(p0 + offsetCubic.anchor0, plusCubic.anchor0);
      expectPointsEqualish(p1 + offsetCubic.control0, plusCubic.control0);
      expectPointsEqualish(p2 + offsetCubic.control1, plusCubic.control1);
      expectPointsEqualish(p3 + offsetCubic.anchor1, plusCubic.anchor1);
    });

    test('reversed', () {
      final CubicBezier reverseCubic = cubic.reversed;
      expect(p3, reverseCubic.anchor0);
      expect(p2, reverseCubic.control0);
      expect(p1, reverseCubic.control1);
      expect(p0, reverseCubic.anchor1);
    });

    void expectBetween(Point end0, Point end1, Point actual) {
      final double minX = math.min(end0.x, end1.x);
      final double minY = math.min(end0.y, end1.y);
      final double maxX = math.max(end0.x, end1.x);
      final double maxY = math.max(end0.y, end1.y);
      expect(minX <= actual.x, isTrue);
      expect(minY <= actual.y, isTrue);
      expect(maxX >= actual.x, isTrue);
      expect(maxY >= actual.y, isTrue);
    }

    test('straightLine', () {
      final lineCubic = CubicBezier.straightLine(p0, p3);
      expect(p0, lineCubic.anchor0);
      expect(p3, lineCubic.anchor1);
      expectBetween(p0, p3, lineCubic.control0);
      expectBetween(p0, p3, lineCubic.control1);
    });

    test('split', () {
      final (CubicBezier split0, CubicBezier split1) = cubic.split(0.5);
      expect(cubic.anchor0, split0.anchor0);
      expect(cubic.anchor1, split1.anchor1);
      expectBetween(cubic.anchor0, cubic.anchor1, split0.anchor1);
      expectBetween(cubic.anchor0, cubic.anchor1, split1.anchor0);
    });

    test('pointAt', () {
      Point halfway = cubic.pointAt(0.5);
      expectBetween(cubic.anchor0, cubic.anchor1, halfway);
      final straightLineCubic = CubicBezier.straightLine(p0, p3);
      halfway = straightLineCubic.pointAt(0.5);
      final computedHalfway = Point(p0.x + 0.5 * (p3.x - p0.x), p0.y + 0.5 * (p3.y - p0.y));
      expectPointsEqualish(computedHalfway, halfway);
    });

    test('transform', () {
      PointTransformer transform = identityTransform();
      CubicBezier transformedCubic = cubic.transformed(transform);
      expectCubicsEqualish(cubic, transformedCubic);

      transform = scaleTransform(3, 3);
      transformedCubic = cubic.transformed(transform);
      expectCubicsEqualish(cubic * 3, transformedCubic);

      const tx = 200.0;
      const ty = 300.0;
      const translationVector = Point(tx, ty);
      transform = translateTransform(tx, ty);
      transformedCubic = cubic.transformed(transform);
      expectPointsEqualish(cubic.anchor0 + translationVector, transformedCubic.anchor0);
      expectPointsEqualish(cubic.control0 + translationVector, transformedCubic.control0);
      expectPointsEqualish(cubic.control1 + translationVector, transformedCubic.control1);
      expectPointsEqualish(cubic.anchor1 + translationVector, transformedCubic.anchor1);
    });

    test('point CubicBezier has zero length', () {
      expect(CubicBezier.point(const Point(10, 10)).isZeroLength, isTrue);
    });

    test('== compares points by value', () {
      final equalCubic = CubicBezier(p0, p1, p2, p3);
      final otherCubic = CubicBezier(p0, p1, p2, zero);

      expect(identical(cubic, equalCubic), isFalse);
      expect(cubic, equalCubic);
      expect(cubic.hashCode, equalCubic.hashCode);
      expect(cubic, isNot(otherCubic));
    });

    test('toString', () {
      expect(
        CubicBezier(Point.zero, const Point(1, 0), const Point(2, 0), const Point(3, 0)).toString(),
        'CubicBezier(anchor0: (0.0, 0.0), control0: (1.0, 0.0), '
        'control1: (2.0, 0.0), anchor1: (3.0, 0.0))',
      );
    });
  });

  group('pathFromCubics', () {
    // A triangle whose first curve starts one unit along the positive X-axis,
    // so its start angle around the origin is zero.
    final triangle = [
      CubicBezier.straightLine(const Point(1, 0), const Point(0, 1)),
      CubicBezier.straightLine(const Point(0, 1), const Point(0, -1)),
      CubicBezier.straightLine(const Point(0, -1), const Point(1, 0)),
    ];

    test('startAngle is in radians', () {
      // A quarter turn moves the start point to one unit along the positive
      // Y-axis.
      final Path path = pathFromCubics(triangle, startAngle: math.pi / 2);
      expectPointsEqualish(const Point(0, 1), pathStartPoint(path));
    });

    test('startAngle rotates around rotationPivot', () {
      const pivot = Point(5, 5);
      // A diamond around the pivot, whose first curve starts at angle zero
      // from it.
      final diamond = [
        CubicBezier.straightLine(const Point(6, 5), const Point(5, 6)),
        CubicBezier.straightLine(const Point(5, 6), const Point(4, 5)),
        CubicBezier.straightLine(const Point(4, 5), const Point(5, 4)),
        CubicBezier.straightLine(const Point(5, 4), const Point(6, 5)),
      ];

      final Path path = pathFromCubics(diamond, startAngle: math.pi / 2, rotationPivot: pivot);

      // A quarter turn gives back the same diamond, so the bounds stay centered
      // on the pivot. Only the start point changes, landing on the next vertex.
      // Rotating about the origin would move the bounds instead.
      expectPointsEqualish(pivot, path.getBounds().center);
      expectPointsEqualish(const Point(5, 6), pathStartPoint(path));
    });

    test('repeatPath doubles the contour', () {
      final double single = pathFromCubics(triangle).computeMetrics().first.length;
      final double doubled = pathFromCubics(
        triangle,
        repeatPath: true,
      ).computeMetrics().first.length;
      expectEqualish(single * 2, doubled);
    });

    test('closePath closes the contour', () {
      expect(pathFromCubics(triangle).computeMetrics().first.isClosed, isTrue);
      expect(pathFromCubics(triangle, closePath: false).computeMetrics().first.isClosed, isFalse);
    });
  });
}
