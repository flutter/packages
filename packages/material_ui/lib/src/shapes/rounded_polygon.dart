// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// @docImport 'morph.dart';
library;

import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/foundation.dart';

import 'corner_rounding.dart';
import 'cubic.dart';
import 'features.dart';
import 'point.dart';
import 'utils.dart';

/// The RoundedPolygon class allows simple construction of polygonal shapes
/// with optional rounding at the vertices. Polygons can be constructed with
/// either the number of vertices desired or an ordered list of vertices.
@immutable
class RoundedPolygon {
  RoundedPolygon._(this.features, this._center) : cubics = <CubicBezier>[] {
    _initCubics();

    assert(() {
      CubicBezier prevCubic = cubics[cubics.length - 1];

      for (var index = 0; index < cubics.length; index++) {
        final CubicBezier cubic = cubics[index];

        if ((cubic.anchor0X - prevCubic.anchor1X).abs() > distanceEpsilon ||
            (cubic.anchor0Y - prevCubic.anchor1Y).abs() > distanceEpsilon) {
          throw ArgumentError(
            'RoundedPolygon must be contiguous, with the anchor points of all '
            'curves matching the anchor points of the preceding and succeeding '
            'cubics.',
          );
        }
        prevCubic = cubic;
      }

      return true;
    }());
  }

  /// This constructor takes the number of vertices in the resulting polygon.
  /// These vertices are positioned on a virtual circle around a given center
  /// with each vertex positioned [radius] distance from that center, equally
  /// spaced (with equal angles between them). If no radius is supplied, the
  /// shape will be created with a default radius of 1, resulting in a shape
  /// whose vertices lie on a unit circle, with width/height of 2. That default
  /// polygon will probably need to be rescaled using [transformed] into the
  /// appropriate size for the UI in which it will be drawn.
  ///
  /// The [rounding] and [perVertexRounding] parameters are optional. If not
  /// supplied, the result will be a regular polygon with straight edges and
  /// unrounded corners.
  ///
  /// [numVertices] is the number of vertices in this polygon.
  ///
  /// [radius] is the radius of the polygon, in pixels. This radius determines
  /// the initial size of the object, but it can be transformed later by using
  /// the [transformed] function.
  ///
  /// [center] is the center of the polygon, around which all vertices will be
  /// placed. The default center is at (0,0).
  ///
  /// [rounding] is the [CornerRounding] properties of all vertices. If some
  /// vertices should have different rounding properties, then use
  /// [perVertexRounding] instead. The default rounding value is
  /// [CornerRounding.unrounded], meaning that the polygon will use the
  /// vertices themselves in the final shape and not curves rounded around the
  /// vertices.
  ///
  /// [perVertexRounding] is the [CornerRounding] properties of every vertex.
  /// If this parameter is not null, then it must have [numVertices] elements.
  /// If this parameter is null, then the polygon will use the [rounding]
  /// parameter for every vertex instead. The default value is null.
  ///
  /// Throws [ArgumentError] if [perVertexRounding] is not null and its size
  /// is not equal to [numVertices].
  /// Throws [ArgumentError] when [numVertices] is less than 3.
  factory RoundedPolygon.fromVerticesNum(
    int numVertices, {
    double radius = 1,
    Offset center = Offset.zero,
    CornerRounding rounding = CornerRounding.unrounded,
    List<CornerRounding>? perVertexRounding,
  }) {
    if (numVertices < 3) {
      throw ArgumentError('numVertices must be at least 3.');
    }

    return RoundedPolygon.fromVertices(
      _verticesFromNumVerts(numVertices, radius, center),
      rounding: rounding,
      perVertexRounding: perVertexRounding,
      center: center,
    );
  }

  /// Creates a copy of the given [RoundedPolygon].
  RoundedPolygon.from(RoundedPolygon roundedPolygon)
    : this._(roundedPolygon.features, roundedPolygon.center);

  /// This function takes the vertices (either supplied or calculated,
  /// depending on the constructor called), plus [CornerRounding] parameters,
  /// and creates the actual [RoundedPolygon] shape, rounding around the
  /// vertices (or not) as specified. The result is a list of [CubicBezier] curves
  /// which represent the geometry of the final shape.
  ///
  /// [vertices] is the list of vertices in this polygon. This should be an
  /// ordered list (with the outline of the shape going from each vertex to the
  /// next in order of this list), otherwise the results will be undefined.
  ///
  /// [rounding] is the [CornerRounding] properties of all vertices. If some
  /// vertices should have different rounding properties, then use
  /// [perVertexRounding] instead. The default rounding value is
  /// [CornerRounding.unrounded], meaning that the polygon will use the
  /// vertices themselves in the final shape and not curves rounded around the
  /// vertices.
  ///
  /// [perVertexRounding] is the [CornerRounding] properties of all vertices.
  /// If this parameter is not null, then it must have the same size as
  /// [vertices]. If this parameter is null, then the polygon will use the
  /// [rounding] parameter for every vertex instead. The default value is null.
  ///
  /// [center] is the center of the polygon, around which all vertices will be
  /// placed. If `null` (the default value), the center is estimated by
  /// averaging the [vertices].
  ///
  /// Throws [ArgumentError] if the number of vertices is less than 3, or if
  /// the [perVertexRounding] parameter is not null and its size doesn't match
  /// the number of vertices.
  ///
  // TODO(performance): Update the map calls to more efficient code that
  // doesn't allocate Iterators unnecessarily.
  factory RoundedPolygon.fromVertices(
    List<Offset> vertices, {
    CornerRounding rounding = CornerRounding.unrounded,
    List<CornerRounding>? perVertexRounding,
    Offset? center,
  }) {
    if (vertices.length < 3) {
      throw ArgumentError('Polygons must have at least 3 vertices.');
    }
    if (perVertexRounding != null && perVertexRounding.length != vertices.length) {
      throw ArgumentError(
        'perVertexRounding list should be either null or '
        'the same size as the number of vertices.',
      );
    }
    final corners = <List<CubicBezier>>[];
    final int n = vertices.length;
    final roundedCorners = <_RoundedCorner>[];
    for (var i = 0; i < n; i++) {
      final CornerRounding vtxRounding = perVertexRounding?[i] ?? rounding;
      final int prevIndex = (i + n - 1) % n;
      final int nextIndex = (i + 1) % n;
      roundedCorners.add(
        _RoundedCorner(vertices[prevIndex], vertices[i], vertices[nextIndex], vtxRounding),
      );
    }

    // For each side, check if we have enough space to do the cuts needed, and
    // if not split the available space, first for round cuts, then for
    // smoothing if there is space left. Each element in this list is a pair,
    // that represent how much we can do of the cut for the given side (side i
    // goes from corner i to corner i+1), the elements of the pair are: first
    // is how much we can use of expectedRoundCut, second how much of
    // expectedCut.
    final List<(num, num)> cutAdjusts = List.generate(n, (ix) {
      final double expectedRoundCut =
          roundedCorners[ix].expectedRoundCut + roundedCorners[(ix + 1) % n].expectedRoundCut;
      final double expectedCut =
          roundedCorners[ix].expectedCut + roundedCorners[(ix + 1) % n].expectedCut;
      final Point vtx = vertices[ix];
      final Point nextVtx = vertices[(ix + 1) % n];
      final double sideSize = distance(vtx.x - nextVtx.x, vtx.y - nextVtx.y);

      // Check expectedRoundCut first, and ensure we fulfill rounding needs
      // first for both corners before using space for smoothing.
      if (expectedRoundCut > sideSize) {
        // Not enough room for fully rounding, see how much we can actually do.
        return (sideSize / expectedRoundCut, 0);
      } else if (expectedCut > sideSize) {
        // We can do full rounding, but not full smoothing.
        return (1, (sideSize - expectedRoundCut) / (expectedCut - expectedRoundCut));
      } else {
        // There is enough room for rounding & smoothing.
        return (1, 1);
      }
    });

    // Create and store list of beziers for each [potentially] rounded corner.
    for (var i = 0; i < n; i++) {
      // allowedCuts[0] is for the side from the previous corner to this one,
      // allowedCuts[1] is for the side from this corner to the next one.
      final allowedCuts = List<double>.filled(2, 0);

      for (var delta = 0; delta <= 1; delta++) {
        final (num roundCutRatio, num cutRatio) = cutAdjusts[(i + n - 1 + delta) % n];
        allowedCuts[delta] =
            roundedCorners[i].expectedRoundCut * roundCutRatio +
            (roundedCorners[i].expectedCut - roundedCorners[i].expectedRoundCut) * cutRatio;
      }

      corners.add(roundedCorners[i].getCubics(allowedCuts[0], allowedCuts[1]));
    }

    // Finally, store the calculated cubics. This includes all of the rounded
    // corners from above, along with new cubics representing the edges between
    // those corners.
    final tempFeatures = <Feature>[];
    for (var i = 0; i < n; i++) {
      final Point currVertex = vertices[i];
      final Point prevVertex = vertices[(i + n - 1) % n];
      final Point nextVertex = vertices[(i + 1) % n];
      final bool cvx = convex(prevVertex, currVertex, nextVertex);
      tempFeatures
        ..add(CornerFeature(corners[i], convex: cvx))
        ..add(
          EdgeFeature([
            CubicBezier.straightLine(corners[i].last.anchor1, corners[(i + 1) % n].first.anchor0),
          ]),
        );
    }

    return RoundedPolygon.fromFeatures(tempFeatures, center: center ?? calculateCenter(vertices));
  }

  /// Takes a list of [Feature] objects that define the polygon's shape and
  /// curves. By specifying the features directly, the summarization of [CubicBezier]
  /// objects to curves can be precisely controlled. This affects [Morph]'s
  /// default mapping, as curves with the same type (convex or concave) are
  /// mapped with each other. For example, if you have a convex curve in your
  /// start polygon, [Morph] will map it to another convex curve in the end
  /// polygon.
  ///
  /// The [center] parameter is optional. If not supplied, it will be estimated
  /// by calculating the average of all cubic anchor points.
  ///
  /// [features] are the [Feature]s that describe the characteristics of each
  /// outline segment of the polygon.
  ///
  /// [center] is the center of the polygon, around which all vertices will be
  /// placed. If null (the default value), the center will be averaged.
  ///
  /// Throws [ArgumentError] if [features] length is less than 2 or if they
  /// don't describe a closed shape.
  factory RoundedPolygon.fromFeatures(List<Feature> features, {Offset? center}) {
    if (features.length < 2) {
      throw ArgumentError('Polygons must have at least 2 features.');
    }

    if (center != null) {
      return RoundedPolygon._(features, center);
    }

    final vertices = <Point>[];

    for (final feature in features) {
      for (final CubicBezier cubic in feature.cubics) {
        vertices.add(Point(cubic.anchor0X, cubic.anchor0Y));
      }
    }

    return RoundedPolygon._(features, calculateCenter(vertices));
  }

  /// Creates a circular shape, approximating the rounding of the shape around
  /// the underlying polygon
  /// vertices.
  ///
  /// [numVertices] is the number of vertices in the underlying polygon with
  /// which to approximate the circle, default value is 8.
  ///
  /// [radius] is the optional radius for the circle, default value is 1.0.
  ///
  /// [center] is the optional center for the circle, default value is
  /// [Offset.zero].
  ///
  /// Throws [ArgumentError] when [numVertices] is less than 3.
  factory RoundedPolygon.circle({
    int numVertices = 8,
    double radius = 1,
    Offset center = Offset.zero,
  }) {
    if (numVertices < 3) {
      throw ArgumentError('Circle must have at least three vertices.');
    }

    // Half of the angle between two adjacent vertices on the polygon.
    final double theta = math.pi / numVertices;
    // Radius of the underlying RoundedPolygon object given the desired radius
    // of the circle.
    final double polygonRadius = radius / math.cos(theta);
    return RoundedPolygon.fromVerticesNum(
      numVertices,
      radius: polygonRadius,
      center: center,
      rounding: CornerRounding(radius: radius),
    );
  }

  /// Creates a rectangular shape with the given width/height around the given
  /// center. Optional rounding parameters can be used to create a rounded
  /// rectangle instead.
  ///
  /// As with all [RoundedPolygon] objects, if this shape is created with
  /// default dimensions and center, it is sized to fit within the 2x2
  /// bounding box around a center of (0, 0) and will need to be scaled and
  /// moved using [RoundedPolygon.transformed] to fit the intended area in a UI.
  ///
  /// [width] is the width of the rectangle, default value is 2.
  ///
  /// [height] is the height of the rectangle, default value is 2.
  ///
  /// [rounding] is the [CornerRounding] properties of every vertex. If some
  /// vertices should have different rounding properties, then use
  /// [perVertexRounding] instead. The default rounding value is
  /// [CornerRounding.unrounded], meaning that the polygon will use the
  /// vertices themselves in the final shape and not curves rounded around the
  /// vertices.
  ///
  /// [perVertexRounding] is the [CornerRounding] properties of every vertex.
  /// If this parameter is not null, then it must be of size 4 for the four
  /// corners of the shape. If this parameter is null, then the polygon will
  /// use the [rounding] parameter for every vertex instead. The default value
  /// is null.
  ///
  /// [center] is the center of the rectangle, around which all vertices will
  /// be placed equidistantly. The default center is at (0,0).
  factory RoundedPolygon.rectangle({
    double width = 2,
    double height = 2,
    CornerRounding rounding = CornerRounding.unrounded,
    List<CornerRounding>? perVertexRounding,
    Offset center = Offset.zero,
  }) {
    final double left = center.x - width / 2;
    final double top = center.y - height / 2;
    final double right = center.x + width / 2;
    final double bottom = center.y + height / 2;

    return RoundedPolygon.fromVertices(
      [Point(right, bottom), Point(left, bottom), Point(left, top), Point(right, top)],
      rounding: rounding,
      perVertexRounding: perVertexRounding,
      center: center,
    );
  }

  /// Creates a star polygon, which is like a regular polygon except every
  /// other vertex is on either an inner or outer radius. The two radii
  /// specified in the constructor must both both nonzero. If the radii are
  /// equal, the result will be a regular (not star) polygon with twice the
  /// number of vertices specified in [numVerticesPerRadius].
  ///
  /// [numVerticesPerRadius] is the number of vertices along each of the two
  /// radii.
  ///
  /// [radius] is the outer radius for this star shape, must be greater than 0.
  /// Default value is 1.
  ///
  /// [innerRadius] is the inner radius for this star shape, must be greater
  /// than 0 and less than or equal to [radius]. Note that equal radii would
  /// be the same as creating a [RoundedPolygon] directly, but with
  /// 2 * [numVerticesPerRadius] vertices. Default value is 0.5.
  ///
  /// [rounding] is the [CornerRounding] properties of every vertex. If some
  /// vertices should have different rounding properties, then use
  /// [perVertexRounding] instead. The default rounding value is
  /// [CornerRounding.unrounded], meaning that the polygon will use the
  /// vertices themselves in the final shape and not curves rounded around the
  /// vertices.
  ///
  /// [innerRounding] is the optional rounding parameters for the vertices on
  /// the [innerRadius]. If null (the default value), inner vertices will use
  /// the [rounding] or [perVertexRounding] parameters instead.
  ///
  /// [perVertexRounding] is the the [CornerRounding] properties of every
  /// vertex. If this parameter is not null, then it must have the same size as
  /// 2 * [numVerticesPerRadius]. If this parameter is null, then the polygon
  /// will use the [rounding] parameter for every vertex instead. The default
  /// value is null.
  ///
  /// [center] is the center of the polygon, around which all vertices will be
  /// placed. The default center is at (0,0).
  ///
  /// Throws [ArgumentError] if either [radius] or [innerRadius] are <= 0 or
  /// [innerRadius] > [radius].
  factory RoundedPolygon.star({
    required int numVerticesPerRadius,
    double radius = 1,
    double innerRadius = 0.5,
    CornerRounding rounding = CornerRounding.unrounded,
    CornerRounding? innerRounding,
    List<CornerRounding>? perVertexRounding,
    Offset center = Offset.zero,
  }) {
    if (radius <= 0 || innerRadius <= 0) {
      throw ArgumentError('Star radii must both be greater than 0.');
    }
    if (innerRadius >= radius) {
      throw ArgumentError('innerRadius must be less than radius.');
    }

    var pvRounding = perVertexRounding;
    // If no per-vertex rounding supplied and caller asked for inner rounding,
    // create per-vertex rounding list based on supplied outer/inner rounding
    // parameters.
    if (pvRounding == null && innerRounding != null) {
      pvRounding = [
        for (var i = 0; i < numVerticesPerRadius; i++) ...[rounding, innerRounding],
      ];
    }

    // Star polygon is just a polygon with all vertices supplied (where we
    // generate those vertices to be on the inner/outer radii).
    return RoundedPolygon.fromVertices(
      _starVerticesFromNumVerts(numVerticesPerRadius, radius, innerRadius, center),
      rounding: rounding,
      perVertexRounding: pvRounding,
      center: center,
    );
  }

  /// A pill shape consists of a rectangle shape bounded by two semicircles at
  /// either of the long ends of the rectangle.
  ///
  /// [width] is the width of the resulting shape.
  ///
  /// [height is the height of the resulting shape.
  ///
  /// [smoothing] the amount by which the arc is "smoothed" by extending the
  /// curve from the circular arc on each endcap to the edge between the
  /// endcaps. A value of 0 (no smoothing) indicates that the corner is rounded
  /// by only a circular arc.
  ///
  /// [center] is the center of the polygon, around which all vertices will be
  /// placed. The default center is at (0,0).
  ///
  /// Throws [ArgumentError] if either [width] or [height] are <= 0.
  factory RoundedPolygon.pill({
    double width = 2,
    double height = 1,
    double smoothing = 0,
    Offset center = Offset.zero,
  }) {
    if (width <= 0 || height <= 0) {
      throw ArgumentError('Pill shapes must have positive width and height.');
    }

    final double wHalf = width / 2;
    final double hHalf = height / 2;

    return RoundedPolygon.fromVertices(
      [
        Point(wHalf + center.x, hHalf + center.y),
        Point(-wHalf + center.x, hHalf + center.y),
        Point(-wHalf + center.x, -hHalf + center.y),
        Point(wHalf + center.x, -hHalf + center.y),
      ],
      rounding: CornerRounding(radius: math.min(wHalf, hHalf), smoothing: smoothing),
      center: center,
    );
  }

  /// A pillStar shape is like a [RoundedPolygon.pill] except it has inner and
  /// outer radii along its pill-shaped outline, just like a
  /// [RoundedPolygon.star] has inner and outer radii along its circular
  /// outline. The parameters for a [RoundedPolygon.pillStar] are similar to
  /// those of a [RoundedPolygon.star] except, like [RoundedPolygon.pill], it
  /// has a [width] and [height] to determine the general shape of the
  /// underlying pill. Also, there is a subtle complication with the way that
  /// inner and outer vertices proceed along the circular ends of the
  /// shape, depending on the magnitudes of the [rounding], [innerRounding],
  /// and [innerRadiusRatio] parameters. For example, a shape with outer
  /// vertices that lie along the curved end outline will necessarily have
  /// inner vertices that are closer to each other, because of the curvature of
  /// that part of the shape. Conversely, if the inner vertices are lined up
  /// along the pill outline at the ends, then the outer vertices will be much
  /// further apart from each other.
  ///
  /// The default approach, reflected by the default value of [vertexSpacing],
  /// is to use the average of the outer and inner radii, such that each set of
  /// vertices falls equally to the other side of the pill outline on the
  /// curved ends. Depending on the values used for the various rounding
  /// and radius parameters, you may want to change that value to suit the
  /// look you want. A value of 0 for [vertexSpacing] is equivalent to aligning
  /// the inner vertices along the circular curve, and a value of 1 is
  /// equivalent to aligning the outer vertices along that curve.
  ///
  /// [width] is the width of the resulting shape.
  ///
  /// [height] is the height of the resulting shape.
  ///
  /// [numVerticesPerRadius] is the number of vertices along each of the two
  /// radii.
  ///
  /// [innerRadiusRatio] is the Inner radius ratio for this star shape, must be
  /// greater than 0 and less than or equal to 1. Note that a value of 1 would
  /// be similar to creating a [RoundedPolygon.pill], but with more vertices.
  /// The default value is 0.5.
  ///
  /// [rounding] is the [CornerRounding] properties of every vertex. If some
  /// vertices should have different rounding properties, then use
  /// [perVertexRounding] instead. The default rounding value is
  /// [CornerRounding.unrounded], meaning that the polygon will use the
  /// vertices themselves in the final shape and not curves rounded around the
  /// vertices.
  ///
  /// [innerRounding] is the optional rounding parameters for the vertices on
  /// the [innerRadiusRatio]. If null (the default value), inner vertices will
  /// use the [rounding] or [perVertexRounding] parameters instead.
  /// [perVertexRounding] is the [CornerRounding] properties of every vertex.
  /// If this parameter is not null, then it must have the same size as
  /// 2 * [numVerticesPerRadius]. If this parameter is null, then the polygon
  /// will use the [rounding] parameter for every vertex instead. The default
  /// value is null.
  ///
  /// [vertexSpacing] is the factor, which determines how the vertices on the
  /// circular ends are laid out along the outline. A value of 0 aligns spaces
  /// the inner vertices the same as those along the straight edges, with the
  /// outer vertices then being spaced further apart. A value of 1 does the
  /// opposite, with the outer vertices spaced the same as the vertices on the
  /// straight edges. The default value is .5, which takes the average of these
  /// two extremes.
  ///
  /// [startLocation] is a value from 0 to 1 which determines how far along
  /// the perimeter of this shape to start the underlying curves of which it is
  /// comprised. This is not usually needed or noticed by the user. But if the
  /// caller wants to manually and gradually stroke the path when drawing it,
  /// it might matter where that path outline begins and ends. The default
  /// value is 0.
  ///
  /// [center] is the center of the polygon, around which all vertices will be
  /// placed. The default center is at (0,0).
  ///
  /// Throws [ArgumentError] if either [width] or [height] are <= 0 or
  ///  if [innerRadiusRatio] is outside the range of (0, 1].
  factory RoundedPolygon.pillStar({
    double width = 2,
    double height = 1,
    int numVerticesPerRadius = 8,
    double innerRadiusRatio = 0.5,
    CornerRounding rounding = CornerRounding.unrounded,
    CornerRounding? innerRounding,
    List<CornerRounding>? perVertexRounding,
    double vertexSpacing = 0.5,
    double startLocation = 0,
    Offset center = Offset.zero,
  }) {
    if (width <= 0 || height <= 0) {
      throw ArgumentError('Pill shapes must have positive width and height.');
    }
    if (innerRadiusRatio <= 0 || innerRadiusRatio > 1) {
      throw ArgumentError('innerRadius must in (0, 1] range.');
    }
    if (vertexSpacing < 0 || vertexSpacing > 1) {
      throw ArgumentError('vertexSpacing must be in [0, 1] range.');
    }
    if (startLocation < 0 || startLocation > 1) {
      throw ArgumentError('startLocation must be in [0, 1] range.');
    }

    var pvRounding = perVertexRounding;
    // If no per-vertex rounding supplied and caller asked for inner rounding,
    // create per-vertex rounding list based on supplied outer/inner rounding
    // parameters.
    if (pvRounding == null && innerRounding != null) {
      pvRounding = [
        for (var i = 0; i < numVerticesPerRadius; i++) ...[rounding, innerRounding],
      ];
    }

    return RoundedPolygon.fromVertices(
      _pillStarVerticesFromNumVerts(
        numVerticesPerRadius,
        width,
        height,
        innerRadiusRatio,
        vertexSpacing,
        startLocation,
        center,
      ),
      rounding: rounding,
      perVertexRounding: pvRounding,
      center: center,
    );
  }

  /// The [Feature]s this polygon is composed of.
  final List<Feature> features;

  final Point _center;

  /// A flattened version of the [Feature]s, as a `List<CubicBezier>`.
  final List<CubicBezier> cubics;

  /// The center of this polygon, around which all vertices are placed.
  Offset get center => _center;

  void _initCubics() {
    // The first/last mechanism here ensures that the final anchor point in the
    // shape exactly matches the first anchor point. There can be rendering
    // artifacts introduced by those points being slightly off, even by much
    // less than a pixel.
    CubicBezier? firstCubic;
    CubicBezier? lastCubic;
    List<CubicBezier>? firstFeatureSplitStart;
    List<CubicBezier>? firstFeatureSplitEnd;

    if (features.isNotEmpty && features[0].cubics.length == 3) {
      final CubicBezier centerCubic = features[0].cubics[1];
      final (CubicBezier start, CubicBezier end) = centerCubic.split(0.5);
      firstFeatureSplitStart = [features[0].cubics[0], start];
      firstFeatureSplitEnd = [end, features[0].cubics[2]];
    }

    // iterating one past the features list size allows us to insert the
    // initial split cubic if it exists.
    for (var i = 0; i <= features.length; i++) {
      final List<CubicBezier> featureCubics;

      if (i == 0 && firstFeatureSplitEnd != null) {
        featureCubics = firstFeatureSplitEnd;
      } else if (i == features.length) {
        if (firstFeatureSplitStart != null) {
          featureCubics = firstFeatureSplitStart;
        } else {
          break;
        }
      } else {
        featureCubics = features[i].cubics;
      }

      for (var j = 0; j < featureCubics.length; j++) {
        // Skip zero-length curves; they add nothing and can trigger rendering
        // artifacts.
        final CubicBezier cubic = featureCubics[j];

        if (!cubic.zeroLength()) {
          if (lastCubic != null) {
            cubics.add(lastCubic);
          }
          lastCubic = cubic;
          firstCubic ??= cubic;
        } else {
          if (lastCubic != null) {
            // Dropping several zero-ish length curves in a row can lead to
            // enough discontinuity to throw an exception later, even though the
            // distances are quite small. Account for that by making the last
            // cubic use the latest anchor point, always.
            final List<double> points = lastCubic.points.toList();
            points[6] = cubic.anchor1X;
            points[7] = cubic.anchor1Y;
            lastCubic = CubicBezier.raw(points);
          }
        }
      }
    }

    if (lastCubic != null && firstCubic != null) {
      cubics.add(
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
    } else {
      // Empty / 0-sized polygon.
      cubics.add(CubicBezier.empty(_center));
    }
  }

  /// Transforms (scales/translates/etc.) this [RoundedPolygon] with the given
  /// [PointTransformer] and returns a new [RoundedPolygon]. This is a low
  /// level API and there should be more platform idiomatic ways to transform
  /// a [RoundedPolygon] provided by the platform specific wrapper.
  ///
  /// [f] is the [PointTransformer] used to transform this [RoundedPolygon].
  RoundedPolygon transformed(PointTransformer f) {
    return RoundedPolygon._([
      for (var i = 0; i < features.length; i++) features[i].transformed(f),
    ], _center.transformed(f));
  }

  /// Creates a new RoundedPolygon, moving and resizing this one, so it's
  /// completely inside the (0, 0) -> (1, 1) square, centered if there extra
  /// space in one direction.
  RoundedPolygon normalized() {
    final Rect bounds = calculateBounds();
    final double side = math.max(bounds.width, bounds.height);

    // Center the shape if bounds are not a square.
    final double offsetX = (side - bounds.width) / 2 - bounds.left;
    final double offsetY = (side - bounds.height) / 2 - bounds.top;

    return transformed((x, y) => ((x + offsetX) / side, (y + offsetY) / side));
  }

  /// Like [calculateBounds], this function calculates the axis-aligned bounds
  /// of the object and returns that rectangle. But this function determines
  /// the max dimension of the shape (by calculating the distance from its
  /// center to the start and midpoint of each curve) and returns a square
  /// which can be used to hold the object in any rotation. This function can
  /// be used, for example, to calculate the max size of a UI element meant to
  /// hold this shape in any rotation.
  Rect calculateMaxBounds() {
    var maxDistSquared = 0.0;
    for (var i = 0; i < cubics.length; i++) {
      final CubicBezier cubic = cubics[i];
      final double anchorDistance = distanceSquared(
        cubic.anchor0X - _center.x,
        cubic.anchor0Y - _center.y,
      );
      final Point middlePoint = cubic.pointOnCurve(0.5);
      final double middleDistance = distanceSquared(
        middlePoint.x - _center.x,
        middlePoint.y - _center.y,
      );
      maxDistSquared = math.max(maxDistSquared, math.max(anchorDistance, middleDistance));
    }

    final double distance = math.sqrt(maxDistSquared);

    return Rect.fromLTRB(
      _center.x - distance,
      _center.y - distance,
      _center.x + distance,
      _center.y + distance,
    );
  }

  /// Calculates the axis-aligned bounds of the object.
  ///
  /// [approximate] when true, uses a faster calculation to create the bounding
  /// box based on the min/max values of all anchor and control points that
  /// make up the shape. Default value is true.
  Rect calculateBounds({bool approximate = true}) {
    Rect bounds = cubics.first.calculateBounds(approximate: approximate);

    for (var i = 1; i < cubics.length; i++) {
      bounds = bounds.expandToInclude(cubics[i].calculateBounds(approximate: approximate));
    }

    return bounds;
  }

  /// Returns a [Path] representation for a [RoundedPolygon] shape.
  ///
  /// [startAngle] places the start point of the polygon's first curve at that
  /// angle, in radians, around the polygon's [center], rotating the polygon
  /// about that center to get it there. Zero is to the right of the center and
  /// `pi / 2` below it, since y grows downwards.
  /// The default of zero is special: it skips the rotation entirely and leaves
  /// the polygon as it was built.
  ///
  /// [repeatPath] is whether or not to repeat the [Path] twice before closing
  /// it. This flag is useful when the caller would like to draw parts of the
  /// path while offsetting the start and stop positions (for example, when
  /// phasing and rotating a path to simulate a motion as a Star circular
  /// progress indicator advances).
  ///
  /// [closePath] is whether or not to close the created [Path].
  Path toPath({double startAngle = 0, bool repeatPath = false, bool closePath = true}) {
    return pathFromCubics(
      cubics,
      startAngle: startAngle,
      repeatPath: repeatPath,
      closePath: closePath,
      rotationPivot: _center,
    );
  }

  @override
  String toString() {
    return '[RoundedPolygon. '
        'Cubics = ${cubics.join(", ")}'
        ' || Features = ${features.join(", ")}'
        ' || Center = (${_center.x}, ${_center.y})]';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    if (other is! RoundedPolygon) {
      return false;
    }

    if (features.length != other.features.length) {
      return false;
    }

    for (var index = 0; index < features.length; index += 1) {
      if (features[index] != other.features[index]) {
        return false;
      }
    }

    return true;
  }

  @override
  int get hashCode => Object.hashAll(features);
}

/// Calculates an estimated center position for the polygon, returning it. This
/// function should only be called if the center is not already calculated or
/// provided. The Polygon constructor which takes `numVertices` calculates its
/// own center, since it knows exactly where it is centered, at (0, 0).
///
/// Note that this center will be transformed whenever the shape itself is
/// transformed. Any transforms that occur before the center is calculated will
/// be taken into account automatically since the center calculation is an
/// average of the current location of all cubic anchor points.
@internal
Point calculateCenter(List<Point> vertices) {
  var cumulativeX = 0.0;
  var cumulativeY = 0.0;
  for (final vertex in vertices) {
    cumulativeX += vertex.x;
    cumulativeY += vertex.y;
  }
  return Point(cumulativeX / vertices.length, cumulativeY / vertices.length);
}

/// Private utility class that holds the information about each corner in a
/// polygon. The shape of the corner can be returned by calling the [getCubics]
/// function, which will return a list of curves representing the corner
/// geometry. The shape of the corner depends on the [rounding] constructor
/// parameter.
///
/// If rounding is null, there is no rounding; the corner will simply be a
/// single point at [p1]. This point will be represented by a [CubicBezier] of length
/// 0 at that point.
///
/// If rounding is not null, the corner will be rounded either with a curve
/// approximating a circular arc of the radius specified in [rounding], or with
/// three curves if [rounding] has a nonzero smoothing parameter. These three
/// curves are a circular arc in the middle and two symmetrical flanking curves
/// on either side. The smoothing parameter determines the curvature of the
/// flanking curves.
///
/// This is a class because we usually need to do the work in 2 steps, and
/// prefer to keep state between: first we determine how much we want to cut to
/// comply with the parameters, then we are given how much we can actually cut
/// (because of space restrictions outside this corner)
///
/// [p0] is the vertex before the one being rounded.
///
/// [p1] is the vertex of this rounded corner.
///
/// [p2] the vertex after the one being rounded.
///
/// [rounding] the optional parameters specifying how this corner should be
/// rounded.
class _RoundedCorner {
  _RoundedCorner(this.p0, this.p1, this.p2, this.rounding) {
    final Point v01 = p0 - p1;
    final Point v21 = p2 - p1;
    final double d01 = v01.getDistance();
    final double d21 = v21.getDistance();

    if (d01 > 0 && d21 > 0) {
      d1 = v01 / d01;
      d2 = v21 / d21;
      cornerRadius = rounding?.radius ?? 0;
      smoothing = rounding?.smoothing ?? 0;

      // cosine of angle at p1 is dot product of unit vectors to the other
      // two vertices.
      cosAngle = d1.dotProduct(d2);

      // identity: sin^2 + cos^2 = 1
      // sinAngle gives us the intersection
      sinAngle = math.sqrt(1 - square(cosAngle));

      // How much we need to cut, as measured on a side, to get the required
      // radius calculating where the rounding circle hits the edge.
      // This uses the identity of tan(A/2) = sinA/(1 + cosA), where
      // tan(A/2) = radius/cut.
      expectedRoundCut = (sinAngle > 1e-3) ? cornerRadius * (cosAngle + 1) / sinAngle : 0;
    } else {
      // One (or both) of the sides is empty, not much we can do.
      d1 = Point.zero;
      d2 = Point.zero;
      cornerRadius = 0;
      smoothing = 0;
      cosAngle = 0;
      sinAngle = 0;
      expectedRoundCut = 0;
    }
  }

  final Point p0;

  final Point p1;

  final Point p2;

  final CornerRounding? rounding;

  late final Point d1;

  late final Point d2;

  late final double cornerRadius;

  late final double smoothing;

  late final double cosAngle;

  late final double sinAngle;

  late final double expectedRoundCut;

  // Smoothing changes the actual cut. 0 is same as expectedRoundCut, 1
  // doubles it.
  double get expectedCut => (1 + smoothing) * expectedRoundCut;

  /// The center of the circle approximated by the rounding curve (or the
  /// middle of the three curves if smoothing is requested).
  /// The center is the same as [p0] if there is no rounding.
  Point center = Point.zero;

  List<CubicBezier> getCubics(double allowedCut0, double allowedCut1) {
    // We use the minimum of both cuts to determine the radius, but if there is
    // more space in one side we can use it for smoothing.
    final double allowedCut = math.min(allowedCut0, allowedCut1);

    // Nothing to do, just use lines, or a point
    if (expectedRoundCut < distanceEpsilon ||
        allowedCut < distanceEpsilon ||
        cornerRadius < distanceEpsilon) {
      center = p1;
      return [CubicBezier.straightLine(p1, p1)];
    }

    // How much of the cut is required for the rounding part.
    final double actualRoundCut = math.min(allowedCut, expectedRoundCut);

    // We have two smoothing values, one for each side of the vertex
    // Space is used for rounding values first. If there is space left over,
    // then we apply smoothing, if it was requested
    final double actualSmoothing0 = _calculateActualSmoothingValue(allowedCut0);
    final double actualSmoothing1 = _calculateActualSmoothingValue(allowedCut1);
    // Scale the radius if needed
    final double actualR = cornerRadius * actualRoundCut / expectedRoundCut;
    // Distance from the corner (p1) to the center
    final double centerDistance = math.sqrt(square(actualR) + square(actualRoundCut));
    // Center of the arc we will use for rounding
    center = p1 + ((d1 + d2) / 2).getDirection() * centerDistance;
    final Point circleIntersection0 = p1 + d1 * actualRoundCut;
    final Point circleIntersection2 = p1 + d2 * actualRoundCut;
    final CubicBezier flanking0 = _computeFlankingCurve(
      actualRoundCut,
      actualSmoothing0,
      p1,
      p0,
      circleIntersection0,
      circleIntersection2,
      center,
      actualR,
    );
    final CubicBezier flanking2 = _computeFlankingCurve(
      actualRoundCut,
      actualSmoothing1,
      p1,
      p2,
      circleIntersection2,
      circleIntersection0,
      center,
      actualR,
    ).reverse();

    return [
      flanking0,
      CubicBezier.circularArc(center, flanking0.anchor1, flanking2.anchor0),
      flanking2,
    ];
  }

  /// If [allowedCut] (the amount we are able to cut) is greater than the
  /// expected cut (without smoothing applied yet), then there is room to apply
  /// smoothing and we calculate the actual smoothing value here.
  double _calculateActualSmoothingValue(double allowedCut) {
    if (allowedCut > expectedCut) {
      return smoothing;
    } else if (allowedCut > expectedRoundCut) {
      return smoothing * (allowedCut - expectedRoundCut) / (expectedCut - expectedRoundCut);
    } else {
      return 0;
    }
  }

  /// Compute a Bezier to connect the linear segment defined by [corner] and
  /// [sideStart] with the circular segment defined by [circleCenter],
  /// [circleSegmentIntersection], [otherCircleSegmentIntersection] and
  /// [actualR]. The bezier will start at the linear segment and end on the
  /// circular segment.
  ///
  /// [actualRoundCut] is how much we are cutting of the corner to add the
  /// circular segment (this is before smoothing, that will cut some more).
  ///
  /// [actualSmoothingValues] is how much we want to smooth (this is the smooth
  /// parameter, adjusted down if there is not enough room).
  ///
  /// [corner] is the point at which the linear side ends.
  ///
  /// [sideStart] is the point at which the linear side starts.
  ///
  /// [circleSegmentIntersection] is the point at which the linear side and the
  /// circle intersect.
  ///
  /// [otherCircleSegmentIntersection] is the point at which the opposing
  /// linear side and the circle intersect.
  ///
  /// [circleCenter] is the center of the circle.
  ///
  /// [actualR] is the radius of the circle.
  ///
  /// Returns a Bezier cubic curve that connects from the (cut) linear side
  /// and the (cut) circular segment in a smooth way.
  CubicBezier _computeFlankingCurve(
    double actualRoundCut,
    double actualSmoothingValues,
    Point corner,
    Point sideStart,
    Point circleSegmentIntersection,
    Point otherCircleSegmentIntersection,
    Point circleCenter,
    double actualR,
  ) {
    // sideStart is the anchor, 'anchor' is actual control point
    final Point sideDirection = (sideStart - corner).getDirection();
    final Point curveStart = corner + sideDirection * actualRoundCut * (1 + actualSmoothingValues);

    // We use an approximation to cut a part of the circle section proportional
    // to 1 - smooth, When smooth = 0, we take the full section, when
    // smooth = 1, we take nothing.
    final Point p = interpolate(
      circleSegmentIntersection,
      (circleSegmentIntersection + otherCircleSegmentIntersection) / 2,
      actualSmoothingValues,
    );

    // The flanking curve ends on the circle
    final Point curveEnd =
        circleCenter + directionVector(p.x - circleCenter.x, p.y - circleCenter.y) * actualR;

    // The anchor on the circle segment side is in the intersection between the
    // tangent to the circle in the circle/flanking curve boundary and the
    // linear segment.
    final Point circleTangent = (curveEnd - circleCenter).rotate90();
    final Point anchorEnd =
        _lineIntersection(sideStart, sideDirection, curveEnd, circleTangent) ??
        circleSegmentIntersection;

    // From what remains, we pick a point for the start anchor.
    // 2/3 seems to come from design tools?
    final Point anchorStart = (curveStart + anchorEnd * 2) / 3;

    return CubicBezier(curveStart, anchorStart, anchorEnd, curveEnd);
  }

  /// Returns the intersection point of the two lines d0->d1 and p0->p1, or
  /// null if the lines do not intersect.
  Point? _lineIntersection(Point p0, Point d0, Point p1, Point d1) {
    final Point rotatedD1 = d1.rotate90();
    final double den = d0.dotProduct(rotatedD1);

    if (den.abs() < distanceEpsilon) {
      return null;
    }

    final double num = (p1 - p0).dotProduct(rotatedD1);

    // Also check the relative value. This is equivalent to
    // (den/num).abs() < distanceEpsilon, but avoid doing a division
    if (den.abs() < distanceEpsilon * num.abs()) {
      return null;
    }

    final double k = num / den;
    return p0 + d0 * k;
  }
}

List<Point> _verticesFromNumVerts(int numVertices, double radius, Point center) {
  return List<Point>.generate(
    numVertices,
    (i) => radialToCartesian(radius, math.pi / numVertices * 2 * i) + center,
  );
}

List<Point> _pillStarVerticesFromNumVerts(
  int numVerticesPerRadius,
  double width,
  double height,
  double innerRadius,
  double vertexSpacing,
  double startLocation,
  Point center,
) {
  // The general approach here is to get the perimeter of the underlying pill
  // outline, then the t value for each vertex as we walk that perimeter. This
  // tells us where on the outline to place that vertex, then we figure out
  // where to place the vertex depending on which "section" it is in. The
  // possible sections are the vertical edges on the sides, the circular
  // sections on all four corners, or the horizontal edges on the top and
  // bottom. Note that either the vertical or horizontal edges will be of
  // length zero (whichever dimension is smaller gets only circular curvature
  // for the pill shape).
  final double endcapRadius = math.min(width, height);
  final double vSegLen = math.max(height - width, 0.0);
  final double hSegLen = math.max(width - height, 0.0);
  final double vSegHalf = vSegLen / 2;
  final double hSegHalf = hSegLen / 2;
  // vertexSpacing is used to position the vertices on the end caps. The caller
  // has the choice of spacing the inner (0) or outer (1) vertices like those
  // along the edges, causing the other vertices to be either further apart (0)
  // or closer (1). The default is .5, which averages things. The magnitude of
  // the inner and rounding parameters may cause the caller to want a different
  // value.
  final double circlePerimeter = twoPi * endcapRadius * lerp(innerRadius, 1, vertexSpacing);
  // perimeter is circle perimeter plus horizontal and vertical sections of
  // inner rectangle, whether either (or even both) might be of length zero.
  final double perimeter = 2 * hSegLen + 2 * vSegLen + circlePerimeter;

  // The sections array holds the t start values of that part of the outline.
  // We use these to determine which section a given vertex lies in, based on
  // it's t value, as well as where in that section it lies.
  final sections = List<double>.filled(11, 0);
  sections[0] = 0;
  sections[1] = vSegLen / 2;
  sections[2] = sections[1] + circlePerimeter / 4;
  sections[3] = sections[2] + hSegLen;
  sections[4] = sections[3] + circlePerimeter / 4;
  sections[5] = sections[4] + vSegLen;
  sections[6] = sections[5] + circlePerimeter / 4;
  sections[7] = sections[6] + hSegLen;
  sections[8] = sections[7] + circlePerimeter / 4;
  sections[9] = sections[8] + vSegLen / 2;
  sections[10] = perimeter;

  // "t" is the length along the entire pill outline for a given vertex. With
  // vertices spaced evenly along this contour, we can determine for any vertex
  // where it should lie.
  final double tPerVertex = perimeter / (2 * numVerticesPerRadius);
  // separate iteration for inner vs outer, unlike the other shapes, because
  // the vertices can lie in different quadrants so each needs their own
  // calculation.
  var inner = false;
  // Increment section index as we walk around the pill contour with our
  // increasing t values.
  var currSecIndex = 0;
  // secStart/End are used to determine how far along a given vertex is in the
  // section in which it lands.
  var secStart = 0.0;
  double secEnd = sections[1];
  // t value is used to place each vertex. 0 is on the positive x axis,
  // moving into section 0 to begin with. startLocation, a value from 0 to 1,
  // varies the location anywhere on the perimeter of the shape.
  double t = startLocation * perimeter;
  // The list of vertices to be returned.
  final result = List<Point>.filled(numVerticesPerRadius * 2, Point.zero);
  final rectBR = Point(hSegHalf, vSegHalf);
  final rectBL = Point(-hSegHalf, vSegHalf);
  final rectTL = Point(-hSegHalf, -vSegHalf);
  final rectTR = Point(hSegHalf, -vSegHalf);

  // Each iteration through this loop uses the next t value as we walk around
  // the shape.
  for (var i = 0; i < numVerticesPerRadius * 2; i++) {
    // t could start (and end) after 0; extra boundedT logic makes sure it does
    // the right thing when crossing the boundary past 0 again.
    final double boundedT = t % perimeter;
    if (boundedT < secStart) {
      currSecIndex = 0;
    }
    while (boundedT >= sections[(currSecIndex + 1) % sections.length]) {
      currSecIndex = (currSecIndex + 1) % sections.length;
      secStart = sections[currSecIndex];
      secEnd = sections[(currSecIndex + 1) % sections.length];
    }

    // find t in section and its proportion of that section's total length
    final double tInSection = boundedT - secStart;
    final double tProportion = tInSection / (secEnd - secStart);

    // The vertex placement in a section varies depending on whether it is on
    // one of the semicircle endcaps or along one of the straight edges. For
    // the endcaps, we use tProportion to get the angle along that circular cap
    // and add the starting angle for that section. For the edges we use a
    // straight linear calculation given tProportion and the start/end t values
    // for that edge.
    final double currRadius = inner ? (endcapRadius * innerRadius) : endcapRadius;
    final Point vertex = switch (currSecIndex) {
      0 => Point(currRadius, tProportion * vSegHalf),
      1 => radialToCartesian(currRadius, tProportion * math.pi / 2) + rectBR,
      2 => Point(hSegHalf - tProportion * hSegLen, currRadius),
      3 => radialToCartesian(currRadius, math.pi / 2 + (tProportion * math.pi / 2)) + rectBL,
      4 => Point(-currRadius, vSegHalf - tProportion * vSegLen),
      5 => radialToCartesian(currRadius, math.pi + (tProportion * math.pi / 2)) + rectTL,
      6 => Point(-hSegHalf + tProportion * hSegLen, -currRadius),
      7 => radialToCartesian(currRadius, math.pi * 1.5 + (tProportion * math.pi / 2)) + rectTR,
      // 8
      _ => Point(currRadius, -vSegHalf + tProportion * vSegHalf),
    };
    result[i] = vertex + center;
    t += tPerVertex;
    inner = !inner;
  }

  return result;
}

List<Point> _starVerticesFromNumVerts(
  int numVerticesPerRadius,
  double radius,
  double innerRadius,
  Point center,
) {
  final result = List<Point>.filled(numVerticesPerRadius * 2, Point.zero);
  var arrayIndex = 0;

  for (var i = 0; i < numVerticesPerRadius; i++) {
    result[arrayIndex++] =
        radialToCartesian(radius, math.pi / numVerticesPerRadius * 2 * i) + center;
    result[arrayIndex++] =
        radialToCartesian(innerRadius, math.pi / numVerticesPerRadius * (2 * i + 1)) + center;
  }

  return result;
}
