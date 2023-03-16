// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

part 'shell_route_example.g.dart';

void main() => runApp(App());

class App extends StatelessWidget {
  App({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp.router(
        routerConfig: _router,
      );

  final GoRouter _router = GoRouter(
    routes: $appRoutes,
    initialLocation: '/foo',
  );
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('foo')),
      );
}

@TypedShellRoute<MyShellRouteData>(
  routes: <TypedRoute<RouteData>>[
    TypedGoRoute<FooRouteData>(path: '/foo'),
    TypedGoRoute<BarRouteData>(path: '/bar'),
  ],
)
class MyShellRouteData extends ShellRouteData {
  const MyShellRouteData();

  @override
  Widget builder(
    BuildContext context,
    GoRouterState state,
    Widget navigator,
  ) {
    return MyShellRouteScreen(child: navigator);
  }
}

class FooRouteData extends GoRouteData {
  const FooRouteData();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const FooScreen();
  }
}

class BarRouteData extends GoRouteData {
  const BarRouteData();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const BarScreen();
  }
}

class MyShellRouteScreen extends StatelessWidget {
  const MyShellRouteScreen({required this.child, super.key});

  final Widget child;

  int getCurrentIndex(BuildContext context) {
    final String location = GoRouter.of(context).location;
    if (location == '/bar') {
      return 1;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final int currentIndex = getCurrentIndex(context);
    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Foo',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.business),
            label: 'Bar',
          ),
        ],
        onTap: (int index) {
          switch (index) {
            case 0:
              const FooRouteData().go(context);
              break;
            case 1:
              const BarRouteData().go(context);
              break;
          }
        },
      ),
    );
  }
}

class FooScreen extends StatelessWidget {
  const FooScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text('Foo');
  }
}

class BarScreen extends StatelessWidget {
  const BarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text('Bar');
  }
}

@TypedGoRoute<LoginRoute>(path: '/login')
class LoginRoute extends GoRouteData {
  const LoginRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const LoginScreen();
}

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text('Login');
  }
}
