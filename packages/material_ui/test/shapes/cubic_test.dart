// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/src/shapes/shapes.dart';

import 'test_utils.dart';

void main() {
  group('$Cubic', () {
    // These points create a roughly circular arc in the upper-right quadrant
    // around (0,0).
    const Point zero = Point.zero;
    const p0 = Point(1, 0);
    const p1 = Point(1, 0.5);
    const p2 = Point(0.5, 1);
    const p3 = Point(0, 1);
    final cubic = Cubic.fromPoints(p0, p1, p2, p3);

    test('fromPoints', () {
      expect(p0, Point(cubic.anchor0X, cubic.anchor0Y));
      expect(p1, Point(cubic.control0X, cubic.control0Y));
      expect(p2, Point(cubic.control1X, cubic.control1Y));
      expect(p3, Point(cubic.anchor1X, cubic.anchor1Y));
    });

    test('circularArc', () {
      final arcCubic = Cubic.circularArc(zero.x, zero.y, p0.x, p0.y, p3.x, p3.y);
      expect(p0, Point(arcCubic.anchor0X, arcCubic.anchor0Y));
      expect(p3, Point(arcCubic.anchor1X, arcCubic.anchor1Y));
    });

    test('div', () {
      Cubic divCubic = cubic / 1;
      expectCubicsEqualish(cubic, divCubic);
      divCubic = cubic / 1;
      expectCubicsEqualish(cubic, divCubic);
      divCubic = cubic / 2;
      expectPointsEqualish(p0 / 2, Point(divCubic.anchor0X, divCubic.anchor0Y));
      expectPointsEqualish(p1 / 2, Point(divCubic.control0X, divCubic.control0Y));
      expectPointsEqualish(p2 / 2, Point(divCubic.control1X, divCubic.control1Y));
      expectPointsEqualish(p3 / 2, Point(divCubic.anchor1X, divCubic.anchor1Y));
      divCubic = cubic / 2;
      expectPointsEqualish(p0 / 2, Point(divCubic.anchor0X, divCubic.anchor0Y));
      expectPointsEqualish(p1 / 2, Point(divCubic.control0X, divCubic.control0Y));
      expectPointsEqualish(p2 / 2, Point(divCubic.control1X, divCubic.control1Y));
      expectPointsEqualish(p3 / 2, Point(divCubic.anchor1X, divCubic.anchor1Y));
    });

    test('times', () {
      Cubic timesCubic = cubic * 1;
      expect(p0, Point(timesCubic.anchor0X, timesCubic.anchor0Y));
      expect(p1, Point(timesCubic.control0X, timesCubic.control0Y));
      expect(p2, Point(timesCubic.control1X, timesCubic.control1Y));
      expect(p3, Point(timesCubic.anchor1X, timesCubic.anchor1Y));
      timesCubic = cubic * 1;
      expect(p0, Point(timesCubic.anchor0X, timesCubic.anchor0Y));
      expect(p1, Point(timesCubic.control0X, timesCubic.control0Y));
      expect(p2, Point(timesCubic.control1X, timesCubic.control1Y));
      expect(p3, Point(timesCubic.anchor1X, timesCubic.anchor1Y));
      timesCubic = cubic * 2;
      expectPointsEqualish(p0 * 2, Point(timesCubic.anchor0X, timesCubic.anchor0Y));
      expectPointsEqualish(p1 * 2, Point(timesCubic.control0X, timesCubic.control0Y));
      expectPointsEqualish(p2 * 2, Point(timesCubic.control1X, timesCubic.control1Y));
      expectPointsEqualish(p3 * 2, Point(timesCubic.anchor1X, timesCubic.anchor1Y));
      timesCubic = cubic * 2;
      expectPointsEqualish(p0 * 2, Point(timesCubic.anchor0X, timesCubic.anchor0Y));
      expectPointsEqualish(p1 * 2, Point(timesCubic.control0X, timesCubic.control0Y));
      expectPointsEqualish(p2 * 2, Point(timesCubic.control1X, timesCubic.control1Y));
      expectPointsEqualish(p3 * 2, Point(timesCubic.anchor1X, timesCubic.anchor1Y));
    });

    test('plus', () {
      final Cubic offsetCubic = cubic * 2;
      final Cubic plusCubic = cubic + offsetCubic;
      expectPointsEqualish(
        p0 + Point(offsetCubic.anchor0X, offsetCubic.anchor0Y),
        Point(plusCubic.anchor0X, plusCubic.anchor0Y),
      );
      expectPointsEqualish(
        p1 + Point(offsetCubic.control0X, offsetCubic.control0Y),
        Point(plusCubic.control0X, plusCubic.control0Y),
      );
      expectPointsEqualish(
        p2 + Point(offsetCubic.control1X, offsetCubic.control1Y),
        Point(plusCubic.control1X, plusCubic.control1Y),
      );
      expectPointsEqualish(
        p3 + Point(offsetCubic.anchor1X, offsetCubic.anchor1Y),
        Point(plusCubic.anchor1X, plusCubic.anchor1Y),
      );
    });

    test('reverse', () {
      final Cubic reverseCubic = cubic.reverse();
      expect(p3, Point(reverseCubic.anchor0X, reverseCubic.anchor0Y));
      expect(p2, Point(reverseCubic.control0X, reverseCubic.control0Y));
      expect(p1, Point(reverseCubic.control1X, reverseCubic.control1Y));
      expect(p0, Point(reverseCubic.anchor1X, reverseCubic.anchor1Y));
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
      final lineCubic = Cubic.straightLine(p0.x, p0.y, p3.x, p3.y);
      expect(p0, Point(lineCubic.anchor0X, lineCubic.anchor0Y));
      expect(p3, Point(lineCubic.anchor1X, lineCubic.anchor1Y));
      expectBetween(p0, p3, Point(lineCubic.control0X, lineCubic.control0Y));
      expectBetween(p0, p3, Point(lineCubic.control1X, lineCubic.control1Y));
    });

    test('split', () {
      final (Cubic split0, Cubic split1) = cubic.split(0.5);
      expect(Point(cubic.anchor0X, cubic.anchor0Y), Point(split0.anchor0X, split0.anchor0Y));
      expect(Point(cubic.anchor1X, cubic.anchor1Y), Point(split1.anchor1X, split1.anchor1Y));
      expectBetween(
        Point(cubic.anchor0X, cubic.anchor0Y),
        Point(cubic.anchor1X, cubic.anchor1Y),
        Point(split0.anchor1X, split0.anchor1Y),
      );
      expectBetween(
        Point(cubic.anchor0X, cubic.anchor0Y),
        Point(cubic.anchor1X, cubic.anchor1Y),
        Point(split1.anchor0X, split1.anchor0Y),
      );
    });

    test('pointOnCurve', () {
      Point halfway = cubic.pointOnCurve(0.5);
      expectBetween(
        Point(cubic.anchor0X, cubic.anchor0Y),
        Point(cubic.anchor1X, cubic.anchor1Y),
        halfway,
      );
      final straightLineCubic = Cubic.straightLine(p0.x, p0.y, p3.x, p3.y);
      halfway = straightLineCubic.pointOnCurve(0.5);
      final computedHalfway = Point(p0.x + 0.5 * (p3.x - p0.x), p0.y + 0.5 * (p3.y - p0.y));
      expectPointsEqualish(computedHalfway, halfway);
    });

    test('transform', () {
      PointTransformer transform = identityTransform();
      Cubic transformedCubic = cubic.transformed(transform);
      expectCubicsEqualish(cubic, transformedCubic);

      transform = scaleTransform(3, 3);
      transformedCubic = cubic.transformed(transform);
      expectCubicsEqualish(cubic * 3, transformedCubic);

      const tx = 200.0;
      const ty = 300.0;
      const translationVector = Point(tx, ty);
      transform = translateTransform(tx, ty);
      transformedCubic = cubic.transformed(transform);
      expectPointsEqualish(
        Point(cubic.anchor0X, cubic.anchor0Y) + translationVector,
        Point(transformedCubic.anchor0X, transformedCubic.anchor0Y),
      );
      expectPointsEqualish(
        Point(cubic.control0X, cubic.control0Y) + translationVector,
        Point(transformedCubic.control0X, transformedCubic.control0Y),
      );
      expectPointsEqualish(
        Point(cubic.control1X, cubic.control1Y) + translationVector,
        Point(transformedCubic.control1X, transformedCubic.control1Y),
      );
      expectPointsEqualish(
        Point(cubic.anchor1X, cubic.anchor1Y) + translationVector,
        Point(transformedCubic.anchor1X, transformedCubic.anchor1Y),
      );
    });

    test('empty Cubic has zero length', () {
      expect(Cubic.empty(10, 10).zeroLength(), isTrue);
    });
  });
}
