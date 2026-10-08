import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

void main() {
  group('TabBarSearchableLayout missing coverage', () {
    testWidgets('custom controller, dismiss pill, and focus callbacks',
        (tester) async {
      final searchCtrl = SearchableBottomBarController();
      int selectedIndex = 0;
      bool cancelTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            // Fake viewInsets to simulate keyboard presence to trigger dismiss pill
            body: MediaQuery(
              data: const MediaQueryData(
                  viewInsets: EdgeInsets.only(bottom: 200)),
              child: StatefulBuilder(
                builder: (context, setState) {
                  return GlassTabBar.searchable(
                    tabs: [GlassTab(label: 'A'), GlassTab(label: 'B')],
                    selectedIndex: selectedIndex,
                    onTabSelected: (i) => setState(() => selectedIndex = i),
                    controller: searchCtrl,
                    isSearchActive: true,
                    searchConfig: GlassSearchBarConfig(
                      showsCancelButton: true,
                      onSearchToggle: (_) {},
                      onSearchFocusChanged: (_) {},
                      onCancelTap: () => cancelTapped = true,
                      cancelIcon: const Icon(Icons.close),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      );

      // Tell controller search is focused
      searchCtrl.onFocusChanged(true);
      await tester.pumpAndSettle();

      // Find the DismissPill or the cancel button by icon
      expect(find.byIcon(Icons.close), findsOneWidget);

      // Tap the cancel button
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      expect(cancelTapped, true);
    });

    testWidgets(
        'collapsed tab pill icon resolves correctly in dark and light modes (#208)',
        (tester) async {
      // 1. Dark mode — icon should resolve to white (CupertinoColors.label.darkColor)
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: Scaffold(
            body: GlassTabBar.searchable(
              tabs: const [
                GlassTab(
                    icon: Icon(Icons.photo_outlined),
                    activeIcon: Icon(Icons.photo),
                    label: 'Home'),
                GlassTab(
                    icon: Icon(Icons.list_alt_outlined),
                    activeIcon: Icon(Icons.list_alt),
                    label: 'List'),
              ],
              selectedIndex: 0,
              onTabSelected: (_) {},
              isSearchActive: true,
              searchConfig: GlassSearchBarConfig(
                onSearchToggle: (_) {},
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final darkIconTheme = tester.widget<IconTheme>(
        find
            .ancestor(
              of: find.byIcon(Icons.photo),
              matching: find.byType(IconTheme),
            )
            .first,
      );
      expect(darkIconTheme.data.color, const Color(0xFFFFFFFF));

      // 2. Light mode — icon should resolve to black (CupertinoColors.label.color)
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: Scaffold(
            body: GlassTabBar.searchable(
              tabs: const [
                GlassTab(
                    icon: Icon(Icons.photo_outlined),
                    activeIcon: Icon(Icons.photo),
                    label: 'Home'),
                GlassTab(
                    icon: Icon(Icons.list_alt_outlined),
                    activeIcon: Icon(Icons.list_alt),
                    label: 'List'),
              ],
              selectedIndex: 0,
              onTabSelected: (_) {},
              isSearchActive: true,
              searchConfig: GlassSearchBarConfig(
                onSearchToggle: (_) {},
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final lightIconTheme = tester.widget<IconTheme>(
        find
            .ancestor(
              of: find.byIcon(Icons.photo),
              matching: find.byType(IconTheme),
            )
            .first,
      );
      expect(lightIconTheme.data.color, const Color(0xFF000000));

      // 3. Custom unselectedIconColor is respected
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: Scaffold(
            body: GlassTabBar.searchable(
              tabs: const [
                GlassTab(
                    icon: Icon(Icons.photo_outlined),
                    activeIcon: Icon(Icons.photo),
                    label: 'Home'),
                GlassTab(
                    icon: Icon(Icons.list_alt_outlined),
                    activeIcon: Icon(Icons.list_alt),
                    label: 'List'),
              ],
              selectedIndex: 0,
              unselectedIconColor: const Color(0xFFFF0000),
              onTabSelected: (_) {},
              isSearchActive: true,
              searchConfig: GlassSearchBarConfig(
                onSearchToggle: (_) {},
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final customIconTheme = tester.widget<IconTheme>(
        find
            .ancestor(
              of: find.byIcon(Icons.photo),
              matching: find.byType(IconTheme),
            )
            .first,
      );
      expect(customIconTheme.data.color, const Color(0xFFFF0000));
    });
  });
}
