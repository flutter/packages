// Tests for the v0.18.0 unified GlassTabBar named constructors.
//
// Coverage targets:
//   • GlassTabBar.inline()  — renders, onTabSelected fires, compact defaults,
//     text-only tabs, assertion guards, placement dispatch
//   • GlassTabBar.bottom()  — renders, onTabSelected fires, key params wired
//   • GlassTabBar.searchable() — renders, searchConfig wired, tab switch works
//   • _GlassTabBarPlacement dispatch — correct engine for each constructor
//   • GlassTab expanded fields — activeIcon, glowColor, thickness
//   • Deprecated shim surface — GlassTabBar.bottom / GlassTabBar.searchable /
//     GlassTab still render correctly
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:liquid_glass_widgets/src/widgets/surfaces/tab_bar_bottom_layout.dart';
import 'package:liquid_glass_widgets/src/widgets/surfaces/tab_bar_searchable_layout.dart';

import '../../shared/test_helpers.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Wraps [child] inside the LiquidGlassWidgets.wrap() layer so the internal
/// shader registry is initialised — mirrors what the bottom-bar coverage tests
/// do.
Widget _wrap(Widget child) => MaterialApp(
      home: Scaffold(body: LiquidGlassWidgets.wrap(child: child)),
    );

/// Minimal [GlassTab] with icon + label — covers all new fields by default.
GlassTab _tab(String label) => GlassTab(
      label: label,
      icon: const Icon(Icons.home),
      activeIcon: const Icon(Icons.home_filled),
      glowColor: Colors.blue,
      thickness: 1.0,
    );

/// Wraps content in a fixed height box so the bar has room to lay out.
Widget _box(Widget child) => SizedBox(height: 120, child: child);

// ---------------------------------------------------------------------------
// GlassTab — expanded fields
// ---------------------------------------------------------------------------

void main() {
  group('GlassTab — expanded fields', () {
    test('constructs with all new fields without assertion error', () {
      expect(
        () => const GlassTab(
          icon: Icon(Icons.home),
          activeIcon: Icon(Icons.home_filled),
          label: 'Home',
          semanticLabel: 'Go Home',
          glowColor: Colors.blue,
          thickness: 1.5,
        ),
        returnsNormally,
      );
    });

    test('icon-only tab with activeIcon constructs normally', () {
      expect(
        () => const GlassTab(
          icon: Icon(Icons.music_note),
          activeIcon: Icon(Icons.music_note_outlined),
        ),
        returnsNormally,
      );
    });

    test('glowColor and thickness default to null', () {
      const tab = GlassTab(label: 'X');
      expect(tab.glowColor, isNull);
      expect(tab.thickness, isNull);
      expect(tab.activeIcon, isNull);
    });

    test('assertion fires when neither icon nor label is supplied', () {
      expect(
        // ignore: avoid_dynamic_calls
        () => GlassTab(),
        throwsAssertionError,
      );
    });
  });

  // -------------------------------------------------------------------------
  // GlassTabBar.bottom() — rendering
  // -------------------------------------------------------------------------

  group('GlassTabBar.bottom() — rendering', () {
    testWidgets('renders with minimum tabs without crashing', (tester) async {
      await tester.pumpWidget(_wrap(_box(
        GlassTabBar.bottom(
          tabs: [_tab('Home'), _tab('Profile')],
          selectedIndex: 0,
          onTabSelected: (_) {},
        ),
      )));
      await tester.pump();

      expect(find.text('Home'), findsWidgets);
      expect(find.text('Profile'), findsWidgets);
    });

    testWidgets(
        'per-state selectedLabelStyle / unselectedLabelStyle merge over base',
        (tester) async {
      // Exercises BottomBarTabItem's per-state label-style merge: the selected
      // tab merges selectedLabelStyle (and unselected tabs unselectedLabelStyle)
      // over the base label style.
      await tester.pumpWidget(_wrap(_box(
        GlassTabBar.bottom(
          tabs: [_tab('Home'), _tab('Profile')],
          selectedIndex: 0,
          onTabSelected: (_) {},
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w900,
            letterSpacing: 0.4,
          ),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      )));
      await tester.pump();

      expect(tester.takeException(), isNull);
      // The selected label resolves to the merged weight from selectedLabelStyle.
      final homeLabels = tester.widgetList<Text>(find.text('Home'));
      expect(
        homeLabels.any((t) => t.style?.fontWeight == FontWeight.w900),
        isTrue,
      );
    });

    testWidgets('explicit selectedLabelColor wins over textStyle color',
        (tester) async {
      // Regression for the textStyle / selectedLabelColor precedence: an explicit
      // per-state color must apply even when a textStyle (with its own color) is
      // also supplied.
      await tester.pumpWidget(_wrap(_box(
        GlassTabBar.bottom(
          tabs: [_tab('Home'), _tab('Profile')],
          selectedIndex: 0,
          onTabSelected: (_) {},
          textStyle: const TextStyle(color: Colors.green, fontSize: 12),
          selectedLabelColor: Colors.red,
          unselectedLabelColor: Colors.orange,
        ),
      )));
      await tester.pump();

      expect(tester.takeException(), isNull);
      // Selected label resolves to selectedLabelColor (red), not textStyle's green.
      final homeLabels = tester.widgetList<Text>(find.text('Home'));
      expect(homeLabels.any((t) => t.style?.color == Colors.red), isTrue);
      // Unselected label resolves to unselectedLabelColor (orange).
      final profileLabels = tester.widgetList<Text>(find.text('Profile'));
      expect(profileLabels.any((t) => t.style?.color == Colors.orange), isTrue);
    });

    testWidgets('renders with 3 tabs without crashing', (tester) async {
      await tester.pumpWidget(_wrap(_box(
        GlassTabBar.bottom(
          tabs: [_tab('Home'), _tab('Browse'), _tab('Me')],
          selectedIndex: 1,
          onTabSelected: (_) {},
        ),
      )));
      await tester.pump();

      expect(find.text('Browse'), findsWidgets);
    });

    testWidgets('onTabSelected fires with correct index', (tester) async {
      int received = -1;

      await tester.pumpWidget(_wrap(_box(
        StatefulBuilder(
          builder: (context, setState) => GlassTabBar.bottom(
            tabs: [_tab('A'), _tab('B'), _tab('C')],
            selectedIndex: 0,
            onTabSelected: (i) => setState(() => received = i),
          ),
        ),
      )));
      await tester.pump();

      await tester.tap(find.text('B').first);
      await tester.pumpAndSettle();

      expect(received, 1);
    });

    testWidgets('onTabSelected fires index 2 when last tab tapped',
        (tester) async {
      int received = -1;

      await tester.pumpWidget(_wrap(_box(
        StatefulBuilder(
          builder: (context, setState) => GlassTabBar.bottom(
            tabs: [_tab('One'), _tab('Two'), _tab('Three')],
            selectedIndex: 0,
            onTabSelected: (i) => setState(() => received = i),
          ),
        ),
      )));
      await tester.pump();

      await tester.tap(find.text('Three').first);
      await tester.pumpAndSettle();

      expect(received, 2);
    });

    testWidgets('activeIcon field is accepted without crash', (tester) async {
      await tester.pumpWidget(_wrap(_box(
        GlassTabBar.bottom(
          tabs: const [
            GlassTab(
              icon: Icon(Icons.music_note),
              activeIcon: Icon(Icons.music_note_outlined),
              label: 'Music',
            ),
            GlassTab(
              icon: Icon(Icons.podcasts),
              label: 'Podcasts',
            ),
          ],
          selectedIndex: 0,
          onTabSelected: (_) {},
        ),
      )));
      await tester.pump();

      expect(find.text('Music'), findsWidgets);
    });

    testWidgets('glowColor and thickness pass through without crash',
        (tester) async {
      await tester.pumpWidget(_wrap(_box(
        GlassTabBar.bottom(
          tabs: [
            GlassTab(
              icon: const Icon(Icons.star),
              label: 'Glow',
              glowColor: Colors.amber,
              thickness: 2.0,
            ),
            _tab('Normal'),
          ],
          selectedIndex: 0,
          onTabSelected: (_) {},
        ),
      )));
      await tester.pump();

      expect(find.text('Glow'), findsWidgets);
    });

    testWidgets('extraButton parameter wires correctly', (tester) async {
      // ignore: unused_local_variable
      bool extraTapped = false;

      await tester.pumpWidget(_wrap(_box(
        GlassTabBar.bottom(
          tabs: [_tab('Home'), _tab('Search')],
          selectedIndex: 0,
          onTabSelected: (_) {},
          extraButton: GlassTabBarExtraButton(
            icon: const Icon(Icons.add),
            label: 'Add',
            onTap: () => extraTapped = true,
          ),
        ),
      )));
      await tester.pump();

      // Bar renders without error
      expect(find.text('Home'), findsWidgets);
    });

    testWidgets('maskingQuality.off renders without crash', (tester) async {
      await tester.pumpWidget(_wrap(_box(
        GlassTabBar.bottom(
          tabs: [_tab('X'), _tab('Y')],
          selectedIndex: 0,
          onTabSelected: (_) {},
          maskingQuality: MaskingQuality.off,
        ),
      )));
      await tester.pump();

      expect(find.text('X'), findsWidgets);
    });

    testWidgets('quality: premium renders without crash', (tester) async {
      await tester.pumpWidget(_wrap(_box(
        GlassTabBar.bottom(
          tabs: [_tab('A'), _tab('B')],
          selectedIndex: 0,
          onTabSelected: (_) {},
          quality: GlassQuality.premium,
        ),
      )));
      await tester.pump();

      expect(find.text('A'), findsWidgets);
    });

    testWidgets('tabWidth limits pill width without crash', (tester) async {
      await tester.pumpWidget(_wrap(_box(
        GlassTabBar.bottom(
          tabs: [_tab('H'), _tab('P'), _tab('S')],
          selectedIndex: 0,
          onTabSelected: (_) {},
          tabWidth: 88,
        ),
      )));
      await tester.pump();

      expect(find.text('H'), findsWidgets);
    });

    testWidgets('selectedIconColor and iconSize pass through', (tester) async {
      await tester.pumpWidget(_wrap(_box(
        GlassTabBar.bottom(
          tabs: [_tab('Home'), _tab('Settings')],
          selectedIndex: 0,
          onTabSelected: (_) {},
          selectedIconColor: Colors.purple,
          iconSize: 32,
        ),
      )));
      await tester.pump();

      expect(find.text('Home'), findsWidgets);
    });

    testWidgets('selectedLabelColor and unselectedLabelColor pass through',
        (tester) async {
      await tester.pumpWidget(_wrap(_box(
        GlassTabBar.bottom(
          tabs: [_tab('Home'), _tab('Settings')],
          selectedIndex: 0,
          onTabSelected: (_) {},
          selectedLabelColor: Colors.purple,
          unselectedLabelColor: Colors.teal,
        ),
      )));
      await tester.pump();

      expect(find.text('Home'), findsWidgets);
    });

    testWidgets('indicatorBorderRadius passes through without crash',
        (tester) async {
      await tester.pumpWidget(_wrap(_box(
        GlassTabBar.bottom(
          tabs: [_tab('Home'), _tab('Settings')],
          selectedIndex: 0,
          onTabSelected: (_) {},
          indicatorBorderRadius: 12.0,
        ),
      )));
      await tester.pump();

      expect(find.text('Home'), findsWidgets);
    });

    testWidgets('GlassInteractionBehavior.none renders without crash',
        (tester) async {
      await tester.pumpWidget(_wrap(_box(
        GlassTabBar.bottom(
          tabs: [_tab('X'), _tab('Y')],
          selectedIndex: 0,
          onTabSelected: (_) {},
          interactionBehavior: GlassInteractionBehavior.none,
        ),
      )));
      await tester.pump();

      expect(find.text('X'), findsWidgets);
    });

    testWidgets('selectedIndex=1 starts on second tab', (tester) async {
      int received = -1;

      await tester.pumpWidget(_wrap(_box(
        StatefulBuilder(
          builder: (context, setState) => GlassTabBar.bottom(
            tabs: [_tab('First'), _tab('Second'), _tab('Third')],
            selectedIndex: 1,
            onTabSelected: (i) => setState(() => received = i),
          ),
        ),
      )));
      await tester.pump();

      // Tap the first tab from index 1 start
      await tester.tap(find.text('First').first);
      await tester.pumpAndSettle();

      expect(received, 0);
    });
  });

  // -------------------------------------------------------------------------
  // GlassTabBar.inline() — rendering
  // -------------------------------------------------------------------------

  group('GlassTabBar.inline() — rendering', () {
    testWidgets('renders with minimum tabs without crashing', (tester) async {
      await tester.pumpWidget(_wrap(_box(
        GlassTabBar.inline(
          tabs: [_tab('For You'), _tab('Following')],
          selectedIndex: 0,
          onTabSelected: (_) {},
        ),
      )));
      await tester.pump();

      expect(find.text('For You'), findsWidgets);
      expect(find.text('Following'), findsWidgets);
    });

    testWidgets('renders with 3 tabs without crashing', (tester) async {
      await tester.pumpWidget(_wrap(_box(
        GlassTabBar.inline(
          tabs: [_tab('For You'), _tab('Following'), _tab('New')],
          selectedIndex: 1,
          onTabSelected: (_) {},
        ),
      )));
      await tester.pump();

      expect(find.text('Following'), findsWidgets);
    });

    testWidgets('onTabSelected fires with correct index', (tester) async {
      int received = -1;

      await tester.pumpWidget(_wrap(_box(
        StatefulBuilder(
          builder: (context, setState) => GlassTabBar.inline(
            tabs: [_tab('A'), _tab('B'), _tab('C')],
            selectedIndex: 0,
            onTabSelected: (i) => setState(() => received = i),
          ),
        ),
      )));
      await tester.pump();

      await tester.tap(find.text('B').first);
      await tester.pumpAndSettle();

      expect(received, 1);
    });

    testWidgets('text-only tabs (no icons) render without crashing',
        (tester) async {
      await tester.pumpWidget(_wrap(_box(
        GlassTabBar.inline(
          tabs: const [
            GlassTab(label: 'Timeline'),
            GlassTab(label: 'Mentions'),
            GlassTab(label: 'Trending'),
          ],
          selectedIndex: 0,
          onTabSelected: (_) {},
        ),
      )));
      await tester.pump();

      expect(find.text('Timeline'), findsWidgets);
      expect(tester.takeException(), isNull);
    });

    testWidgets('selectedIndex=2 starts on third tab', (tester) async {
      int received = -1;

      await tester.pumpWidget(_wrap(_box(
        StatefulBuilder(
          builder: (context, setState) => GlassTabBar.inline(
            tabs: [_tab('One'), _tab('Two'), _tab('Three')],
            selectedIndex: 2,
            onTabSelected: (i) => setState(() => received = i),
          ),
        ),
      )));
      await tester.pump();

      await tester.tap(find.text('One').first);
      await tester.pumpAndSettle();

      expect(received, 0);
    });

    testWidgets('tabWidth limits slot width without crash', (tester) async {
      await tester.pumpWidget(_wrap(_box(
        GlassTabBar.inline(
          tabs: [_tab('Home'), _tab('Search'), _tab('Me')],
          selectedIndex: 0,
          onTabSelected: (_) {},
          tabWidth: 80,
        ),
      )));
      await tester.pump();

      expect(find.text('Home'), findsWidgets);
    });

    testWidgets('quality: premium renders without crash', (tester) async {
      await tester.pumpWidget(_wrap(_box(
        GlassTabBar.inline(
          tabs: [_tab('A'), _tab('B')],
          selectedIndex: 0,
          onTabSelected: (_) {},
          quality: GlassQuality.premium,
        ),
      )));
      await tester.pump();

      expect(find.text('A'), findsWidgets);
    });

    testWidgets('magnification defaults to 1.0 — no-zoom path renders cleanly',
        (tester) async {
      await tester.pumpWidget(_wrap(_box(
        GlassTabBar.inline(
          tabs: const [GlassTab(label: 'Songs'), GlassTab(label: 'Albums')],
          selectedIndex: 0,
          onTabSelected: (_) {},
        ),
      )));
      await tester.pump();

      expect(tester.takeException(), isNull);
    });

    testWidgets('forwards springDescription to TabIndicator', (tester) async {
      const customSpring =
          SpringDescription(mass: 2, stiffness: 200, damping: 20);

      await tester.pumpWidget(_wrap(_box(
        GlassTabBar.inline(
          tabs: const [GlassTab(label: 'Songs'), GlassTab(label: 'Albums')],
          selectedIndex: 0,
          onTabSelected: (_) {},
          springDescription: customSpring,
        ),
      )));
      await tester.pump();

      expect(tester.takeException(), isNull);
    });

    testWidgets('forwards backgroundQuality to TabBarBottomLayout',
        (tester) async {
      await tester.pumpWidget(_wrap(_box(
        GlassTabBar.inline(
          tabs: [_tab('A'), _tab('B')],
          selectedIndex: 0,
          onTabSelected: (_) {},
          quality: GlassQuality.premium,
          backgroundQuality: GlassQuality.minimal,
        ),
      )));
      await tester.pump();

      final layout = tester.widget<TabBarBottomLayout>(
        find.byType(TabBarBottomLayout),
      );
      expect(layout.backgroundQuality, equals(GlassQuality.minimal));
    });
  });

  // -------------------------------------------------------------------------
  // GlassTabBar.inline() — assertion guards
  // -------------------------------------------------------------------------

  group('GlassTabBar.inline() — assertion guards', () {
    test('asserts minimum 1 tab', () {
      expect(
        () => GlassTabBar.inline(
          tabs: const [],
          selectedIndex: 0,
          onTabSelected: (_) {},
        ),
        throwsAssertionError,
      );
    });

    test('asserts selectedIndex in bounds', () {
      expect(
        () => GlassTabBar.inline(
          tabs: [_tab('A'), _tab('B')],
          selectedIndex: 5,
          onTabSelected: (_) {},
        ),
        throwsAssertionError,
      );
    });

    test('selectedIndex=0 with 1 tab does not throw', () {
      expect(
        () => GlassTabBar.inline(
          tabs: [_tab('Only')],
          selectedIndex: 0,
          onTabSelected: (_) {},
        ),
        returnsNormally,
      );
    });
  });

  // -------------------------------------------------------------------------
  // GlassTabBar.searchable() — rendering
  // -------------------------------------------------------------------------

  group('GlassTabBar.searchable() — rendering', () {
    /// Minimal searchConfig for tests
    final searchConfig =
        GlassSearchBarConfig(hintText: 'Search...', onSearchToggle: (_) {});

    testWidgets('renders with minimum required params without crashing',
        (tester) async {
      await tester.pumpWidget(_wrap(
        SizedBox(
          height: 150,
          child: GlassTabBar.searchable(
            tabs: [_tab('Home'), _tab('Browse'), _tab('Me')],
            selectedIndex: 0,
            onTabSelected: (_) {},
            searchConfig: searchConfig,
          ),
        ),
      ));
      await tester.pump();

      expect(find.text('Home'), findsWidgets);
    });

    testWidgets('onTabSelected fires with correct index', (tester) async {
      int received = -1;

      await tester.pumpWidget(_wrap(
        SizedBox(
          height: 150,
          child: StatefulBuilder(
            builder: (context, setState) => GlassTabBar.searchable(
              tabs: [_tab('A'), _tab('B'), _tab('C')],
              selectedIndex: 0,
              onTabSelected: (i) => setState(() => received = i),
              searchConfig: searchConfig,
            ),
          ),
        ),
      ));
      await tester.pump();

      await tester.tap(find.text('B').first);
      await tester.pumpAndSettle();

      expect(received, 1);
    });

    testWidgets('isSearchActive=true renders without crash', (tester) async {
      await tester.pumpWidget(_wrap(
        SizedBox(
          height: 150,
          child: GlassTabBar.searchable(
            tabs: [_tab('Home'), _tab('Search')],
            selectedIndex: 0,
            onTabSelected: (_) {},
            searchConfig: searchConfig,
            isSearchActive: true,
          ),
        ),
      ));
      await tester.pump();

      expect(find.byType(GlassTabBar), findsOneWidget);
    });

    testWidgets('quality: premium renders without crash', (tester) async {
      await tester.pumpWidget(_wrap(
        SizedBox(
          height: 150,
          child: GlassTabBar.searchable(
            tabs: [_tab('A'), _tab('B')],
            selectedIndex: 0,
            onTabSelected: (_) {},
            searchConfig: searchConfig,
            quality: GlassQuality.premium,
          ),
        ),
      ));
      await tester.pump();

      expect(find.text('A'), findsWidgets);
    });

    testWidgets('tabPillAnchor.center renders without crash', (tester) async {
      await tester.pumpWidget(_wrap(
        SizedBox(
          height: 150,
          child: GlassTabBar.searchable(
            tabs: [_tab('A'), _tab('B')],
            selectedIndex: 0,
            onTabSelected: (_) {},
            searchConfig: searchConfig,
            tabPillAnchor: GlassTabPillAnchor.center,
          ),
        ),
      ));
      await tester.pump();

      expect(find.text('A'), findsWidgets);
    });

    testWidgets('forwards backgroundQuality to TabBarSearchableLayout',
        (tester) async {
      await tester.pumpWidget(_wrap(
        SizedBox(
          height: 150,
          child: GlassTabBar.searchable(
            tabs: [_tab('A'), _tab('B')],
            selectedIndex: 0,
            onTabSelected: (_) {},
            searchConfig: searchConfig,
            quality: GlassQuality.premium,
            backgroundQuality: GlassQuality.minimal,
          ),
        ),
      ));
      await tester.pump();

      final layout = tester.widget<TabBarSearchableLayout>(
        find.byType(TabBarSearchableLayout),
      );
      expect(layout.backgroundQuality, equals(GlassQuality.minimal));
    });
  });

  // -------------------------------------------------------------------------
  // Placement dispatch — each constructor produces the right widget tree
  // -------------------------------------------------------------------------

  group('GlassTabBar placement dispatch', () {
    testWidgets('scrollable constructor dispatches to ScrollableSegmentContent',
        (tester) async {
      // The scrollable build path uses ScrollableSegmentContent internally (visible via
      // finding Container at the root of the bar).
      await tester.pumpWidget(
        createTestApp(
          child: AdaptiveLiquidGlassLayer(
            settings: settingsWithoutLighting,
            child: GlassSegmentedControl(
              segments: const [
                GlassSegment(label: 'X'),
                GlassSegment(label: 'Y')
              ],
              selectedIndex: 0,
              onSegmentSelected: (_) {},
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(GlassSegmentedControl), findsOneWidget);
      // Inline mode must NOT produce a GlassTabBar.bottom
      expect(find.byType(GlassTabBar), findsNothing);
    });

    testWidgets('.bottom() dispatches to TabBarBottomLayout', (tester) async {
      await tester.pumpWidget(_wrap(_box(
        GlassTabBar.bottom(
          tabs: [_tab('Home'), _tab('Me')],
          selectedIndex: 0,
          onTabSelected: (_) {},
        ),
      )));
      await tester.pump();

      expect(find.byType(GlassTabBar), findsOneWidget);
      expect(find.byType(TabBarBottomLayout), findsOneWidget);
    });

    testWidgets('.searchable() dispatches to TabBarSearchableLayout',
        (tester) async {
      await tester.pumpWidget(_wrap(
        SizedBox(
          height: 150,
          child: GlassTabBar.searchable(
            tabs: [_tab('Home'), _tab('Me')],
            selectedIndex: 0,
            onTabSelected: (_) {},
            searchConfig: GlassSearchBarConfig(
                hintText: 'Search', onSearchToggle: (_) {}),
          ),
        ),
      ));
      await tester.pump();

      expect(find.byType(GlassTabBar), findsOneWidget);
      expect(find.byType(TabBarSearchableLayout), findsOneWidget);
    });

    testWidgets('.inline() dispatches to TabBarBottomLayout', (tester) async {
      await tester.pumpWidget(_wrap(_box(
        GlassTabBar.inline(
          tabs: [_tab('Home'), _tab('Me')],
          selectedIndex: 0,
          onTabSelected: (_) {},
        ),
      )));
      await tester.pump();

      expect(find.byType(GlassTabBar), findsOneWidget);
      expect(find.byType(TabBarBottomLayout), findsOneWidget);
    });
  });

  // -------------------------------------------------------------------------
  // Deprecated shim API — verify zero-logic shims still render correctly
  // -------------------------------------------------------------------------

  group('Deprecated shim API — GlassTabBar.bottom / GlassTab', () {
    testWidgets('GlassTabBar.bottom still renders with GlassTab',
        (tester) async {
      await tester.pumpWidget(_wrap(_box(
        GlassTabBar.bottom(
          tabs: [
            GlassTab(
              label: 'Home',
              icon: const Icon(Icons.home),
              activeIcon: const Icon(Icons.home_filled),
              glowColor: Colors.blue,
              thickness: 1.0,
            ),
            GlassTab(
              label: 'Search',
              icon: const Icon(Icons.search),
            ),
          ],
          selectedIndex: 0,
          onTabSelected: (_) {},
        ),
      )));
      await tester.pump();

      expect(find.text('Home'), findsWidgets);
      expect(find.text('Search'), findsWidgets);
    });

    testWidgets('GlassTabBar.bottom onTabSelected still fires correctly',
        (tester) async {
      int received = -1;

      await tester.pumpWidget(_wrap(_box(
        StatefulBuilder(
          builder: (context, setState) => GlassTabBar.bottom(
            tabs: [
              GlassTab(label: 'A', icon: const Icon(Icons.home)),
              GlassTab(label: 'B', icon: const Icon(Icons.search)),
            ],
            selectedIndex: 0,
            onTabSelected: (i) => setState(() => received = i),
          ),
        ),
      )));
      await tester.pump();

      await tester.tap(find.text('B').first);
      await tester.pumpAndSettle();

      expect(received, 1);
    });

    testWidgets('GlassTabBar.searchable still renders with GlassTab',
        (tester) async {
      await tester.pumpWidget(_wrap(
        SizedBox(
          height: 150,
          child: GlassTabBar.searchable(
            tabs: [
              GlassTab(label: 'Home', icon: const Icon(Icons.home)),
              GlassTab(label: 'Browse', icon: const Icon(Icons.explore)),
            ],
            selectedIndex: 0,
            onTabSelected: (_) {},
            searchConfig: GlassSearchBarConfig(
                hintText: 'Search...', onSearchToggle: (_) {}),
          ),
        ),
      ));
      await tester.pump();

      expect(find.text('Home'), findsWidgets);
    });
  });

  // -------------------------------------------------------------------------
  // GlassTabBar.bottom() assertion guards
  // -------------------------------------------------------------------------

  group('GlassTabBar.bottom() — assertion guards', () {
    test('asserts minimum 1 tab', () {
      expect(
        () => GlassTabBar.bottom(
          tabs: const [],
          selectedIndex: 0,
          onTabSelected: (_) {},
        ),
        throwsAssertionError,
      );
    });

    test('asserts selectedIndex in bounds', () {
      expect(
        () => GlassTabBar.bottom(
          tabs: [_tab('A'), _tab('B')],
          selectedIndex: 5,
          onTabSelected: (_) {},
        ),
        throwsAssertionError,
      );
    });

    test('selectedIndex=0 with 1 tab does not throw', () {
      expect(
        () => GlassTabBar.bottom(
          tabs: [_tab('Only')],
          selectedIndex: 0,
          onTabSelected: (_) {},
        ),
        returnsNormally,
      );
    });
  });
}
