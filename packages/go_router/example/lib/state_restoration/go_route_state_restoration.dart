// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

void main() => runApp(const App());

/// An example showing how to configure state restoration
/// for [GoRoute]s.
class App extends StatefulWidget {
  /// Creates an [App].
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  final GoRouter _router = GoRouter(
    restorationScopeId: 'router',
    routes: <GoRoute>[
      GoRoute(
        path: '/',
        // restorationId is set for the route automatically
        // since builder is used.
        builder: (BuildContext context, GoRouterState state) {
          return const HomePage();
        },
        routes: <GoRoute>[
          GoRoute(
            path: 'login',
            // restorationId must be supplied to the MaterialPage
            // since pageBuilder is used.
            pageBuilder: (BuildContext context, GoRouterState state) {
              return const MaterialPage<void>(
                restorationId: 'loginPage',
                fullscreenDialog: true,
                child: LoginPage(),
              );
            },
          ),
        ],
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      restorationScopeId: 'mainApp',
      routerConfig: _router,
    );
  }
}

/// The root page of the app.
class HomePage extends StatelessWidget {
  /// Creates a [HomePage].
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: Column(
        children: <Widget>[
          const TextField(restorationId: 'homeTextField'),
          FilledButton(
            onPressed: () {
              context.go('/login');
            },
            child: const Text('Go to Login'),
          ),
        ],
      ),
    );
  }
}

/// A [LoginPage] with a restorable [TextField].
class LoginPage extends StatelessWidget {
  /// Creates a [LoginPage].
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: const TextField(restorationId: 'loginTextField'),
    );
  }
}
