// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_adaptive_scaffold/src/adaptive_scaffold.dart';
import 'package:flutter_adaptive_scaffold/src/breakpoints.dart';
import 'package:flutter_test/flutter_test.dart';

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

    await tester.binding.setSurfaceSize(SimulatedLayout.mobile.size);
    await tester.pumpWidget(SimulatedLayout.mobile.app());
    await tester.pumpAndSettle();

    expect(smallBody, findsOneWidget);
    expect(smallSBody, findsOneWidget);
    expect(bottomNav, findsOneWidget);
    expect(primaryNav, findsNothing);

    expect(tester.getTopLeft(smallBody), Offset.zero);
    expect(tester.getTopLeft(smallSBody), const Offset(200, 0));
    expect(tester.getTopLeft(bottomNav), const Offset(0, 744));

    await tester.binding.setSurfaceSize(SimulatedLayout.tablet.size);
    await tester.pumpWidget(SimulatedLayout.tablet.app());
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

    await tester.binding.setSurfaceSize(SimulatedLayout.desktop.size);
    await tester.pumpWidget(SimulatedLayout.desktop.app());
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

    await tester.binding.setSurfaceSize(SimulatedLayout.mobile.size);
    await tester.pumpWidget(SimulatedLayout.mobile.app());
    await tester.binding.setSurfaceSize(SimulatedLayout.tablet.size);
    await tester.pumpWidget(SimulatedLayout.tablet.app());

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

    await tester.binding.setSurfaceSize(SimulatedLayout.mobile.size);
    await tester.pumpWidget(SimulatedLayout.mobile.app(animations: false));

    await tester.binding.setSurfaceSize(SimulatedLayout.tablet.size);
    await tester.pumpWidget(SimulatedLayout.tablet.app(animations: false));

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
}

class TestBreakpoint0 extends Breakpoint {
  @override
  bool isActive(BuildContext context) {
    return MediaQuery.of(context).size.width >= 0 &&
        MediaQuery.of(context).size.width < 800;
  }
}

class TestBreakpoint800 extends Breakpoint {
  @override
  bool isActive(BuildContext context) {
    return MediaQuery.of(context).size.width >= 800 &&
        MediaQuery.of(context).size.width < 1000;
  }
}

class TestBreakpoint1000 extends Breakpoint {
  @override
  bool isActive(BuildContext context) {
    return MediaQuery.of(context).size.width >= 1000;
  }
}

class NeverOnBreakpoint extends Breakpoint {
  @override
  bool isActive(BuildContext context) {
    return false;
  }
}

class TestScaffold extends StatefulWidget {
  const TestScaffold({
    super.key,
    this.initialIndex = 0,
    this.isAnimated = true,
  });

  final int initialIndex;
  final bool isAnimated;

  static const List<NavigationDestination> destinations =
      <NavigationDestination>[
    NavigationDestination(
      key: Key('Inbox'),
      icon: Icon(Icons.inbox),
      label: 'Inbox',
    ),
    NavigationDestination(
      key: Key('Articles'),
      icon: Icon(Icons.article),
      label: 'Articles',
    ),
    NavigationDestination(
      key: Key('Chat'),
      icon: Icon(Icons.chat),
      label: 'Chat',
    ),
  ];

  @override
  State<TestScaffold> createState() => TestScaffoldState();
}

class TestScaffoldState extends State<TestScaffold> {
  late int index = widget.initialIndex;

  @override
  Widget build(BuildContext context) {
    return AdaptiveScaffold(
      selectedIndex: index,
      onSelectedIndexChange: (int index) {
        setState(() {
          this.index = index;
        });
      },
      drawerBreakpoint: NeverOnBreakpoint(),
      internalAnimations: widget.isAnimated,
      smallBreakpoint: TestBreakpoint0(),
      mediumBreakpoint: TestBreakpoint800(),
      largeBreakpoint: TestBreakpoint1000(),
      destinations: TestScaffold.destinations,
      smallBody: (_) => Container(color: Colors.red),
      body: (_) => Container(color: Colors.green),
      largeBody: (_) => Container(color: Colors.blue),
      smallSecondaryBody: (_) => Container(color: Colors.red),
      secondaryBody: (_) => Container(color: Colors.green),
      largeSecondaryBody: (_) => Container(color: Colors.blue),
    );
  }
}

enum SimulatedLayout {
  mobile(width: 400, navSlotKey: 'bottomNavigation'),
  tablet(width: 800, navSlotKey: 'primaryNavigation'),
  desktop(width: 1100, navSlotKey: 'primaryNavigation1');

  const SimulatedLayout({
    required double width,
    required this.navSlotKey,
  }) : _width = width;

  final double _width;
  final double _height = 800;
  final String navSlotKey;

  Size get size => Size(_width, _height);

  MaterialApp app({
    int initialIndex = 0,
    bool animations = true,
  }) {
    return MaterialApp(
      home: MediaQuery(
        data: MediaQueryData(size: size),
        child: TestScaffold(
          initialIndex: initialIndex,
          isAnimated: animations,
        ),
      ),
    );
  }
}
