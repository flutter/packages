// ignore: unnecessary_import
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

void main() {
  group('GlassButtonGroup', () {
    testWidgets('renders children in horizontal direction by default',
        (tester) async {
      await tester.pumpWidget(
        CupertinoApp(
          home: Center(
            child: GlassButtonGroup(
              children: [
                GlassButton(
                  icon: const Icon(CupertinoIcons.add),
                  style: GlassButtonStyle.transparent,
                  onTap: () {},
                ),
                GlassButton(
                  icon: const Icon(CupertinoIcons.minus),
                  style: GlassButtonStyle.transparent,
                  onTap: () {},
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(GlassButtonGroup), findsOneWidget);
      expect(find.byType(GlassContainer), findsOneWidget);
      expect(find.byType(Flex), findsOneWidget);

      final Flex flex = tester.widget(find.byType(Flex));
      expect(flex.direction, Axis.horizontal);

      // Should find the two buttons
      expect(find.byType(GlassButton), findsNWidgets(2));

      // Should find the divider by default
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('renders children in vertical direction', (tester) async {
      await tester.pumpWidget(
        CupertinoApp(
          home: Center(
            child: GlassButtonGroup(
              direction: Axis.vertical,
              children: [
                GlassButton(
                  icon: const Icon(CupertinoIcons.add),
                  style: GlassButtonStyle.transparent,
                  onTap: () {},
                ),
                GlassButton(
                  icon: const Icon(CupertinoIcons.minus),
                  style: GlassButtonStyle.transparent,
                  onTap: () {},
                ),
              ],
            ),
          ),
        ),
      );

      final Flex flex = tester.widget(find.byType(Flex));
      expect(flex.direction, Axis.vertical);
    });

    testWidgets('suppresses dividers when showDividers is false',
        (tester) async {
      await tester.pumpWidget(
        CupertinoApp(
          home: Center(
            child: GlassButtonGroup(
              showDividers: false,
              children: [
                GlassButton(
                  icon: const Icon(CupertinoIcons.add),
                  style: GlassButtonStyle.transparent,
                  onTap: () {},
                ),
                GlassButton(
                  icon: const Icon(CupertinoIcons.minus),
                  style: GlassButtonStyle.transparent,
                  onTap: () {},
                ),
              ],
            ),
          ),
        ),
      );

      // In children mode with showDividers: false, no Container dividers should be added
      // Note: children might contain containers natively but the explicit divider is a Container with width/height 1
      final containers = tester.widgetList<Container>(find.byType(Container));
      final hasDivider = containers.any((c) =>
          (c.constraints?.maxWidth == 1.0) ||
          (c.constraints?.maxHeight == 1.0));
      expect(hasDivider, isFalse);
    });
  });

  group('GlassButtonGroup.icons', () {
    testWidgets('renders lightweight items properly', (tester) async {
      int tapCount = 0;

      await tester.pumpWidget(
        CupertinoApp(
          home: Center(
            child: GlassButtonGroup.icons(
              items: [
                GlassButtonGroupItem(
                  icon: const Icon(CupertinoIcons.bold),
                  onTap: () => tapCount++,
                  label: 'Bold',
                ),
                GlassButtonGroupItem(
                  icon: const Icon(CupertinoIcons.italic),
                  onTap: () {},
                  enabled: false,
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(GlassButtonGroup), findsOneWidget);
      // It should wrap in a GlassButton.custom
      expect(find.byType(GlassButton), findsOneWidget);

      // Should find the icons
      expect(find.byIcon(CupertinoIcons.bold), findsOneWidget);
      expect(find.byIcon(CupertinoIcons.italic), findsOneWidget);

      // Should find semantics
      expect(find.bySemanticsLabel('Bold'), findsOneWidget);

      // Tap the first item
      await tester.tap(find.byIcon(CupertinoIcons.bold));
      expect(tapCount, 1);

      // Tap the disabled item (should not trigger anything or crash)
      await tester.tap(find.byIcon(CupertinoIcons.italic));
      // Handled internally by ignoring taps on disabled
    });

    testWidgets('renders lightweight items with dividers if enabled',
        (tester) async {
      await tester.pumpWidget(
        CupertinoApp(
          home: Center(
            child: GlassButtonGroup.icons(
              showDividers: true,
              direction: Axis.vertical,
              items: [
                GlassButtonGroupItem(
                  icon: const Icon(CupertinoIcons.bold),
                  onTap: () {},
                ),
                GlassButtonGroupItem(
                  icon: const Icon(CupertinoIcons.italic),
                  onTap: () {},
                ),
              ],
            ),
          ),
        ),
      );

      final containers = tester.widgetList<Container>(find.byType(Container));
      final hasDivider = containers.any((c) => c.constraints?.maxHeight == 1.0);
      expect(hasDivider, isTrue);
    });
  });

  // ---------------------------------------------------------------------------
  // GlassButtonGroupItem.menu constructor (unit tests)
  // ---------------------------------------------------------------------------

  group('GlassButtonGroupItem.menu constructor', () {
    test('menuItems is non-null', () {
      final item = GlassButtonGroupItem.menu(
        icon: const Icon(CupertinoIcons.ellipsis),
        menuItems: [GlassMenuItem(title: 'Copy', onTap: () {})],
      );
      expect(item.menuItems, isNotNull);
      expect(item.menuItems, hasLength(1));
    });

    test('defaults: menuWidth=200, menuAlignment=null, enabled=true', () {
      final item = GlassButtonGroupItem.menu(
        icon: const Icon(CupertinoIcons.ellipsis),
        menuItems: [],
      );
      expect(item.menuWidth, 200);
      expect(item.menuAlignment, isNull);
      expect(item.enabled, isTrue);
    });

    test('accepts custom menuWidth and menuAlignment', () {
      final item = GlassButtonGroupItem.menu(
        icon: const Icon(CupertinoIcons.ellipsis),
        menuItems: [],
        menuWidth: 280,
        menuAlignment: GlassMenuAlignment.topRight,
      );
      expect(item.menuWidth, 280);
      expect(item.menuAlignment, GlassMenuAlignment.topRight);
    });

    test('accepts GlassMenuDivider alongside GlassMenuItem', () {
      final item = GlassButtonGroupItem.menu(
        icon: const Icon(CupertinoIcons.ellipsis),
        menuItems: [
          GlassMenuItem(title: 'Copy', onTap: () {}),
          GlassMenuDivider(),
          GlassMenuItem(title: 'Delete', isDestructive: true, onTap: () {}),
        ],
      );
      expect(item.menuItems, hasLength(3));
      expect(item.menuItems![0], isA<GlassMenuItem>());
      expect(item.menuItems![1], isA<GlassMenuDivider>());
      expect(item.menuItems![2], isA<GlassMenuItem>());
    });

    test('onTap no-op does not throw', () {
      final item = GlassButtonGroupItem.menu(
        icon: const Icon(CupertinoIcons.ellipsis),
        menuItems: [],
      );
      expect(() => item.onTap(), returnsNormally);
    });

    test('default constructor still has null menuItems', () {
      final item = GlassButtonGroupItem(
          icon: const Icon(CupertinoIcons.add), onTap: () {});
      expect(item.menuItems, isNull);
      expect(item.menuWidth, 200);
    });
  });

  // ---------------------------------------------------------------------------
  // GlassButtonGroup.icons with menu items (widget tests)
  // ---------------------------------------------------------------------------

  group('GlassButtonGroup.icons with GlassButtonGroupItem.menu', () {
    testWidgets('renders mixed group without error', (tester) async {
      await tester.pumpWidget(
        CupertinoApp(
          home: Center(
            child: GlassButtonGroup.icons(
              items: [
                GlassButtonGroupItem(
                  icon: const Icon(CupertinoIcons.chart_bar),
                  onTap: () {},
                ),
                GlassButtonGroupItem.menu(
                  icon: const Icon(CupertinoIcons.ellipsis),
                  menuItems: [
                    GlassMenuItem(title: 'Copy', onTap: () {}),
                    GlassMenuDivider(),
                    GlassMenuItem(
                      title: 'Delete',
                      isDestructive: true,
                      onTap: () {},
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pump();
      expect(find.byIcon(CupertinoIcons.chart_bar), findsOneWidget);
      expect(find.byIcon(CupertinoIcons.ellipsis), findsOneWidget);
    });

    testWidgets('menu item contains a GlassMenu widget', (tester) async {
      await tester.pumpWidget(
        CupertinoApp(
          home: Center(
            child: GlassButtonGroup.icons(
              items: [
                GlassButtonGroupItem.menu(
                  icon: const Icon(CupertinoIcons.ellipsis),
                  menuItems: [GlassMenuItem(title: 'Share', onTap: () {})],
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pump();
      expect(find.byType(GlassMenu), findsOneWidget);
    });
  });

  // ---------------------------------------------------------------------------
  // GlassButtonGroupItem.menu — edge cases
  // ---------------------------------------------------------------------------

  group('GlassButtonGroupItem.menu edge cases', () {
    testWidgets('menu item at index 0 (first position) wraps pill in GlassMenu',
        (tester) async {
      // GlassMenu must appear even when the menu item is the FIRST item,
      // verifying that indexWhere correctly finds index 0.
      await tester.pumpWidget(
        CupertinoApp(
          home: Center(
            child: GlassButtonGroup.icons(
              items: [
                GlassButtonGroupItem.menu(
                  icon: Icon(CupertinoIcons.ellipsis),
                  menuItems: [GlassMenuItem(title: 'Copy', onTap: () {})],
                ),
                GlassButtonGroupItem(
                  icon: Icon(CupertinoIcons.share),
                  onTap: () {},
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pump();
      expect(find.byType(GlassMenu), findsOneWidget);
    });

    testWidgets('non-menu sibling onTap fires independently', (tester) async {
      // Tapping a regular item in a group that also contains a menu item must
      // still call that item's onTap — the menu-trigger wiring must not bleed
      // into adjacent items.
      int tapCount = 0;
      await tester.pumpWidget(
        CupertinoApp(
          home: Center(
            child: GlassButtonGroup.icons(
              items: [
                GlassButtonGroupItem(
                  icon: Icon(CupertinoIcons.chart_bar),
                  onTap: () => tapCount++,
                ),
                GlassButtonGroupItem.menu(
                  icon: Icon(CupertinoIcons.ellipsis),
                  menuItems: [GlassMenuItem(title: 'Copy', onTap: () {})],
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pump();

      // Tap the chart_bar icon (index 0 — the plain tap item)
      await tester.tap(find.byIcon(CupertinoIcons.chart_bar));
      await tester.pump();

      expect(tapCount, 1);
    });

    testWidgets('vertical direction group with menu item renders GlassMenu',
        (tester) async {
      await tester.pumpWidget(
        CupertinoApp(
          home: Center(
            child: GlassButtonGroup.icons(
              direction: Axis.vertical,
              items: [
                GlassButtonGroupItem(
                  icon: Icon(CupertinoIcons.bold),
                  onTap: () {},
                ),
                GlassButtonGroupItem.menu(
                  icon: Icon(CupertinoIcons.ellipsis),
                  menuItems: [GlassMenuItem(title: 'More', onTap: () {})],
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pump();
      expect(find.byType(GlassMenu), findsOneWidget);
      expect(find.byIcon(CupertinoIcons.bold), findsOneWidget);
      expect(find.byIcon(CupertinoIcons.ellipsis), findsOneWidget);
    });
  });

  // ---------------------------------------------------------------------------
  // GlassPullDownButton — List<Widget> items
  // ---------------------------------------------------------------------------

  group('GlassPullDownButton with List<Widget> items', () {
    testWidgets('accepts GlassMenuDivider alongside GlassMenuItem', (
      tester,
    ) async {
      await tester.pumpWidget(
        CupertinoApp(
          home: Center(
            child: GlassPullDownButton(
              items: [
                GlassMenuItem(title: 'Copy', onTap: () {}),
                GlassMenuDivider(),
                GlassMenuItem(
                  title: 'Delete',
                  isDestructive: true,
                  onTap: () {},
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pump();
      expect(find.byType(GlassPullDownButton), findsOneWidget);
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  // Accessibility & Focus
  // ──────────────────────────────────────────────────────────────────────────

  group('GlassButtonGroup keyboard focus & accessibility', () {
    testWidgets('icons mode exposes semantics for items', (tester) async {
      final handle = tester.ensureSemantics();
      try {
        await tester.pumpWidget(
          CupertinoApp(
            home: Center(
              child: GlassButtonGroup.icons(
                items: [
                  GlassButtonGroupItem(
                    label: 'Semantics A',
                    icon: const Icon(CupertinoIcons.bold),
                    onTap: () {},
                  ),
                  GlassButtonGroupItem(
                    label: 'Semantics B',
                    icon: const Icon(CupertinoIcons.italic),
                    onTap: () {},
                    enabled: false,
                  ),
                ],
              ),
            ),
          ),
        );

        final nodeA = tester.getSemantics(find.bySemanticsLabel('Semantics A'));
        debugPrint('NODE A: $nodeA');
        debugDumpFocusTree();
        // ignore: deprecated_member_use
        expect(nodeA.hasFlag(SemanticsFlag.isButton), true);
        // ignore: deprecated_member_use
        expect(nodeA.hasFlag(SemanticsFlag.isEnabled), true);
        // ignore: deprecated_member_use
        expect(nodeA.hasFlag(SemanticsFlag.isFocusable), true);

        final nodeB = tester.getSemantics(find.bySemanticsLabel('Semantics B'));
        // ignore: deprecated_member_use
        expect(nodeB.hasFlag(SemanticsFlag.isButton), true);
        // ignore: deprecated_member_use
        expect(nodeB.hasFlag(SemanticsFlag.isEnabled), false);
        // ignore: deprecated_member_use
        expect(nodeB.hasFlag(SemanticsFlag.isFocusable), false);
      } finally {
        handle.dispose();
      }
    });
  });
}
