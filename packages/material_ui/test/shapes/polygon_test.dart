// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/src/shapes/shapes/shapes.dart';

import 'test_utils.dart';

void main() {
  group('Polygon', () {
    final square = RoundedPolygon.fromVerticesNum(4);
    final roundedSquare = RoundedPolygon.fromVerticesNum(
      4,
      rounding: const CornerRounding(radius: 0.2),
    );
    final pentagon = RoundedPolygon.fromVerticesNum(5);

    test('construction', () {
      // We can't be too specific on how exactly the square is constructed, but
      // we can at least test whether all points are within the unit square.
      var min = const Point(-1, -1);
      var max = const Point(1, 1);
      expectInBounds(square.cubics, min, max);

      final doubleSquare = RoundedPolygon.fromVerticesNum(4, radius: 2);
      min = min * 2;
      max = max * 2;
      expectInBounds(doubleSquare.cubics, min, max);

      final offsetSquare = RoundedPolygon.fromVerticesNum(4, centerX: 1, centerY: 2);
      min = const Point(0, 1);
      max = const Point(2, 3);
      expectInBounds(offsetSquare.cubics, min, max);

      final squareCopy = RoundedPolygon.from(square);
      min = const Point(-1, -1);
      max = const Point(1, 1);
      expectInBounds(squareCopy.cubics, min, max);

      const p0 = Point(1, 0);
      const p1 = Point(0, 1);
      const p2 = Point(-1, 0);
      const p3 = Point(0, -1);
      final manualSquare = RoundedPolygon.fromVertices([
        p0.x,
        p0.y,
        p1.x,
        p1.y,
        p2.x,
        p2.y,
        p3.x,
        p3.y,
      ]);
      min = const Point(-1, -1);
      max = const Point(1, 1);
      expectInBounds(manualSquare.cubics, min, max);

      const offset = Point(1, 2);
      final Point p0Offset = p0 + offset;
      final Point p1Offset = p1 + offset;
      final Point p2Offset = p2 + offset;
      final Point p3Offset = p3 + offset;
      final manualSquareOffset = RoundedPolygon.fromVertices(
        [
          p0Offset.x,
          p0Offset.y,
          p1Offset.x,
          p1Offset.y,
          p2Offset.x,
          p2Offset.y,
          p3Offset.x,
          p3Offset.y,
        ],
        centerX: offset.x,
        centerY: offset.y,
      );
      min = const Point(0, 1);
      max = const Point(2, 3);
      expectInBounds(manualSquareOffset.cubics, min, max);
    });

    test('bounds', () {
      List<double> bounds = square.calculateBounds();
      expectEqualish(-1, bounds[0]); // Left
      expectEqualish(-1, bounds[1]); // Top
      expectEqualish(1, bounds[2]); // Right
      expectEqualish(1, bounds[3]); // Bottom

      List<double> betterBounds = square.calculateBounds(approximate: false);
      expectEqualish(-1, betterBounds[0]); // Left
      expectEqualish(-1, betterBounds[1]); // Top
      expectEqualish(1, betterBounds[2]); // Right
      expectEqualish(1, betterBounds[3]); // Bottom

      // roundedSquare's approximate bounds will be larger due to control
      // points.
      bounds = roundedSquare.calculateBounds();
      betterBounds = roundedSquare.calculateBounds(approximate: false);
      expect(
        betterBounds[2] - betterBounds[0] < bounds[2] - bounds[0],
        isTrue,
        reason:
            'bounds ${bounds[0]}, ${bounds[1]}, ${bounds[2]}, ${bounds[3]}, '
            'betterBounds = ${betterBounds[0]}, ${betterBounds[1]}, '
            '${betterBounds[2]}, ${betterBounds[3]}',
      );

      bounds = pentagon.calculateBounds();
      final List<double> maxBounds = pentagon.calculateMaxBounds();
      expect(maxBounds[2] - maxBounds[0] > bounds[2] - bounds[0], isTrue);
    });

    test('center', () {
      expectPointsEqualish(Point.zero, Point(square.centerX, square.centerY));
    });

    test('transform', () {
      // First, make sure the shape doesn't change when transformed by the
      // identity.
      final RoundedPolygon squareCopy = square.transformed(identityTransform());
      final int n = square.cubics.length;

      expect(n, squareCopy.cubics.length);
      for (var i = 0; i < n; i++) {
        expectCubicsEqualish(square.cubics[i], squareCopy.cubics[i]);
      }

      // Now create a function which translates points by (1, 2) and make sure
      // the shape is translated similarly by it.
      const offset = Point(1, 2);
      final List<Cubic> squareCubics = square.cubics;
      final PointTransformer translator = translateTransform(offset.x, offset.y);
      final List<Cubic> translatedSquareCubics = square.transformed(translator).cubics;

      for (var i = 0; i < squareCubics.length; i++) {
        expectPointsEqualish(
          Point(squareCubics[i].anchor0X, squareCubics[i].anchor0Y) + offset,
          Point(translatedSquareCubics[i].anchor0X, translatedSquareCubics[i].anchor0Y),
        );
        expectPointsEqualish(
          Point(squareCubics[i].control0X, squareCubics[i].control0Y) + offset,
          Point(translatedSquareCubics[i].control0X, translatedSquareCubics[i].control0Y),
        );
        expectPointsEqualish(
          Point(squareCubics[i].control1X, squareCubics[i].control1Y) + offset,
          Point(translatedSquareCubics[i].control1X, translatedSquareCubics[i].control1Y),
        );
        expectPointsEqualish(
          Point(squareCubics[i].anchor1X, squareCubics[i].anchor1Y) + offset,
          Point(translatedSquareCubics[i].anchor1X, translatedSquareCubics[i].anchor1Y),
        );
      }
    });

    test('features', () {
      List<Cubic> nonZeroCubics(List<Cubic> original) {
        return original.where((c) => !c.zeroLength()).toList();
      }

      final List<Feature> squareFeatures = square.features;

      // Verify that cubics of polygon == nonzero cubics of features of that
      // polygon.
      // Note the Equalish test since some points may be adjusted in conversion
      // from raw cubics in the feature to the cubics list for the shape.
      List<Cubic> nonzeroCubics = nonZeroCubics(squareFeatures.expand((f) => f.cubics).toList());
      expectCubicListsEqualish(square.cubics, nonzeroCubics);

      // Same as the first polygon test, but with a copy of that polygon.
      final squareCopy = RoundedPolygon.from(square);
      final List<Feature> squareCopyFeatures = squareCopy.features;
      nonzeroCubics = nonZeroCubics(squareCopyFeatures.expand((f) => f.cubics).toList());
      expectCubicListsEqualish(squareCopy.cubics, nonzeroCubics);
    });

    test('transform keeps contiguous anchors equal', () {
      final RoundedPolygon poly =
          RoundedPolygon.fromVerticesNum(
            4,
            radius: 1,
            rounding: const CornerRounding(radius: 7 / 15),
          ).transformed((x, y) {
            final Point point = Point(x, y).rotate(45).scale(648, 648).translate(540, 1212);
            return (point.x, point.y);
          });

      for (var i = 0; i < poly.cubics.length; i++) {
        // It has to be the same point.
        expect(
          poly.cubics[i].anchor1X,
          poly.cubics[(i + 1) % poly.cubics.length].anchor0X,
          reason: 'Failed at X, index $i',
        );
        expect(
          poly.cubics[i].anchor1Y,
          poly.cubics[(i + 1) % poly.cubics.length].anchor0Y,
          reason: 'Failed at Y, index $i',
        );
      }
    });

    test('empty', () {
      final poly = RoundedPolygon.fromVerticesNum(
        6,
        radius: 0,
        rounding: const CornerRounding(radius: 0.1),
      );
      expect(poly.cubics.length, 1);

      final RoundedPolygon stillEmpty = poly.transformed(scaleTransform(10, 20));
      expect(stillEmpty.cubics.length, 1);
      expect(stillEmpty.cubics.first.zeroLength(), isTrue);
    });

    test('empty side', () {
      // Triangle with one point repeated.
      final poly1 = RoundedPolygon.fromVertices(const [0, 0, 1, 0, 1, 0, 0, 1]);
      // Triangle.
      final poly2 = RoundedPolygon.fromVertices(const [0, 0, 1, 0, 0, 1]);
      expectCubicListsEqualish(poly1.cubics, poly2.cubics);
    });
  });
}
