// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_adaptive_scaffold/flutter_adaptive_scaffold.dart';
import 'package:go_router/go_router.dart';

import 'pages/pages.dart';

/// The [ScaffoldShell] is a [StatelessWidget] that uses the [AdaptiveScaffold]
/// to create a shell for the application.
class ScaffoldShell extends StatelessWidget {
  /// Create a new instance of [AppScaffoldShell]
  const ScaffoldShell({
    required this.navigationShell,
    super.key,
  });

  /// The navigation shell to use with the navigation.
  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return AdaptiveScaffold(
      useDrawer: false,
      body: (BuildContext context) => navigationShell,
      selectedIndex: navigationShell.currentIndex,
      onSelectedIndexChange: (int index) {
        navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        );
      },
      destinations: navigationShell.route.branches.map(
        (StatefulShellBranch e) {
          return switch (e.defaultRoute?.name) {
            HomePage.name => const NavigationDestination(
                icon: Icon(Icons.home), label: 'Home'),
            CounterPage.name => const NavigationDestination(
                icon: Icon(Icons.add), label: 'Counter'),
            MorePage.name => const NavigationDestination(
                icon: Icon(Icons.account_circle), label: 'More'),
            _ => throw UnimplementedError(
                'The route ${e.defaultRoute?.name} is not implemented.',
              ),
          };
        },
      ).toList(),
    );
  }
}
