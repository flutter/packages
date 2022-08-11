// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:go_router_examples/books/main.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

// This example demonstrates how to configure a nested navigation stack using
// [ShellRoute].
void main() => runApp(App());

/// The main app.
class App extends StatelessWidget {
  /// Creates an [App].
  App({Key? key}) : super(key: key);

  /// The title of the app.
  static const String title = 'GoRouter Example: Declarative Routes';

  @override
  Widget build(BuildContext context) => MaterialApp.router(
        routeInformationProvider: _router.routeInformationProvider,
        routeInformationParser: _router.routeInformationParser,
        routerDelegate: _router.routerDelegate,
        title: title,
      );

  final GoRouter _router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    routes: <RouteBase>[
      ShellRoute(
        path: '/',
        defaultRoute: 'a',
        builder: (BuildContext context, GoRouterState state, Widget child) {
          return AppScaffold(
            child: child,
          );
        },
        routes: <RouteBase>[
          GoRoute(
            path: 'a',
            pageBuilder: (BuildContext context, GoRouterState state) {
              return FadeTransitionPage(
                key: state.pageKey,
                child: Screen(
                    title: 'Screen A',
                    detailsPath: '/a/details',
                    backgroundColor: Colors.red.shade100),
              );
            },
            routes: <RouteBase>[
              GoRoute(
                path: 'details',
                builder: (BuildContext context, GoRouterState state) {
                  return const DetailsScreen(label: 'A');
                },
              )
            ],
          ),
          GoRoute(
            path: 'b',
            pageBuilder: (BuildContext context, GoRouterState state) {
              return FadeTransitionPage(
                key: state.pageKey,
                child: Screen(
                  title: 'Screen B',
                  detailsPath: '/b/details',
                  backgroundColor: Colors.green.shade100,
                ),
              );
            },
            routes: <RouteBase>[
              GoRoute(
                path: 'details',
                // Stack this route on the root navigator, instead of the
                // nearest ShellRoute ancestor.
                navigatorKey: _rootNavigatorKey,
                builder: (BuildContext context, GoRouterState state) {
                  return const DetailsScreen(label: 'B');
                },
              )
            ],
          ),
        ],
      ),
    ],
  );
}

/// The "shell" of this app.
class AppScaffold extends StatelessWidget {
  /// AppScaffold constructor. [child] will
  const AppScaffold({
    required this.child,
    Key? key,
  }) : super(key: key);

  /// The child widget to display in the body of the scaffold. In this sample,
  /// it is the inner Navigator configured by GoRouter.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final int selectedIndex = _calculateSelectedIndex(context);
    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'A Screen',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.business),
            label: 'B Screen',
          ),
        ],
        currentIndex: selectedIndex,
        onTap: (int idx) => _onItemTapped(idx, context),
      ),
    );
  }

  static int _calculateSelectedIndex(BuildContext context) {
    final GoRouter route = GoRouter.of(context);
    final String location = route.location;
    if (location != null) {
      if (location.startsWith('/a')) {
        return 0;
      }
      if (location.startsWith('/b')) {
        return 1;
      }
    }
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        GoRouter.of(context).go('/a');
        break;
      case 1:
        GoRouter.of(context).go('/b');
        break;
    }
  }
}

/// The screen of the second page.
class Screen extends StatelessWidget {
  /// Creates a screen with a given title
  const Screen({
    required this.title,
    required this.detailsPath,
    required this.backgroundColor,
    Key? key,
  }) : super(key: key);

  /// The title of the screen.
  final String title;

  /// The path to navigate to when the user presses the View Details button.
  final String detailsPath;

  /// The background color.
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('This AppBar is in the inner navigator'),
      ),
      backgroundColor: backgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              title,
              style: Theme.of(context).textTheme.headline4,
            ),
            TextButton(
              onPressed: () {
                GoRouter.of(context).go(detailsPath);
              },
              child: const Text('View  details'),
            ),
          ],
        ),
      ),
    );
  }
}

/// The details screen for either the A or B screen.
class DetailsScreen extends StatelessWidget {
  /// Constructs a [DetailsScreen].
  const DetailsScreen({
    required this.label,
    Key? key,
  }) : super(key: key);

  /// The label to display in the center of the screen.
  final String label;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Details Screen'),
      ),
      body: Center(
        child: Text(
          'Details for $label',
          style: Theme.of(context).textTheme.headline4,
        ),
      ),
    );
  }
}
