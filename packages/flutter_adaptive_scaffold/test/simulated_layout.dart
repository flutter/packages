// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_adaptive_scaffold/flutter_adaptive_scaffold.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_breakpoints.dart';

AnimatedWidget leftOutIn(Widget child, Animation<double> animation) {
  return SlideTransition(
    key: Key('in-${child.key}'),
    position: Tween<Offset>(
      begin: const Offset(-1, 0),
      end: Offset.zero,
    ).animate(animation),
    child: child,
  );
}

AnimatedWidget leftInOut(Widget child, Animation<double> animation) {
  return SlideTransition(
    key: Key('out-${child.key}'),
    position: Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(-1, 0),
    ).animate(animation),
    child: child,
  );
}

class TestScaffold extends StatefulWidget {
  const TestScaffold({
    super.key,
    this.initialIndex = 0,
    this.isAnimated = true,
    this.appBarBreakpoint,
  });

  final int? initialIndex;
  final bool isAnimated;
  final Breakpoint? appBarBreakpoint;

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
  late int? index = widget.initialIndex;

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
      appBarBreakpoint: widget.appBarBreakpoint,
      internalAnimations: widget.isAnimated,
      smallBreakpoint: TestBreakpoint0(),
      mediumBreakpoint: TestBreakpoint800(),
      mediumLargeBreakpoint: TestBreakpoint1000(),
      largeBreakpoint: TestBreakpoint1200(),
      extraLargeBreakpoint: TestBreakpoint1600(),
      destinations: TestScaffold.destinations,
      smallBody: (_) => Container(color: Colors.red),
      body: (_) => Container(color: Colors.green),
      mediumLargeBody: (_) => Container(color: Colors.blue),
      largeBody: (_) => Container(color: Colors.yellow),
      extraLargeBody: (_) => Container(color: Colors.purple),
      smallSecondaryBody: (_) => Container(color: Colors.red),
      secondaryBody: (_) => Container(color: Colors.green),
      mediumLargeSecondaryBody: (_) => Container(color: Colors.blue),
      largeSecondaryBody: (_) => Container(color: Colors.yellow),
      extraLargeSecondaryBody: (_) => Container(color: Colors.purple),
      leadingExtendedNavRail: const Text('leading_extended'),
      leadingUnextendedNavRail: const Text('leading_unextended'),
      trailingNavRail: const Text('trailing'),
    );
  }
}

enum SimulatedLayout {
  small(width: 400, navSlotKey: 'bottomNavigation'),
  medium(width: 800, navSlotKey: 'primaryNavigation'),
  mediumLarge(width: 1000, navSlotKey: 'primaryNavigation1'),
  large(width: 1200, navSlotKey: 'primaryNavigation2'),
  extraLarge(width: 1600, navSlotKey: 'primaryNavigation3'),
  smallLandscape(width: 500, height: 400, navSlotKey: 'bottomNavigation'),
  mediumLandscape(width: 800, height: 600, navSlotKey: 'primaryNavigation'),
  mediumLargeLandscape(
      width: 1100, height: 900, navSlotKey: 'primaryNavigation1'),
  largeLandscape(width: 1400, height: 1000, navSlotKey: 'primaryNavigation2'),
  extraLargeLandscape(
      width: 1700, height: 1000, navSlotKey: 'primaryNavigation3'),
  smallPortraitMediumLandscape(
      width: 360, height: 650, navSlotKey: 'bottomNavigation'),
  smallLandscapeMediumPortrait(
      width: 650, height: 360, navSlotKey: 'bottomNavigation'),
  smallPortraitMediumLargeLandscape(
      width: 360, height: 900, navSlotKey: 'bottomNavigation'),
  smallLandscapeMediumLargePortrait(
      width: 900, height: 360, navSlotKey: 'primaryNavigation'),
  mediumLargeLandscapeMediumPortrait(
      width: 841, height: 668, navSlotKey: 'primaryNavigation');

  const SimulatedLayout({
    required double width,
    double height = 2000,
    required this.navSlotKey,
  })  : _width = width,
        _height = height;

  final double _width;
  final double _height;
  final String navSlotKey;

  static const Color navigationRailThemeBgColor = Colors.white;
  static const IconThemeData selectedIconThemeData = IconThemeData(
    color: Colors.red,
    size: 32.0,
  );
  static const IconThemeData unSelectedIconThemeData = IconThemeData(
    color: Colors.black,
    size: 24.0,
  );

  Size get size => Size(_width, _height);

  MaterialApp app(WidgetTester tester, {required Widget child}) {
    return MaterialApp(
      theme: ThemeData.light().copyWith(
        navigationRailTheme: const NavigationRailThemeData(
          backgroundColor: navigationRailThemeBgColor,
          selectedIconTheme: selectedIconThemeData,
          unselectedIconTheme: unSelectedIconThemeData,
        ),
      ),
      home: MediaQuery(
        data: MediaQueryData.fromView(tester.view).copyWith(
          size: Size(_width, _height),
          padding: const EdgeInsets.only(top: 30),
        ),
        child: child,
      ),
    );
  }

  MaterialApp scaffold(
    WidgetTester tester, {
    int? initialIndex,
    bool animations = true,
    Breakpoint? appBarBreakpoint,
  }) {
    return app(
      tester,
      child: TestScaffold(
        initialIndex: initialIndex,
        isAnimated: animations,
        appBarBreakpoint: appBarBreakpoint,
      ),
    );
  }

  MediaQuery slot(WidgetTester tester) {
    return MediaQuery(
      data: MediaQueryData.fromView(tester.view)
          .copyWith(size: Size(_width, _height)),
      child: Theme(
        data: ThemeData(),
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: SlotLayout(
            config: <Breakpoint, SlotLayoutConfig>{
              Breakpoints.small: SlotLayout.from(
                key: const Key('Breakpoints.small'),
                builder: (BuildContext context) => Container(),
              ),
              Breakpoints.smallMobile: SlotLayout.from(
                key: const Key('Breakpoints.smallMobile'),
                builder: (BuildContext context) => Container(),
              ),
              Breakpoints.smallDesktop: SlotLayout.from(
                key: const Key('Breakpoints.smallDesktop'),
                builder: (BuildContext context) => Container(),
              ),
              Breakpoints.medium: SlotLayout.from(
                key: const Key('Breakpoints.medium'),
                builder: (BuildContext context) => Container(),
              ),
              Breakpoints.mediumMobile: SlotLayout.from(
                key: const Key('Breakpoints.mediumMobile'),
                builder: (BuildContext context) => Container(),
              ),
              Breakpoints.mediumDesktop: SlotLayout.from(
                key: const Key('Breakpoints.mediumDesktop'),
                builder: (BuildContext context) => Container(),
              ),
              Breakpoints.mediumLarge: SlotLayout.from(
                key: const Key('Breakpoints.mediumLarge'),
                builder: (BuildContext context) => Container(),
              ),
              Breakpoints.mediumLargeMobile: SlotLayout.from(
                key: const Key('Breakpoints.mediumLargeMobile'),
                builder: (BuildContext context) => Container(),
              ),
              Breakpoints.mediumLargeDesktop: SlotLayout.from(
                key: const Key('Breakpoints.mediumLargeDesktop'),
                builder: (BuildContext context) => Container(),
              ),
              Breakpoints.large: SlotLayout.from(
                key: const Key('Breakpoints.large'),
                builder: (BuildContext context) => Container(),
              ),
              Breakpoints.largeMobile: SlotLayout.from(
                key: const Key('Breakpoints.largeMobile'),
                builder: (BuildContext context) => Container(),
              ),
              Breakpoints.largeDesktop: SlotLayout.from(
                key: const Key('Breakpoints.largeDesktop'),
                builder: (BuildContext context) => Container(),
              ),
              Breakpoints.extraLarge: SlotLayout.from(
                key: const Key('Breakpoints.extraLarge'),
                builder: (BuildContext context) => Container(),
              ),
              Breakpoints.extraLargeMobile: SlotLayout.from(
                key: const Key('Breakpoints.extraLargeMobile'),
                builder: (BuildContext context) => Container(),
              ),
              Breakpoints.extraLargeDesktop: SlotLayout.from(
                key: const Key('Breakpoints.extraLargeDesktop'),
                builder: (BuildContext context) => Container(),
              ),
            },
          ),
        ),
      ),
    );
  }

  MediaQuery slotAndUp(WidgetTester tester) {
    return MediaQuery(
      data: MediaQueryData.fromView(tester.view)
          .copyWith(size: Size(_width, _height)),
      child: Theme(
        data: ThemeData(),
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: SlotLayout(
            config: <Breakpoint, SlotLayoutConfig>{
              Breakpoints.small: SlotLayout.from(
                key: const Key('Breakpoints.small'),
                builder: (BuildContext context) => Container(),
              ),
              Breakpoints.mediumAndUp: SlotLayout.from(
                key: const Key('Breakpoints.mediumAndUp'),
                builder: (BuildContext context) => Container(),
              ),
            },
          ),
        ),
      ),
    );
  }
}
