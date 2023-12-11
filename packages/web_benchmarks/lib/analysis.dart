// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:collection/collection.dart';
import 'server.dart';

export 'src/benchmark_result.dart';

/// Returns the average of the benchmark results in [results].
///
/// Each element in [results] is expected to have identical benchmark names and
/// metrics; otherwise, an [Exception] will be thrown.
BenchmarkResults computeAverage(List<BenchmarkResults> results) {
  if (results.isEmpty) {
    throw ArgumentError('Cannot take average of empty list.');
  }

  final BenchmarkResults totalSum = results.reduce(
    (BenchmarkResults sum, BenchmarkResults next) => sum._sumWith(next),
  );

  final BenchmarkResults average = totalSum;
  for (final String benchmark in totalSum.scores.keys) {
    final List<BenchmarkScore> scoresForBenchmark = totalSum.scores[benchmark]!;
    for (int i = 0; i < scoresForBenchmark.length; i++) {
      final BenchmarkScore score = scoresForBenchmark[i];
      final double averageValue = score.value / results.length;
      average.scores[benchmark]![i] =
          BenchmarkScore(metric: score.metric, value: averageValue);
    }
  }
  return average;
}

/// Computes the delta for each matching metric in [test] and [baseline],
/// assigns the delta values to each [BenchmarkScore] in [test], and then
/// returns the modified [test] object.
BenchmarkResults computeDelta(
  BenchmarkResults baseline,
  BenchmarkResults test,
) {
  for (final String benchmarkName in test.scores.keys) {
    // Lookup this benchmark in the baseline.
    final List<BenchmarkScore>? baselineScores = baseline.scores[benchmarkName];
    if (baselineScores == null) {
      continue;
    }

    final List<BenchmarkScore> testScores = test.scores[benchmarkName]!;
    for (final BenchmarkScore score in testScores) {
      // Lookup this metric in the baseline.
      final BenchmarkScore? baselineScore = baselineScores
          .firstWhereOrNull((BenchmarkScore s) => s.metric == score.metric);
      if (baselineScore == null) {
        continue;
      }

      // Add the delta to the [testMetric].
      score.delta = (score.value - baselineScore.value).toDouble();
    }
  }
  return test;
}

extension _AnalysisExtension on BenchmarkResults {
  /// Sums this [BenchmarkResults] instance with [other] by adding the values
  /// of each matching benchmark score.
  ///
  /// Returns a [BenchmarkResults] object with the summed values.
  ///
  /// When [throwExceptionOnMismatch] is true (default), the set of benchmark
  /// names and metric names in [other] are expected to be identical to those in
  /// [scores], or else an [Exception] will be thrown.
  BenchmarkResults _sumWith(
    BenchmarkResults other, {
    bool throwExceptionOnMismatch = true,
  }) {
    final Map<String, List<Map<String, Object?>>> sum = toJson();
    for (final String benchmark in scores.keys) {
      // Look up this benchmark in [other].
      final List<BenchmarkScore>? matchingBenchmark = other.scores[benchmark];
      if (matchingBenchmark == null) {
        if (throwExceptionOnMismatch) {
          throw Exception(
            'Cannot sum benchmarks because [other] is missing an entry for '
            'benchmark "$benchmark".',
          );
        }
        continue;
      }

      final List<BenchmarkScore> scoresForBenchmark = scores[benchmark]!;
      for (int i = 0; i < scoresForBenchmark.length; i++) {
        final BenchmarkScore score = scoresForBenchmark[i];
        // Look up this score in the [matchingBenchmark] from [other].
        final BenchmarkScore? matchingScore = matchingBenchmark
            .firstWhereOrNull((BenchmarkScore s) => s.metric == score.metric);
        if (matchingScore == null) {
          if (throwExceptionOnMismatch) {
            throw Exception(
              'Cannot sum benchmarks because benchmark "$benchmark" is missing '
              'a score for metric ${score.metric}.',
            );
          }
          continue;
        }

        final num sumScore = score.value + matchingScore.value;
        sum[benchmark]![i][BenchmarkScore.valueKey] = sumScore;
      }
    }
    return BenchmarkResults.parse(sum);
  }
}
