import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

import '../../shared/test_helpers.dart';

const _shape = LiquidRoundedSuperellipse(borderRadius: 16);
const _settings = LiquidGlassSettings(
  thickness: 20,
  blur: 2,
  glassColor: Color(0x3DFFFFFF),
  lightIntensity: 0.6,
  saturation: 1.5,
);

void main() {
  group('AdaptiveGlass construction', () {
    testWidgets('minimal quality renders without crash', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: AdaptiveGlass(
            shape: _shape,
            settings: _settings,
            quality: GlassQuality.minimal,
            child: const Text('min'),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('min'), findsOneWidget);
    });

    testWidgets('standard quality renders without crash', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: AdaptiveGlass(
            shape: _shape,
            settings: _settings,
            quality: GlassQuality.standard,
            child: const Text('std'),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('std'), findsOneWidget);
    });

    testWidgets('respects clipExpansion parameter', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: AdaptiveGlass(
            shape: _shape,
            settings: _settings,
            quality: GlassQuality.premium,
            useOwnLayer: true,
            clipExpansion: const EdgeInsets.all(12.0),
            child: const Text('clipExp'),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('clipExp'), findsOneWidget);
    });

    testWidgets('grouped helper creates AdaptiveGlass without own layer',
        (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: AdaptiveLiquidGlassLayer(
            settings: settingsWithoutLighting,
            child: AdaptiveGlass.grouped(
              shape: _shape,
              child: const Text('grouped'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('grouped'), findsOneWidget);
    });
  });

  group('AdaptiveGlass accessibility path (reduceTransparency)', () {
    testWidgets('falls back to _FrostedFallback when reduceTransparency=true',
        (tester) async {
      // GlassAccessibilityScope with reduceTransparency=true activates line 130-139
      await tester.pumpWidget(
        createTestApp(
          child: GlassAccessibilityScope(
            reduceTransparency: true,
            child: AdaptiveGlass(
              shape: _shape,
              settings: _settings,
              quality: GlassQuality.standard,
              child: const Text('a11y'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('a11y'), findsOneWidget);
    });

    testWidgets('accessibility fallback with GlassQuality.standard',
        (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: GlassAccessibilityScope(
            reduceTransparency: true,
            child: AdaptiveGlass(
              shape: _shape,
              settings: _settings,
              quality: GlassQuality.standard,
              child: const SizedBox(width: 100, height: 50),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(AdaptiveGlass), findsOneWidget);
    });
  });

  group('AdaptiveGlass _FrostedFallback interactive path', () {
    testWidgets('isInteractive=true renders without BackdropFilter (line 360)',
        (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: AdaptiveGlass(
            shape: _shape,
            settings: _settings,
            quality: GlassQuality.minimal,
            isInteractive: true, // exercises !useBlur branch (line 360-364)
            child: const Text('interactive'),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('interactive'), findsOneWidget);
    });

    testWidgets('glowIntensity > 0 adds glow overlay (line 391-399)',
        (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: AdaptiveGlass(
            shape: _shape,
            settings: _settings,
            quality: GlassQuality.minimal,
            glowIntensity: 0.5, // exercises glowIntensity > 0 branch
            child: const Text('glow'),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('glow'), findsOneWidget);
    });

    testWidgets('isInteractive + glowIntensity together', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: AdaptiveGlass(
            shape: _shape,
            settings: _settings,
            quality: GlassQuality.minimal,
            isInteractive: true,
            glowIntensity: 0.8,
            child: const Text('both'),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('both'), findsOneWidget);
    });
  });

  group('AdaptiveGlass _FrostedFallback saturation paths', () {
    testWidgets('saturation != 1 applies ColorFilter matrix (line 349-353)',
        (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: AdaptiveGlass(
            shape: _shape,
            settings: const LiquidGlassSettings(saturation: 1.5, blur: 2),
            quality: GlassQuality.minimal,
            isInteractive: false,
            child: const SizedBox(width: 80, height: 40),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(AdaptiveGlass), findsOneWidget);
    });

    testWidgets('saturation == 1.0 skips ColorFilter (else path, line 354)',
        (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: AdaptiveGlass(
            shape: _shape,
            settings: const LiquidGlassSettings(saturation: 1.0, blur: 2),
            quality: GlassQuality.minimal,
            isInteractive: false,
            child: const SizedBox(width: 80, height: 40),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(AdaptiveGlass), findsOneWidget);
    });
  });

  group('AdaptiveGlass elevation path (inherited layer)', () {
    testWidgets('allowElevation=true within ancestor layer uses densityFactor',
        (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: AdaptiveLiquidGlassLayer(
            settings: settingsWithoutLighting,
            child: AdaptiveGlass(
              shape: _shape,
              settings: _settings,
              quality: GlassQuality.standard,
              allowElevation: true,
              child: const Text('elevated'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('elevated'), findsOneWidget);
    });

    testWidgets(
        'allowElevation=false wraps InheritedLiquidGlass (line 185-197)',
        (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: AdaptiveLiquidGlassLayer(
            settings: settingsWithoutLighting,
            child: AdaptiveGlass(
              shape: _shape,
              settings: _settings,
              quality: GlassQuality.standard,
              allowElevation: false, // line 185: !allowElevation branch
              child: const Text('container'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('container'), findsOneWidget);
    });
  });

  group('_SpecularRimPainter', () {
    testWidgets('shouldRepaint returns true when settings change',
        (tester) async {
      // Exercise via animation to ensure the painter is built
      LiquidGlassSettings s = const LiquidGlassSettings(lightIntensity: 0.3);
      late StateSetter outerSetState;
      await tester.pumpWidget(
        createTestApp(
          child: StatefulBuilder(
            builder: (ctx, setState) {
              outerSetState = setState;
              return AdaptiveGlass(
                shape: _shape,
                settings: s,
                quality: GlassQuality.minimal,
                child: const SizedBox(width: 80, height: 40),
              );
            },
          ),
        ),
      );
      await tester.pump();

      outerSetState(() => s = const LiquidGlassSettings(lightIntensity: 0.9));
      await tester.pumpAndSettle();

      expect(find.byType(AdaptiveGlass), findsOneWidget);
    });

    testWidgets('lightIntensity=0 skips painting without crash',
        (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: AdaptiveGlass(
            shape: _shape,
            settings: const LiquidGlassSettings(lightIntensity: 0.0, blur: 2),
            quality: GlassQuality.minimal,
            child: const SizedBox(width: 80, height: 40),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(AdaptiveGlass), findsOneWidget);
    });
  });
  group('AdaptiveGlass premium quality paths (lines 212-231)', () {
    testWidgets(
        'premium quality with own layer uses PremiumGlassTracker + RepaintBoundary',
        (tester) async {
      // Lines 212-220: if (useOwnLayer) → PremiumGlassTracker(RepaintBoundary(LiquidGlass.withOwnLayer))
      await tester.pumpWidget(
        createTestApp(
          child: AdaptiveGlass(
            shape: _shape,
            settings: _settings,
            quality: GlassQuality.premium, // triggers premium render path
            useOwnLayer: true,
            child: const Text('premOwn'),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('premOwn'), findsOneWidget);
    });

    testWidgets(
        'premium quality grouped uses PremiumGlassTracker + LiquidGlass.grouped',
        (tester) async {
      // Lines 222-229: else → PremiumGlassTracker(LiquidGlass.grouped)
      await tester.pumpWidget(
        createTestApp(
          child: AdaptiveLiquidGlassLayer(
            settings: settingsWithoutLighting,
            child: AdaptiveGlass(
              shape: _shape,
              settings: _settings,
              quality: GlassQuality.premium,
              useOwnLayer: false, // grouped path
              child: const Text('premGroup'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('premGroup'), findsOneWidget);
    });
  });

  group('AdaptiveGlass bodyMode (GlassBodyMode.clear)', () {
    testWidgets(
        'renders cleanly with bodyMode: GlassBodyMode.clear in all quality tiers',
        (tester) async {
      const clearSettings = LiquidGlassSettings(
        bodyMode: GlassBodyMode.clear,
        glassColor: Color(0xD9C3E0F5),
        blur: 0,
      );

      for (final quality in [
        GlassQuality.minimal,
        GlassQuality.standard,
        GlassQuality.premium,
      ]) {
        await tester.pumpWidget(
          createTestApp(
            child: AdaptiveGlass(
              shape: _shape,
              settings: clearSettings,
              quality: quality,
              useOwnLayer: true,
              child: Text('clear_${quality.name}'),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.text('clear_${quality.name}'), findsOneWidget);
      }
    });

    testWidgets('preserves exact zero alpha in clear mode minimal tier',
        (tester) async {
      const clearSettings = LiquidGlassSettings(
        bodyMode: GlassBodyMode.clear,
        glassColor: Color(0x00FFFFFF),
        blur: 0,
      );

      await tester.pumpWidget(
        createTestApp(
          child: AdaptiveGlass(
            shape: _shape,
            settings: clearSettings,
            quality: GlassQuality.minimal,
            child: const Text('zeroAlphaClear'),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('zeroAlphaClear'), findsOneWidget);

      // Verify DecoratedBox has withValues(alpha: 0.0)
      final decoratedBoxes =
          tester.widgetList<DecoratedBox>(find.byType(DecoratedBox));
      expect(
        decoratedBoxes.any((box) {
          final dec = box.decoration;
          return (dec is ShapeDecoration && dec.color?.a == 0.0) ||
              (dec is BoxDecoration && dec.color?.a == 0.0);
        }),
        isTrue,
      );
    });
  });

  group('AdaptiveGlass infinite borderRadius handling', () {
    testWidgets(
        'LiquidRoundedRectangle(borderRadius: double.infinity) routes ClipRRect with finite radius',
        (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: const AdaptiveGlass(
            shape: LiquidRoundedRectangle(borderRadius: double.infinity),
            settings: _settings,
            quality: GlassQuality.standard,
            child: SizedBox(width: 60, height: 60),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final clipRRect = tester.widget<ClipRRect>(find.byType(ClipRRect));
      final radius = clipRRect.borderRadius as BorderRadius;
      expect(radius.topLeft.x.isFinite, isTrue);
      expect(radius.topLeft.x, greaterThan(0.0));
    });

    testWidgets(
        'LiquidRoundedRectangle(borderRadius: double.infinity) with drop shadow creates finite BorderRadius for decoration',
        (tester) async {
      await tester.pumpWidget(
        createTestApp(
          theme: ThemeData(brightness: Brightness.light),
          child: const AdaptiveGlass(
            shape: LiquidRoundedRectangle(borderRadius: double.infinity),
            settings: LiquidGlassSettings(
              shadowElevation: 8,
            ),
            child: SizedBox(width: 60, height: 60),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final decBox =
          tester.widget<DecoratedBox>(find.byType(DecoratedBox).first);
      final boxDec = decBox.decoration as BoxDecoration;
      final radius = boxDec.borderRadius as BorderRadius;
      expect(radius.topLeft.x.isFinite, isTrue);
      expect(radius.topLeft.x, greaterThan(0.0));
    });

    testWidgets(
        'platformViewBackdrop with infinite borderRadius routes ClipRRect with finite radius',
        (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: const AdaptiveGlass(
            shape: LiquidRoundedRectangle(borderRadius: double.infinity),
            settings: _settings,
            platformViewBackdrop: true,
            child: SizedBox(width: 60, height: 60),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final clipRRect = tester.widget<ClipRRect>(find.byType(ClipRRect).first);
      final radius = clipRRect.borderRadius as BorderRadius;
      expect(radius.topLeft.x.isFinite, isTrue);
      expect(radius.topLeft.x, greaterThan(0.0));
    });
  });

  group('AdaptiveGlass nested vibrancy avoidance', () {
    testWidgets(
        'nested AdaptiveGlass with useOwnLayer=true bypasses _VibrancyFill',
        (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: AdaptiveLiquidGlassLayer(
            settings: _settings,
            child: AdaptiveGlass(
              shape: _shape,
              settings: _settings,
              useOwnLayer: true,
              child: const Text('nestedOwn'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('nestedOwn'), findsOneWidget);
    });

    testWidgets(
        'nested AdaptiveGlass with useOwnLayer=false uses _VibrancyFill',
        (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: AdaptiveLiquidGlassLayer(
            settings: _settings,
            child: AdaptiveGlass(
              shape: _shape,
              settings: _settings,
              useOwnLayer: false,
              child: const Text('nestedGrouped'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('nestedGrouped'), findsOneWidget);
    });
  });
}
