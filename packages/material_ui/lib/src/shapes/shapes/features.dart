part of 'shapes.dart';

/// While a polygon's shape can be drawn solely using a list of [Cubic] objects
/// representing its raw curves and lines, features add an extra layer of
/// context to groups of cubics. Features group cubics into (straight) edges,
/// convex corners, or concave corners. For example, rounding a rectangle adds
/// many cubics around its edges, but the rectangle's overall number of corners
/// remains the same. [Morph] therefore uses this grouping for several reasons:
///   - Noise Reduction: Grouping cubics reduces the amount of noise introduced
///     by individual cubics (as seen in the rounded rectangle example).
///   - Mapping Base: The grouping serves as the base set for [Morph]'s mapping
///     process.
///   - Curve Type Mapping: [Morph] maps similar curve types (convex, concave)
///     together. Note that edges or features created with
///     [Feature.buildIgnorableFeature] are ignored in the default mapping.
///
/// By using features, you can manipulate polygon shapes with more context and
/// control.
abstract class Feature {
  const Feature(List<Cubic> cubics) : _cubics = cubics;

  /// Group a list of [Cubic] objects to a feature that should be ignored in
  /// the default [Morph] mapping. The feature can have any indentation.
  ///
  /// Sometimes, it's helpful to ignore certain features when morphing shapes.
  /// This is because only the features you mark as important will be smoothly
  /// transitioned between the start and end shapes. Additionally, the default
  /// morph algorithm will try to match convex corners to convex corners and
  /// concave to concave. Marking features as ignorable will influence this
  /// matching.
  ///
  /// For example, given a 12-pointed star, marking all concave corners as
  /// ignorable will create a [Morph] that only considers the outer corners of
  /// the star. As a result, depending on the morphed to shape, the animation
  /// may have fewer intersections and rotations. Another example for the other
  /// way around is a [Morph] between a pointed up triangle to a square.
  /// Marking the square's top edge as a convex corner matches it to the
  /// triangle's upper corner. Instead of moving triangle's upper corner to one
  /// of rectangle's corners, the animation now splits the triangle to match
  /// squares' outer corners.
  ///
  /// Throws [ArgumentError] for lists of empty cubics or non-continuous cubics.
  factory Feature.buildIgnorableFeature(List<Cubic> cubics) =>
      _validated(EdgeFeature(cubics));

  /// Group a [Cubic] object to an edge (neither inward or outward
  /// identification in a shape).
  ///
  /// Throws [ArgumentError] for lists of empty cubics or non-continuous cubics.
  factory Feature.buildEdge(Cubic cubic) => EdgeFeature([cubic]);

  /// Group a list of [Cubic] objects to a convex corner (outward indentation
  /// in a shape).
  ///
  /// Throws [ArgumentError] for lists of empty cubics or non-continuous cubics
  factory Feature.buildConvexCorner(List<Cubic> cubics) =>
      _validated(CornerFeature(cubics));

  /// Group a list of [Cubic] objects to a concave corner (inward indentation
  /// in a shape).
  ///
  /// Throws [ArgumentError] for lists of empty cubics or non-continuous cubics
  factory Feature.buildConcaveCorner(List<Cubic> cubics) =>
      _validated(CornerFeature(cubics, convex: false));

  static Feature _validated(Feature feature) {
    if (feature._cubics.isEmpty) {
      throw ArgumentError('Features need at least one cubic.');
    }

    if (!_isContinuous(feature)) {
      throw ArgumentError(
        'Feature must be continuous, with the anchor points of all cubics '
        'matching the anchor points of the preceding and succeeding cubics',
      );
    }

    return feature;
  }

  static bool _isContinuous(Feature feature) {
    const distanceEpsilon = 1e-5;
    var prevCubic = feature._cubics.first;
    for (var i = 1; i < feature._cubics.length; i++) {
      final cubic = feature._cubics[i];
      if ((cubic.anchor0X - prevCubic.anchor1X).abs() > distanceEpsilon ||
          (cubic.anchor0Y - prevCubic.anchor1Y).abs() > distanceEpsilon) {
        return false;
      }
      prevCubic = cubic;
    }
    return true;
  }

  final List<Cubic> _cubics;

  /// Returns unmodifiable list of [Cubic].
  List<Cubic> get cubics => UnmodifiableListView(_cubics);

  /// Whether this Feature gets ignored in the Morph mapping. See
  /// [Feature.buildIgnorableFeature] for more details
  bool get isIgnorableFeature;

  /// Whether this Feature is an Edge with no inward or outward indentation.
  bool get isEdge;

  /// Whether this Feature is a corner.
  bool get isCorner;

  /// Whether this Feature is a convex corner (outward indentation in a shape).
  bool get isConvexCorner;

  /// Whether this Feature is a concave corner (inward indentation in a shape).
  bool get isConcaveCorner;

  /// Transforms the points in this [Feature] with the given [PointTransformer]
  /// and returns a new [Feature].
  Feature transformed(PointTransformer f);

  /// Returns a new [Feature] with the points that define the shape of this
  /// [Feature] in reversed order.
  Feature reversed();
}

/// Edges have only a list of the cubic curves which make up the edge. Edges
/// lie between corners and have no vertex or concavity; the curves are simply
/// straight lines (represented by [Cubic] curves).
class EdgeFeature extends Feature {
  EdgeFeature(super._cubics);

  @override
  Feature transformed(PointTransformer f) => EdgeFeature(
        List.generate(
          _cubics.length,
          (i) => _cubics[i].transformed(f),
        ),
      );

  @override
  Feature reversed() => EdgeFeature(
        List.generate(
          _cubics.length,
          (i) => _cubics[_cubics.length - 1 - i].reverse(),
        ),
      );

  @override
  bool get isIgnorableFeature => true;

  @override
  bool get isEdge => true;

  @override
  bool get isCorner => false;

  @override
  bool get isConvexCorner => false;

  @override
  bool get isConcaveCorner => false;

  @override
  String toString() => 'Edge';
}

/// Corners contain the list of cubic curves which describe how the corner is
/// rounded (or not), and a flag indicating whether the corner is convex. A
/// regular polygon has all convex corners, while a star polygon generally
/// (but not necessarily) has both convex (outer) and concave (inner) corners.
class CornerFeature extends Feature {
  const CornerFeature(super._cubics, {this.convex = true});

  final bool convex;

  @override
  Feature transformed(PointTransformer f) => CornerFeature(
        List.generate(
          _cubics.length,
          (i) => _cubics[i].transformed(f),
        ),
        convex: convex,
      );

  @override
  Feature reversed() => CornerFeature(
        List.generate(
          _cubics.length,
          (i) => _cubics[_cubics.length - 1 - i].reverse(),
        ),
        // TODO: b/369320447 - Revert flag negation when [RoundedPolygon]
        // ignores orientation for setting the flag.
        convex: !convex,
      );

  @override
  bool get isIgnorableFeature => false;

  @override
  bool get isEdge => false;

  @override
  bool get isCorner => true;

  @override
  bool get isConvexCorner => convex;

  @override
  bool get isConcaveCorner => !convex;

  @override
  String toString() {
    return 'Corner: cubics=${_cubics.map((c) => '[$c]').join(', ')} '
        'convex=$convex';
  }
}
