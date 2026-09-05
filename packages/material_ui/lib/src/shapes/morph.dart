// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/foundation.dart';

import 'cubic.dart';
import 'double_mapping.dart';
import 'feature_mapping.dart';
import 'polygon_measure.dart';
import 'rounded_polygon.dart';
import 'utils.dart';

/// This class is used to animate between start and end polygons objects.
///
/// Morphing between arbitrary objects can be problematic because it can be
/// difficult to determine how the points of a given shape map to the points of
/// some other shape. [Morph] simplifies the problem by only operating on
/// [RoundedPolygon] objects, which are known to have similar, contiguous
/// structures. For one thing, the shape of a polygon is contiguous from start
/// to end (compared to an arbitrary [Path] object, which could have one or more
/// `moveTo` operations in the shape). Also, all edges of a polygon shape are
/// represented by [CubicBezier] objects, thus the start and end shapes use similar
/// operations. Two Polygon shapes then only differ in the quantity and
/// placement of their curves. The morph works by determining how to map the
/// curves of the two shapes together (based on proximity and other
/// information, such as distance to polygon vertices and concavity), and
/// splitting curves when the shapes do not have the same number of curves or
/// when the curve placement within the shapes is very different.
@immutable
class Morph {
  /// Creates a [Morph] between the [start] and [end] polygons.
  ///
  /// The mapping between the two shapes is computed once, here, so a [Morph]
  /// should be created ahead of time and reused across frames rather than
  /// rebuilt for each value of progress.
  Morph(this.start, this.end) : _morphMatch = _match(start, end);

  /// The shape this morph produces at a progress of 0.
  final RoundedPolygon start;

  /// The shape this morph produces at a progress of 1.
  final RoundedPolygon end;

  /// The structure which holds the actual shape being morphed. It contains all
  /// cubics necessary to represent the start and end shapes (the original
  /// cubics in the shapes may be cut to align the start/end shapes), matched
  /// one to one in each pair.
  final List<(CubicBezier, CubicBezier)> _morphMatch;

  /// [_match], called at [Morph] construction time, creates the structure used
  /// to animate between the start and end shapes. The technique is to match
  /// geometry (curves) between the shapes when and where possible, and to
  /// create new/placeholder curves when necessary (when one of the shapes has
  /// more curves than the other). The result is a list of pairs of CubicBezier
  /// curves. Those curves are the matched pairs: the first of each pair holds
  /// the geometry of the start shape, the second holds the geometry for the
  /// end shape. Changing the progress of a Morph object simply interpolates
  /// between all pairs of curves for the morph shape.
  ///
  /// Curves on both shapes are matched by running the [Measurer] to determine
  /// where the points are in each shape (proportionally, along the outline),
  /// and then running [featureMapper] which decides how to map (match) all of
  /// the curves with each other.
  static List<(CubicBezier, CubicBezier)> _match(RoundedPolygon p1, RoundedPolygon p2) {
    // Measure polygons, returns lists of measured cubics for each polygon,
    // which we then use to match start/end curves.
    final measuredPolygon1 = MeasuredPolygon.measurePolygon(const LengthMeasurer(), p1);
    final measuredPolygon2 = MeasuredPolygon.measurePolygon(const LengthMeasurer(), p2);

    // features1 and 2 will contain the list of corners (just the inner
    // circular curve) along with the progress at the middle of those corners.
    // These measurement values are then used to compare and match between the
    // two polygons.
    final List<ProgressableFeature> features1 = measuredPolygon1.features;
    final List<ProgressableFeature> features2 = measuredPolygon2.features;

    // Map features: doubleMapper is the result of mapping the features in each
    // shape to the closest feature in the other shape.
    // Given a progress in one of the shapes it can be used to find the
    // corresponding progress in the other shape (in both directions).
    final DoubleMapper doubleMapper = featureMapper(features1, features2);

    // cut point on poly2 is the mapping of the 0 point on poly1.
    final double polygon2CutPoint = doubleMapper.map(0);

    // Cut and rotate.
    // Polygons start at progress 0, and the featureMapper has decided that we
    // want to match progress 0 in the first polygon to `polygon2CutPoint` on
    // the second polygon. So we need to cut the second polygon there and
    // "rotate it", so as we walk through both polygons we can find the
    // matching. The resulting bs1/2 are MeasuredPolygons, whose MeasuredCubics
    // start from outlineProgress=0 and increasing until outlineProgress=1.
    final bs1 = measuredPolygon1;
    final MeasuredPolygon bs2 = measuredPolygon2.cutAndShift(polygon2CutPoint);

    // Match.
    // Now we can compare the two lists of measured cubics and create a list of
    // pairs of cubics [ret], which are the start/end curves that represent the
    // Morph object and the start and end shapes, and which can be interpolated
    // to animate the between those shapes.
    final ret = <(CubicBezier, CubicBezier)>[];
    // i1/i2 are the indices of the current cubic on the start (1) and end (2)
    // shapes.
    var i1 = 0;
    var i2 = 0;
    // b1, b2 are the current measured cubic for each polygon.
    MeasuredCubic? b1 = bs1.getOrNull(i1++);
    MeasuredCubic? b2 = bs2.getOrNull(i2++);
    // Iterate until all curves are accounted for and matched.
    while (b1 != null && b2 != null) {
      // Progresses are in shape1's perspective
      // b1a, b2a are ending progress values of current measured cubics in
      // [0,1] range.
      final double b1a = (i1 == bs1.length) ? 1.0 : b1.endOutlineProgress;
      final double b2a = (i2 == bs2.length)
          ? 1.0
          : doubleMapper.mapBack(positiveModulo(b2.endOutlineProgress + polygon2CutPoint, 1));
      final double minb = math.min(b1a, b2a);
      // min b is the progress at which the curve that ends first ends.
      // If both curves ends roughly there, no cutting is needed, we have a
      // match.
      // If one curve extends beyond, we need to cut it.
      final (MeasuredCubic seg1, MeasuredCubic? newb1) = (b1a > minb + angleEpsilon)
          ? b1.cutAtProgress(minb)
          : (b1, bs1.getOrNull(i1++));

      final (MeasuredCubic seg2, MeasuredCubic? newb2) = (b2a > minb + angleEpsilon)
          ? b2.cutAtProgress(positiveModulo(doubleMapper.map(minb) - polygon2CutPoint, 1))
          : (b2, bs2.getOrNull(i2++));

      ret.add((seg1.cubic, seg2.cubic));
      b1 = newb1;
      b2 = newb2;
    }

    assert(b1 == null && b2 == null, "Expected both Polygon's CubicBezier to be fully matched");

    return ret;
  }

  /// The axis-aligned bounds of this morph, covering both of its shapes.
  ///
  /// This solves for the actual extrema of every curve. See
  /// [approximateBounds] for a cheaper result that is never smaller than this
  /// one.
  Rect get bounds => start.bounds.expandToInclude(end.bounds);

  /// A cheaper alternative to [bounds], based on the min/max values of all
  /// anchor and control points that make up the two shapes.
  ///
  /// The result is never smaller than [bounds], but can be larger.
  Rect get approximateBounds => start.approximateBounds.expandToInclude(end.approximateBounds);

  /// Like [bounds], the axis-aligned bounds of this morph, but determining the
  /// max dimension of the shapes (by calculating the distance from their
  /// center to the start and midpoint of each curve) and returning a square
  /// which can be used to hold the morph in any rotation.
  ///
  /// This can be used, for example, to calculate the max size of a UI element
  /// meant to hold this morph in any rotation.
  Rect get maxBounds => start.maxBounds.expandToInclude(end.maxBounds);

  /// Returns a representation of the morph object at a given [progress] value
  /// as a list of [CubicBezier]s. Note that this function causes a new list to be
  /// created and populated, so there is some
  /// overhead.
  ///
  /// [progress] is a value from 0 to 1 that determines the morph's current
  /// shape, between the start and end shapes provided at construction time. A
  /// value of 0 results in the start shape, a value of 1 results in the end
  /// shape, and any value in between results in a shape which is a linear
  /// interpolation between those two shapes.
  ///
  /// The range is generally [0..1] and values outside could result in
  /// undefined shapes, but values close to (but outside) the range can be used
  /// to get an exaggerated effect (e.g., for a bounce or overshoot animation).
  List<CubicBezier> toCubics(double progress) {
    final result = <CubicBezier>[];

    // The first/last mechanism here ensures that the final anchor point in the
    // shape exactly matches the first anchor point. There can be rendering
    // artifacts introduced by those points being slightly off, even by much
    // less than a pixel.
    CubicBezier? firstCubic;
    CubicBezier? lastCubic;

    for (var i = 0; i < _morphMatch.length; i++) {
      final cubic = CubicBezier.raw(
        List<double>.generate(8, (j) {
          return lerp(_morphMatch[i].$1.points[j], _morphMatch[i].$2.points[j], progress);
        }),
      );

      firstCubic ??= cubic;
      if (lastCubic != null) {
        result.add(lastCubic);
      }
      lastCubic = cubic;
    }

    if (lastCubic != null && firstCubic != null) {
      result.add(
        CubicBezier.raw([
          lastCubic.anchor0X,
          lastCubic.anchor0Y,
          lastCubic.control0X,
          lastCubic.control0Y,
          lastCubic.control1X,
          lastCubic.control1Y,
          firstCubic.anchor0X,
          firstCubic.anchor0Y,
        ]),
      );
    }

    return result;
  }

  /// Returns a [Path] for a [Morph].
  ///
  /// [progress] is the [Morph]'s progress.
  ///
  /// [startAngle] places the start point of the first curve at that angle, in
  /// radians, around [rotationPivot], rotating the whole path to get it there.
  /// Zero is to the right of the pivot and `pi / 2` below it, since y grows
  /// downwards.
  /// The default of zero is special: it skips the rotation entirely and leaves
  /// the curves as [toCubics] produced them.
  ///
  /// [repeatPath] is whether or not to repeat the [Path] twice before closing
  /// it. This flag is useful when the caller would like to draw parts of the
  /// path while offsetting the start and stop positions (for example, when
  /// phasing and rotating a path to simulate a motion as a Star circular
  /// progress indicator advances).
  ///
  /// [closePath] is whether or not to close the created [Path].
  ///
  /// [rotationPivot] is the point [startAngle] rotates the path around, and the
  /// point its angle is measured from. It defaults to the origin, which suits a
  /// [Morph] between polygons with a zero [RoundedPolygon.center]. A [Morph]
  /// between polygons centered elsewhere should pass their center, (0.5, 0.5)
  /// for normalized ones.
  Path toPath(
    double progress, {
    double startAngle = 0,
    bool repeatPath = false,
    bool closePath = true,
    Offset rotationPivot = Offset.zero,
  }) {
    return pathFromCubics(
      toCubics(progress),
      startAngle: startAngle,
      repeatPath: repeatPath,
      closePath: closePath,
      rotationPivot: rotationPivot,
    );
  }

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) {
      return false;
    }

    return other is Morph && other.start == start && other.end == end;
  }

  @override
  int get hashCode => Object.hash(start, end);

  @override
  String toString() {
    return '${objectRuntimeType(this, 'Morph')}'
        '(start: $start, end: $end)';
  }
}
