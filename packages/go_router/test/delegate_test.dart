// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:go_router/src/delegate.dart';
import 'package:go_router/src/match.dart';
import 'package:go_router/src/misc/error_screen.dart';

Future<GoRouter> createGoRouter(
  WidgetTester tester, {
  Listenable? refreshListenable,
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
      StatefulShellRoute(branches: <StatefulShellBranch>[
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
      ], builder: (_, __, Widget child) => child),
    ],
  );
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

      final RouteMatch last = goRouter.routerDelegate.matches.matches.last;
      await goRouter.routerDelegate.popRoute();
      expect(goRouter.routerDelegate.matches.matches.length, 1);
      expect(goRouter.routerDelegate.matches.matches.contains(last), false);
    });

    testWidgets('pops more than matches count should return false',
        (WidgetTester tester) async {
      final GoRouter goRouter = await createGoRouter(tester)
        ..push('/error');
      await tester.pumpAndSettle();
      await goRouter.routerDelegate.popRoute();
      expect(await goRouter.routerDelegate.popRoute(), isFalse);
    });
  });

  group('push', () {
    testWidgets(
      'It should return different pageKey when push is called',
      (WidgetTester tester) async {
        final GoRouter goRouter = await createGoRouter(tester);
        expect(goRouter.routerDelegate.matches.matches.length, 1);

        goRouter.push('/a');
        await tester.pumpAndSettle();

        expect(goRouter.routerDelegate.matches.matches.length, 2);
        expect(
          goRouter.routerDelegate.matches.matches[1].pageKey,
          const Key('/a-p1'),
        );

        goRouter.push('/a');
        await tester.pumpAndSettle();

        expect(goRouter.routerDelegate.matches.matches.length, 3);
        expect(
          goRouter.routerDelegate.matches.matches[2].pageKey,
          const Key('/a-p2'),
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

        expect(goRouter.routerDelegate.matches.matches.length, 3);
        expect(
          goRouter.routerDelegate.matches.matches[2].pageKey,
          const Key('/a-p1'),
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

        expect(goRouter.routerDelegate.matches.matches.length, 3);
        expect(
          goRouter.routerDelegate.matches.matches[2].pageKey,
          const Key('/c/c2-p1'),
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

        expect(goRouter.routerDelegate.matches.matches.length, 3);
        expect(
          goRouter.routerDelegate.matches.matches[2].pageKey,
          const Key('/c-p2'),
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
        expect(goRouter.routerDelegate.matches.matches.length, 1);
        expect(goRouter.routerDelegate.canPop(), false);
      },
    );
    testWidgets(
      'It should return true if there is more than 1 match in the stack',
      (WidgetTester tester) async {
        final GoRouter goRouter = await createGoRouter(tester)
          ..push('/a');

        await tester.pumpAndSettle();
        expect(goRouter.routerDelegate.matches.matches.length, 2);
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
      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: goRouter,
        ),
      );

      goRouter.push('/page-0');

      goRouter.routerDelegate.addListener(expectAsync0(() {}));
      final RouteMatch first = goRouter.routerDelegate.matches.matches.first;
      final RouteMatch last = goRouter.routerDelegate.matches.last;
      goRouter.pushReplacement('/page-1');
      expect(goRouter.routerDelegate.matches.matches.length, 2);
      expect(
        goRouter.routerDelegate.matches.matches.first,
        first,
        reason: 'The first match should still be in the list of matches',
      );
      expect(
        goRouter.routerDelegate.matches.last,
        isNot(last),
        reason: 'The last match should have been removed',
      );
      expect(
        (goRouter.routerDelegate.matches.last as ImperativeRouteMatch)
            .matches
            .uri
            .toString(),
        '/page-1',
        reason: 'The new location should have been pushed',
      );
    });

    testWidgets(
      'It should return different pageKey when replace is called',
      (WidgetTester tester) async {
        final GoRouter goRouter = await createGoRouter(tester);
        expect(goRouter.routerDelegate.matches.matches.length, 1);
        expect(
          goRouter.routerDelegate.matches.matches[0].pageKey,
          isNotNull,
        );

        goRouter.push('/a');
        await tester.pumpAndSettle();

        expect(goRouter.routerDelegate.matches.matches.length, 2);
        expect(
          goRouter.routerDelegate.matches.matches.last.pageKey,
          const Key('/a-p1'),
        );

        goRouter.pushReplacement('/a');
        await tester.pumpAndSettle();

        expect(goRouter.routerDelegate.matches.matches.length, 2);
        expect(
          goRouter.routerDelegate.matches.matches.last.pageKey,
          const Key('/a-p2'),
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
        await tester.pumpWidget(
          MaterialApp.router(
            routerConfig: goRouter,
          ),
        );

        goRouter.pushNamed('page0');

        goRouter.routerDelegate.addListener(expectAsync0(() {}));
        final RouteMatch first = goRouter.routerDelegate.matches.matches.first;
        final RouteMatch last = goRouter.routerDelegate.matches.last;
        goRouter.pushReplacementNamed('page1');
        expect(goRouter.routerDelegate.matches.matches.length, 2);
        expect(
          goRouter.routerDelegate.matches.matches.first,
          first,
          reason: 'The first match should still be in the list of matches',
        );
        expect(
          goRouter.routerDelegate.matches.last,
          isNot(last),
          reason: 'The last match should have been removed',
        );
        expect(
          goRouter.routerDelegate.matches.last,
          isA<RouteMatch>().having(
            (RouteMatch match) => (match.route as GoRoute).name,
            'match.route.name',
            'page1',
          ),
          reason: 'The new location should have been pushed',
        );
      },
    );
  });

  testWidgets('dispose unsubscribes from refreshListenable',
      (WidgetTester tester) async {
    final FakeRefreshListenable refreshListenable = FakeRefreshListenable();
    final GoRouter goRouter =
        await createGoRouter(tester, refreshListenable: refreshListenable);
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
