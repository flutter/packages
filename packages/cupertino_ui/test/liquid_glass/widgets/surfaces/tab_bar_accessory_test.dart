import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:liquid_glass_widgets/src/widgets/surfaces/tab_bar_searchable_layout.dart';

void main() {
  group('GlassTabBar Accessory iOS 26 Layout', () {
    testWidgets('searchable placement uses TweenAnimationBuilder',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GlassTabBar.searchable(
              isSearchActive: false,
              tabs: const [GlassTab(label: '1'), GlassTab(label: '2')],
              selectedIndex: 0,
              onTabSelected: (_) {},
              searchConfig: GlassSearchBarConfig(
                onSearchToggle: (_) {},
              ),
              bottomAccessory:
                  const SizedBox(height: 50, width: 100, key: Key('acc')),
              bottomAccessoryHeight: 50,
            ),
          ),
        ),
      );

      expect(find.byKey(const Key('acc')), findsOneWidget);
      // In searchable mode, TweenAnimationBuilder is used for the accessory animation.
      expect(find.byType(TweenAnimationBuilder<double>), findsWidgets);

      // Test the preferredSize computation.
      var tabBar = tester.widget<GlassTabBar>(find.byType(GlassTabBar));
      // isSearchActive: false → effectivePillH = barHeight(64) + vertPad(20*2) = 104
      // gapAdjustment = 0 (not searching)
      // total = 104 + spacing(6) + accessory(50) = 160
      expect(tabBar.preferredSize.height, 160.0);

      // Rebuild in inline mode
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GlassTabBar.searchable(
              isSearchActive: true,
              tabs: const [GlassTab(label: '1'), GlassTab(label: '2')],
              selectedIndex: 0,
              onTabSelected: (_) {},
              searchBarHeight: 36, // Explicitly match my mental calculation
              searchConfig: GlassSearchBarConfig(
                onSearchToggle: (_) {},
              ),
              bottomAccessory:
                  const SizedBox(height: 50, width: 100, key: Key('acc')),
              bottomAccessoryHeight: 50,
            ),
          ),
        ),
      );

      tabBar = tester.widget<GlassTabBar>(find.byType(GlassTabBar));
      // isSearchActive: true, no explicit placement → stays expanded (no auto-collapse)
      // effectivePillH = searchBarHeight(36) + vertPad(40) = 76
      // gapAdjustment = barHeight(64) - searchBarHeight(36) = 28
      // total = 76 - 28 + spacing(6) + accessory(50) = 104
      expect(tabBar.preferredSize.height, 104.0);
    });

    testWidgets(
        'searchable placement can be overridden by bottomAccessoryPlacement',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GlassTabBar.searchable(
              isSearchActive: true, // Tabs collapsed
              bottomAccessoryPlacement: GlassTabBarAccessoryPlacement
                  .expanded, // But accessory above!
              tabs: const [GlassTab(label: '1'), GlassTab(label: '2')],
              selectedIndex: 0,
              onTabSelected: (_) {},
              searchBarHeight: 36,
              searchConfig: GlassSearchBarConfig(
                onSearchToggle: (_) {},
              ),
              bottomAccessory:
                  const SizedBox(height: 50, width: 100, key: Key('acc')),
              bottomAccessoryHeight: 50,
            ),
          ),
        ),
      );

      final tabBar = tester.widget<GlassTabBar>(find.byType(GlassTabBar));
      // Base search bar height (36) + vertical padding (20) * 2 = 76
      // Gap adjustment: barHeight (64) - searchBarHeight (36) = 28
      // PLUS accessory height (50) + spacing (6)
      // Total = 76 - 28 + 6 + 50 = 104.0
      expect(tabBar.preferredSize.height, 104.0);
    });
  });

  group('GlassTabBar.bottom accessory & scaffolding', () {
    testWidgets('provides correct placement and sizes scaffolding',
        (tester) async {
      final scrollController = ScrollController();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView(
              controller: scrollController,
              children: List.generate(
                  100, (i) => SizedBox(height: 50, child: Text('Item $i'))),
            ),
            bottomNavigationBar: GlassTabBar.bottom(
              tabs: const [GlassTab(label: '1')],
              selectedIndex: 0,
              scrollController: scrollController,
              onTabSelected: (_) {},
              extraButton: GlassTabBarExtraButton(
                icon: const Icon(Icons.add),
                onTap: () {},
                label: 'Add',
              ),
              bottomAccessory: Builder(builder: (context) {
                final placement =
                    GlassTabBarAccessoryPlacementScope.of(context);
                return Text(
                  placement.name,
                  textDirection: TextDirection.ltr,
                );
              }),
              bottomAccessoryHeight: 50,
            ),
          ),
        ),
      );

      // Placement is always expanded — collapse is no longer available.
      expect(find.text('expanded'), findsOneWidget);

      // Scroll down: placement stays expanded (minimizable is separate API).
      await tester.drag(find.byType(ListView), const Offset(0, -500));
      await tester.pumpAndSettle();

      expect(find.text('expanded'), findsOneWidget);
    });

    testWidgets('GlassScaffold safely resolves PreferredSizeWidget bottomBar',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: GlassScaffold(
            body: const SizedBox(),
            bottomBar: GlassTabBar.bottom(
              tabs: const [GlassTab(label: '1')],
              selectedIndex: 0,
              onTabSelected: (_) {},
              bottomAccessory: const SizedBox(height: 50),
              bottomAccessoryHeight: 50,
            ),
          ),
        ),
      );

      // If GlassScaffold doesn't crash on layout, the PreferredSizeWidget
      // resolution path was covered successfully.
      expect(find.byType(GlassScaffold), findsOneWidget);
    });
  });

  group('minimizable inline accessory trailing slot', () {
    // Regression for #264. The inline geometry was written against the
    // searchable placement, where a trailing capsule always exists. On
    // `minimizable` the capsule is optional (`showPill: trailingButton != null`),
    // so reserving its width unconditionally left a gap nothing could fill —
    // and nothing in the public API could recover it.
    Widget host({GlassTabBarTrailingButton? trailingButton}) => MaterialApp(
          home: Scaffold(
            body: Align(
              alignment: Alignment.bottomCenter,
              child: GlassTabBar.minimizable(
                tabs: const [GlassTab(label: '1'), GlassTab(label: '2')],
                selectedIndex: 0,
                onTabSelected: (_) {},
                minimized: true,
                trailingButton: trailingButton,
                bottomAccessoryPlacement: GlassTabBarAccessoryPlacement.inline,
                bottomAccessory: const SizedBox(key: Key('acc'), height: 50),
                bottomAccessoryHeight: 50,
              ),
            ),
          ),
        );

    testWidgets('reaches the trailing edge when there is no trailing button',
        (tester) async {
      await tester.pumpWidget(host());
      await tester.pumpAndSettle();

      final bar = tester.getRect(find.byType(GlassTabBar));
      final accessory = tester.getRect(find.byKey(const Key('acc')));

      // Symmetric with the leading inset the bar already applies.
      expect(bar.right - accessory.right, closeTo(20.0, 0.5));
    });

    testWidgets('still clears the trailing button when one is present',
        (tester) async {
      await tester.pumpWidget(host(
        trailingButton: GlassTabBarTrailingButton(
          icon: const Icon(Icons.add),
          onTap: () {},
        ),
      ));
      await tester.pumpAndSettle();

      final bar = tester.getRect(find.byType(GlassTabBar));
      final accessory = tester.getRect(find.byKey(const Key('acc')));

      // horizontalPadding(20) + searchBarHeight(50) + spacing(6)
      expect(bar.right - accessory.right, closeTo(76.0, 0.5));
    });

    testWidgets(
        'trailing button and minimized tab taps invoke correct callbacks',
        (tester) async {
      bool trailingTapped = false;
      bool tabTapped = false;

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: GlassTabBar.minimizable(
            tabs: const [
              GlassTab(label: '1', icon: Icon(Icons.home)),
              GlassTab(label: '2', icon: Icon(Icons.star)),
            ],
            selectedIndex: 0,
            onTabSelected: (_) {},
            minimized: true,
            onMinimizedTabTap: () => tabTapped = true,
            trailingButton: GlassTabBarTrailingButton(
              icon: const Icon(Icons.add),
              onTap: () => trailingTapped = true,
            ),
          ),
        ),
      ));
      await tester.pumpAndSettle();

      // Tap the trailing button
      expect(find.byIcon(Icons.add), findsOneWidget);
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();
      expect(trailingTapped, isTrue);

      // Tap the minimized tab pill
      expect(find.byIcon(Icons.home), findsOneWidget);
      await tester.tap(find.byIcon(Icons.home));
      await tester.pumpAndSettle();
      expect(tabTapped, isTrue);
    });

    testWidgets('dynamic trailingButton toggle mounts and unmounts cleanly',
        (tester) async {
      bool showButton = false;

      await tester.pumpWidget(StatefulBuilder(
        builder: (context, setState) {
          return MaterialApp(
            home: Scaffold(
              body: Column(
                children: [
                  ElevatedButton(
                    onPressed: () => setState(() => showButton = !showButton),
                    child: const Text('toggle'),
                  ),
                  GlassTabBar.minimizable(
                    tabs: const [GlassTab(label: '1'), GlassTab(label: '2')],
                    selectedIndex: 0,
                    onTabSelected: (_) {},
                    minimized: true,
                    trailingButton: showButton
                        ? GlassTabBarTrailingButton(
                            icon: const Icon(Icons.add),
                            onTap: () {},
                          )
                        : null,
                  ),
                ],
              ),
            ),
          );
        },
      ));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.add), findsNothing);

      // Toggle ON
      await tester.tap(find.text('toggle'));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.add), findsOneWidget);

      // Toggle OFF
      await tester.tap(find.text('toggle'));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.add), findsNothing);
    });

    testWidgets(
        'MinimizableTrailingPill resolves CupertinoDynamicColor in dark mode',
        (tester) async {
      await tester.pumpWidget(
        CupertinoApp(
          theme: const CupertinoThemeData(brightness: Brightness.dark),
          home: CupertinoPageScaffold(
            child: GlassTabBar.minimizable(
              tabs: const [GlassTab(label: '1'), GlassTab(label: '2')],
              selectedIndex: 0,
              onTabSelected: (_) {},
              minimized: true,
              unselectedIconColor: CupertinoColors.label,
              trailingButton: GlassTabBarTrailingButton(
                icon: const Icon(CupertinoIcons.square_pencil),
                onTap: () {},
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byIcon(CupertinoIcons.square_pencil), findsOneWidget);
    });

    testWidgets(
        'TabBarSearchableLayout asserts when both searchConfig and trailingButton are provided',
        (tester) async {
      expect(
        () => TabBarSearchableLayout(
          tabs: const [GlassTab(label: '1')],
          selectedIndex: 0,
          onTabSelected: (_) {},
          searchConfig: GlassSearchBarConfig(onSearchToggle: (_) {}),
          trailingButton: GlassTabBarTrailingButton(
            icon: const Icon(Icons.add),
            onTap: () {},
          ),
        ),
        throwsA(isA<AssertionError>()),
      );
    });

    testWidgets(
        'searchConfig.onSearchFocusChanged is triggered on focus change',
        (tester) async {
      bool? lastFocus;
      final focusNode = FocusNode();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GlassTabBar.searchable(
              tabs: const [GlassTab(label: 'A'), GlassTab(label: 'B')],
              selectedIndex: 0,
              onTabSelected: (_) {},
              isSearchActive: true,
              searchConfig: GlassSearchBarConfig(
                focusNode: focusNode,
                onSearchToggle: (_) {},
                onSearchFocusChanged: (f) => lastFocus = f,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      focusNode.requestFocus();
      await tester.pumpAndSettle();
      expect(lastFocus, isTrue);

      focusNode.unfocus();
      await tester.pumpAndSettle();
      expect(lastFocus, isFalse);

      focusNode.dispose();
    });
  });
}
