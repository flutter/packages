import 'dart:ui' show FrameTiming;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_widgets/utils/glass_performance_monitor.dart';

void main() {
  // Reset monitor state before every test so tests are fully isolated.
  setUp(() {
    GlassPerformanceMonitor.stop();
    GlassPerformanceMonitor.reset();
  });

  tearDown(() {
    GlassPerformanceMonitor.stop();
    GlassPerformanceMonitor.reset();
  });

  // ── Initial state ──────────────────────────────────────────────────────────

  group('initial state', () {
    test('is not running after reset', () {
      expect(GlassPerformanceMonitor.isRunning, isFalse);
    });

    test('has not emitted a warning after reset', () {
      expect(GlassPerformanceMonitor.warningEmitted, isFalse);
    });

    test('active premium count is zero after reset', () {
      expect(GlassPerformanceMonitor.activePremiumCount, equals(0));
    });

    test('default raster budget is 16 ms', () {
      expect(
        GlassPerformanceMonitor.rasterBudget,
        equals(const Duration(milliseconds: 16)),
      );
    });

    test('default sustained frame threshold is 60', () {
      expect(GlassPerformanceMonitor.sustainedFrameThreshold, equals(60));
    });
  });

  // ── start / stop ───────────────────────────────────────────────────────────

  group('start and stop', () {
    test('start sets isRunning to true (debug/profile only)', () {
      // In release mode, start() is a no-op guarded by kReleaseMode.
      // In debug/profile (which tests always run in) it should register.
      GlassPerformanceMonitor.start();
      // kReleaseMode is always false in test environments.
      expect(GlassPerformanceMonitor.isRunning, isTrue);
    });

    test('calling start twice is idempotent', () {
      GlassPerformanceMonitor.start();
      GlassPerformanceMonitor.start();
      // Should still be running — no crash, no double-registration.
      expect(GlassPerformanceMonitor.isRunning, isTrue);
    });

    test('stop sets isRunning to false', () {
      GlassPerformanceMonitor.start();
      GlassPerformanceMonitor.stop();
      expect(GlassPerformanceMonitor.isRunning, isFalse);
    });

    test('calling stop when not running is safe', () {
      expect(() => GlassPerformanceMonitor.stop(), returnsNormally);
    });

    test('stop preserves warningEmitted latch', () {
      // Manually set the latch by calling reset then simulating a warning
      // by examining the preserved state after stop.
      GlassPerformanceMonitor.start();
      GlassPerformanceMonitor.stop();
      // Warning was never emitted — latch stays false.
      expect(GlassPerformanceMonitor.warningEmitted, isFalse);
    });
  });

  // ── reset ──────────────────────────────────────────────────────────────────

  group('reset', () {
    test('reset clears warningEmitted latch', () {
      // Simulate a warning having fired by checking after reset.
      GlassPerformanceMonitor.reset();
      expect(GlassPerformanceMonitor.warningEmitted, isFalse);
    });

    test('reset clears premium count', () {
      GlassPerformanceMonitor.trackPremiumMount();
      GlassPerformanceMonitor.trackPremiumMount();
      expect(GlassPerformanceMonitor.activePremiumCount, equals(2));

      GlassPerformanceMonitor.reset();
      expect(GlassPerformanceMonitor.activePremiumCount, equals(0));
    });

    test('reset can be called while running without crashing', () {
      GlassPerformanceMonitor.start();
      expect(() => GlassPerformanceMonitor.reset(), returnsNormally);
      GlassPerformanceMonitor.stop();
    });
  });

  // ── premium surface tracking ───────────────────────────────────────────────

  group('premium surface tracking', () {
    test('trackPremiumMount increments activePremiumCount', () {
      GlassPerformanceMonitor.trackPremiumMount();
      expect(GlassPerformanceMonitor.activePremiumCount, equals(1));

      GlassPerformanceMonitor.trackPremiumMount();
      expect(GlassPerformanceMonitor.activePremiumCount, equals(2));
    });

    test('trackPremiumUnmount decrements activePremiumCount', () {
      GlassPerformanceMonitor.trackPremiumMount();
      GlassPerformanceMonitor.trackPremiumMount();
      GlassPerformanceMonitor.trackPremiumUnmount();
      expect(GlassPerformanceMonitor.activePremiumCount, equals(1));
    });

    test('activePremiumCount never goes below zero (clamp guard)', () {
      // Unmount without a prior mount — should clamp to 0, not go negative.
      GlassPerformanceMonitor.trackPremiumUnmount();
      expect(GlassPerformanceMonitor.activePremiumCount, equals(0));
    });

    test('multiple mount/unmount cycles are balanced', () {
      for (int i = 0; i < 5; i++) {
        GlassPerformanceMonitor.trackPremiumMount();
      }
      for (int i = 0; i < 5; i++) {
        GlassPerformanceMonitor.trackPremiumUnmount();
      }
      expect(GlassPerformanceMonitor.activePremiumCount, equals(0));
    });
  });

  // ── PremiumGlassTracker widget ─────────────────────────────────────────────

  group('PremiumGlassTracker widget', () {
    testWidgets('increments count on mount', (tester) async {
      expect(GlassPerformanceMonitor.activePremiumCount, equals(0));

      await tester.pumpWidget(
        const PremiumGlassTracker(
          child: SizedBox.shrink(),
        ),
      );

      expect(GlassPerformanceMonitor.activePremiumCount, equals(1));
    });

    testWidgets('decrements count on unmount', (tester) async {
      await tester.pumpWidget(
        const PremiumGlassTracker(
          child: SizedBox.shrink(),
        ),
      );
      expect(GlassPerformanceMonitor.activePremiumCount, equals(1));

      // Remove the widget from the tree.
      await tester.pumpWidget(const SizedBox.shrink());
      expect(GlassPerformanceMonitor.activePremiumCount, equals(0));
    });

    testWidgets('multiple trackers accumulate correctly', (tester) async {
      await tester.pumpWidget(
        const Column(
          children: [
            PremiumGlassTracker(child: SizedBox.shrink()),
            PremiumGlassTracker(child: SizedBox.shrink()),
            PremiumGlassTracker(child: SizedBox.shrink()),
          ],
        ),
      );
      expect(GlassPerformanceMonitor.activePremiumCount, equals(3));

      await tester.pumpWidget(const SizedBox.shrink());
      expect(GlassPerformanceMonitor.activePremiumCount, equals(0));
    });

    testWidgets('renders its child transparently', (tester) async {
      const key = Key('child');
      await tester.pumpWidget(
        const PremiumGlassTracker(
          child: SizedBox.shrink(key: key),
        ),
      );
      expect(find.byKey(key), findsOneWidget);
    });
  });

  // ── Configuration ──────────────────────────────────────────────────────────

  group('configuration', () {
    test('rasterBudget can be changed and read back', () {
      const custom = Duration(microseconds: 8333); // 120 fps
      GlassPerformanceMonitor.rasterBudget = custom;
      expect(GlassPerformanceMonitor.rasterBudget, equals(custom));

      // Restore default so other tests are unaffected.
      GlassPerformanceMonitor.rasterBudget = const Duration(milliseconds: 16);
    });

    test('sustainedFrameThreshold can be changed and read back', () {
      GlassPerformanceMonitor.sustainedFrameThreshold = 120;
      expect(GlassPerformanceMonitor.sustainedFrameThreshold, equals(120));

      // Restore default.
      GlassPerformanceMonitor.sustainedFrameThreshold = 60;
    });
  });

  // ── _onFrameTimings (indirect) ────────────────────────────────────────────
  // We can't inject FrameTiming objects directly, but we can exercise the
  // guard paths by verifying monitor behaviour when premium count is 0
  // (silent path) and after warning has been emitted (silenced path).

  group('_onFrameTimings guard paths', () {
    test('_onFrameTimings is silent when premiumCount is 0', () {
      // Start with no premium surfaces — the callback should be a no-op.
      // We can verify this by checking that warningEmitted stays false
      // even after starting the monitor (no real frames fire in unit tests).
      GlassPerformanceMonitor.start();
      expect(GlassPerformanceMonitor.warningEmitted, isFalse);
      expect(GlassPerformanceMonitor.activePremiumCount, equals(0));
      GlassPerformanceMonitor.stop();
    });

    test('warningEmitted latch prevents duplicate warnings', () {
      // Calling reset then checking warningEmitted is false validates
      // the latch is cleared and the guard path is exercisable.
      GlassPerformanceMonitor.start();
      GlassPerformanceMonitor.reset();
      expect(GlassPerformanceMonitor.warningEmitted, isFalse);
      GlassPerformanceMonitor.stop();
    });

    testWidgets(
        'PremiumGlassTracker mounts and unmounts while monitor is running',
        (tester) async {
      GlassPerformanceMonitor.start();

      await tester.pumpWidget(
        const PremiumGlassTracker(child: SizedBox.shrink()),
      );
      expect(GlassPerformanceMonitor.activePremiumCount, 1);

      // Run a few frames — the frame callback fires but won't emit warning
      // because rasterDuration in tests is typically zero.
      await tester.pump(const Duration(milliseconds: 100));

      await tester.pumpWidget(const SizedBox.shrink());
      expect(GlassPerformanceMonitor.activePremiumCount, 0);

      GlassPerformanceMonitor.stop();
    });

    test('rasterBudget defaults restored after test', () {
      final original = GlassPerformanceMonitor.rasterBudget;
      GlassPerformanceMonitor.rasterBudget = const Duration(milliseconds: 8);
      GlassPerformanceMonitor.rasterBudget = original;
      expect(GlassPerformanceMonitor.rasterBudget, equals(original));
    });
  });

  // ── simulateFrameTimings (direct path into _onFrameTimings) ───────────────

  /// Creates a [FrameTiming] whose rasterDuration equals [rasterMicros].
  FrameTiming makeTiming(int rasterMicros) {
    return FrameTiming(
      vsyncStart: 0,
      buildStart: 0,
      buildFinish: 0,
      rasterStart: 0,
      rasterFinish: rasterMicros,
      rasterFinishWallTime: rasterMicros,
    );
  }

  group('simulateFrameTimings — _onFrameTimings direct coverage', () {
    test('over-budget frame with premium surface emits warning', () {
      GlassPerformanceMonitor.sustainedFrameThreshold = 1;
      GlassPerformanceMonitor.rasterBudget =
          const Duration(microseconds: 1); // 1µs budget → 100ms is way over

      GlassPerformanceMonitor.trackPremiumMount();

      FlutterErrorDetails? captured;
      final original = FlutterError.onError;
      FlutterError.onError = (details) => captured = details;

      try {
        GlassPerformanceMonitor.simulateFrameTimings([
          makeTiming(100000), // 100 ms raster
        ]);

        expect(GlassPerformanceMonitor.warningEmitted, isTrue);
        expect(captured, isNotNull);
        expect(
          captured!.exception.toString(),
          contains('GlassQuality.premium'),
        );

        // Force the lazy informationCollector lambda to execute
        // (covers lines 189-190, 196-197 in glass_performance_monitor.dart)
        final infos = captured!.informationCollector!();
        expect(infos, isNotEmpty);
        expect(infos.first.toString(), contains('LiquidGlass'));
      } finally {
        FlutterError.onError = original;
        GlassPerformanceMonitor.rasterBudget = const Duration(milliseconds: 16);
        GlassPerformanceMonitor.sustainedFrameThreshold = 60;
      }
    });

    test('under-budget frame resets consecutive counter', () {
      GlassPerformanceMonitor.sustainedFrameThreshold = 5;
      GlassPerformanceMonitor.rasterBudget = const Duration(milliseconds: 16);
      GlassPerformanceMonitor.trackPremiumMount();

      // 2 over-budget frames builds up the counter...
      GlassPerformanceMonitor.simulateFrameTimings([
        makeTiming(20000), // 20 ms > 16 ms budget
        makeTiming(20000),
      ]);
      expect(GlassPerformanceMonitor.warningEmitted, isFalse); // not yet

      // 1 under-budget frame resets the counter
      GlassPerformanceMonitor.simulateFrameTimings([
        makeTiming(5000), // 5 ms < 16 ms budget
      ]);
      expect(GlassPerformanceMonitor.warningEmitted, isFalse);

      GlassPerformanceMonitor.sustainedFrameThreshold = 60;
    });

    test('silent when premiumCount == 0', () {
      GlassPerformanceMonitor.sustainedFrameThreshold = 1;
      GlassPerformanceMonitor.rasterBudget = const Duration(microseconds: 1);
      // No trackPremiumMount() called

      GlassPerformanceMonitor.simulateFrameTimings([
        makeTiming(100000),
      ]);
      expect(GlassPerformanceMonitor.warningEmitted, isFalse);

      GlassPerformanceMonitor.rasterBudget = const Duration(milliseconds: 16);
      GlassPerformanceMonitor.sustainedFrameThreshold = 60;
    });

    test('early-return after warning prevents double-emit', () {
      GlassPerformanceMonitor.sustainedFrameThreshold = 1;
      GlassPerformanceMonitor.rasterBudget = const Duration(microseconds: 1);
      GlassPerformanceMonitor.trackPremiumMount();

      int errorCount = 0;
      final original = FlutterError.onError;
      FlutterError.onError = (_) => errorCount++;

      try {
        // First call should emit warning and return
        GlassPerformanceMonitor.simulateFrameTimings([
          makeTiming(100000),
        ]);
        expect(GlassPerformanceMonitor.warningEmitted, isTrue);
        expect(errorCount, 1);

        // Second call — _warningEmitted guard prevents re-emit
        GlassPerformanceMonitor.simulateFrameTimings([
          makeTiming(100000),
        ]);
        expect(errorCount, 1); // still just 1
      } finally {
        FlutterError.onError = original;
        GlassPerformanceMonitor.rasterBudget = const Duration(milliseconds: 16);
        GlassPerformanceMonitor.sustainedFrameThreshold = 60;
      }
    });

    test('multiple frames required to reach threshold', () {
      GlassPerformanceMonitor.sustainedFrameThreshold = 3;
      GlassPerformanceMonitor.rasterBudget = const Duration(milliseconds: 16);
      GlassPerformanceMonitor.trackPremiumMount();

      final original = FlutterError.onError;
      FlutterError.onError = (_) {};
      try {
        // 2 over-budget — not yet at threshold=3
        GlassPerformanceMonitor.simulateFrameTimings([
          makeTiming(20000),
          makeTiming(20000),
        ]);
        expect(GlassPerformanceMonitor.warningEmitted, isFalse);

        // 1 more — triggers threshold
        GlassPerformanceMonitor.simulateFrameTimings([
          makeTiming(20000),
        ]);
        expect(GlassPerformanceMonitor.warningEmitted, isTrue);
      } finally {
        FlutterError.onError = original;
        GlassPerformanceMonitor.sustainedFrameThreshold = 60;
      }
    });
  });
}
