// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

void main() {
  runApp(const GoRouterExampleApp());
}

/// An example of integrating package:animations with package:go_router.
class GoRouterExampleApp extends StatelessWidget {
  /// Creates a [GoRouterExampleApp].
  const GoRouterExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'OpenContainer go_router Example',
      routerConfig: _router,
    );
  }
}

final GoRouter _router = GoRouter(
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) {
        return const HomeScreen();
      },
      routes: <RouteBase>[
        GoRoute(
          path: 'details/:id',
          pageBuilder: (BuildContext context, GoRouterState state) {
            final String id = state.pathParameters['id']!;
            return OpenContainerPage<void>(
              transitionTag: 'item-$id',
              openBuilder: (BuildContext context, VoidCallback closeContainer) {
                return DetailsScreen(id: id);
              },
            );
          },
        ),
      ],
    ),
  ],
);

/// The home screen of the go_router example.
class HomeScreen extends StatelessWidget {
  /// Creates a [HomeScreen].
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('OpenContainer go_router Example')),
      body: ListView.builder(
        itemCount: 20,
        itemBuilder: (BuildContext context, int index) {
          final id = index.toString();
          return OpenContainer(
            transitionTag: 'item-$id',
            onOpen: () {
              context.go('/details/$id');
              return Future<void>.value();
            },
            closedBuilder: (BuildContext context, VoidCallback openContainer) {
              return ListTile(
                onTap: openContainer,
                title: Text('Item $id'),
                subtitle: const Text('Tap to open with container transform'),
              );
            },
            openBuilder: (BuildContext context, VoidCallback closeContainer) {
              return DetailsScreen(id: id);
            },
          );
        },
      ),
    );
  }
}

/// The details screen of the go_router example.
class DetailsScreen extends StatelessWidget {
  /// Creates a [DetailsScreen].
  const DetailsScreen({super.key, required this.id});

  /// The ID of the item to display.
  final String id;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Details of Item $id')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Details for Item $id',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.pop(),
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }
}
