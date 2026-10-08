/// Glass Quality Adapter
///
/// A pure-Dart state machine that drives automatic `GlassQuality` adaptation
/// based on real device raster performance. Contains all logic for the three
/// phases of [GlassAdaptiveScope]:
///
///   **Phase 1 — Static probe** (~0 ms, at scope construction):
///   - `ImageFilter.isShaderFilterSupported == false` → force `minimal`
///   - `kIsWeb` → cap at `standard`
///   - Otherwise → proceed to Phase 2
///
///   **Phase 2 — Warm-up benchmark** (first 180 measured frames ≈ 3 s at 60 fps):
///   - Skips the first [GlassQualityAdapter.skipInitialFrames] frames (default
///     60 ≈ 1 s) to let shader compilation and first-route transitions settle.
///   - Collects `rasterDuration` via [SchedulerBinding.addTimingsCallback]
///   - Computes the P75 raster time across the collected frames
///   - P75 < 20 ms  → remain at [GlassQuality.premium]
///   - P75 20–28 ms → step to [GlassQuality.standard]
///   - P75 > 28 ms  → step to [GlassQuality.minimal]
///   - Transitions to Phase 3 once `skipInitialFrames + warmupFrames` have been seen
///
///   **Phase 3 — Runtime hysteresis** (ongoing, very low overhead):
///   - Maintains a rolling ring buffer of the last 120 raster durations
///   - Degrades one tier when P95 > targetFrameMs × 1.5 for 2 consecutive
///     sliding windows
///   - Upgrades one tier when P95 < targetFrameMs × 0.6 for 10 consecutive
///     sliding windows (only if `allowStepUp` is `true`)
///   - Hard cooldown: minimum 8 seconds between any quality change
///   - Degradation is 3× faster than recovery — jank is noticed immediately,
///     but quality recovery must be invisible (slow and stable)
///
/// **This class is internal — do NOT export from the barrel file.**
///
/// All logic is pure Dart (no widgets, no [BuildContext]). The adapter is
/// owned and started/stopped by the adaptive scope's internal state.
///
/// ```dart
/// final adapter = GlassQualityAdapter(
///   minQuality: GlassQuality.minimal,
///   maxQuality: GlassQuality.premium,
///   targetFrameMs: 16,
///   allowStepUp: false,
///   onQualityChanged: (from, to) { ... },
/// );
/// adapter.start(); // attaches SchedulerBinding callback
/// adapter.reset(); // call on AppLifecycleState.resumed
/// adapter.stop();  // detaches callback (dispose)
/// ```
library;

import 'dart:collection';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';

import '../types/glass_quality.dart';
import '../types/glass_quality_change_reason.dart';

// ---------------------------------------------------------------------------
// Enums and constants
// ---------------------------------------------------------------------------

/// Internal phase of the [GlassQualityAdapter] state machine.
enum AdaptivePhase {
  /// Checking static device capabilities at construction time.
  probe,

  /// Collecting raster timing data to estimate baseline device performance.
  warmup,

  /// Ongoing runtime monitoring with sliding-window hysteresis.
  runtime,
}

// ---------------------------------------------------------------------------
// GlassQualityAdapter
// ---------------------------------------------------------------------------

/// Pure-Dart state machine that automatically selects and adjusts
/// [GlassQuality] based on observed raster frame performance.
///
/// **Usage** — see file-level documentation above.
///
/// **Testing** — inject synthetic timings via [simulateFrameTimings] without
/// needing a real GPU raster loop:
///
/// ```dart
/// adapter.start();
/// adapter.simulateFrameTimings([
///   FakeFrameTiming(rasterUs: 25000), // 25 ms → over budget
/// ]);
/// ```
class GlassQualityAdapter {
  /// Creates a [GlassQualityAdapter].
  ///
  /// [onQualityChanged] is called on the Dart main thread whenever the
  /// effective quality changes. The callback receives `(from, to)`.
  ///
  /// [initialQuality] overrides both the session cache and Phase 2 — the
  /// adapter skips the warm-up benchmark and jumps directly to Phase 3 using
  /// the provided quality as its starting point. Use this to restore a quality
  /// level previously persisted to storage (e.g. `SharedPreferences`) so
  /// repeat launches skip the warm-up jank window entirely.
  GlassQualityAdapter({
    required this.minQuality,
    required this.maxQuality,
    required this.targetFrameMs,
    required this.allowStepUp,
    required void Function(GlassQuality from, GlassQuality to) onQualityChanged,
    this.initialQuality,
    this.warmupPremiumThresholdMs = 20.0,
    this.warmupStandardThresholdMs = 28.0,
    void Function(GlassQuality settled, double p75Ms, int frames)?
        onWarmupComplete,
    this.frostStep = false,
    void Function(bool frostEnabled)? onFrostChanged,
  })  : _onQualityChanged = onQualityChanged,
        _onWarmupComplete = onWarmupComplete,
        _onFrostChanged = onFrostChanged,
        _currentQuality = maxQuality;

  // ── Configuration ──────────────────────────────────────────────────────────

  /// The lowest quality tier the adapter may step down to.
  final GlassQuality minQuality;

  /// Whether premium steps through premium without frost on its way to and
  /// from standard.
  ///
  /// The iOS 27 frost ([LiquidGlassSettings.frost]) is the most expensive
  /// part of premium glass. With this on, the first step down from premium
  /// only switches the frost off ([frostEnabled] turns `false`) and keeps
  /// the premium shader, rim and lens; the next one goes to standard. On the
  /// way back up, standard steps to premium without frost first. Surfaces
  /// without frost look the same in both premium steps.
  final bool frostStep;

  /// The highest quality tier the adapter may step up to.
  final GlassQuality maxQuality;

  /// The target frame duration in milliseconds (e.g. 16 for 60 Hz, 8 for
  /// ProMotion / 120 Hz). Thresholds for degradation and upgrade are derived
  /// from this value.
  final int targetFrameMs;

  /// Whether the adapter may increase quality after sustained good performance.
  ///
  /// When `false`, quality can only stay the same or decrease for the lifetime
  /// of this adapter. A warm-up triggered by [reset] cannot restore a higher
  /// quality either; recreate the adapter to clear this restriction.
  final bool allowStepUp;

  /// The quality tier to start at, bypassing Phase 2 (the warm-up benchmark).
  ///
  /// When non-null, [start] skips the warm-up benchmark and jumps directly to
  /// Phase 3 (runtime hysteresis) using this quality as the starting point.
  ///
  /// Two use cases:
  /// - **Developer-provided persistence** — restore a quality previously saved
  ///   to `SharedPreferences` so repeat launches skip warmup jank entirely.
  /// - **In-session cache** — the static session cache is checked automatically
  ///   if this field is null, so scopes remounted within the same app process
  ///   skip Phase 2 without any extra code.
  final GlassQuality? initialQuality;

  /// The P75 warmup threshold (ms) **below which** the device is classified as
  /// capable of [GlassQuality.premium].
  ///
  /// Defaults to `20.0`. This threshold is set slightly higher than the 16.0 ms
  /// frame budget because Android GPU clock-scaling and JIT shader compilation
  /// frequently inflate timings during the initial warm-up phase (Phase 2), even
  /// on highly capable devices. Setting it to 20.0 ms avoids prematurely
  /// penalizing capable mid-range devices.
  ///
  /// If a device actually struggles to maintain premium performance, Phase 3
  /// runtime monitoring acts as a safety net and will step it down within ~4 s
  /// (2 windows of jank).
  ///
  /// Values ≥ this threshold (and ≤ [warmupStandardThresholdMs]) result in
  /// [GlassQuality.standard]; values above [warmupStandardThresholdMs] result
  /// in [GlassQuality.minimal].
  final double warmupPremiumThresholdMs;

  /// The P75 warmup threshold (ms) **at or below which** the device is
  /// classified as capable of [GlassQuality.standard] (when P75 ≥
  /// [warmupPremiumThresholdMs]).
  ///
  /// Defaults to `28.0`. Devices with P75 above this value are classified as
  /// [GlassQuality.minimal] (BackdropFilter-only, zero shader cost).
  ///
  /// Standard quality uses BackdropFilter blur without custom fragment shaders,
  /// which is safe for mid-range devices. Minimal should be reserved for
  /// genuinely incapable hardware (P75 > 28 ms). The production crashes
  /// (Mali GPU / Impeller) are shader-related (premium path) — standard
  /// quality does not trigger those code paths.
  final double warmupStandardThresholdMs;

  // ── Session cache ──────────────────────────────────────────────────────────

  /// In-session cache of the quality tier settled by Phase 2.
  ///
  /// Written when Phase 2 completes. On the next [start] call (e.g. the scope
  /// is disposed and remounted), the adapter skips Phase 2 and jumps directly
  /// to Phase 3 using the cached quality — eliminating repeat warmup jank
  /// within a single app process.
  ///
  /// Intentionally NOT persisted across cold starts. Developers who want
  /// cross-launch persistence should use [initialQuality] with a storage
  /// mechanism of their choice (e.g. `SharedPreferences`).
  static GlassQuality? _sessionSettledQuality;

  /// Clears the in-session quality cache.
  ///
  /// **For testing only.** Call between tests to prevent cache leakage across
  /// test cases.
  @visibleForTesting
  static void clearSessionCache() => _sessionSettledQuality = null;

  /// The currently cached quality for this session, or `null` if Phase 2 has
  /// not yet completed on any adapter instance.
  ///
  /// Used by the adaptive scope's internal state to seed its initial display quality so
  /// the first rendered frame matches the adapter's starting point, avoiding a
  /// one-frame flash from [maxQuality] to the cached lower value.
  static GlassQuality? get sessionSettledQuality => _sessionSettledQuality;

  /// Whether the adapter is using a previously settled quality (either from
  /// [initialQuality] or [_sessionSettledQuality]) and has skipped Phase 2.
  bool get usedCachedQuality => _usedCachedQuality;
  bool _usedCachedQuality = false;

  // ── Tunable constants (override in tests) ──────────────────────────────────

  /// Frames to skip at the very start of Phase 2 before collecting warmup
  /// data. This lets shader compilation, first-route transitions, and provider
  /// initialisation settle so they don't pollute the warmup benchmark.
  ///
  /// Raised to 90 (≈ 1.5 s at 60 Hz) to give Android GPU clock-scaling and
  /// shader-cache warm-up enough time to settle before benchmarking starts.
  /// Community data (P75 ≈ 17–18 ms on capable mid-range Android devices)
  /// showed that the original 60-frame skip was not long enough to clear
  /// shader-compile inflation on the Android/Vulkan/Impeller path.
  static int skipInitialFrames = 90;

  /// Frames to collect in Phase 2 (warm-up) before making the initial quality
  /// decision. Default: 180 ≈ 3 seconds at 60 Hz.
  static int warmupFrames = 180;

  /// Size of the rolling window used in Phase 3 for P95 calculation.
  /// Default: 120 ≈ 2 seconds at 60 Hz.
  static int windowSize = 120;

  /// Number of consecutive over-budget windows that trigger a quality
  /// step-down. Default: 2.
  static int degradeWindowCount = 2;

  /// Number of consecutive under-budget windows that trigger a quality
  /// step-up (only when [allowStepUp] is `true`). Default: 10.
  static int upgradeWindowCount = 10;

  /// Minimum time between consecutive quality changes.
  static Duration cooldownDuration = const Duration(seconds: 8);

  /// When `true`, the static-probe step (Phase 1) is skipped and the adapter
  /// proceeds directly to Phase 2 (warm-up) even on headless test VMs where
  /// [ImageFilter.isShaderFilterSupported] returns `false`.
  ///
  /// **For testing only.** Set this before calling [start] in any test that
  /// needs to exercise Phase 2 or Phase 3 logic.
  @visibleForTesting
  static bool skipStaticProbeForTesting = false;

  // ── Phase 2 — warm-up ──────────────────────────────────────────────────────

  final List<int> _warmupDurations = []; // raster durations in microseconds
  int _skippedWarmupFrames = 0; // frames dropped during the startup-skip window

  // ── Phase 3 — runtime ring buffer ─────────────────────────────────────────

  // We use a fixed-capacity queue for O(1) append/evict.
  final Queue<int> _window = Queue<int>();

  // Pre-allocated sort buffer — avoids heap allocation on every window
  // evaluation (every windowSize frames ≈ every 2 s). Filled from _window
  // before sorting in-place. Cleared in reset().
  List<int> _sortBuffer = [];

  int _overBudgetWindowCount = 0;
  int _underBudgetWindowCount = 0;
  int _windowFrameCount = 0; // frames into the current evaluation window
  DateTime? _lastChangeAt;

  // ── Diagnostic tracking (set before every _applyQuality call) ───────────

  /// The P75 raster time (ms) that informed the most recent Phase 2 decision.
  /// `null` until warmup completes, or after a Phase 3 runtime change.
  double? _lastP75Ms;

  /// The P95 raster time (ms) from the most recent Phase 3 window evaluation.
  /// `null` until Phase 3 fires its first quality change.
  double? _lastP95Ms;

  /// Cached P95 from the current/last window evaluation — used by step-down
  /// and step-up helpers which don't have direct access to the ring buffer.
  double? _lastComputedP95Ms;

  /// Number of frames measured when the most recent quality decision was made.
  int? _lastFramesMeasured;

  /// The reason for the most recent quality change.
  GlassQualityChangeReason _lastChangeReason =
      GlassQualityChangeReason.staticProbe;

  /// The P75 raster time (ms) from the most recent Phase 2 warmup decision.
  double? get lastP75Ms => _lastP75Ms;

  /// The P95 raster time (ms) from the most recent Phase 3 runtime decision.
  double? get lastP95Ms => _lastP95Ms;

  /// Frames measured when the most recent quality decision was made.
  int? get lastFramesMeasured => _lastFramesMeasured;

  /// The reason for the most recent quality change.
  GlassQualityChangeReason get lastChangeReason => _lastChangeReason;

  // ── State ──────────────────────────────────────────────────────────────────

  AdaptivePhase _phase = AdaptivePhase.probe;
  GlassQuality _currentQuality;
  bool _running = false;
  final void Function(GlassQuality from, GlassQuality to) _onQualityChanged;

  /// Always called at the end of Phase 2, regardless of whether quality
  /// changed. Receives the settled quality, P75 (ms), and frame count.
  ///
  /// Use this in the adaptive scope to emit a diagnostic even on
  /// fast devices that stay at [maxQuality] through warmup — those devices
  /// never fire [_onQualityChanged], so their P75 would otherwise be invisible.
  final void Function(GlassQuality settled, double p75Ms, int frames)?
      _onWarmupComplete;

  // ── Public API ─────────────────────────────────────────────────────────────

  /// The currently effective quality this adapter has decided on.
  GlassQuality get currentQuality => _currentQuality;

  /// Whether premium glass may draw its frost. Only ever `false` with
  /// [frostStep]; see there.
  bool get frostEnabled => _frostEnabled;
  bool _frostEnabled = true;
  final void Function(bool frostEnabled)? _onFrostChanged;

  /// The current internal phase (probe → warmup → runtime).
  AdaptivePhase get phase => _phase;

  /// Whether the adapter is currently collecting frame timings.
  bool get isRunning => _running;

  /// Starts the adapter.
  ///
  /// Runs Phase 1 (static probe) synchronously. If the probe does not force
  /// a terminal quality, registers a [SchedulerBinding.addTimingsCallback]
  /// and begins Phase 2 (warm-up).
  ///
  /// Safe to call multiple times — subsequent calls are no-ops if already
  /// running.
  void start() {
    if (_running) return;

    // Phase 1 — static probe
    _phase = AdaptivePhase.probe;
    if (!skipStaticProbeForTesting) {
      final forced = _staticProbe();
      if (forced != null) {
        _lastChangeReason = GlassQualityChangeReason.staticProbe;
        _lastP75Ms = null;
        _lastP95Ms = null;
        _lastFramesMeasured = 0;
        // Respect minQuality even when the static probe forces a low quality.
        // e.g. minQuality: GlassQuality.standard prevents fallback to minimal
        // on devices where isShaderFilterSupported is a false negative.
        _applyQuality(_floorQuality(forced, minQuality));
        // No frame callback needed — static probe gives us a definitive answer.
        return;
      }
    }

    // Check for a usable cached quality — either developer-provided
    // (initialQuality) or in-session cache (_sessionSettledQuality).
    // Developer-provided takes priority over the session cache.
    final cached = initialQuality ?? _sessionSettledQuality;
    if (cached != null) {
      // Apply the settled quality from the cache and skip Phase 2.
      // Keep it within [minQuality, maxQuality] in case the config changed.
      final clamped =
          _floorQuality(_capQuality(maxQuality, cached), minQuality);
      _lastChangeReason = GlassQualityChangeReason.restoredFromCache;
      _lastP75Ms = null;
      _lastP95Ms = null;
      _lastFramesMeasured = 0;
      _applyQuality(clamped);
      _phase = AdaptivePhase.runtime;
      _usedCachedQuality = true;
      _running = true;
      SchedulerBinding.instance.addTimingsCallback(_onFrameTimings);
      return;
    }

    // Phase 2 — warm-up begins (no cache available)
    _phase = AdaptivePhase.warmup;
    _running = true;
    SchedulerBinding.instance.addTimingsCallback(_onFrameTimings);
  }

  /// Stops the adapter and detaches its frame timing callback.
  ///
  /// Call in your widget's `dispose()` method.
  void stop() {
    if (!_running) return;
    _running = false;
    SchedulerBinding.instance.removeTimingsCallback(_onFrameTimings);
  }

  /// Resets the adapter to Phase 2 and clears all accumulated data.
  ///
  /// Call when the app resumes from background (thermal recovery). The warm-up
  /// benchmark re-runs from scratch; the current quality is preserved until the
  /// new benchmark completes, at which point it may change.
  ///
  /// If the adapter was stopped, this restarts it.
  void reset() {
    _warmupDurations.clear();
    _window.clear();
    _sortBuffer = [];
    _overBudgetWindowCount = 0;
    _underBudgetWindowCount = 0;
    _windowFrameCount = 0;
    _lastChangeAt = null;
    _skippedWarmupFrames = 0; // restart the startup-skip window
    _usedCachedQuality = false; // accurate: we are re-running Phase 2

    if (_running) {
      // Already running — just reset to warm-up phase without toggling callback.
      _phase = AdaptivePhase.warmup;
    } else {
      // Not running (e.g. tests, or after a static-probe terminal result).
      // Just reset the phase; start() may be called later by the widget.
      _phase = AdaptivePhase.warmup;
    }
  }

  /// Injects synthetic [FrameTiming] data directly into the phase handlers,
  /// bypassing the [SchedulerBinding] listener registration.
  ///
  /// **For testing only.** Allows unit tests to exercise Phase 2 and Phase 3
  /// logic without a real GPU raster loop or a widget binding.
  ///
  /// If the adapter is still in the [AdaptivePhase.probe] phase (i.e. [start]
  /// was never called), this automatically advances to [AdaptivePhase.warmup]
  /// before processing the timings.
  ///
  /// ```dart
  /// final adapter = GlassQualityAdapter(...);
  /// adapter.simulateFrameTimings(_frames(180, 15000)); // 15 ms → standard
  /// expect(adapter.currentQuality, GlassQuality.standard);
  /// ```
  @visibleForTesting
  void simulateFrameTimings(List<FrameTiming> timings) {
    // Auto-advance out of probe so tests don't need to call start().
    if (_phase == AdaptivePhase.probe) {
      _phase = AdaptivePhase.warmup;
    }
    for (final timing in timings) {
      final rasterUs = timing.rasterDuration.inMicroseconds;
      if (_phase == AdaptivePhase.warmup) {
        _processWarmupFrame(rasterUs);
      } else if (_phase == AdaptivePhase.runtime) {
        _processRuntimeFrame(rasterUs);
      }
    }
  }

  // ── Phase 1 — static probe ─────────────────────────────────────────────────

  /// Returns a forced quality if the device can't support higher tiers, or
  /// `null` if we should proceed to Phase 2.
  GlassQuality? _staticProbe() {
    // No custom shader support (e.g. software renderer, some broken Android
    // drivers) — force minimal: BackdropFilter only, zero shader cost.
    if (!ui.ImageFilter.isShaderFilterSupported) {
      return GlassQuality.minimal;
    }

    // On web, Windows, and Linux: Impeller uses WebGL / ANGLE (OpenGLESSDF)
    // where runtime GLSL compilation of complex multi-pass SDFs can block the
    // raster thread. Cap at standard so apps open instantly at 60/120fps with
    // crisp 2D liquid glass.
    if (kIsWeb ||
        defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.linux) {
      final capped = _capQuality(maxQuality, GlassQuality.standard);
      return capped == maxQuality ? null : capped;
    }

    return null; // No forced quality — proceed to warm-up.
  }

  // ── Phase 2 — warm-up ──────────────────────────────────────────────────────

  void _processWarmupFrame(int rasterUs) {
    // Drop the first `skipInitialFrames` frames so that shader compilation,
    // first-route animation and provider/localisation initialisation noise does
    // not pollute the warmup benchmark on otherwise capable devices.
    if (_skippedWarmupFrames < skipInitialFrames) {
      _skippedWarmupFrames++;
      return;
    }

    _warmupDurations.add(rasterUs);

    if (_warmupDurations.length < warmupFrames) return;

    // Warm-up complete — compute P75 and decide initial quality.
    final p75 = _percentile(_warmupDurations, 75);
    final p75Ms = p75 / 1000.0;

    final GlassQuality decided;
    // Warmup thresholds are intentionally more lenient than the 60-fps frame
    // budget (16 ms). Even after skipping the first 90 frames, Android GPU
    // clock-scaling and JIT warm-up can inflate P75 by 4–6 ms on otherwise
    // capable hardware — community data showed P75 ≈ 17–18 ms on mid-range
    // Android devices that sustain full premium quality at steady state.
    //
    //   P75 < warmupPremiumThresholdMs  → premium
    //   P75 ≤ warmupStandardThresholdMs → standard
    //   P75 > warmupStandardThresholdMs → minimal
    //
    // Both thresholds are user-configurable via GlassAdaptiveScopeConfig so
    // community members can experiment and report optimal values for their
    // hardware.
    //
    // Phase 3 runtime hysteresis will still step down quickly (2 windows,
    // ~4 s) if the device cannot actually sustain premium after warmup.
    if (p75Ms < warmupPremiumThresholdMs) {
      decided = _capQuality(maxQuality, maxQuality); // stay at ceiling
    } else if (p75Ms <= warmupStandardThresholdMs) {
      decided = _capQuality(maxQuality, GlassQuality.standard);
    } else {
      decided = _capQuality(maxQuality, GlassQuality.minimal);
    }

    // Apply the warm-up result while respecting [minQuality] and [allowStepUp].
    // When [allowStepUp] is false, warm-up may lower the current quality but
    // never raises it after the quality has been selected.
    final effective = allowStepUp
        ? _floorQuality(decided, minQuality)
        : _floorQuality(
            _capQuality(decided, _currentQuality),
            minQuality,
          );

    // Write to session cache so remounts within this app process skip Phase 2.
    _sessionSettledQuality = effective;

    // Record diagnostic data before applying quality.
    _lastChangeReason = GlassQualityChangeReason.warmupComplete;
    _lastP75Ms = p75Ms;
    _lastP95Ms = null;
    _lastFramesMeasured = _warmupDurations.length;

    _applyQuality(effective);

    // Transition to Phase 3.
    _phase = AdaptivePhase.runtime;
    _warmupDurations.clear();

    // Always notify about warmup completion — even when quality didn't change.
    // This lets the scope surface a diagnostic on fast devices that stay at
    // maxQuality throughout Phase 2, where _onQualityChanged never fires.
    _onWarmupComplete?.call(effective, p75Ms, _lastFramesMeasured!);
  }

  // ── Phase 3 — runtime hysteresis ──────────────────────────────────────────

  void _processRuntimeFrame(int rasterUs) {
    // Maintain rolling ring buffer.
    _window.addLast(rasterUs);
    if (_window.length > windowSize) _window.removeFirst();
    _windowFrameCount++;

    // Only evaluate the window once every windowSize frames (non-overlapping
    // windows). This ensures "3 consecutive windows" means 3 × windowSize
    // frames of data, not 3 individual frames, preventing runaway degradation.
    if (_window.length < windowSize) return;
    if (_windowFrameCount % windowSize != 0) return;

    // Reuse pre-allocated sort buffer to avoid heap allocation on the
    // frame timing callback path (GC pressure → frame drops).
    // We rebuild from scratch only when the window size changes (rare —
    // typically only on the first evaluation). Otherwise we overwrite in-place.
    if (_sortBuffer.length != _window.length) {
      _sortBuffer = List<int>.filled(_window.length, 0, growable: true);
    }
    var i = 0;
    for (final v in _window) {
      _sortBuffer[i++] = v;
    }
    final p95 = _percentileInPlace(_sortBuffer, 95);
    final p95Ms = p95 / 1000.0;
    final budgetMs = targetFrameMs.toDouble();

    // Cache the current P95 so _tryStepDown / _tryStepUp can record it.
    _lastComputedP95Ms = p95Ms;

    if (p95Ms > budgetMs * 1.5) {
      // Over budget
      _overBudgetWindowCount++;
      _underBudgetWindowCount = 0;
    } else if (p95Ms < budgetMs * 0.6) {
      // Comfortably under budget
      _underBudgetWindowCount++;
      _overBudgetWindowCount = 0;
    } else {
      // In the acceptable range — no change signal.
      //
      // A neutral window is not evidence of jank, so it must not erase
      // progress toward recovery. Resetting here made the step-up
      // unreachable in practice: recovery needs [upgradeWindowCount]
      // CONSECUTIVE under-budget windows, and because the measure is P95 —
      // a tail statistic — an ordinary scrolling list drifts into this band
      // often enough to zero the counter before it ever gets there. The
      // result was a one-way ratchet: a single transient cost (opening a
      // map, a heavy platform view, a route with a big image) demoted
      // quality for the rest of the session with no path back.
      //
      // Decaying leaves degradation exactly as responsive as before — an
      // over-budget window still zeroes this counter on the branch above —
      // while letting a mostly-good stretch accumulate toward recovery.
      _overBudgetWindowCount = 0;
      if (_underBudgetWindowCount > 0) _underBudgetWindowCount--;
    }

    if (_overBudgetWindowCount >= degradeWindowCount) {
      _overBudgetWindowCount = 0;
      _tryStepDown();
    } else if (_underBudgetWindowCount >= upgradeWindowCount && allowStepUp) {
      _underBudgetWindowCount = 0;
      _tryStepUp();
    }
  }

  void _tryStepDown() {
    if (!_canChange()) return;
    if (frostStep && _currentQuality == GlassQuality.premium && _frostEnabled) {
      _lastChangeReason = GlassQualityChangeReason.thermalDegradation;
      _lastP75Ms = null;
      _lastP95Ms = _lastComputedP95Ms;
      _lastFramesMeasured = windowSize;
      _setFrostEnabled(false);
      return;
    }
    final next = _stepDown(_currentQuality);
    if (next == _currentQuality) return; // already at minQuality
    _lastChangeReason = GlassQualityChangeReason.thermalDegradation;
    _lastP75Ms = null;
    _lastP95Ms = _lastComputedP95Ms;
    _lastFramesMeasured = windowSize;
    _applyQuality(next);
  }

  void _tryStepUp() {
    if (!_canChange()) return;
    if (frostStep &&
        _currentQuality == GlassQuality.premium &&
        !_frostEnabled) {
      _lastChangeReason = GlassQualityChangeReason.thermalRecovery;
      _lastP75Ms = null;
      _lastP95Ms = _lastComputedP95Ms;
      _lastFramesMeasured = windowSize;
      _setFrostEnabled(true);
      return;
    }
    final next = _stepUp(_currentQuality);
    if (next == _currentQuality) return; // already at maxQuality
    _lastChangeReason = GlassQualityChangeReason.thermalRecovery;
    _lastP75Ms = null;
    _lastP95Ms = _lastComputedP95Ms;
    _lastFramesMeasured = windowSize;
    // Back to premium without the frost first; it returns one step later.
    if (frostStep && next == GlassQuality.premium) _frostEnabled = false;
    _applyQuality(next);
  }

  void _setFrostEnabled(bool enabled) {
    if (_frostEnabled == enabled) return;
    _frostEnabled = enabled;
    _lastChangeAt = DateTime.now();
    _onFrostChanged?.call(enabled);
  }

  bool _canChange() {
    if (_lastChangeAt == null) return true;
    return DateTime.now().difference(_lastChangeAt!) >= cooldownDuration;
  }

  // ── Frame timing callback ─────────────────────────────────────────────────

  void _onFrameTimings(List<FrameTiming> timings) {
    if (!_running) return;

    for (final timing in timings) {
      final rasterUs = timing.rasterDuration.inMicroseconds;
      if (_phase == AdaptivePhase.warmup) {
        _processWarmupFrame(rasterUs);
      } else if (_phase == AdaptivePhase.runtime) {
        _processRuntimeFrame(rasterUs);
      }
    }
  }

  // ── State mutation ─────────────────────────────────────────────────────────

  void _applyQuality(GlassQuality newQuality) {
    if (newQuality == _currentQuality) return;
    final old = _currentQuality;
    _currentQuality = newQuality;
    _lastChangeAt = DateTime.now();
    _onQualityChanged(old, newQuality);
  }

  // ── Quality math helpers ───────────────────────────────────────────────────

  /// Steps quality one tier down (premium → standard → minimal).
  GlassQuality _stepDown(GlassQuality q) {
    switch (q) {
      case GlassQuality.premium:
        return _floorQuality(GlassQuality.standard, minQuality);
      case GlassQuality.standard:
        return _floorQuality(GlassQuality.minimal, minQuality);
      case GlassQuality.minimal:
        return GlassQuality.minimal; // already at bottom
    }
  }

  /// Steps quality one tier up (minimal → standard → premium).
  GlassQuality _stepUp(GlassQuality q) {
    switch (q) {
      case GlassQuality.minimal:
        return _capQuality(GlassQuality.standard, maxQuality);
      case GlassQuality.standard:
        return _capQuality(GlassQuality.premium, maxQuality);
      case GlassQuality.premium:
        return GlassQuality.premium; // already at top
    }
  }

  /// Maps a [GlassQuality] to a monotonic ordinal for comparison.
  ///
  /// The [GlassQuality] enum is defined as `standard=0, premium=1, minimal=2`,
  /// which is NOT monotonic with respect to quality. This helper normalises
  /// the ordering so that higher ordinal = higher quality:
  ///   - [GlassQuality.premium]  → 2 (best)
  ///   - [GlassQuality.standard] → 1
  ///   - [GlassQuality.minimal]  → 0 (worst)
  static int _qualityOrdinal(GlassQuality q) {
    switch (q) {
      case GlassQuality.premium:
        return 2;
      case GlassQuality.standard:
        return 1;
      case GlassQuality.minimal:
        return 0;
    }
  }

  /// Returns the lower of [requested] and [ceiling].
  ///
  /// "Lower" here means lower quality (descending: premium → standard → minimal).
  /// Capping prevents exceeding the quality ceiling.
  static GlassQuality _capQuality(
      GlassQuality requested, GlassQuality ceiling) {
    // If requested is BETTER than ceiling, cap it at ceiling.
    if (_qualityOrdinal(requested) > _qualityOrdinal(ceiling)) return ceiling;
    return requested;
  }

  /// Returns the higher of [requested] and [floor].
  ///
  /// "Higher" means higher quality. Flooring prevents going below the minimum.
  static GlassQuality _floorQuality(
      GlassQuality requested, GlassQuality floor) {
    // If requested is WORSE than floor, elevate it to floor.
    if (_qualityOrdinal(requested) < _qualityOrdinal(floor)) return floor;
    return requested;
  }

  // ── Percentile math ───────────────────────────────────────────────────────

  /// Computes the [percentile]-th percentile (0–100) from a list of integer
  /// values. The list is not modified.
  ///
  /// Uses the "nearest rank" definition — appropriate for frame timing data
  /// where we care about real observed samples, not interpolated values.
  ///
  /// Used by Phase 2 (warmup) where the list is discarded afterward.
  static int _percentile(List<int> data, int percentile) {
    assert(data.isNotEmpty);
    assert(percentile >= 0 && percentile <= 100);
    if (data.length == 1) return data.first;
    final rank = ((percentile / 100.0) * data.length).ceil();
    final index = (rank - 1).clamp(0, data.length - 1);
    final copy = List<int>.from(data, growable: false);
    return _quickSelect(copy, index);
  }

  /// In-place variant of [_percentile] — runs Quickselect on [data] directly in
  /// O(N) average time, avoiding heap allocations and O(N log N) sorting.
  /// Used by Phase 3 runtime with a pre-allocated sort buffer
  /// to eliminate GC pressure on the frame timing callback path.
  static int _percentileInPlace(List<int> data, int percentile) {
    assert(data.isNotEmpty);
    assert(percentile >= 0 && percentile <= 100);
    if (data.length == 1) return data.first;
    final rank = ((percentile / 100.0) * data.length).ceil();
    final index = (rank - 1).clamp(0, data.length - 1);
    return _quickSelect(data, index);
  }

  /// O(N) Quickselect algorithm to find the element that would be at [k] if sorted.
  static int _quickSelect(List<int> a, int k) {
    int left = 0, right = a.length - 1;
    while (left < right) {
      final pivot = a[(left + right) >> 1];
      int i = left, j = right;
      while (i <= j) {
        while (a[i] < pivot) {
          i++;
        }
        while (a[j] > pivot) {
          j--;
        }
        if (i <= j) {
          final tmp = a[i];
          a[i] = a[j];
          a[j] = tmp;
          i++;
          j--;
        }
      }
      if (k <= j) {
        right = j;
      } else if (k >= i) {
        left = i;
      } else {
        break;
      }
    }
    return a[k];
  }

  /// Visible for testing only: computes percentile using Quickselect.
  @visibleForTesting
  static int percentileForTesting(List<int> data, int percentile) =>
      _percentile(data, percentile);

  /// Visible for testing only: finds k-th smallest element using Quickselect.
  @visibleForTesting
  static int quickSelectForTesting(List<int> a, int k) => _quickSelect(a, k);
}
