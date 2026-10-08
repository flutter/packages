import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:liquid_glass_widgets/src/engine/glass_glow.dart';

/// Extended unit tests for [GlassThemeData], [GlassThemeVariant],
/// [GlassGlowColors] and [GlassThemeHelpers] — covering fields and paths
/// not yet exercised by glass_theme_test.dart.
void main() {
  // ──────────────────────────────────────────────────────────────────────────
  // GlassGlowColors
  // ──────────────────────────────────────────────────────────────────────────

  group('GlassGlowColors', () {
    group('copyWith — each colour field', () {
      const original = GlassGlowColors(
        primary: Colors.red,
        secondary: Colors.blue,
        success: Colors.green,
        warning: Colors.orange,
        danger: Colors.pink,
        info: Colors.cyan,
      );

      test('copyWith primary', () {
        final copy = original.copyWith(primary: Colors.purple);
        expect(copy.primary, Colors.purple);
        expect(copy.secondary, Colors.blue);
      });

      test('copyWith secondary', () {
        final copy = original.copyWith(secondary: Colors.yellow);
        expect(copy.secondary, Colors.yellow);
        expect(copy.primary, Colors.red);
      });

      test('copyWith success', () {
        final copy = original.copyWith(success: Colors.teal);
        expect(copy.success, Colors.teal);
        expect(copy.danger, Colors.pink);
      });

      test('copyWith warning', () {
        final copy = original.copyWith(warning: Colors.amber);
        expect(copy.warning, Colors.amber);
        expect(copy.info, Colors.cyan);
      });

      test('copyWith danger', () {
        final copy = original.copyWith(danger: Colors.red);
        expect(copy.danger, Colors.red);
        expect(copy.success, Colors.green);
      });

      test('copyWith info', () {
        final copy = original.copyWith(info: Colors.indigo);
        expect(copy.info, Colors.indigo);
        expect(copy.primary, Colors.red);
      });

      test('copy with no changes equals original', () {
        expect(original.copyWith(), equals(original));
        expect(original.copyWith().hashCode, equals(original.hashCode));
      });

      test('copyWith multiple fields', () {
        final copy =
            original.copyWith(primary: Colors.white, danger: Colors.black);
        expect(copy.primary, Colors.white);
        expect(copy.danger, Colors.black);
        expect(copy.secondary, Colors.blue);
      });
    });

    group('equality and hashCode', () {
      test('same fields are equal', () {
        const a = GlassGlowColors(primary: Colors.red);
        const b = GlassGlowColors(primary: Colors.red);
        expect(a, equals(b));
        expect(a.hashCode, equals(b.hashCode));
      });

      test('different primary are not equal', () {
        const a = GlassGlowColors(primary: Colors.red);
        const b = GlassGlowColors(primary: Colors.blue);
        expect(a, isNot(equals(b)));
      });

      test('all-null instances are equal', () {
        const a = GlassGlowColors();
        const b = GlassGlowColors();
        expect(a, equals(b));
      });
    });

    group('fallback constant', () {
      test('primary is null (runtime-injected by glowColorsFor)', () {
        expect(GlassGlowColors.fallback.primary, isNull);
      });

      test('secondary is iOS purple', () {
        expect(GlassGlowColors.fallback.secondary, const Color(0xFF5856D6));
      });

      test('success is iOS green', () {
        expect(GlassGlowColors.fallback.success, const Color(0xFF34C759));
      });

      test('warning is iOS orange', () {
        expect(GlassGlowColors.fallback.warning, const Color(0xFFFF9500));
      });

      test('danger is iOS red', () {
        expect(GlassGlowColors.fallback.danger, const Color(0xFFFF3B30));
      });

      test('info is iOS light blue', () {
        expect(GlassGlowColors.fallback.info, const Color(0xFF5AC8FA));
      });
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  // GlassThemeVariant static presets
  // ──────────────────────────────────────────────────────────────────────────

  group('GlassThemeVariant static presets', () {
    test('light quality is null (widget defaults respected)', () {
      expect(GlassThemeVariant.light.quality, isNull);
    });

    test('dark quality is null (widget defaults respected)', () {
      expect(GlassThemeVariant.dark.quality, isNull);
    });

    test('minimal quality is GlassQuality.minimal', () {
      expect(GlassThemeVariant.minimal.quality, GlassQuality.minimal);
    });

    test('minimal has non-null settings', () {
      expect(GlassThemeVariant.minimal.settings, isNotNull);
    });

    test('light settings has non-null thickness', () {
      expect(GlassThemeVariant.light.settings?.thickness, isNotNull);
    });

    test('dark settings has non-null thickness', () {
      expect(GlassThemeVariant.dark.settings?.thickness, isNotNull);
    });

    test(
        'light thickness is >= dark thickness (light glass needs more contrast)',
        () {
      final lightThickness = GlassThemeVariant.light.settings?.thickness ?? 0;
      final darkThickness = GlassThemeVariant.dark.settings?.thickness ?? 0;
      expect(lightThickness, greaterThanOrEqualTo(darkThickness));
    });

    test('all presets have non-null glowColors', () {
      expect(GlassThemeVariant.light.glowColors, isNotNull);
      expect(GlassThemeVariant.dark.glowColors, isNotNull);
      expect(GlassThemeVariant.minimal.glowColors, isNotNull);
    });
  });

  group('GlassThemeVariant copyWith', () {
    const base = GlassThemeVariant(
      settings: GlassThemeSettings(thickness: 30.0),
      quality: GlassQuality.standard,
      glowColors: GlassGlowColors(primary: Colors.blue),
    );

    test('copy with no args equals original', () {
      expect(base.copyWith(), equals(base));
    });

    test('copyWith quality', () {
      final copy = base.copyWith(quality: GlassQuality.premium);
      expect(copy.quality, GlassQuality.premium);
      expect(copy.settings, base.settings);
    });

    test('copyWith settings', () {
      final copy = base.copyWith(
        settings: const GlassThemeSettings(blur: 12.0),
      );
      expect(copy.settings?.blur, 12.0);
      expect(copy.quality, base.quality);
    });

    test('copyWith glowColors', () {
      final copy = base.copyWith(
        glowColors: const GlassGlowColors(primary: Colors.red),
      );
      expect(copy.glowColors?.primary, Colors.red);
    });
  });

  group('GlassThemeVariant equality and hashCode', () {
    test('identical variants are equal', () {
      const a = GlassThemeVariant(quality: GlassQuality.standard);
      const b = GlassThemeVariant(quality: GlassQuality.standard);
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('different quality are not equal', () {
      const a = GlassThemeVariant(quality: GlassQuality.standard);
      const b = GlassThemeVariant(quality: GlassQuality.premium);
      expect(a, isNot(equals(b)));
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  // GlassThemeData
  // ──────────────────────────────────────────────────────────────────────────

  group('GlassThemeData', () {
    group('fallback()', () {
      test('returns non-null instance', () {
        expect(GlassThemeData.fallback(), isNotNull);
      });

      test('light variant equals GlassThemeVariant.light', () {
        expect(GlassThemeData.fallback().light, GlassThemeVariant.light);
      });

      test('dark variant equals GlassThemeVariant.dark', () {
        expect(GlassThemeData.fallback().dark, GlassThemeVariant.dark);
      });

      test('light and dark quality are null in fallback', () {
        final f = GlassThemeData.fallback();
        expect(f.light.quality, isNull);
        expect(f.dark.quality, isNull);
      });
    });

    group('copyWith', () {
      const original = GlassThemeData(
        light: GlassThemeVariant(quality: GlassQuality.standard),
        dark: GlassThemeVariant(quality: GlassQuality.premium),
      );

      test('copy with no args equals original', () {
        expect(original.copyWith(), equals(original));
      });

      test('copyWith light', () {
        final copy = original.copyWith(
          light: const GlassThemeVariant(quality: GlassQuality.minimal),
        );
        expect(copy.light.quality, GlassQuality.minimal);
        expect(copy.dark.quality, GlassQuality.premium);
      });

      test('copyWith dark', () {
        final copy = original.copyWith(
          dark: const GlassThemeVariant(quality: GlassQuality.standard),
        );
        expect(copy.dark.quality, GlassQuality.standard);
        expect(copy.light.quality, GlassQuality.standard);
      });
    });

    group('equality and hashCode', () {
      test('identical instances are equal', () {
        const a = GlassThemeData(
          light: GlassThemeVariant(quality: GlassQuality.standard),
        );
        const b = GlassThemeData(
          light: GlassThemeVariant(quality: GlassQuality.standard),
        );
        expect(a, equals(b));
        expect(a.hashCode, equals(b.hashCode));
      });

      test('different light quality are not equal', () {
        const a = GlassThemeData(
          light: GlassThemeVariant(quality: GlassQuality.standard),
        );
        const b = GlassThemeData(
          light: GlassThemeVariant(quality: GlassQuality.premium),
        );
        expect(a, isNot(equals(b)));
      });
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  // GlassThemeData.glowColorsFor — adaptive primary injection
  // ──────────────────────────────────────────────────────────────────────────

  group('GlassThemeData.glowColorsFor adaptive primary', () {
    testWidgets('injects bright primary in light mode (primary was null)',
        (tester) async {
      const data = GlassThemeData(
        light: GlassThemeVariant(
          glowColors: GlassGlowColors(), // primary is null
        ),
      );

      Color? injected;
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(platformBrightness: Brightness.light),
          child: MaterialApp(
            home: GlassTheme(
              data: data,
              child: Builder(builder: (context) {
                injected = data.glowColorsFor(context).primary;
                return const SizedBox.shrink();
              }),
            ),
          ),
        ),
      );

      // Light mode → 0x3DFFFFFF (24% white)
      expect(injected, isNotNull);
      expect(injected, const Color(0x3DFFFFFF));
    });

    testWidgets('injects dimmer primary in dark mode (primary was null)',
        (tester) async {
      const data = GlassThemeData(
        dark: GlassThemeVariant(
          glowColors: GlassGlowColors(), // primary is null
        ),
      );

      Color? injected;
      tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
      addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          themeMode: ThemeMode.system,
          home: GlassTheme(
            data: data,
            child: Builder(builder: (context) {
              injected = data.glowColorsFor(context).primary;
              return const SizedBox.shrink();
            }),
          ),
        ),
      );

      // Dark mode → 0x2AFFFFFF (16% white)
      expect(injected, isNotNull);
      expect(injected, const Color(0x2AFFFFFF));
    });

    testWidgets('does NOT inject when caller already set primary',
        (tester) async {
      const explicitPrimary = Colors.purple;
      const data = GlassThemeData(
        light: GlassThemeVariant(
          glowColors: GlassGlowColors(primary: explicitPrimary),
        ),
      );

      Color? resolved;
      await tester.pumpWidget(
        MaterialApp(
          home: GlassTheme(
            data: data,
            child: Builder(builder: (context) {
              resolved = data.glowColorsFor(context).primary;
              return const SizedBox.shrink();
            }),
          ),
        ),
      );

      expect(resolved, explicitPrimary);
    });

    testWidgets('secondary color is preserved during injection',
        (tester) async {
      const data = GlassThemeData(
        light: GlassThemeVariant(
          glowColors: GlassGlowColors(
            // primary is null so injection kicks in
            secondary: Colors.orange,
          ),
        ),
      );

      Color? secondary;
      await tester.pumpWidget(
        MaterialApp(
          home: GlassTheme(
            data: data,
            child: Builder(builder: (context) {
              secondary = data.glowColorsFor(context).secondary;
              return const SizedBox.shrink();
            }),
          ),
        ),
      );

      expect(secondary, Colors.orange);
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  // GlassThemeHelpers.of — fallback when no ancestor
  // ──────────────────────────────────────────────────────────────────────────

  group('GlassThemeHelpers / GlassThemeData.of', () {
    testWidgets('returns fallback when no GlassTheme in tree', (tester) async {
      GlassThemeData? captured;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(builder: (context) {
            captured = GlassThemeData.of(context);
            return const SizedBox.shrink();
          }),
        ),
      );

      expect(captured, isNotNull);
      expect(captured, equals(GlassThemeData.fallback()));
    });

    testWidgets('returns provided theme when GlassTheme is present',
        (tester) async {
      const custom = GlassThemeData(
        light: GlassThemeVariant(quality: GlassQuality.minimal),
      );

      GlassThemeData? captured;
      await tester.pumpWidget(
        MaterialApp(
          home: GlassTheme(
            data: custom,
            child: Builder(builder: (context) {
              captured = GlassThemeData.of(context);
              return const SizedBox.shrink();
            }),
          ),
        ),
      );

      expect(captured, equals(custom));
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  // variantFor / settingsFor / qualityFor
  // ──────────────────────────────────────────────────────────────────────────

  group('variantFor / settingsFor / qualityFor', () {
    testWidgets('variantFor picks light in light mode', (tester) async {
      const data = GlassThemeData(
        light: GlassThemeVariant(quality: GlassQuality.standard),
        dark: GlassThemeVariant(quality: GlassQuality.premium),
      );

      GlassThemeVariant? variant;
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(platformBrightness: Brightness.light),
          child: MaterialApp(
            home: Builder(builder: (context) {
              variant = data.variantFor(context);
              return const SizedBox.shrink();
            }),
          ),
        ),
      );

      expect(variant?.quality, GlassQuality.standard);
    });

    testWidgets('variantFor picks dark in dark mode', (tester) async {
      const data = GlassThemeData(
        light: GlassThemeVariant(quality: GlassQuality.standard),
        dark: GlassThemeVariant(quality: GlassQuality.premium),
      );

      GlassThemeVariant? variant;
      tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
      addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          themeMode: ThemeMode.system,
          home: Builder(builder: (context) {
            variant = data.variantFor(context);
            return const SizedBox.shrink();
          }),
        ),
      );

      expect(variant?.quality, GlassQuality.premium);
    });

    testWidgets('settingsFor returns the variant settings', (tester) async {
      const data = GlassThemeData(
        light: GlassThemeVariant(
          settings: GlassThemeSettings(thickness: 42.0),
        ),
      );

      GlassThemeSettings? settings;
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(platformBrightness: Brightness.light),
          child: MaterialApp(
            home: Builder(builder: (context) {
              settings = data.settingsFor(context);
              return const SizedBox.shrink();
            }),
          ),
        ),
      );

      expect(settings?.thickness, 42.0);
    });

    testWidgets('qualityFor returns the variant quality', (tester) async {
      const data = GlassThemeData(
        light: GlassThemeVariant(quality: GlassQuality.minimal),
      );

      GlassQuality? quality;
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(platformBrightness: Brightness.light),
          child: MaterialApp(
            home: Builder(builder: (context) {
              quality = data.qualityFor(context);
              return const SizedBox.shrink();
            }),
          ),
        ),
      );

      expect(quality, GlassQuality.minimal);
    });

    testWidgets('settingsFor returns null when variant has no settings',
        (tester) async {
      const data = GlassThemeData(
        light: GlassThemeVariant(), // no settings
      );

      GlassThemeSettings? settings;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(builder: (context) {
            settings = data.settingsFor(context);
            return const SizedBox.shrink();
          }),
        ),
      );

      expect(settings, isNull);
    });
  });

  // ────────────────────────────────────────────────────────────────────────────
  // GlassGlowColors — glowBlurRadius / glowSpreadRadius / glowOpacity
  // ────────────────────────────────────────────────────────────────────────────

  group('GlassGlowColors appearance fields', () {
    // ── Construction defaults ──────────────────────────────────────────────

    group('construction defaults', () {
      test('glowBlurRadius defaults to 4.0 (liquid-glass soft edge)', () {
        expect(const GlassGlowColors().glowBlurRadius, 4.0);
      });

      test('glowSpreadRadius defaults to 0', () {
        expect(const GlassGlowColors().glowSpreadRadius, 0);
      });

      test('glowOpacity defaults to 1', () {
        expect(const GlassGlowColors().glowOpacity, 1);
      });

      test('explicit values are stored', () {
        const c = GlassGlowColors(
          glowBlurRadius: 8,
          glowSpreadRadius: 0.15,
          glowOpacity: 0.6,
        );
        expect(c.glowBlurRadius, 8);
        expect(c.glowSpreadRadius, 0.15);
        expect(c.glowOpacity, 0.6);
      });
    });

    // ── copyWith ──────────────────────────────────────────────────────────

    group('copyWith appearance fields', () {
      const original = GlassGlowColors(
        primary: Colors.red,
        glowBlurRadius: 4,
        glowSpreadRadius: 0.1,
        glowOpacity: 0.8,
      );

      test('copyWith glowBlurRadius', () {
        final copy = original.copyWith(glowBlurRadius: 12);
        expect(copy.glowBlurRadius, 12);
        // unchanged
        expect(copy.glowSpreadRadius, 0.1);
        expect(copy.glowOpacity, 0.8);
        expect(copy.primary, Colors.red);
      });

      test('copyWith glowSpreadRadius', () {
        final copy = original.copyWith(glowSpreadRadius: 0.25);
        expect(copy.glowSpreadRadius, 0.25);
        expect(copy.glowBlurRadius, 4);
        expect(copy.glowOpacity, 0.8);
      });

      test('copyWith glowOpacity', () {
        final copy = original.copyWith(glowOpacity: 0.4);
        expect(copy.glowOpacity, 0.4);
        expect(copy.glowBlurRadius, 4);
        expect(copy.glowSpreadRadius, 0.1);
      });

      test('copyWith all three at once', () {
        final copy = original.copyWith(
          glowBlurRadius: 16,
          glowSpreadRadius: 0.3,
          glowOpacity: 0.5,
        );
        expect(copy.glowBlurRadius, 16);
        expect(copy.glowSpreadRadius, 0.3);
        expect(copy.glowOpacity, 0.5);
      });

      test('copyWith with no args preserves appearance fields', () {
        final copy = original.copyWith();
        expect(copy.glowBlurRadius, original.glowBlurRadius);
        expect(copy.glowSpreadRadius, original.glowSpreadRadius);
        expect(copy.glowOpacity, original.glowOpacity);
      });
    });

    // ── Equality and hashCode participation ───────────────────────────────

    group('equality / hashCode participation', () {
      test('same appearance fields are equal', () {
        const a = GlassGlowColors(glowBlurRadius: 6, glowOpacity: 0.7);
        const b = GlassGlowColors(glowBlurRadius: 6, glowOpacity: 0.7);
        expect(a, equals(b));
        expect(a.hashCode, equals(b.hashCode));
      });

      test('different glowBlurRadius breaks equality', () {
        const a = GlassGlowColors(glowBlurRadius: 6);
        const b = GlassGlowColors(glowBlurRadius: 8);
        expect(a, isNot(equals(b)));
      });

      test('different glowSpreadRadius breaks equality', () {
        const a = GlassGlowColors(glowSpreadRadius: 0.1);
        const b = GlassGlowColors(glowSpreadRadius: 0.2);
        expect(a, isNot(equals(b)));
      });

      test('different glowOpacity breaks equality', () {
        const a = GlassGlowColors(glowOpacity: 0.8);
        const b = GlassGlowColors(glowOpacity: 0.5);
        expect(a, isNot(equals(b)));
      });

      test('two identical full instances share hashCode', () {
        const a = GlassGlowColors(
          primary: Colors.blue,
          glowBlurRadius: 10,
          glowSpreadRadius: 0.2,
          glowOpacity: 0.9,
        );
        const b = GlassGlowColors(
          primary: Colors.blue,
          glowBlurRadius: 10,
          glowSpreadRadius: 0.2,
          glowOpacity: 0.9,
        );
        expect(a, equals(b));
        expect(a.hashCode, b.hashCode);
      });
    });

    // ── Fallback constant ─────────────────────────────────────────────────

    group('fallback constant appearance field defaults', () {
      test('fallback.glowBlurRadius is 4.0', () {
        expect(GlassGlowColors.fallback.glowBlurRadius, 4.0);
      });

      test('fallback.glowSpreadRadius is 0', () {
        expect(GlassGlowColors.fallback.glowSpreadRadius, 0);
      });

      test('fallback.glowOpacity is 1', () {
        expect(GlassGlowColors.fallback.glowOpacity, 1);
      });
    });

    // ── glowColorsFor preserves appearance fields through injection ────────

    group('glowColorsFor preserves appearance fields', () {
      testWidgets(
          'appearance fields survive adaptive-primary injection (light mode)',
          (tester) async {
        const data = GlassThemeData(
          light: GlassThemeVariant(
            glowColors: GlassGlowColors(
              // primary null → injection will run
              glowBlurRadius: 10,
              glowSpreadRadius: 0.2,
              glowOpacity: 0.75,
            ),
          ),
        );

        GlassGlowColors? resolved;
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(platformBrightness: Brightness.light),
            child: MaterialApp(
              home: GlassTheme(
                data: data,
                child: Builder(builder: (context) {
                  resolved = data.glowColorsFor(context);
                  return const SizedBox.shrink();
                }),
              ),
            ),
          ),
        );

        expect(resolved, isNotNull);
        expect(resolved!.primary, const Color(0x3DFFFFFF)); // injected
        expect(resolved!.glowBlurRadius, 10);
        expect(resolved!.glowSpreadRadius, 0.2);
        expect(resolved!.glowOpacity, 0.75);
      });

      testWidgets(
          'appearance fields survive adaptive-primary injection (dark mode)',
          (tester) async {
        const data = GlassThemeData(
          dark: GlassThemeVariant(
            glowColors: GlassGlowColors(
              glowBlurRadius: 8,
              glowSpreadRadius: 0.15,
              glowOpacity: 0.6,
            ),
          ),
        );

        GlassGlowColors? resolved;
        tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
        addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData.light(),
            darkTheme: ThemeData.dark(),
            themeMode: ThemeMode.system,
            home: GlassTheme(
              data: data,
              child: Builder(builder: (context) {
                resolved = data.glowColorsFor(context);
                return const SizedBox.shrink();
              }),
            ),
          ),
        );

        expect(resolved!.primary, const Color(0x2AFFFFFF)); // dark injection
        expect(resolved!.glowBlurRadius, 8);
        expect(resolved!.glowSpreadRadius, 0.15);
        expect(resolved!.glowOpacity, 0.6);
      });

      testWidgets('explicit primary path also preserves appearance fields',
          (tester) async {
        const data = GlassThemeData(
          light: GlassThemeVariant(
            glowColors: GlassGlowColors(
              primary: Colors.purple, // explicit → no injection
              glowBlurRadius: 6,
              glowOpacity: 0.9,
            ),
          ),
        );

        GlassGlowColors? resolved;
        await tester.pumpWidget(
          MaterialApp(
            home: GlassTheme(
              data: data,
              child: Builder(builder: (context) {
                resolved = data.glowColorsFor(context);
                return const SizedBox.shrink();
              }),
            ),
          ),
        );

        // Early-return path (primary non-null) preserves all fields
        expect(resolved!.primary, Colors.purple);
        expect(resolved!.glowBlurRadius, 6);
        expect(resolved!.glowOpacity, 0.9);
      });
    });

    // ── GlassGlow widget accepts the new props ────────────────────────────

    group('GlassGlow widget accepts appearance fields', () {
      testWidgets('renders without error when all three fields are non-default',
          (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: GlassGlow(
                glowColor: Colors.white24,
                glowRadius: 1.0,
                glowBlurRadius: 8,
                glowSpreadRadius: 0.2,
                glowOpacity: 0.7,
                child: const SizedBox(width: 100, height: 100),
              ),
            ),
          ),
        );
        expect(tester.takeException(), isNull);
      });

      testWidgets('glowOpacity=0 suppresses glow without errors',
          (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: GlassGlow(
                glowColor: Colors.white24,
                glowRadius: 1.0,
                glowOpacity: 0,
                child: const SizedBox(width: 80, height: 80),
              ),
            ),
          ),
        );
        expect(tester.takeException(), isNull);
      });

      testWidgets('glowOpacity clamps above 1 without errors', (tester) async {
        // Values > 1.0 passed to glowOpacity should be clamped safely.
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: GlassGlow(
                glowColor: Colors.white24,
                glowRadius: 1.0,
                glowOpacity: 2.0, // intentionally out-of-range
                child: const SizedBox(width: 80, height: 80),
              ),
            ),
          ),
        );
        expect(tester.takeException(), isNull);
      });

      testWidgets('GlassGlowLayerState.updateTouch accepts the new fields',
          (tester) async {
        GlassGlowLayerState? state;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: GlassGlowLayer(
                child: Builder(builder: (innerCtx) {
                  state = GlassGlowLayer.maybeOf(innerCtx);
                  return const SizedBox(width: 200, height: 200);
                }),
              ),
            ),
          ),
        );

        expect(state, isNotNull);

        // Should not throw with the new optional named params.
        state!.updateTouch(
          const Offset(50, 50),
          radius: 1.0,
          color: Colors.white24,
          blurRadius: 8,
          spreadRadius: 0.2,
          opacity: 0.7,
        );
        await tester.pump();
        expect(state!.dragging, isTrue);

        state!.removeTouch();
        await tester.pump();
        expect(state!.dragging, isFalse);
      });
    });
  });
}
