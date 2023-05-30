// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

part 'extra_example.g.dart';

void main() => runApp(const App());

final GoRouter _router = GoRouter(
  routes: $appRoutes,
  initialLocation: '/splash',
);

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _router,
    );
  }
}

class Extra {
  const Extra(this.value);

  final int value;
}

@TypedGoRoute<RequiredExtraRoute>(path: '/requiredExtra')
class RequiredExtraRoute extends GoRouteData {
  const RequiredExtraRoute({required this.$extra});

  final Extra $extra;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      RequiredExtraScreen(extra: $extra);
}

class RequiredExtraScreen extends StatelessWidget {
  const RequiredExtraScreen({super.key, required this.extra});

  final Extra extra;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Required Extra')),
      body: Center(child: Text('Extra: ${extra.value}')),
    );
  }
}

@TypedGoRoute<OptionalExtraRoute>(path: '/optionalExtra')
class OptionalExtraRoute extends GoRouteData {
  const OptionalExtraRoute({this.$extra});

  final Extra? $extra;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      OptionalExtraScreen(extra: $extra);
}

class OptionalExtraScreen extends StatelessWidget {
  const OptionalExtraScreen({super.key, this.extra});

  final Extra? extra;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Optional Extra')),
      body: Center(child: Text('Extra: ${extra?.value}')),
    );
  }
}

@TypedGoRoute<SplashRoute>(path: '/splash')
class SplashRoute extends GoRouteData {
  const SplashRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const Splash();
}

class Splash extends StatelessWidget {
  const Splash({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Splash')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Placeholder(),
          ElevatedButton(
            onPressed: () =>
                const RequiredExtraRoute($extra: Extra(1)).go(context),
            child: const Text('Required Extra'),
          ),
          ElevatedButton(
            onPressed: () =>
                const OptionalExtraRoute($extra: Extra(2)).go(context),
            child: const Text('Optional Extra'),
          ),
          ElevatedButton(
            onPressed: () => const OptionalExtraRoute().go(context),
            child: const Text('Optional Extra (null)'),
          ),
        ],
      ),
    );
  }
}
