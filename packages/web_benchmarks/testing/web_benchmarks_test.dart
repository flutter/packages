// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert' show JsonEncoder;
import 'dart:io';

import 'package:web_benchmarks/server.dart';

Future<void> main() async {
  final BenchmarkResults taskResult = await serveWebBenchmark(
    benchmarkAppDirectory: Directory('testing/test_app'),
    entryPoint: 'lib/benchmarks/runner.dart',
    useCanvasKit: false,
  );

  for (final String benchmarkName in <String>['scroll', 'page', 'tap']) {
    for (final String metricName in <String>[
      'preroll_frame',
      'apply_frame',
      'drawFrameDuration'
    ]) {
      for (final String valueName in <String>[
        'average',
        'outlierAverage',
        'outlierRatio',
        'noise'
      ]) {
        _expect(
          taskResult.scores[benchmarkName]
              .where((BenchmarkScore score) =>
                  score.metric == '$metricName.$valueName')
              .length,
          1,
        );
      }
    }
    _expect(
      taskResult.scores[benchmarkName]
          .where(
              (BenchmarkScore score) => score.metric == 'totalUiFrame.average')
          .length,
      1,
    );
  }

  print(const JsonEncoder.withIndent('  ').convert(taskResult.toJson()));
}

void _expect(Object actual, Object expected) {
  if (actual != expected) {
    throw Exception('Values different. Expected $expected, but got $actual');
  }
}
