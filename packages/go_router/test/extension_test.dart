// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'test_helpers.dart';

void main() {
  final key = GlobalKey<DummyStatefulWidgetState>();
  final routes = <GoRoute>[
    GoRoute(
      path: '/',
      name: 'home',
      builder: (BuildContext context, GoRouterState state) => DummyStatefulWidget(key: key),
    ),
    GoRoute(
      path: '/page1',
      name: 'page1',
      builder: (BuildContext context, GoRouterState state) => const Page1Screen(),
    ),
    GoRoute(
      path: '/page-0/:tab',
      name: 'page-0',
      builder: (BuildContext context, GoRouterState state) => const SizedBox(),
    ),
  ];

  const name = 'page1';
  final params = <String, String>{'a-param-key': 'a-param-value'};
  final queryParams = <String, String>{'a-query-key': 'a-query-value'};
  const location = '/page1';
  const extra = 'Hello';

  group('GoRouterHelper extensions', () {
    testWidgets('calls [canPop] on closest GoRouter', (WidgetTester tester) async {
      final router = GoRouterCanPopSpy(routes: routes, canPopResult: true);
      addTearDown(router.dispose);
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      expect(key.currentContext!.canPop(), isTrue);
      expect(router.canPopCalled, isTrue);
    });

    testWidgets('calls [pushReplacement] on closest GoRouter', (WidgetTester tester) async {
      final router = GoRouterPushReplacementSpy(routes: routes);
      addTearDown(router.dispose);
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      key.currentContext!.pushReplacement(location, extra: extra);
      expect(router.myLocation, location);
      expect(router.extra, extra);
    });

    testWidgets('calls [pushReplacementNamed] on closest GoRouter', (WidgetTester tester) async {
      final router = GoRouterPushReplacementNamedSpy(routes: routes);
      addTearDown(router.dispose);
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      key.currentContext!.pushReplacementNamed(
        name,
        pathParameters: params,
        queryParameters: queryParams,
        extra: extra,
      );
      expect(router.name, name);
      expect(router.pathParameters, params);
      expect(router.queryParameters, queryParams);
      expect(router.extra, extra);
    });

    testWidgets('calls [replace] on closest GoRouter', (WidgetTester tester) async {
      final router = GoRouterReplaceSpy(routes: routes);
      addTearDown(router.dispose);
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      key.currentContext!.replace(location, extra: extra);
      expect(router.myLocation, location);
      expect(router.extra, extra);
    });
  });

  group('replaceNamed', () {
    Future<GoRouter> createGoRouter(WidgetTester tester) async {
      final router = GoRouter(
        initialLocation: '/',
        routes: <GoRoute>[
          GoRoute(path: '/', name: 'home', builder: (_, _) => const _MyWidget()),
          GoRoute(path: '/page-0/:tab', name: 'page-0', builder: (_, _) => const SizedBox()),
        ],
      );
      addTearDown(router.dispose);
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      return router;
    }

    testWidgets('Passes GoRouter parameters through context call.', (WidgetTester tester) async {
      final GoRouter router = await createGoRouter(tester);
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();
      expect(
        router.routerDelegate.currentConfiguration.uri.toString(),
        '/page-0/settings?search=notification',
      );
    });
  });

  group('canPop integration', () {
    testWidgets('returns true on screen B and false after popping back to screen A', (
      WidgetTester tester,
    ) async {
      final screenAKey = GlobalKey();
      final router = GoRouter(
        initialLocation: '/a',
        routes: <GoRoute>[
          GoRoute(
            path: '/a',
            builder: (_, _) => _CanPopScreen(key: screenAKey, label: 'A'),
          ),
          GoRoute(
            path: '/b',
            builder: (_, _) => const _CanPopScreen(label: 'B'),
          ),
        ],
      );
      addTearDown(router.dispose);
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();

      expect(find.text('Screen A'), findsOneWidget);
      expect(find.text('canPop=false'), findsOneWidget);
      expect(router.canPop(), isFalse);

      router.push('/b');
      await tester.pumpAndSettle();

      expect(find.text('Screen B'), findsOneWidget);
      expect(find.text('canPop=true'), findsOneWidget);
      expect(router.canPop(), isTrue);

      router.pop();
      await tester.pumpAndSettle();

      expect(find.text('Screen A'), findsOneWidget);
      expect(find.text('canPop=false'), findsOneWidget);
      expect(router.canPop(), isFalse);
      expect(screenAKey.currentContext!.canPop(), isFalse);
    });

    testWidgets('returns false when navigating with go between sibling routes', (
      WidgetTester tester,
    ) async {
      final router = GoRouter(
        initialLocation: '/a',
        routes: <GoRoute>[
          GoRoute(
            path: '/a',
            builder: (_, _) => const _CanPopScreen(label: 'A'),
          ),
          GoRoute(
            path: '/b',
            builder: (_, _) => const _CanPopScreen(label: 'B'),
          ),
        ],
      );
      addTearDown(router.dispose);
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();

      router.go('/b');
      await tester.pumpAndSettle();

      expect(find.text('Screen B'), findsOneWidget);
      expect(find.text('canPop=false'), findsOneWidget);
      expect(router.canPop(), isFalse);
    });
  });

  group('canPop pop button', () {
    Future<GoRouter> pumpRouter(WidgetTester tester) async {
      final router = GoRouter(
        initialLocation: '/',
        routes: <GoRoute>[
          GoRoute(
            path: '/',
            builder: (_, _) => const _ScreenWithPopButton(label: 'Home'),
          ),
          GoRoute(
            path: '/a',
            builder: (_, _) => const _ScreenWithPopButton(label: 'A'),
          ),
        ],
      );
      addTearDown(router.dispose);
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();
      return router;
    }

    testWidgets('go to A hides pop button because context.canPop() is false', (
      WidgetTester tester,
    ) async {
      final GoRouter router = await pumpRouter(tester);

      expect(find.text('Screen Home'), findsOneWidget);
      expect(find.byType(BackButton), findsNothing);

      router.go('/a');
      await tester.pumpAndSettle();

      expect(find.text('Screen A'), findsOneWidget);
      expect(find.text('canPop=false'), findsOneWidget);
      expect(find.byType(BackButton), findsNothing);
      expect(router.canPop(), isFalse);
    });

    testWidgets('push to A shows pop button and popping returns to Home', (
      WidgetTester tester,
    ) async {
      final GoRouter router = await pumpRouter(tester);

      router.push('/a');
      await tester.pumpAndSettle();

      expect(find.text('Screen A'), findsOneWidget);
      expect(find.text('canPop=true'), findsOneWidget);
      expect(find.byType(BackButton), findsOneWidget);
      expect(router.canPop(), isTrue);

      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();

      expect(find.text('Screen Home'), findsOneWidget);
      expect(find.text('canPop=false'), findsOneWidget);
      expect(find.byType(BackButton), findsNothing);
      expect(router.canPop(), isFalse);
    });

    testWidgets('replace to A hides pop button because context.canPop() is false', (
      WidgetTester tester,
    ) async {
      final GoRouter router = await pumpRouter(tester);

      router.replace('/a');
      await tester.pumpAndSettle();

      expect(find.text('Screen A'), findsOneWidget);
      expect(find.text('canPop=false'), findsOneWidget);
      expect(find.byType(BackButton), findsNothing);
      expect(router.canPop(), isFalse);
      expect(router.routerDelegate.currentConfiguration.uri.path, '/a');
    });
  });

  group('Navigator.of(context).pop()', () {
    Future<GoRouter> pumpRouter(WidgetTester tester, {required PopMethod popMethod}) async {
      final router = GoRouter(
        initialLocation: '/',
        routes: <GoRoute>[
          GoRoute(
            path: '/',
            builder: (_, _) => _ScreenWithPopButton(label: 'Home', popMethod: popMethod),
          ),
          GoRoute(
            path: '/a',
            builder: (_, _) => _ScreenWithPopButton(label: 'A', popMethod: popMethod),
          ),
        ],
      );
      addTearDown(router.dispose);
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();
      return router;
    }

    testWidgets('after push to A, Navigator.pop returns to Home and canPop is false', (
      WidgetTester tester,
    ) async {
      final GoRouter router = await pumpRouter(tester, popMethod: PopMethod.navigator);

      router.push('/a');
      await tester.pumpAndSettle();

      expect(find.text('Screen A'), findsOneWidget);
      expect(find.text('canPop=true'), findsOneWidget);
      expect(find.byType(BackButton), findsOneWidget);

      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();

      expect(find.text('Screen Home'), findsOneWidget);
      expect(find.text('canPop=false'), findsOneWidget);
      expect(find.byType(BackButton), findsNothing);
      expect(router.canPop(), isFalse);
    });

    testWidgets('after go to A, context.canPop() is false so Navigator.pop is not offered', (
      WidgetTester tester,
    ) async {
      final GoRouter router = await pumpRouter(tester, popMethod: PopMethod.navigator);

      router.go('/a');
      await tester.pumpAndSettle();

      expect(find.text('Screen A'), findsOneWidget);
      expect(find.text('canPop=false'), findsOneWidget);
      expect(find.byType(BackButton), findsNothing);
      expect(router.canPop(), isFalse);
    });

    testWidgets('context.pop throws but Navigator.pop is guarded by canPop on go routes', (
      WidgetTester tester,
    ) async {
      final GoRouter router = await pumpRouter(tester, popMethod: PopMethod.goRouter);

      router.go('/a');
      await tester.pumpAndSettle();
      expect(router.canPop(), isFalse);

      expect(router.pop, throwsA(isA<GoError>()));
    });

    testWidgets('push then Navigator.pop behaves the same as context.pop', (
      WidgetTester tester,
    ) async {
      final GoRouter routerNav = await pumpRouter(tester, popMethod: PopMethod.navigator);
      routerNav.push('/a');
      await tester.pumpAndSettle();
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      expect(find.text('Screen Home'), findsOneWidget);
      expect(routerNav.canPop(), isFalse);

      final GoRouter routerGo = GoRouter(
        initialLocation: '/',
        routes: <GoRoute>[
          GoRoute(
            path: '/',
            builder: (_, _) =>
                const _ScreenWithPopButton(label: 'Home', popMethod: PopMethod.goRouter),
          ),
          GoRoute(
            path: '/a',
            builder: (_, _) =>
                const _ScreenWithPopButton(label: 'A', popMethod: PopMethod.goRouter),
          ),
        ],
      );
      addTearDown(routerGo.dispose);
      await tester.pumpWidget(MaterialApp.router(routerConfig: routerGo));
      await tester.pumpAndSettle();

      routerGo.push('/a');
      await tester.pumpAndSettle();
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      expect(find.text('Screen Home'), findsOneWidget);
      expect(routerGo.canPop(), isFalse);
    });
  });

  group('framework Navigator 1.0 widgets', () {
    Future<GoRouter> pumpScaffoldRouter(WidgetTester tester) async {
      final router = GoRouter(
        initialLocation: '/',
        routes: <GoRoute>[
          GoRoute(
            path: '/',
            builder: (_, _) => Scaffold(
              appBar: AppBar(title: const Text('Home')),
              body: const Text('Home body'),
            ),
          ),
          GoRoute(
            path: '/a',
            builder: (_, _) => Scaffold(
              appBar: AppBar(title: const Text('A')),
              body: const Text('A body'),
            ),
          ),
        ],
      );
      addTearDown(router.dispose);
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();
      return router;
    }

    testWidgets('AppBar BackButton uses Navigator.maybePop after push', (
      WidgetTester tester,
    ) async {
      final GoRouter router = await pumpScaffoldRouter(tester);

      router.push('/a');
      await tester.pumpAndSettle();

      // AppBar shows BackButton when ModalRoute.canPop is true (Navigator stack > 1).
      expect(router.canPop(), isTrue);
      expect(find.byType(BackButton), findsOneWidget);

      // Framework BackButton calls Navigator.maybePop — no custom onPressed needed.
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();

      expect(find.text('Home body'), findsOneWidget);
      expect(router.canPop(), isFalse);
      expect(find.byType(BackButton), findsNothing);
    });

    testWidgets('AppBar hides BackButton after go because ModalRoute.canPop is false', (
      WidgetTester tester,
    ) async {
      final GoRouter router = await pumpScaffoldRouter(tester);

      router.go('/a');
      await tester.pumpAndSettle();

      expect(router.canPop(), isFalse);
      expect(find.byType(BackButton), findsNothing);
      expect(find.text('A body'), findsOneWidget);
    });

    testWidgets('showDialog closes with Navigator.pop from framework dialog actions', (
      WidgetTester tester,
    ) async {
      final router = GoRouter(
        initialLocation: '/',
        routes: <GoRoute>[
          GoRoute(
            path: '/',
            builder: (BuildContext context, _) => Scaffold(
              body: ElevatedButton(
                onPressed: () => showDialog<void>(
                  context: context,
                  builder: (BuildContext dialogContext) => AlertDialog(
                    content: const Text('Dialog'),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () => Navigator.of(dialogContext).pop(),
                        child: const Text('Close'),
                      ),
                    ],
                  ),
                ),
                child: const Text('Open'),
              ),
            ),
          ),
        ],
      );
      addTearDown(router.dispose);
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.text('Dialog'), findsOneWidget);
      expect(router.canPop(), isTrue);

      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();

      expect(find.text('Dialog'), findsNothing);
      expect(router.canPop(), isFalse);
    });
  });

  group('mixed Navigator.pop and context.pop', () {
    testWidgets('push A, push B, Navigator.pop, push B, context.pop returns to A correctly', (
      WidgetTester tester,
    ) async {
      final GoRouter router = GoRouter(
        initialLocation: '/home',
        routes: <GoRoute>[
          GoRoute(
            path: '/home',
            builder: (_, _) => const _RouteScreen(label: 'Home'),
          ),
          GoRoute(
            path: '/a',
            builder: (_, _) => const _RouteScreen(label: 'A'),
          ),
          GoRoute(
            path: '/b',
            builder: (_, _) => const _RouteScreen(label: 'B'),
          ),
        ],
      );
      addTearDown(router.dispose);
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();

      expect(find.text('Screen Home'), findsOneWidget);
      expect(router.routerDelegate.currentConfiguration.matches.length, 1);

      router.push('/a');
      await tester.pumpAndSettle();
      expect(find.text('Screen A'), findsOneWidget);
      expect(router.routerDelegate.currentConfiguration.matches.length, 2);
      expect(router.canPop(), isTrue);

      router.push('/b');
      await tester.pumpAndSettle();
      expect(find.text('Screen B'), findsOneWidget);
      expect(router.routerDelegate.currentConfiguration.matches.length, 3);

      // First pop: framework Navigator API from screen B.
      Navigator.of(tester.element(find.text('Screen B'))).pop();
      await tester.pumpAndSettle();
      expect(find.text('Screen A'), findsOneWidget);
      expect(find.text('Screen B'), findsNothing);
      expect(router.routerDelegate.currentConfiguration.matches.length, 2);
      expect(router.canPop(), isTrue);
      // Imperative pushes keep the declarative URL at /home by default.
      expect(router.routerDelegate.currentConfiguration.uri.path, '/home');

      router.push('/b');
      await tester.pumpAndSettle();
      expect(find.text('Screen B'), findsOneWidget);
      expect(router.routerDelegate.currentConfiguration.matches.length, 3);

      // Second pop: GoRouter context.pop from screen B.
      tester.element(find.text('Screen B')).pop();
      await tester.pumpAndSettle();
      expect(find.text('Screen A'), findsOneWidget);
      expect(find.text('Screen B'), findsNothing);
      expect(router.routerDelegate.currentConfiguration.matches.length, 2);
      expect(router.canPop(), isTrue);

      // Third pop: back to home.
      tester.element(find.text('Screen A')).pop();
      await tester.pumpAndSettle();
      expect(find.text('Screen Home'), findsOneWidget);
      expect(router.routerDelegate.currentConfiguration.matches.length, 1);
      expect(router.canPop(), isFalse);
    });
  });
}

class _MyWidget extends StatelessWidget {
  const _MyWidget();

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => context.replaceNamed(
        'page-0',
        pathParameters: <String, String>{'tab': 'settings'},
        queryParameters: <String, String>{'search': 'notification'},
      ),
      child: const Text('Settings'),
    );
  }
}

class _CanPopScreen extends StatelessWidget {
  const _CanPopScreen({required this.label, super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[Text('Screen $label'), Text('canPop=${context.canPop()}')],
    );
  }
}

/// A screen that mirrors common app usage: show a pop button only when
/// [BuildContext.canPop] returns true.
class _ScreenWithPopButton extends StatelessWidget {
  const _ScreenWithPopButton({required this.label, this.popMethod = PopMethod.goRouter});

  final String label;
  final PopMethod popMethod;

  @override
  Widget build(BuildContext context) {
    final bool canPop = context.canPop();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('Screen $label'),
        Text('canPop=$canPop'),
        if (canPop)
          BackButton(
            onPressed: () {
              switch (popMethod) {
                case PopMethod.goRouter:
                  context.pop();
                case PopMethod.navigator:
                  Navigator.of(context).pop();
              }
            },
          ),
      ],
    );
  }
}

enum PopMethod { goRouter, navigator }

class _RouteScreen extends StatelessWidget {
  const _RouteScreen({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) => Text('Screen $label');
}
