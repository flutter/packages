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

    // Define the list of destinations to be used within the app.
    const List<NavigationDestination> destinations = <NavigationDestination>[
      NavigationDestination(
          label: 'Inbox', icon: Icon(Icons.inbox, color: Colors.black)),
      NavigationDestination(
          label: 'Articles',
          icon: Icon(Icons.article_outlined, color: Colors.black)),
      NavigationDestination(
          label: 'Chat',
          icon: Icon(Icons.chat_bubble_outline, color: Colors.black)),
      NavigationDestination(
          label: 'Video',
          icon: Icon(Icons.video_call_outlined, color: Colors.black)),
    ];

    Widget trailingNavRail = Column(
      children: [
        const Divider(
          color: Colors.black,
        ),
        const SizedBox(
          height: 10,
        ),
        Row(
          children: const [
            SizedBox(
              width: 27,
            ),
            Text(
              "Folders",
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
        const SizedBox(
          height: 10,
        ),
        Row(
          children: [
            const SizedBox(
              width: 16,
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.folder_copy_outlined),
              iconSize: 21,
            ),
            const SizedBox(
              width: 21,
            ),
            const Text("Freelance"),
          ],
        ),
        const SizedBox(
          height: 12,
        ),
        Row(
          children: [
            const SizedBox(
              width: 16,
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.folder_copy_outlined),
              iconSize: 21,
            ),
            const SizedBox(
              width: 21,
            ),
            const Text("Mortage"),
          ],
        ),
        const SizedBox(
          height: 12,
        ),
        Row(
          children: [
            const SizedBox(
              width: 16,
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.folder_copy_outlined),
              iconSize: 21,
            ),
            const SizedBox(
              width: 21,
            ),
            const Flexible(
                child: Text(
              "Taxes",
              overflow: TextOverflow.ellipsis,
            )),
          ],
        ),
        const SizedBox(
          height: 12,
        ),
        Row(
          children: [
            const SizedBox(
              width: 16,
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.folder_copy_outlined),
              iconSize: 21,
            ),
            const SizedBox(
              width: 21,
            ),
            const Flexible(
                child: Text(
              "Receipts",
              overflow: TextOverflow.ellipsis,
            )),
          ],
        ),
      ],
    );

    return AdaptiveLayout(
      primaryNavigation: SlotLayout(
        config: {
          Breakpoints.small: SlotLayout.from(
              key: const Key('pnav'), builder: (_) => const SizedBox.shrink()),
          Breakpoints.medium: SlotLayout.from(
            inAnimation: AdaptiveScaffold.leftOutIn,
            key: const Key('pnav1'),
            builder: (_) => AdaptiveScaffold.toNavigationRail(
                leading: const Icon(Icons.menu), destinations: destinations),
          ),
          Breakpoints.large: SlotLayout.from(
            key: const Key('pnav2'),
            inAnimation: AdaptiveScaffold.leftOutIn,
            builder: (_) => AdaptiveScaffold.toNavigationRail(
              extended: true,
              leading: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: const [
                  Text(
                    "REPLY",
                    style: TextStyle(color: Color.fromARGB(255, 255, 201, 197)),
                  ),
                  Icon(Icons.menu_open)
                ],
              ),
              destinations: destinations,
              trailing: trailingNavRail,
            ),
          ),
        },
      ),
      body: SlotLayout(
        config: {
          Breakpoints.small: SlotLayout.from(
            key: const Key('body'),
            builder: (_) => ListView.builder(
              itemCount: 10,
              itemBuilder: (context, index) => Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  color: const Color.fromARGB(255, 255, 201, 197),
                  height: 400,
                ),
              ),
            ),
          ),
          Breakpoints.medium: SlotLayout.from(
            key: const Key('body1'),
            builder: (_) =>
                GridView.count(crossAxisCount: 2, children: <Widget>[
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
          Breakpoints.large: SlotLayout.from(
            key: const Key('body1'),
            builder: (_) =>
                GridView.count(crossAxisCount: 2, children: <Widget>[
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
        config: {
          Breakpoints.small: SlotLayout.from(
            key: const Key('botnav'),
            inAnimation: AdaptiveScaffold.bottomToTop,
            outAnimation: AdaptiveScaffold.topToBottom,
            builder: (_) => AdaptiveScaffold.toBottomNavigationBar(
                destinations: destinations),
          ),
          Breakpoints.medium: SlotLayoutConfig.empty(),
          Breakpoints.large: SlotLayoutConfig.empty()
        },
      ),
    );
  }
}
