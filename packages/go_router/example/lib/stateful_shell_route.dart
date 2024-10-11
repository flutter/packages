// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');
final GlobalKey<NavigatorState> _sectionANavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'sectionANav');

// This example demonstrates how to setup nested navigation using a
// BottomNavigationBar, where each bar item uses its own persistent navigator,
// i.e. navigation state is maintained separately for each item. This setup also
// enables deep linking into nested pages.

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
      // #docregion configuration-builder
      StatefulShellRoute.indexedStack(
        shellRedirectPath: '/shell',
        builder: (BuildContext context, ShellRouteState state, Widget child) {
          // Return the widget that implements the custom shell (in this case
          // using a BottomNavigationBar). The StatefulNavigationShell is passed
          // to be able access the state of the shell and to navigate to other
          // branches in a stateful way.
          return ScaffoldWithNavBar(shellState: state, child: child);
        },
        // #enddocregion configuration-builder
        // #docregion configuration-branches
        branches: <StatefulShellBranch>[
          // The route branch for the first tab of the bottom navigation bar.
          StatefulShellBranch(
            name: 'branchA',
            navigatorKey: _sectionANavigatorKey,
            routes: <RouteBase>[
              GoRoute(
                // The screen to display as the root in the first tab of the
                // bottom navigation bar.
                path: '/a',
                builder: (BuildContext context, GoRouterState state) =>
                    const RootScreen(label: 'A', detailsPath: '/a/details'),
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
          // #enddocregion configuration-branches

          // The route branch for the second tab of the bottom navigation bar.
          StatefulShellBranch(
            name: 'branchB',
            // It's not necessary to provide a navigatorKey if it isn't also
            // needed elsewhere. If not provided, a default key will be used.
            routes: <RouteBase>[
              GoRoute(
                // The screen to display as the root in the second tab of the
                // bottom navigation bar.
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
                      param: state.pathParameters['param'],
                    ),
                  ),
                ],
              ),
            ],
          ),

          // The route branch for the third tab of the bottom navigation bar.
          StatefulShellBranch(
            name: 'branchC',
            routes: <RouteBase>[
              GoRoute(
                // The screen to display as the root in the third tab of the
                // bottom navigation bar.
                path: '/c',
                builder: (BuildContext context, GoRouterState state) =>
                    const RootScreen(
                  label: 'C',
                  detailsPath: '/c/details',
                ),
                routes: <RouteBase>[
                  GoRoute(
                    path: 'details',
                    builder: (BuildContext context, GoRouterState state) =>
                        DetailsScreen(
                      label: 'C',
                      extra: state.extra,
                    ),
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
      routerConfig: _router,
    );
  }
}

/// Builds the "shell" for the app by building a Scaffold with a
/// BottomNavigationBar, where [child] is placed in the body of the Scaffold.
class ScaffoldWithNavBar extends StatelessWidget {
  /// Constructs an [ScaffoldWithNavBar].
  const ScaffoldWithNavBar({
    required this.shellState,
    required this.child,
    Key? key,
  }) : super(key: key ?? const ValueKey<String>('ScaffoldWithNavBar'));

  /// The state of the shell route.
  final ShellRouteState shellState;

  /// The navigation shell and container for the branch Navigators.
  final Widget child;

  StatefulShellRoute get _shellRoute =>
      shellState.shellRoute as StatefulShellRoute;

  // #docregion configuration-custom-shell
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // The StatefulNavigationShell from the associated StatefulShellRoute is
      // directly passed as the body of the Scaffold.
      body: child,
      bottomNavigationBar: BottomNavigationBar(
          // Here, the items of BottomNavigationBar are hard coded. In a real
          // world scenario, the items would most likely be generated from the
          // branches of the shell route, which can be fetched using
          // `navigationShell.route.branches`.
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Section A'),
            BottomNavigationBarItem(icon: Icon(Icons.work), label: 'Section B'),
            BottomNavigationBarItem(icon: Icon(Icons.tab), label: 'Section C'),
          ],
          currentIndex: shellState.navigatorIndex,
          // Navigate to the current location of the branch at the provided index
          // when tapping an item in the BottomNavigationBar.
          onTap: (int index) {
            // It's possible to simply do this to navigate between branches:
            // return GoRouter.of(context).go('/shell/$index');
            // But since names are configured for the branches, it is also
            // possible to restore a branch by name, like this:
            return switch (index) {
              1 => GoRouter.of(context).goNamed('branchB'),
              2 => GoRouter.of(context).goNamed('branchC'),
              _ => GoRouter.of(context).goNamed('branchA'),
            };
          }),
    );
  }
  // #enddocregion configuration-custom-shell

  /// NOTE: For a slightly more sophisticated branch switching, change the onTap
  /// handler on the BottomNavigationBar above to the following:
  /// `onTap: _onTap,`
  // ignore: unused_element
  void _onTap(BuildContext context, int index) {
    // A common pattern when using bottom navigation bars is to support
    // navigating to the initial location when tapping the item that is
    // already active.
    if (index == shellState.navigatorIndex) {
      final String initialLocation =
          _shellRoute.initialBranchLocation(shellState, index);
      GoRouter.of(context).go(initialLocation);
    } else {
      return switch (index) {
        1 => GoRouter.of(context).goNamed('branchB'),
        2 => GoRouter.of(context).goNamed('branchC'),
        _ => GoRouter.of(context).goNamed('branchA'),
      };
      // It is also possible to navigate to the branch by index like this:
      //GoRouter.of(context).go('/shell/$index');
    }
  }
}

/// Widget for the root/initial pages in the bottom navigation bar.
class RootScreen extends StatelessWidget {
  /// Creates a RootScreen
  const RootScreen({
    required this.label,
    required this.detailsPath,
    this.secondDetailsPath,
    super.key,
  });

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
        title: Text(
            'Root of section $label - navigatorIndex: ${ShellRouteState.of(context).navigatorIndex}'),
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
    super.key,
  });

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
