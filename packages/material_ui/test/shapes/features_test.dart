// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/src/shapes/shapes.dart';

import 'test_utils.dart';

void main() {
  group('$Feature', () {
    test('Cannot build empty features', () {
      expect(() => Feature.buildConvexCorner([]), throwsArgumentError);
      expect(() => Feature.buildConcaveCorner([]), throwsArgumentError);
      expect(() => Feature.buildIgnorableFeature([]), throwsArgumentError);
    });

    test('Cannot build non continuous features', () {
      final cubic1 = Cubic.straightLine(0, 0, 1, 1);
      final cubic2 = Cubic.straightLine(10, 10, 11, 11);

      expect(() => Feature.buildConvexCorner([cubic1, cubic2]), throwsArgumentError);
      expect(() => Feature.buildConcaveCorner([cubic1, cubic2]), throwsArgumentError);
      expect(() => Feature.buildIgnorableFeature([cubic1, cubic2]), throwsArgumentError);
    });

    test('Builds concave corner', () {
      final cubic = Cubic.straightLine(0, 0, 1, 0);
      final actual = Feature.buildConcaveCorner([cubic]);
      final expected = CornerFeature([cubic], convex: false);
      expectFeaturesEqualish(expected, actual);
    });

    test('Builds convex corner', () {
      final cubic = Cubic.straightLine(0, 0, 1, 0);
      final actual = Feature.buildConvexCorner([cubic]);
      final expected = CornerFeature([cubic], convex: true);
      expectFeaturesEqualish(expected, actual);
    });

    test('Builds edge', () {
      final cubic = Cubic.straightLine(0, 0, 1, 0);
      final actual = Feature.buildEdge(cubic);
      final expected = EdgeFeature([cubic]);
      expectFeaturesEqualish(expected, actual);
    });

    test('Builds ignorable as edge', () {
      final cubic = Cubic.straightLine(0, 0, 1, 0);
      final actual = Feature.buildIgnorableFeature([cubic]);
      final expected = EdgeFeature([cubic]);
      expectFeaturesEqualish(expected, actual);
    });
  });
}
