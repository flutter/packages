import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:side_navigation/side_navigation.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');
final GlobalKey<NavigatorState> _shellNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'shell');
final GlobalKey<NavigatorState> _internalNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'internal');

void main() {
  runApp(ShellRouteExampleAppForWeb());
}

/// An example demonstrating how to use [ShellRoute]
class ShellRouteExampleAppForWeb extends StatelessWidget {
  /// Creates a [ShellRouteExampleAppForWeb]
  ShellRouteExampleAppForWeb({super.key});

  final GoRouter _router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/a/d',
    debugLogDiagnostics: true,
    routes: <RouteBase>[
      /// Application shell
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (BuildContext context, GoRouterState state, Widget child) {
          return ScaffoldWithNavBar(child: child);
        },
        routes: <RouteBase>[
          GoRoute(
            path: '/a',
            builder: (BuildContext context, GoRouterState state) {
              return Container();
            },
            routes: <RouteBase>[
              ShellRoute(
                navigatorKey: _internalNavigatorKey,
                builder:
                    (BuildContext context, GoRouterState state, Widget child) {
                  return InternalScaffoldWithNavBar(child: child);
                },
                routes: <RouteBase>[
                  GoRoute(
                    path: 'd',
                    builder: (BuildContext context, GoRouterState state) {
                      return const Screen(
                        label: "D (Sub Menu of A)",
                        dynamicRoute: '/a/d/details',
                      );
                    },
                    routes: <RouteBase>[
                      GoRoute(
                        path: 'details',
                        builder: (BuildContext context, GoRouterState state) {
                          return const DetailsScreen(label: 'D');
                        },
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'e',
                    builder: (BuildContext context, GoRouterState state) {
                      return const Screen(
                        label: "E (Sub Menu of A)",
                        dynamicRoute: '/a/e/details',
                      );
                    },
                    routes: <RouteBase>[
                      GoRoute(
                        path: 'details',
                        parentNavigatorKey: _shellNavigatorKey,
                        builder: (BuildContext context, GoRouterState state) {
                          return const DetailsScreen(label: 'E');
                        },
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'f',
                    builder: (BuildContext context, GoRouterState state) {
                      return const Screen(
                        label: "F (Sub Menu of A)",
                        dynamicRoute: '/a/f/details',
                      );
                    },
                    routes: <RouteBase>[
                      GoRoute(
                        path: 'details',
                        parentNavigatorKey: _rootNavigatorKey,
                        builder: (BuildContext context, GoRouterState state) {
                          return const DetailsScreen(label: 'F');
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          GoRoute(
            path: '/b',
            builder: (BuildContext context, GoRouterState state) {
              return const Screen(
                label: "Menu B",
                dynamicRoute: '/b/details',
              );
            },
            routes: <RouteBase>[
              GoRoute(
                path: 'details',
                builder: (BuildContext context, GoRouterState state) {
                  return const DetailsScreen(label: 'B');
                },
              ),
            ],
          ),
          GoRoute(
            path: '/c',
            builder: (BuildContext context, GoRouterState state) {
              return const Screen(
                label: "Menu C",
                dynamicRoute: '/c/details',
              );
            },
            routes: <RouteBase>[
              GoRoute(
                path: 'details',
                parentNavigatorKey: _rootNavigatorKey,
                builder: (BuildContext context, GoRouterState state) {
                  return const DetailsScreen(label: 'C');
                },
              ),
            ],
          ),
        ],
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

class ScaffoldWithNavBar extends StatelessWidget {
  /// Constructs an [ScaffoldWithNavBar].
  const ScaffoldWithNavBar({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          SideNavigationBar(
              selectedIndex: _calculateSelectedIndex(context),
              items: const [
                SideNavigationBarItem(
                  icon: Icons.dashboard,
                  label: 'Menu A',
                ),
                SideNavigationBarItem(
                  icon: Icons.dashboard,
                  label: 'Menu B',
                ),
                SideNavigationBarItem(
                  icon: Icons.dashboard,
                  label: 'Menu C',
                ),
              ],
              onTap: (int idx) => _onItemTapped(idx, context)),
          Container(
            height: MediaQuery.of(context).size.height,
            width: 2,
            color: Colors.black12,
          ),
          Expanded(
            child: child,
          )
        ],
      ),
    );
  }

  static int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/a')) {
      return 0;
    }
    if (location.startsWith('/b')) {
      return 1;
    }
    if (location.startsWith('/c')) {
      return 2;
    }
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        GoRouter.of(context).go('/a/d');
      case 1:
        GoRouter.of(context).go('/b');
      case 2:
        GoRouter.of(context).go('/c');
    }
  }
}

class InternalScaffoldWithNavBar extends StatelessWidget {
  const InternalScaffoldWithNavBar({
    required this.child,
    super.key,
  });
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          SideNavigationBar(
              selectedIndex: _calculateInternalSelectedIndex(context),
              items: const [
                SideNavigationBarItem(
                  icon: Icons.dashboard,
                  label: 'D (Sub Menu of A)',
                ),
                SideNavigationBarItem(
                  icon: Icons.dashboard,
                  label: 'E (Sub Menu of A)',
                ),
                SideNavigationBarItem(
                  icon: Icons.dashboard,
                  label: 'F (Sub Menu of A)',
                ),
              ],
              onTap: (int idx) => _onInternalItemTapped(idx, context)),
          Container(
            height: MediaQuery.of(context).size.height,
            width: 2,
            color: Colors.black12,
          ),
          Expanded(
            child: child,
          )
        ],
      ),
    );
  }

  static int _calculateInternalSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/a/d')) {
      return 0;
    }
    if (location.startsWith('/a/e')) {
      return 1;
    }
    if (location.startsWith('/a/f')) {
      return 2;
    }
    return 0;
  }

  void _onInternalItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        GoRouter.of(context).go('/a/d');
      case 1:
        GoRouter.of(context).go('/a/e');
      case 2:
        GoRouter.of(context).go('/a/f');
    }
  }
}

class Screen extends StatelessWidget {
  /// Constructs a [ScreenA] widget.
  const Screen({super.key, required this.label, required this.dynamicRoute});
  final String label;
  final String dynamicRoute;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text('Screen $label'),
            TextButton(
              onPressed: () {
                GoRouter.of(context).go(dynamicRoute);
              },
              child: Text('View $label details'),
            ),
          ],
        ),
      ),
    );
  }
}

/// The details screen for either the A, B or C screen.
class DetailsScreen extends StatelessWidget {
  /// Constructs a [DetailsScreen].
  const DetailsScreen({
    required this.label,
    super.key,
  });

  /// The label to display in the center of the screen.
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 400,
      color: Colors.red,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Details Screen'),
        ),
        body: Center(
          child: Text(
            'Details for $label',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        ),
      ),
    );
  }
}
