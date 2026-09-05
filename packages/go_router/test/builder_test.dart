// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'test_helpers.dart';

void main() {
  group('RouteBuilder', () {
    testWidgets('Builds GoRoute', (WidgetTester tester) async {
      final RouteConfiguration config = createRouteConfiguration(
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

      final matches = RouteMatchList(
        matches: <RouteMatch>[
          RouteMatch(
            route: config.routes.first as GoRoute,
            matchedLocation: '/',
            pageKey: const ValueKey<String>('/'),
          ),
        ],
        uri: Uri.parse('/'),
        pathParameters: const <String, String>{},
      );

      await tester.pumpWidget(_BuilderTestWidget(routeConfiguration: config, matches: matches));

      expect(find.byType(_DetailsScreen), findsOneWidget);
    });

    testWidgets('Builds ShellRoute', (WidgetTester tester) async {
      final shellNavigatorKey = GlobalKey<NavigatorState>();
      final RouteConfiguration config = createRouteConfiguration(
        routes: <RouteBase>[
          ShellRoute(
            navigatorKey: shellNavigatorKey,
            builder: (BuildContext context, GoRouterState state, Widget child) {
              return _DetailsScreen();
            },
            routes: <GoRoute>[
              GoRoute(
                path: '/',
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
        navigatorKey: GlobalKey<NavigatorState>(),
      );

      final matches = RouteMatchList(
        matches: <RouteMatchBase>[
          ShellRouteMatch(
            route: config.routes.first as ShellRouteBase,
            matchedLocation: '',
            pageKey: const ValueKey<String>(''),
            navigatorKey: shellNavigatorKey,
            matches: <RouteMatchBase>[
              RouteMatch(
                route: config.routes.first.routes.first as GoRoute,
                matchedLocation: '/',
                pageKey: const ValueKey<String>('/'),
              ),
            ],
          ),
        ],
        uri: Uri.parse('/'),
        pathParameters: const <String, String>{},
      );

      await tester.pumpWidget(_BuilderTestWidget(routeConfiguration: config, matches: matches));

      expect(find.byType(_DetailsScreen), findsOneWidget);
    });

    testWidgets('Uses the correct navigatorKey', (WidgetTester tester) async {
      final rootNavigatorKey = GlobalKey<NavigatorState>();
      final RouteConfiguration config = createRouteConfiguration(
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

      final matches = RouteMatchList(
        matches: <RouteMatch>[
          RouteMatch(
            route: config.routes.first as GoRoute,
            matchedLocation: '/',
            pageKey: const ValueKey<String>('/'),
          ),
        ],
        uri: Uri.parse('/'),
        pathParameters: const <String, String>{},
      );

      await tester.pumpWidget(_BuilderTestWidget(routeConfiguration: config, matches: matches));

      expect(find.byKey(rootNavigatorKey), findsOneWidget);
    });

    testWidgets('Builds a Navigator for ShellRoute', (WidgetTester tester) async {
      final rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
      final shellNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'shell');
      final RouteConfiguration config = createRouteConfiguration(
        navigatorKey: rootNavigatorKey,
        routes: <RouteBase>[
          ShellRoute(
            builder: (BuildContext context, GoRouterState state, Widget child) {
              return _HomeScreen(child: child);
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

      final matches = RouteMatchList(
        matches: <RouteMatchBase>[
          ShellRouteMatch(
            route: config.routes.first as ShellRouteBase,
            matchedLocation: '',
            pageKey: const ValueKey<String>(''),
            navigatorKey: shellNavigatorKey,
            matches: <RouteMatchBase>[
              RouteMatch(
                route: config.routes.first.routes.first as GoRoute,
                matchedLocation: '/details',
                pageKey: const ValueKey<String>('/details'),
              ),
            ],
          ),
        ],
        uri: Uri.parse('/details'),
        pathParameters: const <String, String>{},
      );

      await tester.pumpWidget(_BuilderTestWidget(routeConfiguration: config, matches: matches));

      expect(find.byType(_HomeScreen, skipOffstage: false), findsOneWidget);
      expect(find.byType(_DetailsScreen), findsOneWidget);
      expect(find.byKey(rootNavigatorKey), findsOneWidget);
      expect(find.byKey(shellNavigatorKey), findsOneWidget);
    });

    testWidgets('Builds a Navigator for ShellRoute with parentNavigatorKey', (
      WidgetTester tester,
    ) async {
      final rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
      final shellNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'shell');
      final RouteConfiguration config = createRouteConfiguration(
        navigatorKey: rootNavigatorKey,
        routes: <RouteBase>[
          ShellRoute(
            builder: (BuildContext context, GoRouterState state, Widget child) {
              return _HomeScreen(child: child);
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

      final matches = RouteMatchList(
        matches: <RouteMatch>[
          RouteMatch(
            route: config.routes.first.routes.first as GoRoute,
            matchedLocation: '/a/details',
            pageKey: const ValueKey<String>('/a/details'),
          ),
        ],
        uri: Uri.parse('/a/details'),
        pathParameters: const <String, String>{},
      );

      await tester.pumpWidget(_BuilderTestWidget(routeConfiguration: config, matches: matches));

      // The Details screen should be visible, but the HomeScreen should be
      // offstage (underneath) the DetailsScreen.
      expect(find.byType(_HomeScreen), findsNothing);
      expect(find.byType(_DetailsScreen), findsOneWidget);
    });

    testWidgets('Uses the correct restorationScopeId for ShellRoute', (WidgetTester tester) async {
      final rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
      final shellNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'shell');
      final RouteConfiguration config = createRouteConfiguration(
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

      final matches = RouteMatchList(
        matches: <RouteMatchBase>[
          ShellRouteMatch(
            route: config.routes.first as ShellRouteBase,
            matchedLocation: '',
            pageKey: const ValueKey<String>(''),
            navigatorKey: shellNavigatorKey,
            matches: <RouteMatchBase>[
              RouteMatch(
                route: config.routes.first.routes.first as GoRoute,
                matchedLocation: '/a',
                pageKey: const ValueKey<String>('/a'),
              ),
            ],
          ),
        ],
        uri: Uri.parse('/b'),
        pathParameters: const <String, String>{},
      );

      await tester.pumpWidget(_BuilderTestWidget(routeConfiguration: config, matches: matches));

      expect(find.byKey(rootNavigatorKey), findsOneWidget);
      expect(find.byKey(shellNavigatorKey), findsOneWidget);
      expect((shellNavigatorKey.currentWidget as Navigator?)?.restorationScopeId, 'scope1');
    });

    testWidgets('Uses the correct restorationScopeId for StatefulShellRoute', (
      WidgetTester tester,
    ) async {
      final rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
      final shellNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'shell');
      final goRouter = GoRouter(
        initialLocation: '/a',
        navigatorKey: rootNavigatorKey,
        routes: <RouteBase>[
          StatefulShellRoute.indexedStack(
            restorationScopeId: 'shell',
            builder:
                (
                  BuildContext context,
                  GoRouterState state,
                  StatefulNavigationShell navigationShell,
                ) => _HomeScreen(child: navigationShell),
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
      addTearDown(goRouter.dispose);

      await tester.pumpWidget(MaterialApp.router(routerConfig: goRouter));

      expect(find.byKey(rootNavigatorKey), findsOneWidget);
      expect(find.byKey(shellNavigatorKey), findsOneWidget);
      expect((shellNavigatorKey.currentWidget as Navigator?)?.restorationScopeId, 'scope1');
    });

    testWidgets('GoRouter requestFocus defaults to true', (WidgetTester tester) async {
      final router = GoRouter(
        routes: <RouteBase>[
          GoRoute(
            path: '/',
            builder: (BuildContext context, GoRouterState state) =>
                const Scaffold(body: Center(child: Text('Home'))),
          ),
        ],
      );

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));

      addTearDown(() => router.dispose());

      final Navigator navigator = tester.widget<Navigator>(find.byType(Navigator));
      expect(navigator.requestFocus, isTrue);
    });

    testWidgets('GoRouter requestFocus can be set to false', (WidgetTester tester) async {
      final router = GoRouter(
        routes: <RouteBase>[
          GoRoute(
            path: '/',
            builder: (BuildContext context, GoRouterState state) =>
                const Scaffold(body: Center(child: Text('Home'))),
          ),
        ],
        requestFocus: false,
      );

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));

      addTearDown(() => router.dispose());

      final Navigator navigator = tester.widget<Navigator>(find.byType(Navigator));
      expect(navigator.requestFocus, isFalse);
    });

    group('Shell navigator semantics boundary', () {
      testWidgets('Chrome painted before a ShellRoute Navigator stays in the '
          'semantics tree alongside routed content', (WidgetTester tester) async {
        final SemanticsHandle semantics = tester.ensureSemantics();

        final router = GoRouter(
          initialLocation: '/a',
          routes: <RouteBase>[
            ShellRoute(
              builder: (BuildContext context, GoRouterState state, Widget child) {
                return Row(
                  children: <Widget>[
                    Semantics(
                      container: true,
                      label: 'chrome',
                      child: const SizedBox(width: 40, height: 40),
                    ),
                    Expanded(child: child),
                  ],
                );
              },
              routes: <RouteBase>[
                GoRoute(
                  path: '/a',
                  builder: (BuildContext context, GoRouterState state) {
                    return const Text('content-a');
                  },
                ),
                GoRoute(
                  path: '/b',
                  builder: (BuildContext context, GoRouterState state) {
                    return const Text('content-b');
                  },
                ),
              ],
            ),
          ],
        );
        addTearDown(router.dispose);

        await tester.pumpWidget(MaterialApp.router(routerConfig: router));
        await tester.pumpAndSettle();

        // Without the Semantics(container: true) wrap around the shell's
        // Navigator, the route's ModalBarrier (BlockSemantics) drops the
        // chrome painted before it, because a Navigator does not
        // establish a semantics boundary. See
        // https://github.com/flutter/flutter/issues/135656.
        expect(find.bySemanticsLabel('chrome'), findsOneWidget);
        expect(find.bySemanticsLabel('content-a'), findsOneWidget);

        // Navigation between two routes within the same shell keeps
        // working, and the chrome remains exposed after the rebuild.
        router.go('/b');
        await tester.pumpAndSettle();

        expect(find.bySemanticsLabel('chrome'), findsOneWidget);
        expect(find.bySemanticsLabel('content-b'), findsOneWidget);
        expect(find.bySemanticsLabel('content-a'), findsNothing);

        semantics.dispose();
      });

      testWidgets('ShellRoute Navigator is wrapped in a Semantics(container: true) '
          'boundary', (WidgetTester tester) async {
        final shellNavigatorKey = GlobalKey<NavigatorState>();
        final router = GoRouter(
          initialLocation: '/',
          routes: <RouteBase>[
            ShellRoute(
              navigatorKey: shellNavigatorKey,
              builder: (BuildContext context, GoRouterState state, Widget child) {
                return child;
              },
              routes: <RouteBase>[
                GoRoute(
                  path: '/',
                  builder: (BuildContext context, GoRouterState state) {
                    return const Text('content');
                  },
                ),
              ],
            ),
          ],
        );
        addTearDown(router.dispose);

        await tester.pumpWidget(MaterialApp.router(routerConfig: router));
        await tester.pumpAndSettle();

        final Iterable<Semantics> ancestorSemantics = tester.widgetList<Semantics>(
          find.ancestor(of: find.byKey(shellNavigatorKey), matching: find.byType(Semantics)),
        );
        expect(
          ancestorSemantics.first.container,
          isTrue,
          reason:
              'The nearest Semantics ancestor of the shell Navigator '
              'should be the container boundary added by go_router.',
        );
      });

      testWidgets('Root GoRouter Navigator is not wrapped in an extra Semantics '
          'container boundary', (WidgetTester tester) async {
        final rootNavigatorKey = GlobalKey<NavigatorState>();
        final router = GoRouter(
          navigatorKey: rootNavigatorKey,
          initialLocation: '/',
          routes: <RouteBase>[
            GoRoute(
              path: '/',
              builder: (BuildContext context, GoRouterState state) {
                return const Text('content');
              },
            ),
          ],
        );
        addTearDown(router.dispose);

        await tester.pumpWidget(MaterialApp.router(routerConfig: router));
        await tester.pumpAndSettle();

        // The root navigator has no earlier-painted siblings by
        // construction, so go_router must not add the shell-only
        // Semantics(container: true) wrap around it.
        final Finder wrapper = find.ancestor(
          of: find.byKey(rootNavigatorKey),
          matching: find.byWidgetPredicate(
            (Widget widget) => widget is Semantics && widget.container,
          ),
        );
        expect(wrapper, findsNothing);
      });

      testWidgets('Chrome painted before a StatefulShellRoute Navigator stays in the '
          'semantics tree alongside routed content', (WidgetTester tester) async {
        final SemanticsHandle semantics = tester.ensureSemantics();
        StatefulNavigationShell? navigationShell;

        final router = GoRouter(
          initialLocation: '/a',
          routes: <RouteBase>[
            StatefulShellRoute.indexedStack(
              builder: (BuildContext context, GoRouterState state, StatefulNavigationShell shell) {
                navigationShell = shell;
                return Column(
                  children: <Widget>[
                    Semantics(container: true, label: 'chrome', child: const SizedBox(height: 10)),
                    Expanded(child: shell),
                  ],
                );
              },
              branches: <StatefulShellBranch>[
                StatefulShellBranch(
                  routes: <RouteBase>[
                    GoRoute(
                      path: '/a',
                      builder: (BuildContext context, GoRouterState state) {
                        return const Text('content-a');
                      },
                    ),
                  ],
                ),
                StatefulShellBranch(
                  routes: <RouteBase>[
                    GoRoute(
                      path: '/b',
                      builder: (BuildContext context, GoRouterState state) {
                        return const Text('content-b');
                      },
                    ),
                  ],
                ),
              ],
            ),
          ],
        );
        addTearDown(router.dispose);

        await tester.pumpWidget(MaterialApp.router(routerConfig: router));
        await tester.pumpAndSettle();

        // Without the Semantics(container: true) wrap around the shell
        // branch's Navigator, the route's ModalBarrier (BlockSemantics)
        // drops the chrome painted before it, because a Navigator does not
        // establish a semantics boundary. See
        // https://github.com/flutter/flutter/issues/135656.
        expect(find.bySemanticsLabel('chrome'), findsOneWidget);
        expect(find.bySemanticsLabel('content-a'), findsOneWidget);

        // Switching branches keeps the chrome exposed after the rebuild.
        navigationShell!.goBranch(1);
        await tester.pumpAndSettle();

        expect(find.bySemanticsLabel('chrome'), findsOneWidget);
        expect(find.bySemanticsLabel('content-b'), findsOneWidget);
        expect(find.bySemanticsLabel('content-a'), findsNothing);

        semantics.dispose();
      });
    });
  });
}

class _HomeScreen extends StatelessWidget {
  const _HomeScreen({required this.child});

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
    return const Scaffold(body: Text('Details Screen'));
  }
}

class _BuilderTestWidget extends StatelessWidget {
  _BuilderTestWidget({required this.routeConfiguration, required this.matches})
    : builder = _routeBuilder(routeConfiguration);

  final RouteConfiguration routeConfiguration;
  final RouteBuilder builder;
  final RouteMatchList matches;

  /// Builds a [RouteBuilder] for tests
  static RouteBuilder _routeBuilder(RouteConfiguration configuration) {
    return RouteBuilder(
      configuration: configuration,
      builderWithNav: (BuildContext context, Widget child) {
        return child;
      },
      errorPageBuilder: (BuildContext context, GoRouterState state) {
        return MaterialPage<dynamic>(child: Text('Error: ${state.error}'));
      },
      errorBuilder: (BuildContext context, GoRouterState state) {
        return Text('Error: ${state.error}');
      },
      restorationScopeId: null,
      observers: <NavigatorObserver>[],
      onPopPageWithRouteMatch: (_, _, _) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: builder.build(context, matches, false));
  }
}
