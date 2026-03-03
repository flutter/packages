// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// To use a custom transition animation, provide a `pageBuilder` with a
/// CustomTransitionPage.
///
/// To learn more about animation in Flutter, check out the [Introduction to
/// animations](https://docs.flutter.dev/development/ui/animations) page on
/// flutter.dev.
void main() => runApp(const MyApp());

/// The route configuration.
final GoRouter _router = GoRouter(
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) {
        return const HomeScreen();
      },
      routes: <RouteBase>[
        GoRoute(
          path: 'details',
          pageBuilder: (BuildContext context, GoRouterState state) {
            return CustomTransitionPage<void>(
              key: state.pageKey,
              child: const DetailsScreen(),
              transitionDuration: const Duration(milliseconds: 150),
              transitionsBuilder:
                  (
                    BuildContext context,
                    Animation<double> animation,
                    Animation<double> secondaryAnimation,
                    Widget child,
                  ) {
                    // Change the opacity of the screen using a Curve based on the the animation's
                    // value
                    return FadeTransition(
                      opacity: CurveTween(
                        curve: Curves.easeInOut,
                      ).animate(animation),
                      child: child,
                    );
                  },
            );
          },
        ),
        GoRoute(
          path: 'dismissible-details',
          pageBuilder: (BuildContext context, GoRouterState state) {
            return CustomTransitionPage<void>(
              key: state.pageKey,
              child: const DismissibleDetails(),
              barrierDismissible: true,
              barrierColor: Colors.black38,
              opaque: false,
              transitionDuration: Duration.zero,
              transitionsBuilder: (_, __, ___, Widget child) => child,
            );
          },
        ),
        GoRoute(
          path: 'custom-reverse-transition-duration',
          pageBuilder: (BuildContext context, GoRouterState state) {
            return CustomTransitionPage<void>(
              key: state.pageKey,
              child: const DetailsScreen(),
              barrierDismissible: true,
              barrierColor: Colors.black38,
              opaque: false,
              transitionDuration: const Duration(milliseconds: 500),
              reverseTransitionDuration: const Duration(milliseconds: 200),
              transitionsBuilder:
                  (
                    BuildContext context,
                    Animation<double> animation,
                    Animation<double> secondaryAnimation,
                    Widget child,
                  ) {
                    return FadeTransition(opacity: animation, child: child);
                  },
            );
          },
        ),
      ],
    ),
  ],
);

/// The main app.
class MyApp extends StatelessWidget {
  /// Constructs a [MyApp]
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(routerConfig: _router);
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () => context.go('/details'),
              child: const Text('Go to the Details screen'),
            ),
            const SizedBox(height: 48),
            ElevatedButton(
              onPressed: () => context.go('/dismissible-details'),
              child: const Text('Go to the Dismissible Details screen'),
            ),
            const SizedBox(height: 48),
            ElevatedButton(
              onPressed: () =>
                  context.go('/custom-reverse-transition-duration'),
              child: const Text(
                'Go to the Custom Reverse Transition Duration Screen',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The details screen
class DetailsScreen extends StatelessWidget {
  /// Constructs a [DetailsScreen]
  const DetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Details Screen')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () => context.go('/'),
              child: const Text('Go back to the Home screen'),
            ),
          ],
        ),
      ),
    );
  }
}

/// The dismissible details screen
class DismissibleDetails extends StatelessWidget {
  /// Constructs a [DismissibleDetails]
  const DismissibleDetails({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(48),
      child: ColoredBox(color: Colors.red),
    );
  }
}
