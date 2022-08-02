// Copyright 2014 The Flutter Authors. All rights reserved.
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
    const List<NavigationDestination> destinations = <NavigationDestination>[
      NavigationDestination(label: 'Inbox', icon: Icon(Icons.inbox, color: Colors.black)),
      NavigationDestination(label: 'Articles', icon: Icon(Icons.article_outlined, color: Colors.black)),
      NavigationDestination(label: 'Chat', icon: Icon(Icons.chat_bubble_outline, color: Colors.black)),
      NavigationDestination(label: 'Video', icon: Icon(Icons.video_call_outlined, color: Colors.black)),
    ];

    return AdaptiveLayout(
      primaryNavigation: SlotLayout(
        config: <Breakpoint, SlotLayoutConfig?> {
          Breakpoints.small: SlotLayoutConfig(key: const Key('pnav'), builder: (_) => const SizedBox.shrink()),
          Breakpoints.medium: SlotLayoutConfig(
            inAnimation: AdaptiveScaffold.leftOutIn,
            key: const Key('pnav1'),
            builder: (_) => AdaptiveScaffold.toNavigationRail(destinations: destinations),
          ),
          Breakpoints.large: SlotLayoutConfig(
            key: const Key('pnav2'),
            inAnimation: AdaptiveScaffold.leftOutIn,
            builder: (_) => AdaptiveScaffold.toNavigationRail(extended: true, destinations: destinations),
          ),
        },
      ),
      body: SlotLayout(
        config: <Breakpoint, SlotLayoutConfig?> {
          Breakpoints.small: SlotLayoutConfig(
            key: const Key('body'),
            builder: (_) => ListView.builder(
              itemCount: 10,
              itemBuilder: (_, __) => Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  color: const Color.fromARGB(255, 255, 201, 197),
                  height: 400,
                ),
              ),
            ),
          ),
          Breakpoints.medium: SlotLayoutConfig(
            key: const Key('body1'),
            builder: (_) => GridView.count(crossAxisCount: 2, children: <Widget>[
              for (int i = 0; i < 10; i++)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    color: const Color.fromARGB(255, 255, 201, 197),
                    height: 400,
                  ),
                )
            ]),
          ),
        },
      ),
      bottomNavigation: SlotLayout(
        config: <Breakpoint, SlotLayoutConfig?> {
          Breakpoints.small: SlotLayoutConfig(
            key: const Key('botnav'),
            inAnimation: AdaptiveScaffold.bottomToTop,
            builder: (_) => AdaptiveScaffold.toBottomNavigationBar(destinations: destinations),
          ),
        },
      ),
    );
  }
}
