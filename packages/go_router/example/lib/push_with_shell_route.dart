// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// This scenario demonstrates the behavior when pushing ShellRoute in various
// scenario.
//
// This example have three routes, /shell1, /shell2, and /regular-route. The
// /shell1 and /shell2 are nested in different ShellRoutes. The /regular-route
// is a simple GoRoute.

void main() {
  runApp(PushWithShellRouteExampleApp());
}

/// An example demonstrating how to use [ShellRoute]
class PushWithShellRouteExampleApp extends StatelessWidget {
  /// Creates a [PushWithShellRouteExampleApp]
  PushWithShellRouteExampleApp({super.key});

  final GoRouter _router = GoRouter(
    initialLocation: '/home',
    debugLogDiagnostics: true,
    routes: <RouteBase>[
      ShellRoute(
        builder: (BuildContext context, GoRouterState state, Widget child) {
          return ScaffoldForShell1(child: child);
        },
        routes: <RouteBase>[
          GoRoute(
            path: '/home',
            builder: (BuildContext context, GoRouterState state) {
              return const Home();
            },
          ),
          GoRoute(
            path: '/shell1',
            pageBuilder: (_, __) => const NoTransitionPage<void>(
              child: Center(child: Text('shell1 body')),
            ),
          ),
        ],
      ),
      ShellRoute(
        builder: (BuildContext context, GoRouterState state, Widget child) {
          return ScaffoldForShell2(child: child);
        },
        routes: <RouteBase>[
          GoRoute(
            path: '/shell2',
            builder: (BuildContext context, GoRouterState state) {
              return const Center(child: Text('shell2 body'));
            },
          ),
        ],
      ),
      GoRoute(
        path: '/regular-route',
        builder: (BuildContext context, GoRouterState state) {
          return const Scaffold(body: Center(child: Text('regular route')));
        },
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Flutter Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      routerConfig: _router,
    );
  }
}

/// Builds the "shell" for /shell1
class ScaffoldForShell1 extends StatelessWidget {
  /// Constructs an [ScaffoldForShell1].
  const ScaffoldForShell1({required this.child, super.key});

  /// The widget to display in the body of the Scaffold.
  /// In this sample, it is a Navigator.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('shell1')),
      body: child,
    );
  }
}

/// Builds the "shell" for /shell1
class ScaffoldForShell2 extends StatelessWidget {
  /// Constructs an [ScaffoldForShell1].
  const ScaffoldForShell2({required this.child, super.key});

  /// The widget to display in the body of the Scaffold.
  /// In this sample, it is a Navigator.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('shell2')),
      body: child,
    );
  }
}

/// The screen for /home
class Home extends StatelessWidget {
  /// Constructs a [Home] widget.
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          TextButton(
            onPressed: () {
              GoRouter.of(context).push('/shell1');
            },
            child: const Text('push the same shell route /shell1'),
          ),
          TextButton(
            onPressed: () {
              GoRouter.of(context).push('/shell2');
            },
            child: const Text('push the different shell route /shell2'),
          ),
          TextButton(
            onPressed: () {
              GoRouter.of(context).push('/regular-route');
            },
            child: const Text('push the regular route /regular-route'),
          ),
        ],
      ),
    );
  }
}
