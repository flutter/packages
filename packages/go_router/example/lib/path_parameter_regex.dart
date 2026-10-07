// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

/// Router configuration demonstrating regex-constrained path parameters.
final GoRouter router = GoRouter(
  routes: <GoRoute>[
    GoRoute(
      path: r'/users/:id(\d+)',
      builder: (BuildContext context, GoRouterState state) {
        return Scaffold(body: Center(child: Text('User ${state.pathParameters['id']}')));
      },
    ),
  ],
);

/// Runs the path parameter regular expression example.
void main() {
  runApp(const PathParameterRegexApp());
}

/// A minimal app demonstrating regex-constrained path parameters.
class PathParameterRegexApp extends StatelessWidget {
  /// Creates a [PathParameterRegexApp].
  const PathParameterRegexApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(routerConfig: router);
  }
}
