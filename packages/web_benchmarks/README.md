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
