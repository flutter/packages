import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('DividerSettings coverage', () {
    test('equality, hashCode, and copyWith', () {
      const d1 = DividerSettings(
        indent: 10,
        endIndent: 10,
        thickness: 2,
        duration: Duration(milliseconds: 200),
        curve: Curves.easeIn,
        isHideAutomatically: false,
      );
      const d2 = DividerSettings(
        indent: 10,
        endIndent: 10,
        thickness: 2,
        duration: Duration(milliseconds: 200),
        curve: Curves.easeIn,
        isHideAutomatically: false,
      );
      const d3 = DividerSettings(indent: 5);

      expect(d1 == d2, isTrue);
      expect(d1 == d3, isFalse);
      expect(d1.hashCode == d2.hashCode, isTrue);

      final copy = d1.copyWith(
        indent: 12,
        endIndent: 14,
        thickness: 3,
        decoration: const BoxDecoration(color: Colors.red),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
        isHideAutomatically: true,
      );

      expect(copy.indent, 12);
      expect(copy.endIndent, 14);
      expect(copy.thickness, 3);
      expect(copy.duration, const Duration(milliseconds: 300));
      expect(copy.curve, Curves.easeOut);
      expect(copy.isHideAutomatically, isTrue);
      expect(copy.decoration?.color, Colors.red);
    });
  });

  group('SearchableBottomBarController & SearchablePillLayout coverage', () {
    test('openSearch, closeSearch, syncSearchActive', () {
      final controller = SearchableBottomBarController();
      expect(controller.isSearchOpen, isFalse);

      int notifyCount = 0;
      controller.addListener(() => notifyCount++);

      // openSearch
      controller.openSearch();
      expect(controller.isSearchOpen, isTrue);
      expect(notifyCount, 1);

      // idempotent openSearch
      controller.openSearch();
      expect(notifyCount, 1);

      // closeSearch
      controller.closeSearch();
      expect(controller.isSearchOpen, isFalse);
      expect(notifyCount, 2);

      // idempotent closeSearch
      controller.closeSearch();
      expect(notifyCount, 2);

      // syncSearchActive
      controller.syncSearchActive(true);
      expect(controller.isSearchOpen, isTrue);
      controller.syncSearchActive(true); // idempotent
      controller.syncSearchActive(false);
      expect(controller.isSearchOpen, isFalse);
    });

    test('SearchablePillLayout field inequalities', () {
      const base = SearchablePillLayout(
        targetTabW: 100,
        targetSearchLeft: 200,
        targetSearchW: 50,
        floatY: 0,
        extraTargetW: 10,
        dismissReserve: 5,
      );
      const diffExtra = SearchablePillLayout(
        targetTabW: 100,
        targetSearchLeft: 200,
        targetSearchW: 50,
        floatY: 0,
        extraTargetW: 20,
        dismissReserve: 5,
      );
      const diffDismiss = SearchablePillLayout(
        targetTabW: 100,
        targetSearchLeft: 200,
        targetSearchW: 50,
        floatY: 0,
        extraTargetW: 10,
        dismissReserve: 15,
      );

      expect(base == diffExtra, isFalse);
      expect(base == diffDismiss, isFalse);
    });
  });

  group('GlassDivider coverage', () {
    testWidgets('vertical and dark mode divider', (tester) async {
      await tester.pumpWidget(
        const CupertinoApp(
          theme: CupertinoThemeData(brightness: Brightness.dark),
          home: Center(
            child: Row(
              children: [
                Text('Left'),
                GlassDivider.vertical(height: 50),
                Text('Right'),
              ],
            ),
          ),
        ),
      );
      await tester.pump();
      expect(find.byType(GlassDivider), findsOneWidget);
    });
  });

  group('GlassListTile coverage', () {
    testWidgets('onTapCancel and pressed highlight', (tester) async {
      await tester.pumpWidget(
        CupertinoApp(
          theme: const CupertinoThemeData(brightness: Brightness.light),
          home: Center(
            child: GlassListTile(
              title: const Text('Item'),
              onTap: () {},
            ),
          ),
        ),
      );

      // Press down to show highlight
      final gesture = await tester
          .startGesture(tester.getCenter(find.byType(GlassListTile)));
      await tester.pump(const Duration(milliseconds: 50));

      // Cancel gesture to trigger onTapCancel
      await gesture.cancel();
      await tester.pumpAndSettle();
      expect(find.text('Item'), findsOneWidget);
    });

    testWidgets('dark mode pressed highlight', (tester) async {
      await tester.pumpWidget(
        CupertinoApp(
          theme: const CupertinoThemeData(brightness: Brightness.dark),
          home: Center(
            child: GlassListTile(
              title: const Text('Item Dark'),
              onTap: () {},
            ),
          ),
        ),
      );

      final gesture = await tester
          .startGesture(tester.getCenter(find.byType(GlassListTile)));
      await tester.pump(const Duration(milliseconds: 50));
      await gesture.up();
      await tester.pumpAndSettle();
      expect(find.text('Item Dark'), findsOneWidget);
    });
  });

  group('GlassChip coverage', () {
    testWidgets('interaction overrides', (tester) async {
      await tester.pumpWidget(
        const CupertinoApp(
          home: Center(
            child: GlassChip(
              label: 'Chip',
              interactionScale: 1.08,
              anchorStretch: false,
              anchorStretchSettings: AnchorStretchSettings(intensity: 0.8),
            ),
          ),
        ),
      );
      await tester.pump();
      expect(find.text('Chip'), findsOneWidget);
    });
  });

  group('GlassToolbar coverage', () {
    testWidgets('dark mode divider rendering', (tester) async {
      await tester.pumpWidget(
        const CupertinoApp(
          theme: CupertinoThemeData(brightness: Brightness.dark),
          home: Center(
            child: GlassToolbar(
              children: [Icon(CupertinoIcons.heart)],
            ),
          ),
        ),
      );
      await tester.pump();
      expect(find.byType(GlassToolbar), findsOneWidget);
    });
  });

  group('GlassPage coverage', () {
    testWidgets('edgeToEdge: true and statusBarStyle: none', (tester) async {
      await tester.pumpWidget(
        const CupertinoApp(
          home: GlassPage(
            edgeToEdge: true,
            statusBarStyle: GlassStatusBarStyle.none,
            child: Scaffold(
              body: Center(child: Text('Content')),
            ),
          ),
        ),
      );
      await tester.pump();
      expect(find.text('Content'), findsOneWidget);
    });
  });
}
