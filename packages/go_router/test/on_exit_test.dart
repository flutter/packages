// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'test_helpers.dart';

void main() {
  for (final asynchronous in <bool>[false, true]) {
    testWidgets('chained pops preserve results with ${asynchronous ? 'async' : 'sync'} onExit', (
      WidgetTester tester,
    ) async {
      final results = <String?>[];
      var exits = 0;
      final GoRouter router = await createRouter(<GoRoute>[
        GoRoute(path: '/', builder: (_, _) => const Text('A')),
        GoRoute(path: '/b', builder: (_, _) => const Text('B')),
        GoRoute(
          path: '/c',
          builder: (_, _) => const Text('C'),
          onExit: (_, _) {
            exits += 1;
            return asynchronous ? Future<bool>.value(true) : true;
          },
        ),
      ], tester);
      router.push<String>('/b').then(results.add);
      await tester.pumpAndSettle();
      router.push<String>('/c').then((String? result) {
        results.add(result);
        // Deliberately pop B as soon as C's result is delivered, before a frame.
        router.pop<String>('B:$result');
      });
      await tester.pumpAndSettle();

      router.pop<String>('C');
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(results, <String?>['C', 'B:C']);
      expect(exits, 1);
      expect(find.text('A'), findsOneWidget);
      expect(router.canPop(), isFalse);
    });
  }

  for (final allowExit in <bool>[false, true]) {
    testWidgets('repeated pops share pending onExit that returns $allowExit', (
      WidgetTester tester,
    ) async {
      var approval = Completer<bool>();
      var exits = 0;
      final results = <String?>[];
      final GoRouter router = await createRouter(<GoRoute>[
        GoRoute(path: '/', builder: (_, _) => const Text('A')),
        GoRoute(path: '/b', builder: (_, _) => const Text('B')),
        GoRoute(
          path: '/c',
          builder: (_, _) => const Text('C'),
          onExit: (_, _) {
            exits += 1;
            return approval.future;
          },
        ),
      ], tester);
      router.push<void>('/b');
      await tester.pumpAndSettle();
      router.push<String>('/c').then(results.add);
      await tester.pumpAndSettle();

      router.pop<String>('first');
      router.pop<String>('duplicate');
      await tester.pumpAndSettle();
      expect(exits, 1);
      expect(results, isEmpty);
      expect(find.text('C'), findsOneWidget);

      approval.complete(allowExit);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(results, allowExit ? <String?>['first'] : isEmpty);
      expect(find.text(allowExit ? 'B' : 'C'), findsOneWidget);
      if (!allowExit) {
        approval = Completer<bool>();
        router.pop<String>('retry');
        await tester.pumpAndSettle();
        expect(exits, 2);
        approval.complete(true);
        await tester.pumpAndSettle();
        expect(results, <String?>['retry']);
        expect(find.text('B'), findsOneWidget);
      }
    });
  }

  testWidgets('pending onExit does not pop a newer pushed page', (WidgetTester tester) async {
    final approval = Completer<bool>();
    final results = <String?>[];
    final GoRouter router = await createRouter(<GoRoute>[
      GoRoute(path: '/', builder: (_, _) => const Text('A')),
      GoRoute(path: '/b', builder: (_, _) => const Text('B'), onExit: (_, _) => approval.future),
      GoRoute(path: '/c', builder: (_, _) => const Text('C')),
    ], tester);
    router.push<String>('/b').then(results.add);
    await tester.pumpAndSettle();
    router.pop<String>('stale');
    await tester.pumpAndSettle();
    router.push<String>('/c').then(results.add);
    await tester.pumpAndSettle();

    approval.complete(true);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('C'), findsOneWidget);
    expect(results, isEmpty);
    router.pop<String>('C');
    await tester.pumpAndSettle();
    expect(find.text('B'), findsOneWidget);
    router.pop<String>('B');
    await tester.pumpAndSettle();
    expect(results, <String?>['C', 'B']);
  });

  for (final navigation in <String>['go', 'replace', 'pushReplacement']) {
    testWidgets('pending onExit ignores stale approval after $navigation', (
      WidgetTester tester,
    ) async {
      final approval = Completer<bool>();
      var exits = 0;
      final results = <String?>[];
      final GoRouter router = await createRouter(<GoRoute>[
        GoRoute(path: '/', builder: (_, _) => const Text('A')),
        GoRoute(
          path: '/b',
          builder: (_, _) => const Text('B'),
          onExit: (_, _) => exits++ == 0 ? approval.future : true,
        ),
        GoRoute(path: '/c', builder: (_, _) => const Text('C')),
      ], tester);
      router.push<String>('/b').then(results.add);
      await tester.pumpAndSettle();
      router.pop<String>('stale');
      await tester.pumpAndSettle();

      switch (navigation) {
        case 'go':
          router.go('/c');
        case 'replace':
          router.replace<String>('/c').then(results.add);
        case 'pushReplacement':
          router.pushReplacement<String>('/c').then(results.add);
      }
      // Flush navigation without rebuilding Navigator. The old Route can still
      // be current even though the router's configuration has changed.
      await tester.idle();
      approval.complete(true);
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('C'), findsOneWidget);
      expect(results, isNot(contains('stale')));
    });
  }

  testWidgets('pending onExit is ignored after disposal', (WidgetTester tester) async {
    final approval = Completer<bool>();
    final router = GoRouter(
      routes: <GoRoute>[
        GoRoute(path: '/', builder: (_, _) => const Text('A')),
        GoRoute(path: '/b', builder: (_, _) => const Text('B'), onExit: (_, _) => approval.future),
      ],
    );
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    router.push<void>('/b');
    await tester.pumpAndSettle();
    router.pop();
    await tester.pumpAndSettle();
    await tester.pumpWidget(const SizedBox());
    router.dispose();

    approval.complete(true);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('onExit can approve a pop through a dialog', (WidgetTester tester) async {
    final results = <String?>[];
    final GoRouter router = await createRouter(<GoRoute>[
      GoRoute(path: '/', builder: (_, _) => const Text('A')),
      GoRoute(
        path: '/b',
        builder: (_, _) => const Text('B'),
        onExit: (BuildContext context, GoRouterState state) async {
          return await showDialog<bool>(
                context: context,
                builder: (BuildContext context) => AlertDialog(
                  actions: <Widget>[
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text('Leave'),
                    ),
                  ],
                ),
              ) ??
              false;
        },
      ),
    ], tester);
    router.push<String>('/b').then(results.add);
    await tester.pumpAndSettle();
    router.pop<String>('B');
    await tester.pumpAndSettle();
    expect(find.text('Leave'), findsOneWidget);
    expect(results, isEmpty);

    await tester.tap(find.text('Leave'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(results, <String?>['B']);
    expect(find.text('A'), findsOneWidget);
  });

  testWidgets('pending onExit does not pop a newer pageless route', (WidgetTester tester) async {
    final approval = Completer<bool>();
    final results = <String?>[];
    late BuildContext pageContext;
    final GoRouter router = await createRouter(<GoRoute>[
      GoRoute(path: '/', builder: (_, _) => const Text('A')),
      GoRoute(
        path: '/b',
        builder: (BuildContext context, GoRouterState state) {
          pageContext = context;
          return const Text('B');
        },
        onExit: (_, _) => approval.future,
      ),
    ], tester);
    router.push<String>('/b').then(results.add);
    await tester.pumpAndSettle();
    router.pop<String>('stale');
    await tester.pumpAndSettle();
    showDialog<void>(
      context: pageContext,
      builder: (_) => const AlertDialog(content: Text('Dialog')),
    );
    await tester.pumpAndSettle();

    approval.complete(true);
    await tester.pumpAndSettle();
    expect(find.text('Dialog'), findsOneWidget);
    expect(results, isEmpty);
    router.pop();
    await tester.pumpAndSettle();
    expect(find.text('B'), findsOneWidget);
    router.pop<String>('B');
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(results, <String?>['B']);
  });

  testWidgets('back button works synchronously', (WidgetTester tester) async {
    var allow = false;
    final home = UniqueKey();
    final page1 = UniqueKey();
    final routes = <GoRoute>[
      GoRoute(
        path: '/',
        builder: (BuildContext context, GoRouterState state) => DummyScreen(key: home),
        routes: <GoRoute>[
          GoRoute(
            path: '1',
            builder: (BuildContext context, GoRouterState state) => DummyScreen(key: page1),
            onExit: (BuildContext context, GoRouterState state) {
              return allow;
            },
          ),
        ],
      ),
    ];

    final GoRouter router = await createRouter(routes, tester, initialLocation: '/1');
    expect(find.byKey(page1), findsOneWidget);

    router.pop();
    await tester.pumpAndSettle();
    expect(find.byKey(page1), findsOneWidget);

    allow = true;
    router.pop();
    await tester.pumpAndSettle();
    expect(find.byKey(home), findsOneWidget);
  });

  testWidgets('context.go works synchronously', (WidgetTester tester) async {
    var allow = false;
    final home = UniqueKey();
    final page1 = UniqueKey();
    final routes = <GoRoute>[
      GoRoute(
        path: '/',
        builder: (BuildContext context, GoRouterState state) => DummyScreen(key: home),
      ),
      GoRoute(
        path: '/1',
        builder: (BuildContext context, GoRouterState state) => DummyScreen(key: page1),
        onExit: (BuildContext context, GoRouterState state) {
          return allow;
        },
      ),
    ];

    final GoRouter router = await createRouter(routes, tester, initialLocation: '/1');
    expect(find.byKey(page1), findsOneWidget);

    router.go('/');
    await tester.pumpAndSettle();
    expect(find.byKey(page1), findsOneWidget);

    allow = true;
    router.go('/');
    await tester.pumpAndSettle();
    expect(find.byKey(home), findsOneWidget);
  });

  testWidgets('back button works asynchronously', (WidgetTester tester) async {
    var allow = Completer<bool>();
    final home = UniqueKey();
    final page1 = UniqueKey();
    final routes = <GoRoute>[
      GoRoute(
        path: '/',
        builder: (BuildContext context, GoRouterState state) => DummyScreen(key: home),
        routes: <GoRoute>[
          GoRoute(
            path: '1',
            builder: (BuildContext context, GoRouterState state) => DummyScreen(key: page1),
            onExit: (BuildContext context, GoRouterState state) async {
              return allow.future;
            },
          ),
        ],
      ),
    ];

    final GoRouter router = await createRouter(routes, tester, initialLocation: '/1');
    expect(find.byKey(page1), findsOneWidget);

    router.pop();
    await tester.pumpAndSettle();
    expect(find.byKey(page1), findsOneWidget);

    allow.complete(false);
    await tester.pumpAndSettle();
    expect(find.byKey(page1), findsOneWidget);

    allow = Completer<bool>();
    router.pop();
    await tester.pumpAndSettle();
    expect(find.byKey(page1), findsOneWidget);

    allow.complete(true);
    await tester.pumpAndSettle();
    expect(find.byKey(home), findsOneWidget);
  });

  testWidgets('context.go works asynchronously', (WidgetTester tester) async {
    var allow = Completer<bool>();
    final home = UniqueKey();
    final page1 = UniqueKey();
    final routes = <GoRoute>[
      GoRoute(
        path: '/',
        builder: (BuildContext context, GoRouterState state) => DummyScreen(key: home),
      ),
      GoRoute(
        path: '/1',
        builder: (BuildContext context, GoRouterState state) => DummyScreen(key: page1),
        onExit: (BuildContext context, GoRouterState state) async {
          return allow.future;
        },
      ),
    ];

    final GoRouter router = await createRouter(routes, tester, initialLocation: '/1');
    expect(find.byKey(page1), findsOneWidget);

    router.go('/');
    await tester.pumpAndSettle();
    expect(find.byKey(page1), findsOneWidget);

    allow.complete(false);
    await tester.pumpAndSettle();
    expect(find.byKey(page1), findsOneWidget);

    allow = Completer<bool>();
    router.go('/');
    await tester.pumpAndSettle();
    expect(find.byKey(page1), findsOneWidget);

    allow.complete(true);
    await tester.pumpAndSettle();
    expect(find.byKey(home), findsOneWidget);
  });

  testWidgets('android back button respects the last route.', (WidgetTester tester) async {
    var allow = false;
    final home = UniqueKey();
    final routes = <GoRoute>[
      GoRoute(
        path: '/',
        builder: (BuildContext context, GoRouterState state) => DummyScreen(key: home),
        onExit: (BuildContext context, GoRouterState state) {
          return allow;
        },
      ),
    ];

    final GoRouter router = await createRouter(routes, tester);
    expect(find.byKey(home), findsOneWidget);

    // Not allow system pop.
    expect(await router.routerDelegate.popRoute(), true);

    allow = true;
    expect(await router.routerDelegate.popRoute(), false);
  });

  testWidgets('android back button respects the last route. async', (WidgetTester tester) async {
    var allow = false;
    final home = UniqueKey();
    final routes = <GoRoute>[
      GoRoute(
        path: '/',
        builder: (BuildContext context, GoRouterState state) => DummyScreen(key: home),
        onExit: (BuildContext context, GoRouterState state) async {
          return allow;
        },
      ),
    ];

    final GoRouter router = await createRouter(routes, tester);
    expect(find.byKey(home), findsOneWidget);

    // Not allow system pop.
    expect(await router.routerDelegate.popRoute(), true);

    allow = true;
    expect(await router.routerDelegate.popRoute(), false);
  });

  testWidgets('android back button respects the last route with shell route.', (
    WidgetTester tester,
  ) async {
    var allow = false;
    final home = UniqueKey();
    final routes = <RouteBase>[
      ShellRoute(
        builder: (_, _, Widget child) => child,
        routes: <RouteBase>[
          GoRoute(
            path: '/',
            builder: (BuildContext context, GoRouterState state) => DummyScreen(key: home),
            onExit: (BuildContext context, GoRouterState state) {
              return allow;
            },
          ),
        ],
      ),
    ];

    final GoRouter router = await createRouter(routes, tester);
    expect(find.byKey(home), findsOneWidget);

    // Not allow system pop.
    expect(await router.routerDelegate.popRoute(), true);

    allow = true;
    expect(await router.routerDelegate.popRoute(), false);
  });

  testWidgets('It should provide the correct uri to the onExit callback', (
    WidgetTester tester,
  ) async {
    final home = UniqueKey();
    final page1 = UniqueKey();
    final page2 = UniqueKey();
    final page3 = UniqueKey();
    late final GoRouterState onExitState1;
    late final GoRouterState onExitState2;
    late final GoRouterState onExitState3;
    final routes = <GoRoute>[
      GoRoute(
        path: '/',
        builder: (BuildContext context, GoRouterState state) => DummyScreen(key: home),
        routes: <GoRoute>[
          GoRoute(
            path: '1',
            builder: (BuildContext context, GoRouterState state) => DummyScreen(key: page1),
            onExit: (BuildContext context, GoRouterState state) {
              onExitState1 = state;
              return true;
            },
            routes: <GoRoute>[
              GoRoute(
                path: '2',
                builder: (BuildContext context, GoRouterState state) => DummyScreen(key: page2),
                onExit: (BuildContext context, GoRouterState state) {
                  onExitState2 = state;
                  return true;
                },
                routes: <GoRoute>[
                  GoRoute(
                    path: '3',
                    builder: (BuildContext context, GoRouterState state) => DummyScreen(key: page3),
                    onExit: (BuildContext context, GoRouterState state) {
                      onExitState3 = state;
                      return true;
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ];

    final GoRouter router = await createRouter(routes, tester, initialLocation: '/1/2/3');
    expect(find.byKey(page3), findsOneWidget);

    router.pop();
    await tester.pumpAndSettle();
    expect(find.byKey(page2), findsOneWidget);

    expect(onExitState3.uri.toString(), '/1/2/3');

    router.pop();
    await tester.pumpAndSettle();
    expect(find.byKey(page1), findsOneWidget);
    expect(onExitState2.uri.toString(), '/1/2');

    router.pop();
    await tester.pumpAndSettle();
    expect(find.byKey(home), findsOneWidget);
    expect(onExitState1.uri.toString(), '/1');
  });

  testWidgets('It should provide the correct path parameters to the onExit callback', (
    WidgetTester tester,
  ) async {
    final page0 = UniqueKey();
    final page1 = UniqueKey();
    final page2 = UniqueKey();
    final page3 = UniqueKey();
    late final GoRouterState onExitState1;
    late final GoRouterState onExitState2;
    late final GoRouterState onExitState3;
    final routes = <GoRoute>[
      GoRoute(
        path: '/route-0/:id0',
        builder: (BuildContext context, GoRouterState state) => DummyScreen(key: page0),
      ),
      GoRoute(
        path: '/route-1/:id1',
        builder: (BuildContext context, GoRouterState state) => DummyScreen(key: page1),
        onExit: (BuildContext context, GoRouterState state) {
          onExitState1 = state;
          return true;
        },
      ),
      GoRoute(
        path: '/route-2/:id2',
        builder: (BuildContext context, GoRouterState state) => DummyScreen(key: page2),
        onExit: (BuildContext context, GoRouterState state) {
          onExitState2 = state;
          return true;
        },
      ),
      GoRoute(
        path: '/route-3/:id3',
        builder: (BuildContext context, GoRouterState state) {
          return DummyScreen(key: page3);
        },
        onExit: (BuildContext context, GoRouterState state) {
          onExitState3 = state;
          return true;
        },
      ),
    ];

    final GoRouter router = await createRouter(
      routes,
      tester,
      initialLocation: '/route-0/0?param0=0',
    );
    unawaited(router.push('/route-1/1?param1=1'));
    unawaited(router.push('/route-2/2?param2=2'));
    unawaited(router.push('/route-3/3?param3=3'));

    await tester.pumpAndSettle();
    expect(find.byKey(page3), findsOne);

    router.pop();
    await tester.pumpAndSettle();
    expect(find.byKey(page2), findsOne);
    expect(onExitState3.uri.toString(), '/route-3/3?param3=3');
    expect(onExitState3.pathParameters, const <String, String>{'id3': '3'});
    expect(onExitState3.fullPath, '/route-3/:id3');

    router.pop();
    await tester.pumpAndSettle();
    expect(find.byKey(page1), findsOne);
    expect(onExitState2.uri.toString(), '/route-2/2?param2=2');
    expect(onExitState2.pathParameters, const <String, String>{'id2': '2'});
    expect(onExitState2.fullPath, '/route-2/:id2');

    router.pop();
    await tester.pumpAndSettle();
    expect(find.byKey(page0), findsOne);
    expect(onExitState1.uri.toString(), '/route-1/1?param1=1');
    expect(onExitState1.pathParameters, const <String, String>{'id1': '1'});
    expect(onExitState1.fullPath, '/route-1/:id1');
  });

  testWidgets('It should provide the correct path parameters to the onExit callback during a go', (
    WidgetTester tester,
  ) async {
    final page0 = UniqueKey();
    final page1 = UniqueKey();
    final page2 = UniqueKey();
    final page3 = UniqueKey();
    late final GoRouterState onExitState0;
    late final GoRouterState onExitState1;
    late final GoRouterState onExitState2;
    final routes = <GoRoute>[
      GoRoute(
        path: '/route-0/:id0',
        builder: (BuildContext context, GoRouterState state) => DummyScreen(key: page0),
        onExit: (BuildContext context, GoRouterState state) {
          onExitState0 = state;
          return true;
        },
      ),
      GoRoute(
        path: '/route-1/:id1',
        builder: (BuildContext context, GoRouterState state) => DummyScreen(key: page1),
        onExit: (BuildContext context, GoRouterState state) {
          onExitState1 = state;
          return true;
        },
      ),
      GoRoute(
        path: '/route-2/:id2',
        builder: (BuildContext context, GoRouterState state) => DummyScreen(key: page2),
        onExit: (BuildContext context, GoRouterState state) {
          onExitState2 = state;
          return true;
        },
      ),
      GoRoute(
        path: '/route-3/:id3',
        builder: (BuildContext context, GoRouterState state) {
          return DummyScreen(key: page3);
        },
      ),
    ];

    final GoRouter router = await createRouter(
      routes,
      tester,
      initialLocation: '/route-0/0?param0=0',
    );
    expect(find.byKey(page0), findsOne);

    router.go('/route-1/1?param1=1');
    await tester.pumpAndSettle();
    expect(find.byKey(page1), findsOne);
    expect(onExitState0.uri.toString(), '/route-0/0?param0=0');
    expect(onExitState0.pathParameters, const <String, String>{'id0': '0'});
    expect(onExitState0.fullPath, '/route-0/:id0');

    router.go('/route-2/2?param2=2');
    await tester.pumpAndSettle();
    expect(find.byKey(page2), findsOne);
    expect(onExitState1.uri.toString(), '/route-1/1?param1=1');
    expect(onExitState1.pathParameters, const <String, String>{'id1': '1'});
    expect(onExitState1.fullPath, '/route-1/:id1');

    router.go('/route-3/3?param3=3');
    await tester.pumpAndSettle();
    expect(find.byKey(page3), findsOne);
    expect(onExitState2.uri.toString(), '/route-2/2?param2=2');
    expect(onExitState2.pathParameters, const <String, String>{'id2': '2'});
    expect(onExitState2.fullPath, '/route-2/:id2');
  });

  // Regression test: pop() with onExit + async redirect must not restore
  // stale configuration.
  testWidgets('pop does not call restore with stale config when route has onExit', (
    WidgetTester tester,
  ) async {
    final homeKey = UniqueKey();
    final detailKey = UniqueKey();

    final GoRouter router = await createRouter(
      <RouteBase>[
        GoRoute(
          path: '/',
          builder: (_, _) => DummyScreen(key: homeKey),
          routes: <RouteBase>[
            GoRoute(
              path: 'detail',
              onExit: (_, _) => true,
              builder: (_, _) => DummyScreen(key: detailKey),
            ),
          ],
        ),
      ],
      tester,
      initialLocation: '/detail',
      redirect: (_, GoRouterState state) async {
        // Async redirect — completes in a later microtask.
        await Future<void>.delayed(Duration.zero);
        return null;
      },
    );

    await tester.pumpAndSettle();
    expect(find.byKey(detailKey), findsOneWidget);

    router.pop();
    await tester.pumpAndSettle();

    // The detail route should be gone after pop.
    expect(
      find.byKey(detailKey),
      findsNothing,
      reason:
          'Route with onExit should be properly popped '
          'even when async redirect is present',
    );
    expect(find.byKey(homeKey), findsOneWidget);
  });

  // Verify that pop is correctly cancelled when onExit returns false.
  testWidgets('pop is cancelled when onExit returns false', (WidgetTester tester) async {
    final homeKey = UniqueKey();
    final detailKey = UniqueKey();

    final GoRouter router = await createRouter(
      <RouteBase>[
        GoRoute(
          path: '/',
          builder: (_, _) => DummyScreen(key: homeKey),
          routes: <RouteBase>[
            GoRoute(
              path: 'detail',
              onExit: (_, _) => false, // Always prevent leaving.
              builder: (_, _) => DummyScreen(key: detailKey),
            ),
          ],
        ),
      ],
      tester,
      initialLocation: '/detail',
    );

    await tester.pumpAndSettle();
    expect(find.byKey(detailKey), findsOneWidget);

    router.pop();
    await tester.pumpAndSettle();

    // Should still be on the detail page.
    expect(find.byKey(detailKey), findsOneWidget);
    expect(find.byKey(homeKey), findsNothing);
  });

  // Regression test for https://github.com/flutter/flutter/issues/137829
  testWidgets('back button works synchronously with ShellRoute', (WidgetTester tester) async {
    var allow = false;
    final home = UniqueKey();
    final page = UniqueKey();
    final routes = <RouteBase>[
      GoRoute(
        path: '/',
        builder: (_, _) => DummyScreen(key: home),
        routes: <RouteBase>[
          ShellRoute(
            builder: (_, _, Widget child) => child,
            routes: <RouteBase>[
              GoRoute(
                path: 'page',
                builder: (_, _) => DummyScreen(key: page),
                onExit: (BuildContext context, GoRouterState state) => allow,
              ),
            ],
          ),
        ],
      ),
    ];

    final GoRouter router = await createRouter(routes, tester, initialLocation: '/page');
    expect(find.byKey(page), findsOneWidget);

    router.pop();
    await tester.pumpAndSettle();
    expect(find.byKey(page), findsOneWidget);

    allow = true;
    router.pop();
    await tester.pumpAndSettle();
    expect(find.byKey(home), findsOneWidget);
  });

  // Regression test for https://github.com/flutter/flutter/issues/137829
  testWidgets('back button works asynchronously with ShellRoute', (WidgetTester tester) async {
    var allow = Completer<bool>();
    final home = UniqueKey();
    final page = UniqueKey();
    final routes = <RouteBase>[
      GoRoute(
        path: '/',
        builder: (_, _) => DummyScreen(key: home),
        routes: <RouteBase>[
          ShellRoute(
            builder: (_, _, Widget child) => child,
            routes: <RouteBase>[
              GoRoute(
                path: 'page',
                builder: (_, _) => DummyScreen(key: page),
                onExit: (BuildContext context, GoRouterState state) async => allow.future,
              ),
            ],
          ),
        ],
      ),
    ];

    final GoRouter router = await createRouter(routes, tester, initialLocation: '/page');
    expect(find.byKey(page), findsOneWidget);

    router.pop();
    await tester.pumpAndSettle();
    allow.complete(false);
    await tester.pumpAndSettle();
    expect(find.byKey(page), findsOneWidget);

    allow = Completer<bool>();
    router.pop();
    await tester.pumpAndSettle();
    allow.complete(true);
    await tester.pumpAndSettle();
    expect(find.byKey(home), findsOneWidget);
  });
}
