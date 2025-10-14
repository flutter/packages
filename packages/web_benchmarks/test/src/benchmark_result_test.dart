// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:web_benchmarks/server.dart';

void main() {
  group('can serialize and deserialize', () {
    test('$BenchmarkResults', () {
      final Map<String, Object?> data = <String, Object?>{
        'foo': <Map<String, Object?>>[
          <String, Object?>{'metric': 'foo.bar', 'value': 12.34, 'delta': -0.2},
          <String, Object?>{'metric': 'foo.baz', 'value': 10, 'delta': 3.3},
        ],
        'bar': <Map<String, Object?>>[
          <String, Object?>{'metric': 'bar.foo', 'value': 1.23},
        ],
      };

      final BenchmarkResults benchmarkResults = BenchmarkResults.parse(data);
      expect(benchmarkResults.scores.length, 2);
      final List<BenchmarkScore> fooBenchmarks =
          benchmarkResults.scores['foo']!;
      final List<BenchmarkScore> barBenchmarks =
          benchmarkResults.scores['bar']!;
      expect(fooBenchmarks.length, 2);
      expect(fooBenchmarks[0].metric, 'foo.bar');
      expect(fooBenchmarks[0].value, 12.34);
      expect(fooBenchmarks[0].delta, -0.2);
      expect(fooBenchmarks[1].metric, 'foo.baz');
      expect(fooBenchmarks[1].value, 10);
      expect(fooBenchmarks[1].delta, 3.3);
      expect(barBenchmarks.length, 1);
      expect(barBenchmarks[0].metric, 'bar.foo');
      expect(barBenchmarks[0].value, 1.23);
      expect(barBenchmarks[0].delta, isNull);

      expect(benchmarkResults.toJson(), data);
    });

    test('$BenchmarkScore', () {
      final Map<String, Object?> data = <String, Object?>{
        'metric': 'foo',
        'value': 1.234,
        'delta': -0.4,
      };

      final BenchmarkScore score = BenchmarkScore.parse(data);
      expect(score.metric, 'foo');
      expect(score.value, 1.234);
      expect(score.delta, -0.4);

      expect(score.toJson(), data);
    });
  });
}
