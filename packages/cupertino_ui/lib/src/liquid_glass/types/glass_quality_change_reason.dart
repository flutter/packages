// ---------------------------------------------------------------------------
// GlassQualityChangeReason — why GlassAdaptiveScope changed quality
// ---------------------------------------------------------------------------

/// Describes what triggered a [GlassAdaptiveScope] quality change.
///
/// Passed inside [GlassAdaptiveDiagnostic] to [GlassAdaptiveScope.onDiagnostic].
///
/// Use this to filter analytics events — e.g. only log [warmupComplete] and
/// [thermalDegradation] to avoid noise from [restoredFromCache].
enum GlassQualityChangeReason {
  /// Phase 1 — the device failed the static capability probe.
  ///
  /// Either `ImageFilter.isShaderFilterSupported` is `false` (software
  /// renderer / broken driver) or the app is running on web (`kIsWeb`).
  /// The adapter forced a lower quality tier immediately at startup, without
  /// collecting any frame timings.
  staticProbe,

  /// The adapter started from a persisted or in-session cached quality,
  /// skipping Phase 2 (the warm-up benchmark).
  ///
  /// This fires when [GlassAdaptiveScope.initialQuality] is non-null, or
  /// when the in-session cache was populated by an earlier adapter instance
  /// in the same app process. The change happens immediately at startup
  /// with no P75/P95 data.
  restoredFromCache,

  /// Phase 2 completed — the warm-up benchmark measured the baseline P75
  /// raster time and selected a quality tier.
  ///
  /// [GlassAdaptiveDiagnostic.p75Ms] will be set. This is the most useful
  /// event for threshold calibration — please post it to the
  /// [Threshold Calibration Discussion](https://github.com/sdegenaar/liquid_glass_widgets/discussions).
  warmupComplete,

  /// Phase 3 — sustained over-budget raster frames triggered a quality
  /// step-down (e.g. thermal throttling or background CPU load).
  ///
  /// [GlassAdaptiveDiagnostic.p95Ms] will be set.
  thermalDegradation,

  /// Phase 3 — sustained under-budget raster frames triggered a quality
  /// step-up after a period of thermal throttling.
  ///
  /// Only fires when [GlassAdaptiveScope.allowStepUp] is `true`.
  /// [GlassAdaptiveDiagnostic.p95Ms] will be set.
  thermalRecovery,
}
