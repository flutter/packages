// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_adaptive_scaffold/flutter_adaptive_scaffold.dart';

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
  });

  final int? initialIndex;
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
      leadingExtendedNavRail: const Text('leading_extended'),
      leadingUnextendedNavRail: const Text('leading_unextended'),
      trailingNavRail: const Text('trailing'),
    );
  }
}

enum SimulatedLayout {
  small(width: 400, navSlotKey: 'bottomNavigation'),
  medium(width: 800, navSlotKey: 'primaryNavigation'),
  large(width: 1100, navSlotKey: 'primaryNavigation1');

  const SimulatedLayout({
    required double width,
    required this.navSlotKey,
  }) : _width = width;

  final double _width;
  final double _height = 800;
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

  MaterialApp app({
    int? initialIndex,
    bool animations = true,
  }) {
    return MaterialApp(
      theme: ThemeData.light().copyWith(
        navigationRailTheme: const NavigationRailThemeData(
          backgroundColor: navigationRailThemeBgColor,
          selectedIconTheme: selectedIconThemeData,
          unselectedIconTheme: unSelectedIconThemeData,
        ),
      ),
      home: MediaQuery(
        data: MediaQueryData(size: size),
        child: TestScaffold(
          initialIndex: initialIndex,
          isAnimated: animations,
        ),
      ),
    );
  }

  MediaQuery get slot {
    return MediaQuery(
      // TODO(stuartmorgan): Replace with .fromView once this package requires
      // Flutter 3.8+.
      // ignore: deprecated_member_use
      data: MediaQueryData.fromWindow(WidgetsBinding.instance.window)
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
            },
          ),
        ),
      ),
    );
  }
}
