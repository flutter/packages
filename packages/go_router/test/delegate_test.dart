// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:go_router/src/misc/error_screen.dart';

import 'test_helpers.dart';

Future<GoRouter> createGoRouter(
  WidgetTester tester, {
  Listenable? refreshListenable,
  bool dispose = true,
}) async {
  final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: <GoRoute>[
      GoRoute(path: '/', builder: (_, __) => const DummyStatefulWidget()),
      GoRoute(path: '/a', builder: (_, __) => const DummyStatefulWidget()),
      GoRoute(
        path: '/error',
        builder: (_, __) => const ErrorScreen(null),
      ),
    ],
    refreshListenable: refreshListenable,
  );
  if (dispose) {
    addTearDown(router.dispose);
  }
  await tester.pumpWidget(MaterialApp.router(
    routerConfig: router,
  ));
  return router;
}

Future<GoRouter> createGoRouterWithStatefulShellRoute(
    WidgetTester tester) async {
  final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: <RouteBase>[
      GoRoute(path: '/', builder: (_, __) => const DummyStatefulWidget()),
      GoRoute(path: '/a', builder: (_, __) => const DummyStatefulWidget()),
      StatefulShellRoute.indexedStack(branches: <StatefulShellBranch>[
        StatefulShellBranch(routes: <RouteBase>[
          GoRoute(
              path: '/c',
              builder: (_, __) => const DummyStatefulWidget(),
              routes: <RouteBase>[
                GoRoute(
                    path: 'c1',
                    builder: (_, __) => const DummyStatefulWidget()),
                GoRoute(
                    path: 'c2',
                    builder: (_, __) => const DummyStatefulWidget()),
              ]),
        ]),
        StatefulShellBranch(routes: <RouteBase>[
          GoRoute(
              path: '/d',
              builder: (_, __) => const DummyStatefulWidget(),
              routes: <RouteBase>[
                GoRoute(
                    path: 'd1',
                    builder: (_, __) => const DummyStatefulWidget()),
              ]),
        ]),
      ], builder: mockStackedShellBuilder),
    ],
  );
  addTearDown(router.dispose);
  await tester.pumpWidget(MaterialApp.router(
    routerConfig: router,
  ));
  return router;
}

void main() {
  group('pop', () {
    testWidgets('removes the last element', (WidgetTester tester) async {
      final GoRouter goRouter = await createGoRouter(tester)
        ..push('/error');
      await tester.pumpAndSettle();
      expect(find.byType(ErrorScreen), findsOneWidget);
      final RouteMatchBase last =
          goRouter.routerDelegate.currentConfiguration.matches.last;
      await goRouter.routerDelegate.popRoute();
      expect(goRouter.routerDelegate.currentConfiguration.matches.length, 1);
      expect(
          goRouter.routerDelegate.currentConfiguration.matches.contains(last),
          false);
    });

    testWidgets('pops more than matches count should return false',
        (WidgetTester tester) async {
      final GoRouter goRouter = await createGoRouter(tester)
        ..push('/error');
      await tester.pumpAndSettle();
      await goRouter.routerDelegate.popRoute();
      expect(await goRouter.routerDelegate.popRoute(), isFalse);
    });

    testWidgets('throw if nothing to pop', (WidgetTester tester) async {
      final GlobalKey<NavigatorState> rootKey = GlobalKey<NavigatorState>();
      final GlobalKey<NavigatorState> navKey = GlobalKey<NavigatorState>();
      final GoRouter goRouter = await createRouter(
        <RouteBase>[
          ShellRoute(
            navigatorKey: rootKey,
            builder: (_, __, Widget child) => child,
            routes: <RouteBase>[
              ShellRoute(
                parentNavigatorKey: rootKey,
                navigatorKey: navKey,
                builder: (_, __, Widget child) => child,
                routes: <RouteBase>[
                  GoRoute(
                    path: '/',
                    parentNavigatorKey: navKey,
                    builder: (_, __) => const Text('Home'),
                  ),
                ],
              ),
            ],
          ),
        ],
        tester,
      );
      await tester.pumpAndSettle();
      expect(find.text('Home'), findsOneWidget);
      String? message;
      try {
        goRouter.pop();
      } on GoError catch (e) {
        message = e.message;
      }
      expect(message, 'There is nothing to pop');
    });

    testWidgets('poproute return false if nothing to pop',
        (WidgetTester tester) async {
      final GlobalKey<NavigatorState> rootKey = GlobalKey<NavigatorState>();
      final GlobalKey<NavigatorState> navKey = GlobalKey<NavigatorState>();
      final GoRouter goRouter = await createRouter(
        <RouteBase>[
          ShellRoute(
            navigatorKey: rootKey,
            builder: (_, __, Widget child) => child,
            routes: <RouteBase>[
              ShellRoute(
                parentNavigatorKey: rootKey,
                navigatorKey: navKey,
                builder: (_, __, Widget child) => child,
                routes: <RouteBase>[
                  GoRoute(
                    path: '/',
                    parentNavigatorKey: navKey,
                    builder: (_, __) => const Text('Home'),
                  ),
                ],
              ),
            ],
          ),
        ],
        tester,
      );
      expect(await goRouter.routerDelegate.popRoute(), isFalse);
    });
  });

  group('push', () {
    testWidgets(
      'It should return different pageKey when push is called',
      (WidgetTester tester) async {
        final GoRouter goRouter = await createGoRouter(tester);
        expect(goRouter.routerDelegate.currentConfiguration.matches.length, 1);

        goRouter.push('/a');
        await tester.pumpAndSettle();

        goRouter.push('/a');
        await tester.pumpAndSettle();

        expect(goRouter.routerDelegate.currentConfiguration.matches.length, 3);
        expect(
          goRouter.routerDelegate.currentConfiguration.matches[1].pageKey,
          isNot(equals(
              goRouter.routerDelegate.currentConfiguration.matches[2].pageKey)),
        );
      },
    );

    testWidgets(
      'It should successfully push a route from outside the the current '
      'StatefulShellRoute',
      (WidgetTester tester) async {
        final GoRouter goRouter =
            await createGoRouterWithStatefulShellRoute(tester);
        goRouter.push('/c/c1');
        await tester.pumpAndSettle();
        goRouter.push('/a');
        await tester.pumpAndSettle();
        expect(goRouter.routerDelegate.currentConfiguration.matches.length, 3);
        expect(
          goRouter.routerDelegate.currentConfiguration.matches[1].pageKey,
          isNot(equals(
              goRouter.routerDelegate.currentConfiguration.matches[2].pageKey)),
        );
      },
    );

    testWidgets(
      'It should successfully push a route that is a descendant of the current '
      'StatefulShellRoute branch',
      (WidgetTester tester) async {
        final GoRouter goRouter =
            await createGoRouterWithStatefulShellRoute(tester);
        goRouter.push('/c/c1');
        await tester.pumpAndSettle();

        goRouter.push('/c/c2');
        await tester.pumpAndSettle();

        expect(goRouter.routerDelegate.currentConfiguration.matches.length, 2);
        final ShellRouteMatch shellRouteMatch = goRouter.routerDelegate
            .currentConfiguration.matches.last as ShellRouteMatch;
        expect(shellRouteMatch.matches.length, 2);
        expect(
          shellRouteMatch.matches[0].pageKey,
          isNot(equals(shellRouteMatch.matches[1].pageKey)),
        );
      },
    );

    testWidgets(
      'It should successfully push the root of the current StatefulShellRoute '
      'branch upon itself',
      (WidgetTester tester) async {
        final GoRouter goRouter =
            await createGoRouterWithStatefulShellRoute(tester);
        goRouter.push('/c');
        await tester.pumpAndSettle();

        goRouter.push('/c');
        await tester.pumpAndSettle();

        expect(goRouter.routerDelegate.currentConfiguration.matches.length, 2);
        final ShellRouteMatch shellRouteMatch = goRouter.routerDelegate
            .currentConfiguration.matches.last as ShellRouteMatch;
        expect(shellRouteMatch.matches.length, 2);
        expect(
          shellRouteMatch.matches[0].pageKey,
          isNot(equals(shellRouteMatch.matches[1].pageKey)),
        );
      },
    );
  });

  group('canPop', () {
    testWidgets(
      'It should return false if there is only 1 match in the stack',
      (WidgetTester tester) async {
        final GoRouter goRouter = await createGoRouter(tester);

        await tester.pumpAndSettle();
        expect(goRouter.routerDelegate.currentConfiguration.matches.length, 1);
        expect(goRouter.routerDelegate.canPop(), false);
      },
    );
    testWidgets(
      'It should return true if there is more than 1 match in the stack',
      (WidgetTester tester) async {
        final GoRouter goRouter = await createGoRouter(tester)
          ..push('/a');

        await tester.pumpAndSettle();
        expect(goRouter.routerDelegate.currentConfiguration.matches.length, 2);
        expect(goRouter.routerDelegate.canPop(), true);
      },
    );
  });

  group('pushReplacement', () {
    testWidgets('It should replace the last match with the given one',
        (WidgetTester tester) async {
      final GoRouter goRouter = GoRouter(
        initialLocation: '/',
        routes: <GoRoute>[
          GoRoute(path: '/', builder: (_, __) => const SizedBox()),
          GoRoute(path: '/page-0', builder: (_, __) => const SizedBox()),
          GoRoute(path: '/page-1', builder: (_, __) => const SizedBox()),
        ],
      );
      addTearDown(goRouter.dispose);
      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: goRouter,
        ),
      );

      goRouter.push('/page-0');

      goRouter.routerDelegate.addListener(expectAsync0(() {}));
      final RouteMatchBase first =
          goRouter.routerDelegate.currentConfiguration.matches.first;
      final RouteMatch last = goRouter.routerDelegate.currentConfiguration.last;
      goRouter.pushReplacement('/page-1');
      expect(goRouter.routerDelegate.currentConfiguration.matches.length, 2);
      expect(
        goRouter.routerDelegate.currentConfiguration.matches.first,
        first,
        reason: 'The first match should still be in the list of matches',
      );
      expect(
        goRouter.routerDelegate.currentConfiguration.last,
        isNot(last),
        reason: 'The last match should have been removed',
      );
      expect(
        (goRouter.routerDelegate.currentConfiguration.last
                as ImperativeRouteMatch)
            .matches
            .uri
            .toString(),
        '/page-1',
        reason: 'The new location should have been pushed',
      );
    });

    testWidgets(
      'It should return different pageKey when pushReplacement is called',
      (WidgetTester tester) async {
        final GoRouter goRouter = await createGoRouter(tester);
        expect(goRouter.routerDelegate.currentConfiguration.matches.length, 1);
        expect(
          goRouter.routerDelegate.currentConfiguration.matches[0].pageKey,
          isNotNull,
        );

        goRouter.push('/a');
        await tester.pumpAndSettle();

        expect(goRouter.routerDelegate.currentConfiguration.matches.length, 2);
        final ValueKey<String> prev =
            goRouter.routerDelegate.currentConfiguration.matches.last.pageKey;

        goRouter.pushReplacement('/a');
        await tester.pumpAndSettle();

        expect(goRouter.routerDelegate.currentConfiguration.matches.length, 2);
        expect(
          goRouter.routerDelegate.currentConfiguration.matches.last.pageKey,
          isNot(equals(prev)),
        );
      },
    );
  });

  group('pushReplacementNamed', () {
    testWidgets(
      'It should replace the last match with the given one',
      (WidgetTester tester) async {
        final GoRouter goRouter = GoRouter(
          initialLocation: '/',
          routes: <GoRoute>[
            GoRoute(path: '/', builder: (_, __) => const SizedBox()),
            GoRoute(
                path: '/page-0',
                name: 'page0',
                builder: (_, __) => const SizedBox()),
            GoRoute(
                path: '/page-1',
                name: 'page1',
                builder: (_, __) => const SizedBox()),
          ],
        );
        addTearDown(goRouter.dispose);
        await tester.pumpWidget(
          MaterialApp.router(
            routerConfig: goRouter,
          ),
        );

        goRouter.pushNamed('page0');

        goRouter.routerDelegate.addListener(expectAsync0(() {}));
        final RouteMatchBase first =
            goRouter.routerDelegate.currentConfiguration.matches.first;
        final RouteMatch last =
            goRouter.routerDelegate.currentConfiguration.last;
        goRouter.pushReplacementNamed('page1');
        expect(goRouter.routerDelegate.currentConfiguration.matches.length, 2);
        expect(
          goRouter.routerDelegate.currentConfiguration.matches.first,
          first,
          reason: 'The first match should still be in the list of matches',
        );
        expect(
          goRouter.routerDelegate.currentConfiguration.last,
          isNot(last),
          reason: 'The last match should have been removed',
        );
        expect(
          goRouter.routerDelegate.currentConfiguration.last,
          isA<RouteMatch>().having(
            (RouteMatch match) => match.route.name,
            'match.route.name',
            'page1',
          ),
          reason: 'The new location should have been pushed',
        );
      },
    );
  });

  group('replace', () {
    testWidgets('It should replace the last match with the given one',
        (WidgetTester tester) async {
      final GoRouter goRouter = GoRouter(
        initialLocation: '/',
        routes: <GoRoute>[
          GoRoute(path: '/', builder: (_, __) => const SizedBox()),
          GoRoute(path: '/page-0', builder: (_, __) => const SizedBox()),
          GoRoute(path: '/page-1', builder: (_, __) => const SizedBox()),
        ],
      );
      addTearDown(goRouter.dispose);
      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: goRouter,
        ),
      );

      goRouter.push('/page-0');

      goRouter.routerDelegate.addListener(expectAsync0(() {}));
      final RouteMatchBase first =
          goRouter.routerDelegate.currentConfiguration.matches.first;
      final RouteMatch last = goRouter.routerDelegate.currentConfiguration.last;
      goRouter.replace<void>('/page-1');
      expect(goRouter.routerDelegate.currentConfiguration.matches.length, 2);
      expect(
        goRouter.routerDelegate.currentConfiguration.matches.first,
        first,
        reason: 'The first match should still be in the list of matches',
      );
      expect(
        goRouter.routerDelegate.currentConfiguration.last,
        isNot(last),
        reason: 'The last match should have been removed',
      );
      expect(
        (goRouter.routerDelegate.currentConfiguration.last
                as ImperativeRouteMatch)
            .matches
            .uri
            .toString(),
        '/page-1',
        reason: 'The new location should have been pushed',
      );
    });

    testWidgets(
      'It should use the same pageKey when replace is called (with the same path)',
      (WidgetTester tester) async {
        final GoRouter goRouter = await createGoRouter(tester);
        expect(goRouter.routerDelegate.currentConfiguration.matches.length, 1);
        expect(
          goRouter.routerDelegate.currentConfiguration.matches[0].pageKey,
          isNotNull,
        );

        goRouter.push('/a');
        await tester.pumpAndSettle();

        expect(goRouter.routerDelegate.currentConfiguration.matches.length, 2);
        final ValueKey<String> prev =
            goRouter.routerDelegate.currentConfiguration.matches.last.pageKey;

        goRouter.replace<void>('/a');
        await tester.pumpAndSettle();

        expect(goRouter.routerDelegate.currentConfiguration.matches.length, 2);
        expect(
          goRouter.routerDelegate.currentConfiguration.matches.last.pageKey,
          prev,
        );
      },
    );

    testWidgets(
      'It should use the same pageKey when replace is called (with a different path)',
      (WidgetTester tester) async {
        final GoRouter goRouter = await createGoRouter(tester);
        expect(goRouter.routerDelegate.currentConfiguration.matches.length, 1);
        expect(
          goRouter.routerDelegate.currentConfiguration.matches[0].pageKey,
          isNotNull,
        );

        goRouter.push('/a');
        await tester.pumpAndSettle();

        expect(goRouter.routerDelegate.currentConfiguration.matches.length, 2);
        final ValueKey<String> prev =
            goRouter.routerDelegate.currentConfiguration.matches.last.pageKey;

        goRouter.replace<void>('/');
        await tester.pumpAndSettle();

        expect(goRouter.routerDelegate.currentConfiguration.matches.length, 2);
        expect(
          goRouter.routerDelegate.currentConfiguration.matches.last.pageKey,
          prev,
        );
      },
    );
  });

  group('replaceNamed', () {
    Future<GoRouter> createGoRouter(
      WidgetTester tester, {
      Listenable? refreshListenable,
    }) async {
      final GoRouter router = GoRouter(
        initialLocation: '/',
        routes: <GoRoute>[
          GoRoute(
            path: '/',
            name: 'home',
            builder: (_, __) => const SizedBox(),
          ),
          GoRoute(
            path: '/page-0',
            name: 'page0',
            builder: (_, __) => const SizedBox(),
          ),
          GoRoute(
            path: '/page-1',
            name: 'page1',
            builder: (_, __) => const SizedBox(),
          ),
        ],
      );
      addTearDown(router.dispose);
      await tester.pumpWidget(MaterialApp.router(
        routerConfig: router,
      ));
      return router;
    }

    testWidgets('It should replace the last match with the given one',
        (WidgetTester tester) async {
      final GoRouter goRouter = await createGoRouter(tester);

      goRouter.pushNamed('page0');

      goRouter.routerDelegate.addListener(expectAsync0(() {}));
      final RouteMatchBase first =
          goRouter.routerDelegate.currentConfiguration.matches.first;
      final RouteMatch last = goRouter.routerDelegate.currentConfiguration.last;
      goRouter.replaceNamed<void>('page1');
      expect(goRouter.routerDelegate.currentConfiguration.matches.length, 2);
      expect(
        goRouter.routerDelegate.currentConfiguration.matches.first,
        first,
        reason: 'The first match should still be in the list of matches',
      );
      expect(
        goRouter.routerDelegate.currentConfiguration.last,
        isNot(last),
        reason: 'The last match should have been removed',
      );
      expect(
        (goRouter.routerDelegate.currentConfiguration.last
                as ImperativeRouteMatch)
            .matches
            .uri
            .toString(),
        '/page-1',
        reason: 'The new location should have been pushed',
      );
    });

    testWidgets(
      'It should use the same pageKey when replace is called with the same path',
      (WidgetTester tester) async {
        final GoRouter goRouter = await createGoRouter(tester);
        expect(goRouter.routerDelegate.currentConfiguration.matches.length, 1);
        expect(
          goRouter.routerDelegate.currentConfiguration.matches.first.pageKey,
          isNotNull,
        );

        goRouter.pushNamed('page0');
        await tester.pumpAndSettle();

        expect(goRouter.routerDelegate.currentConfiguration.matches.length, 2);
        final ValueKey<String> prev =
            goRouter.routerDelegate.currentConfiguration.matches.last.pageKey;

        goRouter.replaceNamed<void>('page0');
        await tester.pumpAndSettle();

        expect(goRouter.routerDelegate.currentConfiguration.matches.length, 2);
        expect(
          goRouter.routerDelegate.currentConfiguration.matches.last.pageKey,
          prev,
        );
      },
    );

    testWidgets(
      'It should use a new pageKey when replace is called with a different path',
      (WidgetTester tester) async {
        final GoRouter goRouter = await createGoRouter(tester);
        expect(goRouter.routerDelegate.currentConfiguration.matches.length, 1);
        expect(
          goRouter.routerDelegate.currentConfiguration.matches.first.pageKey,
          isNotNull,
        );

        goRouter.pushNamed('page0');
        await tester.pumpAndSettle();

        expect(goRouter.routerDelegate.currentConfiguration.matches.length, 2);
        final ValueKey<String> prev =
            goRouter.routerDelegate.currentConfiguration.matches.last.pageKey;

        goRouter.replaceNamed<void>('home');
        await tester.pumpAndSettle();

        expect(goRouter.routerDelegate.currentConfiguration.matches.length, 2);
        expect(
          goRouter.routerDelegate.currentConfiguration.matches.last.pageKey,
          prev,
        );
      },
    );
  });

  testWidgets('dispose unsubscribes from refreshListenable',
      (WidgetTester tester) async {
    final FakeRefreshListenable refreshListenable = FakeRefreshListenable();
    addTearDown(refreshListenable.dispose);

    final GoRouter goRouter = await createGoRouter(
      tester,
      refreshListenable: refreshListenable,
      dispose: false,
    );
    await tester.pumpWidget(Container());
    goRouter.dispose();
    expect(refreshListenable.unsubscribed, true);
  });
}

class FakeRefreshListenable extends ChangeNotifier {
  bool unsubscribed = false;

  @override
  void removeListener(VoidCallback listener) {
    unsubscribed = true;
    super.removeListener(listener);
  }
}

class DummyStatefulWidget extends StatefulWidget {
  const DummyStatefulWidget({super.key});

  @override
  State<DummyStatefulWidget> createState() => _DummyStatefulWidgetState();
}

class _DummyStatefulWidgetState extends State<DummyStatefulWidget> {
  @override
  Widget build(BuildContext context) => Container();
}
