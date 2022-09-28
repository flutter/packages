// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/cupertino.dart';
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

/// Extension to get the child widget of the Page. Wish there were a better way...
extension PageWithChild on Page<dynamic> {
  /// Gets the child of the page
  Widget? findTheChild() {
    final Page<dynamic> widget = this;
    if (widget is MaterialPage) {
      return widget.child;
    } else if (widget is CupertinoPage) {
      return widget.child;
    } else if (widget is CustomTransitionPage) {
      return widget.child;
    }
    return null;
    // An unsafer option... :
    //return (this as dynamic).child as Widget;
  }
}

/// ShellRoute that uses a bottom tab navigation (ScaffoldWithNavBar) with
/// separate navigators for each tab.
class BottomTabBarShellRoute extends ShellRoute {
  /// Constructs a BottomTabBarShellRoute
  BottomTabBarShellRoute({
    required this.tabs,
    GlobalKey<NavigatorState>? navigatorKey,
    List<RouteBase> routes = const <RouteBase>[],
    Key? scaffoldKey = const ValueKey<String>('ScaffoldWithNavBar'),
  }) : super(
            navigatorKey: navigatorKey,
            routes: routes,
            nestedNavigationBuilder: (BuildContext context, GoRouterState state,
                List<Page<dynamic>> pagesForCurrentRoute) {
              // The first (and only) page will be the nested navigator for the
              // current tab. The pages parameter will in this case
              final Widget? shellNav =
                  pagesForCurrentRoute.first.findTheChild();
              return ScaffoldWithNavBar(
                  tabs: tabs,
                  key: scaffoldKey,
                  shellNav: shellNav! as Navigator);
            });

  /// The tabs
  final List<ScaffoldWithNavBarTabItem> tabs;
}

/// An example demonstrating how to use nested navigators
class NestedTabNavigationExampleApp extends StatelessWidget {
  /// Creates a NestedTabNavigationExampleApp
  NestedTabNavigationExampleApp({Key? key}) : super(key: key);

  static final List<ScaffoldWithNavBarTabItem> _tabs =
      <ScaffoldWithNavBarTabItem>[
    ScaffoldWithNavBarTabItem(
        initialLocation: '/a',
        navigatorKey: _sectionANavigatorKey,
        icon: const Icon(Icons.home),
        label: 'Section A'),
    ScaffoldWithNavBarTabItem(
      initialLocation: '/b',
      navigatorKey: _sectionBNavigatorKey,
      icon: const Icon(Icons.settings),
      label: 'Section B',
    ),
  ];

  final GoRouter _router = GoRouter(
    initialLocation: '/a',
    routes: <RouteBase>[
      /// Custom top shell route - wraps the below routes in a scaffold with
      /// a bottom tab navigator (ScaffoldWithNavBar). Note that no Navigator
      /// will be created by this top ShellRoute.
      BottomTabBarShellRoute(
        tabs: _tabs,
        routes: <RouteBase>[
          ShellRoute(
              navigatorKey: _sectionANavigatorKey,
              builder:
                  (BuildContext context, GoRouterState state, Widget child) {
                return child;
              },
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
              ]),
          ShellRoute(
            navigatorKey: _sectionBNavigatorKey,
            builder: (BuildContext context, GoRouterState state, Widget child) {
              return child;
            },
            routes: <RouteBase>[
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
  const ScaffoldWithNavBarTabItem(
      {required this.initialLocation,
      required this.navigatorKey,
      required Widget icon,
      String? label})
      : super(icon: icon, label: label);

  /// The initial location/path
  final String initialLocation;

  /// Optional navigatorKey
  final GlobalKey<NavigatorState> navigatorKey;
}

/// Builds the "shell" for the app by building a Scaffold with a
/// BottomNavigationBar, where [child] is placed in the body of the Scaffold.
class ScaffoldWithNavBar extends StatefulWidget {
  /// Constructs an [ScaffoldWithNavBar].
  const ScaffoldWithNavBar({
    required this.shellNav,
    required this.tabs,
    Key? key,
  }) : super(key: key ?? const ValueKey<String>('ScaffoldWithNavBar'));

  /// The navigator for the currently active tab
  final Navigator shellNav;

  /// The tabs
  final List<ScaffoldWithNavBarTabItem> tabs;

  @override
  State<StatefulWidget> createState() => ScaffoldWithNavBarState();
}

/// State for ScaffoldWithNavBar
class ScaffoldWithNavBarState extends State<ScaffoldWithNavBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final List<_NavBarTabNavigator> _tabs;

  int _locationToTabIndex(String location) {
    final int index = _tabs.indexWhere(
        (_NavBarTabNavigator t) => location.startsWith(t.initialLocation));
    return index < 0 ? 0 : index;
  }

  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabs = widget.tabs
        .map((ScaffoldWithNavBarTabItem e) => _NavBarTabNavigator(e))
        .toList();

    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    _animationController.forward();
  }

  @override
  void didUpdateWidget(covariant ScaffoldWithNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateForCurrentTab();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateForCurrentTab();
  }

  void _updateForCurrentTab() {
    final int previousIndex = _currentIndex;
    _currentIndex = _locationToTabIndex(GoRouter.of(context).location);

    final _NavBarTabNavigator tabNav = _tabs[_currentIndex];
    tabNav.navigator = widget.shellNav;
    assert(widget.shellNav.key == tabNav.navigatorKey);

    if (previousIndex != _currentIndex) {
      _animationController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(context),
      bottomNavigationBar: BottomNavigationBar(
        items: _tabs
            .map((_NavBarTabNavigator e) => e.bottomNavigationTab)
            .toList(),
        currentIndex: _currentIndex,
        onTap: (int idx) => _onItemTapped(idx, context),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return FadeTransition(
        opacity: _animationController,
        child: IndexedStack(
            index: _currentIndex,
            children: _tabs
                .map((_NavBarTabNavigator tab) => tab.buildNavigator(context))
                .toList()));
  }

  void _onItemTapped(int index, BuildContext context) {
    GoRouter.of(context).go(_tabs[index].currentLocation);
  }
}

/// Class representing a tab along with its navigation logic
class _NavBarTabNavigator {
  _NavBarTabNavigator(this.bottomNavigationTab);

  final ScaffoldWithNavBarTabItem bottomNavigationTab;
  Navigator? navigator;

  String get initialLocation => bottomNavigationTab.initialLocation;
  Key get navigatorKey => bottomNavigationTab.navigatorKey;
  List<Page<dynamic>> get pages => navigator?.pages ?? <Page<dynamic>>[];
  String get currentLocation =>
      pages.isNotEmpty ? pages.last.name! : initialLocation;

  Widget buildNavigator(BuildContext context) {
    if (navigator != null) {
      return navigator!;
    } else {
      return const SizedBox.shrink();
    }
  }
}

/// Widget for the root/initial pages in the bottom navigation bar.
class RootScreen extends StatelessWidget {
  /// Creates a RootScreen
  const RootScreen({required this.label, required this.detailsPath, Key? key})
      : super(key: key);

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
            Text('Screen $label',
                style: Theme.of(context).textTheme.titleLarge),
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
