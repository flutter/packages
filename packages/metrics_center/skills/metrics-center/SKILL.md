---
name: metrics-center
description: Set up and use the metrics_center package to collect, format, and publish performance benchmark metrics from CI bots to Skia Perf and Flutter dashboards.
---

# Setting Up and Using metrics_center

The `metrics_center` package provides a unified set of data models and destination clients to support multiple performance metric generators (such as LUCI bots, Cocoon device lab, Google Benchmark, or Firebase Test Lab) and publish results to metric destinations like Skia Perf.

## 1. Installation

Add `metrics_center` to your Dart project's `pubspec.yaml`:

```bash
dart pub add metrics_center
```

Or manually in `pubspec.yaml`:

```yaml
dependencies:
  metrics_center: ^1.0.15
```

## 2. Authentication and Environment Setup

Publishing metrics to `FlutterDestination` or `SkiaPerfDestination` requires Google Cloud authentication:
- **Service Account JSON**: Provide a decoded GCP service account credentials map to `makeFromCredentialsJson`.
- **OAuth Access Token**: In environments like Chromium/Flutter LUCI bots where only a short-lived OAuth token is available, use `makeFromAccessToken(token, projectId)`.

## 3. Usage and API Examples

Import the package in your Dart code:

```dart
import 'package:metrics_center/metrics_center.dart';
```

### Creating Generic and Flutter Engine Metric Points

Use `MetricPoint` for general performance metrics with arbitrary key-value tags, or `FlutterEngineMetricPoint` for Flutter engine benchmarks:

```dart
import 'package:metrics_center/metrics_center.dart';

void createMetricPoints() {
  // Generic MetricPoint with custom tags
  final MetricPoint frameTimePoint = MetricPoint(
    16.4,
    <String, String>{
      kNameKey: 'frame_rasterizer_time_ms',
      kGithubRepoKey: kFlutterFrameworkRepo,
      kGitRevisionKey: '8d53c8e278a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5',
      kUnitKey: 'ms',
      'device_type': 'Pixel_7_Pro',
    },
  );

  // Specialized FlutterEngineMetricPoint
  final FlutterEngineMetricPoint enginePoint = FlutterEngineMetricPoint(
    'scenebuilder_draw_time',
    4.21,
    '8d53c8e278a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5',
    moreTags: const <String, String>{
      'sub_result': 'average',
      kUnitKey: 'ms',
    },
  );

  print('Point ID: ${frameTimePoint.id}');
  print('Engine Point: $enginePoint');
}
```

### Publishing Metrics to `FlutterDestination`

Use `FlutterDestination` to upload a batch of `MetricPoint`s for a specific commit timestamp and CI task name:

```dart
import 'dart:convert';
import 'dart:io';
import 'package:metrics_center/metrics_center.dart';

Future<void> uploadBenchmarkResults(
  String credentialsFilePath,
  List<MetricPoint> points,
) async {
  final String jsonString = await File(credentialsFilePath).readAsString();
  final Map<String, dynamic> credentialsJson =
      jsonDecode(jsonString) as Map<String, dynamic>;

  final FlutterDestination destination =
      await FlutterDestination.makeFromCredentialsJson(
    credentialsJson,
    isTesting: false,
  );

  await destination.update(
    points,
    DateTime.now().toUtc(),
    'linux_android_pixel7_perf_test',
  );
}
```

### Parsing Google Benchmark JSON Files

`metrics_center` includes a parser to convert Google Benchmark JSON output directly into `MetricPoint` instances:

```dart
import 'package:metrics_center/metrics_center.dart';

Future<List<MetricPoint>> parseGoogleBenchmarkOutput(String jsonFilePath) async {
  final List<MetricPoint> points = await GoogleBenchmarkParser.parse(jsonFilePath);
  return points;
}
```
