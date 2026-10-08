import 'package:flutter/cupertino.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

import '../../shared/test_helpers.dart';

/// A tab has to be activatable by assistive technology, not only by a finger.
///
/// [GlassTabBar.bottom] and [GlassTabBar.searchable] own selection on the
/// indicator's own `onTapDown`, so every tab is built with a null `onTap` and
/// its [GestureDetector] is excluded from semantics. Without an explicit tap
/// action the tab's node is a button with a selected state that TalkBack and
/// VoiceOver can read and cannot activate, and that a focused tab does not
/// answer Enter or Space on either (WCAG 2.1.1).
void main() {
  const tabs = [
    GlassTab(label: 'Home', icon: Icon(CupertinoIcons.home)),
    GlassTab(label: 'Search', icon: Icon(CupertinoIcons.search)),
    GlassTab(label: 'Profile', icon: Icon(CupertinoIcons.person)),
  ];

  Widget bottomBar({
    required ValueChanged<int> onTabSelected,
    TextDirection textDirection = TextDirection.ltr,
    int selectedIndex = 0,
  }) {
    return createTestApp(
      child: Directionality(
        textDirection: textDirection,
        child: GlassTabBar.bottom(
          tabs: tabs,
          selectedIndex: selectedIndex,
          onTabSelected: onTabSelected,
          maskingQuality: MaskingQuality.off,
        ),
      ),
    );
  }

  group('GlassTabBar.bottom semantics actions', () {
    testWidgets('every tab exposes a tap action', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(bottomBar(onTabSelected: (_) {}));

      for (final label in ['Home', 'Search', 'Profile']) {
        final node = tester.getSemantics(find.bySemanticsLabel(label));
        expect(
          node.getSemanticsData().hasAction(SemanticsAction.tap),
          isTrue,
          reason: '\$label can be read but not activated',
        );
      }

      handle.dispose();
    });

    testWidgets('performing the tap action selects that tab', (tester) async {
      final handle = tester.ensureSemantics();
      var selected = -1;
      await tester.pumpWidget(bottomBar(onTabSelected: (i) => selected = i));

      tester.semantics.performAction(
        find.semantics.byLabel('Search'),
        SemanticsAction.tap,
      );
      await tester.pump();
      expect(selected, 1);

      tester.semantics.performAction(
        find.semantics.byLabel('Profile'),
        SemanticsAction.tap,
      );
      await tester.pump();
      expect(selected, 2);

      handle.dispose();
    });

    testWidgets('under RTL the tap action reports the logical index', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      var selected = -1;
      await tester.pumpWidget(
        bottomBar(
          onTabSelected: (i) => selected = i,
          textDirection: TextDirection.rtl,
        ),
      );

      // 'Home' renders on the trailing (right) edge under RTL and is still
      // logical index 0 — the bar reverses its tab data and mirrors the
      // callback, and the semantics action rides that same wrapper.
      tester.semantics.performAction(
        find.semantics.byLabel('Home'),
        SemanticsAction.tap,
      );
      await tester.pump();
      expect(selected, 0);

      tester.semantics.performAction(
        find.semantics.byLabel('Profile'),
        SemanticsAction.tap,
      );
      await tester.pump();
      expect(selected, 2);

      handle.dispose();
    });
  });

  group('GlassTabBar.searchable semantics actions', () {
    testWidgets('performing the tap action selects that tab', (tester) async {
      final handle = tester.ensureSemantics();
      var selected = -1;
      await tester.pumpWidget(
        createTestApp(
          child: GlassTabBar.searchable(
            tabs: tabs,
            selectedIndex: 0,
            onTabSelected: (i) => selected = i,
            maskingQuality: MaskingQuality.off,
            searchConfig: GlassSearchBarConfig(onSearchToggle: (_) {}),
          ),
        ),
      );
      await tester.pump();

      // The collapsed search pill is a 'Search' button as well (named by the
      // config's hint text), so pick the tab: the node with a selected state.
      tester.semantics.performAction(
        find.semantics.byPredicate(
          (node) =>
              node.label == 'Search' &&
              // ignore: deprecated_member_use
              node.hasFlag(SemanticsFlag.hasSelectedState),
        ),
        SemanticsAction.tap,
      );
      await tester.pump();
      expect(selected, 1);

      handle.dispose();
    });

    testWidgets('under RTL the tap action reports the logical index', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      var selected = -1;
      await tester.pumpWidget(
        createTestApp(
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: GlassTabBar.searchable(
              tabs: tabs,
              selectedIndex: 1,
              onTabSelected: (i) => selected = i,
              maskingQuality: MaskingQuality.off,
              searchConfig: GlassSearchBarConfig(onSearchToggle: (_) {}),
            ),
          ),
        ),
      );
      await tester.pump();

      tester.semantics.performAction(
        find.semantics.byLabel('Home'),
        SemanticsAction.tap,
      );
      await tester.pump();
      expect(selected, 0);

      tester.semantics.performAction(
        find.semantics.byLabel('Profile'),
        SemanticsAction.tap,
      );
      await tester.pump();
      expect(selected, 2);

      handle.dispose();
    });
  });
}
