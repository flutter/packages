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

// This example demonstrates how to setup nested navigation using a
// BottomNavigationBar, where each tab uses its own persistent navigator, i.e.
// navigation state is maintained separately for each tab. This setup also
// enables deep linking into nested pages.
//
// This example demonstrates how to display routes within a StatefulShellRoute,
// that are places on separate navigators. The example also demonstrates how
// state is maintained when switching between different tabs (and thus branches
// and Navigators).

void main() {
  runApp(NestedTabNavigationExampleApp());
}

/// An example demonstrating how to use nested navigators
class NestedTabNavigationExampleApp extends StatelessWidget {
  /// Creates a NestedTabNavigationExampleApp
  NestedTabNavigationExampleApp({super.key});

  final GoRouter _router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/a',
    routes: <RouteBase>[
      GoRoute(
        path: '/modal',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (BuildContext context, GoRouterState state) =>
            const ModalScreen(),
      ),
      StackedShellRoute(
        branches: <StatefulShellBranch>[
          /// The route branch for the first tab of the bottom navigation bar.
          StatefulShellBranch(
            navigatorKey: _tabANavigatorKey,
            routes: <RouteBase>[
              GoRoute(
                /// The screen to display as the root in the first tab of the
                /// bottom navigation bar.
                path: '/a',
                builder: (BuildContext context, GoRouterState state) =>
                    const RootScreen(label: 'A', detailsPath: '/a/details'),
                routes: <RouteBase>[
                  /// The details screen to display stacked on navigator of the
                  /// first tab. This will cover screen A but not the application
                  /// shell (bottom navigation bar).
                  GoRoute(
                    path: 'details',
                    builder: (BuildContext context, GoRouterState state) =>
                        DetailsScreen(label: 'A', extra: state.extra),
                  ),
                ],
              ),
            ],
          ),

          /// The route branch for the second tab of the bottom navigation bar.
          StatefulShellBranch(
            /// It's not necessary to provide a navigatorKey if it isn't also
            /// needed elsewhere. If not provided, a default key will be used.
            // navigatorKey: _tabBNavigatorKey,
            routes: <RouteBase>[
              GoRoute(
                /// The screen to display as the root in the second tab of the
                /// bottom navigation bar.
                path: '/b',
                builder: (BuildContext context, GoRouterState state) =>
                    const RootScreen(
                  label: 'B',
                  detailsPath: '/b/details/1',
                  secondDetailsPath: '/b/details/2',
                ),
                routes: <RouteBase>[
                  GoRoute(
                    path: 'details/:param',
                    builder: (BuildContext context, GoRouterState state) =>
                        DetailsScreen(
                      label: 'B',
                      param: state.pathParameters['param'],
                      extra: state.extra,
                    ),
                  ),
                ],
              ),
            ],
          ),

          /// The route branch for the third tab of the bottom navigation bar.
          StatefulShellBranch(
            /// StatefulShellBranch will automatically use the first descendant
            /// GoRoute as the initial location of the branch. If another route
            /// is desired, specify the location of it using the defaultLocation
            /// parameter.
            // defaultLocation: '/c2',
            routes: <RouteBase>[
              StatefulShellRoute(
                /// This bottom tab uses a nested shell, wrapping sub routes in a
                /// top TabBar.
                branches: <StatefulShellBranch>[
                  StatefulShellBranch(routes: <GoRoute>[
                    GoRoute(
                      path: '/c1',
                      builder: (BuildContext context, GoRouterState state) =>
                          const TabScreen(
                              label: 'C1', detailsPath: '/c1/details'),
                      routes: <RouteBase>[
                        GoRoute(
                          path: 'details',
                          builder:
                              (BuildContext context, GoRouterState state) =>
                                  DetailsScreen(
                            label: 'C1',
                            extra: state.extra,
                            withScaffold: false,
                          ),
                        ),
                      ],
                    ),
                  ]),
                  StatefulShellBranch(routes: <GoRoute>[
                    GoRoute(
                      path: '/c2',
                      builder: (BuildContext context, GoRouterState state) =>
                          const TabScreen(
                              label: 'C2', detailsPath: '/c2/details'),
                      routes: <RouteBase>[
                        GoRoute(
                          path: 'details',
                          builder:
                              (BuildContext context, GoRouterState state) =>
                                  DetailsScreen(
                            label: 'C2',
                            extra: state.extra,
                            withScaffold: false,
                          ),
                        ),
                      ],
                    ),
                  ]),
                ],
                builder: (BuildContext context, GoRouterState state,
                    StatefulNavigationShell navigationShell) {
                  /// This nested StatefulShellRoute demonstrates the use of a
                  /// custom container (TabBarView) for the branch Navigators.
                  /// In this implementation, no customization is done in the
                  /// builder function (navigationShell itself is simply used as
                  /// the Widget for the route). Instead, the
                  /// navigatorContainerBuilder function below is provided to
                  /// customize the container for the branch Navigators.
                  return navigationShell;
                },
                navigatorContainerBuilder: (BuildContext context,
                        StatefulNavigationShell navigationShell,
                        List<Widget> children) =>

                    /// Returning a customized container for the branch
                    /// Navigators (i.e. the `List<Widget> children` argument).
                    ///
                    /// See TabbedRootScreen for more details on how the children
                    /// are used in the TabBarView.
                    TabbedRootScreen(
                        navigationShell: navigationShell, children: children),
              ),
            ],
          ),
        ],
        builder: (BuildContext context, GoRouterState state,
            StatefulNavigationShell navigationShell) {
          /// This builder implementation uses the default container for the
          /// branch Navigators (provided in through the `child` argument). This
          /// is the simplest way to use StatefulShellRoute, where the shell is
          /// built around the Navigator container (see ScaffoldWithNavBar).
          return ScaffoldWithNavBar(navigationShell: navigationShell);
        },

        /// If it's necessary to customize the Page for StatefulShellRoute,
        /// provide a pageBuilder function instead of the builder, for example:
        // pageBuilder: (BuildContext context, GoRouterState state,
        //             StatefulNavigationShell navigationShell) {
        //   return NoTransitionPage<dynamic>(
        //       child: ScaffoldWithNavBar(navigationShell: navigationShell));
        // },
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
        /// Here, the items of BottomNavigationBar are hard coded. In a real
        /// world scenario, the items would most likely be generated from the
        /// branches of the shell route, which can be fetched using
        /// `navigationShell.route.branches`.
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Section A'),
          BottomNavigationBarItem(icon: Icon(Icons.work), label: 'Section B'),
          BottomNavigationBarItem(icon: Icon(Icons.tab), label: 'Section C'),
        ],
        currentIndex: navigationShell.currentIndex,
        onTap: (int index) => _onTap(context, index),
      ),
    );
  }

  void _onTap(BuildContext context, int index) {
    // Navigate to the current location of branch at the provided index. If
    // tapping the bar item for the current branch, go to the initial location
    // instead.
    if (index == navigationShell.currentIndex) {
      GoRouter.of(context)
          .go(navigationShell.effectiveInitialBranchLocation(index));
    } else {
      navigationShell.goBranch(index);
    }
  }
}

/// Widget for the root/initial pages in the bottom navigation bar.
class RootScreen extends StatelessWidget {
  /// Creates a RootScreen
  const RootScreen(
      {required this.label,
      required this.detailsPath,
      this.secondDetailsPath,
      super.key});

  /// The label
  final String label;

  /// The path to the detail page
  final String detailsPath;

  /// The path to another detail page
  final String? secondDetailsPath;

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
            const Padding(padding: EdgeInsets.all(4)),
            if (secondDetailsPath != null)
              TextButton(
                onPressed: () {
                  GoRouter.of(context).go(secondDetailsPath!);
                },
                child: const Text('View more details'),
              ),
            const Padding(padding: EdgeInsets.all(8)),
            ElevatedButton(
              onPressed: () {
                GoRouter.of(context).push('/modal');
              },
              child: const Text('Show modal screen on ROOT navigator'),
            ),
            const Padding(padding: EdgeInsets.all(4)),
            ElevatedButton(
              onPressed: () {
                showModalBottomSheet(
                    context: context,
                    useRootNavigator: true,
                    builder: _bottomSheet);
              },
              child: const Text('Show bottom sheet on ROOT navigator'),
            ),
            const Padding(padding: EdgeInsets.all(4)),
            ElevatedButton(
              onPressed: () {
                showModalBottomSheet(
                    context: context,
                    useRootNavigator: false,
                    builder: _bottomSheet);
              },
              child: const Text('Show bottom sheet on CURRENT navigator'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bottomSheet(BuildContext context) {
    return Container(
      height: 200,
      color: Colors.amber,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Text('Modal BottomSheet'),
            ElevatedButton(
              child: const Text('Close BottomSheet'),
              onPressed: () => Navigator.pop(context),
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
class DetailsScreenState extends State<DetailsScreen> {
  int _counter = 0;

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

/// Widget for a modal screen.
class ModalScreen extends StatelessWidget {
  /// Creates a ModalScreen
  const ModalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Modal'),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text('Modal screen', style: Theme.of(context).textTheme.titleLarge),
            const Padding(padding: EdgeInsets.all(8)),
            ElevatedButton(
              onPressed: () {
                GoRouter.of(context).go('/a');
              },
              child: const Text('Go to initial section'),
            ),
          ],
        ),
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
