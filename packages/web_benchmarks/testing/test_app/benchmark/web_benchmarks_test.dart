// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert' show JsonEncoder;
import 'dart:io';

import 'package:test/test.dart';

import 'package:web_benchmarks/metrics.dart';
import 'package:web_benchmarks/server.dart';
import 'package:web_benchmarks/src/common.dart';

import 'test_infra/common.dart';

Future<void> main() async {
  test(
    'Can run a web benchmark',
    () async {
      await _runBenchmarks(
        benchmarkNames: <String>[
          BenchmarkName.appNavigate.name,
          BenchmarkName.appScroll.name,
          BenchmarkName.appTap.name,
        ],
        entryPoint: 'benchmark/test_infra/client/app_client.dart',
      );
    },
    timeout: Timeout.none,
  );

  test(
    'Can run a web benchmark with an alternate benchmarkPath',
    () async {
      final BenchmarkResults results = await _runBenchmarks(
        benchmarkNames: <String>[BenchmarkName.simpleBenchmarkPathCheck.name],
        entryPoint:
            'benchmark/test_infra/client/simple_benchmark_path_client.dart',
        benchmarkPath: testBenchmarkPath,
      );

      final List<BenchmarkScore>? scores =
          results.scores[BenchmarkName.simpleBenchmarkPathCheck.name];
      expect(scores, isNotNull);

      // The runner puts an `expectedUrl` metric in the results so that we can
      // verify the initial page value that should be passed on initial load
      // and on reloads.
      final BenchmarkScore expectedUrlScore = scores!
          .firstWhere((BenchmarkScore score) => score.metric == 'expectedUrl');
      expect(expectedUrlScore.value, 1);
    },
    timeout: Timeout.none,
  );

  test(
    'Can run a web benchmark with wasm',
    () async {
      final BenchmarkResults results = await _runBenchmarks(
        benchmarkNames: <String>[BenchmarkName.simpleCompilationCheck.name],
        entryPoint:
            'benchmark/test_infra/client/simple_compilation_client.dart',
        compilationOptions: const CompilationOptions.wasm(),
      );

      // The runner puts an `isWasm` metric in the results so that we can verify
      // we are running with the correct compiler and renderer.
      final List<BenchmarkScore>? scores =
          results.scores[BenchmarkName.simpleCompilationCheck.name];
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
  String benchmarkPath = defaultInitialPath,
  CompilationOptions compilationOptions = const CompilationOptions.js(),
}) async {
  final BenchmarkResults taskResult = await serveWebBenchmark(
    benchmarkAppDirectory: Directory('testing/test_app'),
    entryPoint: entryPoint,
    treeShakeIcons: false,
    benchmarkPath: benchmarkPath,
    compilationOptions: compilationOptions,
  );

  final List<String> expectedMetrics =
      expectedBenchmarkMetrics(useWasm: compilationOptions.useWasm)
          .map((BenchmarkMetric metric) => metric.label)
          .toList();

  for (final String benchmarkName in benchmarkNames) {
    for (final String metricName in expectedMetrics) {
      for (final BenchmarkMetricComputation computation
          in BenchmarkMetricComputation.values) {
        expect(
            taskResult.scores[benchmarkName]!.where((BenchmarkScore score) =>
                score.metric == '$metricName.${computation.name}'),
            hasLength(1),
            reason: 'Expected to find a metric named '
                '$metricName.${computation.name}');
      }
    }
    expect(
      taskResult.scores[benchmarkName]!
          .where((BenchmarkScore score) => score.metric == totalUiFrameAverage),
      hasLength(1),
    );
  }

  expect(
    const JsonEncoder.withIndent('  ').convert(taskResult.toJson()),
    isA<String>(),
  );
  return taskResult;
}
