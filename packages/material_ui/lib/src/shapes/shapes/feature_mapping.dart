part of 'shapes.dart';

/// MeasuredFeatures contains a list of all features in a polygon along with
/// the [0..1] progress at that feature.
typedef MeasuredFeatures = List<ProgressableFeature>;

class ProgressableFeature {
  const ProgressableFeature(this.progress, this.feature);

  final double progress;

  final Feature feature;
}

class DistanceVertex {
  const DistanceVertex(this.distance, this.f1, this.f2);

  final double distance;

  final ProgressableFeature f1;

  final ProgressableFeature f2;
}

/// Creates a mapping between the "features" (rounded corners) of two shapes.
DoubleMapper featureMapper(
  MeasuredFeatures features1,
  MeasuredFeatures features2,
) {
  // We only use corners for this mapping.
  final filteredFeatures1 = <ProgressableFeature>[];
  for (var i = 0; i < features1.length; i++) {
    if (features1[i].feature.isCorner) {
      filteredFeatures1.add(features1[i]);
    }
  }

  final filteredFeatures2 = <ProgressableFeature>[];
  for (var i = 0; i < features2.length; i++) {
    if (features2[i].feature.isCorner) {
      filteredFeatures2.add(features2[i]);
    }
  }

  final featureProgressMapping = doMapping(
    filteredFeatures1,
    filteredFeatures2,
  );

  return DoubleMapper(featureProgressMapping);
}

/// Returns a mapping of the features between features1 and features2. The
/// return is a list of pairs in which the first element is the progress of a
/// feature in features1 and the second element is the progress of the feature
/// in features2 that we mapped it to. The list is sorted by the first
/// element. To do this:
///   1) Compute the distance for all pairs of features in (features1 x
///    features2)
/// 2) Sort ascending by by such distance
/// 3) Try to add them, from smallest distance to biggest, ensuring that:
///    a) The features we are mapping haven't been mapped yet.
///    b) We are not adding a crossing in the mapping. Since the
///       mapping is sorted by the first element of each pair, this means that
///       the second elements of each pair are monotonically increasing, except
///       maybe one time (Counting all pair of consecutive elements, and the
///       last element to first element).
List<(double, double)> doMapping(
  List<ProgressableFeature> features1,
  List<ProgressableFeature> features2,
) {
  final distanceVertexList = <DistanceVertex>[];

  for (final f1 in features1) {
    for (final f2 in features2) {
      final d = featureDistSquared(f1.feature, f2.feature);
      if (d != double.maxFinite) {
        distanceVertexList.add(DistanceVertex(d, f1, f2));
      }
    }
  }

  distanceVertexList.sort((a, b) => a.distance.compareTo(b.distance));

  // Special cases.
  if (distanceVertexList.isEmpty) {
    return [(0.0, 0.0), (0.5, 0.5)];
  }

  if (distanceVertexList.length == 1) {
    final d = distanceVertexList.first;

    final f1 = d.f1.progress;
    final f2 = d.f2.progress;

    return [(f1, f2), ((f1 + 0.5) % 1, (f2 + 0.5) % 1)];
  }

  final helper = _MappingHelper();

  for (final d in distanceVertexList) {
    helper.addMapping(d.f1, d.f2);
  }

  return helper.mapping;
}

class _MappingHelper {
  // List of mappings from progress in the start shape to progress in the
  // end shape.
  // We keep this list sorted by the first element.
  final mapping = <(double, double)>[];

  // Which features in the start shape have we used and which in the end shape.
  final _usedF1 = <ProgressableFeature>{};
  final _usedF2 = <ProgressableFeature>{};

  void addMapping(ProgressableFeature f1, ProgressableFeature f2) {
    // We don't want to map the same feature twice.
    if (_usedF1.contains(f1) || _usedF2.contains(f2)) {
      return;
    }

    // List is sorted, find where we need to insert this new mapping.
    final index = binarySearchBy<(double, double), double>(
      mapping,
      (it) => it.$1,
      (a, b) => a.compareTo(b),
      f1.progress,
    );

    if (index >= 0) {
      throw StateError("There can't be two features with the same progress.");
    }

    final insertionIndex = -index - 1;
    final n = mapping.length;

    // We can always add the first 1 element.
    if (n >= 1) {
      final (before1, before2) = mapping[(insertionIndex + n - 1) % n];
      final (after1, after2) = mapping[insertionIndex % n];

      // We don't want features that are way too close to each other, that will
      // make the DoubleMapper unstable.
      if (progressDistance(f1.progress, before1) < distanceEpsilon ||
          progressDistance(f1.progress, after1) < distanceEpsilon ||
          progressDistance(f2.progress, before2) < distanceEpsilon ||
          progressDistance(f2.progress, after2) < distanceEpsilon) {
        return;
      }

      // When we have 2 or more elements, we need to ensure we are not adding
      // extra crossings.
      if (n > 1 && !progressInRange(f2.progress, before2, after2)) {
        return;
      }
    }

    // All good, we can add the mapping.
    mapping.insert(insertionIndex, (f1.progress, f2.progress));
    _usedF1.add(f1);
    _usedF2.add(f2);
  }
}

/// Returns distance along overall shape between two Features on the two
/// different shapes. This information is used to determine how to map features
/// (and the curves that make up those features).
double featureDistSquared(Feature f1, Feature f2) {
  // TODO: We might want to enable concave-convex matching in some situations.
  // If so, the approach below will not work
  if (f1 is CornerFeature && f2 is CornerFeature && f1.convex != f2.convex) {
    // Simple hack to force all features to map only to features of the same
    // concavity, by returning an infinitely large distance in that case.
    return double.maxFinite;
  }

  return (featureRepresentativePoint(f1) - featureRepresentativePoint(f2))
      .getDistanceSquared();
}

// TODO: b/378441547 - Move to explicit parameter / expose?
Point featureRepresentativePoint(Feature feature) {
  final cubics = feature.cubics;
  final x = (cubics.first.anchor0X + cubics.last.anchor1X) / 2;
  final y = (cubics.first.anchor0Y + cubics.last.anchor1Y) / 2;
  return Point(x, y);
}
