import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:liquid_glass_widgets/src/widgets/surfaces/tab_bar_searchable_internal.dart';
import 'package:liquid_glass_widgets/src/widgets/surfaces/tab_bar_searchable_layout.dart';

import '../../shared/test_helpers.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

const _testTabs = [
  GlassTab(label: 'For You', icon: Icon(CupertinoIcons.news)),
  GlassTab(label: 'Following', icon: Icon(CupertinoIcons.person_2)),
  GlassTab(label: 'Saved', icon: Icon(CupertinoIcons.bookmark)),
];

Widget _buildBar({
  bool minimized = false,
  int selectedIndex = 0,
  ValueChanged<int>? onTabSelected,
  VoidCallback? onMinimizedTabTap,
  GlassTabBarTrailingButton? trailingButton,
  Color? selectedIconColor,
  Color? unselectedIconColor,
}) {
  return createTestApp(
    child: GlassTabBar.minimizable(
      tabs: _testTabs,
      selectedIndex: selectedIndex,
      onTabSelected: onTabSelected ?? (_) {},
      minimized: minimized,
      onMinimizedTabTap: onMinimizedTabTap,
      trailingButton: trailingButton,
      selectedIconColor: selectedIconColor,
      unselectedIconColor: unselectedIconColor,
      maskingQuality: MaskingQuality.off, // no dual-layer in tests
    ),
  );
}

GlassTabBarTrailingButton _trailingButton({VoidCallback? onTap}) {
  return GlassTabBarTrailingButton(
    icon: const Icon(CupertinoIcons.square_pencil),
    onTap: onTap ?? () {},
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('GlassTabBar.minimizable', () {
    // ── Instantiation ─────────────────────────────────────────────────────────

    testWidgets('can be instantiated with required parameters', (tester) async {
      await tester.pumpWidget(_buildBar());
      expect(find.byType(GlassTabBar), findsOneWidget);
    });

    testWidgets(
        'forwards backgroundQuality to underlying TabBarSearchableLayout',
        (tester) async {
      await tester.pumpWidget(createTestApp(
        child: GlassTabBar.minimizable(
          tabs: _testTabs,
          selectedIndex: 0,
          onTabSelected: (_) {},
          quality: GlassQuality.premium,
          backgroundQuality: GlassQuality.minimal,
        ),
      ));
      await tester.pump();

      final layout = tester.widget<TabBarSearchableLayout>(
        find.byType(TabBarSearchableLayout),
      );
      expect(layout.backgroundQuality, equals(GlassQuality.minimal));
    });

    testWidgets('propagates backgroundQuality to MinimizableTrailingPill',
        (tester) async {
      await tester.pumpWidget(createTestApp(
        child: GlassTabBar.minimizable(
          tabs: _testTabs,
          selectedIndex: 0,
          onTabSelected: (_) {},
          quality: GlassQuality.premium,
          backgroundQuality: GlassQuality.minimal,
          trailingButton: _trailingButton(),
        ),
      ));
      await tester.pump();

      final pill = tester.widget<MinimizableTrailingPill>(
        find.byType(MinimizableTrailingPill),
      );
      expect(pill.quality, equals(GlassQuality.minimal));
    });

    testWidgets('displays tab labels while expanded', (tester) async {
      await tester.pumpWidget(_buildBar());
      await tester.pump();

      expect(find.text('For You'), findsWidgets);
      expect(find.text('Following'), findsWidgets);
      expect(find.text('Saved'), findsWidgets);
    });

    testWidgets('minimized shows the selected tab\'s icon in the circle',
        (tester) async {
      await tester.pumpWidget(_buildBar(minimized: true, selectedIndex: 2));
      await tester.pumpAndSettle();

      expect(find.byIcon(CupertinoIcons.bookmark), findsAtLeastNWidgets(1));
    });

    testWidgets('minimized circle draws the icon in selectedIconColor',
        (tester) async {
      await tester.pumpWidget(_buildBar(
        minimized: true,
        selectedIndex: 2,
        selectedIconColor: const Color(0xFFFF0000),
        unselectedIconColor: const Color(0xFF0000FF),
      ));
      await tester.pumpAndSettle();

      final iconTheme = tester.widget<IconTheme>(
        find
            .ancestor(
              of: find.byIcon(CupertinoIcons.bookmark),
              matching: find.byType(IconTheme),
            )
            .first,
      );
      expect(iconTheme.data.color, const Color(0xFFFF0000));
    });

    // ── Trailing button: none (plain minimizing bar) ──────────────────────────

    testWidgets('renders no trailing pill in either state without a button',
        (tester) async {
      await tester.pumpWidget(_buildBar());
      await tester.pump();
      expect(find.byIcon(CupertinoIcons.search), findsNothing);
      expect(find.byIcon(CupertinoIcons.square_pencil), findsNothing);

      await tester.pumpWidget(_buildBar(minimized: true));
      await tester.pumpAndSettle();
      expect(find.byIcon(CupertinoIcons.search), findsNothing);
      expect(find.byIcon(CupertinoIcons.square_pencil), findsNothing);
    });

    // ── Trailing button: present (Tab(role: .search) behavior) ────────────────

    testWidgets('trailing button is present in both states', (tester) async {
      await tester.pumpWidget(_buildBar(trailingButton: _trailingButton()));
      await tester.pump();
      expect(
          find.byIcon(CupertinoIcons.square_pencil), findsAtLeastNWidgets(1));

      await tester.pumpWidget(
        _buildBar(minimized: true, trailingButton: _trailingButton()),
      );
      await tester.pumpAndSettle();
      expect(
          find.byIcon(CupertinoIcons.square_pencil), findsAtLeastNWidgets(1));
    });

    // ── Trailing button: app-driven minimized-only pattern ────────────────────
    //
    // The package models only the native behaviors; an app that wants a
    // button ONLY while minimized composes it by passing [trailingButton]
    // conditionally, in the same rebuild that flips [minimized]. The bar
    // animates the difference: the button spring-scales in at its slot as
    // the tab pill shrinks, and unmounts once it has scaled away.

    testWidgets('a conditionally passed button springs in with the minimize',
        (tester) async {
      await tester.pumpWidget(_buildBar());
      await tester.pump();
      expect(find.byIcon(CupertinoIcons.square_pencil), findsNothing);

      await tester.pumpWidget(
        _buildBar(minimized: true, trailingButton: _trailingButton()),
      );
      // The appear scale is spring-driven; a couple of frames in, the pill
      // is mounted and visible.
      await tester.pump(const Duration(milliseconds: 100));
      expect(
          find.byIcon(CupertinoIcons.square_pencil), findsAtLeastNWidgets(1));
    });

    testWidgets('a conditionally removed button unmounts with the expand',
        (tester) async {
      await tester.pumpWidget(
        _buildBar(minimized: true, trailingButton: _trailingButton()),
      );
      await tester.pump();
      expect(
          find.byIcon(CupertinoIcons.square_pencil), findsAtLeastNWidgets(1));

      await tester.pumpWidget(_buildBar());
      await tester.pumpAndSettle();
      expect(find.byIcon(CupertinoIcons.square_pencil), findsNothing);
    });

    testWidgets('a removed button keeps its own icon while disappearing',
        (tester) async {
      await tester.pumpWidget(_buildBar(trailingButton: _trailingButton()));
      await tester.pump();

      await tester.pumpWidget(_buildBar(trailingButton: null));
      // Mid-disappear the pill is still mounted and scaling away. It must
      // render the button it WAS — deriving content from the now-null button
      // would drop the icon and swap the collapsed slot to the config's
      // default search glyph for its last few frames. (The pill's hidden
      // expanded row always contains a search icon at zero opacity, so the
      // meaningful assertion is the button's own icon surviving, not the
      // search icon's absence.)
      await tester.pump(const Duration(milliseconds: 50));
      expect(
          find.byIcon(CupertinoIcons.square_pencil), findsAtLeastNWidgets(1));

      await tester.pumpAndSettle();
      expect(find.byIcon(CupertinoIcons.square_pencil), findsNothing);
    });

    // ── Taps ──────────────────────────────────────────────────────────────────

    testWidgets('tapping the trailing button calls onTap', (tester) async {
      var taps = 0;

      await tester.pumpWidget(
        _buildBar(
          minimized: true,
          trailingButton: _trailingButton(onTap: () => taps++),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(CupertinoIcons.square_pencil).first);
      await tester.pumpAndSettle();

      expect(taps, 1);
    });

    testWidgets('tapping the minimized tab circle calls onMinimizedTabTap',
        (tester) async {
      var taps = 0;

      await tester.pumpWidget(
        _buildBar(minimized: true, onMinimizedTabTap: () => taps++),
      );
      await tester.pumpAndSettle();

      // The minimized circle carries the selected tab's icon.
      await tester.tap(find.byIcon(CupertinoIcons.news).first);
      await tester.pumpAndSettle();

      expect(taps, 1);
    });

    // ── Trailing button: menu mode (Issue #275) ──────────────────────────────

    test('GlassTabBarTrailingButton.menu constructor sets properties correctly',
        () {
      final button = GlassTabBarTrailingButton.menu(
        icon: const Icon(CupertinoIcons.ellipsis),
        label: 'Actions',
        menuWidth: 240,
        menuAlignment: GlassMenuAlignment.topLeft,
        menuItems: [
          GlassMenuItem(
            icon: const Icon(CupertinoIcons.share),
            title: 'Share',
            onTap: () {},
          ),
        ],
      );

      expect(button.isMenu, isTrue);
      expect(button.label, 'Actions');
      expect(button.enabled, isTrue);
      expect(button.menuWidth, 240);
      expect(button.menuAlignment, GlassMenuAlignment.topLeft);
      expect(button.menuItems?.length, 1);
      expect(() => button.onTap(), returnsNormally);
    });

    testWidgets('tapping trailing button in menu mode opens GlassMenu',
        (tester) async {
      var itemTapped = false;

      final menuButton = GlassTabBarTrailingButton.menu(
        icon: const Icon(CupertinoIcons.ellipsis),
        label: 'Options',
        menuItems: [
          GlassMenuItem(
            icon: const Icon(CupertinoIcons.share),
            title: 'Share Action',
            onTap: () => itemTapped = true,
          ),
          GlassMenuItem(
            icon: const Icon(CupertinoIcons.trash),
            title: 'Delete Action',
            isDestructive: true,
            onTap: () {},
          ),
        ],
      );

      await tester.pumpWidget(_buildBar(trailingButton: menuButton));
      await tester.pumpAndSettle();

      // Menu items should not be visible before tap
      expect(find.text('Share Action'), findsNothing);

      // Tap the trailing menu pill
      await tester.tap(find.byIcon(CupertinoIcons.ellipsis).first);
      await tester.pumpAndSettle();

      // Menu overlay is now open and items are visible
      expect(find.text('Share Action'), findsOneWidget);
      expect(find.text('Delete Action'), findsOneWidget);

      // Tap a menu item
      await tester.tap(find.text('Share Action'));
      await tester.pumpAndSettle();

      expect(itemTapped, isTrue);
      // Menu should be dismissed
      expect(find.text('Share Action'), findsNothing);
    });

    testWidgets('disabled trailing menu button does not open menu on tap',
        (tester) async {
      final menuButton = GlassTabBarTrailingButton.menu(
        icon: const Icon(CupertinoIcons.ellipsis),
        enabled: false,
        menuItems: [
          GlassMenuItem(
            icon: const Icon(CupertinoIcons.share),
            title: 'Share Action',
            onTap: () {},
          ),
        ],
      );

      await tester.pumpWidget(_buildBar(trailingButton: menuButton));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(CupertinoIcons.ellipsis).first);
      await tester.pumpAndSettle();

      expect(find.text('Share Action'), findsNothing);
    });

    // ── preferredSize ─────────────────────────────────────────────────────────

    test('preferredSize follows minimizedBarHeight while minimized', () {
      final expanded = GlassTabBar.minimizable(
        tabs: _testTabs,
        selectedIndex: 0,
        onTabSelected: _noopInt,
        minimizedBarHeight: 44,
      );
      final minimized = GlassTabBar.minimizable(
        tabs: _testTabs,
        selectedIndex: 0,
        onTabSelected: _noopInt,
        minimized: true,
        minimizedBarHeight: 44,
      );

      // barHeight 64 + verticalPadding 20 * 2 / minimizedBarHeight 44 + 40.
      expect(expanded.preferredSize.height, 104);
      expect(minimized.preferredSize.height, 84);
    });
  });
}

void _noopInt(int _) {}
