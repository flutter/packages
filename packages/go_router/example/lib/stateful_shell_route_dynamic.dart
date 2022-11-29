// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');

// This example demonstrates how to setup nested navigation using a
// BottomNavigationBar, using a dynamic set of tabs. Each tab uses its own
// persistent navigator, i.e. navigation state is maintained separately for each
// tab. This setup also enables deep linking into nested pages.
//
// This example demonstrates how to display routes within a StatefulShellRoute,
// that are places on separate navigators. The example also demonstrates how
// state is maintained when switching between different tabs (and thus branches
// and Navigators), as well as how to maintain a dynamic set of branches/tabs.

void main() {
  runApp(const NestedTabNavigationExampleApp());
}

/// An example demonstrating how to use nested navigators
class NestedTabNavigationExampleApp extends StatefulWidget {
  /// Creates a NestedTabNavigationExampleApp
  const NestedTabNavigationExampleApp({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => NestedTabNavigationExampleAppState();
}

/// An example demonstrating how to use dynamic nested navigators
class NestedTabNavigationExampleAppState
    extends State<NestedTabNavigationExampleApp> {
  final List<StatefulShellBranch> _branches = <StatefulShellBranch>[
    StatefulShellBranch(rootLocation: '/home', name: 'Home'),
    StatefulShellBranch(rootLocation: '/a/0', name: 'Dynamic 0'),
  ];

  void _addSection(StatefulShellRouteState shellRouteState) => setState(() {
        if (_branches.length < 10) {
          final int index = _branches.length - 1;
          _branches.add(StatefulShellBranch(
              rootLocation: '/a/$index', name: 'Dynamic $index'));
          // In situations where setState isn't possible, you can call refresh() on
          // StatefulShellRouteState instead, to refresh the branches
          //shellRouteState.refresh();
        }
      });

  void _removeSection(StatefulShellRouteState shellRouteState) {
    if (_branches.length > 2) {
      _branches.removeLast();
      // In situations where setState isn't possible, you can call refresh() on
      // StatefulShellRouteState instead, to refresh the branches
      shellRouteState.refresh();
    }
  }

  late final GoRouter _router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/home',
    routes: <RouteBase>[
      StatefulShellRoute(
        branchBuilder: (_, __) => _branches,
        routes: <RouteBase>[
          GoRoute(
            path: '/home',
            builder: (BuildContext context, GoRouterState state) => RootScreen(
              label: 'Home',
              addSection: () => _addSection(StatefulShellRoute.of(context)),
              removeSection: () =>
                  _removeSection(StatefulShellRoute.of(context)),
            ),
          ),
          GoRoute(
            /// The screen to display as the root in the first tab of the
            /// bottom navigation bar.
            path: '/a/:id',
            builder: (BuildContext context, GoRouterState state) => RootScreen(
              label: 'A${state.params['id']}',
              detailsPath: '/a/${state.params['id']}/details',
            ),
            routes: <RouteBase>[
              /// The details screen to display stacked on navigator of the
              /// first tab. This will cover screen A but not the application
              /// shell (bottom navigation bar).
              GoRoute(
                path: 'details',
                builder: (BuildContext context, GoRouterState state) =>
                    DetailsScreen(label: 'A${state.params['id']}'),
              ),
            ],
          ),
        ],
        builder: (BuildContext context, GoRouterState state, Widget child) {
          return ScaffoldWithNavBar(body: child);
        },
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      routerConfig: _router,
    );
  }
}

/// Builds the "shell" for the app by building a Scaffold with a
/// BottomNavigationBar, where [child] is placed in the body of the Scaffold.
class ScaffoldWithNavBar extends StatelessWidget {
  /// Constructs an [ScaffoldWithNavBar].
  const ScaffoldWithNavBar({
    required this.body,
    Key? key,
  }) : super(key: key ?? const ValueKey<String>('ScaffoldWithNavBar'));

  /// Body, i.e. the index stack
  final Widget body;

  List<BottomNavigationBarItem> _items(
      List<StatefulShellBranchState> branches) {
    return branches.mapIndexed((int i, StatefulShellBranchState e) {
      if (i == 0) {
        return BottomNavigationBarItem(
            icon: const Icon(Icons.home), label: e.branch.name);
      } else {
        return BottomNavigationBarItem(
            icon: const Icon(Icons.star), label: e.branch.name);
      }
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final StatefulShellRouteState shellState = StatefulShellRoute.of(context);
    return Scaffold(
      body: body,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: _items(shellState.branchStates),
        currentIndex: shellState.currentIndex,
        onTap: (int tappedIndex) => shellState.goBranch(index: tappedIndex),
      ),
    );
  }
}

/// Widget for the root/initial pages in the bottom navigation bar.
class RootScreen extends StatelessWidget {
  /// Creates a RootScreen
  const RootScreen({
    required this.label,
    this.detailsPath,
    this.addSection,
    this.removeSection,
    Key? key,
  }) : super(key: key);

  /// The label
  final String label;

  /// The path to the detail page
  final String? detailsPath;

  /// Function for adding a new branch
  final VoidCallback? addSection;

  /// Function for removing a branch
  final VoidCallback? removeSection;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Section - $label'),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text('Screen $label',
                style: Theme.of(context).textTheme.titleLarge),
            const Padding(padding: EdgeInsets.all(4)),
            if (detailsPath != null)
              TextButton(
                onPressed: () {
                  GoRouter.of(context).go(detailsPath!);
                },
                child: const Text('View details'),
              ),
            if (addSection != null && removeSection != null)
              ..._actions(context),
          ],
        ),
      ),
    );
  }

  List<Widget> _actions(BuildContext context) {
    return <Widget>[
      const Padding(padding: EdgeInsets.all(4)),
      TextButton(
        onPressed: addSection,
        child: const Text('Add section'),
      ),
      const Padding(padding: EdgeInsets.all(4)),
      TextButton(
        onPressed: removeSection,
        child: const Text('Remove section'),
      ),
    ];
  }
}

/// The details screen for either the A or B screen.
class DetailsScreen extends StatefulWidget {
  /// Constructs a [DetailsScreen].
  const DetailsScreen({
    required this.label,
    this.param,
    Key? key,
  }) : super(key: key);

  /// The label to display in the center of the screen.
  final String label;

  /// Optional param
  final String? param;

  @override
  State<StatefulWidget> createState() => DetailsScreenState();
}

/// The state for DetailsScreen
class DetailsScreenState extends State<DetailsScreen> {
  int _counter = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Details Screen - ${widget.label}'),
      ),
      body: _build(context),
    );
  }

  Widget _build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text('Details for ${widget.label} - Counter: $_counter',
              style: Theme.of(context).textTheme.titleLarge),
          const Padding(padding: EdgeInsets.all(4)),
          TextButton(
            onPressed: () {
              setState(() {
                _counter++;
              });
            },
            child: const Text('Increment counter'),
          ),
          const Padding(padding: EdgeInsets.all(8)),
          if (widget.param != null)
            Text('Parameter: ${widget.param!}',
                style: Theme.of(context).textTheme.titleMedium),
          const Padding(padding: EdgeInsets.all(8)),
        ],
      ),
    );
  }
}
