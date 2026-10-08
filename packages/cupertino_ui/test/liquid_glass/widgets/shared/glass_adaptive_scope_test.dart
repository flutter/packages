import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:liquid_glass_widgets/utils/glass_quality_adapter.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Wraps [child] in a minimal Material app.
Widget _app(Widget child) => MaterialApp(home: Scaffold(body: child));

// ---------------------------------------------------------------------------
// Widget tests
// ---------------------------------------------------------------------------

void main() {
  setUp(() {
    GlassQualityAdapter.warmupFrames = 5;
    GlassQualityAdapter.windowSize = 5;
    GlassQualityAdapter.degradeWindowCount = 3;
    GlassQualityAdapter.upgradeWindowCount = 10;
    GlassQualityAdapter.cooldownDuration = Duration.zero;
    GlassQualityAdapter.skipStaticProbeForTesting = true;
  });

  tearDown(() {
    GlassQualityAdapter.skipStaticProbeForTesting = false;
  });

  // ── Basic construction ─────────────────────────────────────────────────────

  group('GlassAdaptiveScope — construction', () {
    testWidgets('builds without error with defaults', (tester) async {
      await tester.pumpWidget(_app(
        const GlassAdaptiveScope(child: SizedBox.shrink()),
      ));
      expect(tester.takeException(), isNull);
    });

    testWidgets('seeds at maxQuality on Apple when initialQuality is null',
        (tester) async {
      // Android also seeds at maxQuality now (Best Foot Forward).
      GlassAdaptiveScopeData? captured;
      await tester.pumpWidget(_app(
        GlassAdaptiveScope(
          maxQuality: GlassQuality.premium,
          child: Builder(builder: (context) {
            captured = GlassAdaptiveScopeData.of(context);
            return const SizedBox.shrink();
          }),
        ),
      ));
      await tester.pump();
      expect(captured?.effectiveQuality, GlassQuality.premium);
    },
        variant:
            TargetPlatformVariant({TargetPlatform.iOS, TargetPlatform.macOS}));

    testWidgets('initialQuality is exposed via GlassAdaptiveScopeData.of',
        (tester) async {
      GlassAdaptiveScopeData? captured;
      await tester.pumpWidget(_app(
        GlassAdaptiveScope(
          initialQuality: GlassQuality.standard,
          child: Builder(builder: (context) {
            captured = GlassAdaptiveScopeData.of(context);
            return const SizedBox.shrink();
          }),
        ),
      ));
      await tester.pump();
      expect(captured?.effectiveQuality, GlassQuality.standard);
    });

    testWidgets('seeds at maxQuality on Android when initialQuality is null',
        (tester) async {
      // The Flutter test framework defaults to TargetPlatform.android.
      // We now seed at maxQuality (Best Foot Forward).
      GlassAdaptiveScopeData? captured;
      GlassQualityAdapter.clearSessionCache();
      await tester.pumpWidget(_app(
        GlassAdaptiveScope(
          child: Builder(builder: (context) {
            captured = GlassAdaptiveScopeData.of(context);
            return const SizedBox.shrink();
          }),
        ),
      ));
      await tester.pump();
      expect(captured?.effectiveQuality, GlassQuality.premium);
    });

    testWidgets('seeds at maxQuality on iOS when initialQuality is null',
        (tester) async {
      // On iOS / macOS, Metal shaders are precompiled — premium from frame 1
      // is safe and provides the best first-impression experience.
      // Unlike Android, _conservativeInitialQuality returns max directly.
      GlassAdaptiveScopeData? captured;
      GlassQualityAdapter.clearSessionCache();
      await tester.pumpWidget(_app(
        GlassAdaptiveScope(
          maxQuality: GlassQuality.premium,
          child: Builder(builder: (context) {
            captured = GlassAdaptiveScopeData.of(context);
            return const SizedBox.shrink();
          }),
        ),
      ));
      await tester.pump();
      expect(captured?.effectiveQuality, GlassQuality.premium);
    },
        variant:
            TargetPlatformVariant({TargetPlatform.iOS, TargetPlatform.macOS}));

    testWidgets(
        'seeds at minimal on Android when maxQuality is minimal and initialQuality is null',
        (tester) async {
      // maxQuality is minimal, so we seed at minimal on all platforms.
      GlassAdaptiveScopeData? captured;
      GlassQualityAdapter.clearSessionCache();
      await tester.pumpWidget(_app(
        GlassAdaptiveScope(
          maxQuality: GlassQuality.minimal,
          child: Builder(builder: (context) {
            captured = GlassAdaptiveScopeData.of(context);
            return const SizedBox.shrink();
          }),
        ),
      ));
      await tester.pump();
      expect(captured?.effectiveQuality, GlassQuality.minimal);
    });
  });

  // ── GlassAdaptiveScopeData accessors ──────────────────────────────────────

  group('GlassAdaptiveScopeData accessors', () {
    testWidgets('maybeOf returns null outside any scope', (tester) async {
      GlassAdaptiveScopeData? result;
      await tester.pumpWidget(_app(
        Builder(builder: (context) {
          result = GlassAdaptiveScopeData.maybeOf(context);
          return const SizedBox.shrink();
        }),
      ));
      await tester.pump();
      expect(result, isNull);
    });

    testWidgets('maybeOf returns data inside scope', (tester) async {
      GlassAdaptiveScopeData? result;
      await tester.pumpWidget(_app(
        GlassAdaptiveScope(
          child: Builder(builder: (context) {
            result = GlassAdaptiveScopeData.maybeOf(context);
            return const SizedBox.shrink();
          }),
        ),
      ));
      await tester.pump();
      expect(result, isNotNull);
    });

    testWidgets(
        'GlassAdaptiveScopeData.of throws an AssertionError outside scope',
        (tester) async {
      await tester.pumpWidget(_app(
        Builder(builder: (context) {
          GlassAdaptiveScopeData.of(context);
          return const SizedBox.shrink();
        }),
      ));
      expect(tester.takeException(), isA<AssertionError>());
    });
  });

  // ── GlassAdaptiveScopeData value type ────────────────────────────────────

  group('GlassAdaptiveScopeData value type', () {
    test('equality holds for identical values', () {
      const a = GlassAdaptiveScopeData(
        effectiveQuality: GlassQuality.premium,
        phase: AdaptivePhase.runtime,
      );
      const b = GlassAdaptiveScopeData(
        effectiveQuality: GlassQuality.premium,
        phase: AdaptivePhase.runtime,
      );
      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
    });

    test('inequality when quality differs', () {
      const a = GlassAdaptiveScopeData(
        effectiveQuality: GlassQuality.premium,
        phase: AdaptivePhase.runtime,
      );
      const b = GlassAdaptiveScopeData(
        effectiveQuality: GlassQuality.standard,
        phase: AdaptivePhase.runtime,
      );
      expect(a, isNot(equals(b)));
    });

    test('inequality when phase differs', () {
      const a = GlassAdaptiveScopeData(
        effectiveQuality: GlassQuality.premium,
        phase: AdaptivePhase.warmup,
      );
      const b = GlassAdaptiveScopeData(
        effectiveQuality: GlassQuality.premium,
        phase: AdaptivePhase.runtime,
      );
      expect(a, isNot(equals(b)));
    });

    test('toString includes quality and phase', () {
      const data = GlassAdaptiveScopeData(
        effectiveQuality: GlassQuality.standard,
        phase: AdaptivePhase.runtime,
      );
      expect(data.toString(), contains('standard'));
      expect(data.toString(), contains('runtime'));
    });
  });

  // ── Widget config update (didUpdateWidget) ────────────────────────────────

  group('didUpdateWidget', () {
    testWidgets('changing maxQuality recreates adapter without crash',
        (tester) async {
      await tester.pumpWidget(_app(
        const GlassAdaptiveScope(
          maxQuality: GlassQuality.premium,
          child: SizedBox.shrink(),
        ),
      ));
      await tester.pump();

      await tester.pumpWidget(_app(
        const GlassAdaptiveScope(
          maxQuality: GlassQuality.standard,
          child: SizedBox.shrink(),
        ),
      ));
      await tester.pump();

      expect(tester.takeException(), isNull);
    });

    testWidgets('changing minQuality recreates adapter without crash',
        (tester) async {
      await tester.pumpWidget(_app(
        const GlassAdaptiveScope(
          minQuality: GlassQuality.minimal,
          child: SizedBox.shrink(),
        ),
      ));
      await tester.pump();

      await tester.pumpWidget(_app(
        const GlassAdaptiveScope(
          minQuality: GlassQuality.standard,
          child: SizedBox.shrink(),
        ),
      ));
      await tester.pump();

      expect(tester.takeException(), isNull);
    });

    testWidgets('changing allowStepUp recreates adapter without crash',
        (tester) async {
      await tester.pumpWidget(_app(
        const GlassAdaptiveScope(
          allowStepUp: false,
          child: SizedBox.shrink(),
        ),
      ));
      await tester.pump();

      await tester.pumpWidget(_app(
        const GlassAdaptiveScope(
          allowStepUp: true,
          child: SizedBox.shrink(),
        ),
      ));
      await tester.pump();

      expect(tester.takeException(), isNull);
    });
  });

  // ── Dispose ───────────────────────────────────────────────────────────────

  group('dispose', () {
    testWidgets('no error when scope is removed from tree', (tester) async {
      await tester.pumpWidget(_app(
        const GlassAdaptiveScope(child: SizedBox.shrink()),
      ));
      await tester.pump();

      // Remove from tree — triggers dispose.
      await tester.pumpWidget(_app(const SizedBox.shrink()));
      await tester.pump();

      expect(tester.takeException(), isNull);
    });
  });

  // ── Nested scopes ─────────────────────────────────────────────────────────

  group('nested scopes', () {
    testWidgets('inner scope shadows outer scope for descendants below it',
        (tester) async {
      GlassAdaptiveScopeData? outerData;
      GlassAdaptiveScopeData? innerData;

      await tester.pumpWidget(_app(
        GlassAdaptiveScope(
          initialQuality: GlassQuality.premium,
          child: Column(
            children: [
              Builder(builder: (ctx) {
                outerData = GlassAdaptiveScopeData.of(ctx);
                return const SizedBox.shrink();
              }),
              GlassAdaptiveScope(
                initialQuality: GlassQuality.standard,
                child: Builder(builder: (ctx) {
                  innerData = GlassAdaptiveScopeData.of(ctx);
                  return const SizedBox.shrink();
                }),
              ),
            ],
          ),
        ),
      ));
      await tester.pump();

      expect(outerData?.effectiveQuality, GlassQuality.premium);
      expect(innerData?.effectiveQuality, GlassQuality.standard);
    });
  });

  // ── onQualityChanged callback ─────────────────────────────────────────────

  group('onQualityChanged', () {
    testWidgets('no crash when callback is null', (tester) async {
      await tester.pumpWidget(_app(
        const GlassAdaptiveScope(child: SizedBox.shrink()),
      ));
      await tester.pump();
      expect(tester.takeException(), isNull);
    });

    testWidgets('no crash when callback is provided', (tester) async {
      final events = <(GlassQuality, GlassQuality)>[];
      await tester.pumpWidget(_app(
        GlassAdaptiveScope(
          onQualityChanged: (from, to) => events.add((from, to)),
          child: const SizedBox.shrink(),
        ),
      ));
      await tester.pump();
      // No error — static probe ran; callback not called if quality unchanged.
      expect(tester.takeException(), isNull);
    });
  });

  // ── AdaptivePhase enum ────────────────────────────────────────────────────

  group('AdaptivePhase enum', () {
    test('all three phases exist', () {
      expect(
          AdaptivePhase.values,
          containsAll([
            AdaptivePhase.probe,
            AdaptivePhase.warmup,
            AdaptivePhase.runtime,
          ]));
    });
  });

  // ── GlassQualityChangeReason enum ────────────────────────────────────────

  group('GlassQualityChangeReason enum', () {
    test('all five values exist', () {
      expect(
        GlassQualityChangeReason.values,
        containsAll([
          GlassQualityChangeReason.staticProbe,
          GlassQualityChangeReason.restoredFromCache,
          GlassQualityChangeReason.warmupComplete,
          GlassQualityChangeReason.thermalDegradation,
          GlassQualityChangeReason.thermalRecovery,
        ]),
      );
    });
  });

  // ── GlassAdaptiveDiagnostic value type ───────────────────────────────────

  group('GlassAdaptiveDiagnostic', () {
    test('toString contains quality, reason, and phase', () {
      const d = GlassAdaptiveDiagnostic(
        from: GlassQuality.premium,
        to: GlassQuality.standard,
        reason: GlassQualityChangeReason.warmupComplete,
        phase: AdaptivePhase.runtime,
        p75Ms: 14.2,
        framesMeasured: 10,
      );
      final s = d.toString();
      expect(s, contains('premium'));
      expect(s, contains('standard'));
      expect(s, contains('warmupComplete'));
      expect(s, contains('runtime'));
      expect(s, contains('14.2'));
      expect(s, contains('10'));
    });

    test('toString works when optional fields are null', () {
      const d = GlassAdaptiveDiagnostic(
        from: GlassQuality.standard,
        to: GlassQuality.minimal,
        reason: GlassQualityChangeReason.staticProbe,
        phase: AdaptivePhase.probe,
      );
      // Must not throw.
      expect(d.toString(), isNotEmpty);
      expect(d.toString(), contains('staticProbe'));
    });

    test('p95Ms appears in toString when set', () {
      const d = GlassAdaptiveDiagnostic(
        from: GlassQuality.premium,
        to: GlassQuality.standard,
        reason: GlassQualityChangeReason.thermalDegradation,
        phase: AdaptivePhase.runtime,
        p95Ms: 28.5,
      );
      expect(d.toString(), contains('28.5'));
    });
  });

  // ── onDiagnostic callback ─────────────────────────────────────────────────

  group('onDiagnostic callback', () {
    testWidgets('no crash when onDiagnostic is null', (tester) async {
      await tester.pumpWidget(_app(
        const GlassAdaptiveScope(child: SizedBox.shrink()),
      ));
      await tester.pump();
      expect(tester.takeException(), isNull);
    });

    testWidgets('no crash when onDiagnostic is provided', (tester) async {
      final received = <GlassAdaptiveDiagnostic>[];
      await tester.pumpWidget(_app(
        GlassAdaptiveScope(
          onDiagnostic: received.add,
          child: const SizedBox.shrink(),
        ),
      ));
      await tester.pump();
      expect(tester.takeException(), isNull);
    });
  });

  // ── debugLogDiagnostics ───────────────────────────────────────────────────

  group('debugLogDiagnostics', () {
    testWidgets('does not crash when true', (tester) async {
      await tester.pumpWidget(_app(
        const GlassAdaptiveScope(
          debugLogDiagnostics: true,
          child: SizedBox.shrink(),
        ),
      ));
      await tester.pump();
      expect(tester.takeException(), isNull);
    });

    testWidgets('does not crash when false (default)', (tester) async {
      await tester.pumpWidget(_app(
        const GlassAdaptiveScope(
          // ignore: avoid_redundant_argument_values
          debugLogDiagnostics: false,
          child: SizedBox.shrink(),
        ),
      ));
      await tester.pump();
      expect(tester.takeException(), isNull);
    });
  });

  // ── Warmup threshold wiring (widget-level) ────────────────────────────────

  group('warmup threshold wiring', () {
    testWidgets('warmupPremiumThresholdMs is accepted and stored without crash',
        (tester) async {
      await tester.pumpWidget(_app(
        const GlassAdaptiveScope(
          warmupPremiumThresholdMs: 24.0,
          child: SizedBox.shrink(),
        ),
      ));
      await tester.pump();
      expect(tester.takeException(), isNull);

      final scope = tester.widget<GlassAdaptiveScope>(
        find.byType(GlassAdaptiveScope),
      );
      expect(scope.warmupPremiumThresholdMs, 24.0);
    });

    testWidgets(
        'warmupStandardThresholdMs is accepted and stored without crash',
        (tester) async {
      await tester.pumpWidget(_app(
        const GlassAdaptiveScope(
          warmupStandardThresholdMs: 32.0,
          child: SizedBox.shrink(),
        ),
      ));
      await tester.pump();
      expect(tester.takeException(), isNull);

      final scope = tester.widget<GlassAdaptiveScope>(
        find.byType(GlassAdaptiveScope),
      );
      expect(scope.warmupStandardThresholdMs, 32.0);
    });

    testWidgets(
        'changing warmupPremiumThresholdMs via didUpdateWidget recreates '
        'adapter without crash', (tester) async {
      await tester.pumpWidget(_app(
        const GlassAdaptiveScope(
          warmupPremiumThresholdMs: 20.0,
          child: SizedBox.shrink(),
        ),
      ));
      await tester.pump();

      await tester.pumpWidget(_app(
        const GlassAdaptiveScope(
          warmupPremiumThresholdMs: 24.0,
          child: SizedBox.shrink(),
        ),
      ));
      await tester.pump();

      expect(tester.takeException(), isNull);
    });

    testWidgets(
        'changing warmupStandardThresholdMs via didUpdateWidget recreates '
        'adapter without crash', (tester) async {
      await tester.pumpWidget(_app(
        const GlassAdaptiveScope(
          warmupStandardThresholdMs: 28.0,
          child: SizedBox.shrink(),
        ),
      ));
      await tester.pump();

      await tester.pumpWidget(_app(
        const GlassAdaptiveScope(
          warmupStandardThresholdMs: 32.0,
          child: SizedBox.shrink(),
        ),
      ));
      await tester.pump();

      expect(tester.takeException(), isNull);
    });

    testWidgets(
        'both thresholds together — custom values stored and adapter stable',
        (tester) async {
      await tester.pumpWidget(_app(
        const GlassAdaptiveScope(
          warmupPremiumThresholdMs: 22.0,
          warmupStandardThresholdMs: 30.0,
          child: SizedBox.shrink(),
        ),
      ));
      await tester.pump();
      expect(tester.takeException(), isNull);

      final scope = tester.widget<GlassAdaptiveScope>(
        find.byType(GlassAdaptiveScope),
      );
      expect(scope.warmupPremiumThresholdMs, 22.0);
      expect(scope.warmupStandardThresholdMs, 30.0);
    });
  });
}
