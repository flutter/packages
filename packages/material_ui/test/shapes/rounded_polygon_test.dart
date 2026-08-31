// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/src/shapes/corner_rounding.dart';
import 'package:material_ui/src/shapes/cubic.dart';
import 'package:material_ui/src/shapes/features.dart';
import 'package:material_ui/src/shapes/point.dart';
import 'package:material_ui/src/shapes/rounded_polygon.dart';

import 'test_utils.dart';

void main() {
  group('$RoundedPolygon', () {
    const rounding = CornerRounding(radius: 0.1);
    final perVtxRounded = [rounding, rounding, rounding, rounding];

    test('fromVerticesNum', () {
      expect(() => RoundedPolygon.fromVerticesNum(2), throwsArgumentError);

      final square = RoundedPolygon.fromVerticesNum(4);
      var min = const Point(-1, -1);
      var max = const Point(1, 1);
      expectInBounds(square.cubics, min, max);

      final doubleSquare = RoundedPolygon.fromVerticesNum(4, radius: 2);
      min *= 2;
      max *= 2;
      expectInBounds(doubleSquare.cubics, min, max);

      final squareRounded = RoundedPolygon.fromVerticesNum(4, rounding: rounding);
      min = const Point(-1, -1);
      max = const Point(1, 1);
      expectInBounds(squareRounded.cubics, min, max);

      final squarePVRounded = RoundedPolygon.fromVerticesNum(4, perVertexRounding: perVtxRounded);
      min = const Point(-1, -1);
      max = const Point(1, 1);
      expectInBounds(squarePVRounded.cubics, min, max);
    });

    test('fromVertices', () {
      const p0 = Point(1, 0);
      const p1 = Point(0, 1);
      const p2 = Point(-1, 0);
      const p3 = Point(0, -1);
      const verts = [p0, p1, p2, p3];

      expect(() => RoundedPolygon.fromVertices(const [p0, p1]), throwsArgumentError);

      final manualSquare = RoundedPolygon.fromVertices(verts);
      var min = const Point(-1, -1);
      var max = const Point(1, 1);
      expectInBounds(manualSquare.cubics, min, max);

      const offset = Point(1, 2);
      final List<Point> offsetVerts = [p0 + offset, p1 + offset, p2 + offset, p3 + offset];
      final manualSquareOffset = RoundedPolygon.fromVertices(offsetVerts, center: offset);
      min = const Point(0, 1);
      max = const Point(2, 3);
      expectInBounds(manualSquareOffset.cubics, min, max);

      final manualSquareRounded = RoundedPolygon.fromVertices(verts, rounding: rounding);
      min = const Point(-1, -1);
      max = const Point(1, 1);
      expectInBounds(manualSquareRounded.cubics, min, max);

      final manualSquarePVRounded = RoundedPolygon.fromVertices(
        verts,
        perVertexRounding: perVtxRounded,
      );
      min = const Point(-1, -1);
      max = const Point(1, 1);
      expectInBounds(manualSquarePVRounded.cubics, min, max);
    });

    group('fromFeatures', () {
      test('throws for too few features', () {
        expect(() => RoundedPolygon.fromFeatures(const []), throwsArgumentError);
        expect(
          () => RoundedPolygon.fromFeatures([
            CornerFeature([CubicBezier.empty(Point.zero)]),
          ]),
          throwsArgumentError,
        );
      });

      test('throws for non continuous features', () {
        final cubic1 = CubicBezier.straightLine(Point.zero, const Point(1, 0));
        final cubic2 = CubicBezier.straightLine(const Point(10, 10), const Point(20, 20));
        expect(
          () => RoundedPolygon.fromFeatures([Feature.buildEdge(cubic1), Feature.buildEdge(cubic2)]),
          throwsArgumentError,
        );
      });

      test('reconstructs square', () {
        final base = RoundedPolygon.rectangle();
        final actual = RoundedPolygon.fromFeatures(base.features);
        expectPolygonsEqualish(base, actual);
      });

      test('reconstructs rounded square', () {
        final base = RoundedPolygon.rectangle(
          rounding: const CornerRounding(radius: 0.5, smoothing: 0.2),
        );
        final actual = RoundedPolygon.fromFeatures(base.features);
        expectPolygonsEqualish(base, actual);
      });

      test('reconstructs circles', () {
        for (var i = 3; i <= 20; i++) {
          final base = RoundedPolygon.circle(numVertices: i);
          final actual = RoundedPolygon.fromFeatures(base.features);
          expectPolygonsEqualish(base, actual);
        }
      });

      test('reconstructs stars', () {
        for (var i = 3; i <= 20; i++) {
          final base = RoundedPolygon.star(numVerticesPerRadius: i);
          final actual = RoundedPolygon.fromFeatures(base.features);
          expectPolygonsEqualish(base, actual);
        }
      });

      test('reconstructs rounded stars', () {
        for (var i = 3; i <= 20; i++) {
          final base = RoundedPolygon.star(
            numVerticesPerRadius: i,
            rounding: const CornerRounding(radius: 0.5, smoothing: 0.2),
          );
          final actual = RoundedPolygon.fromFeatures(base.features);
          expectPolygonsEqualish(base, actual);
        }
      });

      test('reconstructs pill', () {
        final base = RoundedPolygon.pill();
        final actual = RoundedPolygon.fromFeatures(base.features);
        expectPolygonsEqualish(base, actual);
      });

      test('reconstructs pill star', () {
        final base = RoundedPolygon.pillStar(
          rounding: const CornerRounding(radius: 0.5, smoothing: 0.2),
        );
        final actual = RoundedPolygon.fromFeatures(base.features);
        expectPolygonsEqualish(base, actual);
      });
    });

    test('computes center', () {
      final polygon = RoundedPolygon.fromVertices(const [
        Point.zero,
        Point(1, 0),
        Point(0, 1),
        Point(1, 1),
      ]);
      expect(const Point(0.5, 0.5), polygon.center);
    });

    test('toPath rotates around the polygon center', () {
      // A diamond filling the unit square, with its first vertex at angle zero
      // from its center.
      final diamond = RoundedPolygon.fromVertices(const [
        Point(1, 0.5),
        Point(0.5, 1),
        Point(0, 0.5),
        Point(0.5, 0),
      ]);
      expect(diamond.center, const Point(0.5, 0.5));

      final Path path = diamond.toPath(startAngle: math.pi / 2);

      // A quarter turn gives back the same diamond, so the bounds do not move.
      // Only the start point changes, landing on the next vertex. Rotating
      // about the origin would push the diamond out of the unit square.
      expectPointsEqualish(const Point(0.5, 0.5), path.getBounds().center);
      expectPointsEqualish(const Point(0.5, 1), pathStartPoint(path));
    });

    test('rounding space usage', () {
      const Point p0 = Point.zero;
      const p1 = Point(1, 0);
      const p2 = Point(0.5, 1);
      final List<CornerRounding> pvRounding = [
        const CornerRounding(radius: 1),
        const CornerRounding(radius: 1, smoothing: 1),
        CornerRounding.unrounded,
      ];
      final polygon = RoundedPolygon.fromVertices(const [
        p0,
        p1,
        p2,
      ], perVertexRounding: pvRounding);

      // Since there is not enough room in the p0 -> p1 side even for the
      // roundings, we shouldn't take smoothing into account, so the corners
      // should end in the middle point.
      final Feature lowerEdgeFeature = polygon.features.firstWhere((f) => f is EdgeFeature);
      expect(1, lowerEdgeFeature.cubics.length);

      final CubicBezier lowerEdge = lowerEdgeFeature.cubics.first;
      expectEqualish(0.5, lowerEdge.anchor0X);
      expectEqualish(0, lowerEdge.anchor0Y);
      expectEqualish(0.5, lowerEdge.anchor1X);
      expectEqualish(0, lowerEdge.anchor1Y);
    });

    // In the following tests, we check how much was cut for the top left
    // (vertex 0) and bottom left corner (vertex 3).
    // In particular, both vertex are competing for space in the left side.
    //
    //   Vertex 0            Vertex 1
    //      *---------------------*
    //      |                     |
    //      *---------------------*
    //   Vertex 3            Vertex 2
    const points = 20;

    String describe(CornerRounding cr) => '(r=${cr.radius}, s=${cr.smoothing})';

    void doUnevenSmoothTest({
      // Corner rounding parameter for vertex 0 (top left).
      required CornerRounding rounding0,
      // Expected total cut from vertex 0 towards vertex 1.
      required double expectedV0SX,
      // Expected total cut from vertex 0 towards vertex 3.
      required double expectedV0SY,
      // Expected total cut from vertex 3 towards vertex 0.
      required double expectedV3SY,
      // Corner rounding parameter for vertex 3 (bottom left).
      CornerRounding rounding3 = const CornerRounding(radius: 0.5),
    }) {
      const Point p0 = Point.zero;
      const p1 = Point(5, 0);
      const p2 = Point(5, 1);
      const p3 = Point(0, 1);

      final List<CornerRounding> pvRounding = [
        rounding0,
        CornerRounding.unrounded,
        CornerRounding.unrounded,
        rounding3,
      ];
      final polygon = RoundedPolygon.fromVertices(const [
        p0,
        p1,
        p2,
        p3,
      ], perVertexRounding: pvRounding);

      final [EdgeFeature e01, _, _, EdgeFeature e30] = polygon.features
          .whereType<EdgeFeature>()
          .toList();
      final msg = 'r0 = ${describe(rounding0)}, r3 = ${describe(rounding3)}';
      expectEqualish(expectedV0SX, e01.cubics.first.anchor0X, msg);
      expectEqualish(expectedV0SY, e30.cubics.first.anchor1Y, msg);
      expectEqualish(expectedV3SY, 1 - e30.cubics.first.anchor0Y, msg);
    }

    test('uneven smoothing 1', () {
      // Vertex 3 has the default 0.5 radius, 0 smoothing.
      // Vertex 0 has 0.4 radius, and smoothing varying from 0 to 1.
      for (var i = 0; i <= points; i++) {
        final double smooth = i / points;
        doUnevenSmoothTest(
          rounding0: CornerRounding(radius: 0.4, smoothing: smooth),
          expectedV0SX: 0.4 * (1 + smooth),
          expectedV0SY: math.min(0.4 * (1 + smooth), 0.5),
          expectedV3SY: 0.5,
        );
      }
    });

    test('uneven smoothing 2', () {
      // Vertex 3 has 0.2f radius and 0.2f smoothing, so it takes at most 0.4.
      // Vertex 0 has 0.4f radius and smoothing varies from 0 to 1, when it
      // reaches 0.5 it starts competing with vertex 3 for space.
      for (var i = 0; i <= points; i++) {
        final double smooth = i / points;

        final double smoothWantedV0 = 0.4 * smooth;
        const smoothWantedV3 = 0.2;

        // There is 0.4 room for smoothing.
        final double factor = math.min(0.4 / (smoothWantedV0 + smoothWantedV3), 1.0);
        doUnevenSmoothTest(
          rounding0: CornerRounding(radius: 0.4, smoothing: smooth),
          expectedV0SX: 0.4 * (1 + smooth),
          expectedV0SY: 0.4 + factor * smoothWantedV0,
          expectedV3SY: 0.2 + factor * smoothWantedV3,
          rounding3: const CornerRounding(radius: 0.2, smoothing: 1),
        );
      }
    });

    test('uneven smoothing 3', () {
      // Vertex 3 has 0.6 radius.
      // Vertex 0 has 0.4 radius and smoothing varies from 0 to 1. There is no
      // room for smoothing on the segment between these vertices, but vertex
      // 0 can still have smoothing on the top side.
      for (var i = 0; i <= points; i++) {
        final double smooth = i / points;

        doUnevenSmoothTest(
          rounding0: CornerRounding(radius: 0.4, smoothing: smooth),
          expectedV0SX: 0.4 * (1 + smooth),
          expectedV0SY: 0.4,
          expectedV3SY: 0.6,
          rounding3: const CornerRounding(radius: 0.6),
        );
      }
    });

    test('full size creation', () {
      const radius = 400.0;
      const innerRadiusFactor = 0.35;
      const double innerRadius = radius * innerRadiusFactor;
      const roundingFactor = 0.32;

      final RoundedPolygon fullSizeShape = RoundedPolygon.star(
        numVerticesPerRadius: 4,
        radius: radius,
        innerRadius: innerRadius,
        rounding: const CornerRounding(radius: radius * roundingFactor),
        innerRounding: const CornerRounding(radius: radius * roundingFactor),
        center: const Point(radius, radius),
      ).transformed((x, y) => ((x - radius) / radius, (y - radius) / radius));

      final canonicalShape = RoundedPolygon.star(
        numVerticesPerRadius: 4,
        innerRadius: innerRadiusFactor,
        rounding: const CornerRounding(radius: roundingFactor),
        innerRounding: const CornerRounding(radius: roundingFactor),
      );

      final List<CubicBezier> cubics = canonicalShape.cubics;
      final List<CubicBezier> cubics1 = fullSizeShape.cubics;
      expect(cubics.length, cubics1.length);

      for (var i = 0; i < cubics.length; i++) {
        final CubicBezier cubic = cubics[i];
        final CubicBezier cubic1 = cubics1[i];

        expectEqualish(cubic.anchor0X, cubic1.anchor0X);
        expectEqualish(cubic.anchor0Y, cubic1.anchor0Y);
        expectEqualish(cubic.anchor1X, cubic1.anchor1X);
        expectEqualish(cubic.anchor1Y, cubic1.anchor1Y);
        expectEqualish(cubic.control0X, cubic1.control0X);
        expectEqualish(cubic.control0Y, cubic1.control0Y);
        expectEqualish(cubic.control1X, cubic1.control1X);
        expectEqualish(cubic.control1Y, cubic1.control1Y);
      }
    });
  });
}
