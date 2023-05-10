// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');
final GlobalKey<NavigatorState> _tabANavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'tabANav');

void main() => runApp(RestorableStatefulShellRouteExampleApp());

/// An example demonstrating how to use StatefulShellRoute with state
/// restoration.
class RestorableStatefulShellRouteExampleApp extends StatelessWidget {
  /// Creates a NestedTabNavigationExampleApp
  RestorableStatefulShellRouteExampleApp({super.key});

  final GoRouter _router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/a',
    restorationScopeId: 'router',
    routes: <RouteBase>[
      StackedShellRoute(
        restorationScopeId: 'shell1',
        branches: <StatefulShellBranch>[
          // The route branch for the first tab of the bottom navigation bar.
          StatefulShellBranch(
            navigatorKey: _tabANavigatorKey,
            restorationScopeId: 'branchA',
            routes: <RouteBase>[
              GoRoute(
                // The screen to display as the root in the first tab of the
                // bottom navigation bar.
                path: '/a',
                pageBuilder: (BuildContext context, GoRouterState state) =>
                    const MaterialPage<void>(
                        restorationId: 'screenA',
                        child:
                            RootScreen(label: 'A', detailsPath: '/a/details')),
                routes: <RouteBase>[
                  // The details screen to display stacked on navigator of the
                  // first tab. This will cover screen A but not the application
                  // shell (bottom navigation bar).
                  GoRoute(
                    path: 'details',
                    pageBuilder: (BuildContext context, GoRouterState state) =>
                        MaterialPage<void>(
                            restorationId: 'screenADetail',
                            child:
                                DetailsScreen(label: 'A', extra: state.extra)),
                  ),
                ],
              ),
            ],
          ),

          // The route branch for the third tab of the bottom navigation bar.
          StatefulShellBranch(
            restorationScopeId: 'branchB',
            routes: <RouteBase>[
              StatefulShellRoute(
                restorationScopeId: 'shell2',

                // This bottom tab uses a nested shell, wrapping sub routes in a
                // top TabBar.
                branches: <StatefulShellBranch>[
                  StatefulShellBranch(
                      restorationScopeId: 'branchB1',
                      routes: <GoRoute>[
                        GoRoute(
                          path: '/b1',
                          pageBuilder:
                              (BuildContext context, GoRouterState state) =>
                                  const MaterialPage<void>(
                                      restorationId: 'screenB1',
                                      child: TabScreen(
                                          label: 'B1',
                                          detailsPath: '/b1/details')),
                          routes: <RouteBase>[
                            GoRoute(
                              path: 'details',
                              pageBuilder:
                                  (BuildContext context, GoRouterState state) =>
                                      MaterialPage<void>(
                                          restorationId: 'screenB1Detail',
                                          child: DetailsScreen(
                                            label: 'B1',
                                            extra: state.extra,
                                            withScaffold: false,
                                          )),
                            ),
                          ],
                        ),
                      ]),
                  StatefulShellBranch(
                      restorationScopeId: 'branchB2',
                      routes: <GoRoute>[
                        GoRoute(
                          path: '/b2',
                          pageBuilder:
                              (BuildContext context, GoRouterState state) =>
                                  const MaterialPage<void>(
                                      restorationId: 'screenB2',
                                      child: TabScreen(
                                          label: 'B2',
                                          detailsPath: '/b2/details')),
                          routes: <RouteBase>[
                            GoRoute(
                              path: 'details',
                              pageBuilder:
                                  (BuildContext context, GoRouterState state) =>
                                      MaterialPage<void>(
                                          restorationId: 'screenB2Detail',
                                          child: DetailsScreen(
                                            label: 'B2',
                                            extra: state.extra,
                                            withScaffold: false,
                                          )),
                            ),
                          ],
                        ),
                      ]),
                ],
                pageBuilder: (BuildContext context, GoRouterState state,
                    StatefulNavigationShell navigationShell) {
                  return MaterialPage<void>(
                      restorationId: 'shellWidget2', child: navigationShell);
                },
                navigatorContainerBuilder: (BuildContext context,
                        StatefulNavigationShell navigationShell,
                        List<Widget> children) =>

                    // Returning a customized container for the branch
                    // Navigators (i.e. the `List<Widget> children` argument).
                    //
                    // See TabbedRootScreen for more details on how the children
                    // are used in the TabBarView.
                    TabbedRootScreen(
                        navigationShell: navigationShell, children: children),
              ),
            ],
          ),
        ],
        pageBuilder: (BuildContext context, GoRouterState state,
            StatefulNavigationShell navigationShell) {
          return MaterialPage<void>(
              restorationId: 'shellWidget1',
              child: ScaffoldWithNavBar(navigationShell: navigationShell));
        },
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      restorationScopeId: 'app',
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
    required this.navigationShell,
    Key? key,
  }) : super(key: key ?? const ValueKey<String>('ScaffoldWithNavBar'));

  /// The navigation shell and container for the branch Navigators.
  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Section A'),
          BottomNavigationBarItem(icon: Icon(Icons.work), label: 'Section B'),
        ],
        currentIndex: navigationShell.currentIndex,
        onTap: (int tappedIndex) => navigationShell.goBranch(tappedIndex),
      ),
    );
  }
}

/// Widget for the root/initial pages in the bottom navigation bar.
class RootScreen extends StatelessWidget {
  /// Creates a RootScreen
  const RootScreen({
    required this.label,
    required this.detailsPath,
    super.key,
  });

  /// The label
  final String label;

  /// The path to the detail page
  final String detailsPath;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tab root - $label'),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text('Screen $label',
                style: Theme.of(context).textTheme.titleLarge),
            const Padding(padding: EdgeInsets.all(4)),
            TextButton(
              onPressed: () {
                GoRouter.of(context).go(detailsPath, extra: '$label-XYZ');
              },
              child: const Text('View details'),
            ),
          ],
        ),
      ),
    );
  }
}

/// The details screen for either the A or B screen.
class DetailsScreen extends StatefulWidget {
  /// Constructs a [DetailsScreen].
  const DetailsScreen({
    required this.label,
    this.param,
    this.extra,
    this.withScaffold = true,
    super.key,
  });

  /// The label to display in the center of the screen.
  final String label;

  /// Optional param
  final String? param;

  /// Optional extra object
  final Object? extra;

  /// Wrap in scaffold
  final bool withScaffold;

  @override
  State<StatefulWidget> createState() => DetailsScreenState();
}

/// The state for DetailsScreen
class DetailsScreenState extends State<DetailsScreen> with RestorationMixin {
  final RestorableInt _counter = RestorableInt(0);

  @override
  String? get restorationId => 'DetailsScreen-${widget.label}';

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(_counter, 'counter');
  }

  @override
  void dispose() {
    super.dispose();
    _counter.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.withScaffold) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Details Screen - ${widget.label}'),
        ),
        body: _build(context),
      );
    } else {
      return Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: _build(context),
      );
    }
  }

  Widget _build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text('Details for ${widget.label} - Counter: ${_counter.value}',
              style: Theme.of(context).textTheme.titleLarge),
          const Padding(padding: EdgeInsets.all(4)),
          TextButton(
            onPressed: () {
              setState(() {
                _counter.value++;
              });
            },
            child: const Text('Increment counter'),
          ),
          const Padding(padding: EdgeInsets.all(8)),
          if (widget.param != null)
            Text('Parameter: ${widget.param!}',
                style: Theme.of(context).textTheme.titleMedium),
          const Padding(padding: EdgeInsets.all(8)),
          if (widget.extra != null)
            Text('Extra: ${widget.extra!}',
                style: Theme.of(context).textTheme.titleMedium),
          if (!widget.withScaffold) ...<Widget>[
            const Padding(padding: EdgeInsets.all(16)),
            TextButton(
              onPressed: () {
                GoRouter.of(context).pop();
              },
              child: const Text('< Back',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            ),
          ]
        ],
      ),
    );
  }
}

/// Builds a nested shell using a [TabBar] and [TabBarView].
class TabbedRootScreen extends StatefulWidget {
  /// Constructs a TabbedRootScreen
  const TabbedRootScreen(
      {required this.navigationShell, required this.children, super.key});

  /// The current state of the parent StatefulShellRoute.
  final StatefulNavigationShell navigationShell;

  /// The children (Navigators) to display in the [TabBarView].
  final List<Widget> children;

  @override
  State<StatefulWidget> createState() => _TabbedRootScreenState();
}

class _TabbedRootScreenState extends State<TabbedRootScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController = TabController(
      length: widget.children.length,
      vsync: this,
      initialIndex: widget.navigationShell.currentIndex);

  @override
  void didUpdateWidget(covariant TabbedRootScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    _tabController.index = widget.navigationShell.currentIndex;
  }

  @override
  Widget build(BuildContext context) {
    final List<Tab> tabs = widget.children
        .mapIndexed((int i, _) => Tab(text: 'Tab ${i + 1}'))
        .toList();

    return Scaffold(
      appBar: AppBar(
          title: const Text('Tab root'),
          bottom: TabBar(
            controller: _tabController,
            tabs: tabs,
            onTap: (int tappedIndex) => _onTabTap(context, tappedIndex),
          )),
      body: TabBarView(
        controller: _tabController,
        children: widget.children,
      ),
    );
  }

  void _onTabTap(BuildContext context, int index) {
    widget.navigationShell.goBranch(index);
  }
}

/// Widget for the pages in the top tab bar.
class TabScreen extends StatelessWidget {
  /// Creates a RootScreen
  const TabScreen({required this.label, this.detailsPath, super.key});

  /// The label
  final String label;

  /// The path to the detail page
  final String? detailsPath;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text('Screen $label', style: Theme.of(context).textTheme.titleLarge),
          const Padding(padding: EdgeInsets.all(4)),
          if (detailsPath != null)
            TextButton(
              onPressed: () {
                GoRouter.of(context).go(detailsPath!);
              },
              child: const Text('View details'),
            ),
        ],
      ),
    );
  }
}
