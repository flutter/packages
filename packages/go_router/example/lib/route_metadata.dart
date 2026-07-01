// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

void main() => runApp(const RouteMetadataApp());

/// An example that displays metadata from the matched route.
class RouteMetadataApp extends StatelessWidget {
  /// Creates a [RouteMetadataApp].
  const RouteMetadataApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(routerConfig: _router);
  }
}

final GoRouter _router = GoRouter(
  initialLocation: '/books',
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      redirect: (BuildContext context, GoRouterState state) => '/books',
    ),
    GoRoute(
      path: '/books',
      metadata: const <String, dynamic>{
        'section': 'Library',
        'requiresAuth': true,
        'analyticsName': 'books',
      },
      builder: (BuildContext context, GoRouterState state) {
        return MetadataScreen(state: state);
      },
      routes: <RouteBase>[
        GoRoute(
          path: 'preview',
          metadata: const <String, dynamic>{
            'requiresAuth': false,
            'analyticsName': 'book-preview',
          },
          builder: (BuildContext context, GoRouterState state) {
            return MetadataScreen(state: state);
          },
        ),
      ],
    ),
  ],
);

/// Displays the current route metadata.
class MetadataScreen extends StatelessWidget {
  /// Creates a [MetadataScreen].
  const MetadataScreen({required this.state, super.key});

  /// The current route state.
  final GoRouterState state;

  @override
  Widget build(BuildContext context) {
    final title = state.metadata['analyticsName'] as String;
    final requiresAuth = state.metadata['requiresAuth'] as bool;

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          ListTile(
            title: const Text('section'),
            subtitle: Text(state.metadata['section'] as String),
          ),
          ListTile(
            title: const Text('requiresAuth'),
            subtitle: Text(requiresAuth.toString()),
          ),
          ListTile(
            title: const Text('analyticsName'),
            subtitle: Text(title),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () => context.go('/books'),
            child: const Text('Books'),
          ),
          const SizedBox(height: 8),
          FilledButton(
            onPressed: () => context.go('/books/preview'),
            child: const Text('Preview'),
          ),
        ],
      ),
    );
  }
}
