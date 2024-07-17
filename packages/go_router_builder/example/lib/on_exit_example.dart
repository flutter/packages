// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: public_member_api_docs, unreachable_from_main

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

part 'on_exit_example.g.dart';

void main() => runApp(App());

class App extends StatelessWidget {
  App({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp.router(
        routerConfig: _router,
        title: _appTitle,
      );

  final GoRouter _router = GoRouter(routes: $appRoutes);
}

@TypedGoRoute<HomeRoute>(
  path: '/',
  routes: <TypedGoRoute<GoRouteData>>[
    TypedGoRoute<SubRoute>(path: 'sub-route')
  ],
)
class HomeRoute extends GoRouteData {
  const HomeRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const HomeScreen();
}

class SubRoute extends GoRouteData {
  const SubRoute();

  @override
  Future<bool> onExit(BuildContext context, GoRouterState state) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        content: const Text('Are you sure to leave this page?'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
    return confirmed ?? false;
  }

  @override
  Widget build(BuildContext context, GoRouterState state) => const SubScreen();
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(title: const Text(_appTitle)),
      body: Center(
        child: ElevatedButton(
          onPressed: () => const SubRoute().go(context),
          child: const Text('Go to sub screen'),
        ),
      ));
}

class SubScreen extends StatelessWidget {
  const SubScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('$_appTitle Sub screen')),
        body: Center(
          child: ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Go back'),
          ),
        ),
      );
}

const String _appTitle = 'GoRouter Example: builder';
