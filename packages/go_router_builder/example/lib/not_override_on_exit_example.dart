// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: public_member_api_docs, unreachable_from_main

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

part 'not_override_on_exit_example.g.dart';

void main() => runApp(App());

class App extends StatelessWidget {
  App({super.key});

  @override
  Widget build(BuildContext context) =>
      MaterialApp.router(routerConfig: _router, title: _appTitle);

  final GoRouter _router = GoRouter(routes: $appRoutes);
}

@TypedGoRoute<HomeRoute>(path: '/')
class HomeRoute extends GoRouteData with $HomeRoute {
  const HomeRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const HomeScreen();
}

@TypedGoRoute<Sub1Route>(path: '/sub-1-route')
class Sub1Route extends GoRouteData with $Sub1Route {
  const Sub1Route();

  @override
  Widget build(BuildContext context, GoRouterState state) => const Sub1Screen();
}

@TypedGoRoute<Sub2Route>(path: '/sub-2-route')
class Sub2Route extends GoRouteData with $Sub2Route {
  const Sub2Route();

  @override
  Widget build(BuildContext context, GoRouterState state) => const Sub2Screen();
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _result;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text(_appTitle)),
    body: Center(
      child: ElevatedButton(
        onPressed: () async {
          final String? result = await const Sub1Route().push<String?>(context);
          if (!context.mounted) {
            return;
          }
          setState(() => _result = result);
        },
        child: Text(_result ?? 'Go to sub 1 screen'),
      ),
    ),
  );
}

class Sub1Screen extends StatelessWidget {
  const Sub1Screen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('$_appTitle Sub 1 screen')),
    body: Center(
      child: ElevatedButton(
        onPressed: () async {
          final String? result = await const Sub2Route().push<String?>(context);
          if (!context.mounted) {
            return;
          }
          context.pop(result);
        },
        child: const Text('Go to sub 2 screen'),
      ),
    ),
  );
}

class Sub2Screen extends StatelessWidget {
  const Sub2Screen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('$_appTitle Sub 2 screen')),
    body: Center(
      child: ElevatedButton(
        onPressed: () => context.pop('Sub2Screen'),
        child: const Text('Go back to sub 1 screen'),
      ),
    ),
  );
}

const String _appTitle = 'GoRouter Example: builder';
