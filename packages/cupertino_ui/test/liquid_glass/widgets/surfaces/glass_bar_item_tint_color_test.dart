import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:liquid_glass_widgets/widgets/surfaces/shared/glass_nav_pinned_host.dart';

void main() {
  const testTint = Color(0xFFFF9500);
  const testTintSecondary = Color(0xFF007AFF);

  group('GlassBarItem tintColor construction', () {
    test('GlassBarItem.icon stores and exposes tintColor', () {
      final item = GlassBarItem.icon(
        icon: const Icon(CupertinoIcons.add),
        onTap: () {},
        background: GlassBarItemBackground.separate,
        tintColor: testTint,
      ) as GlassBarIconItem;

      expect(item.tintColor, testTint);
      expect(item.background, GlassBarItemBackground.separate);
      expect(item.content, isA<Icon>());
    });

    test('GlassBarItem.icon defaults tintColor to null', () {
      final item = GlassBarItem.icon(
        icon: const Icon(CupertinoIcons.add),
        onTap: () {},
      ) as GlassBarIconItem;

      expect(item.tintColor, isNull);
      expect(item.background, GlassBarItemBackground.shared);
    });

    test('GlassBarItem.custom stores and exposes tintColor', () {
      const childWidget = Text('Custom');
      final item = const GlassBarItem.custom(
        child: childWidget,
        background: GlassBarItemBackground.separate,
        tintColor: testTint,
      ) as GlassBarCustomItem;

      expect(item.tintColor, testTint);
      expect(item.background, GlassBarItemBackground.separate);
      expect(item.content, same(childWidget));
    });

    test('GlassBarItem.custom defaults tintColor to null', () {
      final item = const GlassBarItem.custom(
        child: Text('Custom'),
      ) as GlassBarCustomItem;

      expect(item.tintColor, isNull);
      expect(item.background, GlassBarItemBackground.shared);
    });

    test('GlassBarItem.menu stores and exposes tintColor', () {
      final item = GlassBarItem.menu(
        icon: const Icon(CupertinoIcons.ellipsis),
        menuItems: [GlassMenuItem(title: 'Item', onTap: () {})],
        background: GlassBarItemBackground.separate,
        tintColor: testTint,
      ) as GlassBarMenuItem;

      expect(item.tintColor, testTint);
      expect(item.background, GlassBarItemBackground.separate);
      expect(item.content, isA<Icon>());
    });

    test('GlassBarItem.menu defaults tintColor to null', () {
      final item = GlassBarItem.menu(
        icon: const Icon(CupertinoIcons.ellipsis),
        menuItems: [GlassMenuItem(title: 'Item', onTap: () {})],
      ) as GlassBarMenuItem;

      expect(item.tintColor, isNull);
      expect(item.background, GlassBarItemBackground.shared);
    });

    test('GlassBarItem.sheet stores and exposes tintColor', () {
      final item = GlassBarItem.sheet(
        icon: const Icon(CupertinoIcons.share),
        onPresent: (_) {},
        background: GlassBarItemBackground.separate,
        tintColor: testTint,
      ) as GlassBarSheetItem;

      expect(item.tintColor, testTint);
      expect(item.background, GlassBarItemBackground.separate);
      expect(item.content, isA<Icon>());
    });

    test('GlassBarItem.sheet defaults tintColor to null', () {
      final item = GlassBarItem.sheet(
        icon: const Icon(CupertinoIcons.share),
        onPresent: (_) {},
      ) as GlassBarSheetItem;

      expect(item.tintColor, isNull);
      expect(item.background, GlassBarItemBackground.shared);
    });

    test('default onTap executes safely for custom, menu, and sheet items', () {
      const custom =
          GlassBarItem.custom(child: SizedBox()) as GlassBarActionItem;
      final menu = GlassBarItem.menu(
        icon: const Icon(CupertinoIcons.ellipsis),
        menuItems: const [],
      ) as GlassBarActionItem;
      final sheet = GlassBarItem.sheet(
        icon: const Icon(CupertinoIcons.share),
        onPresent: (_) {},
      ) as GlassBarActionItem;

      expect(custom.onTap, returnsNormally);
      custom.onTap();
      expect(menu.onTap, returnsNormally);
      menu.onTap();
      expect(sheet.onTap, returnsNormally);
      sheet.onTap();
    });

    test('GlassBarItem.spacer constructor creates GlassBarSpacer', () {
      const spacer = GlassBarItem.spacer();
      expect(spacer, isA<GlassBarSpacer>());
    });
  });

  group('groupGlassNavBarItems tintColor assertions and grouping', () {
    test('asserts when tintColor is set on shared icon item', () {
      final item = GlassBarItem.icon(
        icon: const Icon(CupertinoIcons.add),
        onTap: () {},
        background: GlassBarItemBackground.shared,
        tintColor: testTint,
      ) as GlassBarActionItem;

      expect(
        () => groupGlassNavBarItems([item]),
        throwsA(
          isA<AssertionError>().having(
            (e) => e.message,
            'message',
            contains('GlassBarItem.tintColor is only supported'),
          ),
        ),
      );
    });

    test('asserts when tintColor is set on shared custom item', () {
      final item = const GlassBarItem.custom(
        child: Text('Custom'),
        background: GlassBarItemBackground.shared,
        tintColor: testTint,
      ) as GlassBarActionItem;

      expect(
        () => groupGlassNavBarItems([item]),
        throwsA(isA<AssertionError>()),
      );
    });

    test('asserts when tintColor is set on shared menu item', () {
      final item = GlassBarItem.menu(
        icon: const Icon(CupertinoIcons.ellipsis),
        menuItems: const [],
        background: GlassBarItemBackground.shared,
        tintColor: testTint,
      ) as GlassBarActionItem;

      expect(
        () => groupGlassNavBarItems([item]),
        throwsA(isA<AssertionError>()),
      );
    });

    test('asserts when tintColor is set on shared sheet item', () {
      final item = GlassBarItem.sheet(
        icon: const Icon(CupertinoIcons.share),
        onPresent: (_) {},
        background: GlassBarItemBackground.shared,
        tintColor: testTint,
      ) as GlassBarActionItem;

      expect(
        () => groupGlassNavBarItems([item]),
        throwsA(isA<AssertionError>()),
      );
    });

    test('allows tintColor on separate, none, and own items without assertion',
        () {
      final separate = GlassBarItem.icon(
        icon: const Icon(CupertinoIcons.add),
        onTap: () {},
        background: GlassBarItemBackground.separate,
        tintColor: testTint,
      ) as GlassBarActionItem;

      final none = GlassBarItem.icon(
        icon: const Icon(CupertinoIcons.clear),
        onTap: () {},
        background: GlassBarItemBackground.none,
        tintColor: testTint,
      ) as GlassBarActionItem;

      final own = GlassBarItem.icon(
        icon: const Icon(CupertinoIcons.check_mark),
        onTap: () {},
        background: GlassBarItemBackground.own,
        tintColor: testTint,
      ) as GlassBarActionItem;

      expect(
          () => groupGlassNavBarItems([separate, none, own]), returnsNormally);
      final groups = groupGlassNavBarItems([separate, none, own]);
      expect(groups, hasLength(3));
      expect(groups[0].background, GlassBarItemBackground.separate);
      expect(groups[0].items.single.tintColor, testTint);
      expect(groups[1].background, GlassBarItemBackground.none);
      expect(groups[2].background, GlassBarItemBackground.own);
    });

    test('correctly splits mixed runs of shared and tinted separate items', () {
      final shared1 = GlassBarItem.icon(
        icon: const Icon(CupertinoIcons.back),
        onTap: () {},
        background: GlassBarItemBackground.shared,
      ) as GlassBarActionItem;

      final shared2 = GlassBarItem.icon(
        icon: const Icon(CupertinoIcons.forward),
        onTap: () {},
        background: GlassBarItemBackground.shared,
      ) as GlassBarActionItem;

      final separate = GlassBarItem.icon(
        icon: const Icon(CupertinoIcons.bell),
        onTap: () {},
        background: GlassBarItemBackground.separate,
        tintColor: testTint,
      ) as GlassBarActionItem;

      final shared3 = GlassBarItem.icon(
        icon: const Icon(CupertinoIcons.settings),
        onTap: () {},
        background: GlassBarItemBackground.shared,
      ) as GlassBarActionItem;

      final groups =
          groupGlassNavBarItems([shared1, shared2, separate, shared3]);
      expect(groups, hasLength(3));

      // Group 1: shared run of 2 items
      expect(groups[0].background, GlassBarItemBackground.shared);
      expect(groups[0].items, [shared1, shared2]);

      // Group 2: standalone separate item with tint
      expect(groups[1].background, GlassBarItemBackground.separate);
      expect(groups[1].items, [separate]);
      expect(groups[1].items.single.tintColor, testTint);

      // Group 3: flushed shared run of 1 item
      expect(groups[2].background, GlassBarItemBackground.shared);
      expect(groups[2].items, [shared3]);
    });
  });

  group('GlassPinnedBarChrome local rendering with tintColor', () {
    testWidgets(
        'renders GlassButtonGroup with clear bodyMode and tintColor for separate item',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(
              actions: [
                GlassPinnedBarChrome(
                  actions: [
                    GlassBarItem.icon(
                      icon: const Icon(CupertinoIcons.heart_fill),
                      onTap: () {},
                      background: GlassBarItemBackground.separate,
                      tintColor: testTint,
                    ),
                  ],
                  builder: (context, chrome) => Row(children: chrome.actions),
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final buttonGroupFinder = find.byType(GlassButtonGroup);
      expect(buttonGroupFinder, findsOneWidget);

      final buttonGroup = tester.widget<GlassButtonGroup>(buttonGroupFinder);
      expect(buttonGroup.settings, isNotNull);
      expect(buttonGroup.settings!.glassColor, testTint);
      expect(buttonGroup.settings!.bodyMode, GlassBodyMode.clear);
    });

    testWidgets('tinted group keeps buttonSettings under its tint',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(
              actions: [
                GlassPinnedBarChrome(
                  buttonSettings: LiquidGlassSettings.ios27Light,
                  actions: [
                    GlassBarItem.icon(
                      icon: const Icon(CupertinoIcons.checkmark),
                      onTap: () {},
                      background: GlassBarItemBackground.separate,
                      tintColor: testTintSecondary,
                    ),
                  ],
                  builder: (context, chrome) => Row(children: chrome.actions),
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final buttonGroup =
          tester.widget<GlassButtonGroup>(find.byType(GlassButtonGroup));
      expect(
        buttonGroup.settings,
        LiquidGlassSettings.ios27Light.copyWith(
          glassColor: testTintSecondary,
          bodyMode: GlassBodyMode.clear,
        ),
      );
    });

    testWidgets(
        'renders GlassButtonGroup without settings when tintColor is null',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(
              actions: [
                GlassPinnedBarChrome(
                  actions: [
                    GlassBarItem.icon(
                      icon: const Icon(CupertinoIcons.heart),
                      onTap: () {},
                      background: GlassBarItemBackground.separate,
                      tintColor: null,
                    ),
                  ],
                  builder: (context, chrome) => Row(children: chrome.actions),
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final buttonGroupFinder = find.byType(GlassButtonGroup);
      expect(buttonGroupFinder, findsOneWidget);

      final buttonGroup = tester.widget<GlassButtonGroup>(buttonGroupFinder);
      expect(buttonGroup.settings, isNull);
    });

    testWidgets('shared multi-item group renders with null settings',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(
              actions: [
                GlassPinnedBarChrome(
                  actions: [
                    GlassBarItem.icon(
                      icon: const Icon(CupertinoIcons.add),
                      onTap: () {},
                      background: GlassBarItemBackground.shared,
                    ),
                    GlassBarItem.icon(
                      icon: const Icon(CupertinoIcons.search),
                      onTap: () {},
                      background: GlassBarItemBackground.shared,
                    ),
                  ],
                  builder: (context, chrome) => Row(children: chrome.actions),
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final buttonGroupFinder = find.byType(GlassButtonGroup);
      expect(buttonGroupFinder, findsOneWidget);

      final buttonGroup = tester.widget<GlassButtonGroup>(buttonGroupFinder);
      expect(buttonGroup.settings, isNull);
    });

    testWidgets(
        'multiple separate items render distinct GlassButtonGroup with respective tints',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(
              actions: [
                GlassPinnedBarChrome(
                  actions: [
                    GlassBarItem.icon(
                      icon: const Icon(CupertinoIcons.heart),
                      onTap: () {},
                      background: GlassBarItemBackground.separate,
                      tintColor: testTint,
                    ),
                    GlassBarItem.icon(
                      icon: const Icon(CupertinoIcons.bookmark),
                      onTap: () {},
                      background: GlassBarItemBackground.separate,
                      tintColor: testTintSecondary,
                    ),
                  ],
                  builder: (context, chrome) => Row(children: chrome.actions),
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final buttonGroups = tester
          .widgetList<GlassButtonGroup>(find.byType(GlassButtonGroup))
          .toList();
      expect(buttonGroups, hasLength(2));

      expect(buttonGroups[0].settings?.glassColor, testTint);
      expect(buttonGroups[0].settings?.bodyMode, GlassBodyMode.clear);

      expect(buttonGroups[1].settings?.glassColor, testTintSecondary);
      expect(buttonGroups[1].settings?.bodyMode, GlassBodyMode.clear);
    });
  });
}
