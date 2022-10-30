// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

final GlobalKey<NavigatorState> _tabANavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'tabANav');

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

  final GoRouter _router = GoRouter(
    initialLocation: '/a',
    routes: <RouteBase>[
      StatefulShellRoute(
        /// To enable preloading of the root routes of the branches, pass true
        /// for the parameter preloadBranches.
        // preloadBranches: true,
        branches: <ShellRouteBranch>[
          /// The route branch for the first tab of the bottom navigation bar.
          ShellRouteBranch(
            navigatorKey: _tabANavigatorKey,
            rootRoute: GoRoute(
              /// The screen to display as the root in the first tab of the bottom
              /// navigation bar.
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
                      DetailsScreen(label: 'A', extra: state.extra),
                ),
              ],
            ),
          ),

          /// The route branch for the second tab of the bottom navigation bar.
          ShellRouteBranch(
            /// It's not necessary to provide a navigatorKey if it isn't also
            /// needed elsewhere. If not provided, a default key will be used.
            // navigatorKey: _tabBNavigatorKey,
            rootRoute: GoRoute(
              /// The screen to display as the root in the second tab of the bottom
              /// navigation bar.
              path: '/b',
              builder: (BuildContext context, GoRouterState state) =>
                  const RootScreen(
                      label: 'B',
                      detailsPath: '/b/details/1',
                      secondDetailsPath: '/b/details/2'),
              routes: <RouteBase>[
                GoRoute(
                  path: 'details/:param',
                  builder: (BuildContext context, GoRouterState state) =>
                      DetailsScreen(
                          label: 'B',
                          param: state.params['param'],
                          extra: state.extra),
                ),
              ],
            ),
          ),

          /// The route branch for the third tab of the bottom navigation bar.
          ShellRouteBranch(
            /// Since this route branch has a nested StatefulShellRoute as the
            /// root route, we need to specify what the default location for the
            /// branch is.
            defaultLocation: '/c1',
            rootRoute: StatefulShellRoute.rootRoutes(
              /// This bottom tab uses a nested shell, wrapping sub routes in a
              /// top TabBar. In this case, we're using the `rootRoutes`
              /// convenience constructor.
              routes: <GoRoute>[
                GoRoute(
                  path: '/c1',
                  builder: (BuildContext context, GoRouterState state) =>
                      const TabScreen(label: 'C1', detailsPath: '/c1/details'),
                  routes: <RouteBase>[
                    GoRoute(
                      path: 'details',
                      builder: (BuildContext context, GoRouterState state) =>
                          DetailsScreen(
                              label: 'C1',
                              extra: state.extra,
                              withScaffold: false),
                    ),
                  ],
                ),
                GoRoute(
                  path: '/c2',
                  builder: (BuildContext context, GoRouterState state) =>
                      const TabScreen(label: 'C2', detailsPath: '/c2/details'),
                  routes: <RouteBase>[
                    GoRoute(
                      path: 'details',
                      builder: (BuildContext context, GoRouterState state) =>
                          DetailsScreen(
                              label: 'C2',
                              extra: state.extra,
                              withScaffold: false),
                    ),
                  ],
                ),
              ],
              builder:
                  (BuildContext context, GoRouterState state, Widget child) {
                /// For this nested StatefulShellRoute we are using a custom
                /// container (TabBarView) for the branch navigators, and thus
                /// ignoring the default navigator contained passed to the
                /// builder. Custom implementation can access the branch
                /// navigators via the StatefulShellRouteState
                /// (see TabbedRootScreen for details).
                return const TabbedRootScreen();
              },
            ),
          ),
        ],
        builder: (BuildContext context, GoRouterState state, Widget child) {
          return ScaffoldWithNavBar(body: child);
        },

        /// If you need to create a custom container for the branch routes, to
        /// for instance setup animations, you can implement your builder
        /// something like this (see _AnimatedRouteBranchContainer):
        // builder: (BuildContext context, GoRouterState state, Widget child) {
        //   return ScaffoldWithNavBar(
        //     body: _AnimatedRouteBranchContainer(),
        //   );
        // },

        /// If you need to customize the Page for StatefulShellRoute, pass a
        /// pageBuilder function in addition to the builder, for example:
        // pageBuilder:
        //     (BuildContext context, GoRouterState state, Widget statefulShell) {
        //   return NoTransitionPage<dynamic>(child: statefulShell);
        // },
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
    required this.body,
    Key? key,
  }) : super(key: key ?? const ValueKey<String>('ScaffoldWithNavBar'));

  /// Body, i.e. the index stack
  final Widget body;

  @override
  Widget build(BuildContext context) {
    final StatefulShellRouteState shellState = StatefulShellRoute.of(context);
    return Scaffold(
      body: body,
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Section A'),
          BottomNavigationBarItem(icon: Icon(Icons.work), label: 'Section B'),
          BottomNavigationBarItem(icon: Icon(Icons.tab), label: 'Section C'),
        ],
        currentIndex: shellState.index,
        onTap: (int tappedIndex) => shellState.goBranch(tappedIndex),
      ),
    );
  }
}

/// Widget for the root/initial pages in the bottom navigation bar.
class RootScreen extends StatelessWidget {
  /// Creates a RootScreen
  const RootScreen(
      {required this.label,
      required this.detailsPath,
      this.secondDetailsPath,
      Key? key})
      : super(key: key);

  /// The label
  final String label;

  /// The path to the detail page
  final String detailsPath;

  /// The path to another detail page
  final String? secondDetailsPath;

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
                GoRouter.of(context).go(detailsPath, extra: '$label-XYZ');
              },
              child: const Text('View details'),
            ),
            const Padding(padding: EdgeInsets.all(4)),
            if (secondDetailsPath != null)
              TextButton(
                onPressed: () {
                  GoRouter.of(context).go(secondDetailsPath!);
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
    this.extra,
    this.withScaffold = true,
    Key? key,
  }) : super(key: key);

  /// The label to display in the center of the screen.
  final String label;

  /// Optional param
  final String? param;

  /// Optional extra object
  final Object? extra;

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
      return Container(
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
          if (widget.extra != null)
            Text('Extra: ${widget.extra!}',
                style: Theme.of(context).textTheme.titleMedium),
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
class TabbedRootScreen extends StatelessWidget {
  /// Constructs a TabbedRootScreen
  const TabbedRootScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final StatefulShellRouteState shellState = StatefulShellRoute.of(context);
    final List<TabbedRootScreenTab> children = shellState.branchState
        .mapIndexed((int index, ShellRouteBranchState e) =>
            TabbedRootScreenTab(index: index))
        .toList();

    return DefaultTabController(
      length: children.length,
      initialIndex: shellState.index,
      child: Scaffold(
        appBar: AppBar(
            title: const Text('Tab root'),
            bottom: TabBar(
              tabs: children.map((TabbedRootScreenTab e) => e.tab).toList(),
              onTap: (int tappedIndex) =>
                  _onTabTap(context, shellState, tappedIndex),
            )),
        body: TabBarView(
          children: children,
        ),
      ),
    );
  }

  void _onTabTap(
      BuildContext context, StatefulShellRouteState shellState, int index) {
    shellState.goBranch(index);
  }
}

/// Widget wrapping the [Navigator] for a specific tab in [TabbedRootScreen].
///
/// This class is needed since [TabBarView] won't update its cached list of
/// children while in a transition between tabs. This is why we only pass the
/// index of the branch as a parameter, and fetch the state fresh in the build
/// method.
class TabbedRootScreenTab extends StatelessWidget {
  /// Constructs a TabbedRootScreenTab
  const TabbedRootScreenTab({Key? key, required this.index}) : super(key: key);

  /// The index of the tab
  final int index;

  /// Gets the associated [Tab] object
  Tab get tab => Tab(text: 'Tab ${index + 1}');

  @override
  Widget build(BuildContext context) {
    // Note that we must fetch the state fresh here, since the
    // TabbedRootScreenTab is "cached" by the TabBarView.
    final StatefulShellRouteState shellState = StatefulShellRoute.of(context);
    final Widget? navigator = shellState.branchState[index].navigator;
    return navigator ?? const SizedBox.expand();
  }
}

/// Widget for the pages in the top tab bar.
class TabScreen extends StatelessWidget {
  /// Creates a RootScreen
  const TabScreen({required this.label, this.detailsPath, Key? key})
      : super(key: key);

  /// The label
  final String label;

  /// The path to the detail page
  final String? detailsPath;

  @override
  Widget build(BuildContext context) {
    /// If preloading is enabled on the top StatefulShellRoute, this will be
    /// printed directly after the app has been started, but only for the route
    /// that is the default location ('/c1')
    debugPrint('Building TabScreen - $label');

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text('Screen $label', style: Theme.of(context).textTheme.titleLarge),
          const Padding(padding: EdgeInsets.all(4)),
          if (detailsPath != null)
            TextButton(
              onPressed: () {
                GoRouter.of(context).go(detailsPath!);
              },
              child: const Text('View details'),
            ),
        ],
      ),
    );
  }
}

// ignore: unused_element
class _AnimatedRouteBranchContainer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final StatefulShellRouteState shellRouteState =
        StatefulShellRoute.of(context);
    return Stack(
        children: shellRouteState.navigators.mapIndexed(
      (int index, Widget? navigator) {
        return AnimatedScale(
          scale: index == shellRouteState.index ? 1 : 1.5,
          duration: const Duration(milliseconds: 400),
          child: AnimatedOpacity(
            opacity: index == shellRouteState.index ? 1 : 0,
            duration: const Duration(milliseconds: 400),
            child: Offstage(
              offstage: index != shellRouteState.index,
              child: navigator ?? const SizedBox.shrink(),
            ),
          ),
        );
      },
    ).toList());
  }
}
