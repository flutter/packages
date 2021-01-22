// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert' show JsonEncoder;
import 'dart:io';

import 'package:test/test.dart';

import 'package:web_benchmarks/server.dart';

Future<void> main() async {
  test('Can run a web benchmark', () async {
    final BenchmarkResults taskResult = await serveWebBenchmark(
      benchmarkAppDirectory: Directory('testing/test_app'),
      entryPoint: 'lib/benchmarks/runner.dart',
      useCanvasKit: false,
    );

    for (final String benchmarkName in <String>['scroll', 'page', 'tap']) {
      for (final String metricName in <String>[
        'preroll_frame',
        'apply_frame',
        'drawFrameDuration',
      ]) {
        for (final String valueName in <String>[
          'average',
          'outlierAverage',
          'outlierRatio',
          'noise',
        ]) {
          expect(
            taskResult.scores[benchmarkName].where((BenchmarkScore score) =>
                score.metric == '$metricName.$valueName'),
            hasLength(1),
          );
        }
      }
      expect(
        taskResult.scores[benchmarkName].where(
            (BenchmarkScore score) => score.metric == 'totalUiFrame.average'),
        hasLength(1),
      );
    }

    expect(
      const JsonEncoder.withIndent('  ').convert(taskResult.toJson()),
      isA<String>(),
    );
  }, timeout: Timeout.none);
}
