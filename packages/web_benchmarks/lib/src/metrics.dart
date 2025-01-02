// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// The names for the metrics collected by the benchmark recorder.
enum BenchmarkMetric {
  /// The name for the benchmark metric that includes frame-related computations
  /// prior to submitting layer and picture operations to the underlying
  /// renderer, such as HTML and CanvasKit.
  ///
  /// During this phase we compute transforms, clips, and other information
  /// needed for rendering.
  prerollFrame('preroll_frame'),

  /// The name for the benchmark metric that includes submitting layer and
  /// picture information to the renderer.
  applyFrame('apply_frame'),

  /// The name for the benchmark metric that measures the time spent in
  /// [PlatformDispatcher]'s onDrawFrame callback.
  drawFrame('draw_frame'),

  /// The name for the benchmark metric that tracks the timespan between vsync
  /// start and raster finish for a Flutter frame.
  ///
  /// This value corresponds to [FrameTiming.totalSpan] from the Flutter Engine.
  flutterFrameTotalTime('flutter_frame.total_time'),

  /// The name for the benchmark metric that tracks the duration to build the
  /// Flutter frame on the Dart UI thread.
  ///
  /// This value corresponds to [FrameTiming.buildDuration] from the Flutter
  /// Engine.
  flutterFrameBuildTime('flutter_frame.build_time'),

  /// The name for the benchmark metric that tracks the duration to rasterize
  /// the Flutter frame on the Dart raster thread.
  ///
  /// This value corresponds to [FrameTiming.rasterDuration] from the Flutter
  /// Engine.
  flutterFrameRasterTime('flutter_frame.raster_time');

  const BenchmarkMetric(this.label);

  /// The metric name used in the recorded benchmark data.
  final String label;
}

/// The name for the benchmark metric that records the 'averageTotalUIFrameTime'
/// from the Blink trace summary.
const String totalUiFrameAverage = 'totalUiFrame.average';

/// Describes the values computed for each [BenchmarkMetric].
sealed class BenchmarkMetricComputation {
  const BenchmarkMetricComputation(this.name);

  /// The name of each metric computation.
  final String name;

  /// The name for the computed value tracking the average value of the measured
  /// samples without outliers.
  static const NamedMetricComputation average =
      NamedMetricComputation._('average');

  /// The name for the computed value tracking the average of outlier samples.
  static const NamedMetricComputation outlierAverage =
      NamedMetricComputation._('outlierAverage');

  /// The name for the computed value tracking the outlier average divided by
  /// the clean average.
  static const NamedMetricComputation outlierRatio =
      NamedMetricComputation._('outlierRatio');

  /// The name for the computed value tracking the noise as a multiple of the
  /// [average] value takes from clean samples.
  static const NamedMetricComputation noise = NamedMetricComputation._('noise');

  /// The name for the computed value tracking the 50th percentile value from
  /// the samples with outliers.
  static const PercentileMetricComputation p50 =
      PercentileMetricComputation._('p50', 0.5);

  /// The name for the computed value tracking the 90th percentile value from
  /// the samples with outliers.
  static const PercentileMetricComputation p90 =
      PercentileMetricComputation._('p90', 0.9);

  /// The name for the computed value tracking the 95th percentile value from
  /// the samples with outliers.
  static const PercentileMetricComputation p95 =
      PercentileMetricComputation._('p95', 0.95);

  /// All of the computed vales for each [BenchmarkMetric].
  static const List<BenchmarkMetricComputation> values =
      <BenchmarkMetricComputation>[
    average,
    outlierAverage,
    outlierRatio,
    noise,
    p50,
    p90,
    p95,
  ];
}

/// A [BenchmarkMetricComputation] with a descriptive name.
final class NamedMetricComputation extends BenchmarkMetricComputation {
  const NamedMetricComputation._(super.name);
}

/// A [BenchmarkMetricComputation] describing a percentile (p50, p90, etc.).
final class PercentileMetricComputation extends BenchmarkMetricComputation {
  const PercentileMetricComputation._(super.name, this.percentile)
      : assert(percentile >= 0.0 && percentile <= 1.0);

  /// The percentile value as a double.
  ///
  /// This value must be between 0.0 and 1.0.
  final double percentile;

  /// The percentile [BenchmarkMetricComputation]s computed for each benchmark
  /// metric.
  static const List<PercentileMetricComputation> values =
      <PercentileMetricComputation>[
    BenchmarkMetricComputation.p50,
    BenchmarkMetricComputation.p90,
    BenchmarkMetricComputation.p95,
  ];

  /// The percentile values as doubles computed for each benchmark metric.
  static List<double> percentilesAsDoubles = PercentileMetricComputation.values
      .map((PercentileMetricComputation value) => value.percentile)
      .toList();
}

/// The list of expected benchmark metrics for the current compilation mode, as
/// determined by the value of [useWasm].
List<BenchmarkMetric> expectedBenchmarkMetrics({required bool useWasm}) {
  return <BenchmarkMetric>[
    // The skwasm renderer doesn't have preroll or apply frame steps in its
    // rendering.
    if (!useWasm) ...<BenchmarkMetric>[
      BenchmarkMetric.prerollFrame,
      BenchmarkMetric.applyFrame,
    ],
    BenchmarkMetric.drawFrame,
    BenchmarkMetric.flutterFrameTotalTime,
    BenchmarkMetric.flutterFrameBuildTime,
    BenchmarkMetric.flutterFrameRasterTime,
  ];
}
