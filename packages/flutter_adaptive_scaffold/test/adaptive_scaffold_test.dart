// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_adaptive_scaffold/src/adaptive_scaffold.dart';
import 'package:flutter_test/flutter_test.dart';

import 'simulated_layout.dart';
import 'test_breakpoints.dart';

void main() {
  testWidgets('adaptive scaffold lays out slots as expected',
      (WidgetTester tester) async {
    final Finder smallBody = find.byKey(const Key('smallBody'));
    final Finder body = find.byKey(const Key('body'));
    final Finder mediumLargeBody = find.byKey(const Key('mediumLargeBody'));
    final Finder largeBody = find.byKey(const Key('largeBody'));
    final Finder extraLargeBody = find.byKey(const Key('extraLargeBody'));

    final Finder smallSBody = find.byKey(const Key('smallSBody'));
    final Finder sBody = find.byKey(const Key('sBody'));
    final Finder mediumLargeSBody = find.byKey(const Key('mediumLargeSBody'));
    final Finder largeSBody = find.byKey(const Key('largeSBody'));
    final Finder extraLargeSBody = find.byKey(const Key('extraLargeSBody'));

    final Finder bottomNav = find.byKey(const Key('bottomNavigation'));
    final Finder primaryNav = find.byKey(const Key('primaryNavigation'));
    final Finder primaryNav1 = find.byKey(const Key('primaryNavigation1'));
    final Finder primaryNav2 = find.byKey(const Key('primaryNavigation2'));
    final Finder primaryNav3 = find.byKey(const Key('primaryNavigation3'));

    await tester.binding.setSurfaceSize(SimulatedLayout.small.size);
    await tester.pumpWidget(SimulatedLayout.small.scaffold(tester));
    await tester.pumpAndSettle();

    expect(smallBody, findsOneWidget);
    expect(smallSBody, findsOneWidget);
    expect(bottomNav, findsOneWidget);
    expect(primaryNav, findsNothing);

    expect(tester.getTopLeft(smallBody), Offset.zero);
    expect(tester.getTopLeft(smallSBody), const Offset(200, 0));
    expect(tester.getTopLeft(bottomNav), const Offset(0, 1920));

    await tester.binding.setSurfaceSize(SimulatedLayout.medium.size);
    await tester.pumpWidget(SimulatedLayout.medium.scaffold(tester));
    await tester.pumpAndSettle();

    expect(smallBody, findsNothing);
    expect(body, findsOneWidget);
    expect(smallSBody, findsNothing);
    expect(sBody, findsOneWidget);
    expect(bottomNav, findsNothing);
    expect(primaryNav, findsOneWidget);

    expect(tester.getTopLeft(body), const Offset(88, 0));
    expect(tester.getTopLeft(sBody), const Offset(400, 0));
    expect(tester.getTopLeft(primaryNav), Offset.zero);
    expect(tester.getBottomRight(primaryNav), const Offset(88, 2000));

    await tester.binding.setSurfaceSize(SimulatedLayout.mediumLarge.size);
    await tester.pumpWidget(SimulatedLayout.mediumLarge.scaffold(tester));
    await tester.pumpAndSettle();

    expect(body, findsNothing);
    expect(mediumLargeBody, findsOneWidget);
    expect(sBody, findsNothing);
    expect(mediumLargeSBody, findsOneWidget);
    expect(primaryNav, findsNothing);
    expect(primaryNav1, findsOneWidget);

    expect(tester.getTopLeft(mediumLargeBody), const Offset(208, 0));
    expect(tester.getTopLeft(mediumLargeSBody), const Offset(500, 0));
    expect(tester.getTopLeft(primaryNav1), Offset.zero);
    expect(tester.getBottomRight(primaryNav1), const Offset(208, 2000));

    await tester.binding.setSurfaceSize(SimulatedLayout.large.size);
    await tester.pumpWidget(SimulatedLayout.large.scaffold(tester));
    await tester.pumpAndSettle();

    expect(mediumLargeBody, findsNothing);
    expect(largeBody, findsOneWidget);
    expect(mediumLargeSBody, findsNothing);
    expect(largeSBody, findsOneWidget);
    expect(primaryNav1, findsNothing);
    expect(primaryNav2, findsOneWidget);

    expect(tester.getTopLeft(largeBody), const Offset(208, 0));
    expect(tester.getTopLeft(largeSBody), const Offset(600, 0));
    expect(tester.getTopLeft(primaryNav2), Offset.zero);
    expect(tester.getBottomRight(primaryNav2), const Offset(208, 2000));

    await tester.binding.setSurfaceSize(SimulatedLayout.extraLarge.size);
    await tester.pumpWidget(SimulatedLayout.extraLarge.scaffold(tester));
    await tester.pumpAndSettle();

    expect(largeBody, findsNothing);
    expect(extraLargeBody, findsOneWidget);
    expect(largeSBody, findsNothing);
    expect(extraLargeSBody, findsOneWidget);
    expect(primaryNav2, findsNothing);
    expect(primaryNav3, findsOneWidget);

    expect(tester.getTopLeft(extraLargeBody), const Offset(208, 0));
    expect(tester.getTopLeft(extraLargeSBody), const Offset(800, 0));
    expect(tester.getTopLeft(primaryNav3), Offset.zero);
    expect(tester.getBottomRight(primaryNav3), const Offset(208, 2000));
  });

  testWidgets('adaptive scaffold animations work correctly',
      (WidgetTester tester) async {
    final Finder b = find.byKey(const Key('body'));
    final Finder sBody = find.byKey(const Key('sBody'));

    await tester.binding.setSurfaceSize(SimulatedLayout.small.size);
    await tester.pumpWidget(SimulatedLayout.small.scaffold(tester));
    await tester.binding.setSurfaceSize(SimulatedLayout.medium.size);
    await tester.pumpWidget(SimulatedLayout.medium.scaffold(tester));

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(tester.getTopLeft(b), const Offset(17.6, 0));
    expect(tester.getBottomRight(b),
        offsetMoreOrLessEquals(const Offset(778.2, 1936), epsilon: 1.0));
    expect(tester.getTopLeft(sBody),
        offsetMoreOrLessEquals(const Offset(778.2, 0), epsilon: 1.0));
    expect(tester.getBottomRight(sBody),
        offsetMoreOrLessEquals(const Offset(1178.2, 1936), epsilon: 1.0));

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    expect(tester.getTopLeft(b), const Offset(70.4, 0));
    expect(tester.getBottomRight(b),
        offsetMoreOrLessEquals(const Offset(416.0, 1984), epsilon: 1.0));
    expect(tester.getTopLeft(sBody),
        offsetMoreOrLessEquals(const Offset(416, 0), epsilon: 1.0));
    expect(tester.getBottomRight(sBody),
        offsetMoreOrLessEquals(const Offset(816, 1984), epsilon: 1.0));

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(tester.getTopLeft(b), const Offset(88.0, 0));
    expect(tester.getBottomRight(b), const Offset(400, 2000));
    expect(tester.getTopLeft(sBody), const Offset(400, 0));
    expect(tester.getBottomRight(sBody), const Offset(800, 2000));
  });

  testWidgets('adaptive scaffold animations can be disabled',
      (WidgetTester tester) async {
    final Finder b = find.byKey(const Key('body'));
    final Finder sBody = find.byKey(const Key('sBody'));

    await tester.binding.setSurfaceSize(SimulatedLayout.small.size);
    await tester
        .pumpWidget(SimulatedLayout.small.scaffold(tester, animations: false));

    await tester.binding.setSurfaceSize(SimulatedLayout.medium.size);
    await tester
        .pumpWidget(SimulatedLayout.medium.scaffold(tester, animations: false));

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(tester.getTopLeft(b), const Offset(88.0, 0));
    expect(tester.getBottomRight(b), const Offset(400, 2000));
    expect(tester.getTopLeft(sBody), const Offset(400, 0));
    expect(tester.getBottomRight(sBody), const Offset(800, 2000));
  });

  // The goal of this test is to run through each of the navigation elements
  // and test whether tapping on that element will update the selected index
  // globally
  testWidgets('tapping navigation elements calls onSelectedIndexChange',
      (WidgetTester tester) async {
    // for each screen size there is a different navigational element that
    // we want to test tapping to set the selected index
    await Future.forEach(SimulatedLayout.values,
        (SimulatedLayout region) async {
      int selectedIndex = 0;
      final MaterialApp app =
          region.scaffold(tester, initialIndex: selectedIndex);
      await tester.binding.setSurfaceSize(region.size);
      await tester.pumpWidget(app);
      await tester.pumpAndSettle();

      // tap on the next icon
      selectedIndex = (selectedIndex + 1) % TestScaffold.destinations.length;

      // Resolve the icon that should be found
      final NavigationDestination destination =
          TestScaffold.destinations[selectedIndex];
      expect(destination.icon, isA<Icon>());
      final Icon icon = destination.icon as Icon;
      expect(icon.icon, isNotNull);

      // Find the icon in the application to tap
      final Widget navigationSlot =
          tester.widget(find.byKey(Key(region.navSlotKey)));
      final Finder target =
          find.widgetWithIcon(navigationSlot.runtimeType, icon.icon!);
      expect(target, findsOneWidget);

      await tester.tap(target);
      await tester.pumpAndSettle();

      // Check that the state was set appropriately
      final Finder scaffold = find.byType(TestScaffold);
      final TestScaffoldState state = tester.state<TestScaffoldState>(scaffold);
      expect(selectedIndex, state.index);
    });
  });

  // Regression test for https://github.com/flutter/flutter/issues/111008
  testWidgets(
    'appBar parameter should have the type PreferredSizeWidget',
    (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(size: Size(500, 800)),
          child: AdaptiveScaffold(
            drawerBreakpoint: TestBreakpoint0(),
            internalAnimations: false,
            destinations: const <NavigationDestination>[
              NavigationDestination(icon: Icon(Icons.inbox), label: 'Inbox'),
              NavigationDestination(
                  icon: Icon(Icons.video_call), label: 'Video'),
            ],
            appBar: const PreferredSizeWidgetImpl(),
          ),
        ),
      ));

      expect(find.byType(PreferredSizeWidgetImpl), findsOneWidget);
    },
  );

  // Verify that the leading navigation rail widget is displayed
  // based on the screen size
  testWidgets(
    'adaptive scaffold displays leading widget in navigation rail',
    (WidgetTester tester) async {
      await Future.forEach(SimulatedLayout.values,
          (SimulatedLayout region) async {
        final MaterialApp app = region.scaffold(tester);
        await tester.binding.setSurfaceSize(region.size);
        await tester.pumpWidget(app);
        await tester.pumpAndSettle();

        if (region.size == SimulatedLayout.mediumLarge.size) {
          expect(find.text('leading_extended'), findsOneWidget);
          expect(find.text('leading_unextended'), findsNothing);
          expect(find.text('trailing'), findsOneWidget);
        } else if (region.size == SimulatedLayout.medium.size) {
          expect(find.text('leading_extended'), findsNothing);
          expect(find.text('leading_unextended'), findsOneWidget);
          expect(find.text('trailing'), findsOneWidget);
        } else if (region.size == SimulatedLayout.small.size) {
          expect(find.text('leading_extended'), findsNothing);
          expect(find.text('leading_unextended'), findsNothing);
          expect(find.text('trailing'), findsNothing);
        }
      });
    },
  );

  /// Verify that selectedIndex of [AdaptiveScaffold.standardNavigationRail]
  /// and [AdaptiveScaffold] can be set to null
  testWidgets(
    'adaptive scaffold selectedIndex can be set to null',
    (WidgetTester tester) async {
      await Future.forEach(SimulatedLayout.values,
          (SimulatedLayout region) async {
        int? selectedIndex;
        final MaterialApp app =
            region.scaffold(tester, initialIndex: selectedIndex);
        await tester.binding.setSurfaceSize(region.size);
        await tester.pumpWidget(app);
        await tester.pumpAndSettle();
      });
    },
  );

  testWidgets(
    'when destinations passed with all data, it shall not be null',
    (WidgetTester tester) async {
      const List<NavigationDestination> destinations = <NavigationDestination>[
        NavigationDestination(
          icon: Icon(Icons.inbox_outlined),
          selectedIcon: Icon(Icons.inbox),
          label: 'Inbox',
        ),
        NavigationDestination(
          icon: Icon(Icons.video_call_outlined),
          selectedIcon: Icon(Icons.video_call),
          label: 'Video',
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(700, 900)),
            child: AdaptiveScaffold(
              destinations: destinations,
            ),
          ),
        ),
      );

      final Finder fNavigationRail = find.descendant(
        of: find.byType(AdaptiveScaffold),
        matching: find.byType(NavigationRail),
      );
      final NavigationRail navigationRail = tester.firstWidget(fNavigationRail);
      expect(
        navigationRail.destinations,
        isA<List<NavigationRailDestination>>(),
      );
      expect(
        navigationRail.destinations.length,
        destinations.length,
      );

      for (final NavigationRailDestination destination
          in navigationRail.destinations) {
        expect(destination.label, isNotNull);
        expect(destination.icon, isA<Icon>());
        expect(destination.icon, isNotNull);
        expect(destination.selectedIcon, isA<Icon?>());
        expect(destination.selectedIcon, isNotNull);
      }

      final NavigationDestination firstDestinationFromListPassed =
          destinations.first;
      final NavigationRailDestination firstDestinationFromFinderView =
          navigationRail.destinations.first;

      expect(firstDestinationFromListPassed, isNotNull);
      expect(firstDestinationFromFinderView, isNotNull);

      expect(
        firstDestinationFromListPassed.icon,
        equals(firstDestinationFromFinderView.icon),
      );
      expect(
        firstDestinationFromListPassed.selectedIcon,
        equals(firstDestinationFromFinderView.selectedIcon),
      );
    },
  );

  testWidgets(
    'when tap happens on any destination, its selected icon shall be visible',
    (WidgetTester tester) async {
      //region Keys
      const ValueKey<String> firstDestinationIconKey = ValueKey<String>(
        'first-normal-icon',
      );
      const ValueKey<String> firstDestinationSelectedIconKey = ValueKey<String>(
        'first-selected-icon',
      );
      const ValueKey<String> lastDestinationIconKey = ValueKey<String>(
        'last-normal-icon',
      );
      const ValueKey<String> lastDestinationSelectedIconKey = ValueKey<String>(
        'last-selected-icon',
      );
      //endregion

      //region Finder for destinations as per its icon.
      final Finder firstDestinationWithSelectedIcon = find.byKey(
        firstDestinationSelectedIconKey,
      );
      final Finder lastDestinationWithIcon = find.byKey(
        lastDestinationIconKey,
      );

      final Finder firstDestinationWithIcon = find.byKey(
        firstDestinationIconKey,
      );
      final Finder lastDestinationWithSelectedIcon = find.byKey(
        lastDestinationSelectedIconKey,
      );
      //endregion

      int selectedDestination = 0;
      const List<NavigationDestination> destinations = <NavigationDestination>[
        NavigationDestination(
          icon: Icon(
            Icons.inbox_outlined,
            key: firstDestinationIconKey,
          ),
          selectedIcon: Icon(
            Icons.inbox,
            key: firstDestinationSelectedIconKey,
          ),
          label: 'Inbox',
        ),
        NavigationDestination(
          icon: Icon(
            Icons.video_call_outlined,
            key: lastDestinationIconKey,
          ),
          selectedIcon: Icon(
            Icons.video_call,
            key: lastDestinationSelectedIconKey,
          ),
          label: 'Video',
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(700, 900)),
            child: StatefulBuilder(
              builder: (BuildContext context,
                  void Function(void Function()) setState) {
                return AdaptiveScaffold(
                  destinations: destinations,
                  selectedIndex: selectedDestination,
                  onSelectedIndexChange: (int value) {
                    setState(() {
                      selectedDestination = value;
                    });
                  },
                );
              },
            ),
          ),
        ),
      );

      expect(selectedDestination, 0);
      expect(firstDestinationWithSelectedIcon, findsOneWidget);
      expect(lastDestinationWithIcon, findsOneWidget);
      expect(firstDestinationWithIcon, findsNothing);
      expect(lastDestinationWithSelectedIcon, findsNothing);

      await tester.ensureVisible(lastDestinationWithIcon);
      await tester.tap(lastDestinationWithIcon);
      await tester.pumpAndSettle();
      expect(selectedDestination, 1);

      expect(firstDestinationWithSelectedIcon, findsNothing);
      expect(lastDestinationWithIcon, findsNothing);
      expect(firstDestinationWithIcon, findsOneWidget);
      expect(lastDestinationWithSelectedIcon, findsOneWidget);
    },
  );

  testWidgets(
    'when view in medium screen, navigation rail must be visible as per theme data values.',
    (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(SimulatedLayout.medium.size);
      await tester.pumpWidget(SimulatedLayout.medium.scaffold(tester));
      await tester.pumpAndSettle();

      final Finder primaryNavigationMedium = find.byKey(
        const Key('primaryNavigation'),
      );
      expect(primaryNavigationMedium, findsOneWidget);

      final Finder navigationRailFinder = find.descendant(
        of: primaryNavigationMedium,
        matching: find.byType(NavigationRail),
      );
      expect(navigationRailFinder, findsOneWidget);

      final NavigationRail navigationRailView = tester.firstWidget(
        navigationRailFinder,
      );
      expect(navigationRailView, isNotNull);

      expect(
        navigationRailView.backgroundColor,
        SimulatedLayout.navigationRailThemeBgColor,
      );
      expect(
        navigationRailView.selectedIconTheme?.color,
        SimulatedLayout.selectedIconThemeData.color,
      );
      expect(
        navigationRailView.selectedIconTheme?.size,
        SimulatedLayout.selectedIconThemeData.size,
      );
      expect(
        navigationRailView.unselectedIconTheme?.color,
        SimulatedLayout.unSelectedIconThemeData.color,
      );
      expect(
        navigationRailView.unselectedIconTheme?.size,
        SimulatedLayout.unSelectedIconThemeData.size,
      );
    },
  );

  testWidgets(
    'when view in mediumLarge screen, navigation rail must be visible as per theme data values.',
    (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(SimulatedLayout.mediumLarge.size);
      await tester.pumpWidget(SimulatedLayout.mediumLarge.scaffold(tester));
      await tester.pumpAndSettle();

      final Finder primaryNavigationMediumLarge = find.byKey(
        const Key('primaryNavigation1'),
      );
      expect(primaryNavigationMediumLarge, findsOneWidget);

      final Finder navigationRailFinder = find.descendant(
        of: primaryNavigationMediumLarge,
        matching: find.byType(NavigationRail),
      );
      expect(navigationRailFinder, findsOneWidget);

      final NavigationRail navigationRailView = tester.firstWidget(
        navigationRailFinder,
      );
      expect(navigationRailView, isNotNull);

      expect(
        navigationRailView.backgroundColor,
        SimulatedLayout.navigationRailThemeBgColor,
      );
      expect(
        navigationRailView.selectedIconTheme?.color,
        SimulatedLayout.selectedIconThemeData.color,
      );
      expect(
        navigationRailView.selectedIconTheme?.size,
        SimulatedLayout.selectedIconThemeData.size,
      );
      expect(
        navigationRailView.unselectedIconTheme?.color,
        SimulatedLayout.unSelectedIconThemeData.color,
      );
      expect(
        navigationRailView.unselectedIconTheme?.size,
        SimulatedLayout.unSelectedIconThemeData.size,
      );
    },
  );

  testWidgets(
    'when drawer item tap, it shall close the already open drawer',
    (WidgetTester tester) async {
      //region Keys
      const ValueKey<String> firstDestinationIconKey = ValueKey<String>(
        'first-normal-icon',
      );
      const ValueKey<String> firstDestinationSelectedIconKey = ValueKey<String>(
        'first-selected-icon',
      );
      const ValueKey<String> lastDestinationIconKey = ValueKey<String>(
        'last-normal-icon',
      );
      const ValueKey<String> lastDestinationSelectedIconKey = ValueKey<String>(
        'last-selected-icon',
      );
      //endregion

      //region Finder for destinations as per its icon.
      final Finder lastDestinationWithIcon = find.byKey(
        lastDestinationIconKey,
      );
      final Finder lastDestinationWithSelectedIcon = find.byKey(
        lastDestinationSelectedIconKey,
      );
      //endregion

      const List<NavigationDestination> destinations = <NavigationDestination>[
        NavigationDestination(
          icon: Icon(
            Icons.inbox_outlined,
            key: firstDestinationIconKey,
          ),
          selectedIcon: Icon(
            Icons.inbox,
            key: firstDestinationSelectedIconKey,
          ),
          label: 'Inbox',
        ),
        NavigationDestination(
          icon: Icon(
            Icons.video_call_outlined,
            key: lastDestinationIconKey,
          ),
          selectedIcon: Icon(
            Icons.video_call,
            key: lastDestinationSelectedIconKey,
          ),
          label: 'Video',
        ),
      ];
      int selectedDestination = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(450, 900)),
            child: StatefulBuilder(
              builder: (
                BuildContext context,
                void Function(void Function()) setState,
              ) {
                return AdaptiveScaffold(
                  destinations: destinations,
                  selectedIndex: selectedDestination,
                  smallBreakpoint: TestBreakpoint400(),
                  drawerBreakpoint: TestBreakpoint400(),
                  onSelectedIndexChange: (int value) {
                    setState(() {
                      selectedDestination = value;
                    });
                  },
                );
              },
            ),
          ),
        ),
      );

      expect(selectedDestination, 0);
      Finder fDrawer = find.byType(Drawer);
      Finder fNavigationRail = find.descendant(
        of: fDrawer,
        matching: find.byType(NavigationRail),
      );
      expect(fDrawer, findsNothing);
      expect(fNavigationRail, findsNothing);

      final ScaffoldState state = tester.state(find.byType(Scaffold));
      state.openDrawer();
      await tester.pumpAndSettle(Durations.short4);
      expect(state.isDrawerOpen, isTrue);

      // Need to find again as Scaffold's state has been updated
      fDrawer = find.byType(Drawer);
      fNavigationRail = find.descendant(
        of: fDrawer,
        matching: find.byType(NavigationRail),
      );
      expect(fDrawer, findsOneWidget);
      expect(fNavigationRail, findsOneWidget);

      expect(lastDestinationWithIcon, findsOneWidget);
      expect(lastDestinationWithSelectedIcon, findsNothing);

      await tester.ensureVisible(lastDestinationWithIcon);
      await tester.tap(lastDestinationWithIcon);
      await tester.pumpAndSettle(Durations.short4);
      expect(selectedDestination, 1);
      expect(state.isDrawerOpen, isFalse);
    },
  );

  // This test checks whether AdaptiveScaffold.standardNavigationRail function
  // creates a NavigationRail widget as expected with groupAlignment provided,
  // and checks whether the NavigationRail's groupAlignment matches the expected value.
  testWidgets(
    'groupAligment parameter of AdaptiveScaffold.standardNavigationRail works correctly',
    (WidgetTester tester) async {
      const List<NavigationRailDestination> destinations =
          <NavigationRailDestination>[
        NavigationRailDestination(
          icon: Icon(Icons.home),
          label: Text('Home'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.account_circle),
          label: Text('Profile'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.settings),
          label: Text('Settings'),
        ),
      ];

      const double groupAlignment = 1.0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (BuildContext context) {
                return AdaptiveScaffold.standardNavigationRail(
                  destinations: destinations,
                  groupAlignment: groupAlignment,
                );
              },
            ),
          ),
        ),
      );
      final NavigationRail rail =
          tester.widget<NavigationRail>(find.byType(NavigationRail));
      expect(rail.groupAlignment, equals(groupAlignment));
    },
  );

  testWidgets(
    "doesn't override Directionality",
    (WidgetTester tester) async {
      const List<NavigationDestination> destinations = <NavigationDestination>[
        NavigationDestination(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        NavigationDestination(
          icon: Icon(Icons.account_circle),
          label: 'Profile',
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Directionality(
              textDirection: TextDirection.rtl,
              child: AdaptiveScaffold(
                destinations: destinations,
                body: (BuildContext context) {
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
        ),
      );

      final Finder body = find.byKey(const Key('body'));
      expect(body, findsOneWidget);
      final TextDirection dir = Directionality.of(body.evaluate().first);
      expect(dir, TextDirection.rtl);
    },
  );

  testWidgets(
    'when appBarBreakpoint is provided validate an AppBar is showing without Drawer on larger than mobile',
    (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(SimulatedLayout.medium.size);
      await tester.pumpWidget(SimulatedLayout.medium
          .scaffold(tester, appBarBreakpoint: AppBarAlwaysOnBreakpoint()));
      await tester.pumpAndSettle();

      final Finder appBar = find.byType(AppBar);
      final Finder drawer = find.byType(Drawer);
      expect(appBar, findsOneWidget);
      expect(drawer, findsNothing);

      await tester.binding.setSurfaceSize(SimulatedLayout.mediumLarge.size);
      await tester.pumpWidget(SimulatedLayout.mediumLarge
          .scaffold(tester, appBarBreakpoint: AppBarAlwaysOnBreakpoint()));
      expect(drawer, findsNothing);
      await tester.pumpAndSettle();

      expect(appBar, findsOneWidget);
    },
  );

  testWidgets(
    'When only one destination passed, shall throw assertion error',
    (WidgetTester tester) async {
      const List<NavigationDestination> destinations = <NavigationDestination>[
        NavigationDestination(
          icon: Icon(Icons.inbox_outlined),
          selectedIcon: Icon(Icons.inbox),
          label: 'Inbox',
        ),
      ];

      expect(
        () => tester.pumpWidget(
          MaterialApp(
            home: MediaQuery(
              data: const MediaQueryData(size: Size(700, 900)),
              child: AdaptiveScaffold(
                destinations: destinations,
              ),
            ),
          ),
        ),
        throwsA(isA<AssertionError>()),
      );
    },
  );

  // Test for navigationRailDestinationBuilder parameter.
  testWidgets('adaptive scaffold custom navigation rail destination mapping',
      (WidgetTester tester) async {
    const List<NavigationDestination> destinations = <NavigationDestination>[
      NavigationDestination(
        icon: Icon(Icons.home),
        label: 'Home',
      ),
      NavigationDestination(
        icon: Icon(Icons.account_circle),
        label: 'Profile',
      ),
    ];

    NavigationRailDestination customMapping(
        int index, NavigationDestination destination) {
      return NavigationRailDestination(
        icon: destination.icon,
        label: Text('Custom ${destination.label}'),
      );
    }

    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(size: Size(800, 600)),
          child: AdaptiveScaffold(
            destinations: destinations,
            navigationRailDestinationBuilder: customMapping,
          ),
        ),
      ),
    );

    expect(find.text('Custom Home'), findsOneWidget);
    expect(find.text('Custom Profile'), findsOneWidget);
  });

  // Test for labelType setting through the navigation rail theme.
  testWidgets(
    'adaptive scaffold respects NavigationRailLabelType from theme',
    (WidgetTester tester) async {
      const List<NavigationDestination> destinations = <NavigationDestination>[
        NavigationDestination(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        NavigationDestination(
          icon: Icon(Icons.account_circle),
          label: 'Profile',
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            navigationRailTheme: const NavigationRailThemeData(
              labelType: NavigationRailLabelType.all,
            ),
          ),
          home: MediaQuery(
            data: const MediaQueryData(size: Size(800, 600)),
            child: AdaptiveScaffold(
              destinations: destinations,
            ),
          ),
        ),
      );

      final NavigationRail rail =
          tester.widget<NavigationRail>(find.byType(NavigationRail));
      expect(rail.labelType, NavigationRailLabelType.all);
    },
  );
}

/// An empty widget that implements [PreferredSizeWidget] to ensure that
/// [PreferredSizeWidget] is used as [AdaptiveScaffold.appBar] parameter instead
/// of [AppBar].
class PreferredSizeWidgetImpl extends StatelessWidget
    implements PreferredSizeWidget {
  const PreferredSizeWidgetImpl({super.key});

  @override
  Widget build(BuildContext context) {
    return Container();
  }

  @override
  Size get preferredSize => const Size(200, 200);
}
