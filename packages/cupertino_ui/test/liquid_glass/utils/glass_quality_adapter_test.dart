// ignore_for_file: invalid_use_of_visible_for_testing_member

import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:liquid_glass_widgets/utils/glass_quality_adapter.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Creates a fake [FrameTiming] with the given raster duration in microseconds.
FrameTiming _frameTiming(int rasterUs) {
  return FrameTiming(
    vsyncStart: 0,
    buildStart: 0,
    buildFinish: 0,
    rasterStart: 0,
    rasterFinish: rasterUs,
    rasterFinishWallTime: rasterUs,
  );
}

/// Creates [count] identical [FrameTiming] entries at [rasterUs] each.
List<FrameTiming> _frames(int count, int rasterUs) =>
    List.generate(count, (_) => _frameTiming(rasterUs));

/// Builds an adapter wired to capture quality change events.
GlassQualityAdapter _makeAdapter({
  GlassQuality min = GlassQuality.minimal,
  GlassQuality max = GlassQuality.premium,
  int targetMs = 16,
  bool allowStepUp = false,
  List<(GlassQuality, GlassQuality)>? changes,
}) {
  return GlassQualityAdapter(
    minQuality: min,
    maxQuality: max,
    targetFrameMs: targetMs,
    allowStepUp: allowStepUp,
    onQualityChanged: (from, to) => changes?.add((from, to)),
  );
}

/// Drives the adapter through a full warm-up by injecting [warmupFrames]
/// synthetic frames, each at [rasterUs] microseconds.
///
/// Uses [simulateFrameTimings] — the test seam — rather than
/// [SchedulerBinding], so no widget tree is needed.
void _runWarmup(GlassQualityAdapter adapter, {required int rasterUs}) {
  adapter.simulateFrameTimings(
    _frames(GlassQualityAdapter.warmupFrames, rasterUs),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  // Initialize the Flutter test binding so that SchedulerBinding.instance
  // is available to adapter.start() and adapter.stop().
  TestWidgetsFlutterBinding.ensureInitialized();

  // Reset tunable constants to deterministic values before each test.
  setUp(() {
    GlassQualityAdapter.warmupFrames = 10;
    GlassQualityAdapter.windowSize = 5;
    GlassQualityAdapter.degradeWindowCount = 3;
    GlassQualityAdapter.upgradeWindowCount = 10;
    GlassQualityAdapter.cooldownDuration = Duration.zero; // disable by default
    // Skip the startup-skip window so tests can supply warmupFrames directly.
    GlassQualityAdapter.skipInitialFrames = 0;
    // Bypass the static probe so tests run on headless VMs where
    // ImageFilter.isShaderFilterSupported is false.
    GlassQualityAdapter.skipStaticProbeForTesting = true;
  });

  tearDown(() {
    GlassQualityAdapter.skipStaticProbeForTesting = false;
    GlassQualityAdapter.skipInitialFrames = 90; // restore production default
    GlassQualityAdapter
        .clearSessionCache(); // prevent cache leakage between tests
  });

  // ── Construction & initial state ──────────────────────────────────────────

  group('construction', () {
    test('initial quality equals maxQuality before any simulated frames', () {
      final adapter = _makeAdapter(max: GlassQuality.premium);
      expect(adapter.currentQuality, GlassQuality.premium);
    });

    test('initial phase is probe', () {
      final adapter = _makeAdapter();
      expect(adapter.phase, AdaptivePhase.probe);
    });

    test('start() does not throw', () {
      final adapter = _makeAdapter();
      expect(() => adapter.start(), returnsNormally);
      adapter.stop();
    });
  });

  // ── Phase 2 — warm-up benchmark ───────────────────────────────────────────

  group('Phase 2 — warm-up benchmark', () {
    test('P75 < 20 ms → stays at maxQuality (premium)', () {
      final changes = <(GlassQuality, GlassQuality)>[];
      final adapter = _makeAdapter(max: GlassQuality.premium, changes: changes);
      _runWarmup(adapter,
          rasterUs: 15000); // 15 ms — well within premium threshold

      expect(adapter.currentQuality, GlassQuality.premium);
      expect(changes, isEmpty);
    });

    test('P75 in [20, 28] ms → steps down to standard', () {
      final changes = <(GlassQuality, GlassQuality)>[];
      final adapter = _makeAdapter(max: GlassQuality.premium, changes: changes);
      _runWarmup(adapter,
          rasterUs: 25000); // 25 ms — in the 20–28 ms standard band

      expect(adapter.currentQuality, GlassQuality.standard);
      expect(changes.length, 1);
      expect(changes.first, (GlassQuality.premium, GlassQuality.standard));
    });

    test('P75 exactly 18 ms stays premium (under 20 ms threshold)', () {
      final changes = <(GlassQuality, GlassQuality)>[];
      final adapter = _makeAdapter(max: GlassQuality.premium, changes: changes);
      // 18 ms — below the 20 ms premium threshold. Capable devices affected by
      // GPU clock-scaling should stay premium during warmup.
      _runWarmup(adapter, rasterUs: 18000);

      expect(adapter.currentQuality, GlassQuality.premium);
      expect(changes, isEmpty);
    });

    test('P75 > 28 ms → steps down to minimal', () {
      final changes = <(GlassQuality, GlassQuality)>[];
      final adapter = _makeAdapter(max: GlassQuality.premium, changes: changes);
      _runWarmup(adapter,
          rasterUs: 35000); // 35 ms — confirmed slow device/driver

      expect(adapter.currentQuality, GlassQuality.minimal);
    });

    test('warm-up does not promote an already downgraded quality when locked',
        () {
      final changes = <(GlassQuality, GlassQuality)>[];
      final adapter = _makeAdapter(
        allowStepUp: false,
        changes: changes,
      );

      _runWarmup(adapter, rasterUs: 25000); // premium → standard
      expect(adapter.currentQuality, GlassQuality.standard);
      changes.clear();

      adapter.reset();
      _runWarmup(adapter, rasterUs: 5000); // would otherwise promote to premium

      expect(adapter.currentQuality, GlassQuality.standard);
      expect(changes, isEmpty);
    });

    test('minQuality floor is honoured even when P75 > 20 ms', () {
      final adapter = _makeAdapter(
        min: GlassQuality.standard,
        max: GlassQuality.premium,
      );
      _runWarmup(adapter, rasterUs: 40000); // extremely slow

      // Cannot go below standard.
      expect(adapter.currentQuality, GlassQuality.standard);
    });

    test('maxQuality=standard caps result even on a fast device', () {
      final adapter = _makeAdapter(
        min: GlassQuality.minimal,
        max: GlassQuality.standard,
      );
      _runWarmup(adapter, rasterUs: 5000); // very fast

      expect(adapter.currentQuality, GlassQuality.standard);
    });

    test('transitions to runtime phase after warmup completes', () {
      final adapter = _makeAdapter();
      _runWarmup(adapter, rasterUs: 8000);
      expect(adapter.phase, AdaptivePhase.runtime);
    });

    test('does not trigger early if fewer than warmupFrames are delivered', () {
      final changes = <(GlassQuality, GlassQuality)>[];
      final adapter = _makeAdapter(max: GlassQuality.premium, changes: changes);
      // Deliver 9 slow frames — one short of the 10-frame threshold.
      adapter.simulateFrameTimings(_frames(9, 30000));

      expect(adapter.phase, AdaptivePhase.warmup);
      expect(changes, isEmpty); // still collecting
    });
  });

  // ── Custom warmup thresholds ──────────────────────────────────────────────
  //
  // These tests verify that warmupPremiumThresholdMs and warmupStandardThresholdMs
  // are actually wired through and used — not just that the defaults work.
  // The defaults themselves (20 ms / 28 ms) are tested in the group above.

  group('custom warmup thresholds', () {
    test(
        'custom warmupPremiumThresholdMs is respected — lower gate demotes sooner',
        () {
      // With a tight premium threshold of 12 ms, 15 ms should fall to standard.
      final changes = <(GlassQuality, GlassQuality)>[];
      final adapter = GlassQualityAdapter(
        minQuality: GlassQuality.minimal,
        maxQuality: GlassQuality.premium,
        targetFrameMs: 16,
        allowStepUp: false,
        warmupPremiumThresholdMs: 12.0, // custom: tighter than default 20 ms
        warmupStandardThresholdMs: 28.0,
        onQualityChanged: (from, to) => changes.add((from, to)),
      );
      _runWarmup(adapter, rasterUs: 15000); // 15 ms — above 12 ms custom gate

      expect(adapter.currentQuality, GlassQuality.standard,
          reason: '15 ms P75 exceeds custom premium threshold of 12 ms');
      expect(changes, [(GlassQuality.premium, GlassQuality.standard)]);
    });

    test(
        'custom warmupPremiumThresholdMs is respected — raised gate keeps premium',
        () {
      // With a raised premium threshold of 25 ms, even 22 ms stays premium.
      final changes = <(GlassQuality, GlassQuality)>[];
      final adapter = GlassQualityAdapter(
        minQuality: GlassQuality.minimal,
        maxQuality: GlassQuality.premium,
        targetFrameMs: 16,
        allowStepUp: false,
        warmupPremiumThresholdMs:
            25.0, // custom: more lenient than default 20 ms
        warmupStandardThresholdMs: 28.0,
        onQualityChanged: (from, to) => changes.add((from, to)),
      );
      _runWarmup(adapter,
          rasterUs: 22000); // 22 ms — under the custom 25 ms gate

      expect(adapter.currentQuality, GlassQuality.premium,
          reason: '22 ms P75 is within the custom premium threshold of 25 ms');
      expect(changes, isEmpty);
    });

    test(
        'custom warmupStandardThresholdMs is respected — lower gate reaches minimal sooner',
        () {
      // With a tight standard threshold of 25 ms, 27 ms should reach minimal.
      final changes = <(GlassQuality, GlassQuality)>[];
      final adapter = GlassQualityAdapter(
        minQuality: GlassQuality.minimal,
        maxQuality: GlassQuality.premium,
        targetFrameMs: 16,
        allowStepUp: false,
        warmupPremiumThresholdMs: 20.0,
        warmupStandardThresholdMs: 25.0, // custom: tighter than default 28 ms
        onQualityChanged: (from, to) => changes.add((from, to)),
      );
      _runWarmup(adapter,
          rasterUs: 27000); // 27 ms — above 25 ms custom standard gate

      expect(adapter.currentQuality, GlassQuality.minimal,
          reason: '27 ms P75 exceeds custom standard threshold of 25 ms');
    });

    test('both custom thresholds work together', () {
      // Tight thresholds: premium < 10 ms, standard ≤ 15 ms, minimal > 15 ms
      final adapter = GlassQualityAdapter(
        minQuality: GlassQuality.minimal,
        maxQuality: GlassQuality.premium,
        targetFrameMs: 16,
        allowStepUp: false,
        warmupPremiumThresholdMs: 10.0,
        warmupStandardThresholdMs: 15.0,
        onQualityChanged: (_, __) {},
      );
      // 12 ms — between the two custom thresholds → standard
      _runWarmup(adapter, rasterUs: 12000);
      expect(adapter.currentQuality, GlassQuality.standard);
    });
  });

  // ── skipInitialFrames ───────────────────────────────────────────────────

  group('skipInitialFrames — startup noise isolation', () {
    test('frames within skip window are not counted in warmup', () {
      GlassQualityAdapter.skipInitialFrames = 5;
      GlassQualityAdapter.warmupFrames = 4;
      final changes = <(GlassQuality, GlassQuality)>[];
      final adapter = _makeAdapter(max: GlassQuality.premium, changes: changes);

      // 5 very slow frames (startup noise) — should be discarded.
      adapter.simulateFrameTimings(_frames(5, 50000));
      expect(adapter.phase, AdaptivePhase.warmup);
      expect(changes, isEmpty);

      // Now 4 fast frames (normal glass rendering) — warmup completes.
      adapter.simulateFrameTimings(_frames(4, 8000));
      expect(adapter.phase, AdaptivePhase.runtime);

      // Quality should be premium (8 ms P75 < 20 ms) because the 50 ms
      // startup frames were discarded.
      expect(adapter.currentQuality, GlassQuality.premium,
          reason:
              'Startup spike frames should not pollute the warmup benchmark');
    });

    test('skip counter resets on reset()', () {
      GlassQualityAdapter.skipInitialFrames = 3;
      GlassQualityAdapter.warmupFrames = 4;
      final adapter = _makeAdapter(max: GlassQuality.premium);

      // Partially consume the skip window.
      adapter.simulateFrameTimings(_frames(2, 50000));
      expect(adapter.phase, AdaptivePhase.warmup);

      // reset() should restart the skip counter.
      adapter.reset();
      // Now deliver 3 (skip) + 4 (warmup) fast frames — should complete.
      adapter.simulateFrameTimings(_frames(3, 50000)); // skip window
      adapter.simulateFrameTimings(_frames(4, 8000)); // warmup window
      expect(adapter.phase, AdaptivePhase.runtime);
      expect(adapter.currentQuality, GlassQuality.premium);
    });
  });

  // ── Phase 3 — runtime hysteresis ─────────────────────────────────────────

  group('Phase 3 — runtime hysteresis', () {
    test('3 consecutive over-budget windows → degrade premium → standard', () {
      final changes = <(GlassQuality, GlassQuality)>[];
      final adapter = _makeAdapter(max: GlassQuality.premium, changes: changes);
      _runWarmup(adapter, rasterUs: 5000); // fast → stays premium
      changes.clear();

      // Over-budget threshold: targetMs=16 × 1.5 = 24 ms. Send 30 ms frames.
      for (int i = 0; i < 3; i++) {
        adapter.simulateFrameTimings(_frames(5, 30000));
      }

      expect(adapter.currentQuality, GlassQuality.standard);
      expect(changes, [(GlassQuality.premium, GlassQuality.standard)]);
    });

    test('second degrade: standard → minimal after 3 more over-budget windows',
        () {
      final adapter = _makeAdapter(max: GlassQuality.premium);
      _runWarmup(adapter, rasterUs: 5000);

      for (int i = 0; i < 3; i++) {
        adapter.simulateFrameTimings(_frames(5, 30000));
      }
      expect(adapter.currentQuality, GlassQuality.standard);

      for (int i = 0; i < 3; i++) {
        adapter.simulateFrameTimings(_frames(5, 30000));
      }
      expect(adapter.currentQuality, GlassQuality.minimal);
    });

    test('does not degrade below minQuality floor', () {
      final adapter = _makeAdapter(
        min: GlassQuality.standard,
        max: GlassQuality.premium,
      );
      _runWarmup(adapter, rasterUs: 5000);

      // Saturate with many over-budget windows.
      for (int i = 0; i < 9; i++) {
        adapter.simulateFrameTimings(_frames(5, 30000));
      }

      expect(adapter.currentQuality, GlassQuality.standard);
    });

    test('under-budget windows do not trigger step-up when allowStepUp=false',
        () {
      final changes = <(GlassQuality, GlassQuality)>[];
      final adapter = _makeAdapter(allowStepUp: false, changes: changes);
      _runWarmup(adapter, rasterUs: 5000);
      // Degrade once
      for (int i = 0; i < 3; i++) {
        adapter.simulateFrameTimings(_frames(5, 30000));
      }
      changes.clear();

      // Now send many under-budget windows.
      for (int i = 0; i < 20; i++) {
        adapter.simulateFrameTimings(_frames(5, 2000));
      }

      expect(adapter.currentQuality, GlassQuality.standard);
      expect(changes, isEmpty);
    });

    test('10 consecutive under-budget windows → step-up when allowStepUp=true',
        () {
      final changes = <(GlassQuality, GlassQuality)>[];
      final adapter = _makeAdapter(allowStepUp: true, changes: changes);
      _runWarmup(adapter, rasterUs: 5000);
      // Degrade once
      for (int i = 0; i < 3; i++) {
        adapter.simulateFrameTimings(_frames(5, 30000));
      }
      expect(adapter.currentQuality, GlassQuality.standard);
      changes.clear();

      // Under-budget threshold: 16 × 0.6 = 9.6 ms. Send 2 ms frames.
      for (int i = 0; i < 10; i++) {
        adapter.simulateFrameTimings(_frames(5, 2000));
      }

      expect(adapter.currentQuality, GlassQuality.premium);
      expect(changes, [(GlassQuality.standard, GlassQuality.premium)]);
    });

    test('a neutral window decays recovery progress rather than erasing it',
        () {
      // Regression: recovery requires `upgradeWindowCount` CONSECUTIVE
      // under-budget windows, and a neutral window used to reset that
      // counter to zero. Because the measure is P95 — a tail statistic — an
      // ordinary scrolling list drifts into the neutral band often enough
      // that the counter never reached the threshold, so a single transient
      // cost demoted quality permanently with no path back.
      final changes = <(GlassQuality, GlassQuality)>[];
      final adapter = _makeAdapter(allowStepUp: true, changes: changes);
      _runWarmup(adapter, rasterUs: 5000);

      // Degrade to standard.
      for (int i = 0; i < 3; i++) {
        adapter.simulateFrameTimings(_frames(5, 30000));
      }
      expect(adapter.currentQuality, GlassQuality.standard);
      changes.clear();

      // Nine under-budget windows: one short of the step-up threshold.
      // Under-budget is 16 x 0.6 = 9.6 ms, so 2 ms qualifies.
      for (int i = 0; i < 9; i++) {
        adapter.simulateFrameTimings(_frames(5, 2000));
      }
      expect(adapter.currentQuality, GlassQuality.standard);

      // One neutral window — 15 ms sits between 9.6 ms and 24 ms, so it is
      // neither jank nor comfortably fast. This must not wipe the nine.
      adapter.simulateFrameTimings(_frames(5, 15000));

      // Nine more good windows. With the counter decayed to 8 rather than
      // reset to 0, the threshold is crossed. Under the old behaviour this
      // run would end at 9 and the adapter would stay demoted forever.
      for (int i = 0; i < 9; i++) {
        adapter.simulateFrameTimings(_frames(5, 2000));
      }

      expect(adapter.currentQuality, GlassQuality.premium);
      expect(changes, [(GlassQuality.standard, GlassQuality.premium)]);
    });

    test('a sustained over-budget window still degrades immediately', () {
      // Guard for the other side of the same branch: the decay must not make
      // degradation any slower or any less certain.
      final changes = <(GlassQuality, GlassQuality)>[];
      final adapter = _makeAdapter(allowStepUp: true, changes: changes);
      _runWarmup(adapter, rasterUs: 5000);
      expect(adapter.currentQuality, GlassQuality.premium);

      for (int i = 0; i < 3; i++) {
        adapter.simulateFrameTimings(_frames(5, 30000));
      }

      expect(adapter.currentQuality, GlassQuality.standard);
      expect(changes, [(GlassQuality.premium, GlassQuality.standard)]);
    });

    test('step-up is blocked while cooldown is active', () {
      GlassQualityAdapter.cooldownDuration = const Duration(hours: 1);
      final changes = <(GlassQuality, GlassQuality)>[];
      final adapter = _makeAdapter(allowStepUp: true, changes: changes);
      _runWarmup(adapter, rasterUs: 5000);

      // Step down (uses up cooldown window)
      for (int i = 0; i < 3; i++) {
        adapter.simulateFrameTimings(_frames(5, 30000));
      }
      expect(adapter.currentQuality, GlassQuality.standard);
      changes.clear();

      // Step-up attempt — still within cooldown, so blocked.
      for (int i = 0; i < 15; i++) {
        adapter.simulateFrameTimings(_frames(5, 2000));
      }

      expect(adapter.currentQuality, GlassQuality.standard);
      expect(changes, isEmpty);
    });

    test('second step-down within cooldown is blocked', () {
      GlassQualityAdapter.cooldownDuration = const Duration(hours: 1);
      final adapter = _makeAdapter(max: GlassQuality.premium);
      _runWarmup(adapter, rasterUs: 5000);

      // First degrade (premium → standard) succeeds.
      for (int i = 0; i < 3; i++) {
        adapter.simulateFrameTimings(_frames(5, 30000));
      }
      expect(adapter.currentQuality, GlassQuality.standard);

      // Second degrade attempt (standard → minimal) blocked by cooldown.
      for (int i = 0; i < 6; i++) {
        adapter.simulateFrameTimings(_frames(5, 30000));
      }
      expect(adapter.currentQuality, GlassQuality.standard);
    });

    test('frames within the tolerable zone reset both counters → no change',
        () {
      final changes = <(GlassQuality, GlassQuality)>[];
      final adapter = _makeAdapter(max: GlassQuality.premium, changes: changes);
      _runWarmup(adapter, rasterUs: 5000);
      changes.clear();

      // 16 ms exactly — right on budget, in the "no change" band.
      for (int i = 0; i < 20; i++) {
        adapter.simulateFrameTimings(_frames(5, 16000));
      }

      expect(adapter.currentQuality, GlassQuality.premium);
      expect(changes, isEmpty);
    });
  });

  // ── Lifecycle API ─────────────────────────────────────────────────────────

  group('lifecycle', () {
    test('isRunning is false after stop()', () {
      final adapter = _makeAdapter();
      // On the headless VM the static probe may have already stopped the
      // adapter. Call start() explicitly (no-op if running) then stop().
      // We verify simply that stop() does not throw.
      adapter.stop();
      expect(adapter.isRunning, isFalse);
    });

    test('reset() clears phase counters and returns to warmup', () {
      GlassQualityAdapter.warmupFrames = 5;
      final adapter = _makeAdapter();
      _runWarmup(adapter, rasterUs: 5000);
      expect(adapter.phase, AdaptivePhase.runtime);
      adapter.reset();
      expect(adapter.phase, AdaptivePhase.warmup);
    });

    test('reset() clears degrade counter', () {
      final changes = <(GlassQuality, GlassQuality)>[];
      final adapter = _makeAdapter(max: GlassQuality.premium, changes: changes);
      _runWarmup(adapter, rasterUs: 5000);

      // Deliver 2 out of 3 needed over-budget windows — not yet degraded.
      for (int i = 0; i < 2; i++) {
        adapter.simulateFrameTimings(_frames(5, 30000));
      }
      changes.clear();

      adapter.reset();
      _runWarmup(adapter, rasterUs: 5000); // new fast warmup

      // No degrade should have fired.
      expect(changes, isEmpty);
      expect(adapter.currentQuality, GlassQuality.premium);
    });
  });

  // ── Percentile math ───────────────────────────────────────────────────────

  group('percentile math', () {
    setUp(() {
      GlassQualityAdapter.warmupFrames = 4;
      GlassQualityAdapter.windowSize = 4;
    });

    test('P75 of [10, 12, 20, 25] ms → 20 ms → standard band [20, 28]', () {
      final changes = <(GlassQuality, GlassQuality)>[];
      final adapter = _makeAdapter(max: GlassQuality.premium, changes: changes);

      adapter.simulateFrameTimings([
        _frameTiming(10000), // 10 ms
        _frameTiming(12000), // 12 ms
        _frameTiming(20000), // 20 ms
        _frameTiming(25000), // 25 ms
        // P75 of sorted[10,12,20,25]: rank=ceil(0.75*4)=3 → index 2 → 20 ms
        // 20 ms hits the standard band (>= 20 ms and <= 28 ms)
      ]);

      expect(adapter.currentQuality, GlassQuality.standard);
    });

    test('P75 of [5, 6, 8, 10] ms → 8 ms → stays premium', () {
      final changes = <(GlassQuality, GlassQuality)>[];
      final adapter = _makeAdapter(max: GlassQuality.premium, changes: changes);

      adapter.simulateFrameTimings([
        _frameTiming(5000),
        _frameTiming(6000),
        _frameTiming(8000),
        _frameTiming(10000),
        // P75: rank=ceil(0.75*4)=3 → index 2 → 8 ms < 20 ms → premium
      ]);

      expect(adapter.currentQuality, GlassQuality.premium);
      expect(changes, isEmpty);
    });
  });

  // ── Session cache ──────────────────────────────────────────────────────────

  group('session cache', () {
    setUp(() => GlassQualityAdapter.clearSessionCache());
    tearDown(() => GlassQualityAdapter.clearSessionCache());

    test('Phase 2 writes settled quality to session cache', () {
      final adapter = _makeAdapter(max: GlassQuality.premium);

      // Simulate 10 slow frames (35 ms each) → P75 > 28 ms → minimal.
      adapter.simulateFrameTimings(
        List.generate(10, (_) => _frameTiming(35000)),
      );

      expect(adapter.currentQuality, GlassQuality.minimal);

      // A second adapter (simulating a remount) must read the cache.
      final adapter2 = _makeAdapter(max: GlassQuality.premium);
      adapter2.start();
      // Cache is warm — Phase 2 was skipped, jumped straight to Phase 3.
      expect(adapter2.usedCachedQuality, isTrue);
      expect(adapter2.currentQuality, GlassQuality.minimal);
      expect(adapter2.phase, AdaptivePhase.runtime);
      adapter2.stop();
    });

    test('second adapter goes directly to runtime phase via session cache', () {
      // Settle cache to standard via Phase 2 (22 ms is in the 20–28 ms standard band).
      final adapter1 = _makeAdapter(max: GlassQuality.premium);
      adapter1.simulateFrameTimings(
        List.generate(10, (_) => _frameTiming(22000)), // 22 ms → standard
      );
      expect(adapter1.currentQuality, GlassQuality.standard);

      // Second adapter must skip Phase 2.
      final adapter2 = _makeAdapter(max: GlassQuality.premium);
      adapter2.start();
      expect(adapter2.phase, AdaptivePhase.runtime);
      expect(adapter2.currentQuality, GlassQuality.standard);
      adapter2.stop();
    });

    test('clearSessionCache() forces Phase 2 on next adapter', () {
      // Settle cache.
      final adapter1 = _makeAdapter(max: GlassQuality.premium);
      adapter1.simulateFrameTimings(
        List.generate(
            10, (_) => _frameTiming(35000)), // 35 ms > 28 ms → minimal
      );
      expect(adapter1.currentQuality, GlassQuality.minimal);

      // Clear and verify next adapter runs Phase 2.
      GlassQualityAdapter.clearSessionCache();

      final adapter2 = _makeAdapter(max: GlassQuality.premium);
      adapter2.start();
      expect(adapter2.usedCachedQuality, isFalse);
      expect(adapter2.phase, AdaptivePhase.warmup);
      adapter2.stop();
    });

    test('cached quality is clamped to new [minQuality, maxQuality] range', () {
      // Settle cache to premium.
      final adapter1 = _makeAdapter(max: GlassQuality.premium);
      adapter1.simulateFrameTimings(
        List.generate(10, (_) => _frameTiming(5000)), // 5 ms → premium
      );
      expect(adapter1.currentQuality, GlassQuality.premium);

      // New adapter with maxQuality=standard must clamp premium → standard.
      final adapter2 = _makeAdapter(max: GlassQuality.standard);
      adapter2.start();
      expect(adapter2.currentQuality, GlassQuality.standard);
      adapter2.stop();
    });
  });

  // ── initialQuality ─────────────────────────────────────────────────────────

  group('initialQuality', () {
    setUp(() => GlassQualityAdapter.clearSessionCache());
    tearDown(() => GlassQualityAdapter.clearSessionCache());

    test('initialQuality skips Phase 2 and jumps to runtime', () {
      final adapter = GlassQualityAdapter(
        minQuality: GlassQuality.minimal,
        maxQuality: GlassQuality.premium,
        targetFrameMs: 16,
        allowStepUp: false,
        initialQuality: GlassQuality.minimal,
        onQualityChanged: (_, __) {},
      );
      adapter.start();
      expect(adapter.usedCachedQuality, isTrue);
      expect(adapter.phase, AdaptivePhase.runtime);
      expect(adapter.currentQuality, GlassQuality.minimal);
      adapter.stop();
    });

    test('initialQuality takes priority over session cache', () {
      // First: write standard to the session cache (22 ms is in the 20–28 ms standard band).
      final adapter1 = _makeAdapter(max: GlassQuality.premium);
      adapter1.simulateFrameTimings(
        List.generate(10, (_) => _frameTiming(22000)), // 22 ms → standard
      );
      expect(adapter1.currentQuality, GlassQuality.standard);

      // Developer explicitly provides minimal via initialQuality — must win.
      final adapter2 = GlassQualityAdapter(
        minQuality: GlassQuality.minimal,
        maxQuality: GlassQuality.premium,
        targetFrameMs: 16,
        allowStepUp: false,
        initialQuality: GlassQuality.minimal, // explicit — beats session cache
        onQualityChanged: (_, __) {},
      );
      adapter2.start();
      expect(adapter2.currentQuality, GlassQuality.minimal);
      adapter2.stop();
    });

    test('initialQuality null falls through to session cache', () {
      // Settle cache to minimal.
      final adapter1 = _makeAdapter(max: GlassQuality.premium);
      adapter1.simulateFrameTimings(
        List.generate(
            10, (_) => _frameTiming(35000)), // 35 ms > 28 ms → minimal
      );
      expect(adapter1.currentQuality, GlassQuality.minimal);

      // No initialQuality provided — should pick up session cache.
      final adapter2 = _makeAdapter(max: GlassQuality.premium);
      adapter2.start();
      expect(adapter2.currentQuality, GlassQuality.minimal);
      expect(adapter2.usedCachedQuality, isTrue);
      adapter2.stop();
    });

    test('reset() clears usedCachedQuality so Phase 2 state is accurate', () {
      // Settle cache and create adapter that uses it.
      final adapter1 = _makeAdapter(max: GlassQuality.premium);
      adapter1.simulateFrameTimings(
        List.generate(10, (_) => _frameTiming(25000)),
      );

      final adapter2 = _makeAdapter(max: GlassQuality.premium);
      adapter2.start();
      expect(adapter2.usedCachedQuality, isTrue);

      // After reset(), Phase 2 re-runs — usedCachedQuality must be false.
      adapter2.reset();
      expect(adapter2.usedCachedQuality, isFalse);
      expect(adapter2.phase, AdaptivePhase.warmup);
      adapter2.stop();
    });

    test(
        'sessionSettledQuality getter returns null before any Phase 2 completes',
        () {
      expect(GlassQualityAdapter.sessionSettledQuality, isNull);
    });

    test('sessionSettledQuality getter returns settled quality after Phase 2',
        () {
      final adapter = _makeAdapter(max: GlassQuality.premium);
      adapter.simulateFrameTimings(
        List.generate(
            10, (_) => _frameTiming(35000)), // 35 ms > 28 ms → minimal
      );
      expect(GlassQualityAdapter.sessionSettledQuality, GlassQuality.minimal);
    });
  });

  // ── Diagnostic tracking ───────────────────────────────────────────────────

  group('diagnostic tracking', () {
    setUp(() => GlassQualityAdapter.clearSessionCache());
    tearDown(() => GlassQualityAdapter.clearSessionCache());

    test('lastChangeReason is warmupComplete after Phase 2 with quality change',
        () {
      final adapter = _makeAdapter(max: GlassQuality.premium);
      _runWarmup(adapter,
          rasterUs: 22000); // 22 ms → standard (in 20–28 ms band)
      expect(adapter.lastChangeReason, GlassQualityChangeReason.warmupComplete);
    });

    test('lastP75Ms is approximately the measured P75 after warmup', () {
      final adapter = _makeAdapter(max: GlassQuality.premium);
      _runWarmup(adapter, rasterUs: 22000); // all frames at 22 ms → P75 = 22 ms
      expect(adapter.lastP75Ms, isNotNull);
      // P75 of 10 identical 22 ms frames is 22 ms.
      expect(adapter.lastP75Ms!, closeTo(22.0, 0.5));
    });

    test('lastFramesMeasured equals warmupFrames after Phase 2', () {
      final adapter = _makeAdapter(max: GlassQuality.premium);
      _runWarmup(adapter, rasterUs: 22000);
      expect(adapter.lastFramesMeasured, GlassQualityAdapter.warmupFrames);
    });

    test('lastP75Ms is null before warmup completes', () {
      final adapter = _makeAdapter(max: GlassQuality.premium);
      // Only 5 frames delivered — warmup needs 10.
      adapter.simulateFrameTimings(_frames(5, 15000));
      expect(adapter.lastP75Ms, isNull);
    });

    test('lastChangeReason is thermalDegradation after runtime step-down', () {
      final adapter = _makeAdapter(max: GlassQuality.premium);
      _runWarmup(adapter, rasterUs: 5000); // fast → premium

      for (int i = 0; i < 3; i++) {
        adapter.simulateFrameTimings(_frames(5, 30000)); // over-budget
      }

      expect(adapter.lastChangeReason,
          GlassQualityChangeReason.thermalDegradation);
    });

    test('lastP95Ms is set after thermal degradation', () {
      final adapter = _makeAdapter(max: GlassQuality.premium);
      _runWarmup(adapter, rasterUs: 5000);

      for (int i = 0; i < 3; i++) {
        adapter.simulateFrameTimings(_frames(5, 30000));
      }

      expect(adapter.lastP95Ms, isNotNull);
      expect(adapter.lastP95Ms!, greaterThan(0));
    });

    test('lastP75Ms is null after thermal degradation (P75 only in Phase 2)',
        () {
      final adapter = _makeAdapter(max: GlassQuality.premium);
      _runWarmup(adapter, rasterUs: 5000);

      for (int i = 0; i < 3; i++) {
        adapter.simulateFrameTimings(_frames(5, 30000));
      }

      // After thermal event the P75 field should be cleared.
      expect(adapter.lastP75Ms, isNull);
    });

    test('lastChangeReason is thermalRecovery after runtime step-up', () {
      final adapter =
          _makeAdapter(max: GlassQuality.premium, allowStepUp: true);
      _runWarmup(adapter, rasterUs: 5000);

      // Degrade first.
      for (int i = 0; i < 3; i++) {
        adapter.simulateFrameTimings(_frames(5, 30000));
      }
      expect(adapter.currentQuality, GlassQuality.standard);

      // Recover.
      for (int i = 0; i < 10; i++) {
        adapter.simulateFrameTimings(_frames(5, 2000));
      }

      expect(
          adapter.lastChangeReason, GlassQualityChangeReason.thermalRecovery);
    });

    test('lastChangeReason is restoredFromCache on second adapter', () {
      // Settle a session cache entry to standard (22 ms is in the 20–28 ms standard band).
      final adapter1 = _makeAdapter(max: GlassQuality.premium);
      _runWarmup(adapter1, rasterUs: 22000); // → standard

      final adapter2 = _makeAdapter(max: GlassQuality.premium);
      adapter2.start();
      expect(adapter2.lastChangeReason,
          GlassQualityChangeReason.restoredFromCache);
      adapter2.stop();
    });

    test('lastFramesMeasured equals windowSize after thermal degradation', () {
      final adapter = _makeAdapter(max: GlassQuality.premium);
      _runWarmup(adapter, rasterUs: 5000);

      for (int i = 0; i < 3; i++) {
        adapter.simulateFrameTimings(_frames(5, 30000));
      }

      expect(adapter.lastFramesMeasured, GlassQualityAdapter.windowSize);
    });
  });

  group('percentile math and Quickselect', () {
    test('single element returns itself', () {
      expect(GlassQualityAdapter.percentileForTesting([42], 50), 42);
      expect(GlassQualityAdapter.percentileForTesting([42], 0), 42);
      expect(GlassQualityAdapter.percentileForTesting([42], 100), 42);
    });

    test('matches full sort across all percentiles', () {
      final samples = [
        28,
        12,
        45,
        1,
        99,
        34,
        56,
        78,
        12,
        90,
        3,
        17,
        65,
        88,
        23
      ];
      final sorted = List<int>.from(samples)..sort();

      for (int p = 0; p <= 100; p += 5) {
        final rank = ((p / 100.0) * samples.length).ceil();
        final expectedIndex = (rank - 1).clamp(0, samples.length - 1);
        final expected = sorted[expectedIndex];
        final actual = GlassQualityAdapter.percentileForTesting(samples, p);
        expect(actual, expected, reason: 'failed at percentile $p');
      }
    });

    test('quickSelect handles already sorted, reverse, and identical arrays',
        () {
      final sorted = [1, 2, 3, 4, 5, 6, 7];
      expect(GlassQualityAdapter.quickSelectForTesting(List.of(sorted), 0), 1);
      expect(GlassQualityAdapter.quickSelectForTesting(List.of(sorted), 3), 4);
      expect(GlassQualityAdapter.quickSelectForTesting(List.of(sorted), 6), 7);

      final reverse = [7, 6, 5, 4, 3, 2, 1];
      expect(GlassQualityAdapter.quickSelectForTesting(List.of(reverse), 0), 1);
      expect(GlassQualityAdapter.quickSelectForTesting(List.of(reverse), 3), 4);
      expect(GlassQualityAdapter.quickSelectForTesting(List.of(reverse), 6), 7);

      final identical = [5, 5, 5, 5, 5];
      expect(
          GlassQualityAdapter.quickSelectForTesting(List.of(identical), 2), 5);
    });
  });
}
