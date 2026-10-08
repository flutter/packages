// Integration tests for GlassTheme.brightnessOf — the single package-wide
// brightness authority.
//
// Tests verify:
//   L1: GlassThemeData.brightness explicit override (highest priority)
//   L2: CupertinoThemeData.brightness explicit pin
//   L3: Material ThemeMode (ThemeMode.light / ThemeMode.dark / ThemeMode.system)
//   L4: MediaQuery.platformBrightnessOf fallback
//   Priority order (L1 > L2 > L3 > L4)
//   The critical mismatch scenario: device dark, app light → shadow visible

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

void main() {
  // ──────────────────────────────────────────────────────────────────────────
  // GlassTheme.brightnessOf — Level 1: GlassThemeData.brightness override
  // ──────────────────────────────────────────────────────────────────────────

  group('GlassTheme.brightnessOf — Level 1: GlassThemeData.brightness', () {
    testWidgets(
        'returns light when GlassThemeData.brightness=light, device is dark',
        (tester) async {
      Brightness? captured;
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(platformBrightness: Brightness.dark),
          child: MaterialApp(
            theme: ThemeData.dark(),
            themeMode: ThemeMode.dark,
            home: GlassTheme(
              data: const GlassThemeData(brightness: Brightness.light),
              child: Builder(builder: (ctx) {
                captured = GlassTheme.brightnessOf(ctx);
                return const SizedBox.shrink();
              }),
            ),
          ),
        ),
      );
      expect(captured, Brightness.light,
          reason:
              'GlassThemeData.brightness=light is Level 1 — wins over everything');
    });

    testWidgets(
        'returns dark when GlassThemeData.brightness=dark, device is light',
        (tester) async {
      Brightness? captured;
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(platformBrightness: Brightness.light),
          child: MaterialApp(
            theme: ThemeData.light(),
            themeMode: ThemeMode.light,
            home: GlassTheme(
              data: const GlassThemeData(brightness: Brightness.dark),
              child: Builder(builder: (ctx) {
                captured = GlassTheme.brightnessOf(ctx);
                return const SizedBox.shrink();
              }),
            ),
          ),
        ),
      );
      expect(captured, Brightness.dark,
          reason: 'GlassThemeData.brightness=dark forces dark subtree');
    });

    testWidgets(
        'nested GlassTheme with brightness=light overrides parent brightness=dark',
        (tester) async {
      Brightness? outerCaptured;
      Brightness? innerCaptured;
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(platformBrightness: Brightness.dark),
          child: MaterialApp(
            home: GlassTheme(
              data: const GlassThemeData(brightness: Brightness.dark),
              child: Column(
                children: [
                  Builder(builder: (ctx) {
                    outerCaptured = GlassTheme.brightnessOf(ctx);
                    return const SizedBox.shrink();
                  }),
                  GlassTheme(
                    data: const GlassThemeData(brightness: Brightness.light),
                    child: Builder(builder: (ctx) {
                      innerCaptured = GlassTheme.brightnessOf(ctx);
                      return const SizedBox.shrink();
                    }),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      expect(outerCaptured, Brightness.dark, reason: 'Outer theme is dark');
      expect(innerCaptured, Brightness.light,
          reason: 'Inner GlassTheme override wins');
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  // GlassTheme.brightnessOf — Level 2 (Cupertino) and Level 3 (Material)
  // ──────────────────────────────────────────────────────────────────────────

  group(
      'GlassTheme.brightnessOf — Level 2/3 when GlassThemeData.brightness is null',
      () {
    testWidgets(
        'falls through to CupertinoTheme pin when no glass override (light)',
        (tester) async {
      Brightness? captured;
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(platformBrightness: Brightness.dark),
          child: CupertinoApp(
            theme: const CupertinoThemeData(brightness: Brightness.light),
            home: GlassTheme(
              data: const GlassThemeData(), // brightness: null
              child: Builder(builder: (ctx) {
                captured = GlassTheme.brightnessOf(ctx);
                return const SizedBox.shrink();
              }),
            ),
          ),
        ),
      );
      expect(captured, Brightness.light,
          reason: 'Cupertino explicit pin (Level 2) wins over dark device');
    });

    testWidgets(
        'falls through to Material ThemeMode when no glass or Cupertino override',
        (tester) async {
      Brightness? captured;
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(platformBrightness: Brightness.dark),
          child: MaterialApp(
            theme: ThemeData.light(),
            darkTheme: ThemeData.dark(),
            themeMode: ThemeMode.light, // app is light
            home: GlassTheme(
              data: const GlassThemeData(), // brightness: null
              child: Builder(builder: (ctx) {
                captured = GlassTheme.brightnessOf(ctx);
                return const SizedBox.shrink();
              }),
            ),
          ),
        ),
      );
      expect(captured, Brightness.light,
          reason:
              'ThemeMode.light (Level 3) wins over dark device — the primary bug fix');
    });

    testWidgets(
        'falls through to system brightness when no override and no Material',
        (tester) async {
      Brightness? captured;
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(platformBrightness: Brightness.dark),
          child: CupertinoApp(
            // No explicit brightness — null
            home: GlassTheme(
              data: const GlassThemeData(),
              child: Builder(builder: (ctx) {
                captured = GlassTheme.brightnessOf(ctx);
                return const SizedBox.shrink();
              }),
            ),
          ),
        ),
      );
      expect(captured, Brightness.dark,
          reason: 'No override → system fallback (Level 4)');
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  // No GlassTheme ancestor — GlassTheme.maybeOf returns null
  // ──────────────────────────────────────────────────────────────────────────

  group('GlassTheme.brightnessOf — no GlassTheme ancestor', () {
    testWidgets('falls through cascade gracefully without GlassTheme',
        (tester) async {
      Brightness? captured;
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(platformBrightness: Brightness.dark),
          child: MaterialApp(
            theme: ThemeData.light(),
            themeMode: ThemeMode.light,
            home: Builder(builder: (ctx) {
              // No GlassTheme ancestor — brightnessOf still resolves correctly
              captured = GlassTheme.brightnessOf(ctx);
              return const SizedBox.shrink();
            }),
          ),
        ),
      );
      expect(captured, Brightness.light,
          reason:
              'Without GlassTheme ancestor, cascade falls to Material ThemeMode');
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  // THE CANONICAL BUG SCENARIO
  // ──────────────────────────────────────────────────────────────────────────

  group('GlassTheme.brightnessOf — canonical bug regression', () {
    testWidgets(
        'REGRESSION: device dark + app light → GlassTheme.brightnessOf returns light',
        (tester) async {
      // This is the exact scenario reported in the issue:
      // "GlassBottomTabBar loses shadow when device is Dark but app is Light Mode"
      //
      // Before this fix, all glass widgets called CupertinoTheme.of().brightness
      // which falls back to MediaQuery.platformBrightnessOf (device setting).
      // This caused the shadow to disappear even in Light-Mode apps.
      //
      // After this fix, GlassTheme.brightnessOf correctly returns Brightness.light
      // when the app is ThemeMode.light, regardless of the device OS setting.

      Brightness? resolved;
      await tester.pumpWidget(
        MediaQuery(
          // Device/OS is in Dark Mode
          data: const MediaQueryData(platformBrightness: Brightness.dark),
          child: MaterialApp(
            theme: ThemeData.light(),
            darkTheme: ThemeData.dark(),
            themeMode: ThemeMode.light, // App is explicitly Light Mode
            home: GlassTheme(
              data: const GlassThemeData(),
              child: Builder(builder: (ctx) {
                resolved = GlassTheme.brightnessOf(ctx);
                return const SizedBox.shrink();
              }),
            ),
          ),
        ),
      );

      // The app is ThemeMode.light — the glass theme must see light, not dark.
      expect(resolved, Brightness.light,
          reason:
              'App is ThemeMode.light: glass widgets MUST see Brightness.light '
              'even when the device OS is Dark Mode. '
              'This is the regression that caused shadows to disappear.');
    });
  });
}
