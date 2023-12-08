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

  /// Deserializes a JSON object to create a [BenchmarkScore] object.
  factory BenchmarkScore.parse(Map<String, Object?> json) {
    final String metric = json[_metricKey]! as String;
    final double value = (json[_valueKey]! as num).toDouble();
    return BenchmarkScore(metric: metric, value: value);
  }

  static const String _metricKey = 'metric';
  static const String _valueKey = 'value';

  /// The name of the metric that this score is categorized under.
  ///
  /// Scores collected over time under the same name can be visualized as a
  /// timeline.
  final String metric;

  /// The result of measuring a particular metric in this benchmark run.
  final num value;

  /// Serializes the benchmark metric to a JSON object.
  Map<String, Object?> toJson() {
    return <String, Object?>{
      _metricKey: metric,
      _valueKey: value,
    };
  }
}

/// The result of running a benchmark.
class BenchmarkResults {
  /// Constructs a result containing scores from a single run benchmark run.
  BenchmarkResults(this.scores);

  /// Deserializes a JSON object to create a [BenchmarkResults] object.
  factory BenchmarkResults.parse(Map<String, Object?> json) {
    final Map<String, List<BenchmarkScore>> results =
        <String, List<BenchmarkScore>>{};
    for (final String key in json.keys) {
      final List<BenchmarkScore> scores = (json[key]! as List<Object?>)
          .cast<Map<String, Object?>>()
          .map(BenchmarkScore.parse)
          .toList();
      results[key] = scores;
    }
    return BenchmarkResults(results);
  }

  /// Scores collected in a benchmark run.
  final Map<String, List<BenchmarkScore>> scores;

  /// Serializes benchmark metrics to JSON.
  Map<String, List<Map<String, Object?>>> toJson() {
    return scores.map<String, List<Map<String, Object?>>>(
        (String benchmarkName, List<BenchmarkScore> scores) {
      return MapEntry<String, List<Map<String, Object?>>>(
        benchmarkName,
        scores.map((BenchmarkScore score) => score.toJson()).toList(),
      );
    });
  }
}
