# web_benchmarks

A benchmark harness for Flutter Web apps. Currently only supports running
benchmarks in Chrome.

# Writing a benchmark

An example benchmark can be found in [testing/test_app/benchmark/web_benchmark_test.dart][1].

A web benchmark is made of two parts: a client and a server. The client is code
that runs in the browser together with the benchmark code. The server serves the
app's code and assets. Additionally, the server communicates with the browser to
extract the performance traces.

[1]: https://github.com/flutter/packages/blob/master/packages/web_benchmarks/testing/test_app/benchmark/web_benchmarks_test.dart

# Analyzing benchmark results

After running web benchmarks, you may want to analyze the results or compare
with the results from other benchmark runs. The `web_benchmarks` package
supports the following analysis operations:

* compute the delta between two benchmark results
* compute the average of a set of benchmark results

<?code-excerpt "example/analyze_example.dart (analyze)"?>
```dart
import 'dart:convert';
import 'dart:io';

import 'package:web_benchmarks/analysis.dart';

void main() {
  final BenchmarkResults baselineResults =
      _benchmarkResultsFromFile('/path/to/benchmark_baseline.json');
  final BenchmarkResults testResults1 =
      _benchmarkResultsFromFile('/path/to/benchmark_test_1.json');
  final BenchmarkResults testResults2 =
      _benchmarkResultsFromFile('/path/to/benchmark_test_2.json');

  // Compute the delta between [baselineResults] and [testResults1].
  final BenchmarkResults delta = computeDelta(baselineResults, testResults1);
  stdout.writeln(delta.toJson());

  // Compute the average of [testResults] and [testResults2].
  final BenchmarkResults average =
      computeAverage(<BenchmarkResults>[testResults1, testResults2]);
  stdout.writeln(average.toJson());
}

BenchmarkResults _benchmarkResultsFromFile(String path) {
  final File file = File.fromUri(Uri.parse(path));
  final Map<String, Object?> fileContentAsJson =
      jsonDecode(file.readAsStringSync()) as Map<String, Object?>;
  return BenchmarkResults.parse(fileContentAsJson);
}
```
