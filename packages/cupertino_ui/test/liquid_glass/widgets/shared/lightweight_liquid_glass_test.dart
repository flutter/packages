import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

import '../../shared/test_helpers.dart';

void main() {
  // Always reset shader state before each test so we get consistent
  // code paths regardless of test ordering.
  setUp(LightweightLiquidGlass.resetForTesting);

  group('LightweightLiquidGlass constructors', () {
    testWidgets('main constructor renders with explicit settings',
        (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: LightweightLiquidGlass(
            shape: const LiquidRoundedSuperellipse(borderRadius: 16),
            settings: const LiquidGlassSettings(thickness: 20),
            child: const SizedBox(width: 100, height: 50),
          ),
        ),
      );
      expect(find.byType(LightweightLiquidGlass), findsOneWidget);
    });

    testWidgets('renders cleanly with bodyMode: GlassBodyMode.clear',
        (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: LightweightLiquidGlass(
            shape: const LiquidRoundedSuperellipse(borderRadius: 16),
            settings: const LiquidGlassSettings(
              bodyMode: GlassBodyMode.clear,
              blur: 0,
              glassColor: Color(0xD9C3E0F5),
            ),
            child: const Text('clear body mode'),
          ),
        ),
      );
      expect(find.byType(LightweightLiquidGlass), findsOneWidget);
      expect(find.text('clear body mode'), findsOneWidget);
    });

    testWidgets('inLayer constructor inherits settings from ancestor',
        (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: AdaptiveLiquidGlassLayer(
            settings: settingsWithoutLighting,
            child: LightweightLiquidGlass.inLayer(
              shape: const LiquidRoundedSuperellipse(borderRadius: 12),
              child: const SizedBox(width: 80, height: 40),
            ),
          ),
        ),
      );
      expect(find.byType(LightweightLiquidGlass), findsOneWidget);
    });

    testWidgets('inLayer renders child content', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: AdaptiveLiquidGlassLayer(
            settings: settingsWithoutLighting,
            child: LightweightLiquidGlass.inLayer(
              shape: const LiquidRoundedSuperellipse(borderRadius: 8),
              child: const Text('inside glass'),
            ),
          ),
        ),
      );
      expect(find.text('inside glass'), findsOneWidget);
    });
  });

  group('LightweightLiquidGlass resetForTesting', () {
    test('resetForTesting clears cached state', () {
      // Call twice — should not throw (idempotent).
      expect(LightweightLiquidGlass.resetForTesting, returnsNormally);
      expect(LightweightLiquidGlass.resetForTesting, returnsNormally);
    });

    testWidgets('widget rebuilds cleanly after reset', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: LightweightLiquidGlass(
            shape: const LiquidRoundedSuperellipse(borderRadius: 16),
            child: const SizedBox(width: 60, height: 60),
          ),
        ),
      );

      LightweightLiquidGlass.resetForTesting();

      // Re-pump — should not crash.
      await tester.pump();
      expect(find.byType(LightweightLiquidGlass), findsOneWidget);
    });
  });

  group('LightweightLiquidGlass shape variants', () {
    testWidgets('renders with LiquidOval shape', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: LightweightLiquidGlass(
            shape: const LiquidOval(),
            child: const SizedBox(width: 80, height: 80),
          ),
        ),
      );
      expect(find.byType(LightweightLiquidGlass), findsOneWidget);
    });

    testWidgets('renders with LiquidRoundedRectangle shape', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: LightweightLiquidGlass(
            shape: const LiquidRoundedRectangle(borderRadius: 8),
            child: const SizedBox(width: 100, height: 50),
          ),
        ),
      );
      expect(find.byType(LightweightLiquidGlass), findsOneWidget);
    });

    testWidgets(
        'renders with LiquidRoundedRectangle(borderRadius: double.infinity) without collapsing ClipRRect to 0.0',
        (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: LightweightLiquidGlass(
            shape: const LiquidRoundedRectangle(borderRadius: double.infinity),
            child: const SizedBox(width: 100, height: 50),
          ),
        ),
      );
      expect(find.byType(LightweightLiquidGlass), findsOneWidget);
      final clipRRect = tester.widget<ClipRRect>(find.byType(ClipRRect));
      final radius = clipRRect.borderRadius as BorderRadius;
      expect(radius.topLeft.x.isFinite, isTrue);
      expect(radius.topLeft.x, greaterThan(0.0));
    });
  });

  group('LightweightLiquidGlass platform brightness paths', () {
    testWidgets('renders correctly in dark platform brightness',
        (tester) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(
            platformBrightness: Brightness.dark,
          ),
          child: createTestApp(
            child: LightweightLiquidGlass(
              shape: const LiquidRoundedSuperellipse(borderRadius: 16),
              child: const SizedBox(width: 100, height: 50),
            ),
          ),
        ),
      );
      expect(find.byType(LightweightLiquidGlass), findsOneWidget);
    });

    testWidgets('renders correctly in light platform brightness',
        (tester) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(
            platformBrightness: Brightness.light,
          ),
          child: createTestApp(
            child: LightweightLiquidGlass(
              shape: const LiquidRoundedSuperellipse(borderRadius: 16),
              child: const SizedBox(width: 100, height: 50),
            ),
          ),
        ),
      );
      expect(find.byType(LightweightLiquidGlass), findsOneWidget);
    });
  });

  group('LightweightLiquidGlass render object setters (via widget update)', () {
    testWidgets('glowIntensity update triggers rebuild', (tester) async {
      double glow = 0.0;
      await tester.pumpWidget(
        createTestApp(
          child: StatefulBuilder(
            builder: (context, setState) => Column(
              children: [
                LightweightLiquidGlass(
                  shape: const LiquidRoundedSuperellipse(borderRadius: 16),
                  glowIntensity: glow,
                  child: const SizedBox(width: 80, height: 40),
                ),
                GestureDetector(
                  onTap: () => setState(() => glow = 0.8),
                  child: const Text('bump'),
                ),
              ],
            ),
          ),
        ),
      );

      await tester.tap(find.text('bump'));
      await tester.pump();
      expect(find.byType(LightweightLiquidGlass), findsOneWidget);
    });

    testWidgets('densityFactor update triggers rebuild', (tester) async {
      double density = 0.0;
      await tester.pumpWidget(
        createTestApp(
          child: StatefulBuilder(
            builder: (context, setState) => Column(
              children: [
                LightweightLiquidGlass(
                  shape: const LiquidRoundedSuperellipse(borderRadius: 16),
                  densityFactor: density,
                  child: const SizedBox(width: 80, height: 40),
                ),
                GestureDetector(
                  onTap: () => setState(() => density = 0.5),
                  child: const Text('bump'),
                ),
              ],
            ),
          ),
        ),
      );

      await tester.tap(find.text('bump'));
      await tester.pump();
      expect(find.byType(LightweightLiquidGlass), findsOneWidget);
    });

    testWidgets('indicatorWeight update triggers rebuild', (tester) async {
      double weight = 0.0;
      await tester.pumpWidget(
        createTestApp(
          child: StatefulBuilder(
            builder: (context, setState) => Column(
              children: [
                LightweightLiquidGlass(
                  shape: const LiquidRoundedSuperellipse(borderRadius: 16),
                  indicatorWeight: weight,
                  child: const SizedBox(width: 80, height: 40),
                ),
                GestureDetector(
                  onTap: () => setState(() => weight = 1.0),
                  child: const Text('bump'),
                ),
              ],
            ),
          ),
        ),
      );

      await tester.tap(find.text('bump'));
      await tester.pump();
      expect(find.byType(LightweightLiquidGlass), findsOneWidget);
    });

    testWidgets('settings update triggers rebuild', (tester) async {
      LiquidGlassSettings settings = const LiquidGlassSettings(thickness: 10);
      await tester.pumpWidget(
        createTestApp(
          child: StatefulBuilder(
            builder: (context, setState) => Column(
              children: [
                LightweightLiquidGlass(
                  shape: const LiquidRoundedSuperellipse(borderRadius: 16),
                  settings: settings,
                  child: const SizedBox(width: 80, height: 40),
                ),
                GestureDetector(
                  onTap: () => setState(() =>
                      settings = const LiquidGlassSettings(thickness: 30)),
                  child: const Text('bump'),
                ),
              ],
            ),
          ),
        ),
      );

      await tester.tap(find.text('bump'));
      await tester.pump();
      expect(find.byType(LightweightLiquidGlass), findsOneWidget);
    });

    testWidgets('shape update triggers rebuild', (tester) async {
      LiquidShape shape = const LiquidRoundedSuperellipse(borderRadius: 8);
      await tester.pumpWidget(
        createTestApp(
          child: StatefulBuilder(
            builder: (context, setState) => Column(
              children: [
                LightweightLiquidGlass(
                  shape: shape,
                  child: const SizedBox(width: 80, height: 40),
                ),
                GestureDetector(
                  onTap: () => setState(() => shape =
                      const LiquidRoundedSuperellipse(borderRadius: 24)),
                  child: const Text('bump'),
                ),
              ],
            ),
          ),
        ),
      );

      await tester.tap(find.text('bump'));
      await tester.pump();
      expect(find.byType(LightweightLiquidGlass), findsOneWidget);
    });

    testWidgets(
        'skipBlur update triggers rebuild via ancestor InheritedLiquidGlass',
        (tester) async {
      // InheritedLiquidGlass with isBlurProvidedByAncestor=true triggers skipBlur path
      await tester.pumpWidget(
        createTestApp(
          child: AdaptiveLiquidGlassLayer(
            settings: settingsWithoutLighting,
            child: LightweightLiquidGlass.inLayer(
              shape: const LiquidRoundedSuperellipse(borderRadius: 16),
              child: const SizedBox(width: 100, height: 50),
            ),
          ),
        ),
      );
      expect(find.byType(LightweightLiquidGlass), findsOneWidget);
    });
  });

  group('LightweightLiquidGlass fallback path (shader null)', () {
    testWidgets('renders fallback container when shader cache is cleared',
        (tester) async {
      // After resetForTesting, _sharedShader is null → fallback ClipPath path executes.
      LightweightLiquidGlass.resetForTesting();

      await tester.pumpWidget(
        createTestApp(
          child: LightweightLiquidGlass(
            shape: const LiquidRoundedSuperellipse(borderRadius: 16),
            child: const Text('fallback'),
          ),
        ),
      );

      // Child must still be visible (fallback wraps it in Container + GlassGlowLayer)
      expect(find.text('fallback'), findsOneWidget);
    });
  });
}
