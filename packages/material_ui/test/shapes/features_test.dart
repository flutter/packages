// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/src/shapes/cubic.dart';
import 'package:material_ui/src/shapes/features.dart';

import 'test_utils.dart';

void main() {
  group('$Feature', () {
    test('Cannot build empty features', () {
      expect(() => Feature.buildConvexCorner([]), throwsArgumentError);
      expect(() => Feature.buildConcaveCorner([]), throwsArgumentError);
      expect(() => Feature.buildIgnorableFeature([]), throwsArgumentError);
    });

    test('Cannot build non continuous features', () {
      final cubic1 = CubicBezier.straightLine(Offset.zero, const Offset(1, 1));
      final cubic2 = CubicBezier.straightLine(const Offset(10, 10), const Offset(11, 11));

      expect(() => Feature.buildConvexCorner([cubic1, cubic2]), throwsArgumentError);
      expect(() => Feature.buildConcaveCorner([cubic1, cubic2]), throwsArgumentError);
      expect(() => Feature.buildIgnorableFeature([cubic1, cubic2]), throwsArgumentError);
    });

    test('Builds concave corner', () {
      final cubic = CubicBezier.straightLine(Offset.zero, const Offset(1, 0));
      final actual = Feature.buildConcaveCorner([cubic]);
      final expected = CornerFeature([cubic], convex: false);
      expectFeaturesEqualish(expected, actual);
    });

    test('Builds convex corner', () {
      final cubic = CubicBezier.straightLine(Offset.zero, const Offset(1, 0));
      final actual = Feature.buildConvexCorner([cubic]);
      final expected = CornerFeature([cubic]);
      expectFeaturesEqualish(expected, actual);
    });

    test('Builds edge', () {
      final cubic = CubicBezier.straightLine(Offset.zero, const Offset(1, 0));
      final actual = Feature.buildEdge(cubic);
      final expected = EdgeFeature([cubic]);
      expectFeaturesEqualish(expected, actual);
    });

    test('Builds ignorable as edge', () {
      final cubic = CubicBezier.straightLine(Offset.zero, const Offset(1, 0));
      final actual = Feature.buildIgnorableFeature([cubic]);
      final expected = EdgeFeature([cubic]);
      expectFeaturesEqualish(expected, actual);
    });
  });
}
