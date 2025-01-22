// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io' as io;

import 'package:logging/logging.dart';

import 'src/benchmark_result.dart';
import 'src/common.dart';
import 'src/compilation_options.dart';
import 'src/runner.dart';

export 'src/benchmark_result.dart';
export 'src/compilation_options.dart';

/// The default port number used by the local benchmark server.
const int defaultBenchmarkServerPort = 9999;

/// The default port number used for Chrome DevTool Protocol.
const int defaultChromeDebugPort = 10000;

/// Builds and serves a Flutter Web app, collects raw benchmark data and
/// summarizes the result as a [BenchmarkResult].
///
/// [benchmarkAppDirectory] is the directory containing the app that's being
/// benchmarked. The app is expected to use `package:web_benchmarks/client.dart`
/// and call the `runBenchmarks` function to run the benchmarks.
///
/// [entryPoint] is the path to the main app file that runs the benchmark. It
/// can be different (and typically is) from the production entry point of the
/// app.
///
/// [benchmarkServerPort] is the port this benchmark server serves the app on.
/// By default uses [defaultBenchmarkServerPort].
///
/// [chromeDebugPort] is the port Chrome uses for DevTool Protocol used to
/// extract tracing data. By default uses [defaultChromeDebugPort].
///
/// If [headless] is true, runs Chrome without UI. In particular, this is
/// useful in environments (e.g. CI) that doesn't have a display.
///
/// If [treeShakeIcons] is false, '--no-tree-shake-icons' will be passed as a
/// build argument when building the benchmark app.
///
/// [compilationOptions] specify the compiler and renderer to use for the
/// benchmark app. This can either use dart2wasm & skwasm or
/// dart2js & canvaskit.
///
/// [benchmarkPath] specifies the path for the URL that will be loaded upon
/// opening the benchmark app in Chrome.
Future<BenchmarkResults> serveWebBenchmark({
  required io.Directory benchmarkAppDirectory,
  required String entryPoint,
  int benchmarkServerPort = defaultBenchmarkServerPort,
  int chromeDebugPort = defaultChromeDebugPort,
  bool headless = true,
  bool treeShakeIcons = true,
  CompilationOptions compilationOptions = const CompilationOptions.js(),
  String benchmarkPath = defaultInitialPath,
}) async {
  // Reduce logging level. Otherwise, package:webkit_inspection_protocol is way too spammy.
  Logger.root.level = Level.INFO;

  return BenchmarkServer(
    benchmarkAppDirectory: benchmarkAppDirectory,
    entryPoint: entryPoint,
    benchmarkServerPort: benchmarkServerPort,
    benchmarkPath: benchmarkPath,
    chromeDebugPort: chromeDebugPort,
    headless: headless,
    compilationOptions: compilationOptions,
    treeShakeIcons: treeShakeIcons,
  ).run();
}
