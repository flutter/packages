// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

part 'stateful_shell_route_initial_location_example.g.dart';

void main() => runApp(App());

class App extends StatelessWidget {
  App({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp.router(
        routerConfig: _router,
      );

  final GoRouter _router = GoRouter(
    routes: $appRoutes,
    initialLocation: '/first',
  );
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('foo')),
      );
}

@TypedStatefulShellRoute<MainShellRouteData>(
  branches: <TypedStatefulShellBranch<StatefulShellBranchData>>[
    TypedStatefulShellBranch<FirstShellBranchData>(
      routes: <TypedRoute<RouteData>>[
        TypedGoRoute<FirstRouteData>(path: '/first'),
      ],
    ),
    TypedStatefulShellBranch<SecondShellBranchData>(
      routes: <TypedRoute<RouteData>>[
        TypedGoRoute<SecondRouteData>(path: '/second/:section'),
      ],
    ),
    TypedStatefulShellBranch<ThirdShellBranchData>(
      routes: <TypedRoute<RouteData>>[
        TypedGoRoute<ThirdRouteData>(path: '/third'),
      ],
    ),
  ],
)
class MainShellRouteData extends StatefulShellRouteData {
  const MainShellRouteData();

  @override
  Widget builder(
    BuildContext context,
    GoRouterState state,
    StatefulNavigationShell navigationShell,
  ) {
    return MainPageView(
      navigationShell: navigationShell,
    );
  }
}

class FirstShellBranchData extends StatefulShellBranchData {
  const FirstShellBranchData();
}

class SecondShellBranchData extends StatefulShellBranchData {
  const SecondShellBranchData();

  static String $initialLocation = '/second/second';
}

class ThirdShellBranchData extends StatefulShellBranchData {
  const ThirdShellBranchData();
}

class FirstRouteData extends GoRouteData {
  const FirstRouteData();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const FirstPageView(label: 'First screen');
  }
}

enum SecondPageSection {
  first,
  second,
  third,
}

class SecondRouteData extends GoRouteData {
  const SecondRouteData({
    required this.section,
  });

  final SecondPageSection section;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return SecondPageView(
      section: section,
    );
  }
}

class ThirdRouteData extends GoRouteData {
  const ThirdRouteData();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const ThirdPageView(label: 'Third screen');
  }
}

class MainPageView extends StatelessWidget {
  const MainPageView({
    required this.navigationShell,
    Key? key,
  }) : super(key: key);

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: navigationShell,
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'First'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Second'),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Third'),
        ],
        currentIndex: navigationShell.currentIndex,
        onTap: (int index) => _onTap(context, index),
      ),
    );
  }

  void _onTap(BuildContext context, int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }
}

class FirstPageView extends StatelessWidget {
  const FirstPageView({
    required this.label,
    super.key,
  });

  final String label;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(label),
    );
  }
}

class SecondPageView extends StatelessWidget {
  const SecondPageView({
    super.key,
    required this.section,
  });

  final SecondPageSection section;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      initialIndex: SecondPageSection.values.indexOf(section),
      child: Column(
        children: [
          TabBar(
            tabs: [
              Tab(
                child: Text(
                  'First',
                  style: TextStyle(color: Colors.black87),
                ),
              ),
              Tab(
                child: Text(
                  'Second',
                  style: TextStyle(color: Colors.black87),
                ),
              ),
              Tab(
                child: Text(
                  'Third',
                  style: TextStyle(color: Colors.black87),
                ),
              ),
            ],
            onTap: (index) {
              _onTap(context, index);
            },
          ),
          Expanded(
            child: TabBarView(
              children: [
                SecondSubPageView(
                  label: 'First',
                ),
                SecondSubPageView(
                  label: 'Second',
                ),
                SecondSubPageView(
                  label: 'Third',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

void _onTap(BuildContext context, index) {}

class SecondSubPageView extends StatelessWidget {
  const SecondSubPageView({
    required this.label,
    super.key,
  });

  final String label;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(label),
    );
  }
}

class ThirdPageView extends StatelessWidget {
  const ThirdPageView({
    required this.label,
    super.key,
  });

  final String label;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(label),
    );
  }
}
