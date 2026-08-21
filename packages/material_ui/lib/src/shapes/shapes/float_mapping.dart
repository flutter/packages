part of 'shapes.dart';

/// Checks if the given progress is in the given progress range.
///
/// Since progress is in the [0..1) interval and wraps, there is a special case
/// when [progressTo] < [progressFrom]. For example, if the progress range is
/// 0.7 to 0.2, both 0.8 and 0.1 are inside and 0.5 is outside.
bool progressInRange(double progress, double progressFrom, double progressTo) {
  if (progressTo >= progressFrom) {
    return progress >= progressFrom && progress <= progressTo;
  } else {
    return progress >= progressFrom || progress <= progressTo;
  }
}

/// Maps from one set of progress values to another. This is used to retrieve
/// the value on one shape that maps to the appropriate value on the other.
double linearMap(List<double> xValues, List<double> yValues, double x) {
  assert(x >= 0 && x <= 1, 'Invalid progress $x');

  var segmentStartIndex = -1;

  for (var i = 0; i < xValues.length; i++) {
    if (progressInRange(x, xValues[i], xValues[(i + 1) % xValues.length])) {
      segmentStartIndex = i;
      break;
    }
  }

  if (segmentStartIndex == -1) {
    throw StateError('segmentStartIndex not found.');
  }

  final segmentEndIndex = (segmentStartIndex + 1) % xValues.length;
  final segmentSizeX = positiveModulo(
    xValues[segmentEndIndex] - xValues[segmentStartIndex],
    1,
  );
  final segmentSizeY = positiveModulo(
    yValues[segmentEndIndex] - yValues[segmentStartIndex],
    1,
  );
  final positionInSegment = segmentSizeX < 0.001
      ? 0.5
      : positiveModulo(x - xValues[segmentStartIndex], 1) / segmentSizeX;

  return positiveModulo(
    yValues[segmentStartIndex] + segmentSizeY * positionInSegment,
    1,
  );
}

/// [DoubleMapper] creates mappings from values in the [0..1) source space to
/// values in the [0..1) target space, and back. This mapping is created given
/// a finite list of representative mappings, and this is extended to the whole
/// interval by linear interpolation, and wrapping around.
///
/// For example, if we have mappings 0.2 to 0.5 and 0.4 to 0.6, then 0.3
/// (which is in the middle of the source interval) will be mapped to 0.55
/// (the middle of the targets for the interval), 0.21 will map to 0.505, and
/// so on.
///
/// As a more complete example, if we use x to represent a value in the source
/// space and y for the target space, and given as input the mappings 0 to 0,
/// 0.5 to 0.25, this will create a mapping that: { if x in [0 .. 0.5] }
/// y = x / 2 { if x in [0.5 .. 1] } y = 0.25 + (x - 0.5) * 1.5 = x * 1.5 - 0.5
///
/// The mapping can also be used the other way around (using the [mapBack]
/// function), resulting in: { if y in [0 .. 0.25] } x = y * 2 { if y in
/// [0.25 .. 1] } x = (y + 0.5) / 1.5 This is used to create mappings of
/// progress values between the start and end shape, which is then used to
/// insert new curves and match curves overall.
class DoubleMapper {
  static final identity = DoubleMapper([
    (0.0, 0.0),
    (0.5, 0.5),
  ]);

  DoubleMapper(List<(double, double)> mappings) {
    _sourceValues = List.filled(mappings.length, 0);
    _targetValues = List.filled(mappings.length, 0);
    for (var i = 0; i < mappings.length; i++) {
      final pair = mappings[i];
      _sourceValues[i] = pair.$1;
      _targetValues[i] = pair.$2;
    }
    validateProgress(_sourceValues);
    validateProgress(_targetValues);
  }

  late final List<double> _sourceValues;

  late final List<double> _targetValues;

  /// Maps a value from the source to the target space.
  double map(double x) => linearMap(_sourceValues, _targetValues, x);

  /// Maps a value from the target back to the source space.
  double mapBack(double x) => linearMap(_targetValues, _sourceValues, x);
}

/// Verifies that a list of progress values are all in the range [0.0, 1.0)
/// and are monotonically increasing, allowing at most one wraparound.
///
/// Throws [ArgumentError] if validation fails.
void validateProgress(List<double> p) {
  if (p.isEmpty) {
    throw ArgumentError('List is empty.');
  }

  var prev = p.last;
  var wraps = 0;

  for (var i = 0; i < p.length; i++) {
    final curr = p[i];

    if (curr < 0 || curr >= 1) {
      throw ArgumentError(
        'FloatMapping - Progress outside of range: ${p.join(', ')}',
      );
    }

    if (progressDistance(curr, prev).abs() <= distanceEpsilon) {
      throw ArgumentError(
        'FloatMapping - Progress repeats a value: ${p.join(', ')}',
      );
    }

    if (curr < prev) {
      wraps++;
      if (wraps > 1) {
        throw ArgumentError(
          'FloatMapping - Progress wraps more than once: ${p.join(', ')}',
        );
      }
    }

    prev = curr;
  }
}

/// Distance between two progress values, considering wrap-around.
/// For example, the distance between 0.99 and 0.0 is 0.01.
double progressDistance(double p1, double p2) {
  final diff = (p1 - p2).abs();
  return math.min(diff, 1.0 - diff);
}
