/// Glass Performance Monitor
///
/// A debug/profile-only tool that watches raster frame durations while
/// [GlassQuality.premium] surfaces are active, emitting a single actionable
/// [FlutterError] warning when the GPU budget is consistently exceeded.
///
/// ## Zero production overhead
///
/// The monitor never registers with [SchedulerBinding] in release builds.
/// The `kReleaseMode` guard at `start` means no callbacks, no ring-buffer
/// allocations, and no CPU cycles in shipped apps.
///
/// ## Usage
///
/// Enabled automatically when you pass `enablePerformanceMonitor: true`
/// to [LiquidGlassWidgets.initialize] (which is the default in non-release
/// builds). You can also control it manually:
///
/// ```dart
/// GlassPerformanceMonitor.start();   // begin monitoring
/// GlassPerformanceMonitor.stop();    // stop and reset
/// GlassPerformanceMonitor.reset();   // clear warning latch, keep running
/// ```
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

/// Monitors raster frame durations and emits a developer warning when
/// [GlassQuality.premium] surfaces are active and GPU budget is exceeded.
///
/// This class is entirely static — it acts as a process-wide singleton so
/// that multiple glass widgets share one callback and one ring buffer.
class GlassPerformanceMonitor {
  GlassPerformanceMonitor._();

  // ── Configuration ──────────────────────────────────────────────────────────

  /// Number of consecutive frames that must exceed [rasterBudget] before the
  /// warning fires. Reduces false positives caused by animation spikes.
  ///
  /// Defaults to 60 (≈ 1 second at 60 fps).
  static int sustainedFrameThreshold = 60;

  /// Raster duration budget per frame. Frames that exceed this value count
  /// toward [sustainedFrameThreshold].
  ///
  /// Defaults to 16 ms (60 fps budget). On 120 Hz ProMotion displays you
  /// may wish to lower this to `Duration(microseconds: 8333)`.
  static Duration rasterBudget = const Duration(milliseconds: 16);

  // ── Internal state ─────────────────────────────────────────────────────────

  static bool _running = false;
  static bool _warningEmitted = false;

  /// Number of frames in a row that exceeded [rasterBudget] while at least
  /// one premium widget was active.
  static int _consecutiveOverBudget = 0;

  /// Number of [GlassQuality.premium] surfaces currently mounted.
  ///
  /// Incremented by [trackPremiumMount], decremented by [trackPremiumUnmount].
  /// The monitor stays silent when this is zero — avoiding false positives
  /// caused by other parts of the app being slow.
  static int _premiumCount = 0;

  // ── Public API ─────────────────────────────────────────────────────────────

  /// Whether the monitor is currently active.
  static bool get isRunning => _running;

  /// Whether the performance warning has already been emitted this session.
  static bool get warningEmitted => _warningEmitted;

  /// Number of premium glass surfaces currently mounted.
  static int get activePremiumCount => _premiumCount;

  /// Starts the monitor.
  ///
  /// No-op in release builds ([kReleaseMode] guard). Safe to call multiple
  /// times — subsequent calls are ignored if already running.
  static void start() {
    if (kReleaseMode || _running) return;
    _running = true;
    _consecutiveOverBudget = 0;
    SchedulerBinding.instance.addTimingsCallback(_onFrameTimings);
    if (kDebugMode) {
      debugPrint('[LiquidGlass] PerformanceMonitor started '
          '(budget: ${rasterBudget.inMilliseconds} ms, '
          'threshold: $sustainedFrameThreshold frames)');
    }
  }

  /// Stops the monitor and detaches the frame callback.
  ///
  /// The warning-emitted latch is preserved so the warning does not repeat
  /// if the monitor is restarted. Call [reset] to clear it.
  static void stop() {
    if (!_running) return;
    _running = false;
    SchedulerBinding.instance.removeTimingsCallback(_onFrameTimings);
  }

  /// Resets the consecutive-frame counter and the warning latch.
  ///
  /// Useful in tests or if you want to re-enable the warning after it fired.
  static void reset() {
    _consecutiveOverBudget = 0;
    _warningEmitted = false;
    _premiumCount = 0;
  }

  /// Injects synthetic [FrameTiming] data directly into [_onFrameTimings].
  ///
  /// **For testing only.** Allows unit tests to exercise the budget-exceeded
  /// and warning-emitted paths without requiring a real GPU raster loop.
  ///
  /// ```dart
  /// GlassPerformanceMonitor.trackPremiumMount();
  /// GlassPerformanceMonitor.sustainedFrameThreshold = 1;
  /// GlassPerformanceMonitor.simulateFrameTimings([
  ///   FrameTiming(rasterFinish: 100000 /* 100 ms */),
  /// ]);
  /// expect(GlassPerformanceMonitor.warningEmitted, isTrue);
  /// ```
  @visibleForTesting
  static void simulateFrameTimings(List<FrameTiming> timings) {
    _onFrameTimings(timings);
  }

  // ── Widget integration ─────────────────────────────────────────────────────

  /// Called by the internal premium glass tracker when a premium glass surface mounts.
  ///
  /// Internal — do not call directly.
  @visibleForTesting
  static void trackPremiumMount() {
    if (kReleaseMode) return;
    _premiumCount++;
  }

  /// Called by the internal premium glass tracker when a premium glass surface unmounts.
  ///
  /// Internal — do not call directly.
  @visibleForTesting
  static void trackPremiumUnmount() {
    if (kReleaseMode) return;
    _premiumCount = (_premiumCount - 1).clamp(0, 999);
  }

  // ── Frame callback ─────────────────────────────────────────────────────────

  static void _onFrameTimings(List<FrameTiming> timings) {
    // Silent when no premium surfaces are active — avoids blaming glass for
    // slowdowns caused by other parts of the app.
    if (_premiumCount == 0 || _warningEmitted) return;

    for (final timing in timings) {
      if (timing.rasterDuration > rasterBudget) {
        _consecutiveOverBudget++;
      } else {
        // Reset on any frame that comes in under budget — we only want to
        // warn about *sustained* slowdowns, not transient animation spikes.
        _consecutiveOverBudget = 0;
      }

      if (_consecutiveOverBudget >= sustainedFrameThreshold) {
        _emitWarning(timing.rasterDuration);
        return; // warning emitted, callback stays registered but is silenced
      }
    }
  }

  static void _emitWarning(Duration avgRaster) {
    _warningEmitted = true;
    final ms = (avgRaster.inMicroseconds / 1000).toStringAsFixed(1);

    FlutterError.reportError(
      FlutterErrorDetails(
        exception:
            Exception('GlassQuality.premium performance budget exceeded'),
        library: 'liquid_glass_widgets',
        context: ErrorDescription(
          'sustained raster frames > ${rasterBudget.inMilliseconds} ms '
          'while $_premiumCount premium glass surface(s) are active',
        ),
        informationCollector: () => [
          DiagnosticsNode.message(
            '\n'
            '════════ [LiquidGlass] Performance Warning ════════════════════\n'
            'GlassQuality.premium is sustaining raster frames over budget.\n'
            '\n'
            '  Measured raster duration  : $ms ms\n'
            '  Budget                    : ${rasterBudget.inMilliseconds} ms '
            '(${rasterBudget.inMilliseconds > 0 ? (1000 / rasterBudget.inMilliseconds).round() : 'N/A'} fps)\n'
            '  Active premium surfaces   : $_premiumCount\n'
            '  Consecutive over-budget   : $_consecutiveOverBudget frames\n'
            '\n'
            'This is consistent with pre-A15 GPU constraints (iPhone 12 and\n'
            'older, Pixel 5 and older). GlassQuality.premium targets A15 /\n'
            'iPhone 13+ for animated surfaces.\n'
            '\n'
            'Recommended fixes:\n'
            '  1. Use quality: GlassQuality.standard on this widget\n'
            '     → Lightweight shader, no texture capture, runs on any device\n'
            '  2. Use quality: GlassQuality.minimal for a shader-free fallback\n'
            '     → BackdropFilter only, zero custom shader cost\n'
            '  3. Set GlassThemeVariant(quality: GlassQuality.standard) globally\n'
            '     → All widgets default to standard unless explicitly overridden\n'
            '  4. On GlassTabBar.bottom: maskingQuality: MaskingQuality.off\n'
            '     → Disables dual-layer rendering (biggest single win on old GPUs)\n'
            '\n'
            'This warning only appears in debug/profile builds.\n'
            'To disable: LiquidGlassWidgets.initialize(enablePerformanceMonitor: false)\n'
            'To adjust threshold: GlassPerformanceMonitor.rasterBudget = Duration(...)\n'
            '═══════════════════════════════════════════════════════════════\n',
          ),
        ],
      ),
    );
  }
}

/// Minimal stateful widget that tracks one premium glass surface's
/// lifecycle with [GlassPerformanceMonitor].
///
/// Wrap any widget subtree that uses the Impeller premium path with this
/// to ensure the monitor's active-surface count stays accurate.
class PremiumGlassTracker extends StatefulWidget {
  /// Creates a tracker that notifies [GlassPerformanceMonitor] on mount/unmount.
  const PremiumGlassTracker({required this.child, super.key});

  /// The widget subtree to track.
  final Widget child;

  @override
  State<PremiumGlassTracker> createState() => _PremiumGlassTrackerState();
}

class _PremiumGlassTrackerState extends State<PremiumGlassTracker> {
  @override
  void initState() {
    super.initState();
    GlassPerformanceMonitor.trackPremiumMount();
  }

  @override
  void dispose() {
    GlassPerformanceMonitor.trackPremiumUnmount();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
