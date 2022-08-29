// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// This scenario demonstrates an app with multi-level routing.
//
// The GoRoute '/' builds a HomeScreen page and has a sub-route, 'family'. The
// 'family' also has its own sub-route, person'.
//
// If a url matches a sub-route, the page built by the sub-route is placed on
// top of the parent's page. In this example, a url '/family/person' will create
// a stack of three pages, [PersonScreen, FamilyScreen, HomeScreen] where the
// PersonScreen being the top-most page and shown on the screen. Since there are
// two more pages under it, the back button is shown on the app bar and can pop
// the page to show the pages underneath.

void main() => runApp(App());

/// The main app.
class App extends StatelessWidget {
  /// Creates an [App].
  App({Key? key}) : super(key: key);

  /// The title of the app.
  static const String title = 'GoRouter Example: Sub-routes';

  @override
  Widget build(BuildContext context) => MaterialApp.router(
        routerConfig: _router,
        title: title,
      );

  final GoRouter _router = GoRouter(
    routes: <GoRoute>[
      GoRoute(
        path: '/',
        builder: (BuildContext context, GoRouterState state) =>
            const HomeScreen(),
        routes: <GoRoute>[
          GoRoute(
            path: 'family',
            builder: (BuildContext context, GoRouterState state) =>
                const FamilyScreen(),
            routes: <GoRoute>[
              GoRoute(
                path: 'person',
                builder: (BuildContext context, GoRouterState state) =>
                    const PersonScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

/// The home screen that shows a list of families.
class HomeScreen extends StatelessWidget {
  /// Creates a [HomeScreen].
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text(App.title)),
        body: Center(
          child: ElevatedButton(
            onPressed: () => context.go('/family'),
            child: const Text('Go to family screen'),
          ),
        ),
      );
}

/// The screen that shows a list of persons in a family.
class FamilyScreen extends StatelessWidget {
  /// Creates a [FamilyScreen].
  const FamilyScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Family screen')),
        body: Center(
          child: ElevatedButton(
            onPressed: () => context.go('/family/person'),
            child: const Text('Go to person screen'),
          ),
        ),
      );
}

/// The person screen.
class PersonScreen extends StatelessWidget {
  /// Creates a [PersonScreen].
  const PersonScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(title: const Text('Person screen')),
      body: const Center(
        child: Text('This is the person screen'),
      ));
}
