// ignore_for_file: implementation_imports

import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:liquid_glass_widgets/src/widgets/surfaces/tab_bar_bottom_internal.dart';
import 'package:liquid_glass_widgets/src/widgets/surfaces/tab_bar_layout_utils.dart';
import 'package:liquid_glass_widgets/src/widgets/surfaces/tab_bar_searchable_internal.dart';

import '../../shared/test_helpers.dart';

/// A bar has to be able to reach the native touch light, and until now it
/// could not.
///
/// [GlassButton] has resolved the iOS 26 calibration since 1.3.0 — a wide 1.6
/// radius under a sigma-16 Gaussian at a low alpha, which its own doc
/// describes as washing light across the surface "without producing a
/// concentrated, pointy hotspot". It keys that off a **null** `glowRadius`.
/// [GlassTabBar]'s `interactionGlowRadius` was non-nullable with a default, so
/// no bar had a null to key on: it was pinned to the theme's fallback sigma of
/// 4, which at any useful radius draws a disc with an edge on it.
///
/// Null now means native mode on every factory, and the resolution is shared
/// so the two layouts cannot drift apart again.
void main() {
  const tabs = [
    GlassTab(label: 'Home', icon: Icon(CupertinoIcons.home)),
    GlassTab(label: 'Search', icon: Icon(CupertinoIcons.search)),
    GlassTab(label: 'Profile', icon: Icon(CupertinoIcons.person)),
  ];

  group('resolveTabBarInteractionGlow', () {
    test('a null radius takes the native calibration whole', () {
      final glow = resolveTabBarInteractionGlow(
        interactionGlowRadius: null,
        interactionGlowColor: null,
        themeGlowColor: const Color(0xFFFF0000),
        themeGlowBlurRadius: 4,
        isDark: true,
      );

      expect(glow.radius, kNativeTabBarGlowRadius);
      // The blur is the half that could not be reached: the theme's 4 is what
      // every bar was stuck with.
      expect(glow.blurRadius, kNativeTabBarGlowBlurRadius);
      expect(glow.color, kNativeTabBarGlowColorDark);
    });

    test('and the light-mode sheen in light mode', () {
      final glow = resolveTabBarInteractionGlow(
        interactionGlowRadius: null,
        interactionGlowColor: null,
        themeGlowColor: null,
        themeGlowBlurRadius: 4,
        isDark: false,
      );

      expect(glow.color, kNativeTabBarGlowColorLight);
    });

    test('an explicit radius keeps the theme palette', () {
      // An app that tuned its glow through GlassGlowColors keeps exactly what
      // it tuned — native mode is opt-in by omission, not a new floor.
      final glow = resolveTabBarInteractionGlow(
        interactionGlowRadius: 0.75,
        interactionGlowColor: null,
        themeGlowColor: const Color(0xFFFF0000),
        themeGlowBlurRadius: 4,
        isDark: true,
      );

      expect(glow.radius, 0.75);
      expect(glow.blurRadius, 4);
      expect(glow.color, const Color(0xFFFF0000));
    });

    test('an explicit colour wins over the native sheen', () {
      final glow = resolveTabBarInteractionGlow(
        interactionGlowRadius: null,
        interactionGlowColor: const Color(0xFF00FF00),
        themeGlowColor: const Color(0xFFFF0000),
        themeGlowBlurRadius: 4,
        isDark: true,
      );

      expect(glow.color, const Color(0xFF00FF00));
      // Native mode still owns the geometry it was asked for.
      expect(glow.radius, kNativeTabBarGlowRadius);
      expect(glow.blurRadius, kNativeTabBarGlowBlurRadius);
    });

    test('a theme colour may be null, which the internal widget falls back on',
        () {
      final glow = resolveTabBarInteractionGlow(
        interactionGlowRadius: 1.5,
        interactionGlowColor: null,
        themeGlowColor: null,
        themeGlowBlurRadius: 4,
        isDark: false,
      );

      expect(glow.color, isNull);
    });
  });

  group('GlassTabBar.bottom', () {
    testWidgets('reaches the native glow when no radius is given',
        (tester) async {
      await tester.pumpWidget(createTestApp(
        child: GlassTabBar.bottom(
          tabs: tabs,
          selectedIndex: 0,
          onTabSelected: (_) {},
          maskingQuality: MaskingQuality.off,
        ),
      ));

      final indicator = tester.widget<TabIndicator>(find.byType(TabIndicator));
      expect(indicator.interactionGlowRadius, kNativeTabBarGlowRadius);
      expect(
        indicator.interactionGlowBlurRadius,
        kNativeTabBarGlowBlurRadius,
        reason: 'the bar is still pinned to the theme fallback sigma',
      );
    });

    testWidgets('an explicit radius still reaches the indicator',
        (tester) async {
      await tester.pumpWidget(createTestApp(
        child: GlassTabBar.bottom(
          tabs: tabs,
          selectedIndex: 0,
          onTabSelected: (_) {},
          interactionGlowRadius: 0.75,
          maskingQuality: MaskingQuality.off,
        ),
      ));

      final indicator = tester.widget<TabIndicator>(find.byType(TabIndicator));
      expect(indicator.interactionGlowRadius, 0.75);
      expect(indicator.interactionGlowBlurRadius, 4);
    });
  });

  group('GlassTabBar.searchable', () {
    testWidgets('resolves the same native glow as the bottom bar',
        (tester) async {
      await tester.pumpWidget(createTestApp(
        child: GlassTabBar.searchable(
          tabs: tabs,
          selectedIndex: 0,
          onTabSelected: (_) {},
          isSearchActive: false,
          maskingQuality: MaskingQuality.off,
          searchConfig: GlassSearchBarConfig(
            onSearchToggle: (_) {},
            hintText: 'Search',
          ),
        ),
      ));
      await tester.pumpAndSettle();

      // The searchable bar builds its own indicator, which is the reason the
      // two layouts each resolved the glow for themselves and could drift.
      final indicator = tester
          .widget<SearchableTabIndicator>(find.byType(SearchableTabIndicator));
      expect(indicator.interactionGlowRadius, kNativeTabBarGlowRadius);
      expect(indicator.interactionGlowBlurRadius, kNativeTabBarGlowBlurRadius);
    });
  });

  group('GlassTabBar.minimizable', () {
    testWidgets('shares the searchable engine, and its native glow',
        (tester) async {
      await tester.pumpWidget(createTestApp(
        child: GlassTabBar.minimizable(
          tabs: tabs,
          selectedIndex: 0,
          onTabSelected: (_) {},
          maskingQuality: MaskingQuality.off,
        ),
      ));
      await tester.pumpAndSettle();

      final indicator = tester
          .widget<SearchableTabIndicator>(find.byType(SearchableTabIndicator));
      expect(indicator.interactionGlowRadius, kNativeTabBarGlowRadius);
      expect(indicator.interactionGlowBlurRadius, kNativeTabBarGlowBlurRadius);
    });
  });

  group('GlassTabBar.inline', () {
    testWidgets('takes the native calibration too', (tester) async {
      // This is the factory that carried the odd 1.0 default — not
      // `.searchable`, which was 1.5 like the rest. Its own comment calls 1.0
      // a "compact default suited for inline placement", so it was a choice
      // rather than a typo. It lands on 1.6 here because the radius is a
      // fraction of the layer's shortest side, not an absolute: the same
      // figure `GlassButton` uses on controls smaller than this one.
      await tester.pumpWidget(createTestApp(
        child: GlassTabBar.inline(
          tabs: tabs,
          selectedIndex: 0,
          onTabSelected: (_) {},
          maskingQuality: MaskingQuality.off,
        ),
      ));
      await tester.pumpAndSettle();

      final indicator = tester.widget<TabIndicator>(find.byType(TabIndicator));
      expect(indicator.interactionGlowRadius, kNativeTabBarGlowRadius);
      expect(indicator.interactionGlowBlurRadius, kNativeTabBarGlowBlurRadius);
    });
  });
}
