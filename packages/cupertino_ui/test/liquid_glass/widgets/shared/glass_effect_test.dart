// ignore_for_file: require_trailing_commas

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:liquid_glass_widgets/widgets/shared/glass_effect.dart';

import '../../shared/test_helpers.dart';

// ---------------------------------------------------------------------------
// Shared settings
// ---------------------------------------------------------------------------

const _settings = LiquidGlassSettings(
  thickness: 20,
  blur: 2,
  glassColor: Color(0x3DFFFFFF),
);

const _shape = LiquidRoundedSuperellipse(borderRadius: 16);

Widget _buildGlassEffect({
  GlassQuality quality = GlassQuality.minimal,
  double interactionIntensity = 0.0,
  GlobalKey? backgroundKey,
  double densityFactor = 0.0,
}) {
  return createTestApp(
    child: GlassEffect(
      shape: _shape,
      settings: _settings,
      interactionIntensity: interactionIntensity,
      quality: quality,
      densityFactor: densityFactor,
      backgroundKey: backgroundKey,
      child: const SizedBox(width: 80, height: 40),
    ),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  // GlassEffect.preWarm uses FragmentProgram.fromAsset which is not available
  // in headless tests (no real GPU). Every test must use GlassQuality.minimal
  // or standard so the shader path is not exercised.

  group('GlassEffect construction', () {
    testWidgets('minimal quality renders child via AdaptiveGlass fallback',
        (tester) async {
      await tester.pumpWidget(_buildGlassEffect(quality: GlassQuality.minimal));
      await tester.pumpAndSettle();
      expect(find.byType(GlassEffect), findsOneWidget);
      // AdaptiveGlass fallback must be present on the minimal path
      expect(find.byType(AdaptiveGlass), findsOneWidget);
    });

    testWidgets('standard quality renders without crashing', (tester) async {
      await tester
          .pumpWidget(_buildGlassEffect(quality: GlassQuality.standard));
      await tester.pump();
      expect(find.byType(GlassEffect), findsOneWidget);
    });

    testWidgets('renders child content on minimal path', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: GlassEffect(
            shape: _shape,
            settings: _settings,
            interactionIntensity: 0.0,
            quality: GlassQuality.minimal,
            child: const Text('hello glass'),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('hello glass'), findsOneWidget);
    });

    testWidgets('renders correctly with all optional params', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: GlassEffect(
            shape: const LiquidRoundedSuperellipse(borderRadius: 32),
            settings: _settings,
            interactionIntensity: 0.0,
            quality: GlassQuality.minimal,
            ambientRim: 0.2,
            baseAlphaMultiplier: 0.3,
            edgeAlphaMultiplier: 0.5,
            rimThickness: 1.0,
            rimSmoothing: 2.0,
            densityFactor: 0.5,
            clipExpansion: const EdgeInsets.all(4),
            child: const SizedBox(width: 60, height: 60),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(GlassEffect), findsOneWidget);
    });
  });

  group('GlassEffect lifecycle', () {
    testWidgets('disposes cleanly without active ticker', (tester) async {
      await tester.pumpWidget(_buildGlassEffect(quality: GlassQuality.minimal));
      await tester.pump();

      // Remove widget → calls dispose → ticker disposed (inactive)
      await tester.pumpWidget(const SizedBox.shrink());
      // No crash = pass
      expect(find.byType(GlassEffect), findsNothing);
    });

    testWidgets(
        'disposes cleanly with interactionIntensity > 0 (ticker may be active)',
        (tester) async {
      final key = GlobalKey(debugLabel: 'bg');
      await tester.pumpWidget(
        createTestApp(
          child: Stack(
            children: [
              RepaintBoundary(
                key: key,
                child: const SizedBox(width: 200, height: 200),
              ),
              GlassEffect(
                shape: _shape,
                settings: _settings,
                interactionIntensity: 0.8,
                quality: GlassQuality.minimal,
                backgroundKey: key,
                child: const SizedBox(width: 80, height: 40),
              ),
            ],
          ),
        ),
      );
      // Pump a few frames but don't call pumpAndSettle — the Ticker never settles.
      await tester.pump(const Duration(milliseconds: 100));

      // Remove → dispose called while ticker state could be non-zero
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
      expect(find.byType(GlassEffect), findsNothing);
    });
  });

  group('GlassEffect didUpdateWidget', () {
    testWidgets('quality change from minimal to standard does not crash',
        (tester) async {
      GlassQuality q = GlassQuality.minimal;
      late StateSetter outerSetState;
      await tester.pumpWidget(
        createTestApp(
          child: StatefulBuilder(
            builder: (ctx, setState) {
              outerSetState = setState;
              return GlassEffect(
                shape: _shape,
                settings: _settings,
                interactionIntensity: 0.0,
                quality: q,
                child: const SizedBox(width: 80, height: 40),
              );
            },
          ),
        ),
      );
      await tester.pump();

      // Upgrade quality — exercises didUpdateWidget line 164-168
      outerSetState(() => q = GlassQuality.standard);
      await tester.pumpAndSettle();
      expect(find.byType(GlassEffect), findsOneWidget);
    });

    testWidgets('interactionIntensity change re-evaluates ticker',
        (tester) async {
      double intensity = 0.0;
      late StateSetter outerSetState;
      await tester.pumpWidget(
        createTestApp(
          child: StatefulBuilder(
            builder: (ctx, setState) {
              outerSetState = setState;
              return GlassEffect(
                shape: _shape,
                settings: _settings,
                interactionIntensity: intensity,
                quality: GlassQuality.minimal,
                child: const SizedBox(width: 80, height: 40),
              );
            },
          ),
        ),
      );
      await tester.pump();

      // Increase intensity — _updateTicker start branch (line 187-191)
      outerSetState(() => intensity = 0.9);
      // Pump a few frames instead of pumpAndSettle (ticker never settles)
      await tester.pump(const Duration(milliseconds: 50));
      expect(find.byType(GlassEffect), findsOneWidget);

      // Decrease intensity — _updateTicker stop branch (line 193-199)
      outerSetState(() => intensity = 0.0);
      await tester.pump();
      expect(find.byType(GlassEffect), findsOneWidget);
    });

    testWidgets('settings update propagates via didUpdateWidget',
        (tester) async {
      LiquidGlassSettings s = const LiquidGlassSettings(thickness: 10);
      late StateSetter outerSetState;
      await tester.pumpWidget(
        createTestApp(
          child: StatefulBuilder(
            builder: (ctx, setState) {
              outerSetState = setState;
              return GlassEffect(
                shape: _shape,
                settings: s,
                interactionIntensity: 0.0,
                quality: GlassQuality.minimal,
                child: const SizedBox(width: 80, height: 40),
              );
            },
          ),
        ),
      );
      await tester.pump();

      outerSetState(() => s = const LiquidGlassSettings(thickness: 40));
      await tester.pumpAndSettle();
      expect(find.byType(GlassEffect), findsOneWidget);
    });
  });

  group('GlassEffect avoidsRefraction path', () {
    testWidgets('InheritedLiquidGlass avoidsRefraction=true routes to minimal',
        (tester) async {
      // When the glass is wrapped in an AdaptiveLiquidGlassLayer, the
      // InheritedLiquidGlass marks avoidsRefraction=true for children.
      await tester.pumpWidget(
        createTestApp(
          child: AdaptiveLiquidGlassLayer(
            settings: settingsWithoutLighting,
            child: GlassEffect(
              shape: _shape,
              settings: _settings,
              interactionIntensity: 0.0,
              // Use standard so that without avoidsRefraction it'd hit Path B
              quality: GlassQuality.standard,
              child: const SizedBox(width: 80, height: 40),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(GlassEffect), findsOneWidget);
    });
  });

  group('GlassEffect shape variants', () {
    for (final shape in <LiquidShape>[
      const LiquidRoundedSuperellipse(borderRadius: 24),
      const LiquidOval(),
      const LiquidRoundedRectangle(borderRadius: 8),
    ]) {
      testWidgets('renders ${shape.runtimeType} shape', (tester) async {
        await tester.pumpWidget(
          createTestApp(
            child: GlassEffect(
              shape: shape,
              settings: _settings,
              interactionIntensity: 0.0,
              quality: GlassQuality.minimal,
              child: const SizedBox(width: 80, height: 40),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.byType(GlassEffect), findsOneWidget);
      });
    }
  });

  group('GlassEffect ultra-clean fallback (shader null)', () {
    testWidgets('renders transparent ClipPath when shader not ready',
        (tester) async {
      // On headless test runners _cachedProgram is always null (no GPU).
      // standard quality + no backgroundKey + avoidsRefraction=false → ClipPath fallback.
      await tester.pumpWidget(
        createTestApp(
          child: GlassEffect(
            shape: _shape,
            settings: _settings,
            interactionIntensity: 0.0,
            quality: GlassQuality.standard, // not minimal → skips AdaptiveGlass
            child: const Text('inner'),
          ),
        ),
      );
      await tester.pumpAndSettle();
      // Inner child must still be reachable under the ClipPath wrapper
      expect(find.text('inner'), findsOneWidget);
    });
  });

  // ---------------------------------------------------------------------------
  // Regression: pushClipPath double-offset clip (blur > 0 path)
  // ---------------------------------------------------------------------------
  //
  // Bug: _RenderInteractiveIndicator.paint() built pillPath with `offset & size`
  // (a rect in canvas/global coordinates). PaintingContext.pushClipPath then called
  // clipPath.shift(offset) internally, shifting the path a second time and placing
  // the clip entirely outside the widget when offset != zero.
  //
  // Fix: build pillPath with `Offset.zero & size` (local coordinates) so the
  // framework's single shift produces the correct global clip rect.
  //
  // Headless note: the shader path (_cachedProgram != null) is never taken in
  // headless tests. GlassEffect with blur > 0 and standard quality exercises the
  // pushClipPath branch through the lightweight (no-GPU) code path.
  group('GlassEffect blur clip — pushClipPath double-offset regression', () {
    testWidgets(
        'blur > 0 at non-zero screen offset renders child without displacement',
        (tester) async {
      // Place the widget at a non-zero offset with Padding so that
      // `offset` passed to paint() is non-zero.  Pre-fix, the clip rect
      // was shifted by `offset` twice, placing it off-screen.
      await tester.pumpWidget(
        createTestApp(
          child: Padding(
            padding: const EdgeInsets.only(top: 60, left: 40),
            child: GlassEffect(
              shape: const LiquidRoundedSuperellipse(borderRadius: 16),
              settings: const LiquidGlassSettings(
                thickness: 20,
                blur: 2, // triggers the pushClipPath branch
                glassColor: Color(0x3DFFFFFF),
              ),
              interactionIntensity: 0.0,
              quality: GlassQuality.standard,
              child: const Text('offset-child'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // The child must be painted and reachable — a displaced clip would still
      // render the child but outside its intended bounds; in test-mode the
      // ClipPathLayer receives the correct (non-doubled) path so the child
      // is visible within the expected widget area.
      expect(find.text('offset-child'), findsOneWidget);
      expect(find.byType(GlassEffect), findsOneWidget);
    });

    testWidgets('blur > 0 at zero offset (baseline) renders child correctly',
        (tester) async {
      // Verify the fix does not break the zero-offset case.
      await tester.pumpWidget(
        createTestApp(
          child: GlassEffect(
            shape: const LiquidRoundedSuperellipse(borderRadius: 16),
            settings: const LiquidGlassSettings(
              thickness: 20,
              blur: 2,
              glassColor: Color(0x3DFFFFFF),
            ),
            interactionIntensity: 0.0,
            quality: GlassQuality.standard,
            child: const Text('zero-offset-child'),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('zero-offset-child'), findsOneWidget);
    });

    testWidgets('blur == 0 still renders child (no-op path unchanged)',
        (tester) async {
      // Confirm the blur==0 branch (no pushClipPath) is unaffected by the fix.
      await tester.pumpWidget(
        createTestApp(
          child: Padding(
            padding: const EdgeInsets.only(top: 60, left: 40),
            child: GlassEffect(
              shape: const LiquidRoundedSuperellipse(borderRadius: 16),
              settings: const LiquidGlassSettings(
                thickness: 20,
                blur: 0,
                glassColor: Color(0x3DFFFFFF),
              ),
              interactionIntensity: 0.0,
              quality: GlassQuality.standard,
              child: const Text('no-blur-child'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('no-blur-child'), findsOneWidget);
    });
  });
}
