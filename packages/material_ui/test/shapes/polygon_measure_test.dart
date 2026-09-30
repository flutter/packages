// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/src/shapes/corner_rounding.dart';
import 'package:material_ui/src/shapes/cubic.dart';
import 'package:material_ui/src/shapes/feature_mapping.dart';
import 'package:material_ui/src/shapes/features.dart';
import 'package:material_ui/src/shapes/point.dart';
import 'package:material_ui/src/shapes/polygon_measure.dart';
import 'package:material_ui/src/shapes/rounded_polygon.dart';
import 'package:material_ui/src/shapes/utils.dart';

import 'test_utils.dart';

void main() {
  group('PolygonMeasure', () {
    const measurer = LengthMeasurer();

    void irregularPolygonMeasure(
      RoundedPolygon polygon, [
      void Function(MeasuredPolygon)? extraChecks,
    ]) {
      final measuredPolygon = MeasuredPolygon.measure(measurer, polygon);

      expect(0, measuredPolygon.first.startOutlineProgress);
      expect(1, measuredPolygon.last.endOutlineProgress);

      for (var index = 0; index < measuredPolygon.length; index++) {
        final MeasuredCubic measuredCubic = measuredPolygon[index];

        if (index > 0) {
          expect(measuredPolygon[index - 1].endOutlineProgress, measuredCubic.startOutlineProgress);
        }

        expect(measuredCubic.endOutlineProgress >= measuredCubic.startOutlineProgress, isTrue);
      }

      for (var index = 0; index < measuredPolygon.features.length; index++) {
        final ProgressableFeature progressableFeature = measuredPolygon.features[index];
        expect(
          progressableFeature.progress >= 0 && progressableFeature.progress < 1,
          isTrue,
          reason:
              'Feature #$index has invalid progress: '
              '${progressableFeature.progress}',
        );
      }

      extraChecks?.call(measuredPolygon);
    }

    void regularPolygonMeasure(int sides, [CornerRounding rounding = CornerRounding.unrounded]) {
      irregularPolygonMeasure(RoundedPolygon(sides, rounding: rounding), (measuredPolygon) {
        expect(sides, measuredPolygon.length);

        for (var index = 0; index < measuredPolygon.length; index++) {
          final MeasuredCubic measuredCubic = measuredPolygon[index];
          expectEqualish(index / sides, measuredCubic.startOutlineProgress);
        }
      });
    }

    void customPolygonMeasure(RoundedPolygon polygon, List<double> progresses) {
      irregularPolygonMeasure(polygon, (measuredPolygon) {
        expect(measuredPolygon.length, progresses.length);

        for (var index = 0; index < measuredPolygon.length; index++) {
          final MeasuredCubic measuredCubic = measuredPolygon[index];
          expectEqualish(
            progresses[index],
            measuredCubic.endOutlineProgress - measuredCubic.startOutlineProgress,
          );
        }
      });
    }

    test('measure sharp triangle', () {
      regularPolygonMeasure(3);
    });

    test('measure sharp pentagon', () {
      regularPolygonMeasure(5);
    });

    test('measure sharp octagon', () {
      regularPolygonMeasure(8);
    });

    test('measure sharp dodecagon', () {
      regularPolygonMeasure(12);
    });

    test('measure sharp icosagon', () {
      regularPolygonMeasure(20);
    });

    test('measure slightly rounded hexagon', () {
      irregularPolygonMeasure(RoundedPolygon(6, rounding: const CornerRounding(radius: 0.15)));
    });

    test('measure medium rounded hexagon', () {
      irregularPolygonMeasure(RoundedPolygon(6, rounding: const CornerRounding(radius: 0.5)));
    });

    test('measure maximum rounded hexagon', () {
      irregularPolygonMeasure(RoundedPolygon(6, rounding: const CornerRounding(radius: 1)));
    });

    test('measure circle', () {
      // White box test: As the length measurer approximates arcs by linear
      // segments, this test validates if the chosen segment count approximates
      // the arc length up to an error of 1.5% from the true length.
      const vertices = 4;
      final polygon = RoundedPolygon.circle(numVertices: vertices);

      final double actualLength = polygon.cubics.fold<double>(
        0,
        (sum, cubic) => sum + const LengthMeasurer().measureCubic(cubic),
      );
      const double expectedLength = 2 * math.pi;

      expect(expectedLength, moreOrLessEquals(actualLength, epsilon: 0.015 * expectedLength));
    });

    test('measure irregular triangle angle', () {
      irregularPolygonMeasure(
        RoundedPolygon.fromVertices(
          const [Point(0, -1), Point(1, 1), Point(0, 0.5), Point(-1, 1)],
          perVertexRounding: const [
            CornerRounding(radius: 0.2, smoothing: 0.5),
            CornerRounding(radius: 0.2, smoothing: 0.5),
            CornerRounding(radius: 0.4),
            CornerRounding(radius: 0.2, smoothing: 0.5),
          ],
        ),
      );
    });

    test('measure quarter angle', () {
      irregularPolygonMeasure(
        RoundedPolygon.fromVertices(
          const [Point(-1, -1), Point(1, -1), Point(1, 1), Point(-1, 1)],
          perVertexRounding: const [
            CornerRounding.unrounded,
            CornerRounding.unrounded,
            CornerRounding(radius: 0.5, smoothing: 0.5),
            CornerRounding.unrounded,
          ],
        ),
      );
    });

    test('measure hour glass', () {
      // Regression test: Legacy measurer (AngleMeasurer) would skip the
      // diagonal sides as they are 0 degrees from the center.
      const unit = 1.0;
      const coordinates = <Point>[
        // lower glass
        Point.zero,
        Point(unit, unit),
        Point(-unit, unit),
        // upper glass
        Point.zero,
        Point(-unit, -unit),
        Point(unit, -unit),
      ];

      final double diagonal = math.sqrt(unit * unit + unit * unit);
      const double horizontal = 2 * unit;
      final double total = 4 * diagonal + 2 * horizontal;

      final polygon = RoundedPolygon.fromVertices(coordinates);
      customPolygonMeasure(polygon, [
        diagonal / total,
        horizontal / total,
        diagonal / total,
        diagonal / total,
        horizontal / total,
        diagonal / total,
      ]);
    });

    test('handles empty feature last', () {
      final triangle = RoundedPolygon.fromFeatures([
        PolygonFeature.convexCorner([CubicBezier.straightLine(Offset.zero, const Offset(1, 1))]),
        PolygonFeature.convexCorner([
          CubicBezier.straightLine(const Offset(1, 1), const Offset(1, 0)),
        ]),
        PolygonFeature.convexCorner([CubicBezier.straightLine(const Offset(1, 0), Offset.zero)]),
        // Empty feature at the end.
        PolygonFeature.convexCorner([CubicBezier.straightLine(Offset.zero, Offset.zero)]),
      ]);

      irregularPolygonMeasure(triangle);
    });

    test('measures a zero-perimeter polygon', () {
      irregularPolygonMeasure(RoundedPolygon(4, radius: 0), (measuredPolygon) {
        // With no lengths to go by, the cubics are spaced evenly instead.
        final double expectedSpan = 1 / measuredPolygon.length;
        for (var index = 0; index < measuredPolygon.length; index++) {
          final MeasuredCubic measuredCubic = measuredPolygon[index];
          expectEqualish(
            expectedSpan,
            measuredCubic.endOutlineProgress - measuredCubic.startOutlineProgress,
          );
        }
      });
    });

    test('cutAndShift keeps a cubic that ends a rounding error before the cut', () {
      final measured = MeasuredPolygon.measure(measurer, RoundedPolygon(3));
      final double boundary = measured[0].endOutlineProgress;

      // The smallest double above the boundary. The cut then falls on the
      // second cubic, and the first one ends a rounding error before it, so
      // close that its shifted end wraps around to 0 instead of 1.
      final double cut = _nextUp(boundary);
      expect(cut, greaterThan(boundary));
      expect(positiveModulo(boundary - cut, 1), 0);

      final MeasuredPolygon shifted = measured.cutAndShift(cut);

      // All three edges survive, starting from the second one.
      expect(shifted.length, 3);
      expectCubicsEqualish(measured[1].cubic, shifted[0].cubic);
      expectCubicsEqualish(measured[2].cubic, shifted[1].cubic);
      expectCubicsEqualish(measured[0].cubic, shifted[2].cubic);
      for (var index = 0; index < shifted.length; index++) {
        expectEqualish(
          1 / 3,
          shifted[index].endOutlineProgress - shifted[index].startOutlineProgress,
        );
      }
    });

    test('findCubicCutPoint at measure zero returns the curve start', () {
      final zeroLength = CubicBezier.point(Offset.zero);
      expect(measurer.findCubicCutPoint(zeroLength, 0), 0);

      final line = CubicBezier.straightLine(Offset.zero, const Offset(1, 0));
      expect(measurer.findCubicCutPoint(line, 0), 0);
    });
  });
}

/// The smallest double greater than [value].
double _nextUp(double value) {
  final data = ByteData(8)..setFloat64(0, value);
  data.setInt64(0, data.getInt64(0) + 1);
  return data.getFloat64(0);
}
