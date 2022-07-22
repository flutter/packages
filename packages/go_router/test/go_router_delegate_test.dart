// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:go_router/src/go_route_match.dart';
import 'package:go_router/src/go_router_error_page.dart';

Future<GoRouter> createGoRouter(
  WidgetTester tester, {
  Listenable? refreshListenable,
}) async {
  final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: <GoRoute>[
      GoRoute(path: '/', builder: (_, __) => const DummyStatefulWidget()),
      GoRoute(
        path: '/error',
        builder: (_, __) => const GoRouterErrorScreen(null),
      ),
    ],
    refreshListenable: refreshListenable,
  );
  await tester.pumpWidget(MaterialApp.router(
      routeInformationProvider: router.routeInformationProvider,
      routeInformationParser: router.routeInformationParser,
      routerDelegate: router.routerDelegate));
  return router;
}

void main() {
  group('pop', () {
    testWidgets('removes the last element', (WidgetTester tester) async {
      final GoRouter goRouter = await createGoRouter(tester)
        ..push('/error');

      goRouter.routerDelegate.addListener(expectAsync0(() {}));
      final GoRouteMatch last = goRouter.routerDelegate.matches.last;
      goRouter.routerDelegate.pop();
      expect(goRouter.routerDelegate.matches.length, 1);
      expect(goRouter.routerDelegate.matches.contains(last), false);
    });

    testWidgets('throws when it pops more than matches count',
        (WidgetTester tester) async {
      final GoRouter goRouter = await createGoRouter(tester)
        ..push('/error');
      expect(
        () => goRouter.routerDelegate
          ..pop()
          ..pop(),
        throwsA(isAssertionError),
      );
    });
  });

  group('canPop', () {
    testWidgets(
      'It should return false if there is only 1 match in the stack',
      (WidgetTester tester) async {
        final GoRouter goRouter = await createGoRouter(tester);

        expect(goRouter.routerDelegate.matches.length, 1);
        expect(goRouter.routerDelegate.canPop(), false);
      },
    );
    testWidgets(
      'It should return true if there is more than 1 match in the stack',
      (WidgetTester tester) async {
        final GoRouter goRouter = await createGoRouter(tester)
          ..push('/error');

        expect(goRouter.routerDelegate.matches.length, 2);
        expect(goRouter.routerDelegate.canPop(), true);
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
            routeInformationProvider: goRouter.routeInformationProvider,
            routeInformationParser: goRouter.routeInformationParser,
            routerDelegate: goRouter.routerDelegate,
          ),
        );

        goRouter.push('/page-0');

        goRouter.routerDelegate.addListener(expectAsync0(() {}));
        final GoRouteMatch first = goRouter.routerDelegate.matches.first;
        final GoRouteMatch last = goRouter.routerDelegate.matches.last;
        goRouter.replace('/page-1');
        expect(goRouter.routerDelegate.matches.length, 2);
        expect(
          goRouter.routerDelegate.matches.first,
          first,
          reason: 'The first match should still be in the list of matches',
        );
        expect(
          goRouter.routerDelegate.matches.last,
          isNot(last),
          reason: 'The last match should have been removed',
        );
        expect(
          goRouter.routerDelegate.matches.last.fullpath,
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
            routeInformationProvider: goRouter.routeInformationProvider,
            routeInformationParser: goRouter.routeInformationParser,
            routerDelegate: goRouter.routerDelegate,
          ),
        );

        goRouter.pushNamed('page0');

        goRouter.routerDelegate.addListener(expectAsync0(() {}));
        final GoRouteMatch first = goRouter.routerDelegate.matches.first;
        final GoRouteMatch last = goRouter.routerDelegate.matches.last;
        goRouter.replaceNamed('page1');
        expect(goRouter.routerDelegate.matches.length, 2);
        expect(
          goRouter.routerDelegate.matches.first,
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
          isA<GoRouteMatch>()
              .having(
                (GoRouteMatch match) => match.fullpath,
                'match.fullpath',
                '/page-1',
              )
              .having(
                (GoRouteMatch match) => match.route.name,
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
  const DummyStatefulWidget({Key? key}) : super(key: key);

  @override
  State<DummyStatefulWidget> createState() => _DummyStatefulWidgetState();
}

class _DummyStatefulWidgetState extends State<DummyStatefulWidget> {
  @override
  Widget build(BuildContext context) => Container();
}
