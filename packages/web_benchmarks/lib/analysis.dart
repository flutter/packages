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
    throw Exception('Cannot take average of empty list.');
  }

  BenchmarkResults totalSum = results.first;
  for (int i = 1; i < results.length; i++) {
    final BenchmarkResults current = results[i];
    totalSum = totalSum._sumWith(current);
  }

  final Map<String, List<Map<String, Object?>>> average = totalSum.toJson();
  for (final String benchmark in totalSum.scores.keys) {
    final List<BenchmarkScore> scoresForBenchmark = totalSum.scores[benchmark]!;
    for (int i = 0; i < scoresForBenchmark.length; i++) {
      final BenchmarkScore score = scoresForBenchmark[i];
      final double averageValue = score.value / results.length;
      average[benchmark]![i][BenchmarkScore.valueKey] = averageValue;
    }
  }
  return BenchmarkResults.parse(average);
}

/// Computes the delta between [test] and [baseline], and returns the results
/// as a JSON object where each benchmark score entry contains a new field
/// 'delta' with the metric value comparison.
Map<String, List<Map<String, Object?>>> computeDelta(
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
      _benchmarkDeltas[score] = (score.value - baselineScore.value).toDouble();
    }
  }
  return test._toJsonWithDeltas();
}

/// An expando to hold benchmark delta values computed during a [computeDelta]
/// operation.
Expando<double> _benchmarkDeltas = Expando<double>();

extension _AnalysisExtension on BenchmarkResults {
  /// Returns the JSON representation of this [BenchmarkResults] instance with
  /// an added field 'delta' that contains the delta for this metric as computed
  /// by the [compareBenchmarks] method.
  Map<String, List<Map<String, Object?>>> _toJsonWithDeltas() {
    return scores.map<String, List<Map<String, Object?>>>(
      (String benchmarkName, List<BenchmarkScore> scores) {
        return MapEntry<String, List<Map<String, Object?>>>(
          benchmarkName,
          scores.map<Map<String, Object?>>(
            (BenchmarkScore score) {
              final double? delta = _benchmarkDeltas[score];
              return <String, Object?>{
                ...score.toJson(),
                if (delta != null) 'delta': delta,
              };
            },
          ).toList(),
        );
      },
    );
  }

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
