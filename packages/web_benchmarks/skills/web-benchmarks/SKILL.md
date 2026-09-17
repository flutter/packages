---
name: web-benchmarks
description: Set up and use the web_benchmarks harness to run, record, and analyze performance benchmarks for Flutter Web applications in Chrome.
---

# Setting Up and Using web_benchmarks

`web_benchmarks` is a benchmark harness for Flutter Web applications that runs benchmarks in Chrome, extracts performance traces via Chrome DevTools Protocol, and provides analysis utilities for comparing benchmark runs.

## 1. Installation

Add `web_benchmarks` as a `dev_dependency` in your Flutter web project's `pubspec.yaml`:

```yaml
dev_dependencies:
  web_benchmarks: ^1.0.0
```

## 2. Architecture: Client and Server

A web benchmark consists of two components:
1. **Client (Browser)**: Runs inside Chrome alongside your Flutter web app and executes user interactions or frame rendering tasks using `Recorder` classes (e.g., `WidgetRecorder`, `AppRecorder`).
2. **Server (Runner)**: Compiles and serves the Flutter web app, launches headless/automated Chrome, collects performance metrics, and outputs JSON results.

### Client Benchmark Example (`benchmark/web_benchmarks_client.dart`)

```dart
import 'package:flutter/material.dart';
import 'package:web_benchmarks/client.dart';

class MyWidgetRecorder extends WidgetRecorder {
  MyWidgetRecorder() : super(name: 'my_widget_benchmark');

  @override
  Widget createWidget() {
    return MaterialApp(
      home: Scaffold(
        body: ListView.builder(
          itemCount: 500,
          itemBuilder: (BuildContext context, int index) => ListTile(title: Text('Item $index')),
        ),
      ),
    );
  }

  @override
  Future<void> automate() async {
    // Scroll or interact with the widget under test
  }
}

Future<void> main() async {
  await runBenchmarks(<String, RecorderFactory>{
    'my_widget_benchmark': () => MyWidgetRecorder(),
  });
}
```

### Server Runner Example (`benchmark/run_benchmarks.dart`)

```dart
import 'dart:convert';
import 'dart:io';

import 'package:web_benchmarks/server.dart';

Future<void> main() async {
  final BenchmarkResults results = await serveWebBenchmark(
    benchmarkAppDirectory: Directory.current,
    entryPoint: 'benchmark/web_benchmarks_client.dart',
    useCanvasKit: true,
  );
  stdout.writeln(const JsonEncoder.withIndent('  ').convert(results.toJson()));
}
```

## 3. Analyzing Benchmark Results

Use `package:web_benchmarks/analysis.dart` to compute averages across runs or deltas against a baseline:

```dart
import 'dart:convert';
import 'dart:io';

import 'package:web_benchmarks/analysis.dart';

void analyzeRuns(String baselinePath, String testPath) {
  final BenchmarkResults baseline = BenchmarkResults.parse(
    jsonDecode(File(baselinePath).readAsStringSync()) as Map<String, Object?>,
  );
  final BenchmarkResults current = BenchmarkResults.parse(
    jsonDecode(File(testPath).readAsStringSync()) as Map<String, Object?>,
  );

  final BenchmarkResults delta = computeDelta(baseline, current);
  stdout.writeln(jsonEncode(delta.toJson()));
}
```
