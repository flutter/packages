// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// A single benchmark score value collected from the benchmark.
class BenchmarkScore {
  /// Creates a benchmark score.
  ///
  /// [metric] and [value] must not be null.
  BenchmarkScore({
    required this.metric,
    required this.value,
  });

  /// The name of the metric that this score is categorized under.
  ///
  /// Scores collected over time under the same name can be visualized as a
  /// timeline.
  final String metric;

  /// The result of measuring a particular metric in this benchmark run.
  final num value;

  /// Serializes the benchmark metric to a JSON object.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'metric': metric,
      'value': value,
    };
  }
}

/// The result of running a benchmark.
class BenchmarkResults {
  /// Constructs a result containing scores from a single run benchmark run.
  BenchmarkResults(this.scores);

  /// Scores collected in a benchmark run.
  final Map<String, List<BenchmarkScore>> scores;

  /// Serializes benchmark metrics to JSON.
  Map<String, List<Map<String, dynamic>>> toJson() {
    return scores.map<String, List<Map<String, dynamic>>>(
        (String benchmarkName, List<BenchmarkScore> scores) {
      return MapEntry<String, List<Map<String, dynamic>>>(
        benchmarkName,
        scores
            .map<Map<String, dynamic>>(
                (BenchmarkScore score) => <String, dynamic>{
                      'metric': score.metric,
                      'value': score.value,
                    })
            .toList(),
      );
    });
  }
}
