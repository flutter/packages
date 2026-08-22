// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/src/shapes/shapes.dart';

import 'test_utils.dart';

void main() {
  group('FeatureMapping', () {
    final triangleWithRoundings = RoundedPolygon.fromVerticesNum(
      3,
      rounding: const CornerRounding(radius: 0.2),
    );
    final triangle = RoundedPolygon.fromVerticesNum(3);
    final square = RoundedPolygon.fromVerticesNum(4);
    final RoundedPolygon squareRotated = RoundedPolygon.fromVerticesNum(
      4,
    ).transformed(pointRotator(45));

    void verifyMapping(
      RoundedPolygon p1,
      RoundedPolygon p2,
      void Function(List<double>) validator,
    ) {
      final List<ProgressableFeature> f1 = MeasuredPolygon.measurePolygon(
        const LengthMeasurer(),
        p1,
      ).features;
      final List<ProgressableFeature> f2 = MeasuredPolygon.measurePolygon(
        const LengthMeasurer(),
        p2,
      ).features;

      // Maps progress in p1 to progress in p2.
      final List<(double, double)> map = doMapping(f1, f2);

      // See which features where actually mapped and the distance between
      // their representative points.
      final distances = <double>[];

      for (final (progress1, progress2) in map) {
        final ProgressableFeature feature1 = f1.firstWhere((f) => f.progress == progress1);
        final ProgressableFeature feature2 = f2.firstWhere((f) => f.progress == progress2);
        distances.add(featureDistSquared(feature1.feature, feature2.feature));
      }

      distances.sort((a, b) => b.compareTo(a));
      validator(distances);
    }

    test('feature mapping triangles', () {
      verifyMapping(triangleWithRoundings, triangle, (distances) {
        for (final d in distances) {
          expect(d, lessThan(0.1));
        }
      });
    });

    test('feature mapping triangle to square', () {
      verifyMapping(triangle, square, (distances) {
        // We have one exact match (both have points at 0 degrees), and
        // 2 close ones.
        expect(distances.length, 3);
        expectEqualish(distances[0], distances[1]);
        expect(distances[0], lessThan(0.3));
        expect(distances[2], lessThan(1e-6));
      });
    });

    test('feature mapping square to triangle', () {
      verifyMapping(square, triangle, (distances) {
        // We have one exact match (both have points at 0 degrees), and
        // 2 close ones.
        expect(distances.length, 3);
        expectEqualish(distances[0], distances[1]);
        expect(distances[0], lessThan(0.3));
        expect(distances[2], lessThan(1e-6));
      });
    });

    test('feature mapping square rotated to triangle', () {
      verifyMapping(squareRotated, triangle, (distances) {
        // We have a very bad mapping (the triangle vertex just in the middle
        // of one of the square's sides) and 2 decent ones.
        expect(distances.length, 3);
        expect(distances[0], greaterThan(0.5));
        expectEqualish(distances[1], distances[2]);
        expect(distances[2], lessThan(0.1));
      });
    });

    test('feature mapping does not crash', () {
      // Verify that complicated shapes can me matched (this used to crash
      // before).
      final RoundedPolygon checkmark = RoundedPolygon.fromVertices(const [
        400,
        -304,
        240,
        -464,
        296,
        -520,
        400,
        -416,
        664,
        -680,
        720,
        -624,
        400,
        -304,
      ]).normalized();

      final RoundedPolygon verySunny = RoundedPolygon.star(
        numVerticesPerRadius: 8,
        innerRadius: 0.65,
        rounding: const CornerRounding(radius: 0.15),
      ).normalized();

      verifyMapping(checkmark, verySunny, (distances) {
        // Most vertices on the checkmark map to a feature in the second
        // shape.
        expect(distances.length, 6);
        // And they are close enough
        expect(distances[0], lessThan(0.15));
      });
    });
  });
}
