// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// #docregion analyze
import 'dart:convert';
import 'dart:io';

import 'package:web_benchmarks/analysis.dart';

void main() {
  final BenchmarkResults baselineResults = _benchmarkResultsFromFile(
    '/path/to/benchmark_baseline.json',
  );
  final BenchmarkResults testResults1 = _benchmarkResultsFromFile(
    '/path/to/benchmark_test_1.json',
  );
  final BenchmarkResults testResults2 = _benchmarkResultsFromFile(
    '/path/to/benchmark_test_2.json',
  );

  // Compute the delta between [baselineResults] and [testResults1].
  final BenchmarkResults delta = computeDelta(baselineResults, testResults1);
  stdout.writeln(delta.toJson());

  // Compute the average of [testResults] and [testResults2].
  final BenchmarkResults average = computeAverage(<BenchmarkResults>[
    testResults1,
    testResults2,
  ]);
  stdout.writeln(average.toJson());
}

BenchmarkResults _benchmarkResultsFromFile(String path) {
  final file = File.fromUri(Uri.parse(path));
  final fileContentAsJson =
      jsonDecode(file.readAsStringSync()) as Map<String, Object?>;
  return BenchmarkResults.parse(fileContentAsJson);
}

// #enddocregion analyze
