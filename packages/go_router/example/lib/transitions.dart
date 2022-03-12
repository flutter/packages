// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

void main() => runApp(App());

/// The main app.
class App extends StatelessWidget {
  /// Creates an [App].
  App({Key? key}) : super(key: key);

  /// The title of the app.
  static const String title = 'GoRouter Example: Custom Transitions';

  @override
  Widget build(BuildContext context) => MaterialApp.router(
        routeInformationParser: _router.routeInformationParser,
        routerDelegate: _router.routerDelegate,
        title: title,
      );

  final GoRouter _router = GoRouter(
    routes: <GoRoute>[
      GoRoute(
        path: '/',
        redirect: (_) => '/none',
      ),
      GoRoute(
        path: '/fade',
        pageBuilder: (BuildContext context, GoRouterState state) =>
            CustomTransitionPage<void>(
          key: state.pageKey,
          child: const ExampleTransitionsScreen(
            kind: 'fade',
            color: Colors.red,
          ),
          transitionsBuilder: (BuildContext context,
                  Animation<double> animation,
                  Animation<double> secondaryAnimation,
                  Widget child) =>
              FadeTransition(opacity: animation, child: child),
        ),
      ),
      GoRoute(
        path: '/scale',
        pageBuilder: (BuildContext context, GoRouterState state) =>
            CustomTransitionPage<void>(
          key: state.pageKey,
          child: const ExampleTransitionsScreen(
            kind: 'scale',
            color: Colors.green,
          ),
          transitionsBuilder: (BuildContext context,
                  Animation<double> animation,
                  Animation<double> secondaryAnimation,
                  Widget child) =>
              ScaleTransition(scale: animation, child: child),
        ),
      ),
      GoRoute(
        path: '/slide',
        pageBuilder: (BuildContext context, GoRouterState state) =>
            CustomTransitionPage<void>(
          key: state.pageKey,
          child: const ExampleTransitionsScreen(
            kind: 'slide',
            color: Colors.yellow,
          ),
          transitionsBuilder: (BuildContext context,
                  Animation<double> animation,
                  Animation<double> secondaryAnimation,
                  Widget child) =>
              SlideTransition(
            position: animation.drive(
              Tween<Offset>(
                begin: const Offset(0.25, 0.25),
                end: Offset.zero,
              ).chain(CurveTween(curve: Curves.easeIn)),
            ),
            child: child,
          ),
        ),
      ),
      GoRoute(
        path: '/rotation',
        pageBuilder: (BuildContext context, GoRouterState state) =>
            CustomTransitionPage<void>(
          key: state.pageKey,
          child: const ExampleTransitionsScreen(
            kind: 'rotation',
            color: Colors.purple,
          ),
          transitionsBuilder: (BuildContext context,
                  Animation<double> animation,
                  Animation<double> secondaryAnimation,
                  Widget child) =>
              RotationTransition(turns: animation, child: child),
        ),
      ),
      GoRoute(
        path: '/none',
        pageBuilder: (BuildContext context, GoRouterState state) =>
            NoTransitionPage<void>(
          key: state.pageKey,
          child: const ExampleTransitionsScreen(
            kind: 'none',
            color: Colors.white,
          ),
        ),
      ),
    ],
  );
}

/// An Example transitions screen.
class ExampleTransitionsScreen extends StatelessWidget {
  /// Creates an [ExampleTransitionsScreen].
  const ExampleTransitionsScreen({
    required this.color,
    required this.kind,
    Key? key,
  }) : super(key: key);

  /// The available transition kinds.
  static final List<String> kinds = <String>[
    'fade',
    'scale',
    'slide',
    'rotation',
    'none'
  ];

  /// The color of the container.
  final Color color;

  /// The transition kind
  final String kind;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text('${App.title}: $kind')),
        body: Container(
          color: color,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                for (final String kind in kinds)
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: ElevatedButton(
                      onPressed: () => context.go('/$kind'),
                      child: Text('$kind transition'),
                    ),
                  )
              ],
            ),
          ),
        ),
      );
}
