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

void main() {
  group('pop', () {
    testWidgets('removes the last element', (WidgetTester tester) async {
      final GoRouter goRouter = await createGoRouter(tester)
        ..push('/error');

      goRouter.routerDelegate.addListener(expectAsync0(() {}));
      final GoRouterDelegate delegate =
          goRouter.routerDelegate as GoRouterDelegate;
      final RouteMatch last = delegate.matches.matches.last;
      delegate.pop();
      expect(delegate.matches.matches.length, 1);
      expect(delegate.matches.matches.contains(last), false);
    });

    testWidgets('throws when it pops more than matches count',
        (WidgetTester tester) async {
      final GoRouter goRouter = await createGoRouter(tester)
        ..push('/error');

      final GoRouterDelegate delegate =
          goRouter.routerDelegate as GoRouterDelegate;
      expect(
        () => delegate
          ..pop()
          ..pop(),
        throwsA(isAssertionError),
      );
    });
  });

  group('push', () {
    testWidgets(
      'It should return different pageKey when push is called',
      (WidgetTester tester) async {
        final GoRouter goRouter = await createGoRouter(tester);

        final GoRouterDelegate delegate =
            goRouter.routerDelegate as GoRouterDelegate;
        expect(delegate.matches.matches.length, 1);
        expect(
          delegate.matches.matches[0].pageKey,
          null,
        );

        goRouter.push('/a');
        await tester.pumpAndSettle();

        expect(delegate.matches.matches.length, 2);
        expect(
          delegate.matches.matches[1].pageKey,
          const Key('/a-p1'),
        );

        goRouter.push('/a');
        await tester.pumpAndSettle();

        expect(delegate.matches.matches.length, 3);
        expect(
          delegate.matches.matches[2].pageKey,
          const Key('/a-p2'),
        );
      },
    );
  });

  group('canPop', () {
    testWidgets(
      'It should return false if there is only 1 match in the stack',
      (WidgetTester tester) async {
        final GoRouter goRouter = await createGoRouter(tester);

        final GoRouterDelegate delegate =
            goRouter.routerDelegate as GoRouterDelegate;

        await tester.pumpAndSettle();
        expect(delegate.matches.matches.length, 1);
        expect(delegate.canPop(), false);
      },
    );
    testWidgets(
      'It should return true if there is more than 1 match in the stack',
      (WidgetTester tester) async {
        final GoRouter goRouter = await createGoRouter(tester)
          ..push('/a');

        final GoRouterDelegate delegate =
            goRouter.routerDelegate as GoRouterDelegate;

        await tester.pumpAndSettle();
        expect(delegate.matches.matches.length, 2);
        expect(delegate.canPop(), true);
      },
    );
  });

  group('replace', () {
    testWidgets(
      'It should replace the last match with the given one',
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

        final GoRouterDelegate delegate =
            goRouter.routerDelegate as GoRouterDelegate;
        goRouter.routerDelegate.addListener(expectAsync0(() {}));
        final RouteMatch first = delegate.matches.matches.first;
        final RouteMatch last = delegate.matches.last;
        goRouter.replace('/page-1');
        expect(delegate.matches.matches.length, 2);
        expect(
          delegate.matches.matches.first,
          first,
          reason: 'The first match should still be in the list of matches',
        );
        expect(
          delegate.matches.last,
          isNot(last),
          reason: 'The last match should have been removed',
        );
        expect(
          delegate.matches.last.fullpath,
          '/page-1',
          reason: 'The new location should have been pushed',
        );
      },
    );
  });

  group('replaceNamed', () {
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

        final GoRouterDelegate delegate =
            goRouter.routerDelegate as GoRouterDelegate;

        delegate.addListener(expectAsync0(() {}));
        final RouteMatch first = delegate.matches.matches.first;
        final RouteMatch last = delegate.matches.last;
        goRouter.replaceNamed('page1');
        expect(delegate.matches.matches.length, 2);
        expect(
          delegate.matches.matches.first,
          first,
          reason: 'The first match should still be in the list of matches',
        );
        expect(
          delegate.matches.last,
          isNot(last),
          reason: 'The last match should have been removed',
        );
        expect(
          delegate.matches.last,
          isA<RouteMatch>()
              .having(
                (RouteMatch match) => match.fullpath,
                'match.fullpath',
                '/page-1',
              )
              .having(
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
