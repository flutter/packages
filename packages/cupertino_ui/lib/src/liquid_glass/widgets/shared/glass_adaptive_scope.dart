// ---------------------------------------------------------------------------
// GlassAdaptiveScope — v0.8.0
//
// Wraps any subtree and automatically adjusts GlassQuality based on real
// raster performance observed from SchedulerBinding frame timings.
//
// ## Three-phase adaptation
//
// Phase 1 — Static probe (synchronous, at scope mount):
//   Tests hard device capabilities. Forces minimal on software renderers and
//   broken shader drivers (ImageFilter.isShaderFilterSupported == false).
//   Caps at standard on web (kIsWeb).
//
// Phase 2 — Warm-up benchmark (first 180 frames ≈ 3 s at 60 fps):
//   Collects raster durations and computes P75 to estimate the device baseline.
//   P75 < 20 ms  → promote to maxQuality (premium by default)
//   P75 20-28 ms → step to standard
//   P75 > 28 ms  → step to minimal
//
//   All platforms (including Android) seed at maxQuality (premium by default).
//   If a device genuinely cannot sustain premium performance, Phase 2 will
//   demote it after the warm-up benchmark concludes.
//
// Phase 3 — Runtime hysteresis (ongoing, very low overhead):
//   Degrades quality when P95 > targetFrameMs × 1.5 for 2 consecutive windows
//   (GlassQualityAdapter.degradeWindowCount).
//   Upgrades quality (if allowStepUp) when P95 < targetFrameMs × 0.6
//   for 10 consecutive windows. Hard 8-second cooldown between any change.
//   Degradation is 5× faster than recovery — jank is noticed immediately;
//   recovery should be invisible and stable.
//
// ## Key design constraint
//
// GlassAdaptiveScope acts as a **quality ceiling**, not a floor.
// A widget that explicitly requests GlassQuality.minimal will not be upgraded
// to standard even when the scope is at premium. A widget that requests
// premium will be silently capped to standard if the scope has stepped down
// to standard.
//
// This ceiling is enforced by GlassThemeHelpers.resolveQuality, which reads
// GlassAdaptiveScopeData.maybeOf(context) after resolving the widget-level
// and inherited qualities.
//
// Widgets with an **explicit** quality parameter are capped too: an explicit
// `quality: GlassQuality.premium` means "premium if the device can handle
// it". To force a floor on a subtree regardless of the ceiling, wrap it in
// `GlassAdaptiveScope(minQuality: GlassQuality.premium, child: ...)`.
//
// ## Debug / Profile builds
//
// In debug and profile builds, GlassPerformanceMonitor continues to run
// alongside GlassAdaptiveScope. The monitor emits developer warnings; the
// scope acts on them. They share SchedulerBinding's callback list — Flutter
// handles multiple listeners correctly.
//
// ## Usage
//
// ```dart
// // Minimal — zero config, sensible defaults
// GlassAdaptiveScope(
//   child: MaterialApp(...),
// )
//
// // Advanced — full control
// GlassAdaptiveScope(
//   minQuality: GlassQuality.standard,  // never go below standard
//   maxQuality: GlassQuality.premium,
//   targetFrameMs: 8,                   // 120 Hz ProMotion target
//   allowStepUp: true,                  // allow recovery after throttle
//   onQualityChanged: (from, to) {
//     analytics.log('glass_quality', {'from': from.name, 'to': to.name});
//   },
//   child: child,
// )
//
// // Read from any descendant
// final quality = GlassAdaptiveScopeData.of(context).effectiveQuality;
// ```
// ---------------------------------------------------------------------------

import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

import '../../src/renderer/glass_frost_budget.dart';
import '../../types/glass_quality.dart';
import '../../types/glass_quality_change_reason.dart';
import '../../utils/glass_quality_adapter.dart';

// ---------------------------------------------------------------------------
// GlassAdaptiveScopeData — immutable data carried by the InheritedWidget
// ---------------------------------------------------------------------------

/// Data propagated by [GlassAdaptiveScope] to all glass widgets below it.
///
/// Obtain via [GlassAdaptiveScopeData.of] or [GlassAdaptiveScopeData.maybeOf].
@immutable
class GlassAdaptiveScopeData {
  /// Creates [GlassAdaptiveScopeData].
  const GlassAdaptiveScopeData({
    required this.effectiveQuality,
    required this.phase,
    this.frostEnabled = true,
  });

  /// Whether premium glass may draw its frost; `false` while the scope has
  /// stepped down to premium without frost (see
  /// [GlassAdaptiveScope.frostStep]).
  final bool frostEnabled;

  /// The current quality ceiling enforced by the scope.
  ///
  /// All glass widgets that inherit quality (those without an explicit
  /// `quality:` parameter) will be capped at this level via
  /// [GlassThemeHelpers.resolveQuality].
  final GlassQuality effectiveQuality;

  /// The current adaptation phase (probe → warmup → runtime).
  ///
  /// Useful for analytics or development UIs. Widgets should not change their
  /// behaviour based on this value.
  final AdaptivePhase phase;

  /// Returns the nearest [GlassAdaptiveScopeData] from the widget tree.
  ///
  /// Throws a [FlutterError] if no [GlassAdaptiveScope] ancestor is found.
  /// Use [maybeOf] in contexts where the scope may not be present.
  static GlassAdaptiveScopeData of(BuildContext context) {
    final data = maybeOf(context);
    assert(
      data != null,
      'GlassAdaptiveScopeData.of() was called on a context that does not have '
      'a GlassAdaptiveScope ancestor. Make sure GlassAdaptiveScope is placed '
      'above this widget in the tree.',
    );
    return data!;
  }

  /// Returns the nearest [GlassAdaptiveScopeData], or `null` if not found.
  ///
  /// Glass widgets use this variant internally — if no scope is present, the
  /// normal quality resolution chain runs unchanged.
  static GlassAdaptiveScopeData? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<_InheritedAdaptiveQuality>()
        ?.data;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GlassAdaptiveScopeData &&
          runtimeType == other.runtimeType &&
          effectiveQuality == other.effectiveQuality &&
          phase == other.phase &&
          frostEnabled == other.frostEnabled;

  @override
  int get hashCode => Object.hash(effectiveQuality, phase, frostEnabled);

  @override
  String toString() => 'GlassAdaptiveScopeData(quality: $effectiveQuality, '
      'phase: $phase, frostEnabled: $frostEnabled)';
}

// ---------------------------------------------------------------------------
// GlassAdaptiveDiagnostic — rich event emitted on quality changes
// ---------------------------------------------------------------------------

/// Rich diagnostic snapshot emitted by [GlassAdaptiveScope] whenever the
/// effective quality changes.
///
/// Passed to [GlassAdaptiveScope.onDiagnostic] and printed by
/// [GlassAdaptiveScope.debugLogDiagnostics]. Contains the full context of
/// *why* the quality changed — P75/P95 timing, phase, frame count, and reason.
///
/// **Use [reason] to filter analytics:**
/// - [GlassQualityChangeReason.warmupComplete] — the most useful event for
///   threshold calibration. [p75Ms] will be set.
/// - [GlassQualityChangeReason.thermalDegradation] — thermal throttle detected.
///   [p95Ms] will be set.
/// - [GlassQualityChangeReason.restoredFromCache] — skip in analytics; this
///   fires on every remount and carries no new timing data.
@immutable
class GlassAdaptiveDiagnostic {
  /// Creates a [GlassAdaptiveDiagnostic].
  const GlassAdaptiveDiagnostic({
    required this.from,
    required this.to,
    required this.reason,
    required this.phase,
    this.p75Ms,
    this.p95Ms,
    this.framesMeasured,
  });

  /// The quality tier before the change.
  final GlassQuality from;

  /// The quality tier after the change.
  final GlassQuality to;

  /// What triggered this quality change.
  final GlassQualityChangeReason reason;

  /// The adaptation phase at the moment of the change.
  final AdaptivePhase phase;

  /// The P75 raster time (ms) measured during Phase 2 warm-up.
  ///
  /// Only set when [reason] is [GlassQualityChangeReason.warmupComplete].
  /// This is the threshold calibration data point — please post it to the
  /// [community discussion](https://github.com/sdegenaar/liquid_glass_widgets/discussions).
  final double? p75Ms;

  /// The P95 raster time (ms) from the Phase 3 window that triggered this change.
  ///
  /// Only set when [reason] is [GlassQualityChangeReason.thermalDegradation]
  /// or [GlassQualityChangeReason.thermalRecovery].
  final double? p95Ms;

  /// Number of frames measured to reach this decision.
  ///
  /// Equals [GlassQualityAdapter.warmupFrames] for [GlassQualityChangeReason.warmupComplete]
  /// and [GlassQualityAdapter.windowSize] for Phase 3 changes.
  final int? framesMeasured;

  @override
  String toString() {
    final buf = StringBuffer()
      ..write('GlassAdaptiveDiagnostic(')
      ..write('${from.name}\u2192${to.name}')
      ..write(', reason: ${reason.name}')
      ..write(', phase: ${phase.name}');
    if (p75Ms != null) buf.write(', p75: ${p75Ms!.toStringAsFixed(1)}ms');
    if (p95Ms != null) buf.write(', p95: ${p95Ms!.toStringAsFixed(1)}ms');
    if (framesMeasured != null) buf.write(', frames: $framesMeasured');
    buf.write(')');
    return buf.toString();
  }
}

// ---------------------------------------------------------------------------
// GlassAdaptiveScopeConfig — bundled configuration value object
// ---------------------------------------------------------------------------

/// Bundles all [GlassAdaptiveScope] configuration into a single, portable
/// value object.
///
/// **Experimental** — this API is available in 0.8.0 for community feedback.
/// Phase 2 timing thresholds (12 ms / 20 ms P75) have been validated by
/// reasoning but not yet by broad real-device data. If you observe unexpected
/// quality degradation or promotion, please file an issue with your device
/// model, raster timings (from Flutter DevTools), and the quality tier you
/// expected vs received.
///
/// Use this when passing scope configuration through an API that cannot
/// accept individual widget parameters directly — e.g. [LiquidGlassWidgets.wrap]:
///
/// ```dart
/// runApp(LiquidGlassWidgets.wrap(
///   const MyApp(),
///   adaptiveQuality: true,
///   adaptiveConfig: GlassAdaptiveScopeConfig(
///     initialQuality: GlassQuality.standard, // earn your way up to premium
///     allowStepUp: true,
///   ),
/// ));
/// ```
///
/// All fields mirror the corresponding parameters on [GlassAdaptiveScope].
@immutable
class GlassAdaptiveScopeConfig {
  /// Creates a [GlassAdaptiveScopeConfig] with sensible defaults.
  const GlassAdaptiveScopeConfig({
    this.minQuality = GlassQuality.minimal,
    this.maxQuality = GlassQuality.premium,
    this.initialQuality,
    this.targetFrameMs = 16,
    this.allowStepUp = true,
    this.warmupPremiumThresholdMs = 20.0,
    this.warmupStandardThresholdMs = 28.0,
    this.frostStep = false,
    this.onQualityChanged,
    this.onDiagnostic,
    this.debugLogDiagnostics = false,
  });

  /// Whether premium steps through premium without frost on its way to and
  /// from standard. Defaults to `false`.
  ///
  /// The iOS 27 frost ([LiquidGlassSettings.frost]) is the most expensive part
  /// of premium glass. With this on, the first step down from premium only
  /// switches the frost off, standing in a regular blur for it, and keeps the
  /// premium lens, rim and highlight; the next step goes to standard.
  /// Recovery takes the same two steps back. Glass without a frost looks the
  /// same in both premium steps.
  final bool frostStep;

  /// The lowest quality tier the scope will ever enforce.
  /// Defaults to [GlassQuality.minimal].
  final GlassQuality minQuality;

  /// The highest quality tier the scope may use.
  /// Defaults to [GlassQuality.premium].
  final GlassQuality maxQuality;

  /// The quality to display before the warm-up benchmark completes.
  /// When null (the default), the scope determines the best safe quality
  /// (maxQuality on Apple, standard on Android).
  ///
  /// **Warning for Android**: Forcing this to [GlassQuality.premium] bypasses
  /// the conservative seeding. While `LiquidGlassWidgets.initialize()` protects
  /// against ANRs by pre-compiling the shaders, if you disable warm-up
  /// (`warmUpMode: GlassWarmUpMode.never`), forcing premium on
  /// frame 1 may cause a severe stutter or ANR on GLES-only Android devices.
  final GlassQuality? initialQuality;

  /// The raster frame duration target in milliseconds. Defaults to `16` (60 fps).
  final int targetFrameMs;

  /// Whether the scope may increase quality after sustained good performance.
  /// Defaults to `true`.
  ///
  /// When enabled, recovery requires 10 consecutive under-budget windows
  /// (about 20 seconds) plus an 8-second cooldown, keeping the transition
  /// stable and unobtrusive.
  final bool allowStepUp;

  /// The P75 warmup threshold (ms) below which the device is classified as
  /// capable of [GlassQuality.premium]. Defaults to `20.0`.
  ///
  /// **Community calibration param** — if the default causes incorrect
  /// degradation on your hardware, try raising this (e.g. to `24.0`) and
  /// post your P75 from [GlassAdaptiveDiagnostic.p75Ms] along with your device
  /// model to the [discussions](https://github.com/sdegenaar/liquid_glass_widgets/discussions).
  final double warmupPremiumThresholdMs;

  /// The P75 warmup threshold (ms) at or below which the device is classified
  /// as capable of [GlassQuality.standard] (when above [warmupPremiumThresholdMs]).
  /// Defaults to `28.0`.
  ///
  /// Devices with P75 above this value are classified as [GlassQuality.minimal].
  final double warmupStandardThresholdMs;

  /// Called whenever the effective quality tier changes.
  final void Function(GlassQuality from, GlassQuality to)? onQualityChanged;

  /// Called with rich diagnostic data whenever the effective quality changes.
  ///
  /// Provides [GlassAdaptiveDiagnostic] with P75/P95 timing, reason, phase,
  /// and frame count. Useful for analytics and for posting to the
  /// [Threshold Calibration Discussion](https://github.com/sdegenaar/liquid_glass_widgets/discussions).
  ///
  /// See also [debugLogDiagnostics] for a zero-wiring alternative.
  final void Function(GlassAdaptiveDiagnostic)? onDiagnostic;

  /// When `true`, prints a structured diagnostic log to the console on every
  /// quality change — debug builds only (no-op in release/profile).
  ///
  /// Zero setup required. Add this to quickly capture data for bug reports:
  ///
  /// ```dart
  /// GlassAdaptiveScopeConfig(debugLogDiagnostics: true)
  /// ```
  ///
  /// Defaults to `false`.
  final bool debugLogDiagnostics;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GlassAdaptiveScopeConfig &&
          runtimeType == other.runtimeType &&
          minQuality == other.minQuality &&
          maxQuality == other.maxQuality &&
          initialQuality == other.initialQuality &&
          targetFrameMs == other.targetFrameMs &&
          allowStepUp == other.allowStepUp &&
          warmupPremiumThresholdMs == other.warmupPremiumThresholdMs &&
          warmupStandardThresholdMs == other.warmupStandardThresholdMs &&
          frostStep == other.frostStep &&
          debugLogDiagnostics == other.debugLogDiagnostics;

  @override
  int get hashCode => Object.hash(
        minQuality,
        maxQuality,
        initialQuality,
        targetFrameMs,
        allowStepUp,
        warmupPremiumThresholdMs,
        warmupStandardThresholdMs,
        frostStep,
        debugLogDiagnostics,
      );
}

// ---------------------------------------------------------------------------
// GlassAdaptiveScope — public widget
// ---------------------------------------------------------------------------

/// Automatically adjusts [GlassQuality] for its subtree based on real device
/// raster performance, handling three scenarios developers can't easily test:
///
/// - **Broken/slow shader drivers** (Pixel 4a, Galaxy A22 class devices):
///   detected in Phase 1 (static probe) and capped immediately.
/// - **Warm-up jank** ("wrong quality at startup"):
///   resolved by Phase 2 benchmark over the first 180 frames.
/// - **Thermal throttling** ("fine at launch, janky after 10 minutes"):
///   detected and corrected by Phase 3 runtime hysteresis.
///
/// The scope acts as a **quality ceiling** — it caps inherited and explicit
/// `quality:` widget parameters alike, and never raises them. See the file-level
/// documentation for the complete architecture description.
///
/// **Experimental** — available in 0.8.0 for community feedback. The Phase 2
/// timing thresholds (P75 < 20 ms → premium, 20–28 ms → standard, > 28 ms →
/// minimal) were updated in 0.9.6 based on real-device community data showing
/// that Android GPU clock-scaling and shader-cache inflation can raise P75 by
/// 4–6 ms on capable mid-range devices during the warmup window. If you
/// observe unexpected behaviour, please file an issue with your device model
/// and raster timings.
///
/// ```dart
/// GlassAdaptiveScope(
///   child: MaterialApp(home: MyHome()),
/// )
/// ```
class GlassAdaptiveScope extends StatefulWidget {
  /// Creates a [GlassAdaptiveScope].
  ///
  /// [child] is required. All other parameters have sensible defaults.
  const GlassAdaptiveScope({
    required this.child,
    this.minQuality = GlassQuality.minimal,
    this.maxQuality = GlassQuality.premium,
    this.initialQuality,
    this.targetFrameMs = 16,
    this.allowStepUp = true,
    this.warmupPremiumThresholdMs = 20.0,
    this.warmupStandardThresholdMs = 28.0,
    this.frostStep = false,
    this.onQualityChanged,
    this.onDiagnostic,
    this.debugLogDiagnostics = false,
    super.key,
  });

  /// Whether premium steps through premium without frost on its way to and
  /// from standard. Defaults to `false`.
  ///
  /// The iOS 27 frost ([LiquidGlassSettings.frost]) is the most expensive part
  /// of premium glass. With this on, the first step down from premium only
  /// switches the frost off, standing in a regular blur for it, and keeps the
  /// premium lens, rim and highlight; the next step goes to standard.
  /// Recovery takes the same two steps back. Glass without a frost looks the
  /// same in both premium steps.
  final bool frostStep;

  /// The widget subtree that will have its glass quality automatically managed.
  final Widget child;

  /// The lowest quality tier the scope will ever enforce.
  ///
  /// Widgets in the subtree will never be capped lower than this value.
  /// Defaults to [GlassQuality.minimal] (allow full degradation to
  /// shader-free BackdropFilter mode).
  final GlassQuality minQuality;

  /// The highest quality tier the scope may use.
  ///
  /// The Phase 2 warm-up benchmark respects this ceiling — even on a fast
  /// device, quality will not exceed [maxQuality].
  /// Defaults to [GlassQuality.premium].
  final GlassQuality maxQuality;

  /// The quality to start at, skipping Phase 2 (the warm-up benchmark).
  ///
  /// When non-null, the adapter jumps directly to Phase 3 (runtime hysteresis)
  /// using this quality as the starting point — eliminating the ~3-second
  /// warm-up jank window on repeat launches.
  ///
  /// **Use this to restore a persisted quality across cold starts:**
  ///
  /// ```dart
  /// // In main.dart — persist settled quality to SharedPreferences:
  /// final prefs = await SharedPreferences.getInstance();
  /// final saved = prefs.getString('glass_quality');
  /// final initial = saved != null
  ///     ? GlassQuality.values.byName(saved)
  ///     : null; // null = run Phase 2 on first launch
  ///
  /// runApp(LiquidGlassWidgets.wrap(
  ///   const MyApp(),
  ///   adaptiveQuality: true,
  ///   adaptiveConfig: GlassAdaptiveScopeConfig(
  ///     initialQuality: initial,
  ///     allowStepUp: true,
  ///     onQualityChanged: (_, to) => prefs.setString('glass_quality', to.name),
  ///   ),
  /// ));
  /// ```
  ///
  /// Within a single app process, [GlassQualityAdapter._sessionSettledQuality]
  /// also auto-skips Phase 2 on remounts — no extra code required.
  ///
  /// If null, the scope will automatically determine the best starting quality:
  /// - All platforms (including Android) default to [maxQuality] for an immediate
  ///   premium experience (Best Foot Forward). If a device is too slow, Phase 2
  ///   will demote it after the warmup.
  ///
  /// **Warning for Android**: Forcing this to [GlassQuality.premium] bypasses
  /// the conservative seeding. While `LiquidGlassWidgets.initialize()` protects
  /// against ANRs by pre-compiling the shaders, if you disable warm-up
  /// (`warmUpMode: GlassWarmUpMode.never`), forcing premium on
  /// frame 1 may cause a severe stutter or ANR on GLES-only Android devices.
  final GlassQuality? initialQuality;

  /// The raster frame duration target in milliseconds.
  ///
  /// Used as the reference for Phase 3 thresholds:
  ///   - Degrade when P95 > [targetFrameMs] × 1.5
  ///   - Upgrade when P95 < [targetFrameMs] × 0.6 (if [allowStepUp])
  ///
  /// Set to `8` for 120 Hz ProMotion displays.
  /// Defaults to `16` (60 fps budget).
  final int targetFrameMs;

  /// Whether the scope may increase quality to [maxQuality] after sustained
  /// good performance, such as after thermal recovery or a conservative warm-up
  /// decision.
  ///
  /// Defaults to `true`. Recovery uses 10 consecutive under-budget windows
  /// (about 20 seconds) plus an 8-second cooldown to prevent oscillation.
  /// Set this to `false` to keep quality from increasing after warm-up.
  final bool allowStepUp;

  /// The P75 warmup threshold (ms) below which the device is classified as
  /// capable of [GlassQuality.premium]. Defaults to `20.0`.
  ///
  /// **Community calibration param** — if the default causes incorrect
  /// degradation on your hardware, try raising this (e.g. to `24.0`) and
  /// post your P75 from [GlassAdaptiveDiagnostic.p75Ms] along with your device
  /// model to the [discussions](https://github.com/sdegenaar/liquid_glass_widgets/discussions).
  final double warmupPremiumThresholdMs;

  /// The P75 warmup threshold (ms) at or below which the device is classified
  /// as capable of [GlassQuality.standard] (when above [warmupPremiumThresholdMs]).
  /// Defaults to `28.0`.
  ///
  /// Devices with P75 above this value are classified as [GlassQuality.minimal].
  final double warmupStandardThresholdMs;

  /// Called on the main thread whenever the effective quality changes.
  ///
  /// Receives `(GlassQuality from, GlassQuality to)`. Use [onDiagnostic] for
  /// richer context including P75/P95 timings and change reason.
  final void Function(GlassQuality from, GlassQuality to)? onQualityChanged;

  /// Called with a [GlassAdaptiveDiagnostic] whenever the effective quality
  /// changes. Provides P75/P95 raster timings, change reason, phase, and frame
  /// count — everything needed for bug reports and analytics.
  ///
  /// ```dart
  /// onDiagnostic: (d) {
  ///   if (d.reason == GlassQualityChangeReason.warmupComplete) {
  ///     analytics.log('glass_warmup', {'p75': d.p75Ms, 'quality': d.to.name});
  ///   }
  /// },
  /// ```
  final void Function(GlassAdaptiveDiagnostic)? onDiagnostic;

  /// When `true`, prints a structured diagnostic log on every quality change
  /// in debug builds (no-op in profile/release).
  ///
  /// ```dart
  /// GlassAdaptiveScope(debugLogDiagnostics: true, child: child)
  /// ```
  ///
  /// Defaults to `false`.
  final bool debugLogDiagnostics;

  @override
  State<GlassAdaptiveScope> createState() => _GlassAdaptiveScopeState();
}

class _GlassAdaptiveScopeState extends State<GlassAdaptiveScope>
    with WidgetsBindingObserver {
  late GlassQualityAdapter _adapter;
  late GlassQuality _effectiveQuality;
  bool _frostEnabled = true;

  @override
  void initState() {
    super.initState();
    // Seed _effectiveQuality using the same source priority the adapter will
    // use in start(): developer-provided initialQuality beats session cache
    // beats a conservative platform default.
    //
    // We seed at maxQuality on all platforms (Best Foot Forward).
    // The previous GLES shader compilation ANR risk is mitigated by the
    // `toImage()` warmup in LiquidGlassWidgets.initialize(). If a device
    // genuinely cannot sustain this, Phase 2 will demote it.
    _effectiveQuality = widget.initialQuality ??
        GlassQualityAdapter.sessionSettledQuality ??
        widget.maxQuality;
    _createAdapter();
    WidgetsBinding.instance.addObserver(this);
    _adapter.start();
  }

  /// Returns the safe cold-start quality when no [GlassAdaptiveScope.initialQuality]

  @override
  void didUpdateWidget(GlassAdaptiveScope oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Recreate the adapter if configuration changed.
    if (oldWidget.minQuality != widget.minQuality ||
        oldWidget.maxQuality != widget.maxQuality ||
        oldWidget.targetFrameMs != widget.targetFrameMs ||
        oldWidget.allowStepUp != widget.allowStepUp ||
        oldWidget.warmupPremiumThresholdMs != widget.warmupPremiumThresholdMs ||
        oldWidget.warmupStandardThresholdMs !=
            widget.warmupStandardThresholdMs ||
        oldWidget.frostStep != widget.frostStep) {
      _adapter.stop();
      // Mirror the same seeding logic as initState to avoid a one-frame flash.
      _effectiveQuality = widget.initialQuality ??
          GlassQualityAdapter.sessionSettledQuality ??
          widget.maxQuality;
      _frostEnabled = true;
      _createAdapter();
      _adapter.start();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _adapter.stop();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // On resume, reset the benchmark so thermal recovery is detected.
    // The adapter re-runs Phase 2 from a clean slate while preserving the
    // current quality until the new benchmark completes.
    if (state == AppLifecycleState.resumed) {
      _adapter.reset();
    }
  }

  void _createAdapter() {
    _adapter = GlassQualityAdapter(
      minQuality: widget.minQuality,
      maxQuality: widget.maxQuality,
      targetFrameMs: widget.targetFrameMs,
      allowStepUp: widget.allowStepUp,
      initialQuality: widget.initialQuality,
      warmupPremiumThresholdMs: widget.warmupPremiumThresholdMs,
      warmupStandardThresholdMs: widget.warmupStandardThresholdMs,
      onQualityChanged: _onQualityChanged,
      onWarmupComplete: _onWarmupComplete,
      frostStep: widget.frostStep,
      onFrostChanged: _onFrostChanged,
    );
  }

  void _onFrostChanged(bool enabled) {
    // Like _onQualityChanged: after the frame, not in the middle of it.
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() => _frostEnabled = enabled);
      if (widget.debugLogDiagnostics && kDebugMode) {
        debugPrint('GlassAdaptiveScope: frost ${enabled ? 'on' : 'off'} '
            '(P95 ${_adapter.lastP95Ms?.toStringAsFixed(1) ?? '-'} ms)');
      }
    });
    // The callback above needs a frame; on a screen that just went idle
    // there may be none coming.
    SchedulerBinding.instance.ensureVisualUpdate();
  }

  /// Called by the adapter whenever Phase 2 completes — even if quality
  /// didn't change. This is the critical path for fast devices (e.g. iPhone,
  /// flagship Android) that stay at [GlassQuality.premium] throughout warmup:
  /// [_onQualityChanged] never fires for them, so without this callback their
  /// P75 data would be completely invisible.
  void _onWarmupComplete(GlassQuality settled, double p75Ms, int frames) {
    // Snapshot synchronously: did quality change as a result of warmup?
    // If yes, _onQualityChanged already fired for this event and will emit the
    // diagnostic — avoid double-firing.
    final noQualityChange = _effectiveQuality == settled;

    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      // Nothing to update in state here — _effectiveQuality is already correct.
      // Only emit diagnostic for the no-change path; the changed path was
      // already handled by _onQualityChanged.
      if (noQualityChange) {
        final diagnostic = GlassAdaptiveDiagnostic(
          from: settled,
          to: settled,
          reason: GlassQualityChangeReason.warmupComplete,
          phase: AdaptivePhase.runtime,
          p75Ms: p75Ms,
          framesMeasured: frames,
        );
        widget.onDiagnostic?.call(diagnostic);
        if (widget.debugLogDiagnostics) _logDiagnostic(diagnostic);
      }
    });
  }

  void _onQualityChanged(GlassQuality from, GlassQuality to) {
    // Snapshot diagnostic fields from the adapter NOW (before the async gap)
    // since the adapter may process further frames in the meantime.
    final reason = _adapter.lastChangeReason;
    final p75 = _adapter.lastP75Ms;
    final p95 = _adapter.lastP95Ms;
    final frames = _adapter.lastFramesMeasured;
    final phase = _adapter.phase;

    // Defer setState to after the next frame draw to avoid causing the very
    // frame drop we are trying to fix. addPostFrameCallback is properly
    // drained in widget tests (unlike scheduleTask).
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() => _effectiveQuality = to);

      // Legacy callback — unchanged signature for backward compatibility.
      widget.onQualityChanged?.call(from, to);

      // Rich diagnostic callback.
      final diagnostic = GlassAdaptiveDiagnostic(
        from: from,
        to: to,
        reason: reason,
        phase: phase,
        p75Ms: p75,
        p95Ms: p95,
        framesMeasured: frames,
      );
      widget.onDiagnostic?.call(diagnostic);

      if (widget.debugLogDiagnostics) {
        _logDiagnostic(diagnostic);
      }
    });
  }

  /// Prints a structured diagnostic block. Always gated on [kDebugMode] —
  /// no output in profile or release builds regardless of the flag value.
  void _logDiagnostic(GlassAdaptiveDiagnostic d) {
    if (!kDebugMode) return;
    final noChange = d.from == d.to;
    final buf = StringBuffer()
      ..writeln(
          '┌─ 📊 GlassAdaptiveScope ─────────────────────────────────────');
    if (noChange) {
      buf.writeln('│  Stayed  : ${d.to.name} (no change needed)');
    } else {
      buf.writeln('│  Change  : ${d.from.name} → ${d.to.name}');
    }
    buf
      ..writeln('│  Reason  : ${d.reason.name}')
      ..writeln('│  Phase   : ${d.phase.name}');
    if (d.p75Ms != null) {
      buf.writeln('│  P75     : ${d.p75Ms!.toStringAsFixed(1)} ms');
    }
    if (d.p95Ms != null) {
      buf.writeln('│  P95     : ${d.p95Ms!.toStringAsFixed(1)} ms');
    }
    if (d.framesMeasured != null) {
      buf.writeln('│  Frames  : ${d.framesMeasured}');
    }
    buf
      ..writeln('│')
      ..writeln(
          '│  📬 Post to: github.com/sdegenaar/liquid_glass_widgets/discussions')
      ..write('└──────────────────────────────────────────────────────────');
    // ignore: avoid_print
    debugPrint(buf.toString());
  }

  @override
  Widget build(BuildContext context) {
    return _InheritedAdaptiveQuality(
      data: GlassAdaptiveScopeData(
        effectiveQuality: _effectiveQuality,
        phase: _adapter.phase,
        frostEnabled: _frostEnabled,
      ),
      child: GlassFrostBudget(
        frostEnabled: _frostEnabled,
        child: widget.child,
      ),
    );
  }

  /// Exposes the adapter for widget-level testing.
  @visibleForTesting
  GlassQualityAdapter get adapter => _adapter;
}

// ---------------------------------------------------------------------------
// _InheritedAdaptiveQuality — internal InheritedWidget
// ---------------------------------------------------------------------------

/// Internal [InheritedWidget] that carries [GlassAdaptiveScopeData] down the
/// tree. Not exported — access only via [GlassAdaptiveScopeData.of].
class _InheritedAdaptiveQuality extends InheritedWidget {
  const _InheritedAdaptiveQuality({
    required this.data,
    required super.child,
  });

  final GlassAdaptiveScopeData data;

  @override
  bool updateShouldNotify(_InheritedAdaptiveQuality oldWidget) =>
      data != oldWidget.data;
}
