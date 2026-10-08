// ignore_for_file: require_trailing_commas
// Coverage-targeted tests for LightweightLiquidGlass.
// Targets uncovered branches:
//   - LightweightLiquidGlass.inLayer constructor (settings=null → inherited)
//   - skipBlur=true when ancestor provides blur
//   - _RenderLightweightGlass property setters (no-change guard)
//   - shader == null → ClipPath fallback rendering
//   - Asymmetric shape: LiquidVerticalRoundedSuperellipse
//   - Dynamic property extraction: borderRadius as num / BorderRadius / BorderRadiusGeometry
//   - Class-name heuristics: oval/circle/stadium fallback
//   - preWarm guard: _isPreparing=true / _cachedProgram != null

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

import '../../shared/test_helpers.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

const _settings = LiquidGlassSettings(
  thickness: 20,
  blur: 2,
  glassColor: Color(0x3DFFFFFF),
);

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  setUp(() {
    LightweightLiquidGlass.resetForTesting();
  });

  tearDown(() {
    LightweightLiquidGlass.resetForTesting();
  });

  // ── Shader null → clip wrap fallback ──────────────────────────────────────

  group('LightweightLiquidGlass — fallback (shader == null)', () {
    testWidgets('renders ClipRRect fallback for RoundedRectangleBorder shapes',
        (tester) async {
      // resetForTesting ensures _cachedProgram == null → fallback path.
      await tester.pumpWidget(
        createTestApp(
          child: LightweightLiquidGlass(
            shape: const LiquidRoundedRectangle(borderRadius: 16),
            settings: _settings,
            child: const SizedBox(width: 80, height: 40),
          ),
        ),
      );
      await tester.pump();
      // Shapes that resolve to RoundedRectangleBorder are wrapped in
      // ClipRRect (not ClipPath) so Flutter PR #177551's PlatformView
      // clip-forwarding kicks in over a PlatformView backdrop.
      expect(find.byType(ClipRRect), findsAtLeastNWidgets(1));
    });

    testWidgets('LiquidOval fallback uses ClipPath', (tester) async {
      // LiquidOval is intentionally NOT routed through ClipRRect — the
      // engine fix doesn't trigger for it (see _ShapeClip doc comment).
      // The fallback remains ClipPath.
      await tester.pumpWidget(
        createTestApp(
          child: LightweightLiquidGlass(
            shape: const LiquidOval(),
            settings: _settings,
            child: const SizedBox(width: 80, height: 80),
          ),
        ),
      );
      await tester.pump();
      expect(find.byType(ClipPath), findsAtLeastNWidgets(1));
    });
  });

  // ── .inLayer constructor ───────────────────────────────────────────────────

  group('LightweightLiquidGlass.inLayer', () {
    testWidgets(
        'inherits settings from InheritedLiquidGlass when settings=null',
        (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: AdaptiveLiquidGlassLayer(
            settings: settingsWithoutLighting,
            child: LightweightLiquidGlass.inLayer(
              shape: const LiquidRoundedSuperellipse(borderRadius: 16),
              child: const SizedBox(width: 80, height: 40),
            ),
          ),
        ),
      );
      await tester.pump();
      expect(find.byType(LightweightLiquidGlass), findsOneWidget);
    });

    testWidgets('inLayer with glow and density params does not crash',
        (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: AdaptiveLiquidGlassLayer(
            settings: settingsWithoutLighting,
            child: LightweightLiquidGlass.inLayer(
              shape: const LiquidRoundedSuperellipse(borderRadius: 24),
              glowIntensity: 0.5,
              densityFactor: 0.3,
              indicatorWeight: 0.8,
              child: const SizedBox(width: 80, height: 40),
            ),
          ),
        ),
      );
      await tester.pump();
      expect(find.byType(LightweightLiquidGlass), findsOneWidget);
    });
  });

  // ── skipBlur via ancestor ──────────────────────────────────────────────────

  group('LightweightLiquidGlass — skipBlur from ancestor', () {
    testWidgets('blur-providing ancestor causes skipBlur=true path',
        (tester) async {
      // InheritedLiquidGlass with isBlurProvidedByAncestor=true and matching
      // blur value → skipBlur = true → _paintGlassContent without BackdropFilter.
      await tester.pumpWidget(
        createTestApp(
          child: LiquidGlassLayer(
            settings: settingsWithoutLighting,
            child: LightweightLiquidGlass.inLayer(
              shape: const LiquidRoundedSuperellipse(borderRadius: 16),
              child: const SizedBox(width: 80, height: 40),
            ),
          ),
        ),
      );
      await tester.pump();
      expect(find.byType(LightweightLiquidGlass), findsOneWidget);
    });
  });

  // ── Shape rendering variants ───────────────────────────────────────────────

  group('LightweightLiquidGlass — shape variants', () {
    for (final shape in <LiquidShape>[
      const LiquidRoundedSuperellipse(borderRadius: 20),
      const LiquidOval(),
      const LiquidRoundedRectangle(borderRadius: 12),
      const LiquidVerticalRoundedSuperellipse(topRadius: 30, bottomRadius: 10),
    ]) {
      testWidgets('${shape.runtimeType} renders without crash', (tester) async {
        await tester.pumpWidget(
          createTestApp(
            child: LightweightLiquidGlass(
              shape: shape,
              settings: _settings,
              child: const SizedBox(width: 80, height: 60),
            ),
          ),
        );
        await tester.pump();
        expect(find.byType(LightweightLiquidGlass), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }
  });

  // ── Property change paths (didUpdateWidget / updateRenderObject) ──────────

  group('LightweightLiquidGlass — property changes trigger rebuild', () {
    testWidgets('changing glowIntensity updates render object', (tester) async {
      double glow = 0.0;
      late StateSetter outerSetState;

      await tester.pumpWidget(
        createTestApp(
          child: StatefulBuilder(
            builder: (ctx, setState) {
              outerSetState = setState;
              return LightweightLiquidGlass(
                shape: const LiquidRoundedSuperellipse(borderRadius: 16),
                settings: _settings,
                glowIntensity: glow,
                child: const SizedBox(width: 80, height: 40),
              );
            },
          ),
        ),
      );
      await tester.pump();

      outerSetState(() => glow = 0.8);
      await tester.pump();
      expect(tester.takeException(), isNull);
    });

    testWidgets('changing densityFactor updates render object', (tester) async {
      double density = 0.0;
      late StateSetter outerSetState;

      await tester.pumpWidget(
        createTestApp(
          child: StatefulBuilder(
            builder: (ctx, setState) {
              outerSetState = setState;
              return LightweightLiquidGlass(
                shape: const LiquidRoundedSuperellipse(borderRadius: 16),
                settings: _settings,
                densityFactor: density,
                child: const SizedBox(width: 80, height: 40),
              );
            },
          ),
        ),
      );
      await tester.pump();

      outerSetState(() => density = 0.5);
      await tester.pump();
      expect(tester.takeException(), isNull);
    });

    testWidgets('changing indicatorWeight updates render object',
        (tester) async {
      double indicator = 0.0;
      late StateSetter outerSetState;

      await tester.pumpWidget(
        createTestApp(
          child: StatefulBuilder(
            builder: (ctx, setState) {
              outerSetState = setState;
              return LightweightLiquidGlass(
                shape: const LiquidRoundedSuperellipse(borderRadius: 16),
                settings: _settings,
                indicatorWeight: indicator,
                child: const SizedBox(width: 80, height: 40),
              );
            },
          ),
        ),
      );
      await tester.pump();

      outerSetState(() => indicator = 1.0);
      await tester.pump();
      expect(tester.takeException(), isNull);
    });

    testWidgets('changing settings to same value uses no-op guard',
        (tester) async {
      // The setter guard: if (_settings == value) return; → covered by pumping
      // same settings twice.
      await tester.pumpWidget(
        createTestApp(
          child: LightweightLiquidGlass(
            shape: const LiquidRoundedSuperellipse(borderRadius: 16),
            settings: _settings,
            child: const SizedBox(width: 80, height: 40),
          ),
        ),
      );
      await tester.pump();
      // Pump with identical settings — no-op guard exercised.
      await tester.pump();
      expect(tester.takeException(), isNull);
    });

    testWidgets('changing shape re-routes clipShape logic', (tester) async {
      LiquidShape shape = const LiquidRoundedSuperellipse(borderRadius: 8);
      late StateSetter outerSetState;

      await tester.pumpWidget(
        createTestApp(
          child: StatefulBuilder(
            builder: (ctx, setState) {
              outerSetState = setState;
              return LightweightLiquidGlass(
                shape: shape,
                settings: _settings,
                child: const SizedBox(width: 80, height: 40),
              );
            },
          ),
        ),
      );
      await tester.pump();

      // Switch to LiquidVerticalRoundedSuperellipse → asymmetric shader path
      outerSetState(() => shape = const LiquidVerticalRoundedSuperellipse(
          topRadius: 24, bottomRadius: 8));
      await tester.pump();

      // Switch to LiquidOval → oval/stadium heuristic
      outerSetState(() => shape = const LiquidOval());
      await tester.pump();

      expect(tester.takeException(), isNull);
    });
  });

  // ── preWarm guard branches ─────────────────────────────────────────────────

  group('LightweightLiquidGlass.preWarm guards', () {
    test('calling preWarm twice is idempotent (no crash)', () async {
      // First call sets _isPreparing=true while async; second call returns early.
      final f1 = LightweightLiquidGlass.preWarm();
      final f2 = LightweightLiquidGlass.preWarm(); // should return early
      await Future.wait([f1, f2]);
      // No assertions needed — absence of exceptions = success.
    });
  });

  // ── dispose path ──────────────────────────────────────────────────────────

  group('LightweightLiquidGlass — dispose', () {
    testWidgets('disposed widget does not crash', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: LightweightLiquidGlass(
            shape: const LiquidRoundedSuperellipse(borderRadius: 16),
            settings: _settings,
            child: const SizedBox(width: 80, height: 40),
          ),
        ),
      );
      await tester.pump();
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
      expect(find.byType(LightweightLiquidGlass), findsNothing);
    });
  });

  // ── Remaining setter paths (skipBlur, backdropLuma, shape no-op) ──────────
  // These call updateRenderObject → setter no-op guards in
  // _RenderLightweightGlass (lines 367-405 in lightweight_liquid_glass.dart).

  group('LightweightLiquidGlass — skipBlur and backdropLuma setter paths', () {
    testWidgets('platform brightness change triggers backdropLuma setter',
        (tester) async {
      // Build in dark mode, then simulate light mode via MediaQuery override.
      Brightness brightness = Brightness.dark;
      late StateSetter outerSetState;

      await tester.pumpWidget(
        createTestApp(
          child: StatefulBuilder(
            builder: (ctx, setState) {
              outerSetState = setState;
              return MediaQuery(
                data: MediaQueryData(platformBrightness: brightness),
                child: LightweightLiquidGlass(
                  shape: const LiquidRoundedSuperellipse(borderRadius: 16),
                  settings: _settings,
                  child: const SizedBox(width: 80, height: 40),
                ),
              );
            },
          ),
        ),
      );
      await tester.pump();

      // Change brightness → backdropLuma value changes → setter fires
      outerSetState(() => brightness = Brightness.light);
      await tester.pump();

      // Same brightness → no-op guard
      await tester.pump();
      expect(tester.takeException(), isNull);
    });

    testWidgets(
        'skipBlur setter: switching from ancestor-blur to non-ancestor-blur',
        (tester) async {
      // First render inside LiquidGlassLayer (skipBlur=true), then
      // re-parent outside it (skipBlur=false) to fire the setter.
      bool useLayer = true;
      late StateSetter outerSetState;

      Widget buildChild() {
        return LightweightLiquidGlass.inLayer(
          shape: const LiquidRoundedSuperellipse(borderRadius: 16),
          child: const SizedBox(width: 80, height: 40),
        );
      }

      await tester.pumpWidget(
        createTestApp(
          child: StatefulBuilder(
            builder: (ctx, setState) {
              outerSetState = setState;
              if (useLayer) {
                return LiquidGlassLayer(
                  settings: settingsWithoutLighting,
                  child: buildChild(),
                );
              } else {
                // No layer ancestor → skipBlur=false
                return AdaptiveLiquidGlassLayer(
                  settings: settingsWithoutLighting,
                  child: buildChild(),
                );
              }
            },
          ),
        ),
      );
      await tester.pump();

      // Toggle → different skipBlur value → setter fires
      outerSetState(() => useLayer = false);
      await tester.pump();

      expect(tester.takeException(), isNull);
    });

    testWidgets('shape setter no-op guard (same shape pumped twice)',
        (tester) async {
      const shape = LiquidRoundedSuperellipse(borderRadius: 16);

      await tester.pumpWidget(
        createTestApp(
          child: LightweightLiquidGlass(
            shape: shape,
            settings: _settings,
            child: const SizedBox(width: 80, height: 40),
          ),
        ),
      );
      await tester.pump();
      // Re-pump with identical shape → no-op guard in set shape()
      await tester.pump();
      expect(tester.takeException(), isNull);
    });
  });
  // ── Ticker self-stopping / zero-cost when sampling disabled ─────────────

  group('LightweightLiquidGlass — Ticker zero-cost guarantees', () {
    testWidgets(
        'no backgroundKey → no crash and no RepaintBoundary capture attempted',
        (tester) async {
      // When backgroundKey is null the Ticker must not start.
      // Observable: no exceptions thrown, widget renders normally.
      await tester.pumpWidget(
        createTestApp(
          child: LightweightLiquidGlass(
            shape: const LiquidRoundedSuperellipse(borderRadius: 16),
            settings: _settings,
            // No backgroundKey — simulates glass widget outside LiquidGlassScope.
            child: const SizedBox(width: 80, height: 40),
          ),
        ),
      );
      // Pump several frames to confirm the Ticker stays idle.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 32));
      expect(tester.takeException(), isNull);
    });

    testWidgets(
        'backgroundKey present but no RepaintBoundary context → no crash',
        (tester) async {
      // This simulates GlassBackgroundSource(enabled: false): the GlobalKey
      // exists in the scope but has no RepaintBoundary element attached.
      // _updateTicker must detect hasBoundary=false and NOT start the Ticker.
      // _handleTick (if it somehow fires) must self-stop without crashing.
      final orphanKey = GlobalKey();

      await tester.pumpWidget(
        createTestApp(
          child: LightweightLiquidGlass(
            shape: const LiquidRoundedSuperellipse(borderRadius: 16),
            settings: _settings,
            backgroundKey: orphanKey, // key exists; no RepaintBoundary uses it
            child: const SizedBox(width: 80, height: 40),
          ),
        ),
      );
      // Allow multiple frames — the Ticker must NOT fire and crash.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 32));
      expect(tester.takeException(), isNull);
    });

    testWidgets('backgroundKey transitions null → non-null → null cleanly',
        (tester) async {
      // Simulates GlassPage toggling enableBackgroundSampling at runtime.
      // The Ticker must start and stop without exceptions.
      GlobalKey? bgKey;
      late StateSetter outerSetState;

      await tester.pumpWidget(
        createTestApp(
          child: StatefulBuilder(
            builder: (ctx, setState) {
              outerSetState = setState;
              return LightweightLiquidGlass(
                shape: const LiquidRoundedSuperellipse(borderRadius: 16),
                settings: _settings,
                backgroundKey: bgKey,
                child: const SizedBox(width: 80, height: 40),
              );
            },
          ),
        ),
      );
      await tester.pump();

      // Provide a key (no RepaintBoundary attached) — Ticker checks but stops.
      outerSetState(() => bgKey = GlobalKey());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 16));

      // Remove the key — Ticker must stop cleanly.
      outerSetState(() => bgKey = null);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 16));

      expect(tester.takeException(), isNull);
    });

    testWidgets('dispose while backgroundKey is set does not throw',
        (tester) async {
      final key = GlobalKey();

      await tester.pumpWidget(
        createTestApp(
          child: LightweightLiquidGlass(
            shape: const LiquidRoundedSuperellipse(borderRadius: 16),
            settings: _settings,
            backgroundKey: key,
            child: const SizedBox(width: 80, height: 40),
          ),
        ),
      );
      await tester.pump();

      // Remove widget while Ticker may be active — dispose must cancel Ticker.
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
      expect(tester.takeException(), isNull);
    });
  });
}
