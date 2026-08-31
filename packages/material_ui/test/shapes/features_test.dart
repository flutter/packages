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
      expect(() => Feature.convexCorner(const []), throwsArgumentError);
      expect(() => Feature.concaveCorner(const []), throwsArgumentError);
      expect(() => Feature.ignorable(const []), throwsArgumentError);
    });

    test('Cannot build non continuous features', () {
      final cubic1 = CubicBezier.straightLine(Offset.zero, const Offset(1, 1));
      final cubic2 = CubicBezier.straightLine(const Offset(10, 10), const Offset(11, 11));

      expect(() => Feature.convexCorner([cubic1, cubic2]), throwsArgumentError);
      expect(() => Feature.concaveCorner([cubic1, cubic2]), throwsArgumentError);
      expect(() => Feature.ignorable([cubic1, cubic2]), throwsArgumentError);
    });

    test('Builds concave corner', () {
      final cubic = CubicBezier.straightLine(Offset.zero, const Offset(1, 0));
      final actual = Feature.concaveCorner([cubic]);
      final expected = CornerFeature([cubic], convex: false);
      expectFeaturesEqualish(expected, actual);
    });

    test('Builds convex corner', () {
      final cubic = CubicBezier.straightLine(Offset.zero, const Offset(1, 0));
      final actual = Feature.convexCorner([cubic]);
      final expected = CornerFeature([cubic]);
      expectFeaturesEqualish(expected, actual);
    });

    test('Builds edge', () {
      final cubic = CubicBezier.straightLine(Offset.zero, const Offset(1, 0));
      final actual = Feature.edge(cubic);
      final expected = EdgeFeature([cubic]);
      expectFeaturesEqualish(expected, actual);
    });

    test('Builds ignorable as edge', () {
      final cubic = CubicBezier.straightLine(Offset.zero, const Offset(1, 0));
      final actual = Feature.ignorable([cubic]);
      final expected = EdgeFeature([cubic]);
      expectFeaturesEqualish(expected, actual);
    });

    test('== compares cubics by value', () {
      final cubic = CubicBezier(
        Offset.zero,
        const Offset(1, 0),
        const Offset(2, 0),
        const Offset(3, 0),
      );
      final equalCubic = CubicBezier(
        Offset.zero,
        const Offset(1, 0),
        const Offset(2, 0),
        const Offset(3, 0),
      );
      final otherCubic = CubicBezier(
        Offset.zero,
        const Offset(1, 0),
        const Offset(2, 0),
        const Offset(4, 0),
      );

      expect(EdgeFeature([cubic]), EdgeFeature([equalCubic]));
      expect(EdgeFeature([cubic]).hashCode, EdgeFeature([equalCubic]).hashCode);
      expect(EdgeFeature([cubic]), isNot(EdgeFeature([otherCubic])));
      expect(EdgeFeature([cubic]), isNot(EdgeFeature([cubic, otherCubic])));

      expect(CornerFeature([cubic]), CornerFeature([equalCubic]));
      expect(CornerFeature([cubic]).hashCode, CornerFeature([equalCubic]).hashCode);
      expect(CornerFeature([cubic]), isNot(CornerFeature([otherCubic])));
    });

    test('== distinguishes edges from corners', () {
      final cubic = CubicBezier.straightLine(Offset.zero, const Offset(1, 0));
      final edge = EdgeFeature([cubic]);
      final corner = CornerFeature([cubic]);

      // Asserted in both directions because only CornerFeature overrides `==`
      // to check for its own type, so the edge side is what pins the runtime
      // type check on the base class.
      expect(edge, isNot(corner));
      expect(corner, isNot(edge));
    });

    test('== distinguishes convex from concave corners', () {
      final cubic = CubicBezier.straightLine(Offset.zero, const Offset(1, 0));
      final convex = CornerFeature([cubic]);
      final concave = CornerFeature([cubic], convex: false);

      expect(convex, isNot(concave));
      expect(convex.hashCode, isNot(concave.hashCode));
    });

    test('== compares reversed and transformed features by value', () {
      final cubic = CubicBezier(
        Offset.zero,
        const Offset(1, 0),
        const Offset(2, 0),
        const Offset(3, 0),
      );
      final reversedCubic = CubicBezier(
        const Offset(3, 0),
        const Offset(2, 0),
        const Offset(1, 0),
        Offset.zero,
      );
      final translatedCubic = CubicBezier(
        const Offset(1, 2),
        const Offset(2, 2),
        const Offset(3, 2),
        const Offset(4, 2),
      );

      expect(EdgeFeature([cubic]).reversed, EdgeFeature([reversedCubic]));
      expect(
        EdgeFeature([cubic]).transformed(translateTransform(1, 2)),
        EdgeFeature([translatedCubic]),
      );

      expect(CornerFeature([cubic]).reversed, CornerFeature([reversedCubic], convex: false));
      expect(
        CornerFeature([cubic]).transformed(translateTransform(1, 2)),
        CornerFeature([translatedCubic]),
      );
    });
  });
}
