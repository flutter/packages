// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

void main() => runApp(App());

/// The main app.
class App extends StatelessWidget {
  /// Creates an [App].
  App({super.key});

  /// The title of the app.
  static const String title = 'GoRouter Example: Push';

  @override
  Widget build(BuildContext context) => MaterialApp.router(
        routerConfig: _router,
        title: title,
      );

  late final GoRouter _router = GoRouter(
    routes: <GoRoute>[
      GoRoute(
        path: '/',
        builder: (BuildContext context, GoRouterState state) =>
            const Page1ScreenWithPush(),
      ),
      GoRoute(
        path: '/page2',
        builder: (BuildContext context, GoRouterState state) =>
            Page2ScreenWithPush(
          int.parse(state.queryParameters['push-count']!),
        ),
      ),
    ],
  );
}

/// The screen of the first page.
class Page1ScreenWithPush extends StatelessWidget {
  /// Creates a [Page1ScreenWithPush].
  const Page1ScreenWithPush({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('${App.title}: page 1')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ElevatedButton(
                onPressed: () => context.push('/page2?push-count=1'),
                child: const Text('Push page 2'),
              ),
            ],
          ),
        ),
      );
}

/// The screen of the second page.
class Page2ScreenWithPush extends StatelessWidget {
  /// Creates a [Page2ScreenWithPush].
  const Page2ScreenWithPush(this.pushCount, {super.key});

  /// The push count.
  final int pushCount;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text('${App.title}: page 2 w/ push count $pushCount'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8),
                child: ElevatedButton(
                  onPressed: () => context.go('/'),
                  child: const Text('Go to home page'),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: ElevatedButton(
                  onPressed: () => context.push(
                    '/page2?push-count=${pushCount + 1}',
                  ),
                  child: const Text('Push page 2 (again)'),
                ),
              ),
            ],
          ),
        ),
      );
}
