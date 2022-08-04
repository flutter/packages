// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:adaptive_scaffold/adaptive_scaffold.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(
    const MaterialApp(
      title: 'Adaptive Layout Example',
      home: _MyHomePage(),
    ),
  );
}

class _MyHomePage extends StatelessWidget {
  const _MyHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Define the children to display within the body.
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
          unselectedItemColor: Colors.black, selectedItemColor: Colors.black),
      child: AdaptiveScaffold(
        // An option to override the default breakpoints used for small, medium,
        // and large.
        smallBreakpoint: const WidthPlatformBreakpoint(end: 700),
        mediumBreakpoint: const WidthPlatformBreakpoint(begin: 700, end: 1000),
        largeBreakpoint: const WidthPlatformBreakpoint(begin: 1000),
        useDrawer: false,
        // Define the list of destinations to be used within the app.
        destinations: const <NavigationDestination>[
          NavigationDestination(icon: Icon(Icons.inbox), label: 'Inbox'),
          NavigationDestination(icon: Icon(Icons.article), label: 'Articles'),
          NavigationDestination(icon: Icon(Icons.chat), label: 'Chat'),
          NavigationDestination(icon: Icon(Icons.video_call), label: 'Video'),
        ],
        // Define the default body to be a GridView.
        body: (_) => GridView.count(crossAxisCount: 2, children: children),
        // Override the default body during the small breakpoint to instead become
        // a ListView.
        smallBody: (_) => ListView.builder(
            itemCount: 10, itemBuilder: (_, int idx) => children[idx]),
        // Define a default secondaryBody.
        secondaryBody: (_) =>
            Container(color: const Color.fromARGB(255, 234, 158, 192)),
        // Override the default secondaryBody during the smallBreakpoint to be
        // empty. Must use AdaptiveScaffold.emptyBuilder to ensure it is properly
        // overriden.
        smallSecondaryBody: AdaptiveScaffold.emptyBuilder,
      ),
    );
  }
}
