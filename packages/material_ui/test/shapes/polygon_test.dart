// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/src/shapes/corner_rounding.dart';
import 'package:material_ui/src/shapes/cubic.dart';
import 'package:material_ui/src/shapes/features.dart';
import 'package:material_ui/src/shapes/point.dart';
import 'package:material_ui/src/shapes/rounded_polygon.dart';

import 'test_utils.dart';

void main() {
  group('Polygon', () {
    final square = RoundedPolygon(4);
    final roundedSquare = RoundedPolygon(4, rounding: const CornerRounding(radius: 0.2));
    final pentagon = RoundedPolygon(5);

    test('construction', () {
      // We can't be too specific on how exactly the square is constructed, but
      // we can at least test whether all points are within the unit square.
      var min = const Point(-1, -1);
      var max = const Point(1, 1);
      expectInBounds(square.cubics, min, max);

      final doubleSquare = RoundedPolygon(4, radius: 2);
      min = min * 2;
      max = max * 2;
      expectInBounds(doubleSquare.cubics, min, max);

      final offsetSquare = RoundedPolygon(4, center: const Point(1, 2));
      min = const Point(0, 1);
      max = const Point(2, 3);
      expectInBounds(offsetSquare.cubics, min, max);

      const p0 = Point(1, 0);
      const p1 = Point(0, 1);
      const p2 = Point(-1, 0);
      const p3 = Point(0, -1);
      final manualSquare = RoundedPolygon.fromVertices(const [p0, p1, p2, p3]);
      min = const Point(-1, -1);
      max = const Point(1, 1);
      expectInBounds(manualSquare.cubics, min, max);

      const offset = Point(1, 2);
      final Point p0Offset = p0 + offset;
      final Point p1Offset = p1 + offset;
      final Point p2Offset = p2 + offset;
      final Point p3Offset = p3 + offset;
      final manualSquareOffset = RoundedPolygon.fromVertices([
        p0Offset,
        p1Offset,
        p2Offset,
        p3Offset,
      ], center: offset);
      min = const Point(0, 1);
      max = const Point(2, 3);
      expectInBounds(manualSquareOffset.cubics, min, max);
    });

    test('bounds', () {
      Rect bounds = square.approximateBounds;
      expectEqualish(-1, bounds.left);
      expectEqualish(-1, bounds.top);
      expectEqualish(1, bounds.right);
      expectEqualish(1, bounds.bottom);

      Rect betterBounds = square.bounds;
      expectEqualish(-1, betterBounds.left);
      expectEqualish(-1, betterBounds.top);
      expectEqualish(1, betterBounds.right);
      expectEqualish(1, betterBounds.bottom);

      // roundedSquare's approximate bounds will be larger due to control
      // points.
      bounds = roundedSquare.approximateBounds;
      betterBounds = roundedSquare.bounds;
      expect(
        betterBounds.width < bounds.width,
        isTrue,
        reason: 'bounds = $bounds, betterBounds = $betterBounds',
      );

      bounds = pentagon.approximateBounds;
      final Rect maxBounds = pentagon.maxBounds;
      expect(maxBounds.width > bounds.width, isTrue);
    });

    test('center', () {
      expectPointsEqualish(Point.zero, square.center);
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
      final List<CubicBezier> squareCubics = square.cubics;
      final PointTransformer translator = translateTransform(offset.x, offset.y);
      final List<CubicBezier> translatedSquareCubics = square.transformed(translator).cubics;

      for (var i = 0; i < squareCubics.length; i++) {
        expectPointsEqualish(squareCubics[i].anchor0 + offset, translatedSquareCubics[i].anchor0);
        expectPointsEqualish(squareCubics[i].control0 + offset, translatedSquareCubics[i].control0);
        expectPointsEqualish(squareCubics[i].control1 + offset, translatedSquareCubics[i].control1);
        expectPointsEqualish(squareCubics[i].anchor1 + offset, translatedSquareCubics[i].anchor1);
      }
    });

    test('features', () {
      List<CubicBezier> nonZeroCubics(List<CubicBezier> original) {
        return original.where((c) => !c.isZeroLength).toList();
      }

      final List<Feature> squareFeatures = square.features;

      // Verify that cubics of polygon == nonzero cubics of features of that
      // polygon.
      // Note the Equalish test since some points may be adjusted in conversion
      // from raw cubics in the feature to the cubics list for the shape.
      final List<CubicBezier> nonzeroCubics = nonZeroCubics(
        squareFeatures.expand((f) => f.cubics).toList(),
      );
      expectCubicListsEqualish(square.cubics, nonzeroCubics);
    });

    test('cubics and features are unmodifiable', () {
      final polygon = RoundedPolygon(4);
      final edge = Feature.edge(CubicBezier.straightLine(Point.zero, const Point(1, 0)));

      expect(() => polygon.cubics.clear(), throwsUnsupportedError);
      expect(() => polygon.cubics.add(edge.cubics.first), throwsUnsupportedError);
      expect(() => polygon.features.clear(), throwsUnsupportedError);
      expect(() => polygon.features.add(edge), throwsUnsupportedError);
    });

    test('fromFeatures does not alias the list it is given', () {
      final List<Feature> expected = RoundedPolygon(4).features;
      final features = List<Feature>.of(expected);
      final polygon = RoundedPolygon.fromFeatures(features);
      final int cubicCount = polygon.cubics.length;

      features.clear();

      expect(polygon.features, expected);
      expect(polygon.cubics.length, cubicCount);
    });

    test('toString names the type and its parts', () {
      final description = square.toString();

      expect(description, startsWith('RoundedPolygon(center: Offset(0.0, 0.0), features: ['));
      expect(description, contains('EdgeFeature(cubics: ['));
      expect(description, contains('CornerFeature(cubics: ['));
      expect(description, contains(', cubics: [CubicBezier(anchor0: '));
      expect(description, endsWith(')])'));
    });

    test('transform keeps contiguous anchors equal', () {
      final RoundedPolygon poly = RoundedPolygon(4, rounding: const CornerRounding(radius: 7 / 15))
          .transformed((x, y) {
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
      final poly = RoundedPolygon(6, radius: 0, rounding: const CornerRounding(radius: 0.1));
      expect(poly.cubics.length, 1);

      final RoundedPolygon stillEmpty = poly.transformed(scaleTransform(10, 20));
      expect(stillEmpty.cubics.length, 1);
      expect(stillEmpty.cubics.first.isZeroLength, isTrue);
    });

    test('empty side', () {
      // Triangle with one point repeated.
      final poly1 = RoundedPolygon.fromVertices(const [
        Point.zero,
        Point(1, 0),
        Point(1, 0),
        Point(0, 1),
      ]);
      // Triangle.
      final poly2 = RoundedPolygon.fromVertices(const [Point.zero, Point(1, 0), Point(0, 1)]);
      expectCubicListsEqualish(poly1.cubics, poly2.cubics);
    });
  });
}
