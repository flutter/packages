// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

final GlobalKey<NavigatorState> _sectionANavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'sectionANav');
final GlobalKey<NavigatorState> _sectionBNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'sectionBNav');

// This example demonstrates how to setup nested navigation using a
// BottomNavigationBar, where each tab uses its own persistent navigator, i.e.
// navigation state is maintained separately for each tab. This setup also
// enables deep linking into nested pages.
//
// This example demonstrates how to display routes within a ShellRoute using a
// `nestedNavigationBuilder`. Navigators for the tabs ('Section A' and
// 'Section B') are created via nested ShellRoutes. Note that no navigator will
// be created by the "top" ShellRoute. This example is similar to the ShellRoute
// example, but differs in that it is able to maintain the navigation state of
// each tab.

void main() {
  runApp(NestedTabNavigationExampleApp());
}

/// An example demonstrating how to use nested navigators
class NestedTabNavigationExampleApp extends StatelessWidget {
  /// Creates a NestedTabNavigationExampleApp
  NestedTabNavigationExampleApp({Key? key}) : super(key: key);

  static final List<ScaffoldWithNavBarTabItem> _tabs =
      <ScaffoldWithNavBarTabItem>[
    ScaffoldWithNavBarTabItem(
        navigationItem: StackedNavigationItem(
            rootRoutePath: '/a', navigatorKey: _sectionANavigatorKey),
        icon: const Icon(Icons.home),
        label: 'Section A'),
    ScaffoldWithNavBarTabItem(
      navigationItem: StackedNavigationItem(
          rootRoutePath: '/b', navigatorKey: _sectionBNavigatorKey),
      icon: const Icon(Icons.settings),
      label: 'Section B',
    ),
  ];

  final GoRouter _router = GoRouter(
    initialLocation: '/a',
    routes: <RouteBase>[
      /// Custom top shell route - wraps the below routes in a scaffold with
      /// a bottom tab navigator (ScaffoldWithNavBar). Each tab will use its own
      /// Navigator, provided by MultiPathShellRoute.
      PartitionedShellRoute.stackedNavigation(
        stackItems: _tabs
            .map((ScaffoldWithNavBarTabItem e) => e.navigationItem)
            .toList(),
        scaffoldBuilder: (BuildContext context, int currentIndex,
            List<StackedNavigationItemState> itemsState, Widget scaffoldBody) {
          return ScaffoldWithNavBar(
              tabs: _tabs,
              currentIndex: currentIndex,
              itemsState: itemsState,
              body: scaffoldBody);
        },

        /// A transition builder is optional, only included here for
        /// demonstration purposes.
        transitionBuilder:
            (BuildContext context, Animation<double> animation, Widget child) =>
                FadeTransition(opacity: animation, child: child),
        routes: <GoRoute>[
          /// The screen to display as the root in the first tab of the bottom
          /// navigation bar. Note that the root route must specify the
          /// `parentNavigatorKey`
          GoRoute(
            parentNavigatorKey: _sectionANavigatorKey,
            path: '/a',
            builder: (BuildContext context, GoRouterState state) =>
                const RootScreen(label: 'A', detailsPath: '/a/details'),
            routes: <RouteBase>[
              /// The details screen to display stacked on navigator of the
              /// first tab. This will cover screen A but not the application
              /// shell (bottom navigation bar).
              GoRoute(
                path: 'details',
                builder: (BuildContext context, GoRouterState state) =>
                    const DetailsScreen(label: 'A'),
              ),
            ],
          ),

          /// The screen to display as the root in the second tab of the bottom
          /// navigation bar.
          GoRoute(
            parentNavigatorKey: _sectionBNavigatorKey,
            path: '/b',
            builder: (BuildContext context, GoRouterState state) =>
                const RootScreen(
                    label: 'B',
                    detailsPath: '/b/details/1',
                    detailsPath2: '/b/details/2'),
            routes: <RouteBase>[
              /// The details screen to display stacked on navigator of the
              /// second tab. This will cover screen B but not the application
              /// shell (bottom navigation bar).
              GoRoute(
                path: 'details/:param',
                builder: (BuildContext context, GoRouterState state) =>
                    DetailsScreen(label: 'B', param: state.params['param']),
              ),
            ],
          ),
        ],
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      routerConfig: _router,
    );
  }
}

/// Representation of a tab item in a [ScaffoldWithNavBar]
class ScaffoldWithNavBarTabItem extends BottomNavigationBarItem {
  /// Constructs an [ScaffoldWithNavBarTabItem].
  const ScaffoldWithNavBarTabItem(
      {required this.navigationItem, required Widget icon, String? label})
      : super(icon: icon, label: label);

  /// The [StackedNavigationItem]
  final StackedNavigationItem navigationItem;

  /// Gets the associated navigator key
  GlobalKey<NavigatorState> get navigatorKey => navigationItem.navigatorKey;
}

/// Builds the "shell" for the app by building a Scaffold with a
/// BottomNavigationBar, where [child] is placed in the body of the Scaffold.
class ScaffoldWithNavBar extends StatelessWidget {
  /// Constructs an [ScaffoldWithNavBar].
  const ScaffoldWithNavBar({
    required this.currentIndex,
    required this.itemsState,
    required this.body,
    required this.tabs,
    Key? key,
  }) : super(key: key ?? const ValueKey<String>('ScaffoldWithNavBar'));

  /// Currently active tab index
  final int currentIndex;

  /// Route state
  final List<StackedNavigationItemState> itemsState;

  /// Body, i.e. the index stack
  final Widget body;

  /// The tabs
  final List<ScaffoldWithNavBarTabItem> tabs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: body,
      bottomNavigationBar: BottomNavigationBar(
        items: tabs,
        currentIndex: currentIndex,
        onTap: (int tappedIndex) =>
            _onItemTapped(context, itemsState[tappedIndex]),
      ),
    );
  }

  void _onItemTapped(
      BuildContext context, StackedNavigationItemState itemState) {
    GoRouter.of(context).go(itemState.currentLocation);
  }
}

/// Widget for the root/initial pages in the bottom navigation bar.
class RootScreen extends StatelessWidget {
  /// Creates a RootScreen
  const RootScreen(
      {required this.label,
      required this.detailsPath,
      this.detailsPath2,
      Key? key})
      : super(key: key);

  /// The label
  final String label;

  /// The path to the detail page
  final String detailsPath;

  /// The path to another detail page
  final String? detailsPath2;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tab root - $label'),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text('Screen $label',
                style: Theme.of(context).textTheme.titleLarge),
            const Padding(padding: EdgeInsets.all(4)),
            TextButton(
              onPressed: () {
                GoRouter.of(context).go(detailsPath);
              },
              child: const Text('View details'),
            ),
            const Padding(padding: EdgeInsets.all(4)),
            if (detailsPath2 != null)
              TextButton(
                onPressed: () {
                  GoRouter.of(context).go(detailsPath2!);
                },
                child: const Text('View more details'),
              ),
          ],
        ),
      ),
    );
  }
}

/// The details screen for either the A or B screen.
class DetailsScreen extends StatefulWidget {
  /// Constructs a [DetailsScreen].
  const DetailsScreen({
    required this.label,
    this.param,
    Key? key,
  }) : super(key: key);

  /// The label to display in the center of the screen.
  final String label;

  /// Optional param
  final String? param;

  @override
  State<StatefulWidget> createState() => DetailsScreenState();
}

/// The state for DetailsScreen
class DetailsScreenState extends State<DetailsScreen> {
  int _counter = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Details Screen - ${widget.label}'),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (widget.param != null)
              Text('Parameter: ${widget.param!}',
                  style: Theme.of(context).textTheme.titleLarge),
            const Padding(padding: EdgeInsets.all(4)),
            Text('Details for ${widget.label} - Counter: $_counter',
                style: Theme.of(context).textTheme.titleLarge),
            const Padding(padding: EdgeInsets.all(4)),
            TextButton(
              onPressed: () {
                setState(() {
                  _counter++;
                });
              },
              child: const Text('Increment counter'),
            ),
          ],
        ),
      ),
    );
  }
}
