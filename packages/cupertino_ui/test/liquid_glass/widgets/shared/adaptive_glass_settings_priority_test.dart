import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

import '../../shared/test_helpers.dart';

const _shape = LiquidRoundedSuperellipse(borderRadius: 16);

void main() {
  group('AdaptiveGlass settings priority with ancestor InheritedLiquidGlass',
      () {
    testWidgets(
        'explicit bodyMode: GlassBodyMode.clear overrides ancestor settings even when useOwnLayer is false',
        (tester) async {
      const ancestorSettings = LiquidGlassSettings(
        bodyMode: GlassBodyMode.adaptive,
        glassColor: Color(0x33FFFFFF),
        blur: 20,
      );

      const explicitClearSettings = LiquidGlassSettings(
        bodyMode: GlassBodyMode.clear,
        glassColor: Color(0x00000000),
        blur: 5,
      );

      await tester.pumpWidget(
        createTestApp(
          child: InheritedLiquidGlass(
            settings: ancestorSettings,
            child: AdaptiveGlass(
              shape: _shape,
              settings: explicitClearSettings,
              quality: GlassQuality.standard,
              useOwnLayer: false,
              child: const Text('clear_mode'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final lightweight = tester.widget<LightweightLiquidGlass>(
        find.byType(LightweightLiquidGlass),
      );

      // Explicit bodyMode MUST be preserved, not overwritten by ancestor's adaptive mode
      expect(lightweight.settings?.bodyMode, GlassBodyMode.clear);
      expect(lightweight.settings?.effectiveBlur, 5);
    });

    testWidgets(
        'explicit opaque tint (glassColor.a > 0) overrides ancestor settings even when useOwnLayer is false',
        (tester) async {
      const ancestorSettings = LiquidGlassSettings(
        glassColor: Color(0x22112233),
        bodyMode: GlassBodyMode.adaptive,
        blur: 30,
      );

      const explicitTintSettings = LiquidGlassSettings(
        glassColor: Color(0xFFFF5500), // a = 1.0 > 0
        bodyMode: GlassBodyMode.adaptive,
        blur: 8,
      );

      await tester.pumpWidget(
        createTestApp(
          child: InheritedLiquidGlass(
            settings: ancestorSettings,
            child: AdaptiveGlass(
              shape: _shape,
              settings: explicitTintSettings,
              quality: GlassQuality.standard,
              useOwnLayer: false,
              child: const Text('explicit_tint'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final lightweight = tester.widget<LightweightLiquidGlass>(
        find.byType(LightweightLiquidGlass),
      );

      // Explicit tint colour RGB values MUST be preserved
      final color = lightweight.settings?.effectiveGlassColor;
      expect(color?.r, closeTo(1.0, 0.05)); // Red channel from 0xFFFF5500
      expect(lightweight.settings?.effectiveBlur, 8);
    });

    testWidgets(
        'combined explicit bodyMode.clear and tintColor overrides ancestor settings',
        (tester) async {
      const ancestorSettings = LiquidGlassSettings(
        glassColor: Color(0x00000000),
        bodyMode: GlassBodyMode.adaptive,
        blur: 24,
      );

      const explicitTintAndClear = LiquidGlassSettings(
        glassColor: Color(0xFF34C759),
        bodyMode: GlassBodyMode.clear,
        blur: 0,
      );

      await tester.pumpWidget(
        createTestApp(
          child: InheritedLiquidGlass(
            settings: ancestorSettings,
            child: AdaptiveGlass(
              shape: _shape,
              settings: explicitTintAndClear,
              quality: GlassQuality.standard,
              useOwnLayer: false,
              child: const Text('tint_and_clear'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final lightweight = tester.widget<LightweightLiquidGlass>(
        find.byType(LightweightLiquidGlass),
      );

      expect(lightweight.settings?.bodyMode, GlassBodyMode.clear);
      expect(lightweight.settings?.effectiveGlassColor.g, closeTo(0.78, 0.05));
    });

    testWidgets(
        'default settings (bodyMode: adaptive, glassColor.a == 0, useOwnLayer: false) preserve batch-blur optimization',
        (tester) async {
      const ancestorSettings = LiquidGlassSettings(
        glassColor: Color(0x00000000),
        bodyMode: GlassBodyMode.adaptive,
        blur: 42,
        thickness: 25,
      );

      // Caller passes default settings without explicit bodyMode or tint
      const defaultSettings = LiquidGlassSettings(
        glassColor: Color(0x00000000),
        bodyMode: GlassBodyMode.adaptive,
        blur: 10,
        thickness: 10,
      );

      await tester.pumpWidget(
        createTestApp(
          child: InheritedLiquidGlass(
            settings: ancestorSettings,
            child: AdaptiveGlass(
              shape: _shape,
              settings: defaultSettings,
              quality: GlassQuality.standard,
              useOwnLayer: false,
              child: const Text('batch_blur'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final lightweight = tester.widget<LightweightLiquidGlass>(
        find.byType(LightweightLiquidGlass),
      );

      // Inherited ancestor's settings are used for the batch-blur optimization
      expect(lightweight.settings?.effectiveBlur, 42);
      expect(lightweight.settings?.effectiveThickness, 25);
    });

    testWidgets(
        'useOwnLayer: true always uses explicit settings regardless of bodyMode or glassColor',
        (tester) async {
      const ancestorSettings = LiquidGlassSettings(
        glassColor: Color(0x00000000),
        bodyMode: GlassBodyMode.adaptive,
        blur: 99,
      );

      const explicitSettings = LiquidGlassSettings(
        glassColor: Color(0x00000000),
        bodyMode: GlassBodyMode.adaptive,
        blur: 15,
      );

      await tester.pumpWidget(
        createTestApp(
          child: InheritedLiquidGlass(
            settings: ancestorSettings,
            child: AdaptiveGlass(
              shape: _shape,
              settings: explicitSettings,
              quality: GlassQuality.standard,
              useOwnLayer: true, // forces explicit settings
              child: const Text('own_layer'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final lightweight = tester.widget<LightweightLiquidGlass>(
        find.byType(LightweightLiquidGlass),
      );

      expect(lightweight.settings?.effectiveBlur, 15);
    });

    testWidgets(
        'standalone AdaptiveGlass without ancestor uses explicit settings directly',
        (tester) async {
      const explicitSettings = LiquidGlassSettings(
        glassColor: Color(0xFF007AFF),
        bodyMode: GlassBodyMode.clear,
        blur: 12,
      );

      await tester.pumpWidget(
        createTestApp(
          child: AdaptiveGlass(
            shape: _shape,
            settings: explicitSettings,
            quality: GlassQuality.standard,
            useOwnLayer: false,
            child: const Text('standalone'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final lightweight = tester.widget<LightweightLiquidGlass>(
        find.byType(LightweightLiquidGlass),
      );

      expect(lightweight.settings?.bodyMode, GlassBodyMode.clear);
      expect(lightweight.settings?.effectiveBlur, 12);
    });

    testWidgets('minimal quality tier applies explicit tintColor over ancestor',
        (tester) async {
      const ancestorSettings = LiquidGlassSettings(
        glassColor: Color(0x22111111),
        bodyMode: GlassBodyMode.adaptive,
      );

      const explicitTintSettings = LiquidGlassSettings(
        glassColor: Color(0xFFFFCC00),
        bodyMode: GlassBodyMode.clear,
      );

      await tester.pumpWidget(
        createTestApp(
          child: InheritedLiquidGlass(
            settings: ancestorSettings,
            child: AdaptiveGlass(
              shape: _shape,
              settings: explicitTintSettings,
              quality: GlassQuality.minimal,
              useOwnLayer: false,
              child: const Text('minimal_tint'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // In minimal tier, _FrostedFallback wraps DecoratedBox with the resolved glassColor
      final decoratedBoxes =
          tester.widgetList<DecoratedBox>(find.byType(DecoratedBox));
      final hasMatchingTint = decoratedBoxes.any((box) {
        final dec = box.decoration;
        final Color? color = dec is BoxDecoration
            ? dec.color
            : (dec is ShapeDecoration ? dec.color : null);
        if (color == null) return false;
        return (color.r - const Color(0xFFFFCC00).r).abs() < 0.02 &&
            (color.g - const Color(0xFFFFCC00).g).abs() < 0.02 &&
            (color.b - const Color(0xFFFFCC00).b).abs() < 0.02;
      });

      expect(hasMatchingTint, isTrue);
    });
  });
}
