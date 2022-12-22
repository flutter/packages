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
    final Finder largeBody = find.byKey(const Key('largeBody'));
    final Finder smallSBody = find.byKey(const Key('smallSBody'));
    final Finder sBody = find.byKey(const Key('sBody'));
    final Finder largeSBody = find.byKey(const Key('largeSBody'));
    final Finder bottomNav = find.byKey(const Key('bottomNavigation'));
    final Finder primaryNav = find.byKey(const Key('primaryNavigation'));
    final Finder primaryNav1 = find.byKey(const Key('primaryNavigation1'));

    await tester.binding.setSurfaceSize(SimulatedLayout.small.size);
    await tester.pumpWidget(SimulatedLayout.small.app());
    await tester.pumpAndSettle();

    expect(smallBody, findsOneWidget);
    expect(smallSBody, findsOneWidget);
    expect(bottomNav, findsOneWidget);
    expect(primaryNav, findsNothing);

    expect(tester.getTopLeft(smallBody), Offset.zero);
    expect(tester.getTopLeft(smallSBody), const Offset(200, 0));
    expect(tester.getTopLeft(bottomNav), const Offset(0, 744));

    await tester.binding.setSurfaceSize(SimulatedLayout.medium.size);
    await tester.pumpWidget(SimulatedLayout.medium.app());
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
    expect(tester.getBottomRight(primaryNav), const Offset(88, 800));

    await tester.binding.setSurfaceSize(SimulatedLayout.large.size);
    await tester.pumpWidget(SimulatedLayout.large.app());
    await tester.pumpAndSettle();

    expect(body, findsNothing);
    expect(largeBody, findsOneWidget);
    expect(sBody, findsNothing);
    expect(largeSBody, findsOneWidget);
    expect(primaryNav, findsNothing);
    expect(primaryNav1, findsOneWidget);

    expect(tester.getTopLeft(largeBody), const Offset(208, 0));
    expect(tester.getTopLeft(largeSBody), const Offset(550, 0));
    expect(tester.getTopLeft(primaryNav1), Offset.zero);
    expect(tester.getBottomRight(primaryNav1), const Offset(208, 800));
  });

  testWidgets('adaptive scaffold animations work correctly',
      (WidgetTester tester) async {
    final Finder b = find.byKey(const Key('body'));
    final Finder sBody = find.byKey(const Key('sBody'));

    await tester.binding.setSurfaceSize(SimulatedLayout.small.size);
    await tester.pumpWidget(SimulatedLayout.small.app());
    await tester.binding.setSurfaceSize(SimulatedLayout.medium.size);
    await tester.pumpWidget(SimulatedLayout.medium.app());

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(tester.getTopLeft(b), const Offset(17.6, 0));
    expect(tester.getBottomRight(b),
        offsetMoreOrLessEquals(const Offset(778.2, 755.2), epsilon: 1.0));
    expect(tester.getTopLeft(sBody),
        offsetMoreOrLessEquals(const Offset(778.2, 0), epsilon: 1.0));
    expect(tester.getBottomRight(sBody),
        offsetMoreOrLessEquals(const Offset(1178.2, 755.2), epsilon: 1.0));

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    expect(tester.getTopLeft(b), const Offset(70.4, 0));
    expect(tester.getBottomRight(b),
        offsetMoreOrLessEquals(const Offset(416.0, 788.8), epsilon: 1.0));
    expect(tester.getTopLeft(sBody),
        offsetMoreOrLessEquals(const Offset(416, 0), epsilon: 1.0));
    expect(tester.getBottomRight(sBody),
        offsetMoreOrLessEquals(const Offset(816, 788.8), epsilon: 1.0));

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(tester.getTopLeft(b), const Offset(88.0, 0));
    expect(tester.getBottomRight(b), const Offset(400, 800));
    expect(tester.getTopLeft(sBody), const Offset(400, 0));
    expect(tester.getBottomRight(sBody), const Offset(800, 800));
  });

  testWidgets('adaptive scaffold animations can be disabled',
      (WidgetTester tester) async {
    final Finder b = find.byKey(const Key('body'));
    final Finder sBody = find.byKey(const Key('sBody'));

    await tester.binding.setSurfaceSize(SimulatedLayout.small.size);
    await tester.pumpWidget(SimulatedLayout.small.app(animations: false));

    await tester.binding.setSurfaceSize(SimulatedLayout.medium.size);
    await tester.pumpWidget(SimulatedLayout.medium.app(animations: false));

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(tester.getTopLeft(b), const Offset(88.0, 0));
    expect(tester.getBottomRight(b), const Offset(400, 800));
    expect(tester.getTopLeft(sBody), const Offset(400, 0));
    expect(tester.getBottomRight(sBody), const Offset(800, 800));
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
      final MaterialApp app = region.app(initialIndex: selectedIndex);
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

  testWidgets(
    'AdaptiveScaffold surfaces [BottomNavigationBar.useLegacyColorScheme] property',
    (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(size: Size(500, 500)),
          child: AdaptiveScaffold(
            useDrawer: false,
            useLegacyColorScheme: false,
            destinations: <NavigationDestination>[
              NavigationDestination(icon: Icon(Icons.inbox), label: 'Inbox'),
              NavigationDestination(
                  icon: Icon(Icons.article), label: 'Articles'),
              NavigationDestination(icon: Icon(Icons.chat), label: 'Chat'),
              NavigationDestination(
                  icon: Icon(Icons.video_call), label: 'Video')
            ],
          ),
        ),
      ));

      expect(
        tester.widget(find.byType(BottomNavigationBar)),
        isA<BottomNavigationBar>().having(
          (BottomNavigationBar bottomNav) => bottomNav.useLegacyColorScheme,
          'useLegacyColorScheme',
          isFalse,
        ),
      );
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
