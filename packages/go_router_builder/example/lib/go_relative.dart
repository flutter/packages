// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: public_member_api_docs, unreachable_from_main

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

part 'go_relative.g.dart';

void main() => runApp(const MyApp());

/// The main app.
class MyApp extends StatelessWidget {
  /// Constructs a [MyApp]
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(routerConfig: _router);
  }
}

/// The route configuration.
final GoRouter _router = GoRouter(routes: $appRoutes);
const TypedRelativeGoRoute<DetailsRoute> detailRoute =
    TypedRelativeGoRoute<DetailsRoute>(
      path: 'details/:detailId',
      routes: <TypedRoute<RouteData>>[
        TypedRelativeGoRoute<SettingsRoute>(path: 'settings/:settingId'),
      ],
    );

@TypedGoRoute<HomeRoute>(
  path: '/',
  routes: <TypedRoute<RouteData>>[
    TypedGoRoute<DashboardRoute>(
      path: '/dashboard',
      routes: <TypedRoute<RouteData>>[detailRoute],
    ),
    detailRoute,
  ],
)
class HomeRoute extends GoRouteData with $HomeRoute {
  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const HomeScreen();
  }
}

class DashboardRoute extends GoRouteData with $DashboardRoute {
  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const DashboardScreen();
  }
}

class DetailsRoute extends RelativeGoRouteData with $DetailsRoute {
  const DetailsRoute({required this.detailId});
  final String detailId;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return DetailsScreen(id: detailId);
  }
}

class SettingsRoute extends RelativeGoRouteData with $SettingsRoute {
  const SettingsRoute({required this.settingId});
  final String settingId;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return SettingsScreen(id: settingId);
  }
}

/// The home screen
class HomeScreen extends StatelessWidget {
  /// Constructs a [HomeScreen]
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home Screen')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          ElevatedButton(
            onPressed: () {
              const DetailsRoute(detailId: 'DetailsId').goRelative(context);
            },
            child: const Text('Go to the Details screen'),
          ),
          ElevatedButton(
            onPressed: () {
              DashboardRoute().go(context);
            },
            child: const Text('Go to the Dashboard screen'),
          ),
        ],
      ),
    );
  }
}

/// The home screen
class DashboardScreen extends StatelessWidget {
  /// Constructs a [DashboardScreen]
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard Screen')),
      body: Column(
        children: <Widget>[
          ElevatedButton(
            onPressed: () {
              const DetailsRoute(detailId: 'DetailsId').goRelative(context);
            },
            child: const Text('Go to the Details screen'),
          ),
          ElevatedButton(
            onPressed: () => context.pop(),
            child: const Text('Go back'),
          ),
        ],
      ),
    );
  }
}

/// The details screen
class DetailsScreen extends StatelessWidget {
  /// Constructs a [DetailsScreen]
  const DetailsScreen({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Details Screen $id')),
      body: Center(
        child: Column(
          children: <Widget>[
            ElevatedButton(
              onPressed: () => context.pop(),
              child: const Text('Go back'),
            ),
            ElevatedButton(
              onPressed: () => const SettingsRoute(
                settingId: 'SettingsId',
              ).goRelative(context),
              child: const Text('Go to the Settings screen'),
            ),
          ],
        ),
      ),
    );
  }
}

/// The details screen
class SettingsScreen extends StatelessWidget {
  /// Constructs a [SettingsScreen]
  const SettingsScreen({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Settings Screen $id')),
      body: Center(
        child: TextButton(
          onPressed: () => context.pop(),
          child: const Text('Go back'),
        ),
      ),
    );
  }
}
