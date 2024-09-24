// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert' show JsonEncoder;
import 'dart:io';

import 'package:test/test.dart';

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
    'Can run a web benchmark with an alternate initial page',
    () async {
      final BenchmarkResults results = await _runBenchmarks(
        benchmarkNames: <String>[BenchmarkName.simpleInitialPageCheck.name],
        entryPoint:
            'benchmark/test_infra/client/simple_initial_page_client.dart',
        initialPage: testBenchmarkInitialPage,
      );

      // The runner puts an `expectedUrl` metric in the results so that we can
      // verify the initial page value that should be passed on initial load
      // and on reloads.
      final List<BenchmarkScore>? scores =
          results.scores[BenchmarkName.simpleInitialPageCheck.name];
      expect(scores, isNotNull);

      final BenchmarkScore isWasmScore = scores!
          .firstWhere((BenchmarkScore score) => score.metric == 'expectedUrl');
      expect(isWasmScore.value, 1);
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
