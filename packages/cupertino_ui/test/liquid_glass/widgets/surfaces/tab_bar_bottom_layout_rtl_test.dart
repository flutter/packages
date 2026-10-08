import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

import '../../shared/test_helpers.dart';

/// Regression tests for RTL handling in [GlassTabBar.bottom].
///
/// The indicator/gesture coordinate system operates in physical, left-anchored
/// alignment space, while the tab [Row]s honour the ambient [Directionality]
/// and visually reverse under RTL. Before the fix those two disagreed, so under
/// RTL the pill and the tap hit-testing landed on the mirror-image tab — e.g.
/// tapping the first tab (rendered on the trailing/right edge) reported the
/// last index instead of the first.
///
/// Finder note: with [MaskingQuality.off] every label is drawn twice — once in
/// the base (unselected) row and once in the vibrant selected-overlay row — so
/// each label matches two hit-testable widgets. `.hitTestable().first` keeps the
/// occlusion-safe filtering while deterministically resolving to the base row,
/// whose text sits at the tab's real on-screen position.
void main() {
  const tabs = [
    GlassTab(label: 'Home', icon: Icon(CupertinoIcons.home)),
    GlassTab(label: 'Search', icon: Icon(CupertinoIcons.search)),
    GlassTab(label: 'Profile', icon: Icon(CupertinoIcons.person)),
  ];

  Widget rtlBar(
      {required ValueChanged<int> onTabSelected, int selectedIndex = 1}) {
    return createTestApp(
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: GlassTabBar.bottom(
          tabs: tabs,
          selectedIndex: selectedIndex,
          onTabSelected: onTabSelected,
          // Avoid the dual-layer jelly clipping path in tests.
          maskingQuality: MaskingQuality.off,
        ),
      ),
    );
  }

  Widget ltrBar(
      {required ValueChanged<int> onTabSelected, int selectedIndex = 1}) {
    return createTestApp(
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: GlassTabBar.bottom(
          tabs: tabs,
          selectedIndex: selectedIndex,
          onTabSelected: onTabSelected,
          maskingQuality: MaskingQuality.off,
        ),
      ),
    );
  }

  group('GlassTabBar.bottom RTL', () {
    testWidgets('tapping a tab reports its logical index', (tester) async {
      var selected = -1;
      await tester.pumpWidget(rtlBar(onTabSelected: (i) => selected = i));

      // 'Home' is logical index 0; under RTL it renders on the trailing (right)
      // edge. Tapping it must still report index 0 — before the fix the
      // LTR-only hit-testing mirrored this to the last index.
      await tester.tap(find.text('Home').hitTestable().first);
      await tester.pumpAndSettle();
      expect(selected, 0);

      // 'Profile' is logical index 2; under RTL it renders on the leading
      // (left) edge. It must still report index 2.
      await tester.tap(find.text('Profile').hitTestable().first);
      await tester.pumpAndSettle();
      expect(selected, 2);
    });

    testWidgets('first tab renders on the trailing (right) edge', (
      tester,
    ) async {
      await tester.pumpWidget(rtlBar(onTabSelected: (_) {}));

      final screenWidth = tester.getSize(find.byType(GlassTabBar)).width;
      final homeCenter =
          tester.getCenter(find.text('Home').hitTestable().first);
      final profileCenter =
          tester.getCenter(find.text('Profile').hitTestable().first);

      // RTL ordering: the first tab sits to the right of the last tab.
      expect(homeCenter.dx, greaterThan(profileCenter.dx));
      expect(homeCenter.dx, greaterThan(screenWidth / 2));
    });

    testWidgets('a drag reports the tab under the finger, not its mirror', (
      tester,
    ) async {
      var selected = -1;
      await tester.pumpWidget(rtlBar(onTabSelected: (i) => selected = i));

      // Visual order under RTL is Profile | Search | Home, left to right.
      final home = tester.getCenter(find.text('Home').hitTestable().first);
      final search = tester.getCenter(find.text('Search').hitTestable().first);
      expect(home.dx, greaterThan(search.dx));

      await dragAcross(tester, from: search, to: home);

      // The finger finished over 'Home', logical index 0. The tap path never
      // mirrored the pointer, but the drag physics did — so a press landed on
      // the right tab and the slide then ran backwards, reporting 'Profile'.
      expect(selected, 0);
    });

    testWidgets('LTR dragging is unchanged', (tester) async {
      var selected = -1;
      await tester.pumpWidget(ltrBar(onTabSelected: (i) => selected = i));

      final profile =
          tester.getCenter(find.text('Profile').hitTestable().first);
      final search = tester.getCenter(find.text('Search').hitTestable().first);
      expect(profile.dx, greaterThan(search.dx));

      await dragAcross(tester, from: search, to: profile);

      expect(selected, 2);
    });
  });
}

/// Slides a finger from [from] to [to] and releases it standing still, so the
/// velocity fling in `onBarDragEnd` cannot carry the target past the tab the
/// finger actually ended on.
Future<void> dragAcross(
  WidgetTester tester, {
  required Offset from,
  required Offset to,
}) async {
  final gesture = await tester.startGesture(from);
  await tester.pump(const Duration(milliseconds: 16));
  await gesture.moveTo(Offset.lerp(from, to, 0.5)!);
  await tester.pump(const Duration(milliseconds: 16));
  await gesture.moveTo(to);
  await tester.pump(const Duration(milliseconds: 100));
  await gesture.moveTo(to);
  await tester.pump(const Duration(milliseconds: 100));
  await gesture.up();
  await tester.pumpAndSettle();
}
