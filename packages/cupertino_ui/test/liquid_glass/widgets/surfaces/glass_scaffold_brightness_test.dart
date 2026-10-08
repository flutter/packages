// Regression tests for issue #289:
// GlassScaffold fails to adapt brightness in dark mode when using MaterialApp.
//
// Root cause: GlassScaffold and GlassPage used MediaQuery.platformBrightnessOf
// for the scaffold background colour and GlassStatusBarStyle.auto icon styling.
// That reads the OS/device brightness, NOT the Material ThemeMode. When
// ThemeMode.dark was set but the device OS was in light mode (or vice versa),
// the scaffold chrome stayed at the wrong brightness.
//
// Fix: all call sites now use GlassTheme.brightnessOf(context), which flows
// through the full cascade: GlassThemeData.brightness → Cupertino pin →
// Material ThemeMode (via glassExternalBrightnessResolver) → device OS.
//
// ⚠ IMPORTANT — same harness caveat as glass_brightness_test.dart:
// In the widget-test environment, Flutter's MaterialApp wraps the tree with
// MaterialBasedCupertinoThemeData, whose .brightness is always in sync with
// the active ThemeMode. This means:
//   - The scaffold background colour tests pass correctly (Color checks work).
//   - The GlassStatusBarStyle.auto tests verify the code path, but the system
//     chrome call (SystemChrome.setSystemUIOverlayStyle) cannot be observed in
//     the widget-test harness. We assert on the computed bool value instead by
//     reading the AnnotatedRegion's value.

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart'; // test-only
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:liquid_glass_widgets/utils/glass_brightness.dart';
import 'package:liquid_glass_widgets/widgets/shared/glass_page.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────────────────────────────────────

/// Pumps a [GlassScaffold] inside a [MaterialApp] with the given [themeMode]
/// and device [platformBrightness], then returns the rendered widget tree.
///
/// [brightnessResolver] is registered (mirroring real app setup) so that
/// [GlassTheme.brightnessOf] correctly forwards Material ThemeMode.
Future<void> pumpScaffold(
  WidgetTester tester, {
  required ThemeMode themeMode,
  required Brightness platformBrightness,
  GlassStatusBarStyle statusBarStyle = GlassStatusBarStyle.none,
  Widget? background,
  Color? backgroundColor,
}) async {
  // Register the Material brightness resolver — same as real app usage.
  glassExternalBrightnessResolver = Theme.maybeBrightnessOf;

  await tester.pumpWidget(
    MediaQuery(
      data: MediaQueryData(platformBrightness: platformBrightness),
      child: MaterialApp(
        theme: ThemeData.light(),
        darkTheme: ThemeData.dark(),
        themeMode: themeMode,
        home: GlassScaffold(
          statusBarStyle: statusBarStyle,
          background: background,
          backgroundColor: backgroundColor,
          body: const SizedBox.shrink(),
        ),
      ),
    ),
  );

  // Clear the resolver after each test to avoid state leak.
  addTearDown(() => glassExternalBrightnessResolver = null);
}

// ─────────────────────────────────────────────────────────────────────────────
// Scaffold background colour (issue #289 primary symptom)
// ─────────────────────────────────────────────────────────────────────────────

/// Resolves the effective background colour rendered by [CupertinoPageScaffold].
Color resolveScaffoldColor(WidgetTester tester) {
  final scaffoldElement = tester.element(find.byType(CupertinoPageScaffold));
  final decoratedBox = tester.widget<DecoratedBox>(
    find
        .descendant(
          of: find.byType(CupertinoPageScaffold),
          matching: find.byType(DecoratedBox),
        )
        .first,
  );
  final boxColor = (decoratedBox.decoration as BoxDecoration).color!;
  if (boxColor is CupertinoDynamicColor) {
    return boxColor.resolveFrom(scaffoldElement);
  }
  return boxColor;
}

void main() {
  // Disable the GlassPage initialize guard so we don't need a full
  // LiquidGlassWidgets.initialize() call in tests.
  setUpAll(() => glassPageInitializeGuardEnabled = false);
  tearDownAll(() => glassPageInitializeGuardEnabled = true);

  group('GlassScaffold background colour — issue #289', () {
    testWidgets(
        'dark page: ThemeMode.dark + light device → black scaffold background',
        (tester) async {
      // THE bug: device OS is light, app ThemeMode is dark.
      // Before fix: CupertinoPageScaffold used CupertinoTheme.scaffoldBackgroundColor
      // which reflected the device OS (light) → white page even in dark ThemeMode.
      // After fix: CupertinoTheme is scoped with GlassTheme.brightnessOf (dark) → black page.
      await pumpScaffold(
        tester,
        themeMode: ThemeMode.dark,
        platformBrightness:
            Brightness.light, // device is light — the key tension
      );

      final scaffold = tester
          .widget<CupertinoPageScaffold>(find.byType(CupertinoPageScaffold));
      expect(scaffold.backgroundColor, isNull,
          reason:
              'CupertinoPageScaffold.backgroundColor is null to inherit CupertinoTheme (issue #177)');

      final effectiveColor = resolveScaffoldColor(tester);
      expect(
        ThemeData.estimateBrightnessForColor(effectiveColor),
        Brightness.dark,
        reason:
            'ThemeMode.dark must produce a dark scaffold even when the device OS is light',
      );
      expect(
        effectiveColor,
        ThemeData.dark().scaffoldBackgroundColor,
        reason:
            'In MaterialApp, CupertinoPageScaffold inherits Material dark scaffoldBackgroundColor',
      );
    });

    testWidgets(
        'light page: ThemeMode.light + dark device → white scaffold background',
        (tester) async {
      // Mirror scenario: device OS is dark, app ThemeMode is light.
      // GlassTheme.brightnessOf must return Brightness.light → white page.
      await pumpScaffold(
        tester,
        themeMode: ThemeMode.light,
        platformBrightness: Brightness.dark, // device is dark — the tension
      );

      final scaffold = tester
          .widget<CupertinoPageScaffold>(find.byType(CupertinoPageScaffold));
      expect(scaffold.backgroundColor, isNull,
          reason:
              'CupertinoPageScaffold.backgroundColor is null to inherit CupertinoTheme (issue #177)');

      final effectiveColor = resolveScaffoldColor(tester);
      expect(
        ThemeData.estimateBrightnessForColor(effectiveColor),
        Brightness.light,
        reason:
            'ThemeMode.light must produce a light scaffold even when the device OS is dark',
      );
      expect(
        effectiveColor,
        ThemeData.light().scaffoldBackgroundColor,
        reason:
            'In MaterialApp, CupertinoPageScaffold inherits Material light scaffoldBackgroundColor',
      );
    });

    testWidgets(
        'explicit background provided → scaffold is forced transparent (issue #177 not regressed)',
        (tester) async {
      // When a background widget is provided the scaffold must be transparent
      // so the background shows through. The #289 colour resolution must NOT
      // interfere with this path.
      await pumpScaffold(
        tester,
        themeMode: ThemeMode.dark,
        platformBrightness: Brightness.light,
        background: const ColoredBox(color: Color(0xFF1C1C1E)),
      );

      final scaffold = tester
          .widget<CupertinoPageScaffold>(find.byType(CupertinoPageScaffold));
      expect(
        scaffold.backgroundColor,
        const Color(0x00000000),
        reason:
            'Explicit background must force CupertinoPageScaffold fully transparent',
      );
    });

    testWidgets(
        'explicit backgroundColor provided → scaffold uses that colour exactly',
        (tester) async {
      // When the caller passes backgroundColor explicitly, it takes effect as a
      // ColoredBox background widget, forcing the scaffold transparent — same
      // transparent behaviour as providing a background widget.
      await pumpScaffold(
        tester,
        themeMode: ThemeMode.dark,
        platformBrightness: Brightness.light,
        backgroundColor: const Color(0xFF2C2C2E),
      );

      final scaffold = tester
          .widget<CupertinoPageScaffold>(find.byType(CupertinoPageScaffold));
      expect(
        scaffold.backgroundColor,
        const Color(0x00000000),
        reason:
            'Explicit backgroundColor provides a background widget → scaffold is transparent',
      );
    });
  });

  // ─────────────────────────────────────────────────────────────────────────────
  // GlassStatusBarStyle.auto — brightness cascade (issue #289 secondary symptom)
  // ─────────────────────────────────────────────────────────────────────────────

  group('GlassStatusBarStyle.auto — issue #289', () {
    /// Reads the [SystemUiOverlayStyle] from the [AnnotatedRegion] that
    /// [GlassScaffold] inserts when [statusBarStyle] is not [GlassStatusBarStyle.none].
    SystemUiOverlayStyle? captureAnnotatedStyle(WidgetTester tester) {
      final region = tester
          .widgetList<AnnotatedRegion<SystemUiOverlayStyle>>(
            find.byType(AnnotatedRegion<SystemUiOverlayStyle>),
          )
          .lastOrNull;
      return region?.value;
    }

    testWidgets(
        'auto: ThemeMode.dark + light device → light icons (dark scaffold)',
        (tester) async {
      await pumpScaffold(
        tester,
        themeMode: ThemeMode.dark,
        platformBrightness: Brightness.light,
        statusBarStyle: GlassStatusBarStyle.auto,
      );

      final style = captureAnnotatedStyle(tester);
      expect(
        style,
        SystemUiOverlayStyle.light,
        reason:
            'Dark scaffold → light status bar icons; must not be fooled by light device OS',
      );
    });

    testWidgets(
        'auto: ThemeMode.light + dark device → dark icons (light scaffold)',
        (tester) async {
      await pumpScaffold(
        tester,
        themeMode: ThemeMode.light,
        platformBrightness: Brightness.dark,
        statusBarStyle: GlassStatusBarStyle.auto,
      );

      final style = captureAnnotatedStyle(tester);
      expect(
        style,
        SystemUiOverlayStyle.dark,
        reason:
            'Light scaffold → dark status bar icons; must not be fooled by dark device OS',
      );
    });
  });
}
