// Tests for the resolveGlassBrightness utility function.
//
// These tests verify the three-level cascade:
//   Level 1: Theme.maybeBrightnessOf (Material ThemeMode).
//            - Non-null inside any MaterialApp. Correctly honours
//              ThemeMode.light / .dark / .system.
//   Level 2: CupertinoTheme.of(context).brightness
//            - Non-null only when the developer explicitly sets it via
//              CupertinoApp(theme:) or a manual CupertinoTheme widget.
//   Level 3: MediaQuery.platformBrightnessOf (device/OS fallback).
//            Only reached in a pure CupertinoApp with no explicit pin.
//
// ⚠ UNIT-TEST LIMITATION
// The canonical regression scenario — OS Dark Mode + ThemeMode.light causing
// glass widgets to incorrectly resolve Brightness.dark — does NOT reproduce in
// the widget-test harness. The Flutter test environment correctly propagates
// ThemeMode through MaterialBasedCupertinoThemeData regardless of the
// simulated platformBrightness, so all tests here pass whether or not the
// Level 2 (Theme.maybeBrightnessOf) cascade step is present.
//
// This means: restoring or removing Theme.maybeBrightnessOf cannot be
// verified by unit tests alone. Before every release, run the manual check
// documented in MANUAL_TEST_CHECKLIST.md.
//
// GlassThemeData.brightness (override) is tested in
// glass_theme_data_brightness_test.dart and glass_theme_brightness_test.dart.

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart'; // test-only: used for MaterialApp host wrappers
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_widgets/utils/glass_brightness.dart';

void main() {
  // ──────────────────────────────────────────────────────────────────────────
  // Helper
  // ──────────────────────────────────────────────────────────────────────────

  /// Pump a widget tree and capture the brightness resolved by
  /// [resolveGlassBrightness] at the leaf.
  Future<Brightness> pumpAndCapture(
    WidgetTester tester,
    Widget Function(Widget child) wrapper,
  ) async {
    Brightness? captured;
    await tester.pumpWidget(
      wrapper(
        Builder(builder: (context) {
          captured = resolveGlassBrightness(context);
          return const SizedBox.shrink();
        }),
      ),
    );
    return captured!;
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Level 2a: CupertinoApp with explicit brightness pin
  // ──────────────────────────────────────────────────────────────────────────

  group('resolveGlassBrightness — Level 2: CupertinoApp explicit pin', () {
    testWidgets(
        'returns Brightness.light when CupertinoThemeData.brightness is light',
        (tester) async {
      // Device dark, Cupertino explicitly pinned to light — should return light.
      final result = await pumpAndCapture(
        tester,
        (child) => MediaQuery(
          data: const MediaQueryData(platformBrightness: Brightness.dark),
          child: CupertinoApp(
            theme: const CupertinoThemeData(brightness: Brightness.light),
            home: CupertinoPageScaffold(child: child),
          ),
        ),
      );
      expect(result, Brightness.light,
          reason: 'Explicit Cupertino pin overrides device dark mode');
    });

    testWidgets(
        'returns Brightness.dark when CupertinoThemeData.brightness is dark',
        (tester) async {
      // Device light, Cupertino explicitly pinned to dark — should return dark.
      final result = await pumpAndCapture(
        tester,
        (child) => MediaQuery(
          data: const MediaQueryData(platformBrightness: Brightness.light),
          child: CupertinoApp(
            theme: const CupertinoThemeData(brightness: Brightness.dark),
            home: CupertinoPageScaffold(child: child),
          ),
        ),
      );
      expect(result, Brightness.dark,
          reason: 'Explicit Cupertino pin overrides device light mode');
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  // Level 1: MaterialApp — resolved via MaterialBasedCupertinoThemeData
  //
  // Flutter's MaterialApp automatically wraps the widget tree with a
  // CupertinoTheme using MaterialBasedCupertinoThemeData, whose .brightness
  // property is non-nullable and always returns the active ThemeData brightness.
  // Level 1 therefore handles MaterialApp ThemeMode correctly without any
  // direct Material API access.
  // ──────────────────────────────────────────────────────────────────────────

  group(
      'resolveGlassBrightness — Level 1: MaterialApp ThemeMode (via MaterialBasedCupertinoThemeData)',
      () {
    testWidgets(
        'returns Brightness.light for ThemeMode.light when device is dark',
        (tester) async {
      // The canonical bug scenario: device OS is dark, app is ThemeMode.light.
      final result = await pumpAndCapture(
        tester,
        (child) => MediaQuery(
          data: const MediaQueryData(platformBrightness: Brightness.dark),
          child: MaterialApp(
            theme: ThemeData.light(),
            darkTheme: ThemeData.dark(),
            themeMode: ThemeMode.light, // app explicitly light
            home: Scaffold(body: child),
          ),
        ),
      );
      expect(result, Brightness.light,
          reason:
              'ThemeMode.light must override device dark — this is the primary bug fix');
    });

    testWidgets(
        'returns Brightness.dark for ThemeMode.dark when device is light',
        (tester) async {
      final result = await pumpAndCapture(
        tester,
        (child) => MediaQuery(
          data: const MediaQueryData(platformBrightness: Brightness.light),
          child: MaterialApp(
            theme: ThemeData.light(),
            darkTheme: ThemeData.dark(),
            themeMode: ThemeMode.dark, // app explicitly dark
            home: Scaffold(body: child),
          ),
        ),
      );
      expect(result, Brightness.dark,
          reason: 'ThemeMode.dark must override device light');
    });

    testWidgets('follows device brightness for ThemeMode.system (light device)',
        (tester) async {
      final result = await pumpAndCapture(
        tester,
        (child) => MediaQuery(
          data: const MediaQueryData(platformBrightness: Brightness.light),
          child: MaterialApp(
            theme: ThemeData.light(),
            darkTheme: ThemeData.dark(),
            themeMode: ThemeMode.system,
            home: Scaffold(body: child),
          ),
        ),
      );
      expect(result, Brightness.light,
          reason: 'ThemeMode.system on light device returns light');
    });

    testWidgets('follows device brightness for ThemeMode.system (dark device)',
        (tester) async {
      final result = await pumpAndCapture(
        tester,
        (child) => MediaQuery(
          data: const MediaQueryData(platformBrightness: Brightness.dark),
          child: MaterialApp(
            theme: ThemeData.light(),
            darkTheme: ThemeData.dark(),
            themeMode: ThemeMode.system,
            home: Scaffold(body: child),
          ),
        ),
      );
      expect(result, Brightness.dark,
          reason: 'ThemeMode.system on dark device returns dark');
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  // Level 3: System / device fallback (CupertinoApp, no explicit pin)
  // ──────────────────────────────────────────────────────────────────────────

  group('resolveGlassBrightness — Level 3: device system fallback', () {
    testWidgets(
        'returns device brightness when no explicit Cupertino pin or Material',
        (tester) async {
      // Pure CupertinoApp with NO explicit brightness pin — must fall back to
      // MediaQuery.platformBrightnessOf.
      final resultDark = await pumpAndCapture(
        tester,
        (child) => MediaQuery(
          data: const MediaQueryData(platformBrightness: Brightness.dark),
          child: CupertinoApp(
            // No explicit brightness — null, resolves to system
            home: CupertinoPageScaffold(child: child),
          ),
        ),
      );
      expect(resultDark, Brightness.dark,
          reason: 'Dark device, no explicit pin → dark (fallback)');

      final resultLight = await pumpAndCapture(
        tester,
        (child) => MediaQuery(
          data: const MediaQueryData(platformBrightness: Brightness.light),
          child: CupertinoApp(
            home: CupertinoPageScaffold(child: child),
          ),
        ),
      );
      expect(resultLight, Brightness.light,
          reason: 'Light device, no explicit pin → light (fallback)');
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  // Priority order: CupertinoApp pin > MaterialApp ThemeMode > system
  // ──────────────────────────────────────────────────────────────────────────

  group('resolveGlassBrightness — cascade priority order', () {
    testWidgets('CupertinoTheme explicit pin beats MaterialApp ThemeMode',
        (tester) async {
      // All three disagree: device dark, Material ThemeMode light, Cupertino dark.
      // Expected: explicit CupertinoThemeData pin wins (dark).
      //
      // Mechanism: an explicit CupertinoTheme ancestor with a true
      // CupertinoThemeData (not MaterialBasedCupertinoThemeData) returns a
      // non-null .brightness, so Level 1 returns it immediately.
      final result = await pumpAndCapture(
        tester,
        (child) => MediaQuery(
          data: const MediaQueryData(platformBrightness: Brightness.dark),
          child: MaterialApp(
            theme: ThemeData.light(),
            darkTheme: ThemeData.dark(),
            themeMode: ThemeMode.light, // Material says light
            home: CupertinoTheme(
              data: const CupertinoThemeData(
                  brightness: Brightness.dark), // Cupertino says dark
              child: Scaffold(body: child),
            ),
          ),
        ),
      );
      expect(result, Brightness.dark,
          reason:
              'Explicit CupertinoThemeData.brightness wins over Material ThemeMode');
    });

    testWidgets('MaterialApp ThemeMode beats system device brightness',
        (tester) async {
      // Device dark, no explicit Cupertino pin, but Material is ThemeMode.light.
      final result = await pumpAndCapture(
        tester,
        (child) => MediaQuery(
          data: const MediaQueryData(platformBrightness: Brightness.dark),
          child: MaterialApp(
            theme: ThemeData.light(),
            darkTheme: ThemeData.dark(),
            themeMode: ThemeMode.light,
            home: Scaffold(body: child),
          ),
        ),
      );
      expect(result, Brightness.light,
          reason: 'Material ThemeMode.light wins over dark device OS setting');
    });
  });

  // NOTE: The canonical on-device regression (OS Dark + ThemeMode.light →
  // glass widgets incorrectly dark) cannot be reproduced here. The widget-test
  // harness propagates ThemeMode correctly through MaterialBasedCupertinoThemeData
  // regardless of platformBrightness, so a test covering that scenario would
  // pass even with the Level 2 cascade step removed — giving false confidence.
  // See MANUAL_TEST_CHECKLIST.md for the required pre-release device check.
}
