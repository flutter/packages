// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:web_benchmarks/analysis.dart';

void main() {
  group('averageBenchmarkResults', () {
    test('succeeds for identical benchmark names and metrics', () {
      final BenchmarkResults result1 = BenchmarkResults(
        <String, List<BenchmarkScore>>{
          'foo': <BenchmarkScore>[
            BenchmarkScore(metric: 'foo.bar', value: 6),
            BenchmarkScore(metric: 'foo.baz', value: 10),
          ],
          'bar': <BenchmarkScore>[
            BenchmarkScore(metric: 'bar.foo', value: 2.4),
          ],
        },
      );
      final BenchmarkResults result2 = BenchmarkResults(
        <String, List<BenchmarkScore>>{
          'foo': <BenchmarkScore>[
            BenchmarkScore(metric: 'foo.bar', value: 4),
            BenchmarkScore(metric: 'foo.baz', value: 10),
          ],
          'bar': <BenchmarkScore>[
            BenchmarkScore(metric: 'bar.foo', value: 1.2),
          ],
        },
      );
      final BenchmarkResults average =
          computeAverage(<BenchmarkResults>[result1, result2]);
      expect(
        average.toJson(),
        <String, List<Map<String, Object?>>>{
          'foo': <Map<String, Object?>>[
            <String, Object?>{'metric': 'foo.bar', 'value': 5},
            <String, Object?>{'metric': 'foo.baz', 'value': 10},
          ],
          'bar': <Map<String, Object?>>[
            <String, Object?>{'metric': 'bar.foo', 'value': 1.7999999999999998},
          ],
        },
      );
    });

    test('fails for mismatched benchmark names', () {
      final BenchmarkResults result1 = BenchmarkResults(
        <String, List<BenchmarkScore>>{
          'foo': <BenchmarkScore>[BenchmarkScore(metric: 'foo.bar', value: 6)],
        },
      );
      final BenchmarkResults result2 = BenchmarkResults(
        <String, List<BenchmarkScore>>{
          'foo1': <BenchmarkScore>[BenchmarkScore(metric: 'foo.bar', value: 4)],
        },
      );
      expect(
        () {
          computeAverage(<BenchmarkResults>[result1, result2]);
        },
        throwsException,
      );
    });

    test('fails for mismatched benchmark metrics', () {
      final BenchmarkResults result1 = BenchmarkResults(
        <String, List<BenchmarkScore>>{
          'foo': <BenchmarkScore>[BenchmarkScore(metric: 'foo.bar', value: 6)],
        },
      );
      final BenchmarkResults result2 = BenchmarkResults(
        <String, List<BenchmarkScore>>{
          'foo': <BenchmarkScore>[BenchmarkScore(metric: 'foo.boo', value: 4)],
        },
      );
      expect(
        () {
          computeAverage(<BenchmarkResults>[result1, result2]);
        },
        throwsException,
      );
    });
  });

  test('computeDelta', () {
    final BenchmarkResults benchmark1 =
        BenchmarkResults.parse(testBenchmarkResults1);
    final BenchmarkResults benchmark2 =
        BenchmarkResults.parse(testBenchmarkResults2);
    final BenchmarkResults delta = computeDelta(benchmark1, benchmark2);
    expect(delta.toJson(), expectedBenchmarkDelta);
  });
}

final Map<String, List<Map<String, Object?>>> testBenchmarkResults1 =
    <String, List<Map<String, Object?>>>{
  'foo': <Map<String, Object?>>[
    <String, Object?>{'metric': 'preroll_frame.average', 'value': 60.5},
    <String, Object?>{'metric': 'preroll_frame.outlierAverage', 'value': 1400},
    <String, Object?>{'metric': 'preroll_frame.outlierRatio', 'value': 20.2},
    <String, Object?>{'metric': 'preroll_frame.noise', 'value': 0.85},
    <String, Object?>{'metric': 'apply_frame.average', 'value': 80.0},
    <String, Object?>{'metric': 'apply_frame.outlierAverage', 'value': 200.6},
    <String, Object?>{'metric': 'apply_frame.outlierRatio', 'value': 2.5},
    <String, Object?>{'metric': 'apply_frame.noise', 'value': 0.4},
    <String, Object?>{'metric': 'drawFrameDuration.average', 'value': 2058.9},
    <String, Object?>{
      'metric': 'drawFrameDuration.outlierAverage',
      'value': 24000,
    },
    <String, Object?>{
      'metric': 'drawFrameDuration.outlierRatio',
      'value': 12.05,
    },
    <String, Object?>{'metric': 'drawFrameDuration.noise', 'value': 0.34},
    <String, Object?>{'metric': 'totalUiFrame.average', 'value': 4166},
  ],
  'bar': <Map<String, Object?>>[
    <String, Object?>{'metric': 'preroll_frame.average', 'value': 60.5},
    <String, Object?>{'metric': 'preroll_frame.outlierAverage', 'value': 1400},
    <String, Object?>{'metric': 'preroll_frame.outlierRatio', 'value': 20.2},
    <String, Object?>{'metric': 'preroll_frame.noise', 'value': 0.85},
    <String, Object?>{'metric': 'apply_frame.average', 'value': 80.0},
    <String, Object?>{'metric': 'apply_frame.outlierAverage', 'value': 200.6},
    <String, Object?>{'metric': 'apply_frame.outlierRatio', 'value': 2.5},
    <String, Object?>{'metric': 'apply_frame.noise', 'value': 0.4},
    <String, Object?>{'metric': 'drawFrameDuration.average', 'value': 2058.9},
    <String, Object?>{
      'metric': 'drawFrameDuration.outlierAverage',
      'value': 24000,
    },
    <String, Object?>{
      'metric': 'drawFrameDuration.outlierRatio',
      'value': 12.05,
    },
    <String, Object?>{'metric': 'drawFrameDuration.noise', 'value': 0.34},
    <String, Object?>{'metric': 'totalUiFrame.average', 'value': 4166},
  ],
};

final Map<String, List<Map<String, Object?>>> testBenchmarkResults2 =
    <String, List<Map<String, Object?>>>{
  'foo': <Map<String, Object?>>[
    <String, Object?>{'metric': 'preroll_frame.average', 'value': 65.5},
    <String, Object?>{'metric': 'preroll_frame.outlierAverage', 'value': 1410},
    <String, Object?>{'metric': 'preroll_frame.outlierRatio', 'value': 20.0},
    <String, Object?>{'metric': 'preroll_frame.noise', 'value': 1.5},
    <String, Object?>{'metric': 'apply_frame.average', 'value': 50.0},
    <String, Object?>{'metric': 'apply_frame.outlierAverage', 'value': 100.0},
    <String, Object?>{'metric': 'apply_frame.outlierRatio', 'value': 2.55},
    <String, Object?>{'metric': 'apply_frame.noise', 'value': 0.9},
    <String, Object?>{'metric': 'drawFrameDuration.average', 'value': 2000.0},
    <String, Object?>{
      'metric': 'drawFrameDuration.outlierAverage',
      'value': 20000
    },
    <String, Object?>{
      'metric': 'drawFrameDuration.outlierRatio',
      'value': 11.05
    },
    <String, Object?>{'metric': 'drawFrameDuration.noise', 'value': 1.34},
    <String, Object?>{'metric': 'totalUiFrame.average', 'value': 4150},
  ],
  'bar': <Map<String, Object?>>[
    <String, Object?>{'metric': 'preroll_frame.average', 'value': 65.5},
    <String, Object?>{'metric': 'preroll_frame.outlierAverage', 'value': 1410},
    <String, Object?>{'metric': 'preroll_frame.outlierRatio', 'value': 20.0},
    <String, Object?>{'metric': 'preroll_frame.noise', 'value': 1.5},
    <String, Object?>{'metric': 'apply_frame.average', 'value': 50.0},
    <String, Object?>{'metric': 'apply_frame.outlierAverage', 'value': 100.0},
    <String, Object?>{'metric': 'apply_frame.outlierRatio', 'value': 2.55},
    <String, Object?>{'metric': 'apply_frame.noise', 'value': 0.9},
    <String, Object?>{'metric': 'drawFrameDuration.average', 'value': 2000.0},
    <String, Object?>{
      'metric': 'drawFrameDuration.outlierAverage',
      'value': 20000
    },
    <String, Object?>{
      'metric': 'drawFrameDuration.outlierRatio',
      'value': 11.05
    },
    <String, Object?>{'metric': 'drawFrameDuration.noise', 'value': 1.34},
    <String, Object?>{'metric': 'totalUiFrame.average', 'value': 4150},
  ],
};

final Map<String, List<Map<String, Object?>>> expectedBenchmarkDelta =
    <String, List<Map<String, Object?>>>{
  'foo': <Map<String, Object?>>[
    <String, Object?>{
      'metric': 'preroll_frame.average',
      'value': 65.5,
      'delta': 5.0
    },
    <String, Object?>{
      'metric': 'preroll_frame.outlierAverage',
      'value': 1410.0,
      'delta': 10.0,
    },
    <String, Object?>{
      'metric': 'preroll_frame.outlierRatio',
      'value': 20.0,
      'delta': -0.1999999999999993,
    },
    <String, Object?>{
      'metric': 'preroll_frame.noise',
      'value': 1.5,
      'delta': 0.65,
    },
    <String, Object?>{
      'metric': 'apply_frame.average',
      'value': 50.0,
      'delta': -30.0,
    },
    <String, Object?>{
      'metric': 'apply_frame.outlierAverage',
      'value': 100.0,
      'delta': -100.6,
    },
    <String, Object?>{
      'metric': 'apply_frame.outlierRatio',
      'value': 2.55,
      'delta': 0.04999999999999982,
    },
    <String, Object?>{
      'metric': 'apply_frame.noise',
      'value': 0.9,
      'delta': 0.5,
    },
    <String, Object?>{
      'metric': 'drawFrameDuration.average',
      'value': 2000.0,
      'delta': -58.90000000000009,
    },
    <String, Object?>{
      'metric': 'drawFrameDuration.outlierAverage',
      'value': 20000.0,
      'delta': -4000.0,
    },
    <String, Object?>{
      'metric': 'drawFrameDuration.outlierRatio',
      'value': 11.05,
      'delta': -1.0,
    },
    <String, Object?>{
      'metric': 'drawFrameDuration.noise',
      'value': 1.34,
      'delta': 1.0,
    },
    <String, Object?>{
      'metric': 'totalUiFrame.average',
      'value': 4150.0,
      'delta': -16.0,
    },
  ],
  'bar': <Map<String, Object?>>[
    <String, Object?>{
      'metric': 'preroll_frame.average',
      'value': 65.5,
      'delta': 5.0,
    },
    <String, Object?>{
      'metric': 'preroll_frame.outlierAverage',
      'value': 1410.0,
      'delta': 10.0,
    },
    <String, Object?>{
      'metric': 'preroll_frame.outlierRatio',
      'value': 20.0,
      'delta': -0.1999999999999993,
    },
    <String, Object?>{
      'metric': 'preroll_frame.noise',
      'value': 1.5,
      'delta': 0.65,
    },
    <String, Object?>{
      'metric': 'apply_frame.average',
      'value': 50.0,
      'delta': -30.0,
    },
    <String, Object?>{
      'metric': 'apply_frame.outlierAverage',
      'value': 100.0,
      'delta': -100.6,
    },
    <String, Object?>{
      'metric': 'apply_frame.outlierRatio',
      'value': 2.55,
      'delta': 0.04999999999999982,
    },
    <String, Object?>{
      'metric': 'apply_frame.noise',
      'value': 0.9,
      'delta': 0.5,
    },
    <String, Object?>{
      'metric': 'drawFrameDuration.average',
      'value': 2000.0,
      'delta': -58.90000000000009,
    },
    <String, Object?>{
      'metric': 'drawFrameDuration.outlierAverage',
      'value': 20000.0,
      'delta': -4000.0,
    },
    <String, Object?>{
      'metric': 'drawFrameDuration.outlierRatio',
      'value': 11.05,
      'delta': -1.0,
    },
    <String, Object?>{
      'metric': 'drawFrameDuration.noise',
      'value': 1.34,
      'delta': 1.0,
    },
    <String, Object?>{
      'metric': 'totalUiFrame.average',
      'value': 4150.0,
      'delta': -16.0,
    },
  ],
};
