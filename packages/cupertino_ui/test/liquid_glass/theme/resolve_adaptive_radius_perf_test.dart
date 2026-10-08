// Tests for performance optimisation D2:
//   resolveAdaptiveRadius must use scoped MediaQuery accessors
//   (MediaQuery.viewPaddingOf / MediaQuery.sizeOf) instead of the broad
//   MediaQuery.of(context). The scoped accessors limit rebuild scope so that
//   glass widgets do not rebuild when unrelated MediaQuery fields change
//   (keyboard insets, textScaleFactor, alwaysUse24HourFormat, etc.).
//
// These tests cover:
//   1. Correct return values after the scoped-accessor refactor (regression guard).
//   2. That resolveAdaptiveRadius does NOT depend on viewInsets (keyboard).
//   3. That resolveAdaptiveRadius does NOT depend on textScaleFactor.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_widgets/theme/glass_theme_helpers.dart';

void main() {
  Widget buildWithMedia(
    Widget Function(BuildContext) probe, {
    Size size = const Size(390, 844),
    EdgeInsets viewPadding = const EdgeInsets.only(top: 44, bottom: 34),
    EdgeInsets viewInsets = EdgeInsets.zero,
    double textScaleFactor = 1.0,
  }) {
    return MaterialApp(
      home: Builder(builder: (context) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            size: size,
            viewPadding: viewPadding,
            padding: viewPadding,
            viewInsets: viewInsets,
            textScaler: TextScaler.linear(textScaleFactor),
          ),
          child: Builder(builder: probe),
        );
      }),
    );
  }

  // ── D2 regression: correct values still returned after scoped-accessor refactor ──

  group('resolveAdaptiveRadius — D2 scoped MediaQuery regression', () {
    testWidgets('Pro Max height (>= 900) returns 54.0', (tester) async {
      double? result;
      await tester.pumpWidget(buildWithMedia(
        (ctx) {
          result = GlassThemeHelpers.resolveAdaptiveRadius(ctx);
          return const SizedBox.shrink();
        },
        size: const Size(430, 932),
        viewPadding: const EdgeInsets.only(top: 44, bottom: 34),
      ));
      expect(result, 54.0);
    }, variant: TargetPlatformVariant.only(TargetPlatform.iOS));

    testWidgets('Pro height (>= 800, < 900) returns 46.0', (tester) async {
      double? result;
      await tester.pumpWidget(buildWithMedia(
        (ctx) {
          result = GlassThemeHelpers.resolveAdaptiveRadius(ctx);
          return const SizedBox.shrink();
        },
        size: const Size(393, 852),
        viewPadding: const EdgeInsets.only(top: 54, bottom: 34),
      ));
      expect(result, 46.0);
    }, variant: TargetPlatformVariant.only(TargetPlatform.iOS));

    testWidgets('home-button device (bottom == 0) returns 0.0', (tester) async {
      double? result;
      await tester.pumpWidget(buildWithMedia(
        (ctx) {
          result = GlassThemeHelpers.resolveAdaptiveRadius(ctx);
          return const SizedBox.shrink();
        },
        size: const Size(375, 667),
        viewPadding: const EdgeInsets.only(top: 20, bottom: 0),
      ));
      expect(result, 0.0);
    }, variant: TargetPlatformVariant.only(TargetPlatform.iOS));

    testWidgets('Android with bottom safe area returns 28.0', (tester) async {
      double? result;
      await tester.pumpWidget(buildWithMedia(
        (ctx) {
          result = GlassThemeHelpers.resolveAdaptiveRadius(ctx);
          return const SizedBox.shrink();
        },
        size: const Size(412, 892),
        viewPadding: const EdgeInsets.only(top: 28, bottom: 24),
      ));
      expect(result, 28.0);
    }, variant: TargetPlatformVariant.only(TargetPlatform.android));
  });

  // ── D2 correctness: result must be identical when irrelevant MediaQuery fields change ──

  group('resolveAdaptiveRadius — insensitive to irrelevant MediaQuery fields',
      () {
    testWidgets('keyboard open (large viewInsets) does not change radius',
        (tester) async {
      double? radiusNoKeyboard;
      double? radiusWithKeyboard;

      await tester.pumpWidget(buildWithMedia(
        (ctx) {
          radiusNoKeyboard = GlassThemeHelpers.resolveAdaptiveRadius(ctx);
          return const SizedBox.shrink();
        },
        size: const Size(390, 844),
        viewPadding: const EdgeInsets.only(top: 44, bottom: 34),
        viewInsets: EdgeInsets.zero,
      ));

      await tester.pumpWidget(buildWithMedia(
        (ctx) {
          radiusWithKeyboard = GlassThemeHelpers.resolveAdaptiveRadius(ctx);
          return const SizedBox.shrink();
        },
        size: const Size(390, 844),
        viewPadding: const EdgeInsets.only(top: 44, bottom: 34),
        viewInsets: const EdgeInsets.only(bottom: 300), // keyboard up
      ));

      expect(radiusNoKeyboard, isNotNull);
      expect(
        radiusWithKeyboard,
        radiusNoKeyboard,
        reason: 'resolveAdaptiveRadius must return the same value regardless '
            'of keyboard insets — it only depends on viewPadding and size',
      );
    }, variant: TargetPlatformVariant.only(TargetPlatform.iOS));

    testWidgets('textScaleFactor change does not change radius',
        (tester) async {
      double? radiusScale1;
      double? radiusScale2;

      await tester.pumpWidget(buildWithMedia(
        (ctx) {
          radiusScale1 = GlassThemeHelpers.resolveAdaptiveRadius(ctx);
          return const SizedBox.shrink();
        },
        size: const Size(390, 844),
        viewPadding: const EdgeInsets.only(top: 44, bottom: 34),
        textScaleFactor: 1.0,
      ));

      await tester.pumpWidget(buildWithMedia(
        (ctx) {
          radiusScale2 = GlassThemeHelpers.resolveAdaptiveRadius(ctx);
          return const SizedBox.shrink();
        },
        size: const Size(390, 844),
        viewPadding: const EdgeInsets.only(top: 44, bottom: 34),
        textScaleFactor: 2.5,
      ));

      expect(radiusScale1, isNotNull);
      expect(
        radiusScale2,
        radiusScale1,
        reason: 'resolveAdaptiveRadius must not depend on textScaleFactor',
      );
    }, variant: TargetPlatformVariant.only(TargetPlatform.iOS));
  });
}
