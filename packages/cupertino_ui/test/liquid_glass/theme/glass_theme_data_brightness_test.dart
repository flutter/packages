// Tests for the GlassThemeData.brightness explicit override field.
//
// Verifies:
//   - Constructor accepts brightness field
//   - GlassThemeData.simple() accepts brightness parameter
//   - variantFor() honours brightness field as highest priority
//   - glowColorsFor() uses same brightness as variantFor (consistent source)
//   - copyWith() correctly handles brightness (including clearing via null sentinel)
//   - equality / hashCode include brightness field
//   - brightness=null falls through to cascade (backward compat)

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

// ──────────────────────────────────────────────────────────────────────────
// Helper
// ──────────────────────────────────────────────────────────────────────────

/// Wraps [child] in a Material app with [deviceBrightness], a GlassTheme
/// using [data], and captures the result of [capture] at the leaf.
Future<T> pumpCapture<T>(
  WidgetTester tester, {
  required GlassThemeData data,
  required Brightness deviceBrightness,
  required T Function(BuildContext ctx, GlassThemeData data) capture,
}) async {
  T? result;
  await tester.pumpWidget(
    MediaQuery(
      data: MediaQueryData(platformBrightness: deviceBrightness),
      child: MaterialApp(
        home: GlassTheme(
          data: data,
          child: Builder(builder: (ctx) {
            result = capture(ctx, data);
            return const SizedBox.shrink();
          }),
        ),
      ),
    ),
  );
  return result as T;
}

void main() {
  // ──────────────────────────────────────────────────────────────────────────
  // GlassThemeData constructor
  // ──────────────────────────────────────────────────────────────────────────

  group('GlassThemeData.brightness — constructor', () {
    test('defaults to null (no override)', () {
      const data = GlassThemeData();
      expect(data.brightness, isNull);
    });

    test('can be set to Brightness.light', () {
      const data = GlassThemeData(brightness: Brightness.light);
      expect(data.brightness, Brightness.light);
    });

    test('can be set to Brightness.dark', () {
      const data = GlassThemeData(brightness: Brightness.dark);
      expect(data.brightness, Brightness.dark);
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  // GlassThemeData.simple constructor
  // ──────────────────────────────────────────────────────────────────────────

  group('GlassThemeData.simple — brightness parameter', () {
    test('defaults to null', () {
      final data = GlassThemeData.simple();
      expect(data.brightness, isNull);
    });

    test('propagates Brightness.light', () {
      final data = GlassThemeData.simple(brightness: Brightness.light);
      expect(data.brightness, Brightness.light);
    });

    test('propagates Brightness.dark', () {
      final data = GlassThemeData.simple(brightness: Brightness.dark);
      expect(data.brightness, Brightness.dark);
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  // variantFor — honours brightness override
  // ──────────────────────────────────────────────────────────────────────────

  group('GlassThemeData.variantFor — brightness override', () {
    testWidgets(
        'returns light variant when brightness=light and device is dark',
        (tester) async {
      const data = GlassThemeData(brightness: Brightness.light);
      final variant = await pumpCapture<GlassThemeVariant>(
        tester,
        data: data,
        deviceBrightness: Brightness.dark,
        capture: (ctx, d) => d.variantFor(ctx),
      );
      expect(variant, GlassThemeVariant.light,
          reason: 'brightness=light forces light variant even on dark device');
    });

    testWidgets('returns dark variant when brightness=dark and device is light',
        (tester) async {
      const data = GlassThemeData(brightness: Brightness.dark);
      final variant = await pumpCapture<GlassThemeVariant>(
        tester,
        data: data,
        deviceBrightness: Brightness.light,
        capture: (ctx, d) => d.variantFor(ctx),
      );
      expect(variant, GlassThemeVariant.dark,
          reason: 'brightness=dark forces dark variant even on light device');
    });

    testWidgets(
        'without override, variantFor follows the cascade (device light → light)',
        (tester) async {
      const data = GlassThemeData(); // brightness: null
      final variant = await pumpCapture<GlassThemeVariant>(
        tester,
        data: data,
        deviceBrightness: Brightness.light,
        capture: (ctx, d) => d.variantFor(ctx),
      );
      expect(variant, GlassThemeVariant.light,
          reason: 'No override → cascade → device light → light variant');
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  // glowColorsFor — consistent with variantFor brightness source
  // ──────────────────────────────────────────────────────────────────────────

  group('GlassThemeData.glowColorsFor — consistent brightness source', () {
    testWidgets(
        'uses light-mode glow primary when brightness=light, device is dark',
        (tester) async {
      const data = GlassThemeData(brightness: Brightness.light);
      final colors = await pumpCapture<GlassGlowColors>(
        tester,
        data: data,
        deviceBrightness: Brightness.dark,
        capture: (ctx, d) => d.glowColorsFor(ctx),
      );
      // Light mode: 0x3D = 24% opacity (higher than dark mode's 0x2A = 16%)
      expect(colors.primary, const Color(0x3DFFFFFF),
          reason:
              'Light-mode adaptive primary (0x3DFFFFFF) used when brightness=light');
    });

    testWidgets(
        'uses dark-mode glow primary when brightness=dark, device is light',
        (tester) async {
      const data = GlassThemeData(brightness: Brightness.dark);
      final colors = await pumpCapture<GlassGlowColors>(
        tester,
        data: data,
        deviceBrightness: Brightness.light,
        capture: (ctx, d) => d.glowColorsFor(ctx),
      );
      // Dark mode: 0x2A = 16% opacity
      expect(colors.primary, const Color(0x2AFFFFFF),
          reason:
              'Dark-mode adaptive primary (0x2AFFFFFF) used when brightness=dark');
    });

    testWidgets(
        'glowColorsFor and variantFor use the SAME brightness — no split-brain',
        (tester) async {
      // This is the architectural correctness test: glowColorsFor must never
      // use a different brightness source than variantFor. If they disagree,
      // the glow palette and glass variant are for different modes — broken.
      const data = GlassThemeData(brightness: Brightness.light);

      GlassThemeVariant? variant;
      GlassGlowColors? colors;

      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(platformBrightness: Brightness.dark),
          child: MaterialApp(
            home: GlassTheme(
              data: data,
              child: Builder(builder: (ctx) {
                variant = data.variantFor(ctx);
                colors = data.glowColorsFor(ctx);
                return const SizedBox.shrink();
              }),
            ),
          ),
        ),
      );

      // variantFor should pick the light variant
      expect(variant, GlassThemeVariant.light);
      // glowColorsFor should inject the light-mode primary (0x3D)
      expect(colors!.primary, const Color(0x3DFFFFFF),
          reason:
              'glowColorsFor must use same brightness source as variantFor');
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  // copyWith — brightness field
  // ──────────────────────────────────────────────────────────────────────────

  group('GlassThemeData.copyWith — brightness', () {
    test('copyWith preserves brightness when not specified', () {
      const original = GlassThemeData(brightness: Brightness.light);
      final copy = original.copyWith();
      expect(copy.brightness, Brightness.light,
          reason: 'Unspecified copyWith field is preserved (sentinel pattern)');
    });

    test('copyWith sets brightness to a new value', () {
      const original = GlassThemeData(brightness: Brightness.light);
      final copy = original.copyWith(brightness: Brightness.dark);
      expect(copy.brightness, Brightness.dark);
    });

    test('copyWith can CLEAR brightness to null using sentinel', () {
      const original = GlassThemeData(brightness: Brightness.light);
      // Explicitly pass null to clear the override
      final copy = original.copyWith(brightness: null);
      expect(copy.brightness, isNull,
          reason:
              'Passing null to copyWith must clear the brightness override');
    });

    test('copyWith from null brightness, setting to light', () {
      const original = GlassThemeData(); // brightness: null
      final copy = original.copyWith(brightness: Brightness.light);
      expect(copy.brightness, Brightness.light);
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  // equality & hashCode
  // ──────────────────────────────────────────────────────────────────────────

  group('GlassThemeData — equality and hashCode include brightness', () {
    test('equal objects with same brightness', () {
      const a = GlassThemeData(brightness: Brightness.light);
      const b = GlassThemeData(brightness: Brightness.light);
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('unequal when brightness differs', () {
      const a = GlassThemeData(brightness: Brightness.light);
      const b = GlassThemeData(brightness: Brightness.dark);
      expect(a, isNot(equals(b)));
    });

    test('unequal when one has brightness and other does not', () {
      const a = GlassThemeData(brightness: Brightness.light);
      const b = GlassThemeData(); // null
      expect(a, isNot(equals(b)));
    });

    test('equal when both brightness are null', () {
      const a = GlassThemeData();
      const b = GlassThemeData();
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  // Backward compatibility — null brightness still uses cascade
  // ──────────────────────────────────────────────────────────────────────────

  group('GlassThemeData.brightness=null — backward compatibility', () {
    testWidgets('existing code with no brightness field still works correctly',
        (tester) async {
      // Simulates any existing app that does not set the brightness field.
      // With device in light mode and no explicit theme, it should resolve to
      // light — same as before this feature was added.
      const data = GlassThemeData();
      final variant = await pumpCapture<GlassThemeVariant>(
        tester,
        data: data,
        deviceBrightness: Brightness.light,
        capture: (ctx, d) => d.variantFor(ctx),
      );
      expect(variant, GlassThemeVariant.light,
          reason: 'Null brightness falls through cascade — no regression');
    });

    testWidgets(
        'existing dark-device apps still get dark variant with null brightness',
        (tester) async {
      // The pumpCapture helper uses plain MaterialApp with no explicit ThemeMode.
      // With device dark and ThemeMode.system, the Material theme resolves dark.
      // We verify the correct variant is selected by checking which field matches.
      const data = GlassThemeData(); // brightness: null
      GlassThemeVariant? variant;
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(platformBrightness: Brightness.dark),
          child: MaterialApp(
            theme: ThemeData.light(),
            darkTheme: ThemeData.dark(),
            themeMode: ThemeMode.system, // follows device
            home: GlassTheme(
              data: data,
              child: Builder(builder: (ctx) {
                variant = data.variantFor(ctx);
                return const SizedBox.shrink();
              }),
            ),
          ),
        ),
      );
      // variantFor returned the dark variant — verify by identity not equality.
      expect(variant == GlassThemeVariant.dark, isTrue,
          reason:
              'Null brightness falls through to system dark — no regression');
    });
  });
}
