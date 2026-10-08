// ignore_for_file: invalid_use_of_visible_for_testing_member
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:liquid_glass_widgets/src/widgets/surfaces/tab_bar_bottom_internal.dart';

Widget _wrap(Widget child) => MaterialApp(
      home: Scaffold(body: LiquidGlassWidgets.wrap(child: child)),
    );

GlassTab _tab(String label) =>
    GlassTab(label: label, icon: const Icon(Icons.home));

GlassTab _tabWithGlow(String label) => GlassTab(
      label: label,
      icon: const Icon(Icons.star),
      activeIcon: const Icon(Icons.star_border),
      glowColor: Colors.amber,
      thickness: 1.5,
    );

void main() {
  group('GlassTabBar.bottom — rendering variants', () {
    testWidgets('basic 2-tab bar renders without crash', (tester) async {
      await tester.pumpWidget(_wrap(
        SizedBox(
          height: 100,
          child: GlassTabBar.bottom(
            tabs: [_tab('Home'), _tab('Profile')],
            selectedIndex: 0,
            onTabSelected: (_) {},
          ),
        ),
      ));
      await tester.pump();
      expect(find.text('Home'), findsWidgets);
    });

    testWidgets('tab with glowColor and thickness renders', (tester) async {
      await tester.pumpWidget(_wrap(
        SizedBox(
          height: 100,
          child: GlassTabBar.bottom(
            tabs: [_tabWithGlow('Glow'), _tab('Normal')],
            selectedIndex: 0,
            onTabSelected: (_) {},
          ),
        ),
      ));
      await tester.pump();
      expect(find.text('Glow'), findsWidgets);
    });

    testWidgets('MaskingQuality.off renders simple mode', (tester) async {
      await tester.pumpWidget(_wrap(
        SizedBox(
          height: 100,
          child: GlassTabBar.bottom(
            tabs: [_tab('A'), _tab('B'), _tab('C')],
            selectedIndex: 1,
            onTabSelected: (_) {},
            maskingQuality: MaskingQuality.off,
          ),
        ),
      ));
      await tester.pump();
      expect(find.text('A'), findsWidgets);
    });

    testWidgets('bar with extraButton renders extra btn', (tester) async {
      await tester.pumpWidget(_wrap(
        SizedBox(
          height: 100,
          child: GlassTabBar.bottom(
            tabs: [_tab('Home'), _tab('Profile')],
            selectedIndex: 0,
            onTabSelected: (_) {},
            extraButton: GlassTabBarExtraButton(
              icon: const Icon(Icons.add),
              onTap: () {},
              label: 'Add',
            ),
          ),
        ),
      ));
      await tester.pump();
      expect(find.byType(SizedBox), findsWidgets);
    });

    testWidgets('non-default barBorderRadius passed to extra btn',
        (tester) async {
      await tester.pumpWidget(_wrap(
        SizedBox(
          height: 100,
          child: GlassTabBar.bottom(
            tabs: [_tab('Home'), _tab('Profile')],
            selectedIndex: 0,
            onTabSelected: (_) {},
            barBorderRadius: 10, // not the default 32
            extraButton: GlassTabBarExtraButton(
              icon: const Icon(Icons.add),
              onTap: () {},
              label: 'Add',
            ),
          ),
        ),
      ));
      await tester.pump();
      expect(find.byType(SizedBox), findsWidgets);
    });

    testWidgets(
        'shadow layer renders with infinite barBorderRadius without collapsing',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(brightness: Brightness.light),
          home: Scaffold(
            body: AdaptiveLiquidGlassLayer(
              settings: const LiquidGlassSettings(shadowElevation: 8),
              child: SizedBox(
                height: 100,
                child: GlassTabBar.bottom(
                  tabs: [_tab('Home'), _tab('Profile')],
                  selectedIndex: 0,
                  onTabSelected: (_) {},
                  barBorderRadius: double.infinity,
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(GlassTabBar), findsOneWidget);

      final state = tester.state<TabIndicatorState>(find.byType(TabIndicator));
      final overlay =
          state.buildShadowOverlay(tester.element(find.byType(TabIndicator)));
      expect(overlay, isNotNull);
    });

    testWidgets('standard quality bar renders', (tester) async {
      await tester.pumpWidget(_wrap(
        SizedBox(
          height: 100,
          child: GlassTabBar.bottom(
            tabs: [_tab('Home'), _tab('Settings')],
            selectedIndex: 0,
            onTabSelected: (_) {},
            quality: GlassQuality.standard,
          ),
        ),
      ));
      await tester.pump();
      expect(find.text('Home'), findsWidgets);
    });

    testWidgets('enableBlend defaults to true', (tester) async {
      final bar = GlassTabBar.bottom(
        tabs: [_tab('Home'), _tab('Profile')],
        selectedIndex: 0,
        onTabSelected: (_) {},
      );
      expect(bar.enableBlend, isTrue);
    });

    testWidgets('enableBlend: false renders without crash', (tester) async {
      await tester.pumpWidget(_wrap(
        SizedBox(
          height: 100,
          child: GlassTabBar.bottom(
            tabs: [_tab('Home'), _tab('Profile')],
            selectedIndex: 0,
            onTabSelected: (_) {},
            enableBlend: false,
            extraButton: GlassTabBarExtraButton(
              icon: const Icon(Icons.add),
              onTap: () {},
              label: 'Add',
            ),
          ),
        ),
      ));
      await tester.pump();
      expect(find.text('Home'), findsWidgets);
    });
  });

  group('GlassTabBar.bottom — interaction behavior', () {
    testWidgets('GlassInteractionBehavior.none disables glow and scale',
        (tester) async {
      await tester.pumpWidget(_wrap(
        SizedBox(
          height: 100,
          child: GlassTabBar.bottom(
            tabs: [_tab('X'), _tab('Y')],
            selectedIndex: 0,
            onTabSelected: (_) {},
            interactionBehavior: GlassInteractionBehavior.none,
          ),
        ),
      ));
      await tester.pump();
      expect(find.byType(SizedBox), findsWidgets);
    });

    testWidgets('GlassInteractionBehavior.glowOnly renders', (tester) async {
      await tester.pumpWidget(_wrap(
        SizedBox(
          height: 100,
          child: GlassTabBar.bottom(
            tabs: [_tab('X'), _tab('Y')],
            selectedIndex: 0,
            onTabSelected: (_) {},
            interactionBehavior: GlassInteractionBehavior.glowOnly,
          ),
        ),
      ));
      await tester.pump();
      expect(find.byType(SizedBox), findsWidgets);
    });
  });

  group('GlassTabBar.bottom — tabWidth compact mode', () {
    testWidgets('tabWidth=88 limits pill width', (tester) async {
      await tester.pumpWidget(_wrap(
        SizedBox(
          height: 100,
          child: GlassTabBar.bottom(
            tabs: [_tab('H'), _tab('P'), _tab('S')],
            selectedIndex: 0,
            onTabSelected: (_) {},
            tabWidth: 88,
          ),
        ),
      ));
      await tester.pump();
      expect(find.text('H'), findsWidgets);
    });

    testWidgets('tabWidth=null fills all space', (tester) async {
      await tester.pumpWidget(_wrap(
        SizedBox(
          height: 100,
          child: GlassTabBar.bottom(
            tabs: [_tab('H'), _tab('P')],
            selectedIndex: 0,
            onTabSelected: (_) {},
            tabWidth: null,
          ),
        ),
      ));
      await tester.pump();
      expect(find.byType(SizedBox), findsWidgets);
    });
  });

  group('JellyClipper', () {
    test('shouldReclip returns false for sub-pixel changes', () {
      final c1 = JellyClipper(
        itemCount: 3,
        alignment: const Alignment(0.1, 0),
        thickness: 1.0,
        expansion: const EdgeInsets.all(14.0),
        transform: Matrix4.identity(),
        borderRadius: 32.0,
      );
      final c2 = JellyClipper(
        itemCount: 3,
        alignment: const Alignment(0.1 + 0.0001, 0), // sub-pixel
        thickness: 1.0,
        expansion: const EdgeInsets.all(14.0),
        transform: Matrix4.identity(),
        borderRadius: 32.0,
      );
      expect(c1.shouldReclip(c2), isFalse);
    });

    test('shouldReclip returns true for significant alignment change', () {
      final c1 = JellyClipper(
        itemCount: 3,
        alignment: const Alignment(0.0, 0),
        thickness: 1.0,
        expansion: const EdgeInsets.all(14.0),
        transform: Matrix4.identity(),
        borderRadius: 32.0,
      );
      final c2 = JellyClipper(
        itemCount: 3,
        alignment: const Alignment(0.5, 0),
        thickness: 1.0,
        expansion: const EdgeInsets.all(14.0),
        transform: Matrix4.identity(),
        borderRadius: 32.0,
      );
      expect(c1.shouldReclip(c2), isTrue);
    });

    test('getClip inverse=true produces evenOdd path', () {
      final clipper = JellyClipper(
        itemCount: 2,
        alignment: Alignment.center,
        thickness: 0.5,
        expansion: const EdgeInsets.all(10.0),
        transform: Matrix4.identity(),
        borderRadius: 20.0,
        inverse: true,
      );
      final path = clipper.getClip(const Size(300, 60));
      expect(path.fillType, PathFillType.evenOdd);
    });

    test(
        'shouldReclip returns true when expansion, transform, borderRadius, or inverse differ',
        () {
      final base = JellyClipper(
        itemCount: 3,
        alignment: Alignment.center,
        thickness: 1.0,
        expansion: const EdgeInsets.all(14.0),
        transform: Matrix4.identity(),
        borderRadius: 32.0,
      );

      final diffExpansion = JellyClipper(
        itemCount: 3,
        alignment: Alignment.center,
        thickness: 1.0,
        expansion: const EdgeInsets.all(8.0),
        transform: Matrix4.identity(),
        borderRadius: 32.0,
      );
      expect(base.shouldReclip(diffExpansion), isTrue);

      final diffTransform = JellyClipper(
        itemCount: 3,
        alignment: Alignment.center,
        thickness: 1.0,
        expansion: const EdgeInsets.all(14.0),
        transform: Matrix4.translationValues(1, 1, 0),
        borderRadius: 32.0,
      );
      expect(base.shouldReclip(diffTransform), isTrue);

      final diffBorderRadius = JellyClipper(
        itemCount: 3,
        alignment: Alignment.center,
        thickness: 1.0,
        expansion: const EdgeInsets.all(14.0),
        transform: Matrix4.identity(),
        borderRadius: 16.0,
      );
      expect(base.shouldReclip(diffBorderRadius), isTrue);

      final diffInverse = JellyClipper(
        itemCount: 3,
        alignment: Alignment.center,
        thickness: 1.0,
        expansion: const EdgeInsets.all(14.0),
        transform: Matrix4.identity(),
        borderRadius: 32.0,
        inverse: true,
      );
      expect(base.shouldReclip(diffInverse), isTrue);
    });

    test('getClip right overdrag keeps edge icon inside clip window (#328)',
        () {
      // 3 tabs on a 390 px bar → tabWidth = 130, availableWidth = 260.
      // Maximum right overdrag: alignment.x = 1.6 (rubber-band cap).
      // rawLeft = (1.6 + 1) / 2 * 260 = 338
      // Without fix: clip.left = 338, clip.right = 338 + 130 = 468
      //   → last-tab icon at [260, 390] is only partly covered (left 78px cut)
      // With fix:    clip.left = 260, clip.right = 468
      //   → last-tab icon at [260, 390] is fully inside the clip
      const size = Size(390, 64);
      final clipper = JellyClipper(
        itemCount: 3,
        alignment: const Alignment(1.6, 0), // max right overdrag
        thickness: 1.0,
        expansion: EdgeInsets.zero,
        transform: Matrix4.identity(),
        borderRadius: 24.0,
      );
      final path = clipper.getClip(size);
      // The last tab's icon centre (x = 325) must be inside the clip.
      expect(path.contains(const Offset(325, 32)), isTrue);
      // bounds.left is the padded left edge (baseRect.left + 4 = 260 + 4 = 264).
      // It must be no more than availableWidth + 4 (the padding offset).
      final bounds = path.getBounds();
      expect(bounds.left, lessThanOrEqualTo(264.0));
    });

    test('getClip left overdrag keeps first icon inside clip window (#328)',
        () {
      // 3 tabs on a 390 px bar.
      // Maximum left overdrag: alignment.x = -1.6.
      // rawLeft = (-1.6 + 1) / 2 * 260 = -78
      // Without fix: clip.left = -78, clip.right = -78 + 130 = 52
      //   → first-tab icon at [0, 130]: right portion [52, 130] is outside clip
      // With fix:    clip.left = -78, clip.right = max(52, 130) = 130
      //   → first-tab icon at [0, 130] is fully inside the clip
      const size = Size(390, 64);
      final clipper = JellyClipper(
        itemCount: 3,
        alignment: const Alignment(-1.6, 0), // max left overdrag
        thickness: 1.0,
        expansion: EdgeInsets.zero,
        transform: Matrix4.identity(),
        borderRadius: 24.0,
      );
      final path = clipper.getClip(size);
      // The first tab's icon centre (x = 65) must be inside the clip.
      expect(path.contains(const Offset(65, 32)), isTrue);
      // bounds.right is the padded right edge (baseRect.right - 4 = 130 - 4 = 126).
      // It must be at least tabWidth - 4 (the right pad of the first tab slot).
      final bounds = path.getBounds();
      expect(bounds.right, greaterThanOrEqualTo(126.0));
    });
  });
}
