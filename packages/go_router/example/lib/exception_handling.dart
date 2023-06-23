// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// This sample app shows how to use `GoRouter.onException` to redirect on
/// exception.
///
/// The first route '/' is mapped to [HomeScreen], and the second route
/// '/404' is mapped to [NotFoundScreen].
///
/// Any other unknown route or exception is redirected to `/404`.
void main() => runApp(const MyApp());

/// The route configuration.
final GoRouter _router = GoRouter(
  onException: (_, GoRouterState state, GoRouter router) {
    router.go('/404', extra: state.location);
  },
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) {
        return const HomeScreen();
      },
    ),
    GoRoute(
      path: '/404',
      builder: (BuildContext context, GoRouterState state) {
        return NotFoundScreen(uri: state.extra as String? ?? '');
      },
    ),
  ],
);

/// The main app.
class MyApp extends StatelessWidget {
  /// Constructs a [MyApp]
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _router,
    );
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
      body: Center(
        child: ElevatedButton(
          onPressed: () => context.go('/some-unknown-route'),
          child: const Text('Simulates user entering unknown url'),
        ),
      ),
    );
  }
}

/// The not found screen
class NotFoundScreen extends StatelessWidget {
  /// Constructs a [HomeScreen]
  const NotFoundScreen({super.key, required this.uri});

  /// The uri that can not be found.
  final String uri;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Page Not Found')),
      body: Center(
        child: Text("Can't find a page for: $uri"),
      ),
    );
  }
}
