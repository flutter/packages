// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

/// This sample app shows an app with two screens.
void main() => runApp(const App());

/// The login status.
final ValueNotifier<bool> isLogin = ValueNotifier<bool>(false);

/// The route configuration.
final GoRouter _router = GoRouter(
  debugLogDiagnostics: true,
  // Uncomment this when you want to automatically redirect when ValueNotifier is updated.
  // refreshListenable: isLogin,
  routes: <GoRoute>[
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) =>
          const HomeScreen(),
      routes: <RouteBase>[
        GoRoute(
          path: 'login',
          builder: (BuildContext context, GoRouterState state) =>
              const LoginScreen(),
          redirect: (BuildContext context, GoRouterState state) {
            if (isLogin.value) {
              return '/';
            } else {
              return null;
            }
          },
        ),
      ],
    ),
  ],
);

/// The main app.
class App extends StatelessWidget {
  /// Constructs a [App]
  const App({super.key});

  /// The title of the app.
  static const String title = 'GoRouter Example: Redirection(Route level)';

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ValueNotifier<bool>>.value(
      value: isLogin,
      child: MaterialApp.router(
        routerConfig: _router,
        title: title,
        debugShowCheckedModeBanner: false,
      ),
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
      appBar: AppBar(
        title: const Text('Home Screen'),
      ),
      body: Center(
        child: TextButton(
          onPressed: () => context.push('/login'),
          // using go works as except
          child: const Text('Go to Auth'),
        ),
      ),
    );
  }
}

/// The login screen
class LoginScreen extends StatelessWidget {
  /// Constructs a [LoginScreen]
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isLoggIn = context.select(
      (ValueNotifier<bool> value) => value.value,
    );
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login Screen'),
      ),
      body: isLoggIn
          ? Center(
              child: ElevatedButton(
                onPressed: () {
                  context.read<ValueNotifier<bool>>().value = false;
                },
                child: const Text('Logout'),
              ),
            )
          : Center(
              child: ElevatedButton(
                onPressed: () {
                  context.read<ValueNotifier<bool>>().value = true;
                },
                child: const Text('Login'),
              ),
            ),
    );
  }
}
