// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

void main() => runApp(const App());

/// An example showing how to configure state restoration
/// for a [ShellRoute].
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
      GoRoute(
        path: '/',
        builder: (BuildContext context, GoRouterState state) {
          return const HomePage();
        },
        routes: <RouteBase>[
          ShellRoute(
            restorationScopeId: 'onboardingShell',
            pageBuilder:
                (BuildContext context, GoRouterState state, Widget child) {
                  return MaterialPage<void>(
                    restorationId: 'onboardingPage',
                    child: OnboardingScaffold(child: child),
                  );
                },
            routes: <GoRoute>[
              GoRoute(
                path: 'welcome',
                builder: (BuildContext context, GoRouterState state) {
                  return const WelcomeBody();
                },
              ),
              GoRoute(
                path: 'setup',
                builder: (BuildContext context, GoRouterState state) {
                  return const SetupBody();
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
              context.go('/welcome');
            },
            child: const Text('Go to Welcome'),
          ),
        ],
      ),
    );
  }
}

/// A [Scaffold] for the onboarding flow.
class OnboardingScaffold extends StatelessWidget {
  /// Creates an [OnboardingScaffold].
  const OnboardingScaffold({required this.child, super.key});

  /// The widget displayed in the body of the [Scaffold].
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Onboarding'),
        automaticallyImplyLeading: false,
      ),
      body: child,
    );
  }
}

/// The body for the Welcome step of the onboarding flow.
class WelcomeBody extends StatelessWidget {
  /// Creates a [WelcomeBody].
  const WelcomeBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        const Text('Welcome'),
        FilledButton(
          onPressed: () {
            context.go('/setup');
          },
          child: const Text('Go to Setup'),
        ),
      ],
    );
  }
}

/// The body for the Setup step of the onboarding flow.
class SetupBody extends StatelessWidget {
  /// Creates a [SetupBody].
  const SetupBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        const Text('Setup'),
        const TextField(restorationId: 'setupTextField'),
        FilledButton(
          onPressed: () {
            context.go('/');
          },
          child: const Text('Go to Home'),
        ),
      ],
    );
  }
}
