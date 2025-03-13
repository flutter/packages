// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:math' as math;

import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

import 'common.dart';
import 'metrics.dart';

/// Series of time recordings indexed in time order.
///
/// It can calculate [average], [standardDeviation] and [noise]. If the amount
/// of data collected is higher than [_kMeasuredSampleCount], then these
/// calculations will only apply to the latest [_kMeasuredSampleCount] data
/// points.
class Timeseries {
  /// Creates an empty timeseries.
  ///
  /// [name], [isReported], and [useCustomWarmUp] must not be null.
  Timeseries(this.name, this.isReported, {this.useCustomWarmUp = false})
      : _warmUpFrameCount = useCustomWarmUp ? 0 : null;

  /// The label of this timeseries used for debugging and result inspection.
  final String name;

  /// Whether this timeseries is reported to the benchmark dashboard.
  ///
  /// If `true` a new benchmark card is created for the timeseries and is
  /// visible on the dashboard.
  ///
  /// If `false` the data is stored but it does not show up on the dashboard.
  /// Use unreported metrics for metrics that are useful for manual inspection
  /// but that are too fine-grained to be useful for tracking on the dashboard.
  final bool isReported;

  /// Whether to delimit warm-up frames in a custom way.
  final bool useCustomWarmUp;

  /// The number of frames ignored as warm-up frames, used only
  /// when [useCustomWarmUp] is true.
  int? _warmUpFrameCount;

  /// The number of frames ignored as warm-up frames.
  int get warmUpFrameCount =>
      useCustomWarmUp ? _warmUpFrameCount! : count - kMeasuredSampleCount;

  /// List of all the values that have been recorded.
  ///
  /// This list has no limit.
  final List<double> _allValues = <double>[];

  /// The total amount of data collected, including ones that were dropped
  /// because of the sample size limit.
  int get count => _allValues.length;

  /// Extracts useful statistics out of this timeseries.
  ///
  /// See [TimeseriesStats] for more details.
  TimeseriesStats computeStats() {
    final int finalWarmUpFrameCount = warmUpFrameCount;

    assert(finalWarmUpFrameCount >= 0 && finalWarmUpFrameCount < count);

    // The first few values we simply discard and never look at. They're from the warm-up phase.
    final List<double> warmUpValues =
        _allValues.sublist(0, finalWarmUpFrameCount);

    // Values we analyze.
    final List<double> candidateValues =
        _allValues.sublist(finalWarmUpFrameCount);

    // The average that includes outliers.
    final double dirtyAverage = _computeAverage(name, candidateValues);

    // The standard deviation that includes outliers.
    final double dirtyStandardDeviation =
        _computeStandardDeviationForPopulation(name, candidateValues);

    // Any value that's higher than this is considered an outlier.
    final double outlierCutOff = dirtyAverage + dirtyStandardDeviation;

    // Candidates with outliers removed.
    final Iterable<double> cleanValues =
        candidateValues.where((double value) => value <= outlierCutOff);

    // Outlier candidates.
    final Iterable<double> outliers =
        candidateValues.where((double value) => value > outlierCutOff);

    // Final statistics.
    final double cleanAverage = _computeAverage(name, cleanValues);
    final double standardDeviation =
        _computeStandardDeviationForPopulation(name, cleanValues);
    final double noise =
        cleanAverage > 0.0 ? standardDeviation / cleanAverage : 0.0;

    // Compute outlier average. If there are no outliers the outlier average is
    // the same as clean value average. In other words, in a perfect benchmark
    // with no noise the difference between average and outlier average is zero,
    // which the best possible outcome. Noise produces a positive difference
    // between the two.
    final double outlierAverage =
        outliers.isNotEmpty ? _computeAverage(name, outliers) : cleanAverage;

    // Compute percentile values (e.g. p50, p90, p95).
    final Map<double, double> percentiles = computePercentiles(
      name,
      PercentileMetricComputation.percentilesAsDoubles,
      candidateValues,
    );

    final List<AnnotatedSample> annotatedValues = <AnnotatedSample>[
      for (final double warmUpValue in warmUpValues)
        AnnotatedSample(
          magnitude: warmUpValue,
          isOutlier: warmUpValue > outlierCutOff,
          isWarmUpValue: true,
        ),
      for (final double candidate in candidateValues)
        AnnotatedSample(
          magnitude: candidate,
          isOutlier: candidate > outlierCutOff,
          isWarmUpValue: false,
        ),
    ];

    return TimeseriesStats(
      name: name,
      average: cleanAverage,
      outlierCutOff: outlierCutOff,
      outlierAverage: outlierAverage,
      standardDeviation: standardDeviation,
      noise: noise,
      percentiles: percentiles,
      cleanSampleCount: cleanValues.length,
      outlierSampleCount: outliers.length,
      samples: annotatedValues,
    );
  }

  /// Adds a value to this timeseries.
  void add(double value, {required bool isWarmUpValue}) {
    if (value < 0.0) {
      throw StateError(
        'Timeseries $name: negative metric values are not supported. Got: $value',
      );
    }
    _allValues.add(value);
    if (useCustomWarmUp && isWarmUpValue) {
      _warmUpFrameCount = warmUpFrameCount + 1;
    }
  }
}

/// Various statistics about a [Timeseries].
///
/// See the docs on the individual fields for more details.
@sealed
class TimeseriesStats {
  /// Creates statistics for a time series.
  const TimeseriesStats({
    required this.name,
    required this.average,
    required this.outlierCutOff,
    required this.outlierAverage,
    required this.standardDeviation,
    required this.noise,
    required this.percentiles,
    required this.cleanSampleCount,
    required this.outlierSampleCount,
    required this.samples,
  });

  /// The label used to refer to the corresponding timeseries.
  final String name;

  /// The average value of the measured samples without outliers.
  final double average;

  /// The standard deviation in the measured samples without outliers.
  final double standardDeviation;

  /// The noise as a multiple of the [average] value taken from clean samples.
  ///
  /// This value can be multiplied by 100.0 to get noise as a percentage of
  /// the average.
  ///
  /// If [average] is zero, treats the result as perfect score, returns zero.
  final double noise;

  /// The percentile values (p50, p90, p95, etc.) for the measured samples with
  /// outliers.
  ///
  /// This [Map] is from percentile targets (e.g. 0.50 for p50, 0.90 for p90,
  /// etc.) to the computed value for the [samples].
  final Map<double, double> percentiles;

  /// The maximum value a sample can have without being considered an outlier.
  ///
  /// See [Timeseries.computeStats] for details on how this value is computed.
  final double outlierCutOff;

  /// The average of outlier samples.
  ///
  /// This value can be used to judge how badly we jank, when we jank.
  ///
  /// Another useful metrics is the difference between [outlierAverage] and
  /// [average]. The smaller the value the more predictable is the performance
  /// of the corresponding benchmark.
  final double outlierAverage;

  /// The number of measured samples after outlier are removed.
  final int cleanSampleCount;

  /// The number of outliers.
  final int outlierSampleCount;

  /// All collected samples, annotated with statistical information.
  ///
  /// See [AnnotatedSample] for more details.
  final List<AnnotatedSample> samples;

  /// Outlier average divided by clean average.
  ///
  /// This is a measure of performance consistency. The higher this number the
  /// worse is jank when it happens. Smaller is better, with 1.0 being the
  /// perfect score. If [average] is zero, this value defaults to 1.0.
  double get outlierRatio => average > 0.0
      ? outlierAverage / average
      : 1.0; // this can only happen in perfect benchmark that reports only zeros

  @override
  String toString() {
    final StringBuffer buffer = StringBuffer();
    buffer.writeln(
      '$name: (samples: $cleanSampleCount clean/$outlierSampleCount '
      'outliers/${cleanSampleCount + outlierSampleCount} '
      'measured/${samples.length} total)',
    );
    buffer.writeln(' | average: $average μs');
    buffer.writeln(' | outlier average: $outlierAverage μs');
    buffer.writeln(' | outlier/clean ratio: ${outlierRatio}x');
    buffer.writeln(' | noise: ${_ratioToPercent(noise)}');
    for (final PercentileMetricComputation metric
        in PercentileMetricComputation.values) {
      buffer.writeln(' | ${metric.name}: ${metric.percentile} μs');
    }
    return buffer.toString();
  }
}

/// Annotates a single measurement with statistical information.
@sealed
class AnnotatedSample {
  /// Creates an annotated measurement sample.
  const AnnotatedSample({
    required this.magnitude,
    required this.isOutlier,
    required this.isWarmUpValue,
  });

  /// The non-negative raw result of the measurement.
  final double magnitude;

  /// Whether this sample was considered an outlier.
  final bool isOutlier;

  /// Whether this sample was taken during the warm-up phase.
  ///
  /// If this value is `true`, this sample does not participate in
  /// statistical computations. However, the sample would still be
  /// shown in the visualization of results so that the benchmark
  /// can be inspected manually to make sure there's a predictable
  /// warm-up regression slope.
  final bool isWarmUpValue;
}

/// Computes the arithmetic mean (or average) of given [values].
double _computeAverage(String label, Iterable<double> values) {
  if (values.isEmpty) {
    throw StateError(
        '$label: attempted to compute an average of an empty value list.');
  }

  final double sum = values.reduce((double a, double b) => a + b);
  return sum / values.length;
}

/// Computes population standard deviation.
///
/// Unlike sample standard deviation, which divides by N - 1, this divides by N.
///
/// See also:
///
/// * https://en.wikipedia.org/wiki/Standard_deviation
double _computeStandardDeviationForPopulation(
    String label, Iterable<double> population) {
  if (population.isEmpty) {
    throw StateError(
        '$label: attempted to compute the standard deviation of empty population.');
  }
  final double mean = _computeAverage(label, population);
  final double sumOfSquaredDeltas = population.fold<double>(
    0.0,
    (double previous, double value) => previous += math.pow(value - mean, 2),
  );
  return math.sqrt(sumOfSquaredDeltas / population.length);
}

String _ratioToPercent(double value) {
  return '${(value * 100).toStringAsFixed(2)}%';
}

/// Computes the percentile threshold in [values] for the given [percentiles].
///
/// Each value in [percentiles] should be between 0.0 and 1.0.
///
/// Returns a [Map] of percentile values to the computed value from [values].
Map<double, double> computePercentiles(
  String label,
  List<double> percentiles,
  Iterable<double> values,
) {
  if (values.isEmpty) {
    throw StateError(
      '$label: attempted to compute a percentile of an empty value list.',
    );
  }
  for (final double percentile in percentiles) {
    if (percentile < 0.0 || percentile > 1.0) {
      throw StateError(
        '$label: attempted to compute a percentile for an invalid '
        'value: $percentile',
      );
    }
  }

  final List<double> sorted =
      values.sorted((double a, double b) => a.compareTo(b));
  final Map<double, double> computed = <double, double>{};
  for (final double percentile in percentiles) {
    final int percentileIndex =
        (sorted.length * percentile).round().clamp(0, sorted.length - 1);
    computed[percentile] = sorted[percentileIndex];
  }

  return computed;
}
