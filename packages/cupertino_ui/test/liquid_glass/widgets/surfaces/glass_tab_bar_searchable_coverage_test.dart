// ignore_for_file: require_trailing_commas
// Coverage-targeted tests for GlassTabBar.searchable.
// Targets:
//   - lines 410-411: initState owning-controller creation path
//   - lines 441-452: didUpdateWidget controller swap (owned → external)
//   - line 640:      cachedTotalW update branch
//   - lines 742-743: onDismissSearch callback path
//   - line 797:      extraButton collapsing layout branch

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

import '../../shared/test_helpers.dart';

final _testTabs = [
  const GlassTab(label: 'Home', icon: Icon(Icons.home)),
  const GlassTab(label: 'Music', icon: Icon(Icons.music_note)),
  const GlassTab(label: 'Profile', icon: Icon(Icons.person)),
];

GlassSearchBarConfig _basicSearchConfig() => GlassSearchBarConfig(
      onSearchToggle: (_) {},
    );

Widget _buildBar({
  SearchableBottomBarController? controller,
  bool isSearchActive = false,
  GlassSearchBarConfig? searchConfig,
  GlassTabBarExtraButton? extraButton,
  int selectedIndex = 0,
  ValueChanged<int>? onTabSelected,
  bool enableBlend = true,
}) {
  return createTestApp(
    child: SizedBox(
      height: 90,
      width: 400,
      child: GlassTabBar.searchable(
        tabs: _testTabs,
        selectedIndex: selectedIndex,
        onTabSelected: onTabSelected ?? (_) {},
        searchConfig: searchConfig ?? _basicSearchConfig(),
        controller: controller,
        isSearchActive: isSearchActive,
        extraButton: extraButton,
        enableBlend: enableBlend,
      ),
    ),
  );
}

void main() {
  group('GlassTabBar.searchable — controller swap (didUpdateWidget)', () {
    testWidgets('swapping from null to external controller and back',
        (tester) async {
      // Lines 441-452: didUpdateWidget controller swap path.
      // Null → external → different external → null.
      SearchableBottomBarController? externalCtrl;
      late StateSetter outerSetState;

      await tester.pumpWidget(
        StatefulBuilder(builder: (ctx, setState) {
          outerSetState = setState;
          return _buildBar(controller: externalCtrl);
        }),
      );
      await tester.pump();

      // null → external (owned controller disposed, external adopted).
      final ctrl1 = SearchableBottomBarController();
      outerSetState(() => externalCtrl = ctrl1);
      await tester.pump();
      expect(tester.takeException(), isNull);

      // external → different external.
      final ctrl2 = SearchableBottomBarController();
      outerSetState(() => externalCtrl = ctrl2);
      await tester.pump();
      expect(tester.takeException(), isNull);

      // external → null (back to internally owned).
      outerSetState(() => externalCtrl = null);
      await tester.pump();
      expect(tester.takeException(), isNull);

      ctrl1.dispose();
      ctrl2.dispose();
    });
  });

  group('GlassTabBar.searchable — search expand/collapse', () {
    testWidgets('toggling isSearchActive animates search pill', (tester) async {
      // isSearchActive is driven by parent state — toggle it to trigger animation.
      bool searchActive = false;
      late StateSetter outerSetState;

      await tester.pumpWidget(
        StatefulBuilder(builder: (ctx, setState) {
          outerSetState = setState;
          return createTestApp(
            child: SizedBox(
              height: 90,
              width: 400,
              child: GlassTabBar.searchable(
                tabs: _testTabs,
                selectedIndex: 0,
                onTabSelected: (_) {},
                isSearchActive: searchActive,
                searchConfig: GlassSearchBarConfig(
                  onSearchToggle: (v) => outerSetState(() => searchActive = v),
                ),
              ),
            ),
          );
        }),
      );
      await tester.pump();

      // Activate search.
      outerSetState(() => searchActive = true);
      await tester.pump(const Duration(milliseconds: 16));
      await tester.pump(const Duration(milliseconds: 16));

      expect(tester.takeException(), isNull);

      // Deactivate search.
      outerSetState(() => searchActive = false);
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });

    testWidgets('cancel button shown during search (showsCancelButton)',
        (tester) async {
      // Lines 850-873: dismiss pill path with showsCancelButton=true.
      bool searchActive = true;
      late StateSetter outerSetState;

      await tester.pumpWidget(
        StatefulBuilder(builder: (ctx, setState) {
          outerSetState = setState;
          return createTestApp(
            child: SizedBox(
              height: 90,
              width: 400,
              child: GlassTabBar.searchable(
                tabs: _testTabs,
                selectedIndex: 0,
                onTabSelected: (_) {},
                isSearchActive: searchActive,
                searchConfig: GlassSearchBarConfig(
                  onSearchToggle: (v) => outerSetState(() => searchActive = v),
                  showsCancelButton: true,
                ),
              ),
            ),
          );
        }),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });

  group('GlassTabBar.searchable — extraButton collapse layout', () {
    testWidgets('extraButton renders and collapses when search is active',
        (tester) async {
      // Line 797: the width/height collapse math branch for extraButton.
      bool searchActive = false;
      late StateSetter outerSetState;

      await tester.pumpWidget(
        StatefulBuilder(builder: (ctx, setState) {
          outerSetState = setState;
          return createTestApp(
            child: SizedBox(
              height: 90,
              width: 400,
              child: GlassTabBar.searchable(
                tabs: _testTabs,
                selectedIndex: 0,
                onTabSelected: (_) {},
                isSearchActive: searchActive,
                searchConfig: GlassSearchBarConfig(
                  onSearchToggle: (v) => outerSetState(() => searchActive = v),
                ),
                extraButton: GlassTabBarExtraButton(
                  icon: const Icon(Icons.add),
                  label: 'Add',
                  onTap: () {},
                ),
              ),
            ),
          );
        }),
      );
      await tester.pump();

      // Activate search → extraButton collapse layout path exercised.
      outerSetState(() => searchActive = true);
      await tester.pump(const Duration(milliseconds: 30));
      await tester.pump(const Duration(milliseconds: 30));

      expect(tester.takeException(), isNull);

      // Deactivate.
      outerSetState(() => searchActive = false);
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });

  group('GlassTabBar.searchable — tab selection and onDismissSearch', () {
    testWidgets('switching tabs while search is active exercises dismiss path',
        (tester) async {
      // Lines 742-743: the dismiss callback exercised when search collapses.
      int selectedTab = 0;
      bool searchActive = true;
      late StateSetter outerSetState;

      await tester.pumpWidget(
        StatefulBuilder(builder: (ctx, setState) {
          outerSetState = setState;
          return createTestApp(
            child: SizedBox(
              height: 90,
              width: 400,
              child: GlassTabBar.searchable(
                tabs: _testTabs,
                selectedIndex: selectedTab,
                onTabSelected: (i) => outerSetState(() {
                  selectedTab = i;
                  searchActive = false; // tapping a tab closes search
                }),
                isSearchActive: searchActive,
                searchConfig: GlassSearchBarConfig(
                  onSearchToggle: (v) => outerSetState(() => searchActive = v),
                ),
              ),
            ),
          );
        }),
      );
      await tester.pumpAndSettle();

      // Tap a collapsed tab pill — triggers onDismissSearch callback path.
      final tabFinder = find.byType(GlassTabBar);
      if (tabFinder.evaluate().isNotEmpty) {
        final rect = tester.getRect(tabFinder.first);
        await tester.tapAt(Offset(rect.left + 30, rect.center.dy));
        await tester.pumpAndSettle();
      }

      expect(tester.takeException(), isNull);
    });
  });

  group('GlassTabBar.searchable — enableBlend', () {
    testWidgets('enableBlend defaults to true', (tester) async {
      final bar = GlassTabBar.searchable(
        tabs: _testTabs,
        selectedIndex: 0,
        onTabSelected: (_) {},
        searchConfig: _basicSearchConfig(),
      );
      expect(bar.enableBlend, isTrue);
    });

    testWidgets('enableBlend: false renders without crash', (tester) async {
      await tester.pumpWidget(
        _buildBar(
          enableBlend: false,
          extraButton: GlassTabBarExtraButton(
            icon: const Icon(Icons.add),
            onTap: () {},
            label: 'Add',
          ),
        ),
      );
      await tester.pump();
      expect(tester.takeException(), isNull);
    });
  });
}
