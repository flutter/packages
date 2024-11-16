// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');
final GlobalKey<NavigatorState> _tabANavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'tabANav');
final GlobalKey<NavigatorState> _tabBNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'tabBNav');
final GlobalKey<NavigatorState> _tabB1NavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'tabB1Nav');
final GlobalKey<NavigatorState> _tabB2NavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'tabB2Nav');

@visibleForTesting
// ignore: public_member_api_docs
final GlobalKey<TabbedRootScreenState> tabbedRootScreenKey =
    GlobalKey<TabbedRootScreenState>(debugLabel: 'TabbedRootScreen');

// This example demonstrates how to setup nested navigation using a
// BottomNavigationBar, where each bar item uses its own persistent navigator,
// i.e. navigation state is maintained separately for each item. This setup also
// enables deep linking into nested pages.
//
// This example also demonstrates how build a nested shell with a custom
// container for the branch Navigators (in this case a TabBarView).

void main() {
  runApp(NestedTabNavigationExampleApp());
}

/// An example demonstrating how to use nested navigators
class NestedTabNavigationExampleApp extends StatelessWidget {
  /// Creates a NestedTabNavigationExampleApp
  NestedTabNavigationExampleApp({super.key});

  final GoRouter _router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/a',
    routes: <RouteBase>[
      StatefulShellRoute(
        builder: (BuildContext context, GoRouterState state,
            StatefulNavigationShell navigationShell) {
          // This nested StatefulShellRoute demonstrates the use of a
          // custom container for the branch Navigators. In this implementation,
          // no customization is done in the builder function (navigationShell
          // itself is simply used as the Widget for the route). Instead, the
          // navigatorContainerBuilder function below is provided to
          // customize the container for the branch Navigators.
          return navigationShell;
        },
        navigatorContainerBuilder: (BuildContext context,
            StatefulNavigationShell navigationShell, List<Widget> children) {
          // Returning a customized container for the branch
          // Navigators (i.e. the `List<Widget> children` argument).
          //
          // See ScaffoldWithNavBar for more details on how the children
          // are managed (using AnimatedBranchContainer).
          return ScaffoldWithNavBar(
              navigationShell: navigationShell, children: children);
          // NOTE: To use a Cupertino version of ScaffoldWithNavBar, replace
          // ScaffoldWithNavBar above with CupertinoScaffoldWithNavBar.
        },
        branches: <StatefulShellBranch>[
          // The route branch for the first tab of the bottom navigation bar.
          StatefulShellBranch(
            navigatorKey: _tabANavigatorKey,
            routes: <RouteBase>[
              GoRoute(
                // The screen to display as the root in the first tab of the
                // bottom navigation bar.
                path: '/a',
                builder: (BuildContext context, GoRouterState state) =>
                    const RootScreenA(),
                routes: <RouteBase>[
                  // The details screen to display stacked on navigator of the
                  // first tab. This will cover screen A but not the application
                  // shell (bottom navigation bar).
                  GoRoute(
                    path: 'details',
                    builder: (BuildContext context, GoRouterState state) =>
                        const DetailsScreen(label: 'A'),
                  ),
                ],
              ),
            ],
          ),

          // The route branch for the second tab of the bottom navigation bar.
          StatefulShellBranch(
            navigatorKey: _tabBNavigatorKey,
            // To enable preloading of the initial locations of branches, pass
            // `true` for the parameter `preload` (`false` is default).
            preload: true,
            // StatefulShellBranch will automatically use the first descendant
            // GoRoute as the initial location of the branch. If another route
            // is desired, specify the location of it using the defaultLocation
            // parameter.
            // defaultLocation: '/b1',
            routes: <RouteBase>[
              StatefulShellRoute(
                builder: (BuildContext context, GoRouterState state,
                    StatefulNavigationShell navigationShell) {
                  // Just like with the top level StatefulShellRoute, no
                  // customization is done in the builder function.
                  return navigationShell;
                },
                navigatorContainerBuilder: (BuildContext context,
                    StatefulNavigationShell navigationShell,
                    List<Widget> children) {
                  // Returning a customized container for the branch
                  // Navigators (i.e. the `List<Widget> children` argument).
                  //
                  // See TabbedRootScreen for more details on how the children
                  // are managed (in a TabBarView).
                  return TabbedRootScreen(
                    navigationShell: navigationShell,
                    key: tabbedRootScreenKey,
                    children: children,
                  );
                  // NOTE: To use a PageView version of TabbedRootScreen,
                  // replace TabbedRootScreen above with PagedRootScreen.
                },
                // This bottom tab uses a nested shell, wrapping sub routes in a
                // top TabBar.
                branches: <StatefulShellBranch>[
                  StatefulShellBranch(
                      navigatorKey: _tabB1NavigatorKey,
                      routes: <GoRoute>[
                        GoRoute(
                          path: '/b1',
                          builder:
                              (BuildContext context, GoRouterState state) =>
                                  const TabScreen(
                                      label: 'B1', detailsPath: '/b1/details'),
                          routes: <RouteBase>[
                            GoRoute(
                              path: 'details',
                              builder:
                                  (BuildContext context, GoRouterState state) =>
                                      const DetailsScreen(
                                label: 'B1',
                                withScaffold: false,
                              ),
                            ),
                          ],
                        ),
                      ]),
                  StatefulShellBranch(
                      navigatorKey: _tabB2NavigatorKey,
                      // To enable preloading for all nested branches, set
                      // `preload` to `true` (`false` is default).
                      preload: true,
                      routes: <GoRoute>[
                        GoRoute(
                          path: '/b2',
                          builder:
                              (BuildContext context, GoRouterState state) =>
                                  const TabScreen(
                                      label: 'B2', detailsPath: '/b2/details'),
                          routes: <RouteBase>[
                            GoRoute(
                              path: 'details',
                              builder:
                                  (BuildContext context, GoRouterState state) =>
                                      const DetailsScreen(
                                label: 'B2',
                                withScaffold: false,
                              ),
                            ),
                          ],
                        ),
                      ]),
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
      routerConfig: _router,
    );
  }
}

/// Builds the "shell" for the app by building a Scaffold with a
/// BottomNavigationBar, where [child] is placed in the body of the Scaffold.
class ScaffoldWithNavBar extends StatelessWidget {
  /// Constructs an [ScaffoldWithNavBar].
  const ScaffoldWithNavBar({
    required this.navigationShell,
    required this.children,
    Key? key,
  }) : super(key: key ?? const ValueKey<String>('ScaffoldWithNavBar'));

  /// The navigation shell and container for the branch Navigators.
  final StatefulNavigationShell navigationShell;

  /// The children (branch Navigators) to display in a custom container
  /// ([AnimatedBranchContainer]).
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBranchContainer(
        currentIndex: navigationShell.currentIndex,
        children: children,
      ),
      bottomNavigationBar: BottomNavigationBar(
        // Here, the items of BottomNavigationBar are hard coded. In a real
        // world scenario, the items would most likely be generated from the
        // branches of the shell route, which can be fetched using
        // `navigationShell.route.branches`.
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Section A'),
          BottomNavigationBarItem(icon: Icon(Icons.work), label: 'Section B'),
        ],
        currentIndex: navigationShell.currentIndex,
        onTap: (int index) => _onTap(context, index),
      ),
    );
  }

  /// Navigate to the current location of the branch at the provided index when
  /// tapping an item in the BottomNavigationBar.
  void _onTap(BuildContext context, int index) {
    // When navigating to a new branch, it's recommended to use the goBranch
    // method, as doing so makes sure the last navigation state of the
    // Navigator for the branch is restored.
    navigationShell.goBranch(
      index,
      // A common pattern when using bottom navigation bars is to support
      // navigating to the initial location when tapping the item that is
      // already active. This example demonstrates how to support this behavior,
      // using the initialLocation parameter of goBranch.
      initialLocation: index == navigationShell.currentIndex,
    );
  }
}

/// Alternative version of [ScaffoldWithNavBar], using a [CupertinoTabScaffold].
// ignore: unused_element, unreachable_from_main
class CupertinoScaffoldWithNavBar extends StatefulWidget {
  /// Constructs an [ScaffoldWithNavBar].
  // ignore: unreachable_from_main
  const CupertinoScaffoldWithNavBar({
    required this.navigationShell,
    required this.children,
    Key? key,
  }) : super(key: key ?? const ValueKey<String>('ScaffoldWithNavBar'));

  /// The navigation shell and container for the branch Navigators.
  // ignore: unreachable_from_main
  final StatefulNavigationShell navigationShell;

  /// The children (branch Navigators) to display in a custom container
  /// ([AnimatedBranchContainer]).
  // ignore: unreachable_from_main
  final List<Widget> children;

  @override
  State<StatefulWidget> createState() => _CupertinoScaffoldWithNavBarState();
}

class _CupertinoScaffoldWithNavBarState
    extends State<CupertinoScaffoldWithNavBar> {
  late final CupertinoTabController tabController =
      CupertinoTabController(initialIndex: widget.navigationShell.currentIndex);

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      controller: tabController,
      tabBar: CupertinoTabBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Section A'),
          BottomNavigationBarItem(icon: Icon(Icons.work), label: 'Section B'),
        ],
        currentIndex: widget.navigationShell.currentIndex,
        onTap: (int index) => _onTap(context, index),
      ),
      // Note: It is common to use CupertinoTabView for the tabBuilder when
      // using CupertinoTabScaffold and CupertinoTabBar. This would however be
      // redundant when using StatefulShellRoute, since a separate Navigator is
      // already created for each branch, meaning we can simply use the branch
      // Navigator Widgets (i.e. widget.children) directly.
      tabBuilder: (BuildContext context, int index) => widget.children[index],
    );
  }

  void _onTap(BuildContext context, int index) {
    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
  }
}

/// Custom branch Navigator container that provides animated transitions
/// when switching branches.
class AnimatedBranchContainer extends StatelessWidget {
  /// Creates a AnimatedBranchContainer
  const AnimatedBranchContainer(
      {super.key, required this.currentIndex, required this.children});

  /// The index (in [children]) of the branch Navigator to display.
  final int currentIndex;

  /// The children (branch Navigators) to display in this container.
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Stack(
        children: children.mapIndexed(
      (int index, Widget navigator) {
        return AnimatedScale(
          scale: index == currentIndex ? 1 : 1.5,
          duration: const Duration(milliseconds: 400),
          child: AnimatedOpacity(
            opacity: index == currentIndex ? 1 : 0,
            duration: const Duration(milliseconds: 400),
            child: _branchNavigatorWrapper(index, navigator),
          ),
        );
      },
    ).toList());
  }

  Widget _branchNavigatorWrapper(int index, Widget navigator) => IgnorePointer(
        ignoring: index != currentIndex,
        child: TickerMode(
          enabled: index == currentIndex,
          child: navigator,
        ),
      );
}

/// Widget for the root page for the first section of the bottom navigation bar.
class RootScreenA extends StatelessWidget {
  /// Creates a RootScreenA
  const RootScreenA({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Section A root'),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text('Screen A', style: Theme.of(context).textTheme.titleLarge),
            const Padding(padding: EdgeInsets.all(4)),
            TextButton(
              onPressed: () {
                GoRouter.of(context).go('/a/details');
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
    this.param,
    this.withScaffold = true,
    super.key,
  });

  /// The label to display in the center of the screen.
  final String label;

  /// Optional param
  final String? param;

  /// Wrap in scaffold
  final bool withScaffold;

  @override
  State<StatefulWidget> createState() => DetailsScreenState();
}

/// The state for DetailsScreen
class DetailsScreenState extends State<DetailsScreen> {
  int _counter = 0;

  @override
  Widget build(BuildContext context) {
    if (widget.withScaffold) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Details Screen - ${widget.label}'),
        ),
        body: _build(context),
      );
    } else {
      return ColoredBox(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: _build(context),
      );
    }
  }

  Widget _build(BuildContext context) {
    return Center(
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
          const Padding(padding: EdgeInsets.all(8)),
          if (widget.param != null)
            Text('Parameter: ${widget.param!}',
                style: Theme.of(context).textTheme.titleMedium),
          const Padding(padding: EdgeInsets.all(8)),
          if (!widget.withScaffold) ...<Widget>[
            const Padding(padding: EdgeInsets.all(16)),
            TextButton(
              onPressed: () {
                GoRouter.of(context).pop();
              },
              child: const Text('< Back',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            ),
          ]
        ],
      ),
    );
  }
}

/// Builds a nested shell using a [TabBar] and [TabBarView].
class TabbedRootScreen extends StatefulWidget {
  /// Constructs a TabbedRootScreen
  const TabbedRootScreen(
      {required this.navigationShell, required this.children, super.key});

  /// The current state of the parent StatefulShellRoute.
  final StatefulNavigationShell navigationShell;

  /// The children (branch Navigators) to display in the [TabBarView].
  final List<Widget> children;

  @override
  State<StatefulWidget> createState() => TabbedRootScreenState();
}

@visibleForTesting
// ignore: public_member_api_docs
class TabbedRootScreenState extends State<TabbedRootScreen>
    with SingleTickerProviderStateMixin {
  @visibleForTesting
  // ignore: public_member_api_docs
  late final TabController tabController = TabController(
      length: widget.children.length,
      vsync: this,
      initialIndex: widget.navigationShell.currentIndex);

  void _switchedTab() {
    if (tabController.index != widget.navigationShell.currentIndex) {
      widget.navigationShell.goBranch(tabController.index);
    }
  }

  @override
  void initState() {
    super.initState();
    tabController.addListener(_switchedTab);
  }

  @override
  void dispose() {
    tabController.removeListener(_switchedTab);
    tabController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant TabbedRootScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    tabController.index = widget.navigationShell.currentIndex;
  }

  @override
  Widget build(BuildContext context) {
    final List<Tab> tabs = widget.children
        .mapIndexed((int i, _) => Tab(text: 'Tab ${i + 1}'))
        .toList();

    return Scaffold(
      appBar: AppBar(
          title: Text(
              'Section B root (tab: ${widget.navigationShell.currentIndex + 1})'),
          bottom: TabBar(
            controller: tabController,
            tabs: tabs,
            onTap: (int tappedIndex) => _onTabTap(context, tappedIndex),
          )),
      body: TabBarView(
        controller: tabController,
        children: widget.children,
      ),
    );
  }

  void _onTabTap(BuildContext context, int index) {
    widget.navigationShell.goBranch(index);
  }
}

/// Alternative implementation of TabbedRootScreen, demonstrating the use of
/// a [PageView].
// ignore: unreachable_from_main
class PagedRootScreen extends StatefulWidget {
  /// Constructs a PagedRootScreen
  // ignore: unreachable_from_main
  const PagedRootScreen(
      {required this.navigationShell, required this.children, super.key});

  /// The current state of the parent StatefulShellRoute.
  // ignore: unreachable_from_main
  final StatefulNavigationShell navigationShell;

  /// The children (branch Navigators) to display in the [TabBarView].
  // ignore: unreachable_from_main
  final List<Widget> children;

  @override
  State<StatefulWidget> createState() => _PagedRootScreenState();
}

/// Alternative implementation _TabbedRootScreenState, demonstrating the use of
/// a PageView.
class _PagedRootScreenState extends State<PagedRootScreen> {
  late final PageController _pageController = PageController(
    initialPage: widget.navigationShell.currentIndex,
  );

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            'Section B root (tab ${widget.navigationShell.currentIndex + 1})'),
      ),
      body: Column(
        children: <Widget>[
          Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                ElevatedButton(
                  onPressed: () => _animateToPage(0),
                  child: const Text('Tab 1'),
                ),
                ElevatedButton(
                  onPressed: () => _animateToPage(1),
                  child: const Text('Tab 2'),
                ),
              ]),
          Expanded(
            child: PageView(
              onPageChanged: (int i) => widget.navigationShell.goBranch(i),
              controller: _pageController,
              children: widget.children,
            ),
          ),
        ],
      ),
    );
  }

  void _animateToPage(int index) {
    if (_pageController.hasClients) {
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 500),
        curve: Curves.bounceOut,
      );
    }
  }
}

/// Widget for the pages in the top tab bar.
class TabScreen extends StatelessWidget {
  /// Creates a RootScreen
  const TabScreen({required this.label, required this.detailsPath, super.key});

  /// The label
  final String label;

  /// The path to the detail page
  final String detailsPath;

  @override
  Widget build(BuildContext context) {
    /// If preloading is enabled on the top StatefulShellRoute, this will be
    /// printed directly after the app has been started, but only for the route
    /// that is the initial location ('/b1')
    debugPrint('Building TabScreen - $label');

    return Center(
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
    );
  }
}
