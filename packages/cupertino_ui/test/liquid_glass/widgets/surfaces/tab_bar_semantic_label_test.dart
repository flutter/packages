import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:liquid_glass_widgets/src/widgets/surfaces/tab_bar_searchable_internal.dart';

import '../../shared/test_helpers.dart';

/// Accessibility naming for the bars that render tabs through
/// `BottomBarTabItem` — [GlassTabBar.bottom], [GlassTabBar.inline],
/// [GlassTabBar.searchable] and the deprecated [GlassTabBar.bottom].
///
/// An icon-only tab has no label to announce, so [GlassTab.semanticLabel] is
/// the caller's only way to name it.
///
/// These bars paint an unselected row plus a selected-styled row that the
/// indicator clips. The selected row is wrapped in `ExcludeSemantics`, meaning
/// a tab yields exactly ONE semantics node regardless of where the indicator
/// sits, avoiding duplicate button announcements.
void main() {
  const iconOnlyTabs = [
    GlassTab(icon: Icon(CupertinoIcons.home), semanticLabel: 'Home'),
    GlassTab(icon: Icon(CupertinoIcons.search), semanticLabel: 'Search'),
    GlassTab(icon: Icon(CupertinoIcons.person), semanticLabel: 'Profile'),
  ];

  group('GlassTabBar.bottom semantics', () {
    testWidgets('bar-wide gesture detector is excluded from semantics', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();

      await tester.pumpWidget(
        createTestApp(
          child: GlassTabBar.bottom(
            tabs: const [
              GlassTab(icon: Icon(CupertinoIcons.home), label: 'Home'),
              GlassTab(icon: Icon(CupertinoIcons.search), label: 'Search'),
            ],
            selectedIndex: 0,
            onTabSelected: (_) {},
            maskingQuality: MaskingQuality.off,
          ),
        ),
      );

      final detector = tester.widget<GestureDetector>(
        find.byWidgetPredicate(
          (w) => w is GestureDetector && w.key == const ValueKey(0),
        ),
      );
      expect(detector.excludeFromSemantics, isTrue);

      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));

      semantics.dispose();
    });

    testWidgets('icon-only tabs announce their semanticLabel', (tester) async {
      final semantics = tester.ensureSemantics();

      await tester.pumpWidget(
        createTestApp(
          child: GlassTabBar.bottom(
            tabs: iconOnlyTabs,
            selectedIndex: 0,
            onTabSelected: (_) {},
            maskingQuality: MaskingQuality.off,
          ),
        ),
      );

      expect(find.bySemanticsLabel('Home'), findsOneWidget);
      expect(find.bySemanticsLabel('Search'), findsOneWidget);
      expect(find.bySemanticsLabel('Profile'), findsOneWidget);
      expect(find.bySemanticsLabel('Tab'), findsNothing);

      semantics.dispose();
    });

    testWidgets('semanticLabel replaces the label in the announcement', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();

      await tester.pumpWidget(
        createTestApp(
          child: GlassTabBar.bottom(
            tabs: const [
              GlassTab(
                icon: Icon(CupertinoIcons.home),
                label: 'Home',
                semanticLabel: 'Home, first of two tabs',
              ),
              GlassTab(icon: Icon(CupertinoIcons.search), label: 'Search'),
            ],
            selectedIndex: 0,
            onTabSelected: (_) {},
            maskingQuality: MaskingQuality.off,
          ),
        ),
      );

      expect(find.bySemanticsLabel('Home, first of two tabs'), findsOneWidget);
      // Replaced, not prefixed: the label text is not announced as well.
      expect(find.bySemanticsLabel('Home'), findsNothing);
      // The visible label still renders; only the announcement changes.
      expect(find.text('Home'), findsWidgets);

      semantics.dispose();
    });

    testWidgets('a label-only tab announces its label exactly once', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();

      await tester.pumpWidget(
        createTestApp(
          child: GlassTabBar.bottom(
            tabs: const [
              GlassTab(icon: Icon(CupertinoIcons.home), label: 'Home'),
              GlassTab(icon: Icon(CupertinoIcons.search), label: 'Search'),
            ],
            selectedIndex: 0,
            onTabSelected: (_) {},
            maskingQuality: MaskingQuality.off,
          ),
        ),
      );

      expect(find.bySemanticsLabel('Home'), findsOneWidget);
      expect(find.bySemanticsLabel('Search'), findsWidgets);

      semantics.dispose();
    });

    testWidgets('a tab with neither keeps the Tab fallback', (tester) async {
      final semantics = tester.ensureSemantics();

      await tester.pumpWidget(
        createTestApp(
          child: GlassTabBar.bottom(
            tabs: const [
              GlassTab(icon: Icon(CupertinoIcons.home)),
              GlassTab(icon: Icon(CupertinoIcons.search)),
            ],
            selectedIndex: 0,
            onTabSelected: (_) {},
            maskingQuality: MaskingQuality.off,
          ),
        ),
      );

      expect(find.bySemanticsLabel('Tab'), findsNWidgets(2));

      semantics.dispose();
    });
  });

  group('GlassTabBar.inline semantics', () {
    testWidgets('icon-only tabs announce their semanticLabel', (tester) async {
      final semantics = tester.ensureSemantics();

      await tester.pumpWidget(
        createTestApp(
          child: GlassTabBar.inline(
            tabs: iconOnlyTabs,
            selectedIndex: 0,
            onTabSelected: (_) {},
            maskingQuality: MaskingQuality.off,
          ),
        ),
      );

      expect(find.bySemanticsLabel('Home'), findsOneWidget);
      expect(find.bySemanticsLabel('Profile'), findsOneWidget);
      expect(find.bySemanticsLabel('Tab'), findsNothing);

      semantics.dispose();
    });
  });

  group('GlassTabBar.searchable semantics', () {
    testWidgets('bar-wide gesture detector is excluded from semantics', (
      tester,
    ) async {
      await tester.pumpWidget(
        createTestApp(
          child: GlassTabBar.searchable(
            tabs: const [
              GlassTab(icon: Icon(CupertinoIcons.home), label: 'Home'),
              GlassTab(icon: Icon(CupertinoIcons.search), label: 'Search'),
            ],
            selectedIndex: 0,
            onTabSelected: (_) {},
            maskingQuality: MaskingQuality.off,
            searchConfig: GlassSearchBarConfig(onSearchToggle: (_) {}),
          ),
        ),
      );

      final detector = tester.widget<GestureDetector>(
        find.descendant(
          of: find.byType(SearchableTabIndicator),
          matching: find.byWidgetPredicate(
            (w) => w is GestureDetector && w.key == const ValueKey(0),
          ),
        ),
      );
      expect(detector.excludeFromSemantics, isTrue);
    });

    testWidgets('icon-only tabs announce their semanticLabel', (tester) async {
      final semantics = tester.ensureSemantics();

      await tester.pumpWidget(
        createTestApp(
          child: GlassTabBar.searchable(
            tabs: iconOnlyTabs,
            selectedIndex: 0,
            onTabSelected: (_) {},
            maskingQuality: MaskingQuality.off,
            searchConfig: GlassSearchBarConfig(onSearchToggle: (_) {}),
          ),
        ),
      );

      expect(find.bySemanticsLabel('Home'), findsOneWidget);
      expect(find.bySemanticsLabel('Profile'), findsOneWidget);
      expect(find.bySemanticsLabel('Tab'), findsNothing);

      semantics.dispose();
    });
  });

  group('GlassTabBar.bottom semantics', () {
    testWidgets('icon-only tabs announce their semanticLabel', (tester) async {
      final semantics = tester.ensureSemantics();

      await tester.pumpWidget(
        createTestApp(
          child: GlassTabBar.bottom(
            tabs: const [
              GlassTab(
                icon: Icon(CupertinoIcons.home),
                semanticLabel: 'Home',
              ),
              GlassTab(
                icon: Icon(CupertinoIcons.search),
                semanticLabel: 'Search',
              ),
            ],
            selectedIndex: 0,
            onTabSelected: (_) {},
            maskingQuality: MaskingQuality.off,
          ),
        ),
      );

      expect(find.bySemanticsLabel('Home'), findsOneWidget);
      expect(find.bySemanticsLabel('Search'), findsOneWidget);
      expect(find.bySemanticsLabel('Tab'), findsNothing);

      semantics.dispose();
    });
  });
}
