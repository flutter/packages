// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';


// This example demonstrates how to setup nested navigation using a
// BottomNavigationBar, where each tab uses its own persistent navigator, i.e.
// navigation state is maintained separately for each tab. This setup also
// enables deep linking into nested pages.
//
// The example is loosely based on the ShellRoute sample in go_router, but
// differs in that it is able to maintain the navigation state of each tab.
// This example introduces a fex (imperfect) classes that ideally should be part
// of go_router, such as BottomTabBarShellRoute etc.

void main() {
  runApp(NestedTabNavigationExampleApp());
}


/// NestedNavigationShellRoute that uses a bottom tab navigation
/// (ScaffoldWithNavBar) with separate navigators for each tab.
class BottomTabBarShellRoute extends NestedNavigationShellRoute {
  /// Constructs a BottomTabBarShellRoute
  BottomTabBarShellRoute({
    required this.tabs,
    List<RouteBase> routes = const <RouteBase>[],
    Key? scaffoldKey = const ValueKey<String>('ScaffoldWithNavBar'),
  }) : super(
      routes: routes,
      nestedNavigationBuilder: (BuildContext context, GoRouterState state,
          List<Page<dynamic>> pagesForCurrentRoute) {
        return ScaffoldWithNavBar(tabs: tabs, key: scaffoldKey,
            pagesForCurrentRoute: pagesForCurrentRoute);
      }
  );

  /// The tabs
  final List<ScaffoldWithNavBarTabItem> tabs;
}


/// An example demonstrating how to use nested navigators
class NestedTabNavigationExampleApp extends StatelessWidget {
  /// Creates a NestedTabNavigationExampleApp
  NestedTabNavigationExampleApp({Key? key}) : super(key: key);

  static const List<ScaffoldWithNavBarTabItem> _tabs =
  <ScaffoldWithNavBarTabItem>[
    ScaffoldWithNavBarTabItem(initialLocation: '/a',
        icon: Icon(Icons.home), label: 'Section A'),
    ScaffoldWithNavBarTabItem(initialLocation: '/b',
        icon: Icon(Icons.settings), label: 'Section B'),
  ];

  final GoRouter _router = GoRouter(
    initialLocation: '/a',
    navigatorKey: GlobalKey<NavigatorState>(debugLabel: 'Root'),
    routes: <RouteBase>[
      /// Custom shell route - wraps the below routes in a scaffold with
      /// a bottom tab navigator
      BottomTabBarShellRoute(
        tabs: _tabs,
        routes: <RouteBase>[
          /// The screen to display as the root in the first tab of the bottom
          /// navigation bar.
          GoRoute(
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
            path: '/b',
            builder: (BuildContext context, GoRouterState state) =>
            const RootScreen(label: 'B', detailsPath: '/b/details'),
            routes: <RouteBase>[
              /// The details screen to display stacked on navigator of the
              /// second tab. This will cover screen B but not the application
              /// shell (bottom navigation bar).
              GoRoute(
                path: 'details',
                builder: (BuildContext context, GoRouterState state) =>
                const DetailsScreen(label: 'B'),
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
      routeInformationParser: _router.routeInformationParser,
      routerDelegate: _router.routerDelegate,
      routeInformationProvider: _router.routeInformationProvider,
    );
  }
}


/// Representation of a tab item in a [ScaffoldWithNavBar]
class ScaffoldWithNavBarTabItem extends BottomNavigationBarItem {
  /// Constructs an [ScaffoldWithNavBarTabItem].
  const ScaffoldWithNavBarTabItem({required this.initialLocation,
    this.navigatorKey, required Widget icon, String? label}) :
        super(icon: icon, label: label);

  /// The initial location/path
  final String initialLocation;

  /// Optional navigatorKey
  final GlobalKey<NavigatorState>? navigatorKey;
}


/// Builds the "shell" for the app by building a Scaffold with a
/// BottomNavigationBar, where [child] is placed in the body of the Scaffold.
class ScaffoldWithNavBar extends StatefulWidget {
  /// Constructs an [ScaffoldWithNavBar].
  const ScaffoldWithNavBar({
    required this.pagesForCurrentRoute,
    required this.tabs,
    Key? key,
  }) : super(key: key ?? const ValueKey<String>('ScaffoldWithNavBar'));

  /// The widget to display in the body of the Scaffold.
  /// In this sample, it is a Navigator.
  final List<Page<dynamic>> pagesForCurrentRoute;

  /// The tabs
  final List<ScaffoldWithNavBarTabItem> tabs;

  @override
  State<StatefulWidget> createState() => ScaffoldWithNavBarState();
}

/// State for ScaffoldWithNavBar
class ScaffoldWithNavBarState extends State<ScaffoldWithNavBar> {

  late final List<_NavBarTabNavigator> _tabs;

  int _locationToTabIndex(String location) {
    final int index = _tabs.indexWhere((_NavBarTabNavigator t) =>
        location.startsWith(t.initialLocation));
    return index < 0 ? 0 : index;
  }

  int get _currentIndex => _locationToTabIndex(GoRouter.of(context).location);

  @override
  void initState() {
    super.initState();
    _tabs = widget.tabs.map((ScaffoldWithNavBarTabItem e) =>
        _NavBarTabNavigator(e)).toList();
  }

  @override
  void didUpdateWidget(covariant ScaffoldWithNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    final GoRouter route = GoRouter.of(context);
    final String location = route.location;

    final int tabIndex = _locationToTabIndex(location);

    final _NavBarTabNavigator tabNav = _tabs[tabIndex];
    final List<Page<dynamic>> filteredPages = widget.pagesForCurrentRoute
        .where((Page<dynamic> p) => p.name!.startsWith(tabNav.initialLocation))
        .toList();

    if (filteredPages.length == 1 && location != tabNav.initialLocation) {
      final int index = tabNav.pages.indexWhere((Page<dynamic> e) => e.name == location);
      if (index < 0) {
        tabNav.pages.add(filteredPages.last);
      } else {
        tabNav.pages.length = index + 1;
      }
    } else {
      tabNav.pages = filteredPages;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(context),
      bottomNavigationBar: BottomNavigationBar(
        items: _tabs.map((_NavBarTabNavigator e) => e.bottomNavigationTab).toList(),
        currentIndex: _currentIndex,
        onTap: (int idx) => _onItemTapped(idx, context),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return IndexedStack(
        index: _currentIndex,
        children: _tabs.map((_NavBarTabNavigator tab) => tab.buildNavigator(context)).toList()
    );
  }

  void _onItemTapped(int index, BuildContext context) {
    GoRouter.of(context).go(_tabs[index].currentLocation);
  }
}


/// Class representing
class _NavBarTabNavigator {

  _NavBarTabNavigator(this.bottomNavigationTab);
  static const String _initialPlaceholderPageName = '#placeholder#';

  final ScaffoldWithNavBarTabItem bottomNavigationTab;
  String get initialLocation => bottomNavigationTab.initialLocation;
  Key? get navigatorKey => bottomNavigationTab.navigatorKey;
  List<Page<dynamic>> pages = <Page<dynamic>>[];

  List<Page<dynamic>> get _pagesWithPlaceholder => pages.isNotEmpty ? pages :
  <Page<dynamic>>[const MaterialPage<dynamic>(name: _initialPlaceholderPageName,
      child: SizedBox.shrink())];

  String get currentLocation => pages.isNotEmpty ? pages.last.name! : initialLocation;

  Widget buildNavigator(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      pages: _pagesWithPlaceholder,
      onPopPage: (Route<dynamic> route, dynamic result) {
        if (pages.length == 1 || !route.didPop(result)) {
          return false;
        }
        GoRouter.of(context).pop();
        return true;
      },
    );
  }
}


/// Widget for the root/initial pages in the bottom navigation bar.
class RootScreen extends StatelessWidget {
  /// Creates a RootScreen
  const RootScreen({required this.label, required this.detailsPath, Key? key}) :
        super(key: key);

  /// The label
  final String label;

  /// The path to the detail page
  final String detailsPath;

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
            Text('Screen $label', style: Theme.of(context).textTheme.titleLarge),
            const Padding(padding: EdgeInsets.all(4)),
            TextButton(
              onPressed: () {
                GoRouter.of(context).go(detailsPath);
              },
              child: const Text('View details'),
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
    Key? key,
  }) : super(key: key);

  /// The label to display in the center of the screen.
  final String label;

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
            Text('Details for ${widget.label} - Counter: $_counter',
                style: Theme.of(context).textTheme.titleLarge),
            const Padding(padding: EdgeInsets.all(4)),
            TextButton(
              onPressed: () {
                setState(() { _counter++; });
              },
              child: const Text('Increment counter'),
            ),
          ],
        ),
      ),
    );
  }
}
