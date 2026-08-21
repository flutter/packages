part of 'shapes.dart';

/// The RoundedPolygon class allows simple construction of polygonal shapes
/// with optional rounding at the vertices. Polygons can be constructed with
/// either the number of vertices desired or an ordered list of vertices.
@immutable
class RoundedPolygon {
  RoundedPolygon._(
    this.features,
    this.center,
  ) : cubics = <Cubic>[] {
    _initCubics();

    assert(() {
      var prevCubic = cubics[cubics.length - 1];

      for (var index = 0; index < cubics.length; index++) {
        final cubic = cubics[index];

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
  /// [centerX] is the X coordinate of the center of the polygon, around which
  /// all vertices will be placed. The default center is at (0,0).
  ///
  /// [centerY] is the Y coordinate of the center of the polygon, around which
  /// all vertices will be placed. The default center is at (0,0).
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
    double centerX = 0,
    double centerY = 0,
    CornerRounding rounding = CornerRounding.unrounded,
    List<CornerRounding>? perVertexRounding,
  }) {
    if (numVertices < 3) {
      throw ArgumentError('numVertices must be at least 3.');
    }

    return RoundedPolygon.fromVertices(
      _verticesFromNumVerts(numVertices, radius, centerX, centerY),
      rounding: rounding,
      perVertexRounding: perVertexRounding,
      centerX: centerX,
      centerY: centerY,
    );
  }

  /// Creates a copy of the given [RoundedPolygon].
  RoundedPolygon.from(RoundedPolygon roundedPolygon)
      : this._(roundedPolygon.features, roundedPolygon.center);

  /// This function takes the vertices (either supplied or calculated,
  /// depending on the constructor called), plus [CornerRounding] parameters,
  /// and creates the actual [RoundedPolygon] shape, rounding around the
  /// vertices (or not) as specified. The result is a list of [Cubic] curves
  /// which represent the geometry of the final shape.
  ///
  /// [vertices] is the list of vertices in this polygon specified as pairs of
  /// x/y coordinates in this `List<double>`. This should be an ordered list
  /// (with the outline of the shape going from each vertex to the next in
  /// order of this list), otherwise the results will be undefined.
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
  /// [centerX] is the X coordinate of the center of the polygon, around which
  /// all vertices will be placed. The default center is at (0,0).
  ///
  /// [centerY] is the Y coordinate of the center of the polygon, around which
  /// all vertices will be placed. The default center is at (0,0).
  ///
  /// Throws [ArgumentError] if the number of vertices is less than 3 (the
  /// [vertices] parameter has less than 6 Floats). Or if the
  /// [perVertexRounding] parameter is not null and the size doesn't match the
  /// number vertices.
  ///
  // TODO(performance): Update the map calls to more efficient code that
  // doesn't allocate Iterators unnecessarily.
  factory RoundedPolygon.fromVertices(
    List<double> vertices, {
    CornerRounding rounding = CornerRounding.unrounded,
    List<CornerRounding>? perVertexRounding,
    double centerX = double.minPositive,
    double centerY = double.minPositive,
  }) {
    if (vertices.length < 6) {
      throw ArgumentError('Polygons must have at least 3 vertices.');
    }
    if (vertices.length.isOdd) {
      throw ArgumentError('The vertices array should have even size.');
    }
    if (perVertexRounding != null &&
        perVertexRounding.length * 2 != vertices.length) {
      throw ArgumentError('perVertexRounding list should be either null or '
          'the same size as the number of vertices (vertices.size / 2).');
    }
    final corners = <List<Cubic>>[];
    final n = vertices.length ~/ 2;
    final roundedCorners = <_RoundedCorner>[];
    for (var i = 0; i < n; i++) {
      final vtxRounding = perVertexRounding?[i] ?? rounding;
      final prevIndex = ((i + n - 1) % n) * 2;
      final nextIndex = ((i + 1) % n) * 2;
      roundedCorners.add(
        _RoundedCorner(
          Point(vertices[prevIndex], vertices[prevIndex + 1]),
          Point(vertices[i * 2], vertices[i * 2 + 1]),
          Point(vertices[nextIndex], vertices[nextIndex + 1]),
          vtxRounding,
        ),
      );
    }

    // For each side, check if we have enough space to do the cuts needed, and
    // if not split the available space, first for round cuts, then for
    // smoothing if there is space left. Each element in this list is a pair,
    // that represent how much we can do of the cut for the given side (side i
    // goes from corner i to corner i+1), the elements of the pair are: first
    // is how much we can use of expectedRoundCut, second how much of
    // expectedCut.
    final cutAdjusts = List.generate(n, (ix) {
      final expectedRoundCut = roundedCorners[ix].expectedRoundCut +
          roundedCorners[(ix + 1) % n].expectedRoundCut;
      final expectedCut = roundedCorners[ix].expectedCut +
          roundedCorners[(ix + 1) % n].expectedCut;
      final vtxX = vertices[ix * 2];
      final vtxY = vertices[ix * 2 + 1];
      final nextVtxX = vertices[((ix + 1) % n) * 2];
      final nextVtxY = vertices[((ix + 1) % n) * 2 + 1];
      final sideSize = distance(vtxX - nextVtxX, vtxY - nextVtxY);

      // Check expectedRoundCut first, and ensure we fulfill rounding needs
      // first for both corners before using space for smoothing.
      if (expectedRoundCut > sideSize) {
        // Not enough room for fully rounding, see how much we can actually do.
        return (sideSize / expectedRoundCut, 0);
      } else if (expectedCut > sideSize) {
        // We can do full rounding, but not full smoothing.
        return (
          1,
          (sideSize - expectedRoundCut) / (expectedCut - expectedRoundCut)
        );
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
        final (roundCutRatio, cutRatio) = cutAdjusts[(i + n - 1 + delta) % n];
        allowedCuts[delta] =
            roundedCorners[i].expectedRoundCut * roundCutRatio +
                (roundedCorners[i].expectedCut -
                        roundedCorners[i].expectedRoundCut) *
                    cutRatio;
      }

      corners.add(
        roundedCorners[i].getCubics(allowedCuts[0], allowedCuts[1]),
      );
    }

    // Finally, store the calculated cubics. This includes all of the rounded
    // corners from above, along with new cubics representing the edges between
    // those corners.
    final tempFeatures = <Feature>[];
    for (var i = 0; i < n; i++) {
      // Note that these indices are for pairs of values (points), they need to
      // be doubled to access the xy values in the vertices float array.
      final prevVtxIndex = (i + n - 1) % n;
      final nextVtxIndex = (i + 1) % n;
      final currVertex = Point(vertices[i * 2], vertices[i * 2 + 1]);
      final prevVertex = Point(
        vertices[prevVtxIndex * 2],
        vertices[prevVtxIndex * 2 + 1],
      );
      final nextVertex = Point(
        vertices[nextVtxIndex * 2],
        vertices[nextVtxIndex * 2 + 1],
      );
      final cvx = convex(prevVertex, currVertex, nextVertex);
      tempFeatures
        ..add(CornerFeature(corners[i], convex: cvx))
        ..add(
          EdgeFeature(
            [
              Cubic.straightLine(
                corners[i].last.anchor1X,
                corners[i].last.anchor1Y,
                corners[(i + 1) % n].first.anchor0X,
                corners[(i + 1) % n].first.anchor0Y,
              ),
            ],
          ),
        );
    }

    final double cX;
    final double cY;

    if (centerX == double.minPositive || centerY == double.minPositive) {
      final center = calculateCenter(vertices);
      cX = center.x;
      cY = center.y;
    } else {
      cX = centerX;
      cY = centerY;
    }

    return RoundedPolygon.fromFeatures(tempFeatures, centerX: cX, centerY: cY);
  }

  /// Takes a list of [Feature] objects that define the polygon's shape and
  /// curves. By specifying the features directly, the summarization of [Cubic]
  /// objects to curves can be precisely controlled. This affects [Morph]'s
  /// default mapping, as curves with the same type (convex or concave) are
  /// mapped with each other. For example, if you have a convex curve in your
  /// start polygon, [Morph] will map it to another convex curve in the end
  /// polygon.
  ///
  /// The [centerX] and [centerY] parameters are optional. If not supplied,
  /// they will be estimated by calculating the average of all cubic anchor
  /// points.
  ///
  /// [features] are the [Feature]s that describe the characteristics of each
  /// outline segment of the polygon.
  ///
  /// [centerX] is the X coordinate of the center of the polygon, around which
  /// all vertices will be placed. If none provided, the center will be
  /// averaged.
  ///
  /// [centerY] is the Y coordinate of the center of the polygon, around which
  /// all vertices will be placed. If none provided, the center will be
  /// averaged.
  ///
  /// Throws [ArgumentError] if [features] length is less than 2 or if they
  /// don't describe a closed shape.
  @internal
  factory RoundedPolygon.fromFeatures(
    List<Feature> features, {
    double centerX = double.nan,
    double centerY = double.nan,
  }) {
    if (features.length < 2) {
      throw ArgumentError('Polygons must have at least 2 features.');
    }

    if (centerX.isNaN || centerY.isNaN) {
      final vertices = <double>[];

      for (final feature in features) {
        for (final cubic in feature.cubics) {
          vertices
            ..add(cubic.anchor0X)
            ..add(cubic.anchor0Y);
        }
      }

      final center = calculateCenter(vertices);

      final cX = centerX.isNaN ? center.x : centerX;
      final cY = centerY.isNaN ? center.y : centerY;

      return RoundedPolygon._(features, Point(cX, cY));
    }

    return RoundedPolygon._(features, Point(centerX, centerY));
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
  /// [centerX] is the X coordinate of optional center for the circle, default
  /// value is 0.
  ///
  /// [centerY] is the Y coordinate of optional center for the circle, default
  /// value is 0.
  ///
  /// Throws [ArgumentError] when [numVertices] is less than 3.
  factory RoundedPolygon.circle({
    int numVertices = 8,
    double radius = 1,
    double centerX = 0,
    double centerY = 0,
  }) {
    if (numVertices < 3) {
      throw ArgumentError('Circle must have at least three vertices.');
    }

    // Half of the angle between two adjacent vertices on the polygon.
    final theta = math.pi / numVertices;
    // Radius of the underlying RoundedPolygon object given the desired radius
    // of the circle.
    final polygonRadius = radius / math.cos(theta);
    return RoundedPolygon.fromVerticesNum(
      numVertices,
      radius: polygonRadius,
      centerX: centerX,
      centerY: centerY,
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
  /// [centerX] is the X coordinate of the center of the rectangle, around which
  /// all vertices will be placed equidistantly. The default center is at (0,0).
  ///
  /// [centerY] is the Y coordinate of the center of the rectangle, around
  /// which all vertices will be placed equidistantly. The default center is
  /// at (0,0).
  factory RoundedPolygon.rectangle({
    double width = 2,
    double height = 2,
    CornerRounding rounding = CornerRounding.unrounded,
    List<CornerRounding>? perVertexRounding,
    double centerX = 0,
    double centerY = 0,
  }) {
    final left = centerX - width / 2;
    final top = centerY - height / 2;
    final right = centerX + width / 2;
    final bottom = centerY + height / 2;

    return RoundedPolygon.fromVertices(
      [right, bottom, left, bottom, left, top, right, top],
      rounding: rounding,
      perVertexRounding: perVertexRounding,
      centerX: centerX,
      centerY: centerY,
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
  /// [centerX] is the X coordinate of the center of the polygon, around which
  /// all vertices will be placed. The default center is at (0,0).
  ///
  /// [centerY] is the Y coordinate of the center of the polygon, around which
  /// all vertices will be placed. The default center is at (0,0).
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
    double centerX = 0,
    double centerY = 0,
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
        for (var i = 0; i < numVerticesPerRadius; i++) ...[
          rounding,
          innerRounding,
        ],
      ];
    }

    // Star polygon is just a polygon with all vertices supplied (where we
    // generate those vertices to be on the inner/outer radii).
    return RoundedPolygon.fromVertices(
      _starVerticesFromNumVerts(
        numVerticesPerRadius,
        radius,
        innerRadius,
        centerX,
        centerY,
      ),
      rounding: rounding,
      perVertexRounding: pvRounding,
      centerX: centerX,
      centerY: centerY,
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
  /// [centerX] is the X coordinate of the center of the polygon, around which
  /// all vertices will be placed. The default center is at (0,0).
  ///
  /// [centerY] is the Y coordinate of the center of the polygon, around which
  /// all vertices will be placed. The default center is at (0,0).
  ///
  /// Throws [ArgumentError] if either [width] or [height] are <= 0.
  factory RoundedPolygon.pill({
    double width = 2,
    double height = 1,
    double smoothing = 0,
    double centerX = 0,
    double centerY = 0,
  }) {
    if (width <= 0 || height <= 0) {
      throw ArgumentError('Pill shapes must have positive width and height.');
    }

    final wHalf = width / 2;
    final hHalf = height / 2;

    return RoundedPolygon.fromVertices(
      [
        wHalf + centerX,
        hHalf + centerY,
        -wHalf + centerX,
        hHalf + centerY,
        -wHalf + centerX,
        -hHalf + centerY,
        wHalf + centerX,
        -hHalf + centerY,
      ],
      rounding: CornerRounding(
        radius: math.min(wHalf, hHalf),
        smoothing: smoothing,
      ),
      centerX: centerX,
      centerY: centerY,
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
  /// [centerX] is the X coordinate of the center of the polygon, around which
  /// all vertices will be placed. The default center is at (0,0).
  ///
  /// [centerY] is the Y coordinate of the center of the polygon, around which
  /// all vertices will be placed. The default center is at (0,0).
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
    double centerX = 0,
    double centerY = 0,
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
        for (var i = 0; i < numVerticesPerRadius; i++) ...[
          rounding,
          innerRounding,
        ],
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
        centerX,
        centerY,
      ),
      rounding: rounding,
      perVertexRounding: pvRounding,
      centerX: centerX,
      centerY: centerY,
    );
  }

  final List<Feature> features;

  final Point center;

  /// A flattened version of the [Feature]s, as a `List<Cubic>`.
  final List<Cubic> cubics;

  double get centerX => center.x;

  double get centerY => center.y;

  void _initCubics() {
    // The first/last mechanism here ensures that the final anchor point in the
    // shape exactly matches the first anchor point. There can be rendering
    // artifacts introduced by those points being slightly off, even by much
    // less than a pixel.
    Cubic? firstCubic;
    Cubic? lastCubic;
    List<Cubic>? firstFeatureSplitStart;
    List<Cubic>? firstFeatureSplitEnd;

    if (features.isNotEmpty && features[0].cubics.length == 3) {
      final centerCubic = features[0].cubics[1];
      final (start, end) = centerCubic.split(0.5);
      firstFeatureSplitStart = [features[0].cubics[0], start];
      firstFeatureSplitEnd = [end, features[0].cubics[2]];
    }

    // iterating one past the features list size allows us to insert the
    // initial split cubic if it exists.
    for (var i = 0; i <= features.length; i++) {
      final List<Cubic> featureCubics;

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
        final cubic = featureCubics[j];

        if (!cubic.zeroLength()) {
          if (lastCubic != null) cubics.add(lastCubic);
          lastCubic = cubic;
          firstCubic ??= cubic;
        } else {
          if (lastCubic != null) {
            // Dropping several zero-ish length curves in a row can lead to
            // enough discontinuity to throw an exception later, even though the
            // distances are quite small. Account for that by making the last
            // cubic use the latest anchor point, always.
            final points = lastCubic.points.toList();
            points[6] = cubic.anchor1X;
            points[7] = cubic.anchor1Y;
            lastCubic = Cubic._raw(points);
          }
        }
      }
    }

    if (lastCubic != null && firstCubic != null) {
      cubics.add(
        Cubic(
          lastCubic.anchor0X,
          lastCubic.anchor0Y,
          lastCubic.control0X,
          lastCubic.control0Y,
          lastCubic.control1X,
          lastCubic.control1Y,
          firstCubic.anchor0X,
          firstCubic.anchor0Y,
        ),
      );
    } else {
      // Empty / 0-sized polygon.
      cubics.add(
        Cubic(
          centerX,
          centerY,
          centerX,
          centerY,
          centerX,
          centerY,
          centerX,
          centerY,
        ),
      );
    }
  }

  /// Transforms (scales/translates/etc.) this [RoundedPolygon] with the given
  /// [PointTransformer] and returns a new [RoundedPolygon]. This is a low
  /// level API and there should be more platform idiomatic ways to transform
  /// a [RoundedPolygon] provided by the platform specific wrapper.
  ///
  /// [f] is the [PointTransformer] used to transform this [RoundedPolygon].
  RoundedPolygon transformed(PointTransformer f) {
    final center = this.center.transformed(f);
    return RoundedPolygon._(
      [
        for (var i = 0; i < features.length; i++) features[i].transformed(f),
      ],
      center,
    );
  }

  /// Creates a new RoundedPolygon, moving and resizing this one, so it's
  /// completely inside the (0, 0) -> (1, 1) square, centered if there extra
  /// space in one direction.
  RoundedPolygon normalized() {
    final bounds = calculateBounds();
    final width = bounds[2] - bounds[0];
    final height = bounds[3] - bounds[1];
    final side = math.max(width, height);

    // Center the shape if bounds are not a square.
    final offsetX = (side - width) / 2 - bounds[0]; /* left */
    final offsetY = (side - height) / 2 - bounds[1]; /* top */

    return transformed(
      (x, y) => ((x + offsetX) / side, (y + offsetY) / side),
    );
  }

  /// Like [calculateBounds], this function calculates the axis-aligned bounds
  /// of the object and returns that rectangle. But this function determines
  /// the max dimension of the shape (by calculating the distance from its
  /// center to the start and midpoint of each curve) and returns a square
  /// which can be used to hold the object in any rotation. This function can
  /// be used, for example, to calculate the max size of a UI element meant to
  /// hold this shape in any rotation.
  ///
  /// [bounds] is a buffer to hold the results. If not supplied, a temporary
  /// buffer will be created.
  ///
  /// Returns the axis-aligned max bounding box for this object, where the
  /// rectangles left, top, right, and bottom values will be stored in entries
  /// 0, 1, 2, and 3, in that order.
  List<double> calculateMaxBounds([List<double>? bounds]) {
    bounds ??= List.filled(4, 0);

    if (bounds.length < 4) {
      throw ArgumentError('Required bounds size of 4.');
    }

    var maxDistSquared = 0.0;
    for (var i = 0; i < cubics.length; i++) {
      final cubic = cubics[i];
      final anchorDistance =
          distanceSquared(cubic.anchor0X - centerX, cubic.anchor0Y - centerY);
      final middlePoint = cubic.pointOnCurve(0.5);
      final middleDistance =
          distanceSquared(middlePoint.x - centerX, middlePoint.y - centerY);
      maxDistSquared =
          math.max(maxDistSquared, math.max(anchorDistance, middleDistance));
    }

    final distance = math.sqrt(maxDistSquared);

    bounds[0] = centerX - distance;
    bounds[1] = centerY - distance;
    bounds[2] = centerX + distance;
    bounds[3] = centerY + distance;

    return bounds;
  }

  /// Calculates the axis-aligned bounds of the object.
  ///
  /// [bounds] is a buffer to hold the results. If not supplied, a temporary
  /// buffer will be created.
  ///
  /// [approximate] when true, uses a faster calculation to create the bounding
  /// box based on the min/max values of all anchor and control points that
  /// make up the shape. Default value is true.
  ///
  /// Returns the axis-aligned bounding box for this object, where the
  /// rectangles left, top, right, and bottom values will be stored in entries
  /// 0, 1, 2, and 3, in that order.
  List<double> calculateBounds({
    List<double>? bounds,
    bool approximate = true,
  }) {
    bounds ??= List.filled(4, 0);

    if (bounds.length < 4) {
      throw ArgumentError('Required bounds size of 4.');
    }

    var minX = double.maxFinite;
    var minY = double.maxFinite;
    var maxX = double.minPositive;
    var maxY = double.minPositive;

    for (var i = 0; i < cubics.length; i++) {
      cubics[i].calculateBounds(bounds, approximate: approximate);
      minX = math.min(minX, bounds[0]);
      minY = math.min(minY, bounds[1]);
      maxX = math.max(maxX, bounds[2]);
      maxY = math.max(maxY, bounds[3]);
    }

    bounds[0] = minX;
    bounds[1] = minY;
    bounds[2] = maxX;
    bounds[3] = maxY;

    return bounds;
  }

  @override
  String toString() {
    return '[RoundedPolygon. '
        'Cubics = ${cubics.join(", ")}'
        ' || Features = ${features.join(", ")}'
        ' || Center = ($centerX, $centerY)]';
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
  int get hashCode => features.hashCode;
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
Point calculateCenter(List<double> vertices) {
  var cumulativeX = 0.0;
  var cumulativeY = 0.0;
  var index = 0;
  while (index < vertices.length) {
    cumulativeX += vertices[index++];
    cumulativeY += vertices[index++];
  }
  return Point(
    cumulativeX / (vertices.length / 2),
    cumulativeY / (vertices.length / 2),
  );
}

/// Private utility class that holds the information about each corner in a
/// polygon. The shape of the corner can be returned by calling the [getCubics]
/// function, which will return a list of curves representing the corner
/// geometry. The shape of the corner depends on the [rounding] constructor
/// parameter.
///
/// If rounding is null, there is no rounding; the corner will simply be a
/// single point at [p1]. This point will be represented by a [Cubic] of length
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
  _RoundedCorner(
    this.p0,
    this.p1,
    this.p2,
    this.rounding,
  ) {
    final v01 = p0 - p1;
    final v21 = p2 - p1;
    final d01 = v01.getDistance();
    final d21 = v21.getDistance();

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
      expectedRoundCut =
          (sinAngle > 1e-3) ? cornerRadius * (cosAngle + 1) / sinAngle : 0;
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

  List<Cubic> getCubics(double allowedCut0, double allowedCut1) {
    // We use the minimum of both cuts to determine the radius, but if there is
    // more space in one side we can use it for smoothing.
    final allowedCut = math.min(allowedCut0, allowedCut1);

    // Nothing to do, just use lines, or a point
    if (expectedRoundCut < distanceEpsilon ||
        allowedCut < distanceEpsilon ||
        cornerRadius < distanceEpsilon) {
      center = p1;
      return [Cubic.straightLine(p1.x, p1.y, p1.x, p1.y)];
    }

    // How much of the cut is required for the rounding part.
    final actualRoundCut = math.min(allowedCut, expectedRoundCut);

    // We have two smoothing values, one for each side of the vertex
    // Space is used for rounding values first. If there is space left over,
    // then we apply smoothing, if it was requested
    final actualSmoothing0 = _calculateActualSmoothingValue(allowedCut0);
    final actualSmoothing1 = _calculateActualSmoothingValue(allowedCut1);
    // Scale the radius if needed
    final actualR = cornerRadius * actualRoundCut / expectedRoundCut;
    // Distance from the corner (p1) to the center
    final centerDistance = math.sqrt(
      square(actualR) + square(actualRoundCut),
    );
    // Center of the arc we will use for rounding
    center = p1 + ((d1 + d2) / 2).getDirection() * centerDistance;
    final circleIntersection0 = p1 + d1 * actualRoundCut;
    final circleIntersection2 = p1 + d2 * actualRoundCut;
    final flanking0 = _computeFlankingCurve(
      actualRoundCut,
      actualSmoothing0,
      p1,
      p0,
      circleIntersection0,
      circleIntersection2,
      center,
      actualR,
    );
    final flanking2 = _computeFlankingCurve(
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
      Cubic.circularArc(
        center.x,
        center.y,
        flanking0.anchor1X,
        flanking0.anchor1Y,
        flanking2.anchor0X,
        flanking2.anchor0Y,
      ),
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
      return smoothing *
          (allowedCut - expectedRoundCut) /
          (expectedCut - expectedRoundCut);
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
  Cubic _computeFlankingCurve(
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
    final sideDirection = (sideStart - corner).getDirection();
    final curveStart =
        corner + sideDirection * actualRoundCut * (1 + actualSmoothingValues);

    // We use an approximation to cut a part of the circle section proportional
    // to 1 - smooth, When smooth = 0, we take the full section, when
    // smooth = 1, we take nothing.
    // TODO: revisit this, it can be problematic as it approaches 180 degrees
    final p = interpolate(
      circleSegmentIntersection,
      (circleSegmentIntersection + otherCircleSegmentIntersection) / 2,
      actualSmoothingValues,
    );

    // The flanking curve ends on the circle
    final curveEnd = circleCenter +
        directionVector(p.x - circleCenter.x, p.y - circleCenter.y) * actualR;

    // The anchor on the circle segment side is in the intersection between the
    // tangent to the circle in the circle/flanking curve boundary and the
    // linear segment.
    final circleTangent = (curveEnd - circleCenter).rotate90();
    final anchorEnd = _lineIntersection(
          sideStart,
          sideDirection,
          curveEnd,
          circleTangent,
        ) ??
        circleSegmentIntersection;

    // From what remains, we pick a point for the start anchor.
    // 2/3 seems to come from design tools?
    final anchorStart = (curveStart + anchorEnd * 2) / 3;

    return Cubic.fromPoints(curveStart, anchorStart, anchorEnd, curveEnd);
  }

  /// Returns the intersection point of the two lines d0->d1 and p0->p1, or
  /// null if the lines do not intersect.
  Point? _lineIntersection(Point p0, Point d0, Point p1, Point d1) {
    final rotatedD1 = d1.rotate90();
    final den = d0.dotProduct(rotatedD1);

    if (den.abs() < distanceEpsilon) {
      return null;
    }

    final num = (p1 - p0).dotProduct(rotatedD1);

    // Also check the relative value. This is equivalent to
    // (den/num).abs() < distanceEpsilon, but avoid doing a division
    if (den.abs() < distanceEpsilon * num.abs()) {
      return null;
    }

    final k = num / den;
    return p0 + d0 * k;
  }
}

List<double> _verticesFromNumVerts(
  int numVertices,
  double radius,
  double centerX,
  double centerY,
) {
  final result = List<double>.filled(numVertices * 2, 0);

  var arrayIndex = 0;
  for (var i = 0; i < numVertices; i++) {
    final vertex = radialToCartesian(
          radius,
          math.pi / numVertices * 2 * i,
        ) +
        Point(centerX, centerY);

    result[arrayIndex++] = vertex.x;
    result[arrayIndex++] = vertex.y;
  }

  return result;
}

List<double> _pillStarVerticesFromNumVerts(
  int numVerticesPerRadius,
  double width,
  double height,
  double innerRadius,
  double vertexSpacing,
  double startLocation,
  double centerX,
  double centerY,
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
  final endcapRadius = math.min(width, height);
  final vSegLen = (height - width).coerceAtLeast(0);
  final hSegLen = (width - height).coerceAtLeast(0);
  final vSegHalf = vSegLen / 2;
  final hSegHalf = hSegLen / 2;
  // vertexSpacing is used to position the vertices on the end caps. The caller
  // has the choice of spacing the inner (0) or outer (1) vertices like those
  // along the edges, causing the other vertices to be either further apart (0)
  // or closer (1). The default is .5, which averages things. The magnitude of
  // the inner and rounding parameters may cause the caller to want a different
  // value.
  final circlePerimeter =
      twoPi * endcapRadius * lerp(innerRadius, 1, vertexSpacing);
  // perimeter is circle perimeter plus horizontal and vertical sections of
  // inner rectangle, whether either (or even both) might be of length zero.
  final perimeter = 2 * hSegLen + 2 * vSegLen + circlePerimeter;

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
  final tPerVertex = perimeter / (2 * numVerticesPerRadius);
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
  var secEnd = sections[1];
  // t value is used to place each vertex. 0 is on the positive x axis,
  // moving into section 0 to begin with. startLocation, a value from 0 to 1,
  // varies the location anywhere on the perimeter of the shape.
  var t = startLocation * perimeter;
  // The list of vertices to be returned.
  final result = List<double>.filled(numVerticesPerRadius * 4, 0);
  var arrayIndex = 0;
  final rectBR = Point(hSegHalf, vSegHalf);
  final rectBL = Point(-hSegHalf, vSegHalf);
  final rectTL = Point(-hSegHalf, -vSegHalf);
  final rectTR = Point(hSegHalf, -vSegHalf);

  // Each iteration through this loop uses the next t value as we walk around
  // the shape.
  for (var i = 0; i < numVerticesPerRadius * 2; i++) {
    // t could start (and end) after 0; extra boundedT logic makes sure it does
    // the right thing when crossing the boundary past 0 again.
    final boundedT = t % perimeter;
    if (boundedT < secStart) currSecIndex = 0;
    while (boundedT >= sections[(currSecIndex + 1) % sections.length]) {
      currSecIndex = (currSecIndex + 1) % sections.length;
      secStart = sections[currSecIndex];
      secEnd = sections[(currSecIndex + 1) % sections.length];
    }

    // find t in section and its proportion of that section's total length
    final tInSection = boundedT - secStart;
    final tProportion = tInSection / (secEnd - secStart);

    // The vertex placement in a section varies depending on whether it is on
    // one of the semicircle endcaps or along one of the straight edges. For
    // the endcaps, we use tProportion to get the angle along that circular cap
    // and add the starting angle for that section. For the edges we use a
    // straight linear calculation given tProportion and the start/end t values
    // for that edge.
    final currRadius = inner ? (endcapRadius * innerRadius) : endcapRadius;
    final vertex = switch (currSecIndex) {
      0 => Point(currRadius, tProportion * vSegHalf),
      1 => radialToCartesian(currRadius, tProportion * math.pi / 2) + rectBR,
      2 => Point(hSegHalf - tProportion * hSegLen, currRadius),
      3 => radialToCartesian(
            currRadius,
            math.pi / 2 + (tProportion * math.pi / 2),
          ) +
          rectBL,
      4 => Point(-currRadius, vSegHalf - tProportion * vSegLen),
      5 =>
        radialToCartesian(currRadius, math.pi + (tProportion * math.pi / 2)) +
            rectTL,
      6 => Point(-hSegHalf + tProportion * hSegLen, -currRadius),
      7 => radialToCartesian(
            currRadius,
            math.pi * 1.5 + (tProportion * math.pi / 2),
          ) +
          rectTR,
      // 8
      _ => Point(currRadius, -vSegHalf + tProportion * vSegHalf),
    };
    result[arrayIndex++] = vertex.x + centerX;
    result[arrayIndex++] = vertex.y + centerY;
    t += tPerVertex;
    inner = !inner;
  }

  return result;
}

List<double> _starVerticesFromNumVerts(
  int numVerticesPerRadius,
  double radius,
  double innerRadius,
  double centerX,
  double centerY,
) {
  final result = List<double>.filled(numVerticesPerRadius * 4, 0);
  var arrayIndex = 0;

  for (var i = 0; i < numVerticesPerRadius; i++) {
    var vertex = radialToCartesian(
      radius,
      math.pi / numVerticesPerRadius * 2 * i,
    );
    result[arrayIndex++] = vertex.x + centerX;
    result[arrayIndex++] = vertex.y + centerY;
    vertex = radialToCartesian(
      innerRadius,
      math.pi / numVerticesPerRadius * (2 * i + 1),
    );
    result[arrayIndex++] = vertex.x + centerX;
    result[arrayIndex++] = vertex.y + centerY;
  }

  return result;
}
