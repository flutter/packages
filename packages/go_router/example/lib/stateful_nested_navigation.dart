// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

final List<StatefulShellBranch> _bottomNavBranches = <StatefulShellBranch>[
  StatefulShellBranch(rootLocation: '/a', name: 'A'),
  StatefulShellBranch(rootLocation: '/b', name: 'B'),
  StatefulShellBranch(rootLocations: <String>['/c1', '/c2'], name: 'C'),

  /// To enable preloading of the root routes of the branches, pass true
  /// for the parameter preload of StatefulShellBranch.
  //StatefulShellBranch(rootLocations: <String>['/c1', '/c2'], name: 'C', preload: true),
];

final List<StatefulShellBranch> _topNavBranches = <StatefulShellBranch>[
  StatefulShellBranch(rootLocation: '/c1', name: 'C1'),
  StatefulShellBranch(rootLocation: '/c2', name: 'C2'),
];

// This example demonstrates how to setup nested navigation using a
// BottomNavigationBar, where each tab uses its own persistent navigator, i.e.
// navigation state is maintained separately for each tab. This setup also
// enables deep linking into nested pages.
//
// This example demonstrates how to display routes within a StatefulShellRoute,
// that are places on separate navigators. The example also demonstrates how
// state is maintained when switching between different tabs (and thus branches
// and Navigators).

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
        routes: <RouteBase>[
          GoRoute(
            /// The screen to display as the root in the first tab of the
            /// bottom navigation bar.
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
          GoRoute(
            /// The screen to display as the root in the second tab of the
            /// bottom navigation bar.
            path: '/b',
            builder: (BuildContext context, GoRouterState state) =>
                const RootScreen(
              label: 'B',
              detailsPath: '/b/details/1',
              secondDetailsPath: '/b/details/2',
            ),
            routes: <RouteBase>[
              GoRoute(
                path: 'details/:param',
                builder: (BuildContext context, GoRouterState state) =>
                    DetailsScreen(
                  label: 'B',
                  param: state.params['param'],
                  extra: state.extra,
                ),
              ),
            ],
          ),
          StatefulShellRoute(
              routes: <RouteBase>[
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
                        withScaffold: false,
                      ),
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
                        withScaffold: false,
                      ),
                    ),
                  ],
                ),
              ],
              branches: _topNavBranches,
              builder:
                  (BuildContext context, GoRouterState state, Widget child) {
                /// For this nested StatefulShellRoute we are using a custom
                /// container (TabBarView) for the branch navigators, and thus
                /// ignoring the default navigator contained passed to the
                /// builder. Custom implementation can access the branch
                /// navigators via the StatefulShellRouteState
                /// (see TabbedRootScreen for details).
                return const TabbedRootScreen();
              }),
        ],
        branches: _bottomNavBranches,
        builder: (BuildContext context, GoRouterState state, Widget child) {
          return ScaffoldWithNavBar(body: child);
        },

        /// If you need to create a custom container for the branch routes, to
        /// for instance setup custom animations, you can implement your builder
        /// something like below (see _AnimatedRouteBranchContainer). Note that
        /// in this case, you should not add the Widget provided in the child
        /// parameter of the builder to the widget tree. Instead, you should use
        /// the child widgets of each branch
        /// (see StatefulShellRouteState.children).
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
        currentIndex: shellState.currentIndex,
        onTap: (int tappedIndex) => shellState.goBranch(
            navigatorKey: _bottomNavBranches[tappedIndex].navigatorKey),
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

  Widget _child(StatefulShellBranchState branchState) {
    // TabBarView will cache it's root widget, so we need to reevaluate
    // the child (using a Builder) in case it's null.
    return branchState.child != null
        ? branchState.child!
        : Builder(
            builder: (BuildContext context) =>
                StatefulShellBranch.of(context).child ??
                const SizedBox.expand());
  }

  @override
  Widget build(BuildContext context) {
    final StatefulShellRouteState shellState = StatefulShellRoute.of(context);
    final List<Widget> children = shellState.branchStates.map(_child).toList();
    final List<Tab> tabs =
        children.mapIndexed((int i, _) => Tab(text: 'Tab ${i + 1}')).toList();

    return DefaultTabController(
      length: children.length,
      initialIndex: shellState.currentIndex,
      child: Scaffold(
        appBar: AppBar(
            title: const Text('Tab root'),
            bottom: TabBar(
              tabs: tabs,
              onTap: (int tappedIndex) => _onTabTap(context, tappedIndex),
            )),
        body: TabBarView(
          children: children,
        ),
      ),
    );
  }

  void _onTabTap(BuildContext context, int index) {
    StatefulShellRoute.of(context)
        .goBranch(navigatorKey: _topNavBranches[index].navigatorKey);
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
    final int currentIndex = shellRouteState.currentIndex;
    return Stack(
        children: shellRouteState.children.mapIndexed(
      (int index, Widget? navigator) {
        return AnimatedScale(
          scale: index == currentIndex ? 1 : 1.5,
          duration: const Duration(milliseconds: 400),
          child: AnimatedOpacity(
            opacity: index == currentIndex ? 1 : 0,
            duration: const Duration(milliseconds: 400),
            child: Offstage(
              offstage: index != currentIndex,
              child: navigator ?? const SizedBox.shrink(),
            ),
          ),
        );
      },
    ).toList());
  }
}
