// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:go_router/src/route.dart';
import 'package:go_router_examples/books/main.dart';

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
    routes: <RouteBase>[
      ShellRoute(
        path: '/',
        builder: (context, state, child) {
          return AppScaffold(
            child: child,
          );
        },
        routes: [
          GoRoute(
            path: 'a',
            pageBuilder: (context, state) {
              return FadeTransitionPage(
                key: state.pageKey,
                child: Screen(
                    title: 'Screen A',
                    detailsPath: '/a/details',
                    backgroundColor: Colors.red.shade100),
              );
            },
            routes: [
              GoRoute(
                path: 'details',
                builder: (context, state) {
                  return DetailsScreen(label: 'A');
                },
              )
            ],
          ),
          GoRoute(
            path: 'b',
            pageBuilder: (context, state) {
              return FadeTransitionPage(
                key: state.pageKey,
                child: Screen(
                  title: 'Screen B',
                  detailsPath: '/b/details',
                  backgroundColor: Colors.green.shade100,
                ),
              );
            },
            routes: [
              GoRoute(
                path: 'details',
                builder: (context, state) {
                  return DetailsScreen(label: 'B');
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
  final Widget child;

  const AppScaffold({
    required this.child,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final selectedIndex = _calculateSelectedIndex(context);
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
        onTap: (idx) => _onItemTapped(idx, context),
      ),
    );
  }

  static int _calculateSelectedIndex(BuildContext context) {
    final route = GoRouter.of(context);
    final location = route.location;
    if (location != null) {
      if (location.startsWith('/a')) return 0;
      if (location.startsWith('/b')) return 1;
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
  final String title;
  final String detailsPath;
  final Color backgroundColor;

  /// Creates a screen with a given title
  const Screen({
    required this.title,
    required this.detailsPath,
    required this.backgroundColor,
    Key? key,
  }) : super(key: key);

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
          children: [
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

class DetailsScreen extends StatelessWidget {
  final String label;

  const DetailsScreen({
    required this.label,
    Key? key,
  }) : super(key: key);

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
