// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

void main() => runApp(App());

const Color _kBlue = Color(0xFF2196F3);
const Color _kWhite = Color(0xFFFFFFFF);

/// The main app.
class App extends StatelessWidget {
  /// Creates an [App].
  App({Key? key}) : super(key: key);

  /// The title of the app.
  static const String title = 'GoRouter Example: WidgetsApp';

  @override
  Widget build(BuildContext context) => WidgetsApp.router(
        routeInformationParser: _router.routeInformationParser,
        routerDelegate: _router.routerDelegate,
        title: title,
        color: _kBlue,
        textStyle: const TextStyle(color: _kBlue),
      );

  final GoRouter _router = GoRouter(
    debugLogDiagnostics: true,
    routes: <GoRoute>[
      GoRoute(
        path: '/',
        builder: (BuildContext context, GoRouterState state) =>
            const Page1Screen(),
      ),
      GoRoute(
        path: '/page2',
        builder: (BuildContext context, GoRouterState state) =>
            const Page2Screen(),
      ),
    ],
  );
}

/// The screen of the first page.
class Page1Screen extends StatelessWidget {
  /// Creates a [Page1Screen].
  const Page1Screen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text(
                App.title,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Button(
                onPressed: () => context.go('/page2'),
                child: const Text(
                  'Go to page 2',
                  style: TextStyle(color: _kWhite),
                ),
              ),
            ],
          ),
        ),
      );
}

/// The screen of the second page.
class Page2Screen extends StatelessWidget {
  /// Creates a [Page2Screen].
  const Page2Screen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text(
                App.title,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Button(
                onPressed: () => context.go('/'),
                child: const Text(
                  'Go to home page',
                  style: TextStyle(color: _kWhite),
                ),
              ),
            ],
          ),
        ),
      );
}

/// A custom button.
class Button extends StatelessWidget {
  /// Creates a [Button].
  const Button({
    required this.onPressed,
    required this.child,
    Key? key,
  }) : super(key: key);

  /// Called when user pressed the button.
  final VoidCallback onPressed;

  /// The child subtree.
  final Widget child;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onPressed,
        child: Container(
          padding: const EdgeInsets.all(8),
          color: _kBlue,
          child: child,
        ),
      );
}
