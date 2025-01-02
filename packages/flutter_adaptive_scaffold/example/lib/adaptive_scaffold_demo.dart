// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_adaptive_scaffold/flutter_adaptive_scaffold.dart';

void main() {
  runApp(const MyApp());
}

/// The main application widget for this example.
class MyApp extends StatelessWidget {
  /// Creates a const main application widget.
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.light().copyWith(
        navigationRailTheme: const NavigationRailThemeData(
          selectedIconTheme: IconThemeData(
            color: Colors.red,
            size: 28,
          ),
          selectedLabelTextStyle: TextStyle(
            fontSize: 16,
            color: Colors.red,
          ),
          unselectedLabelTextStyle: TextStyle(
            fontSize: 14,
            color: Colors.black,
          ),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          type: BottomNavigationBarType.fixed,
        ),
      ),
      home: const MyHomePage(),
    );
  }
}

/// Creates a basic adaptive page with navigational elements and a body using
/// [AdaptiveScaffold].
class MyHomePage extends StatefulWidget {
  /// Creates a const [MyHomePage].
  const MyHomePage({super.key, this.transitionDuration = 1000});

  /// Declare transition duration.
  final int transitionDuration;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedTab = 0;
  int _transitionDuration = 1000;

  // Initialize transition time variable.
  @override
  void initState() {
    super.initState();
    setState(() {
      _transitionDuration = widget.transitionDuration;
    });
  }

  // #docregion Example
  @override
  Widget build(BuildContext context) {
    // Define the children to display within the body at different breakpoints.
    final List<Widget> children = <Widget>[
      for (int i = 0; i < 10; i++)
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            color: const Color.fromARGB(255, 255, 201, 197),
            height: 400,
          ),
        )
    ];
    return AdaptiveScaffold(
      // An option to override the default transition duration.
      transitionDuration: Duration(milliseconds: _transitionDuration),
      // An option to override the default breakpoints used for small, medium,
      // mediumLarge, large, and extraLarge.
      smallBreakpoint: const Breakpoint(endWidth: 700),
      mediumBreakpoint: const Breakpoint(beginWidth: 700, endWidth: 1000),
      mediumLargeBreakpoint: const Breakpoint(beginWidth: 1000, endWidth: 1200),
      largeBreakpoint: const Breakpoint(beginWidth: 1200, endWidth: 1600),
      extraLargeBreakpoint: const Breakpoint(beginWidth: 1600),
      useDrawer: false,
      selectedIndex: _selectedTab,
      onSelectedIndexChange: (int index) {
        setState(() {
          _selectedTab = index;
        });
      },
      destinations: const <NavigationDestination>[
        NavigationDestination(
          icon: Icon(Icons.inbox_outlined),
          selectedIcon: Icon(Icons.inbox),
          label: 'Inbox',
        ),
        NavigationDestination(
          icon: Icon(Icons.article_outlined),
          selectedIcon: Icon(Icons.article),
          label: 'Articles',
        ),
        NavigationDestination(
          icon: Icon(Icons.chat_outlined),
          selectedIcon: Icon(Icons.chat),
          label: 'Chat',
        ),
        NavigationDestination(
          icon: Icon(Icons.video_call_outlined),
          selectedIcon: Icon(Icons.video_call),
          label: 'Video',
        ),
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: 'Inbox',
        ),
      ],
      smallBody: (_) => ListView.builder(
        itemCount: children.length,
        itemBuilder: (_, int idx) => children[idx],
      ),
      body: (_) => GridView.count(crossAxisCount: 2, children: children),
      mediumLargeBody: (_) =>
          GridView.count(crossAxisCount: 3, children: children),
      largeBody: (_) => GridView.count(crossAxisCount: 4, children: children),
      extraLargeBody: (_) =>
          GridView.count(crossAxisCount: 5, children: children),
      // Define a default secondaryBody.
      // Override the default secondaryBody during the smallBreakpoint to be
      // empty. Must use AdaptiveScaffold.emptyBuilder to ensure it is properly
      // overridden.
      smallSecondaryBody: AdaptiveScaffold.emptyBuilder,
      secondaryBody: (_) => Container(
        color: const Color.fromARGB(255, 234, 158, 192),
      ),
      mediumLargeSecondaryBody: (_) => Container(
        color: const Color.fromARGB(255, 234, 158, 192),
      ),
      largeSecondaryBody: (_) => Container(
        color: const Color.fromARGB(255, 234, 158, 192),
      ),
      extraLargeSecondaryBody: (_) => Container(
        color: const Color.fromARGB(255, 234, 158, 192),
      ),
    );
  }
// #enddocregion Example
}
