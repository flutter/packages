// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show SelectionRegistrar;
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

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

      await tester.pumpWidget(
        _BuilderTestWidget(routeConfiguration: config, matches: matches),
      );

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

      await tester.pumpWidget(
        _BuilderTestWidget(routeConfiguration: config, matches: matches),
      );

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

      await tester.pumpWidget(
        _BuilderTestWidget(routeConfiguration: config, matches: matches),
      );

      expect(find.byKey(rootNavigatorKey), findsOneWidget);
    });

    testWidgets('Builds a Navigator for ShellRoute', (
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

      await tester.pumpWidget(
        _BuilderTestWidget(routeConfiguration: config, matches: matches),
      );

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

      await tester.pumpWidget(
        _BuilderTestWidget(routeConfiguration: config, matches: matches),
      );

      // The Details screen should be visible, but the HomeScreen should be
      // offstage (underneath) the DetailsScreen.
      expect(find.byType(_HomeScreen), findsNothing);
      expect(find.byType(_DetailsScreen), findsOneWidget);
    });

    testWidgets('Uses the correct restorationScopeId for ShellRoute', (
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

      await tester.pumpWidget(
        _BuilderTestWidget(routeConfiguration: config, matches: matches),
      );

      expect(find.byKey(rootNavigatorKey), findsOneWidget);
      expect(find.byKey(shellNavigatorKey), findsOneWidget);
      expect(
        (shellNavigatorKey.currentWidget as Navigator?)?.restorationScopeId,
        'scope1',
      );
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
      expect(
        (shellNavigatorKey.currentWidget as Navigator?)?.restorationScopeId,
        'scope1',
      );
    });

    testWidgets('GoRouter requestFocus defaults to true', (
      WidgetTester tester,
    ) async {
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

      final Navigator navigator = tester.widget<Navigator>(
        find.byType(Navigator),
      );
      expect(navigator.requestFocus, isTrue);
    });

    testWidgets('GoRouter requestFocus can be set to false', (
      WidgetTester tester,
    ) async {
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

      final Navigator navigator = tester.widget<Navigator>(
        find.byType(Navigator),
      );
      expect(navigator.requestFocus, isFalse);
    });

    testWidgets('Offstage pages disable selection to prevent dead zones '
        'when SelectionArea wraps ShellRoute child (builder)', (
      WidgetTester tester,
    ) async {
      // Tracks the SelectionRegistrar visible from each page's context.
      // When a page is offstage, its registrar should be null (disabled).
      SelectionRegistrar? listPageRegistrar;
      SelectionRegistrar? detailPageRegistrar;

      final router = GoRouter(
        initialLocation: '/list',
        routes: <RouteBase>[
          ShellRoute(
            builder: (BuildContext context, GoRouterState state, Widget child) {
              return SelectionArea(child: child);
            },
            routes: <RouteBase>[
              GoRoute(
                path: '/list',
                builder: (BuildContext context, GoRouterState state) {
                  return Builder(
                    builder: (BuildContext context) {
                      listPageRegistrar = SelectionContainer.maybeOf(context);
                      return const Text('List Page');
                    },
                  );
                },
                routes: <RouteBase>[
                  GoRoute(
                    path: ':id',
                    builder: (BuildContext context, GoRouterState state) {
                      return Builder(
                        builder: (BuildContext context) {
                          detailPageRegistrar = SelectionContainer.maybeOf(
                            context,
                          );
                          return const Text('Detail Page');
                        },
                      );
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

      // Initially, list page is the current page and has a registrar.
      expect(listPageRegistrar, isNotNull);

      // Navigate to detail page (child route of /list).
      router.go('/list/1');
      await tester.pumpAndSettle();

      // Detail page (onstage) should have a registrar for selection.
      expect(
        detailPageRegistrar,
        isNotNull,
        reason: 'Current page should have selection enabled',
      );

      // List page (offstage) should have selection DISABLED to prevent
      // its text from registering as selectable and creating dead zones.
      expect(
        listPageRegistrar,
        isNull,
        reason: 'Offstage page should have selection disabled',
      );
    });

    testWidgets('Offstage pages disable selection to prevent dead zones '
        'when SelectionArea wraps ShellRoute child (pageBuilder)', (
      WidgetTester tester,
    ) async {
      SelectionRegistrar? listPageRegistrar;
      SelectionRegistrar? detailPageRegistrar;

      final router = GoRouter(
        initialLocation: '/list',
        routes: <RouteBase>[
          ShellRoute(
            builder: (BuildContext context, GoRouterState state, Widget child) {
              return SelectionArea(child: child);
            },
            routes: <RouteBase>[
              GoRoute(
                path: '/list',
                pageBuilder: (BuildContext context, GoRouterState state) {
                  return NoTransitionPage<void>(
                    child: Builder(
                      builder: (BuildContext context) {
                        listPageRegistrar = SelectionContainer.maybeOf(context);
                        return const Text('List Page');
                      },
                    ),
                  );
                },
                routes: <RouteBase>[
                  GoRoute(
                    path: ':id',
                    pageBuilder: (BuildContext context, GoRouterState state) {
                      return NoTransitionPage<void>(
                        child: Builder(
                          builder: (BuildContext context) {
                            detailPageRegistrar = SelectionContainer.maybeOf(
                              context,
                            );
                            return const Text('Detail Page');
                          },
                        ),
                      );
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

      // Initially, list page is current and has a registrar.
      expect(listPageRegistrar, isNotNull);

      // Navigate to detail page.
      router.go('/list/1');
      await tester.pumpAndSettle();

      // Detail page (onstage) should have a registrar.
      expect(
        detailPageRegistrar,
        isNotNull,
        reason: 'Current page should have selection enabled',
      );

      // List page (offstage) should have selection DISABLED.
      expect(
        listPageRegistrar,
        isNull,
        reason: 'Offstage page should have selection disabled',
      );
    });

    testWidgets(
      'Selection is re-enabled when navigating back to an offstage page',
      (WidgetTester tester) async {
        SelectionRegistrar? listPageRegistrar;

        final router = GoRouter(
          initialLocation: '/list',
          routes: <RouteBase>[
            ShellRoute(
              builder:
                  (BuildContext context, GoRouterState state, Widget child) {
                    return SelectionArea(child: child);
                  },
              routes: <RouteBase>[
                GoRoute(
                  path: '/list',
                  builder: (BuildContext context, GoRouterState state) {
                    return Builder(
                      builder: (BuildContext context) {
                        listPageRegistrar = SelectionContainer.maybeOf(context);
                        return const Text('List Page');
                      },
                    );
                  },
                  routes: <RouteBase>[
                    GoRoute(
                      path: ':id',
                      builder: (BuildContext context, GoRouterState state) {
                        return const Text('Detail Page');
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

        // Initially, list page has a registrar.
        expect(listPageRegistrar, isNotNull);

        // Navigate to detail, making list offstage.
        router.go('/list/1');
        await tester.pumpAndSettle();
        expect(
          listPageRegistrar,
          isNull,
          reason: 'Offstage page should have selection disabled',
        );

        // Navigate back to list (list becomes current again).
        router.go('/list');
        await tester.pumpAndSettle();

        // List page should have selection re-enabled.
        expect(
          listPageRegistrar,
          isNotNull,
          reason: 'Selection should be re-enabled when page becomes current',
        );
      },
    );

    testWidgets(
      'Deep-linked child route has selection disabled on parent from first frame',
      (WidgetTester tester) async {
        SelectionRegistrar? listPageRegistrar;
        SelectionRegistrar? detailPageRegistrar;

        final router = GoRouter(
          initialLocation: '/list/1',
          routes: <RouteBase>[
            ShellRoute(
              builder:
                  (BuildContext context, GoRouterState state, Widget child) {
                    return SelectionArea(child: child);
                  },
              routes: <RouteBase>[
                GoRoute(
                  path: '/list',
                  builder: (BuildContext context, GoRouterState state) {
                    return Builder(
                      builder: (BuildContext context) {
                        listPageRegistrar = SelectionContainer.maybeOf(context);
                        return const Text('List Page');
                      },
                    );
                  },
                  routes: <RouteBase>[
                    GoRoute(
                      path: ':id',
                      builder: (BuildContext context, GoRouterState state) {
                        return Builder(
                          builder: (BuildContext context) {
                            detailPageRegistrar = SelectionContainer.maybeOf(
                              context,
                            );
                            return const Text('Detail Page');
                          },
                        );
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

        // Parent page was never the "current" route; it should still have
        // selection disabled from the very first frame.
        expect(
          listPageRegistrar,
          isNull,
          reason:
              'Deep-linked parent page should have selection disabled from first frame',
        );
        expect(
          detailPageRegistrar,
          isNotNull,
          reason: 'Current page should have selection enabled',
        );
      },
    );

    testWidgets(
      '3+ level nesting disables selection on all offstage ancestors',
      (WidgetTester tester) async {
        SelectionRegistrar? pageARegistrar;
        SelectionRegistrar? pageBRegistrar;
        SelectionRegistrar? pageCRegistrar;

        final router = GoRouter(
          initialLocation: '/a',
          routes: <RouteBase>[
            ShellRoute(
              builder:
                  (BuildContext context, GoRouterState state, Widget child) {
                    return SelectionArea(child: child);
                  },
              routes: <RouteBase>[
                GoRoute(
                  path: '/a',
                  builder: (BuildContext context, GoRouterState state) {
                    return Builder(
                      builder: (BuildContext context) {
                        pageARegistrar = SelectionContainer.maybeOf(context);
                        return const Text('Page A');
                      },
                    );
                  },
                  routes: <RouteBase>[
                    GoRoute(
                      path: 'b',
                      builder: (BuildContext context, GoRouterState state) {
                        return Builder(
                          builder: (BuildContext context) {
                            pageBRegistrar = SelectionContainer.maybeOf(
                              context,
                            );
                            return const Text('Page B');
                          },
                        );
                      },
                      routes: <RouteBase>[
                        GoRoute(
                          path: 'c',
                          builder: (BuildContext context, GoRouterState state) {
                            return Builder(
                              builder: (BuildContext context) {
                                pageCRegistrar = SelectionContainer.maybeOf(
                                  context,
                                );
                                return const Text('Page C');
                              },
                            );
                          },
                        ),
                      ],
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

        // Initially /a is current.
        expect(pageARegistrar, isNotNull);

        // Navigate to /a/b/c.
        router.go('/a/b/c');
        await tester.pumpAndSettle();

        // Both /a and /a/b should be offstage with selection disabled.
        expect(
          pageARegistrar,
          isNull,
          reason: 'Grandparent offstage page should have selection disabled',
        );
        expect(
          pageBRegistrar,
          isNull,
          reason: 'Parent offstage page should have selection disabled',
        );
        expect(
          pageCRegistrar,
          isNotNull,
          reason: 'Current page should have selection enabled',
        );
      },
    );

    testWidgets(
      'Offstage selection disabled with CustomTransitionPage pageBuilder',
      (WidgetTester tester) async {
        SelectionRegistrar? listPageRegistrar;
        SelectionRegistrar? detailPageRegistrar;

        final router = GoRouter(
          initialLocation: '/list',
          routes: <RouteBase>[
            ShellRoute(
              builder:
                  (BuildContext context, GoRouterState state, Widget child) {
                    return SelectionArea(child: child);
                  },
              routes: <RouteBase>[
                GoRoute(
                  path: '/list',
                  pageBuilder: (BuildContext context, GoRouterState state) {
                    return CustomTransitionPage<void>(
                      transitionsBuilder: (_, animation, __, child) =>
                          FadeTransition(opacity: animation, child: child),
                      child: Builder(
                        builder: (BuildContext context) {
                          listPageRegistrar = SelectionContainer.maybeOf(
                            context,
                          );
                          return const Text('List Page');
                        },
                      ),
                    );
                  },
                  routes: <RouteBase>[
                    GoRoute(
                      path: ':id',
                      pageBuilder: (BuildContext context, GoRouterState state) {
                        return CustomTransitionPage<void>(
                          transitionsBuilder: (_, animation, __, child) =>
                              FadeTransition(opacity: animation, child: child),
                          child: Builder(
                            builder: (BuildContext context) {
                              detailPageRegistrar = SelectionContainer.maybeOf(
                                context,
                              );
                              return const Text('Detail Page');
                            },
                          ),
                        );
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

        expect(listPageRegistrar, isNotNull);

        router.go('/list/1');
        await tester.pumpAndSettle();

        expect(
          detailPageRegistrar,
          isNotNull,
          reason: 'Current page should have selection enabled',
        );
        expect(
          listPageRegistrar,
          isNull,
          reason:
              'Offstage page (CustomTransitionPage) should have selection disabled',
        );
      },
    );

    testWidgets('Selection re-enables after pop navigation', (
      WidgetTester tester,
    ) async {
      SelectionRegistrar? listPageRegistrar;

      final router = GoRouter(
        initialLocation: '/list',
        routes: <RouteBase>[
          ShellRoute(
            builder: (BuildContext context, GoRouterState state, Widget child) {
              return SelectionArea(child: child);
            },
            routes: <RouteBase>[
              GoRoute(
                path: '/list',
                builder: (BuildContext context, GoRouterState state) {
                  return Builder(
                    builder: (BuildContext context) {
                      listPageRegistrar = SelectionContainer.maybeOf(context);
                      return const Text('List Page');
                    },
                  );
                },
                routes: <RouteBase>[
                  GoRoute(
                    path: ':id',
                    builder: (BuildContext context, GoRouterState state) {
                      return const Text('Detail Page');
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
      expect(listPageRegistrar, isNotNull);

      // Push detail page, making list offstage.
      router.push('/list/1');
      await tester.pumpAndSettle();
      expect(
        listPageRegistrar,
        isNull,
        reason: 'Offstage page should have selection disabled',
      );

      // Pop back to list.
      router.pop();
      await tester.pumpAndSettle();
      expect(
        listPageRegistrar,
        isNotNull,
        reason: 'Selection should re-enable after pop',
      );
    });

    testWidgets('Deep-linked page re-enables selection after navigating back', (
      WidgetTester tester,
    ) async {
      SelectionRegistrar? listPageRegistrar;

      final router = GoRouter(
        initialLocation: '/list/1',
        routes: <RouteBase>[
          ShellRoute(
            builder: (BuildContext context, GoRouterState state, Widget child) {
              return SelectionArea(child: child);
            },
            routes: <RouteBase>[
              GoRoute(
                path: '/list',
                builder: (BuildContext context, GoRouterState state) {
                  return Builder(
                    builder: (BuildContext context) {
                      listPageRegistrar = SelectionContainer.maybeOf(context);
                      return const Text('List Page');
                    },
                  );
                },
                routes: <RouteBase>[
                  GoRoute(
                    path: ':id',
                    builder: (BuildContext context, GoRouterState state) {
                      return const Text('Detail Page');
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

      // List page started offstage (deep-linked to /list/1).
      expect(
        listPageRegistrar,
        isNull,
        reason: 'Deep-linked parent should start with selection disabled',
      );

      // Navigate back to list (list becomes current).
      router.go('/list');
      await tester.pumpAndSettle();

      expect(
        listPageRegistrar,
        isNotNull,
        reason:
            'Selection should be re-enabled on page that was always offstage until now',
      );
    });

    testWidgets('StatefulShellRoute disables selection on inactive branches', (
      WidgetTester tester,
    ) async {
      SelectionRegistrar? branchARegistrar;
      SelectionRegistrar? branchBRegistrar;

      final GoRouter router = GoRouter(
        initialLocation: '/a',
        routes: <RouteBase>[
          StatefulShellRoute.indexedStack(
            builder:
                (
                  BuildContext context,
                  GoRouterState state,
                  StatefulNavigationShell navigationShell,
                ) {
                  return SelectionArea(
                    child: Column(
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            TextButton(
                              onPressed: () => navigationShell.goBranch(0),
                              child: const Text('Tab A'),
                            ),
                            TextButton(
                              onPressed: () => navigationShell.goBranch(1),
                              child: const Text('Tab B'),
                            ),
                          ],
                        ),
                        Expanded(child: navigationShell),
                      ],
                    ),
                  );
                },
            branches: <StatefulShellBranch>[
              StatefulShellBranch(
                routes: <RouteBase>[
                  GoRoute(
                    path: '/a',
                    builder: (BuildContext context, GoRouterState state) =>
                        Builder(
                          builder: (BuildContext context) {
                            branchARegistrar = SelectionContainer.maybeOf(
                              context,
                            );
                            return const Text('Branch A');
                          },
                        ),
                  ),
                ],
              ),
              StatefulShellBranch(
                routes: <RouteBase>[
                  GoRoute(
                    path: '/b',
                    builder: (BuildContext context, GoRouterState state) =>
                        Builder(
                          builder: (BuildContext context) {
                            branchBRegistrar = SelectionContainer.maybeOf(
                              context,
                            );
                            return const Text('Branch B');
                          },
                        ),
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

      expect(branchARegistrar, isNotNull);

      // Switch to branch B.
      router.go('/b');
      await tester.pumpAndSettle();

      expect(
        branchBRegistrar,
        isNotNull,
        reason: 'Active branch should have selection enabled',
      );
      expect(
        branchARegistrar,
        isNull,
        reason: 'Inactive branch should have selection disabled',
      );

      // Switch back to branch A.
      router.go('/a');
      await tester.pumpAndSettle();

      expect(
        branchARegistrar,
        isNotNull,
        reason: 'Selection should re-enable when branch becomes active',
      );
    });

    testWidgets(
      'StatefulShellRoute preserves navigator state with selection guard',
      (WidgetTester tester) async {
        final GoRouter router = GoRouter(
          initialLocation: '/a',
          routes: <RouteBase>[
            StatefulShellRoute.indexedStack(
              builder:
                  (
                    BuildContext context,
                    GoRouterState state,
                    StatefulNavigationShell navigationShell,
                  ) {
                    return SelectionArea(child: navigationShell);
                  },
              branches: <StatefulShellBranch>[
                StatefulShellBranch(
                  routes: <RouteBase>[
                    GoRoute(
                      path: '/a',
                      builder: (BuildContext context, GoRouterState state) =>
                          const Text('Branch A Root'),
                      routes: <RouteBase>[
                        GoRoute(
                          path: 'detail',
                          builder:
                              (BuildContext context, GoRouterState state) =>
                                  const Text('Branch A Detail'),
                        ),
                      ],
                    ),
                  ],
                ),
                StatefulShellBranch(
                  routes: <RouteBase>[
                    GoRoute(
                      path: '/b',
                      builder: (BuildContext context, GoRouterState state) =>
                          const Text('Branch B'),
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

        // Push detail page within branch A.
        router.go('/a/detail');
        await tester.pumpAndSettle();
        expect(find.text('Branch A Detail'), findsOneWidget);

        // Switch to branch B (branch A becomes inactive + wrapped).
        router.go('/b');
        await tester.pumpAndSettle();
        expect(find.text('Branch B'), findsOneWidget);

        // Switch back to branch A — detail page should still be showing.
        router.go('/a/detail');
        await tester.pumpAndSettle();
        expect(
          find.text('Branch A Detail'),
          findsOneWidget,
          reason: 'Navigator state should survive branch switching',
        );
      },
    );

    testWidgets('StatefulShellRoute selection composes with route-level '
        '_OffstageSelectionDisabler', (WidgetTester tester) async {
      SelectionRegistrar? branchARootRegistrar;
      SelectionRegistrar? branchADetailRegistrar;

      final GoRouter router = GoRouter(
        initialLocation: '/a',
        routes: <RouteBase>[
          StatefulShellRoute.indexedStack(
            builder:
                (
                  BuildContext context,
                  GoRouterState state,
                  StatefulNavigationShell navigationShell,
                ) {
                  return SelectionArea(child: navigationShell);
                },
            branches: <StatefulShellBranch>[
              StatefulShellBranch(
                routes: <RouteBase>[
                  GoRoute(
                    path: '/a',
                    builder: (BuildContext context, GoRouterState state) =>
                        Builder(
                          builder: (BuildContext context) {
                            branchARootRegistrar = SelectionContainer.maybeOf(
                              context,
                            );
                            return const Text('Branch A Root');
                          },
                        ),
                    routes: <RouteBase>[
                      GoRoute(
                        path: 'detail',
                        builder: (BuildContext context, GoRouterState state) =>
                            Builder(
                              builder: (BuildContext context) {
                                branchADetailRegistrar =
                                    SelectionContainer.maybeOf(context);
                                return const Text('Branch A Detail');
                              },
                            ),
                      ),
                    ],
                  ),
                ],
              ),
              StatefulShellBranch(
                routes: <RouteBase>[
                  GoRoute(
                    path: '/b',
                    builder: (BuildContext context, GoRouterState state) =>
                        const Text('Branch B'),
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

      // Initially /a is active and current within its navigator.
      expect(branchARootRegistrar, isNotNull);

      // Push /a/detail — /a becomes offstage within branch A's navigator.
      router.go('/a/detail');
      await tester.pumpAndSettle();
      expect(
        branchADetailRegistrar,
        isNotNull,
        reason: 'Current route should have selection enabled',
      );
      expect(
        branchARootRegistrar,
        isNull,
        reason:
            'Offstage route within active branch should have selection disabled',
      );

      // Switch to branch B — entire branch A becomes inactive.
      router.go('/b');
      await tester.pumpAndSettle();

      // Switch back to branch A — /a/detail should still be showing.
      router.go('/a/detail');
      await tester.pumpAndSettle();
      expect(
        branchADetailRegistrar,
        isNotNull,
        reason:
            'Current route should have selection re-enabled after branch switch',
      );
      expect(
        branchARootRegistrar,
        isNull,
        reason:
            'Route-level offstage disabling should still work after branch switch',
      );
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
      onPopPageWithRouteMatch: (_, __, ___) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: builder.build(context, matches, false));
  }
}
