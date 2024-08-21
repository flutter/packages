// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert' show JsonEncoder;
import 'dart:io';

import 'package:test/test.dart';

import 'package:web_benchmarks/server.dart';
import 'package:web_benchmarks/src/common.dart';

Future<void> main() async {
  test('Can run a web benchmark', () async {
    await _runBenchmarks(
      benchmarkNames: <String>['scroll', 'page', 'tap'],
      entryPoint: 'lib/benchmarks/runner.dart',
    );
  }, timeout: Timeout.none);

  test('Can run a web benchmark with an alternate initial page', () async {
    final BenchmarkResults results = await _runBenchmarks(
      benchmarkNames: <String>['simple'],
      entryPoint: 'lib/benchmarks/runner_simple.dart',
      initialPage: 'index.html#about',
    );

    // The simple runner just puts an `isWasm` metric in there so we can make
    // sure that we're running in the right environment.
    final List<BenchmarkScore>? scores = results.scores['simple'];
    expect(scores, isNotNull);

    final BenchmarkScore isWasmScore =
        scores!.firstWhere((BenchmarkScore score) => score.metric == 'isWasm');
    expect(isWasmScore.value, 0);
  }, timeout: Timeout.none);

  test(
    'Can run a web benchmark with wasm',
    () async {
      final BenchmarkResults results = await _runBenchmarks(
        benchmarkNames: <String>['simple'],
        entryPoint: 'lib/benchmarks/runner_simple.dart',
        compilationOptions: const CompilationOptions.wasm(),
      );

      // The simple runner just puts an `isWasm` metric in there so we can make
      // sure that we're running in the right environment.
      final List<BenchmarkScore>? scores = results.scores['simple'];
      expect(scores, isNotNull);

      final BenchmarkScore isWasmScore = scores!
          .firstWhere((BenchmarkScore score) => score.metric == 'isWasm');
      expect(isWasmScore.value, 1);
    },
    timeout: Timeout.none,
  );
}

Future<BenchmarkResults> _runBenchmarks({
  required List<String> benchmarkNames,
  required String entryPoint,
  String initialPage = defaultInitialPage,
  CompilationOptions compilationOptions = const CompilationOptions.js(),
}) async {
  final BenchmarkResults taskResult = await serveWebBenchmark(
    benchmarkAppDirectory: Directory('testing/test_app'),
    entryPoint: entryPoint,
    treeShakeIcons: false,
    initialPage: initialPage,
    compilationOptions: compilationOptions,
  );

  // The skwasm renderer doesn't have preroll or apply frame steps in its rendering.
  final List<String> expectedMetrics = compilationOptions.useWasm
      ? <String>['drawFrameDuration']
      : <String>[
          'preroll_frame',
          'apply_frame',
          'drawFrameDuration',
        ];

  for (final String benchmarkName in benchmarkNames) {
    for (final String metricName in expectedMetrics) {
      for (final String valueName in <String>[
        'average',
        'outlierAverage',
        'outlierRatio',
        'noise',
      ]) {
        expect(
          taskResult.scores[benchmarkName]!.where((BenchmarkScore score) =>
              score.metric == '$metricName.$valueName'),
          hasLength(1),
        );
      }
    }
    expect(
      taskResult.scores[benchmarkName]!.where(
          (BenchmarkScore score) => score.metric == 'totalUiFrame.average'),
      hasLength(1),
    );
  }

  expect(
    const JsonEncoder.withIndent('  ').convert(taskResult.toJson()),
    isA<String>(),
  );
  return taskResult;
}
