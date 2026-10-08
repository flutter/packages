import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

import '../../shared/test_helpers.dart';

void main() {
  const tabs = [
    GlassTab(label: 'Home', icon: Icon(CupertinoIcons.home)),
    GlassTab(label: 'Search', icon: Icon(CupertinoIcons.search)),
    GlassTab(label: 'Profile', icon: Icon(CupertinoIcons.person)),
  ];

  Widget rtlBar({
    required ValueChanged<int> onTabSelected,
    int selectedIndex = 0,
  }) {
    return createTestApp(
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: GlassTabBar.searchable(
          tabs: tabs,
          selectedIndex: selectedIndex,
          onTabSelected: onTabSelected,
          searchConfig: GlassSearchBarConfig(onSearchToggle: (_) {}),
          maskingQuality: MaskingQuality.off,
        ),
      ),
    );
  }

  group('GlassTabBar.searchable RTL', () {
    testWidgets('first tab renders on the trailing (right) edge',
        (tester) async {
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

    testWidgets('tapping a tab reports its logical index', (tester) async {
      var selected = -1;
      await tester.pumpWidget(rtlBar(onTabSelected: (i) => selected = i));

      // 'Home' is logical index 0; under RTL it renders on the trailing (right) edge.
      await tester.tap(find.text('Home').hitTestable().first);
      await tester.pumpAndSettle();
      expect(selected, 0);

      // 'Profile' is logical index 2; under RTL it renders on the leading (left) edge.
      await tester.tap(find.text('Profile').hitTestable().first);
      await tester.pumpAndSettle();
      expect(selected, 2);
    });

    testWidgets('a drag reports the tab under the finger, not its mirror', (
      tester,
    ) async {
      var selected = -1;
      await tester.pumpWidget(
          rtlBar(onTabSelected: (i) => selected = i, selectedIndex: 1));

      // Visual order under RTL is Profile | Search | Home, left to right.
      final home = tester.getCenter(find.text('Home').hitTestable().first);
      final search = tester.getCenter(find.text('Search').hitTestable().first);
      expect(home.dx, greaterThan(search.dx));

      await dragAcross(tester, from: search, to: home);

      expect(selected, 0);
    });

    testWidgets('LTR dragging is unchanged', (tester) async {
      var selected = -1;
      await tester.pumpWidget(
        createTestApp(
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: GlassTabBar.searchable(
              tabs: tabs,
              selectedIndex: 1,
              onTabSelected: (i) => selected = i,
              searchConfig: GlassSearchBarConfig(onSearchToggle: (_) {}),
              maskingQuality: MaskingQuality.off,
            ),
          ),
        ),
      );

      final profile =
          tester.getCenter(find.text('Profile').hitTestable().first);
      final search = tester.getCenter(find.text('Search').hitTestable().first);
      expect(profile.dx, greaterThan(search.dx));

      await dragAcross(tester, from: search, to: profile);

      expect(selected, 2);
    });
  });
}

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
