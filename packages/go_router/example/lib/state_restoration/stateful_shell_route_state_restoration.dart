// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

void main() => runApp(const App());

/// An example showing how to configure state restoration
/// for a [StatefulShellRoute].
class App extends StatefulWidget {
  /// Creates an [App].
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  final GoRouter _router = GoRouter(
    restorationScopeId: 'router',
    routes: <RouteBase>[
      StatefulShellRoute.indexedStack(
        restorationScopeId: 'appShell',
        pageBuilder:
            (
              BuildContext context,
              GoRouterState state,
              StatefulNavigationShell navigationShell,
            ) {
              return MaterialPage<void>(
                restorationId: 'appShellPage',
                child: AppShell(navigationShell: navigationShell),
              );
            },
        branches: <StatefulShellBranch>[
          StatefulShellBranch(
            restorationScopeId: 'homeBranch',
            routes: <GoRoute>[
              GoRoute(
                path: '/',
                builder: (BuildContext context, GoRouterState state) {
                  return const HomeBody();
                },
              ),
            ],
          ),
          StatefulShellBranch(
            restorationScopeId: 'profileBranch',
            routes: <GoRoute>[
              GoRoute(
                path: '/profile',
                builder: (BuildContext context, GoRouterState state) {
                  return const ProfileBody();
                },
              ),
            ],
          ),
        ],
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(restorationScopeId: 'app', routerConfig: _router);
  }
}

/// The shell of the app.
class AppShell extends StatelessWidget {
  /// Creates an [AppShell].
  const AppShell({required this.navigationShell, super.key});

  /// The [StatefulNavigationShell] displayed in the body
  /// of the [Scaffold].
  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('App')),
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (int index) {
          navigationShell.goBranch(index);
        },
        destinations: const <NavigationDestination>[
          NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(
            icon: Icon(Icons.account_circle),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

/// The home body of the app.
class HomeBody extends StatelessWidget {
  /// Creates a [HomeBody].
  const HomeBody({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: <Widget>[
        TextField(
          restorationId: 'homeTextField',
          decoration: InputDecoration(labelText: 'Home'),
        ),
      ],
    );
  }
}

/// The profile body of the app.
class ProfileBody extends StatelessWidget {
  /// Creates a [ProfileBody].
  const ProfileBody({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: <Widget>[
        TextField(
          restorationId: 'profileTextField',
          decoration: InputDecoration(labelText: 'Profile'),
        ),
      ],
    );
  }
}
