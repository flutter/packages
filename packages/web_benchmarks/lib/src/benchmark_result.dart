// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// A single benchmark score value collected from the benchmark.
class BenchmarkScore {
  /// Creates a benchmark score.
  ///
  /// [metric] and [value] must not be null.
  BenchmarkScore({required this.metric, required this.value, this.delta});

  /// Deserializes a JSON object to create a [BenchmarkScore] object.
  factory BenchmarkScore.parse(Map<String, Object?> json) {
    final String metric = json[metricKey]! as String;
    final double value = (json[valueKey]! as num).toDouble();
    final num? delta = json[deltaKey] as num?;
    return BenchmarkScore(metric: metric, value: value, delta: delta);
  }

  /// The key for the value [metric] in the [BenchmarkScore] JSON
  /// representation.
  static const String metricKey = 'metric';

  /// The key for the value [value] in the [BenchmarkScore] JSON representation.
  static const String valueKey = 'value';

  /// The key for the value [delta] in the [BenchmarkScore] JSON representation.
  static const String deltaKey = 'delta';

  /// The name of the metric that this score is categorized under.
  ///
  /// Scores collected over time under the same name can be visualized as a
  /// timeline.
  final String metric;

  /// The result of measuring a particular metric in this benchmark run.
  final num value;

  /// Optional delta value describing the difference between this metric's score
  /// and the score of a matching metric from another [BenchmarkResults].
  ///
  /// This value may be assigned by the [computeDelta] analysis method.
  final num? delta;

  /// Serializes the benchmark metric to a JSON object.
  Map<String, Object?> toJson() {
    return <String, Object?>{
      metricKey: metric,
      valueKey: value,
      if (delta != null) deltaKey: delta,
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
          .toList(growable: false);
      results[key] = scores;
    }
    return BenchmarkResults(results);
  }

  /// Scores collected in a benchmark run.
  final Map<String, List<BenchmarkScore>> scores;

  /// Serializes benchmark metrics to JSON.
  Map<String, List<Map<String, Object?>>> toJson() {
    return scores.map<String, List<Map<String, Object?>>>((
      String benchmarkName,
      List<BenchmarkScore> scores,
    ) {
      return MapEntry<String, List<Map<String, Object?>>>(
        benchmarkName,
        scores.map((BenchmarkScore score) => score.toJson()).toList(),
      );
    });
  }
}
