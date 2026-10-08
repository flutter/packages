// ignore_for_file: invalid_use_of_visible_for_testing_member
// Additional branch coverage for GlassQualityAdapter
// Complements glass_quality_adapter_test.dart by targeting paths not
// covered there: onWarmupComplete callback, session-cache clamping,
// skipInitialFrames reset counter, and boundary percentile values.

import 'dart:ui';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_widgets/utils/glass_quality_adapter.dart';
import 'package:liquid_glass_widgets/types/glass_quality.dart';
import 'package:liquid_glass_widgets/types/glass_quality_change_reason.dart';

// ---------------------------------------------------------------------------
// Helpers — identical pattern to the canonical adapter test
// ---------------------------------------------------------------------------

FrameTiming _ft(int rasterUs) => FrameTiming(
      vsyncStart: 0,
      buildStart: 0,
      buildFinish: 0,
      rasterStart: 0,
      rasterFinish: rasterUs,
      rasterFinishWallTime: rasterUs,
    );

List<FrameTiming> _frames(int count, int rasterUs) =>
    List.generate(count, (_) => _ft(rasterUs));

GlassQualityAdapter _make({
  GlassQuality min = GlassQuality.minimal,
  GlassQuality max = GlassQuality.premium,
  int targetFrameMs = 16,
  bool allowStepUp = true,
  GlassQuality? initialQuality,
  void Function(GlassQuality, GlassQuality)? onChange,
  void Function(GlassQuality, double, int)? onWarmup,
}) =>
    GlassQualityAdapter(
      minQuality: min,
      maxQuality: max,
      targetFrameMs: targetFrameMs,
      allowStepUp: allowStepUp,
      initialQuality: initialQuality,
      onQualityChanged: onChange ?? (_, __) {},
      onWarmupComplete: onWarmup,
    );

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  // Required for adapter.start() which calls SchedulerBinding.instance
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    GlassQualityAdapter.clearSessionCache();
    GlassQualityAdapter.skipInitialFrames = 0;
    GlassQualityAdapter.warmupFrames = 10;
    GlassQualityAdapter.windowSize = 10;
    GlassQualityAdapter.degradeWindowCount = 2;
    GlassQualityAdapter.upgradeWindowCount = 2;
    GlassQualityAdapter.cooldownDuration = Duration.zero;
    GlassQualityAdapter.skipStaticProbeForTesting = true;
  });

  tearDown(() {
    GlassQualityAdapter.skipInitialFrames = 90;
    GlassQualityAdapter.warmupFrames = 180;
    GlassQualityAdapter.windowSize = 120;
    GlassQualityAdapter.degradeWindowCount = 2;
    GlassQualityAdapter.upgradeWindowCount = 10;
    GlassQualityAdapter.cooldownDuration = const Duration(seconds: 8);
    GlassQualityAdapter.skipStaticProbeForTesting = false;
    GlassQualityAdapter.clearSessionCache();
  });

  // ── onWarmupComplete callback ─────────────────────────────────────────────

  group('onWarmupComplete callback', () {
    test('fires with settled quality, p75Ms, and frame count', () {
      GlassQuality? cbQuality;
      double? cbP75;
      int? cbFrames;
      final adapter = _make(
        onWarmup: (q, p75, frames) {
          cbQuality = q;
          cbP75 = p75;
          cbFrames = frames;
        },
      );
      adapter.simulateFrameTimings(_frames(10, 10000)); // 10 ms → premium
      expect(cbQuality, GlassQuality.premium);
      expect(cbP75, isNotNull);
      expect(cbFrames, 10);
    });

    test('fires with standard on medium device', () {
      GlassQuality? cbQuality;
      final adapter = _make(onWarmup: (q, _, __) => cbQuality = q);
      adapter.simulateFrameTimings(
          _frames(10, 21000)); // 21 ms → standard (20–28 ms band)
      expect(cbQuality, GlassQuality.standard);
    });

    test('fires with minimal on slow device', () {
      GlassQuality? cbQuality;
      final adapter = _make(onWarmup: (q, _, __) => cbQuality = q);
      adapter
          .simulateFrameTimings(_frames(10, 35000)); // 35 ms > 28 ms threshold
      expect(cbQuality, GlassQuality.minimal);
    });

    test('does not fire before warmupFrames threshold', () {
      bool fired = false;
      final adapter = _make(onWarmup: (_, __, ___) => fired = true);
      adapter.simulateFrameTimings(_frames(9, 10000)); // one short
      expect(fired, isFalse);
    });
  });

  // ── minQuality floor in warmup ────────────────────────────────────────────

  group('minQuality floor in warmup', () {
    test('slow device with min=standard stays at standard not minimal', () {
      final adapter = _make(min: GlassQuality.standard);
      adapter.simulateFrameTimings(_frames(10, 25000));
      expect(adapter.currentQuality, GlassQuality.standard);
    });

    test('very slow device with min=premium stays at premium', () {
      final adapter = _make(
        min: GlassQuality.premium,
        max: GlassQuality.premium,
      );
      adapter.simulateFrameTimings(_frames(10, 40000));
      expect(adapter.currentQuality, GlassQuality.premium);
    });
  });

  // ── allowStepUp=false blocks runtime recovery ─────────────────────────────

  group('allowStepUp=false in runtime', () {
    test('over-then-under budget: no recovery when allowStepUp=false', () {
      final changes = <GlassQuality>[];
      final adapter = _make(
        allowStepUp: false,
        onChange: (_, to) => changes.add(to),
      );
      adapter.simulateFrameTimings(_frames(10, 25000)); // warmup → minimal
      final len = changes.length;
      // Under budget — no step-up
      adapter.simulateFrameTimings(_frames(10, 3000));
      adapter.simulateFrameTimings(_frames(10, 3000));
      expect(changes.length, len); // no new changes
    });
  });

  // ── in-range windows reset hysteresis counter ─────────────────────────────

  group('in-range window resets over-budget counter', () {
    test('one over-budget + one in-range → counter resets → no step-down', () {
      final changes = <GlassQuality>[];
      final adapter = _make(onChange: (_, to) => changes.add(to));
      adapter.simulateFrameTimings(_frames(10, 10000)); // → premium
      final base = changes.length;
      // 1 over-budget
      adapter.simulateFrameTimings(_frames(10, 30000));
      // 1 in-range (exactly on budget)
      adapter.simulateFrameTimings(_frames(10, 16000));
      // 1 more over-budget (only 1 consecutive now — needs 2 to step down)
      adapter.simulateFrameTimings(_frames(10, 30000));
      expect(changes.length, base); // no step-down
    });
  });

  // ── session cache clamping to new adapter's quality range ─────────────────

  group('session cache clamped to adapter range', () {
    test('cached premium is capped to max=standard on second adapter', () {
      // Settle to premium
      final first = _make();
      first.simulateFrameTimings(_frames(10, 8000));
      expect(GlassQualityAdapter.sessionSettledQuality, GlassQuality.premium);

      // New adapter with max=standard clamps cached premium → standard
      final second = _make(max: GlassQuality.standard);
      second.start();
      expect(second.currentQuality, GlassQuality.standard);
      expect(second.usedCachedQuality, isTrue);
      second.stop();
    });

    test('cached minimal is raised to min=standard on second adapter', () {
      final first = _make();
      first.simulateFrameTimings(_frames(10, 35000)); // 35 ms > 28 ms → minimal
      expect(GlassQualityAdapter.sessionSettledQuality, GlassQuality.minimal);

      final second = _make(min: GlassQuality.standard);
      second.start();
      expect(second.currentQuality, GlassQuality.standard);
      second.stop();
    });
  });

  // ── initialQuality overrides session cache ────────────────────────────────

  group('initialQuality', () {
    test('skips warmup phase and goes directly to runtime', () {
      final adapter = _make(initialQuality: GlassQuality.standard);
      adapter.start();
      expect(adapter.phase, AdaptivePhase.runtime);
      expect(adapter.usedCachedQuality, isTrue);
      adapter.stop();
    });

    test('is clamped up to minQuality if below range', () {
      final adapter = _make(
        min: GlassQuality.standard,
        max: GlassQuality.premium,
        initialQuality: GlassQuality.minimal,
      );
      adapter.start();
      expect(adapter.currentQuality, GlassQuality.standard);
      adapter.stop();
    });

    test('is clamped down to maxQuality if above range', () {
      final adapter = _make(
        min: GlassQuality.minimal,
        max: GlassQuality.standard,
        initialQuality: GlassQuality.premium,
      );
      adapter.start();
      expect(adapter.currentQuality, GlassQuality.standard);
      adapter.stop();
    });
  });

  // ── lifecycle ─────────────────────────────────────────────────────────────

  group('lifecycle', () {
    test('start() is idempotent', () {
      final adapter = _make();
      adapter.start();
      expect(() => adapter.start(), returnsNormally);
      adapter.stop();
    });

    test('stop() without start is a no-op', () {
      expect(() => _make().stop(), returnsNormally);
    });

    test('isRunning reflects start/stop', () {
      final adapter = _make();
      expect(adapter.isRunning, isFalse);
      adapter.start();
      expect(adapter.isRunning, isTrue);
      adapter.stop();
      expect(adapter.isRunning, isFalse);
    });

    test('reset() after warmup returns to warmup phase', () {
      final adapter = _make();
      adapter.simulateFrameTimings(_frames(10, 10000)); // → runtime
      expect(adapter.phase, AdaptivePhase.runtime);
      adapter.reset();
      expect(adapter.phase, AdaptivePhase.warmup);
      expect(adapter.usedCachedQuality, isFalse);
    });

    test('reset() before start is safe', () {
      expect(() => _make().reset(), returnsNormally);
    });
  });

  // ── lastChangeReason ──────────────────────────────────────────────────────

  group('lastChangeReason', () {
    test('staticProbe before any quality change (skip probe enabled)', () {
      // When skipStaticProbeForTesting=true, the adapter runs an immediate static
      // probe on construction and sets lastChangeReason = staticProbe
      expect(_make().lastChangeReason,
          anyOf(isNull, GlassQualityChangeReason.staticProbe));
    });

    test('warmupComplete after Phase 2 (with quality change)', () {
      final adapter = _make();
      adapter.simulateFrameTimings(_frames(10, 18000)); // 18 ms → standard
      expect(adapter.lastChangeReason, GlassQualityChangeReason.warmupComplete);
    });

    test('thermalDegradation after step-down', () {
      final adapter = _make();
      adapter.simulateFrameTimings(_frames(10, 10000)); // → premium
      adapter.simulateFrameTimings(_frames(10, 30000));
      adapter.simulateFrameTimings(_frames(10, 30000));
      expect(adapter.lastChangeReason,
          GlassQualityChangeReason.thermalDegradation);
    });

    test('thermalRecovery after step-up', () {
      final adapter = _make(allowStepUp: true);
      adapter.simulateFrameTimings(_frames(10, 25000)); // → minimal
      adapter.simulateFrameTimings(_frames(10, 3000));
      adapter.simulateFrameTimings(_frames(10, 3000));
      expect(
          adapter.lastChangeReason, GlassQualityChangeReason.thermalRecovery);
    });

    test('restoredFromCache on second adapter start', () {
      final first = _make();
      first.simulateFrameTimings(
          _frames(10, 21000)); // 21 ms → standard → write cache
      final second = _make();
      second.start();
      expect(
          second.lastChangeReason, GlassQualityChangeReason.restoredFromCache);
      second.stop();
    });
  });

  // ── skipInitialFrames ─────────────────────────────────────────────────────

  group('skipInitialFrames', () {
    test('skipped frames do not count toward warmup', () {
      GlassQualityAdapter.skipInitialFrames = 5;
      GlassQualityAdapter.warmupFrames = 5;
      final adapter = _make();
      // 5 very slow frames — should be discarded
      adapter.simulateFrameTimings(_frames(5, 50000));
      expect(adapter.phase, AdaptivePhase.warmup); // still in warmup
      // 5 fast frames — warmup completes at premium
      adapter.simulateFrameTimings(_frames(5, 5000));
      expect(adapter.currentQuality, GlassQuality.premium);
    });

    test('skip counter resets after reset()', () {
      GlassQualityAdapter.skipInitialFrames = 3;
      GlassQualityAdapter.warmupFrames = 3;
      final adapter = _make();
      adapter.simulateFrameTimings(_frames(2, 50000)); // partial skip
      adapter.reset();
      // Full skip + warmup cycle again
      adapter.simulateFrameTimings(_frames(3, 50000)); // new skip window
      adapter.simulateFrameTimings(_frames(3, 5000)); // warmup
      expect(adapter.phase, AdaptivePhase.runtime);
      expect(adapter.currentQuality, GlassQuality.premium);
    });
  });

  // ── Percentile boundary values ────────────────────────────────────────────

  group('percentile boundary values', () {
    test('P75 just under 20 ms stays premium', () {
      final adapter = _make();
      adapter.simulateFrameTimings(_frames(10, 19999)); // 19.999 ms < 20 ms
      expect(adapter.currentQuality, GlassQuality.premium);
    });

    test('P75 at exactly 20 ms steps to standard', () {
      final adapter = _make();
      adapter
          .simulateFrameTimings(_frames(10, 20000)); // 20 ms ≥ 20 ms threshold
      expect(adapter.currentQuality, GlassQuality.standard);
    });

    test('P75 just over 28 ms steps to minimal', () {
      final adapter = _make();
      adapter
          .simulateFrameTimings(_frames(10, 29000)); // 29 ms > 28 ms threshold
      expect(adapter.currentQuality, GlassQuality.minimal);
    });
  });

  // ── Static probe platform behavior ────────────────────────────────────────

  group('static probe platform behavior', () {
    test('static probe runs on start when skipStaticProbeForTesting is false',
        () {
      GlassQualityAdapter.skipStaticProbeForTesting = false;
      addTearDown(() => GlassQualityAdapter.skipStaticProbeForTesting = true);

      final adapter = _make(max: GlassQuality.premium);
      adapter.start();
      expect(adapter.currentQuality, isNot(GlassQuality.premium));
      adapter.stop();
    });
  });
}
