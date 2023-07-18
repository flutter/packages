// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

void main() => runApp(RestorableStatefulShellRouteExampleApp());

/// An example demonstrating how to use StatefulShellRoute with state
/// restoration.
class RestorableStatefulShellRouteExampleApp extends StatelessWidget {
  /// Creates a NestedTabNavigationExampleApp
  RestorableStatefulShellRouteExampleApp({super.key});

  final GoRouter _router = GoRouter(
    initialLocation: '/a',
    restorationScopeId: 'router',
    routes: <RouteBase>[
      StatefulShellRoute.indexedStack(
        restorationScopeId: 'shell1',
        pageBuilder: (BuildContext context, GoRouterState state,
            StatefulNavigationShell navigationShell) {
          return MaterialPage<void>(
              restorationId: 'shellWidget1',
              child: ScaffoldWithNavBar(navigationShell: navigationShell));
        },
        branches: <StatefulShellBranch>[
          // The route branch for the first tab of the bottom navigation bar.
          StatefulShellBranch(
            restorationScopeId: 'branchA',
            routes: <RouteBase>[
              GoRoute(
                // The screen to display as the root in the first tab of the
                // bottom navigation bar.
                path: '/a',
                pageBuilder: (BuildContext context, GoRouterState state) =>
                    const MaterialPage<void>(
                        restorationId: 'screenA',
                        child:
                            RootScreen(label: 'A', detailsPath: '/a/details')),
                routes: <RouteBase>[
                  // The details screen to display stacked on navigator of the
                  // first tab. This will cover screen A but not the application
                  // shell (bottom navigation bar).
                  GoRoute(
                    path: 'details',
                    pageBuilder: (BuildContext context, GoRouterState state) =>
                        const MaterialPage<void>(
                            restorationId: 'screenADetail',
                            child: DetailsScreen(label: 'A')),
                  ),
                ],
              ),
            ],
          ),
          // The route branch for the second tab of the bottom navigation bar.
          StatefulShellBranch(
            restorationScopeId: 'branchB',
            routes: <RouteBase>[
              GoRoute(
                // The screen to display as the root in the second tab of the
                // bottom navigation bar.
                path: '/b',
                pageBuilder: (BuildContext context, GoRouterState state) =>
                    const MaterialPage<void>(
                        restorationId: 'screenB',
                        child:
                            RootScreen(label: 'B', detailsPath: '/b/details')),
                routes: <RouteBase>[
                  // The details screen to display stacked on navigator of the
                  // first tab. This will cover screen A but not the application
                  // shell (bottom navigation bar).
                  GoRoute(
                    path: 'details',
                    pageBuilder: (BuildContext context, GoRouterState state) =>
                        const MaterialPage<void>(
                            restorationId: 'screenBDetail',
                            child: DetailsScreen(label: 'B')),
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
      restorationScopeId: 'app',
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
    Key? key,
  }) : super(key: key ?? const ValueKey<String>('ScaffoldWithNavBar'));

  /// The navigation shell and container for the branch Navigators.
  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Section A'),
          BottomNavigationBarItem(icon: Icon(Icons.work), label: 'Section B'),
        ],
        currentIndex: navigationShell.currentIndex,
        onTap: (int tappedIndex) => navigationShell.goBranch(tappedIndex),
      ),
    );
  }
}

/// Widget for the root/initial pages in the bottom navigation bar.
class RootScreen extends StatelessWidget {
  /// Creates a RootScreen
  const RootScreen({
    required this.label,
    required this.detailsPath,
    super.key,
  });

  /// The label
  final String label;

  /// The path to the detail page
  final String detailsPath;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Root of section $label'),
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
    super.key,
  });

  /// The label to display in the center of the screen.
  final String label;

  @override
  State<StatefulWidget> createState() => DetailsScreenState();
}

/// The state for DetailsScreen
class DetailsScreenState extends State<DetailsScreen> with RestorationMixin {
  final RestorableInt _counter = RestorableInt(0);

  @override
  String? get restorationId => 'DetailsScreen-${widget.label}';

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(_counter, 'counter');
  }

  @override
  void dispose() {
    super.dispose();
    _counter.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Details Screen - ${widget.label}'),
      ),
      body: _build(context),
    );
  }

  Widget _build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text('Details for ${widget.label} - Counter: ${_counter.value}',
              style: Theme.of(context).textTheme.titleLarge),
          const Padding(padding: EdgeInsets.all(4)),
          TextButton(
            onPressed: () {
              setState(() {
                _counter.value++;
              });
            },
            child: const Text('Increment counter'),
          ),
          const Padding(padding: EdgeInsets.all(8)),
        ],
      ),
    );
  }
}
