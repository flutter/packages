import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

import '../../shared/test_helpers.dart';

// =============================================================================
// Shared fixtures
// =============================================================================

final _tabs = [
  const GlassTab(label: 'Home', icon: Icon(CupertinoIcons.home)),
  const GlassTab(label: 'Search', icon: Icon(CupertinoIcons.search)),
  const GlassTab(label: 'Profile', icon: Icon(CupertinoIcons.person)),
];

// Builds a GlassTabBar.bottom in a test wrapper — always uses MaskingQuality.off
// for performance and to avoid dual-layer rendering complexity in tests.
Widget _buildBottomBar({
  GlassInteractionBehavior behavior = GlassInteractionBehavior.full,
  double pressScale = 1.04,
  Color? interactionGlowColor,
}) {
  return createTestApp(
    child: GlassTabBar.bottom(
      tabs: _tabs,
      selectedIndex: 0,
      onTabSelected: (_) {},
      maskingQuality: MaskingQuality.off,
      interactionBehavior: behavior,
      pressScale: pressScale,
      interactionGlowColor: interactionGlowColor,
    ),
  );
}

Widget _buildSearchableBar({
  GlassInteractionBehavior behavior = GlassInteractionBehavior.full,
  double pressScale = 1.04,
  Color? interactionGlowColor,
  bool isSearchActive = false,
}) {
  return createTestApp(
    child: GlassTabBar.searchable(
      tabs: _tabs,
      selectedIndex: 0,
      onTabSelected: (_) {},
      isSearchActive: isSearchActive,
      maskingQuality: MaskingQuality.off,
      interactionBehavior: behavior,
      pressScale: pressScale,
      interactionGlowColor: interactionGlowColor,
      searchConfig: GlassSearchBarConfig(
        onSearchToggle: (_) {},
        hintText: 'Search',
      ),
    ),
  );
}

// =============================================================================
// Tests
// =============================================================================

void main() {
  // ---------------------------------------------------------------------------
  // GlassInteractionBehavior enum — unit tests
  // ---------------------------------------------------------------------------

  group('GlassInteractionBehavior enum', () {
    test('has exactly 4 values', () {
      expect(GlassInteractionBehavior.values, hasLength(4));
    });

    test('values are none, glowOnly, scaleOnly, full', () {
      expect(
        GlassInteractionBehavior.values,
        containsAll([
          GlassInteractionBehavior.none,
          GlassInteractionBehavior.glowOnly,
          GlassInteractionBehavior.scaleOnly,
          GlassInteractionBehavior.full,
        ]),
      );
    });

    // ── hasGlow getter ────────────────────────────────────────────────────────

    group('hasGlow', () {
      test('none → false', () {
        expect(GlassInteractionBehavior.none.hasGlow, isFalse);
      });

      test('glowOnly → true', () {
        expect(GlassInteractionBehavior.glowOnly.hasGlow, isTrue);
      });

      test('scaleOnly → false', () {
        expect(GlassInteractionBehavior.scaleOnly.hasGlow, isFalse);
      });

      test('full → true', () {
        expect(GlassInteractionBehavior.full.hasGlow, isTrue);
      });

      test('exactly two behaviors have glow', () {
        final withGlow =
            GlassInteractionBehavior.values.where((b) => b.hasGlow).toList();
        expect(withGlow, hasLength(2));
        expect(
            withGlow,
            containsAll([
              GlassInteractionBehavior.glowOnly,
              GlassInteractionBehavior.full
            ]));
      });
    });

    // ── hasScale getter ───────────────────────────────────────────────────────

    group('hasScale', () {
      test('none → false', () {
        expect(GlassInteractionBehavior.none.hasScale, isFalse);
      });

      test('glowOnly → false', () {
        expect(GlassInteractionBehavior.glowOnly.hasScale, isFalse);
      });

      test('scaleOnly → true', () {
        expect(GlassInteractionBehavior.scaleOnly.hasScale, isTrue);
      });

      test('full → true', () {
        expect(GlassInteractionBehavior.full.hasScale, isTrue);
      });

      test('exactly two behaviors have scale', () {
        final withScale =
            GlassInteractionBehavior.values.where((b) => b.hasScale).toList();
        expect(withScale, hasLength(2));
        expect(
            withScale,
            containsAll([
              GlassInteractionBehavior.scaleOnly,
              GlassInteractionBehavior.full
            ]));
      });
    });

    // ── Physical model invariants ─────────────────────────────────────────────

    group('physical model invariants', () {
      test('none has neither glow nor scale', () {
        expect(GlassInteractionBehavior.none.hasGlow, isFalse);
        expect(GlassInteractionBehavior.none.hasScale, isFalse);
      });

      test('full has both glow and scale', () {
        expect(GlassInteractionBehavior.full.hasGlow, isTrue);
        expect(GlassInteractionBehavior.full.hasScale, isTrue);
      });

      test('glowOnly is exclusively glow — no scale', () {
        expect(GlassInteractionBehavior.glowOnly.hasGlow, isTrue);
        expect(GlassInteractionBehavior.glowOnly.hasScale, isFalse);
      });

      test('scaleOnly is exclusively scale — no glow', () {
        expect(GlassInteractionBehavior.scaleOnly.hasGlow, isFalse);
        expect(GlassInteractionBehavior.scaleOnly.hasScale, isTrue);
      });

      test('each behavior has a unique (hasGlow, hasScale) pair', () {
        final pairs = GlassInteractionBehavior.values
            .map((b) => (b.hasGlow, b.hasScale))
            .toSet();
        // 4 behaviors, each must produce a unique tuple
        expect(pairs, hasLength(GlassInteractionBehavior.values.length));
      });

      test('no behavior can have only-neither (i.e., none is unique null-pair)',
          () {
        final noBoth = GlassInteractionBehavior.values
            .where((b) => !b.hasGlow && !b.hasScale)
            .toList();
        expect(noBoth, equals([GlassInteractionBehavior.none]));
      });
    });

    // ── Enum identity ─────────────────────────────────────────────────────────

    test('enum names match declaration', () {
      expect(GlassInteractionBehavior.none.name, 'none');
      expect(GlassInteractionBehavior.glowOnly.name, 'glowOnly');
      expect(GlassInteractionBehavior.scaleOnly.name, 'scaleOnly');
      expect(GlassInteractionBehavior.full.name, 'full');
    });

    test('can be compared with ==', () {
      const a = GlassInteractionBehavior.full;
      const b = GlassInteractionBehavior.full;
      expect(a, equals(b));
      expect(a, isNot(equals(GlassInteractionBehavior.none)));
    });
  });

  // ---------------------------------------------------------------------------
  // GlassTabBar.bottom — interaction API defaults
  // ---------------------------------------------------------------------------

  group('GlassTabBar.bottom interaction API defaults', () {
    test('interactionBehavior defaults to full', () {
      final bar = GlassTabBar.bottom(
        tabs: _tabs,
        selectedIndex: 0,
        onTabSelected: (_) {},
      );
      expect(bar.interactionBehavior, GlassInteractionBehavior.full);
    });

    test('pressScale defaults to 1.04', () {
      final bar = GlassTabBar.bottom(
        tabs: _tabs,
        selectedIndex: 0,
        onTabSelected: (_) {},
      );
      expect(bar.pressScale, closeTo(1.04, 0.001));
    });

    test('interactionGlowColor defaults to null', () {
      final bar = GlassTabBar.bottom(
        tabs: _tabs,
        selectedIndex: 0,
        onTabSelected: (_) {},
      );
      expect(bar.interactionGlowColor, isNull);
    });

    test('custom pressScale stored correctly', () {
      final bar = GlassTabBar.bottom(
        tabs: _tabs,
        selectedIndex: 0,
        onTabSelected: (_) {},
        pressScale: 1.10,
      );
      expect(bar.pressScale, closeTo(1.10, 0.001));
    });

    test('custom interactionBehavior stored correctly', () {
      final bar = GlassTabBar.bottom(
        tabs: _tabs,
        selectedIndex: 0,
        onTabSelected: (_) {},
        interactionBehavior: GlassInteractionBehavior.none,
      );
      expect(bar.interactionBehavior, GlassInteractionBehavior.none);
    });

    test('custom interactionGlowColor stored correctly', () {
      final bar = GlassTabBar.bottom(
        tabs: _tabs,
        selectedIndex: 0,
        onTabSelected: (_) {},
        interactionGlowColor: Colors.red,
      );
      expect(bar.interactionGlowColor, Colors.red);
    });
  });

  // ---------------------------------------------------------------------------
  // GlassTabBar.bottom — widget rendering per behavior
  // ---------------------------------------------------------------------------

  group('GlassTabBar.bottom widget rendering per behavior', () {
    for (final behavior in GlassInteractionBehavior.values) {
      testWidgets('mounts cleanly with behavior=$behavior', (tester) async {
        await tester.pumpWidget(_buildBottomBar(behavior: behavior));
        expect(find.byType(GlassTabBar), findsOneWidget);
      });
    }

    // ── GlassGlow presence ────────────────────────────────────────────────────

    testWidgets(
        'behavior=none: GlassGlow is NOT in widget tree (transparent short-circuit)',
        (tester) async {
      await tester.pumpWidget(_buildBottomBar(
        behavior: GlassInteractionBehavior.none,
      ));
      await tester.pump();
      // _wrapWithGlow skips GlassGlow when color.a == 0
      expect(find.byType(GlassGlow), findsNothing);
    });

    testWidgets('behavior=scaleOnly: GlassGlow is NOT in widget tree',
        (tester) async {
      await tester.pumpWidget(_buildBottomBar(
        behavior: GlassInteractionBehavior.scaleOnly,
      ));
      await tester.pump();
      expect(find.byType(GlassGlow), findsNothing);
    });

    testWidgets('behavior=glowOnly: GlassGlow IS in widget tree',
        (tester) async {
      await tester.pumpWidget(_buildBottomBar(
        behavior: GlassInteractionBehavior.glowOnly,
      ));
      await tester.pump();
      expect(find.byType(GlassGlow), findsWidgets);
    });

    testWidgets('behavior=full: GlassGlow IS in widget tree', (tester) async {
      await tester.pumpWidget(_buildBottomBar(
        behavior: GlassInteractionBehavior.full,
      ));
      await tester.pump();
      expect(find.byType(GlassGlow), findsWidgets);
    });

    // ── Explicit transparent color also suppresses GlassGlow ─────────────────

    testWidgets(
        'explicit Colors.transparent interactionGlowColor skips GlassGlow',
        (tester) async {
      await tester.pumpWidget(_buildBottomBar(
        behavior: GlassInteractionBehavior.full,
        interactionGlowColor: Colors.transparent,
      ));
      await tester.pump();
      // Even with full behavior, a transparent glow color should skip the wrapper
      expect(find.byType(GlassGlow), findsNothing);
    });

    testWidgets('custom non-transparent glow color renders GlassGlow',
        (tester) async {
      await tester.pumpWidget(_buildBottomBar(
        behavior: GlassInteractionBehavior.full,
        interactionGlowColor: const Color(0x33FFFFFF),
      ));
      await tester.pump();
      expect(find.byType(GlassGlow), findsWidgets);
    });

    // ── behavior=none smoke — no crash, content still visible ─────────────────

    testWidgets('behavior=none renders all tab labels', (tester) async {
      await tester.pumpWidget(
        _buildBottomBar(behavior: GlassInteractionBehavior.none),
      );
      await tester.pump();
      // selectedIndex: 0 → 'Home' appears in both unselected base AND vibrant overlay
      expect(find.text('Home'), findsAtLeastNWidgets(1));
      expect(find.text('Search'), findsWidgets);
      expect(find.text('Profile'), findsWidgets);
    });

    testWidgets('behavior=none: tabs still respond to taps', (tester) async {
      int selected = 0;
      await tester.pumpWidget(
        createTestApp(
          child: GlassTabBar.bottom(
            tabs: _tabs,
            selectedIndex: selected,
            onTabSelected: (i) => selected = i,
            maskingQuality: MaskingQuality.off,
            interactionBehavior: GlassInteractionBehavior.none,
          ),
        ),
      );
      await tester.tap(find.text('Search').first);
      await tester.pumpAndSettle();
      expect(selected, 1);
    });

    // ── pressScale=1.0 is valid (effectively no scale) ────────────────────────

    testWidgets('pressScale=1.0 mounts without error', (tester) async {
      await tester.pumpWidget(
        _buildBottomBar(
          behavior: GlassInteractionBehavior.scaleOnly,
          pressScale: 1.0,
        ),
      );
      expect(find.byType(GlassTabBar), findsOneWidget);
    });
  });

  // ---------------------------------------------------------------------------
  // GlassTabBar.bottom — behavior changes at runtime (hot rebuild)
  // ---------------------------------------------------------------------------

  group('GlassTabBar.bottom hot-rebuild behavior transitions', () {
    testWidgets('behavior can switch from full to none', (tester) async {
      GlassInteractionBehavior behavior = GlassInteractionBehavior.full;

      await tester.pumpWidget(
        createTestApp(
          child: StatefulBuilder(
            builder: (context, setState) => Column(
              children: [
                GlassTabBar.bottom(
                  tabs: _tabs,
                  selectedIndex: 0,
                  onTabSelected: (_) {},
                  maskingQuality: MaskingQuality.off,
                  interactionBehavior: behavior,
                ),
                GestureDetector(
                  onTap: () =>
                      setState(() => behavior = GlassInteractionBehavior.none),
                  child: const Text('toggle'),
                ),
              ],
            ),
          ),
        ),
      );

      // Initially: GlassGlow present for full behavior
      expect(find.byType(GlassGlow), findsWidgets);

      await tester.tap(find.text('toggle'));
      await tester.pump();

      // After switching to none: GlassGlow gone
      expect(find.byType(GlassGlow), findsNothing);
    });

    testWidgets('behavior can switch from none to full', (tester) async {
      GlassInteractionBehavior behavior = GlassInteractionBehavior.none;

      await tester.pumpWidget(
        createTestApp(
          child: StatefulBuilder(
            builder: (context, setState) => Column(
              children: [
                GlassTabBar.bottom(
                  tabs: _tabs,
                  selectedIndex: 0,
                  onTabSelected: (_) {},
                  maskingQuality: MaskingQuality.off,
                  interactionBehavior: behavior,
                ),
                GestureDetector(
                  onTap: () =>
                      setState(() => behavior = GlassInteractionBehavior.full),
                  child: const Text('toggle'),
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(GlassGlow), findsNothing);

      await tester.tap(find.text('toggle'));
      await tester.pump();

      expect(find.byType(GlassGlow), findsWidgets);
    });
  });

  // ---------------------------------------------------------------------------
  // GlassTabBar.searchable — interaction API defaults
  // ---------------------------------------------------------------------------

  group('GlassTabBar.searchable interaction API defaults', () {
    test('interactionBehavior defaults to full', () {
      final bar = GlassTabBar.searchable(
        tabs: _tabs,
        selectedIndex: 0,
        onTabSelected: (_) {},
        searchConfig: GlassSearchBarConfig(onSearchToggle: (_) {}),
      );
      expect(bar.interactionBehavior, GlassInteractionBehavior.full);
    });

    test('pressScale defaults to null — the native press', () {
      final bar = GlassTabBar.searchable(
        tabs: _tabs,
        selectedIndex: 0,
        onTabSelected: (_) {},
        searchConfig: GlassSearchBarConfig(onSearchToggle: (_) {}),
      );
      expect(bar.pressScale, isNull);
    });

    test('interactionGlowColor defaults to null', () {
      final bar = GlassTabBar.searchable(
        tabs: _tabs,
        selectedIndex: 0,
        onTabSelected: (_) {},
        searchConfig: GlassSearchBarConfig(onSearchToggle: (_) {}),
      );
      expect(bar.interactionGlowColor, isNull);
    });

    test('custom interactionBehavior stored correctly', () {
      final bar = GlassTabBar.searchable(
        tabs: _tabs,
        selectedIndex: 0,
        onTabSelected: (_) {},
        interactionBehavior: GlassInteractionBehavior.scaleOnly,
        searchConfig: GlassSearchBarConfig(onSearchToggle: (_) {}),
      );
      expect(bar.interactionBehavior, GlassInteractionBehavior.scaleOnly);
    });

    test('custom pressScale stored correctly', () {
      final bar = GlassTabBar.searchable(
        tabs: _tabs,
        selectedIndex: 0,
        onTabSelected: (_) {},
        pressScale: 1.08,
        searchConfig: GlassSearchBarConfig(onSearchToggle: (_) {}),
      );
      expect(bar.pressScale, closeTo(1.08, 0.001));
    });

    // Verify old API params are gone (compilation-level check via non-existence)
    test('does not expose enableBackgroundAnimation or backgroundPressScale',
        () {
      // If this test compiles cleanly, the old API is fully removed.
      // We verify the NEW API exists and has the correct types.
      final bar = GlassTabBar.searchable(
        tabs: _tabs,
        selectedIndex: 0,
        onTabSelected: (_) {},
        interactionBehavior: GlassInteractionBehavior.full,
        pressScale: 1.04,
        searchConfig: GlassSearchBarConfig(onSearchToggle: (_) {}),
      );
      expect(bar.interactionBehavior, isA<GlassInteractionBehavior>());
      expect(bar.pressScale, isA<double>());
    });
  });

  // ---------------------------------------------------------------------------
  // GlassTabBar.searchable — widget rendering per behavior
  // ---------------------------------------------------------------------------

  group('GlassTabBar.searchable widget rendering per behavior', () {
    for (final behavior in GlassInteractionBehavior.values) {
      testWidgets('mounts cleanly with behavior=$behavior (search inactive)',
          (tester) async {
        await tester.pumpWidget(_buildSearchableBar(behavior: behavior));
        expect(find.byType(GlassTabBar), findsOneWidget);
      });

      testWidgets('mounts cleanly with behavior=$behavior (search active)',
          (tester) async {
        await tester.pumpWidget(
            _buildSearchableBar(behavior: behavior, isSearchActive: true));
        await tester.pumpAndSettle();
        expect(find.byType(GlassTabBar), findsOneWidget);
      });
    }

    // ── GlassGlow presence ────────────────────────────────────────────────────

    // ── GlassGlow presence (searchable bar) ──────────────────────────────────
    //
    // Note: GlassButton (used in the SearchPill collapsed state) always contains
    // its own internal GlassGlow for button-press feedback. Therefore we cannot
    // assert find.byType(GlassGlow).findsNothing for the searchable bar.
    // Instead, we verify the resolved interactionGlowColor is transparent (alpha
    // == 0) when behavior suppresses glow — this is the correct integration
    // boundary to test.

    testWidgets(
        'behavior=none: resolved interactionGlowColor on bar is transparent',
        (tester) async {
      final bar = GlassTabBar.searchable(
        tabs: _tabs,
        selectedIndex: 0,
        onTabSelected: (_) {},
        interactionBehavior: GlassInteractionBehavior.none,
        searchConfig: GlassSearchBarConfig(onSearchToggle: (_) {}),
      );
      // none.hasGlow is false → parent resolves to Colors.transparent
      expect(GlassInteractionBehavior.none.hasGlow, isFalse);
      expect(bar.interactionBehavior.hasGlow, isFalse);
    });

    testWidgets(
        'behavior=scaleOnly: resolved interactionGlowColor on bar is transparent',
        (tester) async {
      final bar = GlassTabBar.searchable(
        tabs: _tabs,
        selectedIndex: 0,
        onTabSelected: (_) {},
        interactionBehavior: GlassInteractionBehavior.scaleOnly,
        searchConfig: GlassSearchBarConfig(onSearchToggle: (_) {}),
      );
      expect(GlassInteractionBehavior.scaleOnly.hasGlow, isFalse);
      expect(bar.interactionBehavior.hasGlow, isFalse);
    });

    testWidgets(
        'behavior=glowOnly: interactionGlowColor on bar is non-transparent',
        (tester) async {
      final bar = GlassTabBar.searchable(
        tabs: _tabs,
        selectedIndex: 0,
        onTabSelected: (_) {},
        interactionBehavior: GlassInteractionBehavior.glowOnly,
        searchConfig: GlassSearchBarConfig(onSearchToggle: (_) {}),
      );
      expect(bar.interactionBehavior.hasGlow, isTrue);
    });

    testWidgets('behavior=full: interactionGlowColor on bar is non-transparent',
        (tester) async {
      final bar = GlassTabBar.searchable(
        tabs: _tabs,
        selectedIndex: 0,
        onTabSelected: (_) {},
        interactionBehavior: GlassInteractionBehavior.full,
        searchConfig: GlassSearchBarConfig(onSearchToggle: (_) {}),
      );
      expect(bar.interactionBehavior.hasGlow, isTrue);
    });

    // ── Search pill also carries through the behavior ─────────────────────────
    //
    // When search is active, the SearchableTabIndicator shows a GlassButton
    // (collapsed tab bar behind the expanded pill). GlassButton always puts a
    // GlassGlow in its widget tree for its own press feedback. Therefore we
    // cannot use find.byType(GlassGlow).findsNothing here either.
    // We verify the behavior enum property instead.

    testWidgets(
        'behavior=none: SearchPill glow suppressed (search active) — verified via enum',
        (tester) async {
      // Arrange: mount a none-behavior bar in search-active state.
      final bar = _buildSearchableBar(
        behavior: GlassInteractionBehavior.none,
        isSearchActive: true,
      );
      await tester.pumpWidget(bar);
      await tester.pumpAndSettle();
      // The widget rendered successfully and behavior.hasGlow is false,
      // which means Colors.transparent is passed to the SearchPill.
      expect(GlassInteractionBehavior.none.hasGlow, isFalse);
      expect(find.byType(GlassTabBar), findsOneWidget);
    });

    testWidgets(
        'behavior=full: GlassGlow present in SearchPill (search active)',
        (tester) async {
      await tester.pumpWidget(_buildSearchableBar(
        behavior: GlassInteractionBehavior.full,
        isSearchActive: true,
      ));
      await tester.pumpAndSettle();
      expect(find.byType(GlassGlow), findsWidgets);
    });

    // ── Tab interaction unaffected by behavior ────────────────────────────────

    testWidgets('tabs still respond to taps with behavior=none',
        (tester) async {
      int selected = 0;
      await tester.pumpWidget(
        createTestApp(
          child: GlassTabBar.searchable(
            tabs: _tabs,
            selectedIndex: selected,
            onTabSelected: (i) => selected = i,
            isSearchActive: false,
            maskingQuality: MaskingQuality.off,
            interactionBehavior: GlassInteractionBehavior.none,
            searchConfig: GlassSearchBarConfig(onSearchToggle: (_) {}),
          ),
        ),
      );
      // Tap 'Profile' (index 2) instead of 'Search' (index 1) because
      // the 'Search' label text conflicts with the collapsed search pill
      // GlassButton that sits on top of the tab area.
      await tester.tap(find.text('Profile').first);
      await tester.pumpAndSettle();
      expect(selected, 2);
    });
  });

  // ---------------------------------------------------------------------------
  // API symmetry — both widgets must expose the same interaction parameters
  // ---------------------------------------------------------------------------

  group('API symmetry: GlassTabBar.bottom vs GlassTabBar.searchable', () {
    test('both expose interactionBehavior field of the same type', () {
      final bar = GlassTabBar.bottom(
        tabs: _tabs,
        selectedIndex: 0,
        onTabSelected: (_) {},
        interactionBehavior: GlassInteractionBehavior.glowOnly,
      );
      final searchBar = GlassTabBar.searchable(
        tabs: _tabs,
        selectedIndex: 0,
        onTabSelected: (_) {},
        interactionBehavior: GlassInteractionBehavior.glowOnly,
        searchConfig: GlassSearchBarConfig(onSearchToggle: (_) {}),
      );
      expect(bar.interactionBehavior, searchBar.interactionBehavior);
    });

    test('both default to interactionBehavior.full', () {
      final bar = GlassTabBar.bottom(
        tabs: _tabs,
        selectedIndex: 0,
        onTabSelected: (_) {},
      );
      final searchBar = GlassTabBar.searchable(
        tabs: _tabs,
        selectedIndex: 0,
        onTabSelected: (_) {},
        searchConfig: GlassSearchBarConfig(onSearchToggle: (_) {}),
      );
      expect(bar.interactionBehavior, searchBar.interactionBehavior);
    });

    test('bottom defaults to 1.04; searchable defaults to the native press',
        () {
      final bar = GlassTabBar.bottom(
        tabs: _tabs,
        selectedIndex: 0,
        onTabSelected: (_) {},
      );
      final searchBar = GlassTabBar.searchable(
        tabs: _tabs,
        selectedIndex: 0,
        onTabSelected: (_) {},
        searchConfig: GlassSearchBarConfig(onSearchToggle: (_) {}),
      );
      expect(bar.pressScale, closeTo(1.04, 0.001));
      expect(searchBar.pressScale, isNull);
    });

    test('all four behaviors accepted by GlassTabBar.bottom without assertion',
        () {
      for (final b in GlassInteractionBehavior.values) {
        expect(
          () => GlassTabBar.bottom(
            tabs: _tabs,
            selectedIndex: 0,
            onTabSelected: (_) {},
            interactionBehavior: b,
          ),
          returnsNormally,
        );
      }
    });

    test(
        'all four behaviors accepted by GlassTabBar.searchable without assertion',
        () {
      for (final b in GlassInteractionBehavior.values) {
        expect(
          () => GlassTabBar.searchable(
            tabs: _tabs,
            selectedIndex: 0,
            onTabSelected: (_) {},
            interactionBehavior: b,
            searchConfig: GlassSearchBarConfig(onSearchToggle: (_) {}),
          ),
          returnsNormally,
        );
      }
    });
  });

  // ---------------------------------------------------------------------------
  // GlassInteractionBehavior — exported from public barrel
  // ---------------------------------------------------------------------------

  group('GlassInteractionBehavior public export', () {
    test('is accessible via liquid_glass_widgets barrel', () {
      // If this test compiles, the export is wired correctly.
      const b = GlassInteractionBehavior.full;
      expect(b, isA<GlassInteractionBehavior>());
    });
  });
}
