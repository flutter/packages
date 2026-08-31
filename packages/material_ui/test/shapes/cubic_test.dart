// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:math' as math;

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

    test('reverse', () {
      final CubicBezier reverseCubic = cubic.reverse();
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

    test('pointOnCurve', () {
      Point halfway = cubic.pointOnCurve(0.5);
      expectBetween(cubic.anchor0, cubic.anchor1, halfway);
      final straightLineCubic = CubicBezier.straightLine(p0, p3);
      halfway = straightLineCubic.pointOnCurve(0.5);
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

    test('empty CubicBezier has zero length', () {
      expect(CubicBezier.empty(const Point(10, 10)).zeroLength(), isTrue);
    });
  });
}
