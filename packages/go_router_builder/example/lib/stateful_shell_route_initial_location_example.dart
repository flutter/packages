// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: public_member_api_docs, unreachable_from_main

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
    initialLocation: '/home',
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
    TypedStatefulShellBranch<HomeShellBranchData>(
      routes: <TypedRoute<RouteData>>[
        TypedGoRoute<HomeRouteData>(
          path: '/home',
        ),
      ],
    ),
    TypedStatefulShellBranch<NotificationsShellBranchData>(
      routes: <TypedRoute<RouteData>>[
        TypedGoRoute<NotificationsRouteData>(
          path: '/notifications/:section',
        ),
      ],
    ),
    TypedStatefulShellBranch<OrdersShellBranchData>(
      routes: <TypedRoute<RouteData>>[
        TypedGoRoute<OrdersRouteData>(
          path: '/orders',
        ),
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

class HomeShellBranchData extends StatefulShellBranchData {
  const HomeShellBranchData();
}

class NotificationsShellBranchData extends StatefulShellBranchData {
  const NotificationsShellBranchData();

  static String $initialLocation = '/notifications/old';
}

class OrdersShellBranchData extends StatefulShellBranchData {
  const OrdersShellBranchData();
}

class HomeRouteData extends GoRouteData with _$HomeRouteData {
  const HomeRouteData();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const HomePageView(label: 'Home page');
  }
}

enum NotificationsPageSection {
  latest,
  old,
  archive,
}

class NotificationsRouteData extends GoRouteData with _$NotificationsRouteData {
  const NotificationsRouteData({
    required this.section,
  });

  final NotificationsPageSection section;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return NotificationsPageView(
      section: section,
    );
  }
}

class OrdersRouteData extends GoRouteData with _$OrdersRouteData {
  const OrdersRouteData();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const OrdersPageView(label: 'Orders page');
  }
}

class MainPageView extends StatelessWidget {
  const MainPageView({
    required this.navigationShell,
    super.key,
  });

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: navigationShell,
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Notifications',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Orders',
          ),
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

class HomePageView extends StatelessWidget {
  const HomePageView({
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

class NotificationsPageView extends StatelessWidget {
  const NotificationsPageView({
    super.key,
    required this.section,
  });

  final NotificationsPageSection section;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      initialIndex: NotificationsPageSection.values.indexOf(section),
      child: const Column(
        children: <Widget>[
          TabBar(
            tabs: <Tab>[
              Tab(
                child: Text(
                  'Latest',
                  style: TextStyle(color: Colors.black87),
                ),
              ),
              Tab(
                child: Text(
                  'Old',
                  style: TextStyle(color: Colors.black87),
                ),
              ),
              Tab(
                child: Text(
                  'Archive',
                  style: TextStyle(color: Colors.black87),
                ),
              ),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: <Widget>[
                NotificationsSubPageView(
                  label: 'Latest notifications',
                ),
                NotificationsSubPageView(
                  label: 'Old notifications',
                ),
                NotificationsSubPageView(
                  label: 'Archived notifications',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class NotificationsSubPageView extends StatelessWidget {
  const NotificationsSubPageView({
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

class OrdersPageView extends StatelessWidget {
  const OrdersPageView({
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
