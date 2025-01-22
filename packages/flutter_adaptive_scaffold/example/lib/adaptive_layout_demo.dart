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
    return const MaterialApp(
      home: MyHomePage(),
    );
  }
}

/// Creates a basic adaptive page with navigational elements and a body using
/// [AdaptiveLayout].
class MyHomePage extends StatefulWidget {
  /// Creates a const [MyHomePage].
  const MyHomePage({super.key, this.transitionDuration = 1000});

  /// Declare transition duration.
  final int transitionDuration;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int selectedNavigation = 0;
  int _transitionDuration = 1000;

  // Initialize transition time variable.
  @override
  void initState() {
    super.initState();
    setState(() {
      _transitionDuration = widget.transitionDuration;
    });
  }

  final TextStyle headerColor =
      const TextStyle(color: Color.fromARGB(255, 255, 201, 197));

  @override
  Widget build(BuildContext context) {
    final NavigationRailThemeData navRailTheme =
        Theme.of(context).navigationRailTheme;

    // Define the children to display within the body.
    final List<Widget> children = List<Widget>.generate(10, (int index) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          color: const Color.fromARGB(255, 255, 201, 197),
          height: 400,
        ),
      );
    });

    final Widget trailingNavRail = Column(
      children: <Widget>[
        const Divider(color: Colors.black),
        const SizedBox(height: 10),
        const Row(
          children: <Widget>[
            SizedBox(width: 27),
            Text('Folders', style: TextStyle(fontSize: 16)),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: <Widget>[
            const SizedBox(width: 16),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.folder_copy_outlined),
              iconSize: 21,
            ),
            const SizedBox(width: 21),
            const Flexible(
              child: Text(
                'Freelance',
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: <Widget>[
            const SizedBox(width: 16),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.folder_copy_outlined),
              iconSize: 21,
            ),
            const SizedBox(width: 21),
            const Flexible(
              child: Text(
                'Mortgage',
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: <Widget>[
            const SizedBox(width: 16),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.folder_copy_outlined),
              iconSize: 21,
            ),
            const SizedBox(width: 21),
            const Flexible(
              child: Text('Taxes', overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: <Widget>[
            const SizedBox(width: 16),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.folder_copy_outlined),
              iconSize: 21,
            ),
            const SizedBox(width: 21),
            const Flexible(
              child: Text('Receipts', overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
      ],
    );

    // Define the list of destinations to be used within the app.
    const List<NavigationDestination> destinations = <NavigationDestination>[
      NavigationDestination(
        label: 'Inbox',
        icon: Icon(Icons.inbox_outlined),
        selectedIcon: Icon(Icons.inbox),
      ),
      NavigationDestination(
        label: 'Articles',
        icon: Icon(Icons.article_outlined),
        selectedIcon: Icon(Icons.article),
      ),
      NavigationDestination(
        label: 'Chat',
        icon: Icon(Icons.chat_outlined),
        selectedIcon: Icon(Icons.chat),
      ),
      NavigationDestination(
        label: 'Video',
        icon: Icon(Icons.video_call_outlined),
        selectedIcon: Icon(Icons.video_call),
      ),
    ];

    // #docregion Example
    // AdaptiveLayout has a number of slots that take SlotLayouts and these
    // SlotLayouts' configs take maps of Breakpoints to SlotLayoutConfigs.
    return AdaptiveLayout(
      // An option to override the default transition duration.
      transitionDuration: Duration(milliseconds: _transitionDuration),
      // Primary navigation config has nothing from 0 to 600 dp screen width,
      // then an unextended NavigationRail with no labels and just icons then an
      // extended NavigationRail with both icons and labels.
      primaryNavigation: SlotLayout(
        config: <Breakpoint, SlotLayoutConfig>{
          Breakpoints.medium: SlotLayout.from(
            inAnimation: AdaptiveScaffold.leftOutIn,
            key: const Key('Primary Navigation Medium'),
            builder: (_) => AdaptiveScaffold.standardNavigationRail(
              selectedIndex: selectedNavigation,
              onDestinationSelected: (int newIndex) {
                setState(() {
                  selectedNavigation = newIndex;
                });
              },
              leading: const Icon(Icons.menu),
              destinations: destinations
                  .map((NavigationDestination destination) =>
                      AdaptiveScaffold.toRailDestination(destination))
                  .toList(),
              backgroundColor: navRailTheme.backgroundColor,
              selectedIconTheme: navRailTheme.selectedIconTheme,
              unselectedIconTheme: navRailTheme.unselectedIconTheme,
              selectedLabelTextStyle: navRailTheme.selectedLabelTextStyle,
              unSelectedLabelTextStyle: navRailTheme.unselectedLabelTextStyle,
            ),
          ),
          Breakpoints.mediumLarge: SlotLayout.from(
            key: const Key('Primary Navigation MediumLarge'),
            inAnimation: AdaptiveScaffold.leftOutIn,
            builder: (_) => AdaptiveScaffold.standardNavigationRail(
              selectedIndex: selectedNavigation,
              onDestinationSelected: (int newIndex) {
                setState(() {
                  selectedNavigation = newIndex;
                });
              },
              extended: true,
              leading: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Text(
                    'REPLY',
                    style: headerColor,
                  ),
                  const Icon(Icons.menu_open)
                ],
              ),
              destinations: destinations
                  .map((NavigationDestination destination) =>
                      AdaptiveScaffold.toRailDestination(destination))
                  .toList(),
              trailing: trailingNavRail,
              backgroundColor: navRailTheme.backgroundColor,
              selectedIconTheme: navRailTheme.selectedIconTheme,
              unselectedIconTheme: navRailTheme.unselectedIconTheme,
              selectedLabelTextStyle: navRailTheme.selectedLabelTextStyle,
              unSelectedLabelTextStyle: navRailTheme.unselectedLabelTextStyle,
            ),
          ),
          Breakpoints.large: SlotLayout.from(
            key: const Key('Primary Navigation Large'),
            inAnimation: AdaptiveScaffold.leftOutIn,
            builder: (_) => AdaptiveScaffold.standardNavigationRail(
              selectedIndex: selectedNavigation,
              onDestinationSelected: (int newIndex) {
                setState(() {
                  selectedNavigation = newIndex;
                });
              },
              extended: true,
              leading: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Text(
                    'REPLY',
                    style: headerColor,
                  ),
                  const Icon(Icons.menu_open)
                ],
              ),
              destinations: destinations
                  .map((NavigationDestination destination) =>
                      AdaptiveScaffold.toRailDestination(destination))
                  .toList(),
              trailing: trailingNavRail,
              backgroundColor: navRailTheme.backgroundColor,
              selectedIconTheme: navRailTheme.selectedIconTheme,
              unselectedIconTheme: navRailTheme.unselectedIconTheme,
              selectedLabelTextStyle: navRailTheme.selectedLabelTextStyle,
              unSelectedLabelTextStyle: navRailTheme.unselectedLabelTextStyle,
            ),
          ),
          Breakpoints.extraLarge: SlotLayout.from(
            key: const Key('Primary Navigation ExtraLarge'),
            inAnimation: AdaptiveScaffold.leftOutIn,
            builder: (_) => AdaptiveScaffold.standardNavigationRail(
              selectedIndex: selectedNavigation,
              onDestinationSelected: (int newIndex) {
                setState(() {
                  selectedNavigation = newIndex;
                });
              },
              extended: true,
              leading: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Text(
                    'REPLY',
                    style: headerColor,
                  ),
                  const Icon(Icons.menu_open)
                ],
              ),
              destinations: destinations
                  .map((NavigationDestination destination) =>
                      AdaptiveScaffold.toRailDestination(destination))
                  .toList(),
              trailing: trailingNavRail,
              backgroundColor: navRailTheme.backgroundColor,
              selectedIconTheme: navRailTheme.selectedIconTheme,
              unselectedIconTheme: navRailTheme.unselectedIconTheme,
              selectedLabelTextStyle: navRailTheme.selectedLabelTextStyle,
              unSelectedLabelTextStyle: navRailTheme.unselectedLabelTextStyle,
            ),
          ),
        },
      ),
      // Body switches between a ListView and a GridView from small to medium
      // breakpoints and onwards.
      body: SlotLayout(
        config: <Breakpoint, SlotLayoutConfig>{
          Breakpoints.small: SlotLayout.from(
            key: const Key('Body Small'),
            builder: (_) => ListView.builder(
              itemCount: children.length,
              itemBuilder: (BuildContext context, int index) => children[index],
            ),
          ),
          Breakpoints.medium: SlotLayout.from(
            key: const Key('Body Medium'),
            builder: (_) =>
                GridView.count(crossAxisCount: 2, children: children),
          ),
          Breakpoints.mediumLarge: SlotLayout.from(
            key: const Key('Body MediumLarge'),
            builder: (_) =>
                GridView.count(crossAxisCount: 3, children: children),
          ),
          Breakpoints.large: SlotLayout.from(
            key: const Key('Body Large'),
            builder: (_) =>
                GridView.count(crossAxisCount: 4, children: children),
          ),
          Breakpoints.extraLarge: SlotLayout.from(
            key: const Key('Body ExtraLarge'),
            builder: (_) =>
                GridView.count(crossAxisCount: 5, children: children),
          ),
        },
      ),
      // BottomNavigation is only active in small views defined as under 600 dp
      // width.
      bottomNavigation: SlotLayout(
        config: <Breakpoint, SlotLayoutConfig>{
          Breakpoints.small: SlotLayout.from(
            key: const Key('Bottom Navigation Small'),
            inAnimation: AdaptiveScaffold.bottomToTop,
            outAnimation: AdaptiveScaffold.topToBottom,
            builder: (_) => AdaptiveScaffold.standardBottomNavigationBar(
              destinations: destinations,
              currentIndex: selectedNavigation,
              onDestinationSelected: (int newIndex) {
                setState(() {
                  selectedNavigation = newIndex;
                });
              },
            ),
          )
        },
      ),
    );
    // #enddocregion Example
  }
}
