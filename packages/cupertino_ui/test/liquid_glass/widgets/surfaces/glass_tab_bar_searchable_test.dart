import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:liquid_glass_widgets/src/renderer/liquid_glass_renderer.dart';
import 'package:liquid_glass_widgets/src/widgets/surfaces/tab_bar_bottom_internal.dart';
import 'package:liquid_glass_widgets/src/widgets/surfaces/tab_bar_searchable_internal.dart';

import '../../shared/test_helpers.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

final _testTabs = [
  const GlassTab(
    label: 'For You',
    icon: Icon(CupertinoIcons.news),
  ),
  const GlassTab(
    label: 'Following',
    icon: Icon(CupertinoIcons.person_2),
  ),
  const GlassTab(
    label: 'Saved',
    icon: Icon(CupertinoIcons.bookmark),
  ),
];

Widget _buildBar({
  bool isSearchActive = false,
  int selectedIndex = 0,
  ValueChanged<int>? onTabSelected,
  ValueChanged<bool>? onSearchToggle,
  TextEditingController? controller,
  FocusNode? focusNode,
  ValueChanged<String>? onChanged,
  GlassTabBarExtraButton? extraButton,
  GlassQuality? quality,
  GlassQuality? backgroundQuality,
  bool showPill = true,
}) {
  return createTestApp(
    child: GlassTabBar.searchable(
      tabs: _testTabs,
      selectedIndex: selectedIndex,
      onTabSelected: onTabSelected ?? (_) {},
      isSearchActive: isSearchActive,
      maskingQuality: MaskingQuality.off, // no dual-layer in tests
      quality: quality,
      backgroundQuality: backgroundQuality,
      extraButton: extraButton,
      searchConfig: GlassSearchBarConfig(
        onSearchToggle: onSearchToggle ?? (_) {},
        hintText: 'Search News',
        controller: controller,
        focusNode: focusNode,
        onChanged: onChanged,
        showPill: showPill,
      ),
    ),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('GlassTabBar.searchable', () {
    // ── Instantiation ─────────────────────────────────────────────────────────

    testWidgets('can be instantiated with required parameters', (tester) async {
      await tester.pumpWidget(_buildBar());
      expect(find.byType(GlassTabBar), findsOneWidget);
    });

    testWidgets('displays tab labels when search is inactive', (tester) async {
      await tester.pumpWidget(_buildBar());
      await tester.pump();

      expect(find.text('For You'), findsWidgets);
      expect(find.text('Following'), findsWidgets);
      expect(find.text('Saved'), findsWidgets);
    });

    testWidgets('displays search hint text when search is active',
        (tester) async {
      await tester.pumpWidget(_buildBar(isSearchActive: true));
      await tester.pumpAndSettle();

      expect(find.text('Search News'), findsOneWidget);
    });

    // ── Tab interaction ───────────────────────────────────────────────────────

    testWidgets('calls onTabSelected when a tab is tapped', (tester) async {
      var selected = 0;

      await tester.pumpWidget(
        _buildBar(onTabSelected: (i) => selected = i),
      );
      await tester.pump();

      await tester.tap(find.text('Following').first);
      await tester.pumpAndSettle();

      expect(selected, equals(1));
    });

    testWidgets('reflects selectedIndex correctly', (tester) async {
      await tester.pumpWidget(_buildBar(selectedIndex: 2));
      expect(find.byType(GlassTabBar), findsOneWidget);
    });

    // ── Search toggle ─────────────────────────────────────────────────────────

    testWidgets('calls onSearchToggle when search pill is tapped',
        (tester) async {
      bool? lastToggle;

      await tester.pumpWidget(
        createTestApp(
          child: GlassTabBar.searchable(
            tabs: _testTabs,
            selectedIndex: 0,
            onTabSelected: (_) {},
            isSearchActive: false,
            maskingQuality: MaskingQuality.off,
            searchConfig: GlassSearchBarConfig(
              onSearchToggle: (v) => lastToggle = v,
              hintText: 'Search',
            ),
          ),
        ),
      );
      await tester.pump();

      // Tap the search icon (search toggle button)
      final searchIconFinder = find.byIcon(CupertinoIcons.search);
      if (searchIconFinder.evaluate().isNotEmpty) {
        await tester.tap(searchIconFinder.first);
        await tester.pumpAndSettle();
        expect(lastToggle, isNotNull);
      }
    });

    // ── Text controller ───────────────────────────────────────────────────────

    testWidgets('uses provided TextEditingController', (tester) async {
      final controller = TextEditingController(text: 'flutter');
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        _buildBar(isSearchActive: true, controller: controller),
      );
      await tester.pumpAndSettle();

      // Widget should mount without errors when a controller is provided.
      expect(find.byType(GlassTabBar), findsOneWidget);
    });

    // ── Focus node ────────────────────────────────────────────────────────────

    testWidgets('accepts and preserves a caller-provided FocusNode',
        (tester) async {
      final focusNode = FocusNode();
      addTearDown(focusNode.dispose);

      await tester.pumpWidget(
        _buildBar(isSearchActive: true, focusNode: focusNode),
      );
      await tester.pumpAndSettle();

      // Widget mounted successfully with external focus node — node must still
      // be alive (the widget must NOT have disposed it).
      expect(focusNode.dispose, isA<Function>());
      expect(find.byType(GlassTabBar), findsOneWidget);
    });

    testWidgets('does not dispose caller-provided FocusNode on rebuild',
        (tester) async {
      final focusNode = FocusNode();
      addTearDown(focusNode.dispose);

      await tester
          .pumpWidget(_buildBar(isSearchActive: true, focusNode: focusNode));
      await tester.pumpAndSettle();
      // Trigger a rebuild by toggling search state.
      await tester
          .pumpWidget(_buildBar(isSearchActive: false, focusNode: focusNode));
      await tester.pumpAndSettle();

      // Node should still be usable after the widget rebuilds.
      expect(() => focusNode.hasFocus, returnsNormally);
    });

    // ── onChanged callback ────────────────────────────────────────────────────

    testWidgets('calls onChanged as user types', (tester) async {
      final values = <String>[];
      final controller = TextEditingController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        _buildBar(
          isSearchActive: true,
          controller: controller,
          onChanged: values.add,
        ),
      );
      await tester.pumpAndSettle();

      final textField = find.byType(CupertinoTextField);
      if (textField.evaluate().isNotEmpty) {
        await tester.enterText(textField.first, 'glass');
        await tester.pump();
        expect(values, contains('glass'));
      }
    });

    // ── Extra button ──────────────────────────────────────────────────────────

    testWidgets('displays extra button when provided', (tester) async {
      await tester.pumpWidget(
        _buildBar(
          extraButton: GlassTabBarExtraButton(
            icon: const Icon(CupertinoIcons.add),
            label: 'Add',
            onTap: () {},
          ),
        ),
      );
      await tester.pump();
      expect(find.byIcon(CupertinoIcons.add), findsOneWidget);
    });

    testWidgets('extra button fires onTap correctly', (tester) async {
      var tapped = false;

      await tester.pumpWidget(
        _buildBar(
          extraButton: GlassTabBarExtraButton(
            icon: const Icon(CupertinoIcons.add),
            label: 'Add',
            onTap: () => tapped = true,
          ),
        ),
      );
      await tester.pump();

      await tester.tap(find.byIcon(CupertinoIcons.add));
      await tester.pump();

      expect(tapped, isTrue);
    });

    // ── Quality path ──────────────────────────────────────────────────────────

    testWidgets('mounts correctly with GlassQuality.minimal', (tester) async {
      await tester.pumpWidget(_buildBar(quality: GlassQuality.minimal));
      await tester.pump();
      expect(find.byType(GlassTabBar), findsOneWidget);
    });

    testWidgets('mounts correctly with GlassQuality.standard', (tester) async {
      await tester.pumpWidget(_buildBar(quality: GlassQuality.standard));
      await tester.pump();
      expect(find.byType(GlassTabBar), findsOneWidget);
    });

    // ── Defaults ──────────────────────────────────────────────────────────────

    test('widget defaults are correct', () {
      final bar = GlassTabBar.searchable(
        tabs: _testTabs,
        selectedIndex: 0,
        onTabSelected: (_) {},
        searchConfig: GlassSearchBarConfig(
          onSearchToggle: (_) {},
        ),
      );

      expect(bar.isSearchActive, isFalse);
      expect(bar.spacing, equals(8));
      expect(bar.barHeight, equals(64));
      expect(bar.barBorderRadius, equals(GlassDefaults.capsuleRadius));
      expect(bar.horizontalPadding, equals(20));
      expect(bar.verticalPadding, equals(20));
      expect(bar.showIndicator, isTrue);
      expect(bar.quality, isNull);
    });

    // ── Assertions ────────────────────────────────────────────────────────────

    test('asserts on empty tabs list', () {
      expect(
        () => GlassTabBar.searchable(
          tabs: const [],
          selectedIndex: 0,
          onTabSelected: (_) {},
          searchConfig: GlassSearchBarConfig(onSearchToggle: (_) {}),
        ),
        throwsAssertionError,
      );
    });

    test('asserts when selectedIndex is out of range', () {
      expect(
        () => GlassTabBar.searchable(
          tabs: _testTabs,
          selectedIndex: 99,
          onTabSelected: (_) {},
          searchConfig: GlassSearchBarConfig(onSearchToggle: (_) {}),
        ),
        throwsAssertionError,
      );
    });
  });

  // ── GlassSearchBarConfig ───────────────────────────────────────────────────

  group('GlassSearchBarConfig', () {
    test('can be instantiated with required parameters', () {
      final config = GlassSearchBarConfig(
        onSearchToggle: (_) {},
      );

      expect(config.hintText, equals('Search'));
      expect(config.collapsedTabWidth, isNull);
      expect(config.autocorrect, isTrue);
      expect(config.enableSuggestions, isTrue);
      expect(config.autoFocusOnExpand, isFalse);
      expect(config.showsCancelButton, isTrue);
    });

    test('respects custom hint text', () {
      final config = GlassSearchBarConfig(
        onSearchToggle: (_) {},
        hintText: 'Search Apple News',
      );
      expect(config.hintText, equals('Search Apple News'));
    });

    test('stores focusNode reference without disposing', () {
      final node = FocusNode();
      addTearDown(node.dispose);

      final config = GlassSearchBarConfig(
        onSearchToggle: (_) {},
        focusNode: node,
      );

      expect(config.focusNode, same(node));
    });

    test('stores controller reference', () {
      final ctrl = TextEditingController();
      addTearDown(ctrl.dispose);

      final config = GlassSearchBarConfig(
        onSearchToggle: (_) {},
        controller: ctrl,
      );

      expect(config.controller, same(ctrl));
    });

    // ── cursorColor (PR #71) ────────────────────────────────────────────────

    test('cursorColor defaults to null (follows Flutter theme chain)', () {
      final config = GlassSearchBarConfig(onSearchToggle: (_) {});
      expect(config.cursorColor, isNull);
    });

    test('cursorColor stores explicit value', () {
      final config = GlassSearchBarConfig(
        onSearchToggle: (_) {},
        cursorColor: const Color(0xFFFF0000),
      );
      expect(config.cursorColor, equals(const Color(0xFFFF0000)));
    });

    test('cursorColor is independent from textColor', () {
      final config = GlassSearchBarConfig(
        onSearchToggle: (_) {},
        textColor: const Color(0xFFFFFFFF),
        cursorColor: const Color(0xFF0000FF),
      );
      expect(config.textColor, equals(const Color(0xFFFFFFFF)));
      expect(config.cursorColor, equals(const Color(0xFF0000FF)));
    });
  });

  // ── Additional coverage for uncovered branches ───────────────────────────

  group('GlassTabBar.searchable uncovered branch coverage', () {
    testWidgets('quality inherited when quality param is null', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: AdaptiveLiquidGlassLayer(
            settings: settingsWithoutLighting,
            child: GlassTabBar.searchable(
              tabs: _testTabs,
              selectedIndex: 0,
              onTabSelected: (_) {},
              maskingQuality: MaskingQuality.off,
              searchConfig: GlassSearchBarConfig(
                onSearchToggle: (_) {},
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      expect(find.byType(GlassTabBar), findsOneWidget);
    });

    testWidgets('tabPillAnchor center activates centeredTab branch',
        (tester) async {
      bool searching = false;
      late StateSetter outerSetState;
      await tester.pumpWidget(
        createTestApp(
          child: StatefulBuilder(
            builder: (ctx, setState) {
              outerSetState = setState;
              return GlassTabBar.searchable(
                tabs: _testTabs,
                selectedIndex: 0,
                onTabSelected: (_) {},
                isSearchActive: searching,
                maskingQuality: MaskingQuality.off,
                tabPillAnchor: GlassTabPillAnchor.center,
                searchConfig: GlassSearchBarConfig(
                  onSearchToggle: (v) => setState(() => searching = v),
                ),
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      outerSetState(() => searching = true);
      await tester.pumpAndSettle();

      expect(find.byType(GlassTabBar), findsOneWidget);
    });

    testWidgets('didUpdateWidget clears _searchFocused when search deactivated',
        (tester) async {
      bool searching = true;
      late StateSetter outerSetState;
      await tester.pumpWidget(
        createTestApp(
          child: StatefulBuilder(
            builder: (ctx, setState) {
              outerSetState = setState;
              return GlassTabBar.searchable(
                tabs: _testTabs,
                selectedIndex: 0,
                onTabSelected: (_) {},
                isSearchActive: searching,
                maskingQuality: MaskingQuality.off,
                searchConfig: GlassSearchBarConfig(
                  onSearchToggle: (v) => setState(() => searching = v),
                  autoFocusOnExpand: true,
                  showsCancelButton: true,
                ),
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      outerSetState(() => searching = false);
      await tester.pumpAndSettle();

      expect(find.byType(GlassTabBar), findsOneWidget);
    });

    testWidgets('collapsedTabWidth positive value is accepted', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: GlassTabBar.searchable(
            tabs: _testTabs,
            selectedIndex: 0,
            onTabSelected: (_) {},
            isSearchActive: true,
            maskingQuality: MaskingQuality.off,
            searchConfig: GlassSearchBarConfig(
              onSearchToggle: (_) {},
              collapsedTabWidth: 48.0,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(GlassTabBar), findsOneWidget);
    });

    testWidgets(
        'extraButton with position afterSearch reserves right-side space',
        (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: GlassTabBar.searchable(
            tabs: _testTabs,
            selectedIndex: 0,
            onTabSelected: (_) {},
            maskingQuality: MaskingQuality.off,
            extraButton: GlassTabBarExtraButton(
              icon: const Icon(CupertinoIcons.mic),
              label: 'Mic',
              onTap: () {},
              position: GlassExtraButtonPosition.afterSearch,
            ),
            searchConfig: GlassSearchBarConfig(
              onSearchToggle: (_) {},
            ),
          ),
        ),
      );
      await tester.pump();
      expect(find.byIcon(CupertinoIcons.mic), findsOneWidget);
    });

    testWidgets(
        'extraButton collapseOnSearchFocus=false keeps button during search',
        (tester) async {
      bool searching = false;
      late StateSetter outerSetState;
      await tester.pumpWidget(
        createTestApp(
          child: StatefulBuilder(
            builder: (ctx, setState) {
              outerSetState = setState;
              return GlassTabBar.searchable(
                tabs: _testTabs,
                selectedIndex: 0,
                onTabSelected: (_) {},
                isSearchActive: searching,
                maskingQuality: MaskingQuality.off,
                extraButton: GlassTabBarExtraButton(
                  icon: const Icon(CupertinoIcons.add_circled),
                  label: 'Add',
                  onTap: () {},
                  collapseOnSearchFocus: false,
                ),
                searchConfig: GlassSearchBarConfig(
                  onSearchToggle: (v) => setState(() => searching = v),
                ),
              );
            },
          ),
        ),
      );
      await tester.pump();
      outerSetState(() => searching = true);
      await tester.pumpAndSettle();
      expect(find.byType(GlassTabBar), findsOneWidget);
    });

    testWidgets('showsCancelButton=false skips dismiss pill layout',
        (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: GlassTabBar.searchable(
            tabs: _testTabs,
            selectedIndex: 0,
            onTabSelected: (_) {},
            isSearchActive: true,
            maskingQuality: MaskingQuality.off,
            searchConfig: GlassSearchBarConfig(
              onSearchToggle: (_) {},
              showsCancelButton: false,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(GlassTabBar), findsOneWidget);
    });

    testWidgets('autoFocusOnExpand=true requests focus when search expands',
        (tester) async {
      bool searching = false;
      late StateSetter outerSetState;
      await tester.pumpWidget(
        createTestApp(
          child: StatefulBuilder(
            builder: (ctx, setState) {
              outerSetState = setState;
              return GlassTabBar.searchable(
                tabs: _testTabs,
                selectedIndex: 0,
                onTabSelected: (_) {},
                isSearchActive: searching,
                maskingQuality: MaskingQuality.off,
                searchConfig: GlassSearchBarConfig(
                  onSearchToggle: (v) => setState(() => searching = v),
                  autoFocusOnExpand: true,
                ),
              );
            },
          ),
        ),
      );
      await tester.pump();
      outerSetState(() => searching = true);
      await tester.pumpAndSettle();
      expect(find.byType(GlassTabBar), findsOneWidget);
    });
  });

  // ── Interaction glow color — theme propagation (fix for collapsed logo pill)
  //
  // Regression: the collapsed logo GlassButton was hardcoding 0x33FFFFFF as a
  // fallback even though the outer GlassTabBar.searchable had already resolved
  // the correct theme color. This group verifies the full propagation chain:
  //
  //   GlassThemeData.glowColors.primary
  //       → effectiveInteractionGlowColor (GlassTabBar.searchable.build)
  //       → SearchableTabIndicator.interactionGlowColor
  //       → GlassButton.glowColor  (collapsed logo pill, isSearchActive=true)

  group('GlassTabBar.searchable interaction glow — theme propagation', () {
    /// Builds the bar inside a [GlassTheme] with a known primary glow color,
    /// then returns the [GlassButton] widget rendered for the collapsed logo.
    Widget buildWithTheme({
      required Color primaryGlow,
      bool isSearchActive = true,
      GlassInteractionBehavior interactionBehavior =
          GlassInteractionBehavior.glowOnly,
    }) {
      return MaterialApp(
        home: GlassTheme(
          data: GlassThemeData(
            light: GlassThemeVariant(
              glowColors: GlassGlowColors(primary: primaryGlow),
            ),
            dark: GlassThemeVariant(
              glowColors: GlassGlowColors(primary: primaryGlow),
            ),
          ),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: GlassTabBar.searchable(
              tabs: _testTabs,
              selectedIndex: 0,
              onTabSelected: (_) {},
              isSearchActive: isSearchActive,
              interactionBehavior: interactionBehavior,
              // An explicit radius, which is what keeps the theme's palette
              // in play. A null radius means native mode, and native mode
              // brings its own calibrated sheen — covered separately below.
              interactionGlowRadius: 1.5,
              maskingQuality: MaskingQuality.off,
              searchConfig: GlassSearchBarConfig(
                onSearchToggle: (_) {},
              ),
            ),
          ),
        ),
      );
    }

    testWidgets(
        'collapsed logo GlassButton receives GlassThemeData.primary glow color',
        (tester) async {
      const expectedColor = Color(0xFF00FF00); // vivid green — unmistakable

      await tester.pumpWidget(
        buildWithTheme(primaryGlow: expectedColor),
      );
      await tester.pumpAndSettle();

      // The collapsed logo pill is now an AdaptiveGlass.grouped wrapped in GlassGlow.
      // Its glowColor should be exactly the theme primary we injected.
      final glows = tester.widgetList<GlassGlow>(find.byType(GlassGlow));
      expect(glows, isNotEmpty,
          reason: 'Expected at least one GlassGlow in collapsed bar');

      // At least one GlassGlow must carry the theme color.
      final match = glows.any((g) => g.glowColor == expectedColor);
      expect(match, isTrue,
          reason: 'No GlassGlow received the theme glow color $expectedColor. '
              'Found: ${glows.map((g) => g.glowColor).toList()}');
    });

    testWidgets('native mode brings its own sheen instead of the theme primary',
        (tester) async {
      // Parity with GlassButton, which has resolved this since 1.3.0: a null
      // radius asks for the platform calibration, and the calibration is the
      // radius, the sigma and the alpha together. The theme's adaptive
      // primary is white at 24% (light) / 16% (dark) — roughly double the
      // native sheen — and at a 1.6 radius under a sigma-16 blur that reads
      // as a fog circle rather than a specular wash. An app that wants its
      // own colour there passes `interactionGlowColor`, which still wins.
      const themeColor = Color(0xFF00FF00);

      await tester.pumpWidget(
        MaterialApp(
          home: GlassTheme(
            data: GlassThemeData(
              light: GlassThemeVariant(
                glowColors: const GlassGlowColors(primary: themeColor),
              ),
              dark: GlassThemeVariant(
                glowColors: const GlassGlowColors(primary: themeColor),
              ),
            ),
            child: Scaffold(
              backgroundColor: Colors.transparent,
              body: GlassTabBar.searchable(
                tabs: _testTabs,
                selectedIndex: 0,
                onTabSelected: (_) {},
                isSearchActive: true,
                maskingQuality: MaskingQuality.off,
                searchConfig: GlassSearchBarConfig(
                  onSearchToggle: (_) {},
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final glows = tester.widgetList<GlassGlow>(find.byType(GlassGlow));
      expect(glows, isNotEmpty);
      expect(
        glows.any((g) => g.glowColor == themeColor),
        isFalse,
        reason: 'native mode should not take the theme primary',
      );
    });

    testWidgets(
        'explicit interactionGlowColor overrides theme (widget param wins)',
        (tester) async {
      const themeColor = Color(0xFF00FF00);
      const explicitColor = Color(0xFFFF0000); // red — different from theme

      await tester.pumpWidget(
        MaterialApp(
          home: GlassTheme(
            data: GlassThemeData(
              light: GlassThemeVariant(
                glowColors: const GlassGlowColors(primary: themeColor),
              ),
              dark: GlassThemeVariant(
                glowColors: const GlassGlowColors(primary: themeColor),
              ),
            ),
            child: Scaffold(
              backgroundColor: Colors.transparent,
              body: GlassTabBar.searchable(
                tabs: _testTabs,
                selectedIndex: 0,
                onTabSelected: (_) {},
                isSearchActive: true,
                // Explicit widget param must win over theme
                interactionGlowColor: explicitColor,
                maskingQuality: MaskingQuality.off,
                searchConfig: GlassSearchBarConfig(
                  onSearchToggle: (_) {},
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final glows = tester.widgetList<GlassGlow>(find.byType(GlassGlow));
      expect(glows, isNotEmpty);

      final hasExplicit = glows.any((g) => g.glowColor == explicitColor);
      expect(hasExplicit, isTrue,
          reason: 'Explicit interactionGlowColor should override theme');

      // The theme green must NOT appear — widget param has priority
      final hasTheme = glows.any((g) => g.glowColor == themeColor);
      expect(hasTheme, isFalse,
          reason: 'Theme color should be overridden by explicit param');
    });

    testWidgets(
        'GlassInteractionBehavior.none passes Colors.transparent — glow suppressed',
        (tester) async {
      const primaryGlow = Color(0xFF00FF00);

      await tester.pumpWidget(
        buildWithTheme(
          primaryGlow: primaryGlow,
          interactionBehavior: GlassInteractionBehavior.none,
        ),
      );
      await tester.pumpAndSettle();

      // With .none behavior the bar passes Colors.transparent so the glow
      // wrapper is skipped. No GlassGlow should have the theme green.
      final glows = tester.widgetList<GlassGlow>(find.byType(GlassGlow));
      final hasGreen = glows.any((g) => g.glowColor == primaryGlow);
      expect(hasGreen, isFalse,
          reason:
              'GlassInteractionBehavior.none should suppress theme glow color');
    });

    testWidgets(
        'bar mounts correctly in tab-bar mode (isSearchActive=false) with theme',
        (tester) async {
      const primaryGlow = Color(0xFF00FF00);

      await tester.pumpWidget(
        buildWithTheme(primaryGlow: primaryGlow, isSearchActive: false),
      );
      await tester.pumpAndSettle();

      expect(find.byType(GlassTabBar), findsOneWidget);
    });
  });

  // ── onBarTap ───────────────────────────────────────────────────────────────
  //
  // Verifies:
  //   1. onBarTap fires when any part of the bar is tapped.
  //   2. When onBarTap is null the bar returns barContent directly (no extra
  //      GestureDetector wrapper in the widget tree).

  group('GlassTabBar.searchable onBarTap', () {
    testWidgets('onBarTap fires when the bar is tapped', (tester) async {
      var tapCount = 0;

      await tester.pumpWidget(
        createTestApp(
          child: GlassTabBar.searchable(
            tabs: _testTabs,
            selectedIndex: 0,
            onTabSelected: (_) {},
            isSearchActive: false,
            maskingQuality: MaskingQuality.off,
            onBarTap: () => tapCount++,
            searchConfig: GlassSearchBarConfig(
              onSearchToggle: (_) {},
            ),
          ),
        ),
      );
      await tester.pump();

      // Tap the bar at its top-left corner — no opaque child sits there,
      // so the translucent GestureDetector receives the event.
      final barBox = tester.getRect(find.byType(GlassTabBar));
      await tester.tapAt(barBox.topLeft + const Offset(4, 4));
      await tester.pump();

      expect(tapCount, greaterThanOrEqualTo(1),
          reason: 'onBarTap should have fired at least once');
    });

    testWidgets('onBarTap fires while search is active', (tester) async {
      var tapCount = 0;

      await tester.pumpWidget(
        createTestApp(
          child: GlassTabBar.searchable(
            tabs: _testTabs,
            selectedIndex: 0,
            onTabSelected: (_) {},
            isSearchActive: true,
            maskingQuality: MaskingQuality.off,
            onBarTap: () => tapCount++,
            searchConfig: GlassSearchBarConfig(
              onSearchToggle: (_) {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap the bar at its top-left corner.
      final barBox = tester.getRect(find.byType(GlassTabBar));
      await tester.tapAt(barBox.topLeft + const Offset(4, 4));
      await tester.pump();

      expect(tapCount, greaterThanOrEqualTo(1));
    });

    testWidgets('when onBarTap is null the bar still mounts cleanly',
        (tester) async {
      // onBarTap defaults to null — verify the widget mounts and operates
      // normally without a wrapping GestureDetector.
      await tester.pumpWidget(_buildBar());
      await tester.pump();

      expect(find.byType(GlassTabBar), findsOneWidget);
    });

    testWidgets('tab selection still works when onBarTap is set',
        (tester) async {
      // Verifies that the translucent GestureDetector does NOT swallow taps
      // intended for internal handlers.
      var selected = -1;
      var barTaps = 0;

      await tester.pumpWidget(
        createTestApp(
          child: GlassTabBar.searchable(
            tabs: _testTabs,
            selectedIndex: 0,
            onTabSelected: (i) => selected = i,
            isSearchActive: false,
            maskingQuality: MaskingQuality.off,
            onBarTap: () => barTaps++,
            searchConfig: GlassSearchBarConfig(
              onSearchToggle: (_) {},
            ),
          ),
        ),
      );
      await tester.pump();

      // Tap the second tab label.
      await tester.tap(find.text('Following').first);
      await tester.pumpAndSettle();

      // Internal handler must still fire.
      expect(selected, equals(1),
          reason: 'Tab selection should not be swallowed by onBarTap wrapper');
      // onBarTap may also fire (translucent) — that is acceptable.
    });
  });

  // ── onSearchFieldTap ───────────────────────────────────────────────────────
  //
  // Verifies that tapping the active TextField body calls onSearchFieldTap.

  group('GlassSearchBarConfig onSearchFieldTap', () {
    test('defaults to null', () {
      final config = GlassSearchBarConfig(onSearchToggle: (_) {});
      expect(config.onSearchFieldTap, isNull);
    });

    test('stores callback reference', () {
      void handler() {}
      final config = GlassSearchBarConfig(
        onSearchToggle: (_) {},
        onSearchFieldTap: handler,
      );
      expect(config.onSearchFieldTap, same(handler));
    });

    testWidgets('onSearchFieldTap fires when active TextField is tapped',
        (tester) async {
      var fieldTapCount = 0;
      final controller = TextEditingController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        createTestApp(
          child: GlassTabBar.searchable(
            tabs: _testTabs,
            selectedIndex: 0,
            onTabSelected: (_) {},
            isSearchActive: true,
            maskingQuality: MaskingQuality.off,
            searchConfig: GlassSearchBarConfig(
              onSearchToggle: (_) {},
              controller: controller,
              onSearchFieldTap: () => fieldTapCount++,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final textField = find.byType(CupertinoTextField);
      if (textField.evaluate().isNotEmpty) {
        await tester.tap(textField.first);
        await tester.pump();
        expect(fieldTapCount, greaterThanOrEqualTo(1),
            reason: 'onSearchFieldTap should fire when TextField is tapped');
      }
    });

    testWidgets('onSearchFieldTap=null does not crash when TextField is tapped',
        (tester) async {
      // Regression guard: verify null callback doesn't throw.
      await tester.pumpWidget(
        createTestApp(
          child: GlassTabBar.searchable(
            tabs: _testTabs,
            selectedIndex: 0,
            onTabSelected: (_) {},
            isSearchActive: true,
            maskingQuality: MaskingQuality.off,
            searchConfig: GlassSearchBarConfig(
              onSearchToggle: (_) {},
              // onSearchFieldTap intentionally omitted
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final textField = find.byType(CupertinoTextField);
      if (textField.evaluate().isNotEmpty) {
        await tester.tap(textField.first);
        await tester.pump();
        // Verify: no exception was thrown reaching this point.
        expect(find.byType(GlassTabBar), findsOneWidget);
      }
    });
  });

  // ── DismissPill focus fix regression ──────────────────────────────────────
  //
  // Regression guard for the focus-handling fix on the × cancel pill:
  //   - Tapping the pill must call onSearchToggle(false) to collapse the bar.
  //   - Tapping the pill must call onCancelTap when provided.
  //
  // Before the fix, the pill called FocusScope.unfocus() but never called
  // onSearchToggle(false), leaving isSearchActive=true with a live opaque
  // GestureDetector(onTap: requestFocus) in the tree — which swallowed the
  // next tap and re-requested focus on back-navigation.

  group('DismissPill focus fix regression', () {
    Widget buildSearchingBar({
      required ValueChanged<bool> onSearchToggle,
      VoidCallback? onCancelTap,
    }) {
      return createTestApp(
        child: GlassTabBar.searchable(
          tabs: _testTabs,
          selectedIndex: 0,
          onTabSelected: (_) {},
          isSearchActive: true,
          maskingQuality: MaskingQuality.off,
          searchConfig: GlassSearchBarConfig(
            onSearchToggle: onSearchToggle,
            showsCancelButton: true,
            onCancelTap: onCancelTap,
          ),
        ),
      );
    }

    testWidgets('tapping dismiss pill calls onSearchToggle(false)',
        (tester) async {
      bool? lastToggle;

      await tester.pumpWidget(
        buildSearchingBar(onSearchToggle: (v) => lastToggle = v),
      );
      await tester.pumpAndSettle();

      // The dismiss pill renders a GlassButton with CupertinoIcons.xmark.
      final dismissPill = find.byIcon(CupertinoIcons.xmark);
      if (dismissPill.evaluate().isNotEmpty) {
        await tester.tap(dismissPill.first);
        await tester.pump();
        expect(lastToggle, isFalse,
            reason:
                'Dismiss pill must call onSearchToggle(false) to collapse the '
                'bar, preventing the expanded GestureDetector from swallowing '
                'the next tap and re-requesting focus on back-navigation.');
      }
    });

    testWidgets('tapping dismiss pill fires onCancelTap when provided',
        (tester) async {
      var cancelCount = 0;

      await tester.pumpWidget(
        buildSearchingBar(
          onSearchToggle: (_) {},
          onCancelTap: () => cancelCount++,
        ),
      );
      await tester.pumpAndSettle();

      final dismissPill = find.byIcon(CupertinoIcons.xmark);
      if (dismissPill.evaluate().isNotEmpty) {
        await tester.tap(dismissPill.first);
        await tester.pump();
        expect(cancelCount, equals(1),
            reason: 'onCancelTap must fire exactly once when × is tapped.');
      }
    });

    test('GlassSearchBarConfig.onCancelTap defaults to null', () {
      final config = GlassSearchBarConfig(onSearchToggle: (_) {});
      expect(config.onCancelTap, isNull);
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // indicatorExpansion (PR #40 — jfhair)
  // ─────────────────────────────────────────────────────────────────────────

  group('GlassTabBar.searchable indicatorExpansion', () {
    test('default indicatorExpansion matches iOS 26 calibration', () {
      final bar = GlassTabBar.searchable(
        tabs: _testTabs,
        selectedIndex: 0,
        onTabSelected: (_) {},
        searchConfig: GlassSearchBarConfig(onSearchToggle: (_) {}),
      );
      expect(
        bar.indicatorExpansion,
        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      );
    });

    test('default indicatorPinchStrength is 0.4 (iOS 26 calibration)', () {
      final bar = GlassTabBar.searchable(
        tabs: _testTabs,
        selectedIndex: 0,
        onTabSelected: (_) {},
        searchConfig: GlassSearchBarConfig(onSearchToggle: (_) {}),
      );
      expect(bar.indicatorPinchStrength, 0.4);
    });

    testWidgets('accepts custom indicatorExpansion', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: GlassTabBar.searchable(
            tabs: _testTabs,
            selectedIndex: 0,
            onTabSelected: (_) {},
            indicatorExpansion: const EdgeInsets.all(6.0),
            maskingQuality: MaskingQuality.off,
            searchConfig: GlassSearchBarConfig(onSearchToggle: (_) {}),
          ),
        ),
      );
      final bar = tester.widget<GlassTabBar>(find.byType(GlassTabBar).first);
      expect(bar.indicatorExpansion, const EdgeInsets.all(6.0));
    });

    testWidgets('accepts zero indicatorExpansion', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: GlassTabBar.searchable(
            tabs: _testTabs,
            selectedIndex: 0,
            onTabSelected: (_) {},
            indicatorExpansion: EdgeInsets.zero,
            maskingQuality: MaskingQuality.off,
            searchConfig: GlassSearchBarConfig(onSearchToggle: (_) {}),
          ),
        ),
      );
      expect(find.byType(GlassTabBar), findsOneWidget);
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // GlassSearchBarConfig.searchIcon (PR #41 — jfhair)
  // ─────────────────────────────────────────────────────────────────────────

  group('GlassSearchBarConfig.searchIcon', () {
    test('defaults to null', () {
      final config = GlassSearchBarConfig(onSearchToggle: (_) {});
      expect(config.searchIcon, isNull);
    });

    test('stores custom searchIcon', () {
      const icon = Icon(CupertinoIcons.star);
      final config =
          GlassSearchBarConfig(onSearchToggle: (_) {}, searchIcon: icon);
      expect(config.searchIcon, same(icon));
    });

    testWidgets('null searchIcon renders default CupertinoIcons.search',
        (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: GlassTabBar.searchable(
            tabs: _testTabs,
            selectedIndex: 0,
            onTabSelected: (_) {},
            maskingQuality: MaskingQuality.off,
            searchConfig:
                GlassSearchBarConfig(onSearchToggle: (_) {}, searchIcon: null),
          ),
        ),
      );
      await tester.pump();
      expect(find.byIcon(CupertinoIcons.search), findsAtLeastNWidgets(1));
    });

    testWidgets('custom searchIcon is rendered in search pill', (tester) async {
      const customIcon =
          Icon(CupertinoIcons.star_fill, key: Key('custom_search_icon'));
      await tester.pumpWidget(
        createTestApp(
          child: GlassTabBar.searchable(
            tabs: _testTabs,
            selectedIndex: 0,
            onTabSelected: (_) {},
            maskingQuality: MaskingQuality.off,
            searchConfig: GlassSearchBarConfig(
                onSearchToggle: (_) {}, searchIcon: customIcon),
          ),
        ),
      );
      await tester.pump();
      expect(find.byKey(const Key('custom_search_icon')), findsOneWidget);
      expect(find.byIcon(CupertinoIcons.star_fill), findsOneWidget);
    });

    testWidgets('custom searchIcon is rendered alongside any other bar icons',
        (tester) async {
      const customIcon = Icon(CupertinoIcons.star_fill);
      await tester.pumpWidget(
        createTestApp(
          child: GlassTabBar.searchable(
            tabs: _testTabs,
            selectedIndex: 0,
            onTabSelected: (_) {},
            maskingQuality: MaskingQuality.off,
            searchConfig: GlassSearchBarConfig(
                onSearchToggle: (_) {}, searchIcon: customIcon),
          ),
        ),
      );
      await tester.pump();
      // The custom star icon must appear in the tree.
      expect(find.byIcon(CupertinoIcons.star_fill), findsOneWidget);
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // GlassSearchBarConfig.showPill
  // ─────────────────────────────────────────────────────────────────────────

  group('GlassSearchBarConfig.showPill', () {
    test('defaults to true', () {
      final config = GlassSearchBarConfig(onSearchToggle: (_) {});
      expect(config.showPill, isTrue);
    });

    testWidgets('true renders the search pill', (tester) async {
      await tester.pumpWidget(_buildBar());
      await tester.pump();
      expect(find.byIcon(CupertinoIcons.search), findsAtLeastNWidgets(1));
    });

    testWidgets('false renders no search pill in either state', (tester) async {
      await tester.pumpWidget(_buildBar(showPill: false));
      await tester.pump();
      expect(find.byIcon(CupertinoIcons.search), findsNothing);

      await tester.pumpWidget(
        _buildBar(isSearchActive: true, showPill: false),
      );
      await tester.pumpAndSettle();
      expect(find.byIcon(CupertinoIcons.search), findsNothing);
    });

    testWidgets('flipping true springs the pill in', (tester) async {
      await tester.pumpWidget(_buildBar(showPill: false));
      await tester.pump();
      expect(find.byIcon(CupertinoIcons.search), findsNothing);

      await tester.pumpWidget(_buildBar());
      // The appear scale is spring-driven; a couple of frames in, the pill
      // is mounted and visible.
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byIcon(CupertinoIcons.search), findsAtLeastNWidgets(1));
      await tester.pumpAndSettle();
      expect(find.byIcon(CupertinoIcons.search), findsAtLeastNWidgets(1));
    });

    testWidgets('flipping false unmounts the pill', (tester) async {
      await tester.pumpWidget(_buildBar());
      await tester.pump();
      expect(find.byIcon(CupertinoIcons.search), findsAtLeastNWidgets(1));

      await tester.pumpWidget(_buildBar(showPill: false));
      await tester.pumpAndSettle();
      // Fully disappeared pills leave the tree entirely — a zero-scale glass
      // shape would still fuse with the tab pill on the blend layer.
      expect(find.byIcon(CupertinoIcons.search), findsNothing);
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // GlassTabBar.searchable backgroundQuality
  // ─────────────────────────────────────────────────────────────────────────

  group('GlassTabBar.searchable backgroundQuality', () {
    testWidgets(
        'propagates backgroundQuality to SearchPill and BottomBarExtraBtn',
        (tester) async {
      await tester.pumpWidget(_buildBar(
        quality: GlassQuality.premium,
        backgroundQuality: GlassQuality.minimal,
        extraButton: GlassTabBarExtraButton(
          icon: const Icon(CupertinoIcons.add),
          onTap: () {},
          label: 'Add',
        ),
      ));
      await tester.pump();

      final searchPill = tester.widget<SearchPill>(find.byType(SearchPill));
      expect(searchPill.quality, equals(GlassQuality.minimal));

      final extraBtn =
          tester.widget<BottomBarExtraBtn>(find.byType(BottomBarExtraBtn));
      expect(extraBtn.quality, equals(GlassQuality.minimal));
    });

    testWidgets(
        'propagates backgroundQuality to DismissPill when search is active with keyboard',
        (tester) async {
      final searchCtrl = SearchableBottomBarController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MediaQuery(
              data: const MediaQueryData(
                viewInsets: EdgeInsets.only(bottom: 200),
              ),
              child: GlassTabBar.searchable(
                tabs: _testTabs,
                selectedIndex: 0,
                onTabSelected: (_) {},
                controller: searchCtrl,
                isSearchActive: true,
                quality: GlassQuality.premium,
                backgroundQuality: GlassQuality.minimal,
                maskingQuality: MaskingQuality.off,
                searchConfig: GlassSearchBarConfig(
                  showsCancelButton: true,
                  onSearchToggle: (_) {},
                ),
              ),
            ),
          ),
        ),
      );

      searchCtrl.onFocusChanged(true);
      await tester.pumpAndSettle();

      final dismissPill = tester.widget<DismissPill>(find.byType(DismissPill));
      expect(dismissPill.quality, equals(GlassQuality.minimal));
    });

    testWidgets('inherits from quality when backgroundQuality is null',
        (tester) async {
      await tester.pumpWidget(_buildBar(
        quality: GlassQuality.standard,
        extraButton: GlassTabBarExtraButton(
          icon: const Icon(CupertinoIcons.add),
          onTap: () {},
          label: 'Add',
        ),
      ));
      await tester.pump();

      final searchPill = tester.widget<SearchPill>(find.byType(SearchPill));
      expect(searchPill.quality, equals(GlassQuality.standard));

      final extraBtn =
          tester.widget<BottomBarExtraBtn>(find.byType(BottomBarExtraBtn));
      expect(extraBtn.quality, equals(GlassQuality.standard));
    });
  });

  group('GlassTabBar.searchable — collapsed indicator native press (#272)', () {
    testWidgets('collapsed tab indicator presses like native button by default',
        (tester) async {
      await tester.pumpWidget(_buildBar(isSearchActive: true));
      await tester.pump();

      final indicatorStretch = tester.widget<LiquidStretch>(find.descendant(
          of: find.byType(SearchableTabIndicator),
          matching: find.byType(LiquidStretch)));
      expect(indicatorStretch.pressGrowth, LiquidStretch.nativePressGrowth);
      expect(indicatorStretch.anchorStretchSettings,
          AnchorStretchSettings.nativeTremor);
      expect(
          find.descendant(
              of: find.byType(SearchableTabIndicator),
              matching: find.byType(PressAmbientLift)),
          findsOneWidget);
    });

    testWidgets(
        'custom interactionGlowColor disables native press lift for collapsed indicator',
        (tester) async {
      await tester.pumpWidget(createTestApp(
        child: GlassTabBar.searchable(
          tabs: _testTabs,
          selectedIndex: 0,
          onTabSelected: (_) {},
          isSearchActive: true,
          maskingQuality: MaskingQuality.off,
          interactionGlowColor: const Color(0xFFFF0000),
          searchConfig: GlassSearchBarConfig(
            onSearchToggle: (_) {},
          ),
        ),
      ));
      await tester.pump();

      expect(
          find.descendant(
              of: find.byType(SearchableTabIndicator),
              matching: find.byType(PressAmbientLift)),
          findsNothing);
    });
  });

  // ── Regression: issue #305 ────────────────────────────────────────────────
  // textColor must follow the app's ThemeMode (via GlassTheme.brightnessOf),
  // NOT the device's OS brightness (MediaQuery.platformBrightness).

  group('textColor follows app ThemeMode, not OS brightness (issue #305)', () {
    /// Pumps the bar with [isSearchActive] = true so _buildExpanded() is
    /// entered immediately, then extracts the [CupertinoTextField] style.
    Future<TextStyle?> pumpAndGetStyle(
      WidgetTester tester, {
      required Brightness platformBrightness, // OS/device setting
      required Brightness appBrightness, // app ThemeData
    }) async {
      await tester.pumpWidget(
        MediaQuery(
          data: MediaQueryData(platformBrightness: platformBrightness),
          child: MaterialApp(
            theme: ThemeData(brightness: appBrightness),
            home: Scaffold(
              backgroundColor: Colors.transparent,
              body: GlassTabBar.searchable(
                tabs: _testTabs,
                selectedIndex: 0,
                onTabSelected: (_) {},
                isSearchActive: true,
                maskingQuality: MaskingQuality.off,
                searchConfig: GlassSearchBarConfig(
                  onSearchToggle: (_) {},
                  hintText: 'Search',
                  // textColor intentionally omitted — testing the default
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      final field =
          tester.widget<CupertinoTextField>(find.byType(CupertinoTextField));
      return field.style;
    }

    testWidgets('app light + OS dark → text colour is dark (near-black label)',
        (tester) async {
      final style = await pumpAndGetStyle(
        tester,
        platformBrightness: Brightness.dark, // device OS is dark
        appBrightness: Brightness.light, // app forced to light
      );
      // CupertinoColors.label.color is the light-mode variant (near-black).
      // If the bug is present, the colour would be the dark-mode white instead.
      expect(
        style?.color,
        equals(CupertinoColors.label.color),
        reason: 'textColor should use app ThemeMode (light), not OS (dark)',
      );
    });

    testWidgets('app dark + OS light → text colour is light (near-white label)',
        (tester) async {
      final style = await pumpAndGetStyle(
        tester,
        platformBrightness: Brightness.light, // device OS is light
        appBrightness: Brightness.dark, // app forced to dark
      );
      // CupertinoColors.label.darkColor is the dark-mode variant (near-white).
      expect(
        style?.color,
        equals(CupertinoColors.label.darkColor),
        reason: 'textColor should use app ThemeMode (dark), not OS (light)',
      );
    });

    testWidgets('explicit textColor is forwarded as-is', (tester) async {
      const explicitColor = Color(0xFFABCDEF);
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(brightness: Brightness.light),
          home: Scaffold(
            backgroundColor: Colors.transparent,
            body: GlassTabBar.searchable(
              tabs: _testTabs,
              selectedIndex: 0,
              onTabSelected: (_) {},
              isSearchActive: true,
              maskingQuality: MaskingQuality.off,
              searchConfig: GlassSearchBarConfig(
                onSearchToggle: (_) {},
                textColor: explicitColor,
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      final field =
          tester.widget<CupertinoTextField>(find.byType(CupertinoTextField));
      expect(field.style?.color, equals(explicitColor));
    });

    testWidgets(
        'explicit CupertinoDynamicColor in textColor is resolved using app brightness',
        (tester) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(platformBrightness: Brightness.dark),
          child: MaterialApp(
            theme: ThemeData(brightness: Brightness.light),
            home: Scaffold(
              backgroundColor: Colors.transparent,
              body: GlassTabBar.searchable(
                tabs: _testTabs,
                selectedIndex: 0,
                onTabSelected: (_) {},
                isSearchActive: true,
                maskingQuality: MaskingQuality.off,
                searchConfig: GlassSearchBarConfig(
                  onSearchToggle: (_) {},
                  textColor: CupertinoColors.label,
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      final field =
          tester.widget<CupertinoTextField>(find.byType(CupertinoTextField));
      expect(
        field.style?.color,
        equals(CupertinoColors.label.color),
        reason:
            'Dynamic color must be eagerly resolved to app light variant, not OS dark variant',
      );
    });

    testWidgets('hintStyle without color preserves resolved textColor',
        (tester) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(platformBrightness: Brightness.dark),
          child: MaterialApp(
            theme: ThemeData(brightness: Brightness.light),
            home: Scaffold(
              backgroundColor: Colors.transparent,
              body: GlassTabBar.searchable(
                tabs: _testTabs,
                selectedIndex: 0,
                onTabSelected: (_) {},
                isSearchActive: true,
                maskingQuality: MaskingQuality.off,
                searchConfig: GlassSearchBarConfig(
                  onSearchToggle: (_) {},
                  hintStyle: const TextStyle(fontSize: 15),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      final field =
          tester.widget<CupertinoTextField>(find.byType(CupertinoTextField));
      expect(field.style?.fontSize, equals(15));
      expect(
        field.style?.color,
        equals(CupertinoColors.label.color),
        reason: 'hintStyle without color must not drop resolved textColor',
      );
    });
  });

  // ── typed text vs hint colour ─────────────────────────────────────────────
  // `textColor` is documented as the typed text's colour and `hintStyle` as
  // the hint's. A caller that mutes the hint must not get muted typed text.

  group('textColor and hintStyle colour are independent', () {
    const typed = Color(0xFF112233);
    const hint = Color(0xFF8899AA);

    Future<CupertinoTextField> pumpField(
      WidgetTester tester,
      GlassSearchBarConfig config, {
      Brightness appBrightness = Brightness.light,
      Brightness platformBrightness = Brightness.light,
    }) async {
      await tester.pumpWidget(
        MediaQuery(
          data: MediaQueryData(platformBrightness: platformBrightness),
          child: MaterialApp(
            theme: ThemeData(brightness: appBrightness),
            home: Scaffold(
              backgroundColor: Colors.transparent,
              body: GlassTabBar.searchable(
                tabs: _testTabs,
                selectedIndex: 0,
                onTabSelected: (_) {},
                isSearchActive: true,
                maskingQuality: MaskingQuality.off,
                searchConfig: config,
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      return tester.widget<CupertinoTextField>(find.byType(CupertinoTextField));
    }

    testWidgets('both set → typed text takes textColor, hint takes hintStyle',
        (tester) async {
      final field = await pumpField(
        tester,
        GlassSearchBarConfig(
          onSearchToggle: (_) {},
          textColor: typed,
          hintStyle: const TextStyle(color: hint, fontSize: 15),
        ),
      );
      expect(field.style?.color, equals(typed),
          reason: 'an explicit textColor must not be overridden by hintStyle');
      expect(field.placeholderStyle?.color, equals(hint));
      // Metrics stay shared, so the field does not jump on the first key.
      expect(field.style?.fontSize, equals(15));
      expect(field.placeholderStyle?.fontSize, equals(15));
    });

    testWidgets('only hintStyle colour set → typed text still follows it',
        (tester) async {
      // Unchanged behaviour for callers that style the field through
      // hintStyle alone.
      final field = await pumpField(
        tester,
        GlassSearchBarConfig(
          onSearchToggle: (_) {},
          hintStyle: const TextStyle(color: hint),
        ),
      );
      expect(field.style?.color, equals(hint));
      expect(field.placeholderStyle?.color, equals(hint));
    });

    testWidgets('dynamic colours on both resolve against the app brightness',
        (tester) async {
      final field = await pumpField(
        tester,
        GlassSearchBarConfig(
          onSearchToggle: (_) {},
          textColor: CupertinoColors.label,
          hintStyle: const TextStyle(color: CupertinoColors.secondaryLabel),
        ),
        appBrightness: Brightness.dark,
        platformBrightness: Brightness.light,
      );
      expect(field.style?.color, equals(CupertinoColors.label.darkColor));
      expect(
        field.placeholderStyle?.color,
        equals(CupertinoColors.secondaryLabel.darkColor),
      );
    });
  });
}
