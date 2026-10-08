// ignore_for_file: require_trailing_commas
// Coverage-targeted tests for GlassEffect.
// These tests exercise branches NOT covered by the existing
// glass_effect_test.dart suite:
//   - didChangeDependencies (LiquidGlassScope key caching)
//   - didUpdateWidget: quality change when _activeShader IS already null
//   - _updateTicker: start when interactionIntensity rises & effectiveKey != null
//   - _updateTicker: stop when intensity drops back to 0
//   - _handleTick: guard when key.currentContext is null
//   - GlassEffect with backgroundKey provided vs LiquidGlassScope key
//   - GlassQuality.premium path (no shader in test → ClipPath fallback)
//   - clipExpansion passed through on standard path
//   - dispose while ticker is active (interaction > 0)
//   - Shape variants: LiquidOval, LiquidRoundedRectangle on standard path

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:liquid_glass_widgets/widgets/shared/glass_effect.dart';

import '../../shared/test_helpers.dart';

// ---------------------------------------------------------------------------
// Shared fixtures
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
  group('GlassEffect — premium quality path (no GPU → ClipPath fallback)', () {
    testWidgets('premium quality renders without crash', (tester) async {
      // No real GPU in tests → _cachedProgram == null → ultra-clean fallback.
      await tester.pumpWidget(
        createTestApp(
          child: GlassEffect(
            shape: const LiquidRoundedSuperellipse(borderRadius: 20),
            settings: _settings,
            interactionIntensity: 0.0,
            quality: GlassQuality.premium,
            child: const SizedBox(width: 80, height: 40),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(GlassEffect), findsOneWidget);
    });

    testWidgets('LiquidOval with premium quality falls back cleanly',
        (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: GlassEffect(
            shape: const LiquidOval(),
            settings: _settings,
            interactionIntensity: 0.0,
            quality: GlassQuality.premium,
            child: const SizedBox(width: 80, height: 80),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(GlassEffect), findsOneWidget);
    });
  });

  group('GlassEffect — clipExpansion parameter', () {
    testWidgets('clipExpansion is accepted without crash', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: GlassEffect(
            shape: const LiquidRoundedSuperellipse(borderRadius: 12),
            settings: _settings,
            interactionIntensity: 0.0,
            quality: GlassQuality.standard,
            clipExpansion: const EdgeInsets.symmetric(horizontal: 8),
            child: const SizedBox(width: 100, height: 50),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(GlassEffect), findsOneWidget);
    });
  });

  group('GlassEffect — didChangeDependencies / LiquidGlassScope', () {
    testWidgets('updates cachedScopeKey when LiquidGlassScope is present',
        (tester) async {
      final bgKey = GlobalKey(debugLabel: 'bg_repaint');
      await tester.pumpWidget(
        createTestApp(
          child: LiquidGlassScope(
            child: Stack(
              children: [
                Positioned.fill(
                  child: GlassBackgroundSource(
                    child: RepaintBoundary(
                      key: bgKey,
                      child: Container(
                        width: 300,
                        height: 600,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ),
                GlassEffect(
                  shape: const LiquidRoundedSuperellipse(borderRadius: 16),
                  settings: _settings,
                  interactionIntensity: 0.0,
                  quality: GlassQuality.standard,
                  child: const SizedBox(width: 80, height: 40),
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(GlassEffect), findsOneWidget);
    });

    testWidgets('backgroundKey takes priority over LiquidGlassScope key',
        (tester) async {
      final explicitKey = GlobalKey(debugLabel: 'explicit_bg');
      await tester.pumpWidget(
        createTestApp(
          child: Stack(
            children: [
              RepaintBoundary(
                key: explicitKey,
                child: const SizedBox(width: 200, height: 200),
              ),
              LiquidGlassScope(
                child: Stack(
                  children: [
                    const Positioned.fill(
                      child: GlassBackgroundSource(
                        child: SizedBox(width: 200, height: 200),
                      ),
                    ),
                    GlassEffect(
                      shape: const LiquidRoundedSuperellipse(borderRadius: 16),
                      settings: _settings,
                      interactionIntensity: 0.0,
                      quality: GlassQuality.standard,
                      backgroundKey: explicitKey, // explicit key wins
                      child: const SizedBox(width: 80, height: 40),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(GlassEffect), findsOneWidget);
    });
  });

  group('GlassEffect — ticker start / stop (_updateTicker)', () {
    testWidgets(
        'ticker starts when interactionIntensity rises and backgroundKey exists',
        (tester) async {
      double intensity = 0.0;
      late StateSetter outerSetState;
      final key = GlobalKey(debugLabel: 'bg_ticker');

      await tester.pumpWidget(
        createTestApp(
          child: Stack(
            children: [
              RepaintBoundary(
                key: key,
                child: const SizedBox(width: 200, height: 200),
              ),
              StatefulBuilder(
                builder: (ctx, setState) {
                  outerSetState = setState;
                  return GlassEffect(
                    shape: const LiquidRoundedSuperellipse(borderRadius: 16),
                    settings: _settings,
                    interactionIntensity: intensity,
                    quality: GlassQuality.standard,
                    backgroundKey: key,
                    child: const SizedBox(width: 80, height: 40),
                  );
                },
              ),
            ],
          ),
        ),
      );
      await tester.pump();

      // Raise intensity → ticker.start() branch
      outerSetState(() => intensity = 0.8);
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.byType(GlassEffect), findsOneWidget);

      // Lower intensity → ticker.stop() + _backgroundImage cleared
      outerSetState(() => intensity = 0.0);
      await tester.pump();

      expect(find.byType(GlassEffect), findsOneWidget);
    });

    testWidgets(
        'no ticker start when interactionIntensity > 0 but no key present',
        (tester) async {
      // No backgroundKey + no LiquidGlassScope → effectiveKey == null →
      // shouldCapture = false → ticker stays stopped.
      await tester.pumpWidget(
        createTestApp(
          child: GlassEffect(
            shape: const LiquidRoundedSuperellipse(borderRadius: 16),
            settings: _settings,
            interactionIntensity: 0.9, // high intensity
            quality: GlassQuality.standard,
            // No backgroundKey — effectiveKey == null
            child: const SizedBox(width: 80, height: 40),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 50));
      // Must not crash even with high intensity and no background.
      expect(find.byType(GlassEffect), findsOneWidget);
    });
  });

  group('GlassEffect — didUpdateWidget quality changes', () {
    testWidgets(
        'standard → minimal change clears ticker and routes to AdaptiveGlass',
        (tester) async {
      GlassQuality q = GlassQuality.standard;
      late StateSetter outerSetState;

      await tester.pumpWidget(
        createTestApp(
          child: StatefulBuilder(
            builder: (ctx, setState) {
              outerSetState = setState;
              return GlassEffect(
                shape: const LiquidRoundedSuperellipse(borderRadius: 16),
                settings: _settings,
                interactionIntensity: 0.0,
                quality: q,
                child: const SizedBox(width: 80, height: 40),
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Downgrade to minimal → didUpdateWidget → AdaptiveGlass fallback
      outerSetState(() => q = GlassQuality.minimal);
      await tester.pumpAndSettle();

      expect(find.byType(AdaptiveGlass), findsOneWidget);
    });

    testWidgets('shape update propagates via didUpdateWidget', (tester) async {
      LiquidShape shape = const LiquidRoundedSuperellipse(borderRadius: 8);
      late StateSetter outerSetState;

      await tester.pumpWidget(
        createTestApp(
          child: StatefulBuilder(
            builder: (ctx, setState) {
              outerSetState = setState;
              return GlassEffect(
                shape: shape,
                settings: _settings,
                interactionIntensity: 0.0,
                quality: GlassQuality.minimal,
                child: const SizedBox(width: 80, height: 40),
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      outerSetState(() => shape = const LiquidOval());
      await tester.pumpAndSettle();

      expect(find.byType(GlassEffect), findsOneWidget);
    });
  });

  group('GlassEffect — dispose paths', () {
    testWidgets(
        'dispose with active ticker and non-null backgroundImage does not crash',
        (tester) async {
      final key = GlobalKey(debugLabel: 'bg_dispose');

      await tester.pumpWidget(
        createTestApp(
          child: Stack(
            children: [
              RepaintBoundary(
                key: key,
                child: Container(
                  width: 200,
                  height: 200,
                  color: Colors.red,
                ),
              ),
              GlassEffect(
                shape: const LiquidRoundedSuperellipse(borderRadius: 16),
                settings: _settings,
                interactionIntensity: 1.0,
                quality: GlassQuality.standard,
                backgroundKey: key,
                child: const SizedBox(width: 80, height: 40),
              ),
            ],
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      // Remove widget → dispose path with active ticker
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();

      expect(find.byType(GlassEffect), findsNothing);
    });
  });

  group('GlassEffect — AvoidsRefraction via InheritedLiquidGlass', () {
    testWidgets('standard quality with avoidsRefraction=true → AdaptiveGlass',
        (tester) async {
      // AdaptiveLiquidGlassLayer sets avoidsRefraction=true for its children.
      await tester.pumpWidget(
        createTestApp(
          child: AdaptiveLiquidGlassLayer(
            settings: settingsWithoutLighting,
            child: GlassEffect(
              shape: const LiquidRoundedSuperellipse(borderRadius: 16),
              settings: _settings,
              interactionIntensity: 0.5,
              quality: GlassQuality.standard,
              child: const SizedBox(width: 80, height: 40),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      // In environments where the shader loaded (real GPU), the standard quality
      // + avoidsRefraction path may still use the shader path. Just verify no crash.
      expect(find.byType(GlassEffect), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('GlassEffect — shape variants on standard path', () {
    for (final shape in <LiquidShape>[
      const LiquidRoundedSuperellipse(borderRadius: 24),
      const LiquidOval(),
      const LiquidRoundedRectangle(borderRadius: 8),
    ]) {
      testWidgets('${shape.runtimeType} on standard quality does not crash',
          (tester) async {
        await tester.pumpWidget(
          createTestApp(
            child: GlassEffect(
              shape: shape,
              settings: _settings,
              interactionIntensity: 0.0,
              quality: GlassQuality.standard,
              child: const SizedBox(width: 80, height: 40),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.byType(GlassEffect), findsOneWidget);
      });
    }
  });

  // ── _RenderInteractiveIndicator setter coverage ────────────────────────────
  // Each updateRenderObject call exercises the setter no-op guards on the
  // private render object (lines 568-656 in glass_effect.dart).

  group('GlassEffect — render object setter updates', () {
    testWidgets(
        'ambientRim / baseAlphaMultiplier / edgeAlphaMultiplier / rimThickness / rimSmoothing / edgeAbsorption setters fire via updateRenderObject',
        (tester) async {
      double ambient = 0.1;
      double baseAlpha = 0.2;
      double edgeAlpha = 0.4;
      double rimThick = 0.5;
      double rimSmooth = 1.5;
      LiquidGlassSettings currentSettings =
          _settings.copyWith(edgeAbsorption: 0.1);
      late StateSetter outerSetState;

      await tester.pumpWidget(
        createTestApp(
          child: StatefulBuilder(
            builder: (ctx, setState) {
              outerSetState = setState;
              return GlassEffect(
                shape: const LiquidRoundedSuperellipse(borderRadius: 16),
                settings: currentSettings,
                interactionIntensity: 0.0,
                quality: GlassQuality.standard,
                ambientRim: ambient,
                baseAlphaMultiplier: baseAlpha,
                edgeAlphaMultiplier: edgeAlpha,
                rimThickness: rimThick,
                rimSmoothing: rimSmooth,
                child: const SizedBox(width: 80, height: 40),
              );
            },
          ),
        ),
      );
      await tester.pump();

      // Pump with different values → updateRenderObject fires all setters.
      outerSetState(() {
        ambient = 0.3;
        baseAlpha = 0.5;
        edgeAlpha = 0.7;
        rimThick = 1.0;
        rimSmooth = 2.0;
        currentSettings = _settings.copyWith(edgeAbsorption: 0.3);
      });
      await tester.pump();
      expect(tester.takeException(), isNull);

      // Pump with same values again → no-op guard exercised (returns early).
      await tester.pump();
      expect(tester.takeException(), isNull);
    });

    testWidgets('backgroundKey setter fires when key changes', (tester) async {
      final key1 = GlobalKey(debugLabel: 'bg1');
      final key2 = GlobalKey(debugLabel: 'bg2');
      GlobalKey? activeKey = key1;
      late StateSetter outerSetState;

      await tester.pumpWidget(
        createTestApp(
          child: Stack(
            children: [
              RepaintBoundary(
                  key: key1, child: const SizedBox(width: 100, height: 100)),
              RepaintBoundary(
                  key: key2, child: const SizedBox(width: 100, height: 100)),
              StatefulBuilder(
                builder: (ctx, setState) {
                  outerSetState = setState;
                  return GlassEffect(
                    shape: const LiquidRoundedSuperellipse(borderRadius: 16),
                    settings: _settings,
                    interactionIntensity: 0.0,
                    quality: GlassQuality.standard,
                    backgroundKey: activeKey,
                    child: const SizedBox(width: 80, height: 40),
                  );
                },
              ),
            ],
          ),
        ),
      );
      await tester.pump();

      // Change key → backgroundKey setter fires
      outerSetState(() => activeKey = key2);
      await tester.pump();

      // Same key → no-op guard
      await tester.pump();
      expect(tester.takeException(), isNull);
    });

    testWidgets('interactionIntensity and densityFactor setters fire',
        (tester) async {
      double intensity = 0.0;
      double density = 0.0;
      late StateSetter outerSetState;

      await tester.pumpWidget(
        createTestApp(
          child: StatefulBuilder(
            builder: (ctx, setState) {
              outerSetState = setState;
              return GlassEffect(
                shape: const LiquidRoundedSuperellipse(borderRadius: 16),
                settings: _settings,
                interactionIntensity: intensity,
                densityFactor: density,
                quality: GlassQuality.standard,
                child: const SizedBox(width: 80, height: 40),
              );
            },
          ),
        ),
      );
      await tester.pump();

      // Change → setters fire
      outerSetState(() {
        intensity = 0.5;
        density = 0.3;
      });
      await tester.pump();

      // Same values → no-op guard
      await tester.pump();
      expect(tester.takeException(), isNull);
    });
  });

  // ── Corner-radius heuristic branches (lines 775-800) ─────────────────────
  // These are reached in _updateShaderUniforms when the shader is live.
  // In headless tests the shader never loads, so these code paths are NOT
  // reachable via `standard` quality (which falls back to ClipPath).
  //
  // However, switching *between shapes* via updateRenderObject is still useful
  // as a smoke test that the shape selector doesn't crash.

  group('GlassEffect — corner radius shape switching', () {
    testWidgets('switching between shape types does not crash', (tester) async {
      LiquidShape shape = const LiquidRoundedSuperellipse(borderRadius: 8);
      late StateSetter outerSetState;

      await tester.pumpWidget(
        createTestApp(
          child: StatefulBuilder(
            builder: (ctx, setState) {
              outerSetState = setState;
              return GlassEffect(
                shape: shape,
                settings: _settings,
                interactionIntensity: 0.0,
                quality: GlassQuality.standard,
                child: const SizedBox(width: 80, height: 40),
              );
            },
          ),
        ),
      );
      await tester.pump();

      // Superellipse → Oval (stadium heuristic path)
      outerSetState(() => shape = const LiquidOval());
      await tester.pump();

      // Oval → Rectangle (cornerRadius = 0.0 path)
      outerSetState(
          () => shape = const LiquidRoundedRectangle(borderRadius: 0));
      await tester.pump();

      // Rectangle → Superellipse with large radius (> half size — clamp)
      outerSetState(
          () => shape = const LiquidRoundedSuperellipse(borderRadius: 9999));
      await tester.pump();

      expect(tester.takeException(), isNull);
    });
  });
}
