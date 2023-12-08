# web_benchmarks

A benchmark harness for Flutter Web apps. Currently only supports running
benchmarks in Chrome.

# Writing a benchmark

An example benchmark can be found in [testing/web_benchmark_test.dart][1].

A web benchmark is made of two parts: a client and a server. The client is code
that runs in the browser together with the benchmark code. The server serves the
app's code and assets. Additionally, the server communicates with the browser to
extract the performance traces.

[1]: https://github.com/flutter/packages/blob/master/packages/web_benchmarks/testing/web_benchmarks_test.dart

# Analyzing benchmark results

After running web benchmarks, you may want to analyze the results or compare
with the results from other benchmark runs. The `web_benchmarks` package
supports the following analysis operations:

* compute the delta between two benchmark results
* compute the average of a set of benchmark results

```dart
import 'dart:convert';
import 'dart:io';

import 'package:web_benchmarks/analysis.dart';

void main() {
  final baseline = '/path/to/benchmark_baseline.json';
  final test1 = '/path/to/benchmark_test_1.json';
  final test2 = '/path/to/benchmark_test_2.json';
  final baselineFile = File.fromUri(Uri.parse(baseline));
  final testFile1 = File.fromUri(Uri.parse(test1));
  final testFile2 = File.fromUri(Uri.parse(test2));

  final baselineResults = BenchmarkResults.parse(
    jsonDecode(baselineFile.readAsStringSync()),
  );
  final testResults1 = BenchmarkResults.parse(
    jsonDecode(testFile1.readAsStringSync()),
  );
  final testResults2 = BenchmarkResults.parse(
    jsonDecode(testFile2.readAsStringSync()),
  );

  // Compute the delta between [baselineResults] and [testResults1].
  final Map<String, List<Map<String, Object?>>> delta = computeDelta(baselineResults, testResults1);
  print(delta);

  // Compute the average of [testResults] and [testResults2].
  final BenchmarkResults average = computeAverage(<BenchmarkResults>[testResults1, testResults2]);
  print(average.toJson());
}
```
