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
