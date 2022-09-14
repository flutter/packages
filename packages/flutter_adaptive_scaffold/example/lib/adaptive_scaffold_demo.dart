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
    return const MaterialApp(home: MyHomePage());
  }
}

/// Creates a basic adaptive page with navigational elements and a body using
/// [AdaptiveScaffold].
class MyHomePage extends StatelessWidget {
  /// Creates a const [MyHomePage].
  const MyHomePage({super.key});

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

    return BottomNavigationBarTheme(
        data: const BottomNavigationBarThemeData(
          unselectedItemColor: Colors.black,
          selectedItemColor: Colors.black,
          backgroundColor: Colors.white,
        ),
        child: AdaptiveScaffold(
            // An option to override the default breakpoints used for small, medium,
            // and large.
            smallBreakpoint: const WidthPlatformBreakpoint(end: 700),
            mediumBreakpoint:
                const WidthPlatformBreakpoint(begin: 700, end: 1000),
            largeBreakpoint: const WidthPlatformBreakpoint(begin: 1000),
            useDrawer: false,
            destinations: const <NavigationDestination>[
              NavigationDestination(icon: Icon(Icons.inbox), label: 'Inbox'),
              NavigationDestination(
                  icon: Icon(Icons.article), label: 'Articles'),
              NavigationDestination(icon: Icon(Icons.chat), label: 'Chat'),
              NavigationDestination(
                  icon: Icon(Icons.video_call), label: 'Video')
            ],
            body: (_) => GridView.count(crossAxisCount: 2, children: children),
            smallBody: (_) => ListView.builder(
                  itemCount: children.length,
                  itemBuilder: (_, int idx) => children[idx],
                ),
            // Define a default secondaryBody.
            secondaryBody: (_) =>
                Container(color: const Color.fromARGB(255, 234, 158, 192)),
            // Override the default secondaryBody during the smallBreakpoint to be
            // empty. Must use AdaptiveScaffold.emptyBuilder to ensure it is properly
            // overridden.
            smallSecondaryBody: AdaptiveScaffold.emptyBuilder));
  }
  // #enddocregion
}
