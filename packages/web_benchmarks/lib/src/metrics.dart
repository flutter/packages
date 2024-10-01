// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// The metrics measured for each benchmark.
enum BenchmarkMetric {
  /// A benchmark metric that includes frame-related computations prior to
  /// submitting layer and picture operations to the underlying renderer, such as
  /// HTML and CanvasKit. During this phase we compute transforms, clips, and
  /// other information needed for rendering.
  prerollFrame('preroll_frame'),

  /// A benchmark metric that includes submitting layer and picture information
  /// to the renderer.
  applyFrame('apply_frame'),

  /// A benchmark metric that measures the time spent in [PlatformDispatcher]'s
  /// onDrawFrame callback.
  drawFrame('draw_frame'),

  /// A benchmark metric that tracks the timespan between vsync start and raster
  /// finish for a Flutter frame.
  ///
  /// This value corresponds to [FrameTiming.totalSpan] from the Flutter Engine.
  flutterFrameTotalTime('flutter_frame.total_time'),

  /// A benchmark metric that tracks the duration to build the Flutter frame on
  /// the Dart UI thread.
  ///
  /// This value corresponds to [FrameTiming.buildDuration] from the Flutter
  /// Engine.
  flutterFrameBuildTime('flutter_frame.build_time'),

  /// A benchmark metric that tracks the duration to rasterize the Flutter frame
  /// on the Dart raster thread.
  ///
  /// This value corresponds to [FrameTiming.rasterDuration] from the Flutter
  /// Engine.
  flutterFrameRasterTime('flutter_frame.raster_time');

  const BenchmarkMetric(this.label);

  /// The metric name used in the recorded benchmark data.
  final String label;
}
