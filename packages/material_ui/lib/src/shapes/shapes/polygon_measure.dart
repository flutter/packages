part of 'shapes.dart';

class MeasuredPolygon {
  MeasuredPolygon._({
    required Measurer measurer,
    required List<ProgressableFeature> features,
    required List<Cubic> cubics,
    required List<double> outlineProgress,
  })  : assert(
          outlineProgress.length == cubics.length + 1,
          'Outline progress length is expected to be the cubics length + 1',
        ),
        assert(
          outlineProgress.first == 0,
          'First outline progress value is expected to be zero',
        ),
        assert(
          outlineProgress.last == 1,
          'Last outline progress value is expected to be one',
        ),
        _measurer = measurer,
        _features = features {
    final measuredCubics = <MeasuredCubic>[];
    var startOutlineProgress = 0.0;
    for (var i = 0; i < cubics.length; i++) {
      // Filter out "empty" cubics.
      if ((outlineProgress[i + 1] - outlineProgress[i]) > distanceEpsilon) {
        measuredCubics.add(
          MeasuredCubic(
            measurer: measurer,
            cubic: cubics[i],
            startOutlineProgress: startOutlineProgress,
            endOutlineProgress: outlineProgress[i + 1],
          ),
        );
        // The next measured cubic will start exactly where this one ends.
        startOutlineProgress = outlineProgress[i + 1];
      }
    }
    // We could have removed empty cubics at the end. Ensure the last measured
    // cubic ends at 1.
    measuredCubics[measuredCubics.length - 1].updateProgressRange(
      endOutlineProgress: 1,
    );
    _cubics = measuredCubics;
  }

  factory MeasuredPolygon.measurePolygon(
    Measurer measurer,
    RoundedPolygon polygon,
  ) {
    final cubics = <Cubic>[];
    final featureToCubic = <(Feature, int)>[];

    // Get the cubics from the polygon, at the same time, extract the features
    // and keep a reference to the representative cubic we will use.
    for (var featureIndex = 0;
        featureIndex < polygon.features.length;
        featureIndex++) {
      final feature = polygon.features[featureIndex];
      for (var cubicIndex = 0;
          cubicIndex < feature.cubics.length;
          cubicIndex++) {
        if (feature is CornerFeature &&
            cubicIndex == feature.cubics.length ~/ 2) {
          featureToCubic.add((feature, cubics.length));
        }
        cubics.add(feature.cubics[cubicIndex]);
      }
    }

    final measures = List<double>.filled(cubics.length + 1, 0);
    var totalMeasure = 0.0;

    for (var i = 0; i < cubics.length; i++) {
      final measure = measurer.measureCubic(cubics[i]);
      if (measure < 0) {
        throw StateError(
          'Measured cubic is expected to be greater or equal to zero',
        );
      }
      totalMeasure += measure;
      measures[i + 1] = totalMeasure;
    }

    final outlineProgress = List<double>.filled(measures.length, 0);
    for (var i = 0; i < measures.length; i++) {
      outlineProgress[i] = measures[i] / totalMeasure;
    }

    final features = List<ProgressableFeature>.generate(
      featureToCubic.length,
      (i) {
        final ix = featureToCubic[i].$2;
        return ProgressableFeature(
          positiveModulo(
            (outlineProgress[ix] + outlineProgress[ix + 1]) / 2,
            1,
          ),
          featureToCubic[i].$1,
        );
      },
    );

    return MeasuredPolygon._(
      measurer: measurer,
      features: features,
      cubics: cubics,
      outlineProgress: outlineProgress,
    );
  }

  final Measurer _measurer;

  late final List<MeasuredCubic> _cubics;

  final List<ProgressableFeature> _features;

  List<ProgressableFeature> get features => UnmodifiableListView(_features);

  MeasuredCubic get first => _cubics.first;

  MeasuredCubic get last => _cubics.last;

  int get length => _cubics.length;

  MeasuredCubic operator [](int index) => _cubics[index];

  MeasuredCubic? getOrNull(int index) {
    final length = _cubics.length;

    if (index < 0 || index >= length) {
      return null;
    }

    return _cubics[index];
  }

  /// Finds the point in the input list of measured cubics that pass the given
  /// outline progress, and generates a new MeasuredPolygon (equivalent to
  /// this), that starts at that point. This usually means cutting the cubic
  /// that crosses the outline progress (unless the cut is at one of its ends).
  /// For example, given outline progress 0.4f and measured cubics on these
  /// outline progress ranges:
  ///
  /// c1 [0 -> 0.2] c2 [0.2 -> 0.5] c3 [0.5 -> 1.0]
  ///
  /// c2 will be cut in two, at the given outline progress, we can name these
  /// c2a [0.2 -> 0.4] and c2b [0.4 -> 0.5]
  ///
  /// The return then will have measured cubics [c2b, c3, c1, c2a], and they
  /// will have their outline progress ranges adjusted so the new list starts
  /// at 0.
  ///
  /// c2b [0 -> 0.1] c3 [0.1 -> 0.6] c1 [0.6 -> 0.8] c2a [0.8 -> 1.0]
  MeasuredPolygon cutAndShift(double cuttingPoint) {
    if (cuttingPoint < 0 && cuttingPoint > 1) {
      throw ArgumentError('Cutting point is expected to be between 0 and 1');
    }

    if (cuttingPoint < distanceEpsilon) return this;

    // Find the index of cubic we want to cut
    final targetIndex = _cubics.indexWhere(
      (c) =>
          cuttingPoint >= c._startOutlineProgress &&
          cuttingPoint <= c._endOutlineProgress,
    );
    final target = _cubics[targetIndex];

    // Cut the target cubic.
    // b1, b2 are two resulting cubics after cut
    final (b1, b2) = target.cutAtProgress(cuttingPoint);

    // Construct the list of the cubics we need:
    // * The second part of the target cubic (after the cut)
    // * All cubics after the target, until the end + All cubics from the
    //   start, before the target cubic
    // * The first part of the target cubic (before the cut)
    final retCubics = [b2.cubic];
    for (var i = 1; i < _cubics.length; i++) {
      retCubics.add(_cubics[(i + targetIndex) % _cubics.length].cubic);
    }
    retCubics.add(b1.cubic);

    // Construct the array of outline progress.
    // For example, if we have 3 cubics with outline progress [0 .. 0.3],
    // [0.3 .. 0.8] & [0.8 .. 1.0], and we cut + shift at 0.6:
    // 0.  0123456789
    //     |--|--/-|-|
    // The outline progresses will start at 0 (the cutting point, that shifts
    // to 0.0), then 0.8 - 0.6 = 0.2, then 1 - 0.6 = 0.4, then 0.3 - 0.6 + 1 =
    // 0.7, then 1 (the cutting point again), all together: (0.0, 0.2, 0.4,
    // 0.7, 1.0)
    final retOutlineProgress = List<double>.filled(_cubics.length + 2, 0);

    for (var i = 0; i < _cubics.length + 2; i++) {
      if (i == 0) {
        retOutlineProgress[i] = 0;
      } else if (i == _cubics.length + 1) {
        retOutlineProgress[i] = 1;
      } else {
        final cubicIndex = (targetIndex + i - 1) % _cubics.length;
        retOutlineProgress[i] = positiveModulo(
          _cubics[cubicIndex]._endOutlineProgress - cuttingPoint,
          1,
        );
      }
    }

    // Shift the feature's outline progress too.
    final newFeatures = [
      for (var i = 0; i < _features.length; i++)
        ProgressableFeature(
          positiveModulo(_features[i].progress - cuttingPoint, 1),
          _features[i].feature,
        ),
    ];

    // Filter out all empty cubics (i.e. start and end anchor are (almost) the
    // same point.)
    return MeasuredPolygon._(
      measurer: _measurer,
      features: newFeatures,
      cubics: retCubics,
      outlineProgress: retOutlineProgress,
    );
  }
}

/// A MeasuredCubic holds information about the cubic itself, the feature
/// (if any) associated with it, and the outline progress values (start and
/// end) for the cubic. This information is used to match cubics between shapes
/// that lie at similar outline progress positions along their respective
/// shapes (after matching features and shifting).
///
/// Outline progress is a value in [0..1) that represents the distance traveled
/// along the overall outline path of the shape.
class MeasuredCubic {
  MeasuredCubic({
    required this.measurer,
    required this.cubic,
    required double startOutlineProgress,
    required double endOutlineProgress,
  })  : assert(
          startOutlineProgress >= 0 && startOutlineProgress <= 1,
          'startOutlineProgress has to be in [0..1] range',
        ),
        assert(
          endOutlineProgress >= 0 && endOutlineProgress <= 1,
          'endOutlineProgress has to be in range [0..1]',
        ),
        assert(
          endOutlineProgress >= startOutlineProgress,
          'endOutlineProgress is expected to be equal or greater than '
          'startOutlineProgress',
        ),
        _startOutlineProgress = startOutlineProgress,
        _endOutlineProgress = endOutlineProgress {
    measuredSize = measurer.measureCubic(cubic);
  }

  final Measurer measurer;

  final Cubic cubic;

  late final double measuredSize;

  double _startOutlineProgress;

  double _endOutlineProgress;

  double get startOutlineProgress => _startOutlineProgress;

  double get endOutlineProgress => _endOutlineProgress;

  void updateProgressRange({
    double? startOutlineProgress,
    double? endOutlineProgress,
  }) {
    startOutlineProgress ??= _startOutlineProgress;
    endOutlineProgress ??= _endOutlineProgress;

    if (endOutlineProgress < startOutlineProgress) {
      throw ArgumentError(
        'endOutlineProgress is expected to be equal or greater than '
        'startOutlineProgress',
      );
    }

    _startOutlineProgress = startOutlineProgress;
    _endOutlineProgress = endOutlineProgress;
  }

  /// Cut this [MeasuredCubic] into two at the given outline progress value.
  (MeasuredCubic, MeasuredCubic) cutAtProgress(double cutOutlineProgress) {
    // Floating point errors further up can cause cutOutlineProgress to land
    // just slightly outside of the start/end progress for this cubic, so we
    // limit it to those bounds to avoid further errors later
    final boundedCutOutlineProgress = cutOutlineProgress.coerceIn(
      _startOutlineProgress,
      _endOutlineProgress,
    );
    final outlineProgressSize = _endOutlineProgress - _startOutlineProgress;
    final progressFromStart = boundedCutOutlineProgress - _startOutlineProgress;

    // Note that in earlier parts of the computation, we have empty
    // MeasuredCubics (cubics with progressSize == 0), but those cubics are
    // filtered out before this method is called.
    final relativeProgress = progressFromStart / outlineProgressSize;
    final t = measurer.findCubicCutPoint(
      cubic,
      relativeProgress * measuredSize,
    );

    if (t < 0 || t > 1) {
      throw ArgumentError('Cubic cut point is expected to be between 0 and 1.');
    }

    // c1/c2 are the two new cubics, then we return MeasuredCubics created
    // from them.
    final (c1, c2) = cubic.split(t);
    return (
      MeasuredCubic(
        measurer: measurer,
        cubic: c1,
        startOutlineProgress: _startOutlineProgress,
        endOutlineProgress: boundedCutOutlineProgress,
      ),
      MeasuredCubic(
        measurer: measurer,
        cubic: c2,
        startOutlineProgress: boundedCutOutlineProgress,
        endOutlineProgress: _endOutlineProgress,
      )
    );
  }

  @override
  String toString() {
    return 'MeasuredCubic(outlineProgress='
        '[$_startOutlineProgress .. $_endOutlineProgress], '
        'size=$measuredSize, cubic=$cubic)';
  }
}

/// Interface for measuring a cubic. Implementations can use whatever algorithm
/// desired to produce these measurement values.
abstract interface class Measurer {
  const Measurer();

  /// Returns size of given cubic, according to however the implementation
  /// wants to measure the size (angle, length, etc). It has to be greater or
  /// equal to 0.
  double measureCubic(Cubic c);

  /// Given a cubic and a measure that should be between 0 and the value
  /// returned by measureCubic (if not, it will be capped), finds the parameter
  /// t of the cubic at which that measure is reached.
  double findCubicCutPoint(Cubic c, double m);
}

/// Approximates the arc lengths of cubics by splitting the arc into segments
/// and calculating their sizes. The more segments, the more accurate the
/// result will be to the true arc length. The default implementation has at
/// least 98.5% accuracy on the case of a circular arc, which is the
/// worst case for our standard shapes.
class LengthMeasurer implements Measurer {
  const LengthMeasurer();

  // The minimum number needed to achieve up to 98.5% accuracy from the true
  // arc length See PolygonMeasureTest.measureCircle
  static const _segments = 3;

  @override
  double measureCubic(Cubic c) {
    return _closestProgressTo(c, double.infinity).$2;
  }

  @override
  double findCubicCutPoint(Cubic c, double m) {
    return _closestProgressTo(c, m).$1;
  }

  (double, double) _closestProgressTo(Cubic cubic, double threshold) {
    var total = 0.0;
    var remainder = threshold;
    var prev = Point(cubic.anchor0X, cubic.anchor0Y);

    for (var i = 0; i <= _segments; i++) {
      final progress = i / _segments;
      final point = cubic.pointOnCurve(progress);
      final segment = (point - prev).getDistance();

      if (segment >= remainder) {
        return (
          progress - (1.0 - remainder / segment) / _segments,
          threshold,
        );
      }

      remainder -= segment;
      total += segment;
      prev = point;
    }

    return (1.0, total);
  }
}
