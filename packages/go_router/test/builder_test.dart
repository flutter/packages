// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/src/builder.dart';
import 'package:go_router/src/configuration.dart';
import 'package:go_router/src/match.dart';
import 'package:go_router/src/router.dart';

import 'test_helpers.dart';

void main() {
  group('RouteBuilder', () {
    testWidgets('Builds GoRoute', (WidgetTester tester) async {
      final RouteConfiguration config = RouteConfiguration(
        routes: <RouteBase>[
          GoRoute(
            path: '/',
            builder: (BuildContext context, GoRouterState state) {
              return _DetailsScreen();
            },
          ),
        ],
        redirectLimit: 10,
        topRedirect: (BuildContext context, GoRouterState state) {
          return null;
        },
        navigatorKey: GlobalKey<NavigatorState>(),
      );

      final RouteMatchList matches = RouteMatchList(
          matches: <RouteMatch>[
            RouteMatch(
              route: config.routes.first as GoRoute,
              matchedLocation: '/',
              pageKey: const ValueKey<String>('/'),
            ),
          ],
          uri: Uri.parse('/'),
          pathParameters: const <String, String>{});

      await tester.pumpWidget(
        _BuilderTestWidget(
          routeConfiguration: config,
          matches: matches,
        ),
      );

      expect(find.byType(_DetailsScreen), findsOneWidget);
    });

    testWidgets('Builds ShellRoute', (WidgetTester tester) async {
      final RouteConfiguration config = RouteConfiguration(
        routes: <RouteBase>[
          ShellRoute(
              builder:
                  (BuildContext context, GoRouterState state, Widget child) {
                return _DetailsScreen();
              },
              routes: <GoRoute>[
                GoRoute(
                  path: '/',
                  builder: (BuildContext context, GoRouterState state) {
                    return _DetailsScreen();
                  },
                ),
              ]),
        ],
        redirectLimit: 10,
        topRedirect: (BuildContext context, GoRouterState state) {
          return null;
        },
        navigatorKey: GlobalKey<NavigatorState>(),
      );

      final RouteMatchList matches = RouteMatchList(
        matches: <RouteMatch>[
          createRouteMatch(config.routes.first, '/'),
          createRouteMatch(config.routes.first.routes.first, '/'),
        ],
        uri: Uri.parse('/'),
        pathParameters: const <String, String>{},
      );

      await tester.pumpWidget(
        _BuilderTestWidget(
          routeConfiguration: config,
          matches: matches,
        ),
      );

      expect(find.byType(_DetailsScreen), findsOneWidget);
    });

    testWidgets('Uses the correct navigatorKey', (WidgetTester tester) async {
      final GlobalKey<NavigatorState> rootNavigatorKey =
          GlobalKey<NavigatorState>();
      final RouteConfiguration config = RouteConfiguration(
        navigatorKey: rootNavigatorKey,
        routes: <RouteBase>[
          GoRoute(
            path: '/',
            builder: (BuildContext context, GoRouterState state) {
              return _DetailsScreen();
            },
          ),
        ],
        redirectLimit: 10,
        topRedirect: (BuildContext context, GoRouterState state) {
          return null;
        },
      );

      final RouteMatchList matches = RouteMatchList(
          matches: <RouteMatch>[
            RouteMatch(
              route: config.routes.first as GoRoute,
              matchedLocation: '/',
              pageKey: const ValueKey<String>('/'),
            ),
          ],
          uri: Uri.parse('/'),
          pathParameters: const <String, String>{});

      await tester.pumpWidget(
        _BuilderTestWidget(
          routeConfiguration: config,
          matches: matches,
        ),
      );

      expect(find.byKey(rootNavigatorKey), findsOneWidget);
    });

    testWidgets('Builds a Navigator for ShellRoute',
        (WidgetTester tester) async {
      final GlobalKey<NavigatorState> rootNavigatorKey =
          GlobalKey<NavigatorState>(debugLabel: 'root');
      final GlobalKey<NavigatorState> shellNavigatorKey =
          GlobalKey<NavigatorState>(debugLabel: 'shell');
      final RouteConfiguration config = RouteConfiguration(
        navigatorKey: rootNavigatorKey,
        routes: <RouteBase>[
          ShellRoute(
            builder: (BuildContext context, GoRouterState state, Widget child) {
              return _HomeScreen(
                child: child,
              );
            },
            navigatorKey: shellNavigatorKey,
            routes: <RouteBase>[
              GoRoute(
                path: '/details',
                builder: (BuildContext context, GoRouterState state) {
                  return _DetailsScreen();
                },
              ),
            ],
          ),
        ],
        redirectLimit: 10,
        topRedirect: (BuildContext context, GoRouterState state) {
          return null;
        },
      );

      final RouteMatchList matches = RouteMatchList(
          matches: <RouteMatch>[
            RouteMatch(
              route: config.routes.first,
              matchedLocation: '',
              pageKey: const ValueKey<String>(''),
            ),
            RouteMatch(
              route: config.routes.first.routes.first,
              matchedLocation: '/details',
              pageKey: const ValueKey<String>('/details'),
            ),
          ],
          uri: Uri.parse('/details'),
          pathParameters: const <String, String>{});

      await tester.pumpWidget(
        _BuilderTestWidget(
          routeConfiguration: config,
          matches: matches,
        ),
      );

      expect(find.byType(_HomeScreen, skipOffstage: false), findsOneWidget);
      expect(find.byType(_DetailsScreen), findsOneWidget);
      expect(find.byKey(rootNavigatorKey), findsOneWidget);
      expect(find.byKey(shellNavigatorKey), findsOneWidget);
    });

    testWidgets('Builds a Navigator for ShellRoute with parentNavigatorKey',
        (WidgetTester tester) async {
      final GlobalKey<NavigatorState> rootNavigatorKey =
          GlobalKey<NavigatorState>(debugLabel: 'root');
      final GlobalKey<NavigatorState> shellNavigatorKey =
          GlobalKey<NavigatorState>(debugLabel: 'shell');
      final RouteConfiguration config = RouteConfiguration(
        navigatorKey: rootNavigatorKey,
        routes: <RouteBase>[
          ShellRoute(
            builder: (BuildContext context, GoRouterState state, Widget child) {
              return _HomeScreen(
                child: child,
              );
            },
            navigatorKey: shellNavigatorKey,
            routes: <RouteBase>[
              GoRoute(
                path: '/a',
                builder: (BuildContext context, GoRouterState state) {
                  return _DetailsScreen();
                },
                routes: <RouteBase>[
                  GoRoute(
                    path: 'details',
                    builder: (BuildContext context, GoRouterState state) {
                      return _DetailsScreen();
                    },
                    // This screen should stack onto the root navigator.
                    parentNavigatorKey: rootNavigatorKey,
                  ),
                ],
              ),
            ],
          ),
        ],
        redirectLimit: 10,
        topRedirect: (BuildContext context, GoRouterState state) {
          return null;
        },
      );

      final RouteMatchList matches = RouteMatchList(
          matches: <RouteMatch>[
            RouteMatch(
              route: config.routes.first.routes.first as GoRoute,
              matchedLocation: '/a/details',
              pageKey: const ValueKey<String>('/a/details'),
            ),
          ],
          uri: Uri.parse('/a/details'),
          pathParameters: const <String, String>{});

      await tester.pumpWidget(
        _BuilderTestWidget(
          routeConfiguration: config,
          matches: matches,
        ),
      );

      // The Details screen should be visible, but the HomeScreen should be
      // offstage (underneath) the DetailsScreen.
      expect(find.byType(_HomeScreen), findsNothing);
      expect(find.byType(_DetailsScreen), findsOneWidget);
    });

    testWidgets('Uses the correct restorationScopeId for ShellRoute',
        (WidgetTester tester) async {
      final GlobalKey<NavigatorState> rootNavigatorKey =
          GlobalKey<NavigatorState>(debugLabel: 'root');
      final GlobalKey<NavigatorState> shellNavigatorKey =
          GlobalKey<NavigatorState>(debugLabel: 'shell');
      final RouteConfiguration config = RouteConfiguration(
        navigatorKey: rootNavigatorKey,
        routes: <RouteBase>[
          ShellRoute(
            builder: (BuildContext context, GoRouterState state, Widget child) {
              return _HomeScreen(child: child);
            },
            navigatorKey: shellNavigatorKey,
            restorationScopeId: 'scope1',
            routes: <RouteBase>[
              GoRoute(
                path: '/a',
                builder: (BuildContext context, GoRouterState state) {
                  return _DetailsScreen();
                },
              ),
            ],
          ),
        ],
        redirectLimit: 10,
        topRedirect: (BuildContext context, GoRouterState state) {
          return null;
        },
      );

      final RouteMatchList matches = RouteMatchList(
        matches: <RouteMatch>[
          createRouteMatch(config.routes.first, ''),
          createRouteMatch(config.routes.first.routes.first, '/a'),
        ],
        uri: Uri.parse('/b'),
        pathParameters: const <String, String>{},
      );

      await tester.pumpWidget(
        _BuilderTestWidget(
          routeConfiguration: config,
          matches: matches,
        ),
      );

      expect(find.byKey(rootNavigatorKey), findsOneWidget);
      expect(find.byKey(shellNavigatorKey), findsOneWidget);
      expect(
          (shellNavigatorKey.currentWidget as Navigator?)?.restorationScopeId,
          'scope1');
    });

    testWidgets('Uses the correct restorationScopeId for StatefulShellRoute',
        (WidgetTester tester) async {
      final GlobalKey<NavigatorState> rootNavigatorKey =
          GlobalKey<NavigatorState>(debugLabel: 'root');
      final GlobalKey<NavigatorState> shellNavigatorKey =
          GlobalKey<NavigatorState>(debugLabel: 'shell');
      final GoRouter goRouter = GoRouter(
        initialLocation: '/a',
        navigatorKey: rootNavigatorKey,
        routes: <RouteBase>[
          StatefulShellRoute.indexedStack(
            restorationScopeId: 'shell',
            builder: (BuildContext context, GoRouterState state,
                    StatefulNavigationShell navigationShell) =>
                _HomeScreen(child: navigationShell),
            branches: <StatefulShellBranch>[
              StatefulShellBranch(
                navigatorKey: shellNavigatorKey,
                restorationScopeId: 'scope1',
                routes: <RouteBase>[
                  GoRoute(
                    path: '/a',
                    builder: (BuildContext context, GoRouterState state) {
                      return _DetailsScreen();
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      );

      await tester.pumpWidget(MaterialApp.router(
        routerConfig: goRouter,
      ));

      expect(find.byKey(rootNavigatorKey), findsOneWidget);
      expect(find.byKey(shellNavigatorKey), findsOneWidget);
      expect(
          (shellNavigatorKey.currentWidget as Navigator?)?.restorationScopeId,
          'scope1');
    });
  });
}

class _HomeScreen extends StatelessWidget {
  const _HomeScreen({
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          const Text('Home Screen'),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _DetailsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Text('Details Screen'),
    );
  }
}

class _BuilderTestWidget extends StatelessWidget {
  _BuilderTestWidget({
    required this.routeConfiguration,
    required this.matches,
  }) : builder = _routeBuilder(routeConfiguration);

  final RouteConfiguration routeConfiguration;
  final RouteBuilder builder;
  final RouteMatchList matches;

  /// Builds a [RouteBuilder] for tests
  static RouteBuilder _routeBuilder(RouteConfiguration configuration) {
    return RouteBuilder(
      configuration: configuration,
      builderWithNav: (
        BuildContext context,
        Widget child,
      ) {
        return child;
      },
      errorPageBuilder: (
        BuildContext context,
        GoRouterState state,
      ) {
        return MaterialPage<dynamic>(
          child: Text('Error: ${state.error}'),
        );
      },
      errorBuilder: (
        BuildContext context,
        GoRouterState state,
      ) {
        return Text('Error: ${state.error}');
      },
      restorationScopeId: null,
      observers: <NavigatorObserver>[],
      onPopPageWithRouteMatch: (_, __, ___) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: builder.tryBuild(context, matches, false,
          routeConfiguration.navigatorKey, <Page<Object?>, GoRouterState>{}),
    );
  }
}
