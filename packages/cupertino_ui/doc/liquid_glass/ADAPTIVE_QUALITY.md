# Adaptive Quality — Threshold Calibration

`GlassAdaptiveScope` (enabled via `wrap(adaptiveQuality: true)`) automatically
benchmarks the device at startup and adjusts rendering quality in real time.
It is `@experimental` because its Phase 2 timing thresholds are based on limited
community data and have not yet been validated across the full Android device
landscape.

## Current defaults

| P75 warmup | Quality assigned |
|---|---|
| < 20 ms | `premium` *(based on 1 report — please share yours)* |
| 20–28 ms | `standard` *(provisional — no real-device data yet)* |
| > 28 ms | `minimal` |

## 📊 Help us tune the thresholds — takes 2 minutes

If you use `adaptiveQuality: true`, please post your results to our
[Threshold Calibration Discussion](https://github.com/sdegenaar/liquid_glass_widgets/discussions)
with the snippet below. Every report directly informs the threshold calibration
and gets us closer to removing `@experimental`.

```dart
// Add to your GlassAdaptiveScopeConfig while testing — remove before shipping:

// Option A: zero-wiring (recommended for quick reports)
GlassAdaptiveScopeConfig(
  debugLogDiagnostics: true, // prints to console in debug builds only
)

// Option B: custom handler for analytics
GlassAdaptiveScopeConfig(
  onDiagnostic: (d) {
    // d.reason, d.p75Ms, d.p95Ms, d.framesMeasured, d.phase are all set
    debugPrint('📊 ${d.from.name} → ${d.to.name} | reason: ${d.reason.name} | P75: ${d.p75Ms?.toStringAsFixed(1)}ms');
  },
)
```

Please include your **device model**, **Flutter version**, and **observed P75 ms**
in your discussion post. Thank you 🙏
