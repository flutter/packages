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

class _CustomSmallBreakpoint extends Breakpoint {
  @override
  bool isActive(BuildContext context) {
    return MediaQuery.of(context).size.width >= 0 &&
        MediaQuery.of(context).size.width < 400;
  }
}

class _CustomMediumBreakpoint extends Breakpoint {
  @override
  bool isActive(BuildContext context) {
    return MediaQuery.of(context).size.width >= 400 &&
        MediaQuery.of(context).size.width < 840;
  }
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

    Widget leadingUnExtendedNavRail = Column(
      children: const [
        SizedBox(
          height: 10,
        ),
        Icon(Icons.menu)
      ],
    );
    Widget leadingExtendedNavRail = Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: const [
        Text(
          "REPLY",
          style: TextStyle(color: Color.fromARGB(255, 255, 201, 197)),
        ),
        Icon(Icons.menu_open)
      ],
    );
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

    return AdaptiveScaffold(
      // An option to override the default breakpoints used for small, medium,
      // and large.
      smallBreakpoint: _CustomSmallBreakpoint(),
      mediumBreakpoint: _CustomMediumBreakpoint(),
      // Define the list of destinations to be used within the app.
      destinations: const <NavigationDestination>[
        NavigationDestination(icon: Icon(Icons.inbox), label: 'Inbox'),
        NavigationDestination(icon: Icon(Icons.article), label: 'Articles'),
        NavigationDestination(icon: Icon(Icons.chat), label: 'Chat'),
        NavigationDestination(icon: Icon(Icons.video_call), label: 'Video'),
      ],
      trailingNavRail: trailingNavRail,
      leadingUnExtendedNavRail: leadingUnExtendedNavRail,
      leadingExtendedNavRail: leadingExtendedNavRail,
      // Override the default body during the small breakpoint to instead become
      // a ListView.
      smallBody: (_) => ListView.builder(
        itemCount: 10,
        itemBuilder: (context, index) => Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            height: 250,
            color: const Color.fromARGB(255, 255, 201, 197),
          ),
        ),
      ),
      // Define the default body to be a GridView.
      body: (_) => GridView.count(crossAxisCount: 2, children: <Widget>[
        for (int i = 0; i < 10; i++)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              color: const Color.fromARGB(255, 255, 201, 197),
              height: 400,
            ),
          )
      ]),
      // Override the default secondaryBody during the smallBreakpoint to be
      // empty. Must use AdaptiveScaffold.emptyBuilder to ensure it is properly
      // overriden.
      smallSecondaryBody: AdaptiveScaffold.emptyBuilder,
      // Define a default secondaryBody.
      secondaryBody: (_) =>
          Container(color: const Color.fromARGB(255, 234, 158, 192)),
    );
  }
}
