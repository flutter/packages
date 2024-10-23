// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:js_interop';
import 'dart:ui';
import 'dart:ui_web' as ui_web;

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';
import 'package:web/web.dart' as html;

import 'common.dart';
import 'computations.dart';
import 'metrics.dart';

/// The number of samples from warm-up iterations.
///
/// We warm-up the benchmark prior to measuring to allow JIT and caches to settle.
const int _kWarmUpSampleCount = 200;

/// The total number of samples collected by a benchmark.
const int kTotalSampleCount = _kWarmUpSampleCount + kMeasuredSampleCount;

/// Measures the amount of time [action] takes.
Duration timeAction(VoidCallback action) {
  final Stopwatch stopwatch = Stopwatch()..start();
  action();
  stopwatch.stop();
  return stopwatch.elapsed;
}

/// A function that performs asynchronous work.
typedef AsyncVoidCallback = Future<void> Function();

/// An [AsyncVoidCallback] that doesn't do anything.
///
/// This is used just so we don't have to deal with null all over the place.
Future<void> _dummyAsyncVoidCallback() async {}

/// Runs the benchmark using the given [recorder].
///
/// Notifies about "set up" and "tear down" events via the [setUpAllDidRun]
/// and [tearDownAllWillRun] callbacks.
@sealed
class Runner {
  /// Creates a runner for the [recorder].
  ///
  /// All arguments must not be null.
  Runner({
    required this.recorder,
    this.setUpAllDidRun = _dummyAsyncVoidCallback,
    this.tearDownAllWillRun = _dummyAsyncVoidCallback,
  });

  /// The recorder that will run and record the benchmark.
  final Recorder recorder;

  /// Called immediately after [Recorder.setUpAll] future is resolved.
  ///
  /// This is useful, for example, to kick off a profiler or a tracer such that
  /// the "set up" computations are not included in the metrics.
  final AsyncVoidCallback setUpAllDidRun;

  /// Called just before calling [Recorder.tearDownAll].
  ///
  /// This is useful, for example, to stop a profiler or a tracer such that
  /// the "tear down" computations are not included in the metrics.
  final AsyncVoidCallback tearDownAllWillRun;

  /// Runs the benchmark and reports the results.
  Future<Profile> run() async {
    await recorder.setUpAll();
    await setUpAllDidRun();
    final Profile profile = await recorder.run();
    await tearDownAllWillRun();
    await recorder.tearDownAll();
    return profile;
  }
}

/// Base class for benchmark recorders.
///
/// Each benchmark recorder has a [name] and a [run] method at a minimum.
abstract class Recorder {
  Recorder._(this.name, this.isTracingEnabled);

  /// Whether this recorder requires tracing using Chrome's DevTools Protocol's
  /// "Tracing" API.
  final bool isTracingEnabled;

  /// The name of the benchmark.
  ///
  /// The results displayed in the Flutter Dashboard will use this name as a
  /// prefix.
  final String name;

  /// Returns the recorded profile.
  ///
  /// This value is only available while the benchmark is running.
  Profile? get profile;

  /// Whether the benchmark should continue running.
  ///
  /// Returns `false` if the benchmark collected enough data and it's time to
  /// stop.
  bool shouldContinue() => profile!.shouldContinue();

  /// Called once before all runs of this benchmark recorder.
  ///
  /// This is useful for doing one-time setup work that's needed for the
  /// benchmark.
  Future<void> setUpAll() async {}

  /// The implementation of the benchmark that will produce a [Profile].
  Future<Profile> run();

  /// Called once after all runs of this benchmark recorder.
  ///
  /// This is useful for doing one-time clean up work after the benchmark is
  /// complete.
  Future<void> tearDownAll() async {}
}

/// A recorder for benchmarking raw execution of Dart code.
///
/// This is useful for benchmarks that don't need frames or widgets.
///
/// Example:
///
/// ```
/// class BenchForLoop extends RawRecorder {
///   BenchForLoop() : super(name: benchmarkName);
///
///   static const String benchmarkName = 'for_loop';
///
///   @override
///   void body(Profile profile) {
///     profile.record('loop', () {
///       double x = 0;
///       for (int i = 0; i < 10000000; i++) {
///         x *= 1.5;
///       }
///     });
///   }
/// }
/// ```
abstract class RawRecorder extends Recorder {
  /// Creates a raw benchmark recorder with a name.
  ///
  /// [name] must not be null.
  RawRecorder({required String name}) : super._(name, false);

  /// The body of the benchmark.
  ///
  /// This is the part that records measurements of the benchmark.
  void body(Profile profile);

  @override
  Profile get profile => _profile;
  late Profile _profile;

  @override
  @nonVirtual
  Future<Profile> run() async {
    _profile = Profile(name: name);
    do {
      await Future<void>.delayed(Duration.zero);
      body(_profile);
    } while (shouldContinue());
    return _profile;
  }
}

/// A recorder for benchmarking interactions with the engine without the
/// framework by directly exercising [SceneBuilder].
///
/// To implement a benchmark, extend this class and implement [onDrawFrame].
///
/// Example:
///
/// ```
/// class BenchDrawCircle extends SceneBuilderRecorder {
///   BenchDrawCircle() : super(name: benchmarkName);
///
///   static const String benchmarkName = 'draw_circle';
///
///   @override
///   void onDrawFrame(SceneBuilder sceneBuilder) {
///     final PictureRecorder pictureRecorder = PictureRecorder();
///     final Canvas canvas = Canvas(pictureRecorder);
///     final Paint paint = Paint()..color = const Color.fromARGB(255, 255, 0, 0);
///     final Size windowSize = window.physicalSize;
///     canvas.drawCircle(windowSize.center(Offset.zero), 50.0, paint);
///     final Picture picture = pictureRecorder.endRecording();
///     sceneBuilder.addPicture(picture);
///   }
/// }
/// ```
abstract class SceneBuilderRecorder extends Recorder {
  /// Creates a [SceneBuilder] benchmark recorder.
  ///
  /// [name] must not be null.
  SceneBuilderRecorder({required String name}) : super._(name, true);

  @override
  Profile get profile => _profile;
  late Profile _profile;

  /// Called from [Window.onBeginFrame].
  @mustCallSuper
  void onBeginFrame() {}

  /// Called on every frame.
  ///
  /// An implementation should exercise the [sceneBuilder] to build a frame.
  /// However, it must not call [SceneBuilder.build] or [Window.render].
  /// Instead the benchmark harness will call them and time them appropriately.
  void onDrawFrame(SceneBuilder sceneBuilder);

  @override
  Future<Profile> run() {
    final Completer<Profile> profileCompleter = Completer<Profile>();
    _profile = Profile(name: name);

    PlatformDispatcher.instance.onBeginFrame = (_) {
      try {
        startMeasureFrame(profile);
        onBeginFrame();
      } catch (error, stackTrace) {
        profileCompleter.completeError(error, stackTrace);
        rethrow;
      }
    };
    PlatformDispatcher.instance.onDrawFrame = () {
      final FlutterView? view = PlatformDispatcher.instance.implicitView;
      try {
        _profile.record(BenchmarkMetric.drawFrame.label, () {
          final SceneBuilder sceneBuilder = SceneBuilder();
          onDrawFrame(sceneBuilder);
          _profile.record('sceneBuildDuration', () {
            final Scene scene = sceneBuilder.build();
            _profile.record('windowRenderDuration', () {
              assert(view != null,
                  'Cannot profile windowRenderDuration on a null View.');
              view!.render(scene);
            }, reported: false);
          }, reported: false);
        }, reported: true);
        endMeasureFrame();

        if (shouldContinue()) {
          PlatformDispatcher.instance.scheduleFrame();
        } else {
          profileCompleter.complete(_profile);
        }
      } catch (error, stackTrace) {
        profileCompleter.completeError(error, stackTrace);
        rethrow;
      }
    };
    PlatformDispatcher.instance.scheduleFrame();
    return profileCompleter.future;
  }
}

/// A recorder for benchmarking interactions with the framework by creating
/// widgets.
///
/// To implement a benchmark, extend this class and implement [createWidget].
///
/// Example:
///
/// ```
/// class BenchListView extends WidgetRecorder {
///   BenchListView() : super(name: benchmarkName);
///
///   static const String benchmarkName = 'bench_list_view';
///
///   @override
///   Widget createWidget() {
///     return Directionality(
///       textDirection: TextDirection.ltr,
///       child: _TestListViewWidget(),
///     );
///   }
/// }
///
/// class _TestListViewWidget extends StatefulWidget {
///   @override
///   State<StatefulWidget> createState() {
///     return _TestListViewWidgetState();
///   }
/// }
///
/// class _TestListViewWidgetState extends State<_TestListViewWidget> {
///   ScrollController scrollController;
///
///   @override
///   void initState() {
///     super.initState();
///     scrollController = ScrollController();
///     Timer.run(() async {
///       bool forward = true;
///       while (true) {
///         await scrollController.animateTo(
///           forward ? 300 : 0,
///           curve: Curves.linear,
///           duration: const Duration(seconds: 1),
///         );
///         forward = !forward;
///       }
///     });
///   }
///
///   @override
///   Widget build(BuildContext context) {
///     return ListView.builder(
///       controller: scrollController,
///       itemCount: 10000,
///       itemBuilder: (BuildContext context, int index) {
///         return Text('Item #$index');
///       },
///     );
///   }
/// }
/// ```
abstract class WidgetRecorder extends Recorder implements FrameRecorder {
  /// Creates a widget benchmark recorder.
  ///
  /// [name] must not be null.
  ///
  /// If [useCustomWarmUp] is true, delegates the benchmark warm-up to the
  /// benchmark implementation instead of using a built-in strategy. The
  /// benchmark is expected to call [Profile.stopWarmingUp] to signal that
  /// the warm-up phase is finished.
  WidgetRecorder({
    required String name,
    this.useCustomWarmUp = false,
  }) : super._(name, true);

  /// Creates a widget to be benchmarked.
  ///
  /// The widget must create its own animation to drive the benchmark. The
  /// animation should continue indefinitely. The benchmark harness will stop
  /// pumping frames automatically.
  Widget createWidget();

  final List<VoidCallback> _didStopCallbacks = <VoidCallback>[];

  @override
  void registerDidStop(VoidCallback fn) {
    _didStopCallbacks.add(fn);
  }

  @override
  late Profile profile;

  // This will be initialized in [run].
  late Completer<void> _runCompleter;

  /// Whether to delimit warm-up frames in a custom way.
  final bool useCustomWarmUp;

  late Stopwatch _drawFrameStopwatch;

  @override
  @mustCallSuper
  void frameWillDraw() {
    startMeasureFrame(profile);
    _drawFrameStopwatch = Stopwatch()..start();
  }

  @override
  @mustCallSuper
  void frameDidDraw() {
    endMeasureFrame();
    profile.addDataPoint(
      BenchmarkMetric.drawFrame.label,
      _drawFrameStopwatch.elapsed,
      reported: true,
    );

    if (shouldContinue()) {
      PlatformDispatcher.instance.scheduleFrame();
    } else {
      for (final VoidCallback fn in _didStopCallbacks) {
        fn();
      }
      _runCompleter.complete();
    }
  }

  @override
  void _onError(dynamic error, StackTrace? stackTrace) {
    _runCompleter.completeError(error as Object, stackTrace);
  }

  @override
  Future<Profile> run() async {
    _runCompleter = Completer<void>();
    final Profile localProfile =
        profile = Profile(name: name, useCustomWarmUp: useCustomWarmUp);
    final _RecordingWidgetsBinding binding =
        _RecordingWidgetsBinding.ensureInitialized();
    final Widget widget = createWidget();

    registerEngineBenchmarkValueListener(BenchmarkMetric.prerollFrame.label,
        (num value) {
      localProfile.addDataPoint(
        BenchmarkMetric.prerollFrame.label,
        Duration(microseconds: value.toInt()),
        reported: false,
      );
    });
    registerEngineBenchmarkValueListener(BenchmarkMetric.applyFrame.label,
        (num value) {
      localProfile.addDataPoint(
        BenchmarkMetric.applyFrame.label,
        Duration(microseconds: value.toInt()),
        reported: false,
      );
    });

    late void Function(List<FrameTiming> frameTimings) frameTimingsCallback;
    binding.addTimingsCallback(
        frameTimingsCallback = (List<FrameTiming> frameTimings) {
      for (final FrameTiming frameTiming in frameTimings) {
        localProfile.addDataPoint(
          BenchmarkMetric.flutterFrameTotalTime.label,
          frameTiming.totalSpan,
          reported: false,
        );
        localProfile.addDataPoint(
          BenchmarkMetric.flutterFrameBuildTime.label,
          frameTiming.buildDuration,
          reported: false,
        );
        localProfile.addDataPoint(
          BenchmarkMetric.flutterFrameRasterTime.label,
          frameTiming.rasterDuration,
          reported: false,
        );
      }
    });

    binding._beginRecording(this, widget);

    try {
      await _runCompleter.future;
      return localProfile;
    } finally {
      stopListeningToEngineBenchmarkValues(BenchmarkMetric.prerollFrame.label);
      stopListeningToEngineBenchmarkValues(BenchmarkMetric.applyFrame.label);
      binding.removeTimingsCallback(frameTimingsCallback);
    }
  }
}

/// A recorder for measuring the performance of building a widget from scratch
/// starting from an empty frame.
///
/// The recorder will call [createWidget] and render it, then it will pump
/// another frame that clears the screen. It repeats this process, measuring the
/// performance of frames that render the widget and ignoring the frames that
/// clear the screen.
abstract class WidgetBuildRecorder extends Recorder implements FrameRecorder {
  /// Creates a widget build benchmark recorder.
  ///
  /// [name] must not be null.
  WidgetBuildRecorder({required String name}) : super._(name, true);

  /// Creates a widget to be benchmarked.
  ///
  /// The widget is not expected to animate as we only care about construction
  /// of the widget. If you are interested in benchmarking an animation,
  /// consider using [WidgetRecorder].
  Widget createWidget();

  final List<VoidCallback> _didStopCallbacks = <VoidCallback>[];

  @override
  void registerDidStop(VoidCallback fn) {
    _didStopCallbacks.add(fn);
  }

  @override
  late Profile profile;
  Completer<void>? _runCompleter;

  late Stopwatch _drawFrameStopwatch;

  /// Whether in this frame we should call [createWidget] and render it.
  ///
  /// If false, then this frame will clear the screen.
  bool showWidget = true;

  /// The state that hosts the widget under test.
  late _WidgetBuildRecorderHostState _hostState;

  Widget? _getWidgetForFrame() {
    if (showWidget) {
      return createWidget();
    } else {
      return null;
    }
  }

  @override
  @mustCallSuper
  void frameWillDraw() {
    if (showWidget) {
      startMeasureFrame(profile);
      _drawFrameStopwatch = Stopwatch()..start();
    }
  }

  @override
  @mustCallSuper
  void frameDidDraw() {
    // Only record frames that show the widget.
    if (showWidget) {
      endMeasureFrame();
      profile.addDataPoint(
        BenchmarkMetric.drawFrame.label,
        _drawFrameStopwatch.elapsed,
        reported: true,
      );
    }

    if (shouldContinue()) {
      showWidget = !showWidget;
      _hostState._setStateTrampoline();
    } else {
      for (final VoidCallback fn in _didStopCallbacks) {
        fn();
      }
      _runCompleter!.complete();
    }
  }

  @override
  void _onError(dynamic error, StackTrace? stackTrace) {
    _runCompleter!.completeError(error as Object, stackTrace);
  }

  @override
  Future<Profile> run() async {
    _runCompleter = Completer<void>();
    final Profile localProfile = profile = Profile(name: name);
    final _RecordingWidgetsBinding binding =
        _RecordingWidgetsBinding.ensureInitialized();
    binding._beginRecording(this, _WidgetBuildRecorderHost(this));

    try {
      await _runCompleter!.future;
      return localProfile;
    } finally {
      _runCompleter = null;
    }
  }
}

/// Hosts widgets created by [WidgetBuildRecorder].
class _WidgetBuildRecorderHost extends StatefulWidget {
  const _WidgetBuildRecorderHost(this.recorder);

  final WidgetBuildRecorder recorder;

  @override
  State<StatefulWidget> createState() => _WidgetBuildRecorderHostState();
}

class _WidgetBuildRecorderHostState extends State<_WidgetBuildRecorderHost> {
  @override
  void initState() {
    super.initState();
    widget.recorder._hostState = this;
  }

  // This is just to bypass the @protected on setState.
  void _setStateTrampoline() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: widget.recorder._getWidgetForFrame(),
    );
  }
}

/// Base class for a profile collected from running a benchmark.
class Profile {
  /// Creates an empty profile.
  ///
  /// [name] and [useCustomWarmUp] must not be null.
  Profile({required this.name, this.useCustomWarmUp = false})
      : _isWarmingUp = useCustomWarmUp;

  /// The name of the benchmark that produced this profile.
  final String name;

  /// Whether to delimit warm-up frames in a custom way.
  final bool useCustomWarmUp;

  /// Whether we are measuring warm-up frames currently.
  bool get isWarmingUp => _isWarmingUp;

  bool _isWarmingUp;

  /// Stop the warm-up phase.
  ///
  /// Call this method only when [useCustomWarmUp] and [isWarmingUp] are both
  /// true.
  /// Call this method only once for each profile.
  void stopWarmingUp() {
    if (!useCustomWarmUp) {
      throw Exception(
          '`stopWarmingUp` should be used only when `useCustomWarmUp` is true.');
    } else if (!_isWarmingUp) {
      throw Exception('Warm-up already stopped.');
    } else {
      _isWarmingUp = false;
    }
  }

  /// This data will be used to display cards in the Flutter Dashboard.
  final Map<String, Timeseries> scoreData = <String, Timeseries>{};

  /// This data isn't displayed anywhere. It's stored for completeness purposes.
  final Map<String, dynamic> extraData = <String, dynamic>{};

  /// Invokes [callback] and records the duration of its execution under [key].
  Duration record(String key, VoidCallback callback, {required bool reported}) {
    final Duration duration = timeAction(callback);
    addDataPoint(key, duration, reported: reported);
    return duration;
  }

  /// Adds a timed sample to the timeseries corresponding to [key].
  ///
  /// Set [reported] to `true` to report the timeseries to the dashboard UI.
  ///
  /// Set [reported] to `false` to store the data, but not show it on the
  /// dashboard UI.
  void addDataPoint(String key, Duration duration, {required bool reported}) {
    scoreData
        .putIfAbsent(
          key,
          () => Timeseries(key, reported, useCustomWarmUp: useCustomWarmUp),
        )
        .add(duration.inMicroseconds.toDouble(), isWarmUpValue: isWarmingUp);
  }

  /// Decides whether the data collected so far is sufficient to stop, or
  /// whether the benchmark should continue collecting more data.
  ///
  /// The signals used are sample size, noise, and duration.
  ///
  /// If any of the timeseries doesn't satisfy the noise requirements, this
  /// method will return true (asking the benchmark to continue collecting
  /// data).
  bool shouldContinue() {
    // If there are no `Timeseries` in the `scoreData`, then we haven't
    // recorded anything yet. Don't stop.
    if (scoreData.isEmpty) {
      return true;
    }

    // We have recorded something, but do we have enough samples? If every
    // timeseries has collected enough samples, stop the benchmark.
    return !scoreData.keys
        .every((String key) => scoreData[key]!.count >= kTotalSampleCount);
  }

  /// Returns a JSON representation of the profile that will be sent to the
  /// server.
  Map<String, dynamic> toJson() {
    final List<String> scoreKeys = <String>[];
    final Map<String, dynamic> json = <String, dynamic>{
      'name': name,
      'scoreKeys': scoreKeys,
    };

    for (final String key in scoreData.keys) {
      final Timeseries timeseries = scoreData[key]!;

      if (timeseries.isReported) {
        scoreKeys.add('$key.${BenchmarkMetricComputation.average.name}');
        // Report `outlierRatio` rather than `outlierAverage`, because
        // the absolute value of outliers is less interesting than the
        // ratio.
        scoreKeys.add('$key.${BenchmarkMetricComputation.outlierRatio.name}');
      }

      final TimeseriesStats stats = timeseries.computeStats();
      json['$key.${BenchmarkMetricComputation.average.name}'] = stats.average;
      json['$key.${BenchmarkMetricComputation.outlierAverage.name}'] =
          stats.outlierAverage;
      json['$key.${BenchmarkMetricComputation.outlierRatio.name}'] =
          stats.outlierRatio;
      json['$key.${BenchmarkMetricComputation.noise.name}'] = stats.noise;
      for (final PercentileMetricComputation metric
          in PercentileMetricComputation.values) {
        json['$key.${metric.name}'] = stats.percentiles[metric.percentile];
      }
    }

    json.addAll(extraData);

    return json;
  }

  @override
  String toString() {
    final StringBuffer buffer = StringBuffer();
    buffer.writeln('name: $name');
    for (final String key in scoreData.keys) {
      final Timeseries timeseries = scoreData[key]!;
      final TimeseriesStats stats = timeseries.computeStats();
      buffer.writeln(stats.toString());
    }
    for (final String key in extraData.keys) {
      final dynamic value = extraData[key];
      if (value is List) {
        buffer.writeln('$key:');
        for (final dynamic item in value) {
          buffer.writeln(' - $item');
        }
      } else {
        buffer.writeln('$key: $value');
      }
    }
    return buffer.toString();
  }
}

/// Implemented by recorders that use [_RecordingWidgetsBinding] to receive
/// frame life-cycle calls.
abstract class FrameRecorder {
  /// Add a callback that will be called by the recorder when it stops recording.
  void registerDidStop(VoidCallback cb);

  /// Called just before calling [SchedulerBinding.handleDrawFrame].
  void frameWillDraw();

  /// Called immediately after calling [SchedulerBinding.handleDrawFrame].
  void frameDidDraw();

  /// Reports an error.
  ///
  /// The implementation is expected to halt benchmark execution as soon as possible.
  void _onError(dynamic error, StackTrace? stackTrace);
}

/// A variant of [WidgetsBinding] that collaborates with a [Recorder] to decide
/// when to stop pumping frames.
///
/// A normal [WidgetsBinding] typically always pumps frames whenever a widget
/// instructs it to do so by calling [scheduleFrame] (transitively via
/// `setState`). This binding will stop pumping new frames as soon as benchmark
/// parameters are satisfactory (e.g. when the metric noise levels become low
/// enough).
class _RecordingWidgetsBinding extends BindingBase
    with
        GestureBinding,
        SchedulerBinding,
        ServicesBinding,
        PaintingBinding,
        SemanticsBinding,
        RendererBinding,
        WidgetsBinding {
  @override
  void initInstances() {
    super.initInstances();
    _instance = this;
  }

  static _RecordingWidgetsBinding get instance =>
      BindingBase.checkInstance(_instance);
  static _RecordingWidgetsBinding? _instance;

  /// Makes an instance of [_RecordingWidgetsBinding] the current binding.
  static _RecordingWidgetsBinding ensureInitialized() {
    if (_instance == null) {
      _RecordingWidgetsBinding();
    }
    return _RecordingWidgetsBinding.instance;
  }

  // This will be not null when the benchmark is running.
  FrameRecorder? _recorder;
  bool _hasErrored = false;

  /// To short-circuit all frame lifecycle methods when the benchmark has
  /// stopped collecting data.
  bool _benchmarkStopped = false;

  void _beginRecording(FrameRecorder recorder, Widget widget) {
    if (_recorder != null) {
      throw Exception(
        'Cannot call _RecordingWidgetsBinding._beginRecording more than once',
      );
    }
    final FlutterExceptionHandler? originalOnError = FlutterError.onError;

    recorder.registerDidStop(() {
      _benchmarkStopped = true;
    });

    // Fail hard and fast on errors. Benchmarks should not have any errors.
    FlutterError.onError = (FlutterErrorDetails details) {
      _haltBenchmarkWithError(details.exception, details.stack);
      originalOnError!(details);
    };
    _recorder = recorder;
    runApp(widget);
  }

  void _haltBenchmarkWithError(dynamic error, StackTrace? stackTrace) {
    if (_hasErrored) {
      return;
    }
    _recorder!._onError(error, stackTrace);
    _hasErrored = true;
  }

  @override
  void handleBeginFrame(Duration? rawTimeStamp) {
    // Don't keep on truckin' if there's an error or the benchmark has stopped.
    if (_hasErrored || _benchmarkStopped) {
      return;
    }
    try {
      super.handleBeginFrame(rawTimeStamp);
    } catch (error, stackTrace) {
      _haltBenchmarkWithError(error, stackTrace);
      rethrow;
    }
  }

  @override
  void scheduleFrame() {
    // Don't keep on truckin' if there's an error or the benchmark has stopped.
    if (_hasErrored || _benchmarkStopped) {
      return;
    }
    super.scheduleFrame();
  }

  @override
  void handleDrawFrame() {
    // Don't keep on truckin' if there's an error or the benchmark has stopped.
    if (_hasErrored || _benchmarkStopped) {
      return;
    }
    try {
      _recorder!.frameWillDraw();
      super.handleDrawFrame();
      _recorder!.frameDidDraw();
    } catch (error, stackTrace) {
      _haltBenchmarkWithError(error, stackTrace);
      rethrow;
    }
  }
}

int _currentFrameNumber = 1;

/// If [_calledStartMeasureFrame] is true, we have called [startMeasureFrame]
/// but have not its pairing [endMeasureFrame] yet.
///
/// This flag ensures that [startMeasureFrame] and [endMeasureFrame] are always
/// called in pairs, with [startMeasureFrame] followed by [endMeasureFrame].
bool _calledStartMeasureFrame = false;

/// Whether we are recording a measured frame.
///
/// This flag ensures that we always stop measuring a frame if we
/// have started one. Because we want to skip warm-up frames, this flag
/// is necessary.
bool _isMeasuringFrame = false;

/// Adds a marker indication the beginning of frame rendering.
///
/// This adds an event to the performance trace used to find measured frames in
/// Chrome tracing data. The tracing data contains all frames, but some
/// benchmarks are only interested in a subset of frames. For example,
/// [WidgetBuildRecorder] only measures frames that build widgets, and ignores
/// frames that clear the screen.
///
/// Warm-up frames are not measured. If [profile.isWarmingUp] is true,
/// this function does nothing.
void startMeasureFrame(Profile profile) {
  if (_calledStartMeasureFrame) {
    throw Exception('`startMeasureFrame` called twice in a row.');
  }

  _calledStartMeasureFrame = true;

  if (!profile.isWarmingUp) {
    // Tell the browser to mark the beginning of the frame.
    html.window.performance.mark('measured_frame_start#$_currentFrameNumber');

    _isMeasuringFrame = true;
  }
}

/// Signals the end of a measured frame.
///
/// See [startMeasureFrame] for details on what this instrumentation is used
/// for.
///
/// Warm-up frames are not measured. If [profile.isWarmingUp] was true
/// when the corresponding [startMeasureFrame] was called,
/// this function does nothing.
void endMeasureFrame() {
  if (!_calledStartMeasureFrame) {
    throw Exception(
        '`startMeasureFrame` has not been called before calling `endMeasureFrame`');
  }

  _calledStartMeasureFrame = false;

  if (_isMeasuringFrame) {
    // Tell the browser to mark the end of the frame, and measure the duration.
    html.window.performance.mark('measured_frame_end#$_currentFrameNumber');
    html.window.performance.measure(
      'measured_frame',
      'measured_frame_start#$_currentFrameNumber'.toJS,
      'measured_frame_end#$_currentFrameNumber',
    );

    // Increment the current frame number.
    _currentFrameNumber += 1;

    _isMeasuringFrame = false;
  }
}

/// A function that receives a benchmark value from the framework.
typedef EngineBenchmarkValueListener = void Function(num value);

// Maps from a value label name to a listener.
final Map<String, EngineBenchmarkValueListener> _engineBenchmarkListeners =
    <String, EngineBenchmarkValueListener>{};

/// Registers a [listener] for engine benchmark values labeled by [name].
///
/// If another listener is already registered, overrides it.
void registerEngineBenchmarkValueListener(
  String name,
  EngineBenchmarkValueListener listener,
) {
  if (_engineBenchmarkListeners.containsKey(name)) {
    throw StateError(
      'A listener for "$name" is already registered.\n'
      'Call `stopListeningToEngineBenchmarkValues` to unregister the previous '
      'listener before registering a new one.',
    );
  }

  if (_engineBenchmarkListeners.isEmpty) {
    // The first listener is being registered. Register the global listener.
    ui_web.benchmarkValueCallback = _dispatchEngineBenchmarkValue;
  }
  _engineBenchmarkListeners[name] = listener;
}

/// Stops listening to engine benchmark values under labeled by [name].
void stopListeningToEngineBenchmarkValues(String name) {
  _engineBenchmarkListeners.remove(name);
  if (_engineBenchmarkListeners.isEmpty) {
    // The last listener unregistered. Remove the global listener.
    ui_web.benchmarkValueCallback = null;
  }
}

// Dispatches a benchmark value reported by the engine to the relevant listener.
//
// If there are no listeners registered for [name], ignores the value.
void _dispatchEngineBenchmarkValue(String name, double value) {
  final EngineBenchmarkValueListener? listener =
      _engineBenchmarkListeners[name];
  if (listener != null) {
    listener(value);
  }
}
