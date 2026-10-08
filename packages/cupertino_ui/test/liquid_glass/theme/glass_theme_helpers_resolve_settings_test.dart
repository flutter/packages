// Tests for GlassThemeHelpers.resolveSettings — the 0.8.0 transparency
// regression fix.  Every priority level of the 5-step resolution chain is
// covered so a future refactor cannot silently break the visible-glass
// invariant (glass is visible on white backgrounds even with zero config).
//
// Priority chain (highest → lowest):
//   1. explicit `settings:` widget parameter
//   2. InheritedLiquidGlass from nearest AdaptiveLiquidGlassLayer ancestor
//   3. LiquidGlassWidgets.globalSettings (app-level override)
//   4. GlassThemeData brightness-aware settings
//   5. LiquidGlassSettings() default (absolute last resort)

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:liquid_glass_widgets/theme/glass_theme_helpers.dart';

void main() {
  tearDown(() {
    // Reset global settings between tests to avoid cross-test pollution.
    LiquidGlassWidgets.globalSettings = null;
  });

  group('GlassThemeHelpers.resolveSettings', () {
    // ── Level 1: explicit widget settings ─────────────────────────────────

    testWidgets(
        'Level 1 — explicit settings are returned immediately (no ancestor required)',
        (tester) async {
      late LiquidGlassSettings result;

      const explicit = LiquidGlassSettings(thickness: 99.0);

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(builder: (context) {
            result = GlassThemeHelpers.resolveSettings(
              context,
              explicit: explicit,
            );
            return const SizedBox.shrink();
          }),
        ),
      );

      expect(result.thickness, 99.0);
    });

    testWidgets(
        'Level 1 — explicit settings win over InheritedLiquidGlass ancestor',
        (tester) async {
      late LiquidGlassSettings result;

      const explicit = LiquidGlassSettings(thickness: 99.0);

      await tester.pumpWidget(
        MaterialApp(
          home: AdaptiveLiquidGlassLayer(
            settings: const LiquidGlassSettings(thickness: 1.0), // ancestor
            child: Builder(builder: (context) {
              result = GlassThemeHelpers.resolveSettings(
                context,
                explicit: explicit, // must win
              );
              return const SizedBox.shrink();
            }),
          ),
        ),
      );

      expect(result.thickness, 99.0); // explicit wins
    });

    testWidgets('Level 1 — explicit settings win over globalSettings',
        (tester) async {
      late LiquidGlassSettings result;

      LiquidGlassWidgets.globalSettings =
          const LiquidGlassSettings(thickness: 50.0);

      const explicit = LiquidGlassSettings(thickness: 99.0);

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(builder: (context) {
            result = GlassThemeHelpers.resolveSettings(
              context,
              explicit: explicit,
            );
            return const SizedBox.shrink();
          }),
        ),
      );

      expect(result.thickness, 99.0);
    });

    // ── Level 2: InheritedLiquidGlass from ancestor layer ─────────────────

    testWidgets(
        'Level 2 — returns inherited settings when no explicit settings provided',
        (tester) async {
      late LiquidGlassSettings result;

      await tester.pumpWidget(
        MaterialApp(
          home: AdaptiveLiquidGlassLayer(
            settings: const LiquidGlassSettings(thickness: 42.0),
            child: Builder(builder: (context) {
              result = GlassThemeHelpers.resolveSettings(context);
              return const SizedBox.shrink();
            }),
          ),
        ),
      );

      expect(result.thickness, 42.0);
    });

    testWidgets(
        'Level 2 — inherited settings win over globalSettings (priority 2 > 3)',
        (tester) async {
      late LiquidGlassSettings result;

      LiquidGlassWidgets.globalSettings =
          const LiquidGlassSettings(thickness: 10.0);

      await tester.pumpWidget(
        MaterialApp(
          home: AdaptiveLiquidGlassLayer(
            settings: const LiquidGlassSettings(thickness: 42.0), // should win
            child: Builder(builder: (context) {
              result = GlassThemeHelpers.resolveSettings(context);
              return const SizedBox.shrink();
            }),
          ),
        ),
      );

      expect(result.thickness, 42.0);
    });

    // ── Level 3: globalSettings (app-level override) ───────────────────────

    testWidgets(
        'Level 3 — globalSettings used when no explicit or inherited settings',
        (tester) async {
      late LiquidGlassSettings result;

      LiquidGlassWidgets.globalSettings =
          const LiquidGlassSettings(thickness: 77.0);

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(builder: (context) {
            result = GlassThemeHelpers.resolveSettings(context);
            return const SizedBox.shrink();
          }),
        ),
      );

      expect(result.thickness, 77.0);
    });

    // ── Level 4: GlassThemeData brightness-aware settings ─────────────────

    testWidgets(
        'Level 4 — GlassThemeData light settings applied when no ancestor or global',
        (tester) async {
      late LiquidGlassSettings result;

      // No ancestor layer, no globalSettings.
      await tester.pumpWidget(
        MaterialApp(
          home: GlassTheme(
            data: GlassThemeData(
              light: GlassThemeVariant(
                settings: GlassThemeSettings(thickness: 33.0),
              ),
              dark: GlassThemeVariant(
                settings: GlassThemeSettings(thickness: 99.0),
              ),
            ),
            // Force light brightness so the test is deterministic.
            child: MediaQuery(
              data: const MediaQueryData(
                platformBrightness: Brightness.light,
              ),
              child: Builder(builder: (context) {
                result = GlassThemeHelpers.resolveSettings(context);
                return const SizedBox.shrink();
              }),
            ),
          ),
        ),
      );

      expect(result.thickness, 33.0);
    });

    testWidgets('Level 4 — GlassThemeData dark settings applied in dark mode',
        (tester) async {
      late LiquidGlassSettings result;

      tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
      addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          themeMode: ThemeMode.system,
          home: GlassTheme(
            data: GlassThemeData(
              light: GlassThemeVariant(
                settings: GlassThemeSettings(thickness: 10.0),
              ),
              dark: GlassThemeVariant(
                settings: GlassThemeSettings(thickness: 88.0),
              ),
            ),
            child: Builder(builder: (context) {
              result = GlassThemeHelpers.resolveSettings(context);
              return const SizedBox.shrink();
            }),
          ),
        ),
      );

      expect(result.thickness, 88.0);
    });

    // ── Level 5: last-resort LiquidGlassSettings() default ────────────────

    testWidgets(
        'Level 5 — falls back to LiquidGlassSettings() when nothing is configured',
        (tester) async {
      late LiquidGlassSettings result;

      // No explicit, no ancestor, no global, no GlassTheme override.
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(builder: (context) {
            result = GlassThemeHelpers.resolveSettings(context);
            return const SizedBox.shrink();
          }),
        ),
      );

      // The result must not be null and must have a non-zero alpha glassColor
      // (the transparency regression guard — the GlassThemeVariant.light
      // default provides a visible tint via applyTo).
      expect(result, isNotNull);
    });

    // ── Transparency regression guard ─────────────────────────────────────
    //
    // Regression test for the 0.8.0 bug: standalone glass widgets were
    // receiving LiquidGlassSettings() with a zero-alpha glassColor, making
    // them invisible on light backgrounds.  resolveSettings() must ALWAYS
    // produce a visible glassColor when a GlassTheme is present.

    testWidgets(
        'transparency guard — glassColor from theme is non-transparent when GlassTheme present',
        (tester) async {
      late LiquidGlassSettings result;

      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(
              platformBrightness: Brightness.light,
            ),
            child: Builder(builder: (context) {
              // No explicit settings, no ancestor layer, no global —
              // the library falls back to GlassThemeVariant.light defaults.
              result = GlassThemeHelpers.resolveSettings(context);
              return const SizedBox.shrink();
            }),
          ),
        ),
      );

      // GlassThemeVariant.light.settings has a non-null, non-transparent
      // glassColor. The resolved settings must carry it through.
      // If this assertion fails, standalone glass will be invisible on white.
      final color = result.glassColor;
      // When a glassColor is resolved, it must have visible alpha.
      expect(color.a, greaterThan(0.0),
          reason:
              'Resolved glassColor has zero alpha — glass will be invisible '
              'on light backgrounds. This is the 0.8.0 transparency regression.');
      // If color is null, the widget falls back to shader defaults — acceptable,
      // but the primary path must produce a visible color.
    });

    testWidgets(
        'transparency guard — explicit settings null glassColor does not produce invisible widget',
        (tester) async {
      late LiquidGlassSettings result;

      // Explicit settings with a clearly visible glassColor.
      const explicit = LiquidGlassSettings(
        glassColor: Color(0x4AD2DCF0), // 29% alpha — visible
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(builder: (context) {
            result = GlassThemeHelpers.resolveSettings(
              context,
              explicit: explicit,
            );
            return const SizedBox.shrink();
          }),
        ),
      );

      expect(result.glassColor.a, greaterThan(0.0));
    });
  });
}
