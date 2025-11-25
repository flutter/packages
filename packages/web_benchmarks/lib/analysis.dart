// Copyright 2013 The Flutter Authors
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

  final average = totalSum;
  for (final String benchmark in totalSum.scores.keys) {
    final List<BenchmarkScore> scoresForBenchmark = totalSum.scores[benchmark]!;
    for (var i = 0; i < scoresForBenchmark.length; i++) {
      final BenchmarkScore score = scoresForBenchmark[i];
      final double averageValue = score.value / results.length;
      average.scores[benchmark]![i] = BenchmarkScore(
        metric: score.metric,
        value: averageValue,
      );
    }
  }
  return average;
}

/// Computes the delta for each matching metric in [test] and [baseline], and
/// returns a new [BenchmarkResults] object where each [BenchmarkScore] contains
/// a [delta] value.
BenchmarkResults computeDelta(
  BenchmarkResults baseline,
  BenchmarkResults test,
) {
  final delta = <String, List<BenchmarkScore>>{};
  for (final String benchmarkName in test.scores.keys) {
    final List<BenchmarkScore> testScores = test.scores[benchmarkName]!;
    final List<BenchmarkScore>? baselineScores = baseline.scores[benchmarkName];
    delta[benchmarkName] = testScores.map<BenchmarkScore>((
      BenchmarkScore testScore,
    ) {
      final BenchmarkScore? baselineScore = baselineScores?.firstWhereOrNull(
        (BenchmarkScore s) => s.metric == testScore.metric,
      );
      return testScore._copyWith(
        delta: baselineScore == null
            ? null
            : (testScore.value - baselineScore.value).toDouble(),
      );
    }).toList();
  }
  return BenchmarkResults(delta);
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
    final sum = <String, List<BenchmarkScore>>{};
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
      sum[benchmark] = scoresForBenchmark.map<BenchmarkScore>((
        BenchmarkScore score,
      ) {
        // Look up this score in the [matchingBenchmark] from [other].
        final BenchmarkScore? matchingScore = matchingBenchmark
            .firstWhereOrNull((BenchmarkScore s) => s.metric == score.metric);
        if (matchingScore == null && throwExceptionOnMismatch) {
          throw Exception(
            'Cannot sum benchmarks because benchmark "$benchmark" is missing '
            'a score for metric ${score.metric}.',
          );
        }
        return score._copyWith(
          value: matchingScore == null
              ? score.value
              : score.value + matchingScore.value,
        );
      }).toList();
    }
    return BenchmarkResults(sum);
  }
}

extension _CopyExtension on BenchmarkScore {
  BenchmarkScore _copyWith({String? metric, num? value, num? delta}) =>
      BenchmarkScore(
        metric: metric ?? this.metric,
        value: value ?? this.value,
        delta: delta ?? this.delta,
      );
}
