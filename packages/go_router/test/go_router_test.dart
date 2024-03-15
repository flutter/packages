// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: cascade_invocations, diagnostic_describe_all_properties, unawaited_futures

import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:go_router/src/match.dart';
import 'package:logging/logging.dart';

import 'test_helpers.dart';

const bool enableLogs = false;
final Logger log = Logger('GoRouter tests');

Future<void> sendPlatformUrl(String url, WidgetTester tester) async {
  final Map<String, dynamic> testRouteInformation = <String, dynamic>{
    'location': url,
  };
  final ByteData message = const JSONMethodCodec().encodeMethodCall(
    MethodCall('pushRouteInformation', testRouteInformation),
  );
  await tester.binding.defaultBinaryMessenger
      .handlePlatformMessage('flutter/navigation', message, (_) {});
}

void main() {
  if (enableLogs) {
    Logger.root.onRecord.listen((LogRecord e) => debugPrint('$e'));
  }

  group('path routes', () {
    testWidgets('match home route', (WidgetTester tester) async {
      final List<GoRoute> routes = <GoRoute>[
        GoRoute(
            path: '/',
            builder: (BuildContext context, GoRouterState state) =>
                const HomeScreen()),
      ];

      final GoRouter router = await createRouter(routes, tester);
      final RouteMatchList matches = router.routerDelegate.currentConfiguration;
      expect(matches.matches, hasLength(1));
      expect(matches.uri.toString(), '/');
      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets('If there is more than one route to match, use the first match',
        (WidgetTester tester) async {
      final List<GoRoute> routes = <GoRoute>[
        GoRoute(name: '1', path: '/', builder: dummy),
        GoRoute(name: '2', path: '/', builder: dummy),
      ];

      final GoRouter router = await createRouter(routes, tester);
      router.go('/');
      final List<RouteMatchBase> matches =
          router.routerDelegate.currentConfiguration.matches;
      expect(matches, hasLength(1));
      expect((matches.first.route as GoRoute).name, '1');
      expect(find.byType(DummyScreen), findsOneWidget);
    });

    test('empty path', () {
      expect(() {
        GoRoute(path: '');
      }, throwsA(isAssertionError));
    });

    test('leading / on sub-route', () {
      expect(() {
        GoRouter(
          routes: <RouteBase>[
            GoRoute(
              path: '/',
              builder: dummy,
              routes: <GoRoute>[
                GoRoute(
                  path: '/foo',
                  builder: dummy,
                ),
              ],
            ),
          ],
        );
      }, throwsA(isAssertionError));
    });

    test('trailing / on sub-route', () {
      expect(() {
        GoRouter(
          routes: <RouteBase>[
            GoRoute(
              path: '/',
              builder: dummy,
              routes: <GoRoute>[
                GoRoute(
                  path: 'foo/',
                  builder: dummy,
                ),
              ],
            ),
          ],
        );
      }, throwsA(isAssertionError));
    });

    testWidgets('lack of leading / on top-level route',
        (WidgetTester tester) async {
      await expectLater(() async {
        final List<GoRoute> routes = <GoRoute>[
          GoRoute(path: 'foo', builder: dummy),
        ];
        await createRouter(routes, tester);
      }, throwsA(isAssertionError));
    });

    testWidgets('match no routes', (WidgetTester tester) async {
      final List<GoRoute> routes = <GoRoute>[
        GoRoute(path: '/', builder: dummy),
      ];

      final GoRouter router = await createRouter(
        routes,
        tester,
        errorBuilder: (BuildContext context, GoRouterState state) =>
            TestErrorScreen(state.error!),
      );
      router.go('/foo');
      await tester.pumpAndSettle();
      final List<RouteMatchBase> matches =
          router.routerDelegate.currentConfiguration.matches;
      expect(matches, hasLength(0));
      expect(find.byType(TestErrorScreen), findsOneWidget);
    });

    testWidgets('match 2nd top level route', (WidgetTester tester) async {
      final List<GoRoute> routes = <GoRoute>[
        GoRoute(
            path: '/',
            builder: (BuildContext context, GoRouterState state) =>
                const HomeScreen()),
        GoRoute(
            path: '/login',
            builder: (BuildContext context, GoRouterState state) =>
                const LoginScreen()),
      ];

      final GoRouter router = await createRouter(routes, tester);
      router.go('/login');
      await tester.pumpAndSettle();
      final List<RouteMatchBase> matches =
          router.routerDelegate.currentConfiguration.matches;
      expect(matches, hasLength(1));
      expect(matches.first.matchedLocation, '/login');
      expect(find.byType(LoginScreen), findsOneWidget);
    });

    testWidgets('match 2nd top level route with subroutes',
        (WidgetTester tester) async {
      final List<GoRoute> routes = <GoRoute>[
        GoRoute(
          path: '/',
          builder: (BuildContext context, GoRouterState state) =>
              const HomeScreen(),
          routes: <GoRoute>[
            GoRoute(
                path: 'page1',
                builder: (BuildContext context, GoRouterState state) =>
                    const Page1Screen())
          ],
        ),
        GoRoute(
            path: '/login',
            builder: (BuildContext context, GoRouterState state) =>
                const LoginScreen()),
      ];

      final GoRouter router = await createRouter(routes, tester);
      router.go('/login');
      await tester.pumpAndSettle();
      final List<RouteMatchBase> matches =
          router.routerDelegate.currentConfiguration.matches;
      expect(matches, hasLength(1));
      expect(matches.first.matchedLocation, '/login');
      expect(find.byType(LoginScreen), findsOneWidget);
    });

    testWidgets('match top level route when location has trailing /',
        (WidgetTester tester) async {
      final List<GoRoute> routes = <GoRoute>[
        GoRoute(
          path: '/',
          builder: (BuildContext context, GoRouterState state) =>
              const HomeScreen(),
        ),
        GoRoute(
          path: '/login',
          builder: (BuildContext context, GoRouterState state) =>
              const LoginScreen(),
        ),
      ];

      final GoRouter router = await createRouter(routes, tester);
      router.go('/login/');
      await tester.pumpAndSettle();
      final List<RouteMatchBase> matches =
          router.routerDelegate.currentConfiguration.matches;
      expect(matches, hasLength(1));
      expect(matches.first.matchedLocation, '/login');
      expect(find.byType(LoginScreen), findsOneWidget);
    });

    testWidgets('match top level route when location has trailing / (2)',
        (WidgetTester tester) async {
      final List<GoRoute> routes = <GoRoute>[
        GoRoute(
            path: '/profile',
            builder: dummy,
            redirect: (_, __) => '/profile/foo'),
        GoRoute(path: '/profile/:kind', builder: dummy),
      ];

      final GoRouter router = await createRouter(routes, tester);
      router.go('/profile/');
      await tester.pumpAndSettle();
      final List<RouteMatchBase> matches =
          router.routerDelegate.currentConfiguration.matches;
      expect(matches, hasLength(1));
      expect(matches.first.matchedLocation, '/profile/foo');
      expect(find.byType(DummyScreen), findsOneWidget);
    });

    testWidgets('match top level route when location has trailing / (3)',
        (WidgetTester tester) async {
      final List<GoRoute> routes = <GoRoute>[
        GoRoute(
            path: '/profile',
            builder: dummy,
            redirect: (_, __) => '/profile/foo'),
        GoRoute(path: '/profile/:kind', builder: dummy),
      ];

      final GoRouter router = await createRouter(routes, tester);
      router.go('/profile/?bar=baz');
      await tester.pumpAndSettle();
      final List<RouteMatchBase> matches =
          router.routerDelegate.currentConfiguration.matches;
      expect(matches, hasLength(1));
      expect(matches.first.matchedLocation, '/profile/foo');
      expect(find.byType(DummyScreen), findsOneWidget);
    });

    testWidgets(
        'match top level route when location has scheme/host and has trailing /',
        (WidgetTester tester) async {
      final List<GoRoute> routes = <GoRoute>[
        GoRoute(
          path: '/',
          builder: (BuildContext context, GoRouterState state) =>
              const HomeScreen(),
        ),
      ];

      final GoRouter router = await createRouter(routes, tester);
      router.go('https://www.domain.com/?bar=baz');
      await tester.pumpAndSettle();
      final List<RouteMatchBase> matches =
          router.routerDelegate.currentConfiguration.matches;
      expect(matches, hasLength(1));
      expect(matches.first.matchedLocation, '/');
      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets(
        'match top level route when location has scheme/host and has trailing / (2)',
        (WidgetTester tester) async {
      final List<GoRoute> routes = <GoRoute>[
        GoRoute(
          path: '/',
          builder: (BuildContext context, GoRouterState state) =>
              const HomeScreen(),
        ),
        GoRoute(
          path: '/login',
          builder: (BuildContext context, GoRouterState state) =>
              const LoginScreen(),
        ),
      ];

      final GoRouter router = await createRouter(routes, tester);
      router.go('https://www.domain.com/login/');
      await tester.pumpAndSettle();
      final List<RouteMatchBase> matches =
          router.routerDelegate.currentConfiguration.matches;
      expect(matches, hasLength(1));
      expect(matches.first.matchedLocation, '/login');
      expect(find.byType(LoginScreen), findsOneWidget);
    });

    testWidgets(
        'match top level route when location has scheme/host and has trailing / (3)',
        (WidgetTester tester) async {
      final List<GoRoute> routes = <GoRoute>[
        GoRoute(
            path: '/profile',
            builder: dummy,
            redirect: (_, __) => '/profile/foo'),
        GoRoute(path: '/profile/:kind', builder: dummy),
      ];

      final GoRouter router = await createRouter(routes, tester);
      router.go('https://www.domain.com/profile/');
      await tester.pumpAndSettle();
      final List<RouteMatchBase> matches =
          router.routerDelegate.currentConfiguration.matches;
      expect(matches, hasLength(1));
      expect(matches.first.matchedLocation, '/profile/foo');
      expect(find.byType(DummyScreen), findsOneWidget);
    });

    testWidgets(
        'match top level route when location has scheme/host and has trailing / (4)',
        (WidgetTester tester) async {
      final List<GoRoute> routes = <GoRoute>[
        GoRoute(
            path: '/profile',
            builder: dummy,
            redirect: (_, __) => '/profile/foo'),
        GoRoute(path: '/profile/:kind', builder: dummy),
      ];

      final GoRouter router = await createRouter(routes, tester);
      router.go('https://www.domain.com/profile/?bar=baz');
      await tester.pumpAndSettle();
      final List<RouteMatchBase> matches =
          router.routerDelegate.currentConfiguration.matches;
      expect(matches, hasLength(1));
      expect(matches.first.matchedLocation, '/profile/foo');
      expect(find.byType(DummyScreen), findsOneWidget);
    });

    testWidgets('repeatedly pops imperative route does not crash',
        (WidgetTester tester) async {
      // Regression test for https://github.com/flutter/flutter/issues/123369.
      final UniqueKey home = UniqueKey();
      final UniqueKey settings = UniqueKey();
      final UniqueKey dialog = UniqueKey();
      final GlobalKey<NavigatorState> navKey = GlobalKey<NavigatorState>();
      final List<GoRoute> routes = <GoRoute>[
        GoRoute(
          path: '/',
          builder: (_, __) => DummyScreen(key: home),
        ),
        GoRoute(
          path: '/settings',
          builder: (_, __) => DummyScreen(key: settings),
        ),
      ];
      final GoRouter router =
          await createRouter(routes, tester, navigatorKey: navKey);
      expect(find.byKey(home), findsOneWidget);

      router.push('/settings');
      await tester.pumpAndSettle();
      expect(find.byKey(home), findsNothing);
      expect(find.byKey(settings), findsOneWidget);

      showDialog<void>(
        context: navKey.currentContext!,
        builder: (_) => DummyScreen(key: dialog),
      );
      await tester.pumpAndSettle();
      expect(find.byKey(dialog), findsOneWidget);

      router.pop();
      await tester.pumpAndSettle();
      expect(find.byKey(dialog), findsNothing);
      expect(find.byKey(settings), findsOneWidget);

      showDialog<void>(
        context: navKey.currentContext!,
        builder: (_) => DummyScreen(key: dialog),
      );
      await tester.pumpAndSettle();
      expect(find.byKey(dialog), findsOneWidget);

      router.pop();
      await tester.pumpAndSettle();
      expect(find.byKey(dialog), findsNothing);
      expect(find.byKey(settings), findsOneWidget);
    });

    testWidgets('can correctly pop stacks of repeated pages',
        (WidgetTester tester) async {
      // Regression test for https://github.com/flutter/flutter/issues/#132229.

      final GlobalKey<NavigatorState> navKey = GlobalKey<NavigatorState>();
      final List<GoRoute> routes = <GoRoute>[
        GoRoute(
          path: '/',
          pageBuilder: (_, __) =>
              const MaterialPage<Object>(child: HomeScreen()),
        ),
        GoRoute(
          path: '/page1',
          pageBuilder: (_, __) =>
              const MaterialPage<Object>(child: Page1Screen()),
        ),
        GoRoute(
          path: '/page2',
          pageBuilder: (_, __) =>
              const MaterialPage<Object>(child: Page2Screen()),
        ),
      ];
      final GoRouter router =
          await createRouter(routes, tester, navigatorKey: navKey);
      expect(find.byType(HomeScreen), findsOneWidget);

      router.push('/page1');
      router.push('/page2');
      router.push('/page1');
      router.push('/page2');
      await tester.pumpAndSettle();

      expect(find.byType(HomeScreen), findsNothing);
      expect(find.byType(Page1Screen), findsNothing);
      expect(find.byType(Page2Screen), findsOneWidget);

      router.pop();
      await tester.pumpAndSettle();

      final List<RouteMatchBase> matches =
          router.routerDelegate.currentConfiguration.matches;
      expect(matches.length, 4);
      expect(find.byType(HomeScreen), findsNothing);
      expect(find.byType(Page1Screen), findsOneWidget);
      expect(find.byType(Page2Screen), findsNothing);
    });

    testWidgets('match sub-route', (WidgetTester tester) async {
      final List<GoRoute> routes = <GoRoute>[
        GoRoute(
          path: '/',
          builder: (BuildContext context, GoRouterState state) =>
              const HomeScreen(),
          routes: <GoRoute>[
            GoRoute(
              path: 'login',
              builder: (BuildContext context, GoRouterState state) =>
                  const LoginScreen(),
            ),
          ],
        ),
      ];

      final GoRouter router = await createRouter(routes, tester);
      router.go('/login');
      await tester.pumpAndSettle();
      final List<RouteMatchBase> matches =
          router.routerDelegate.currentConfiguration.matches;
      expect(matches.length, 2);
      expect(matches.first.matchedLocation, '/');
      expect(find.byType(HomeScreen, skipOffstage: false), findsOneWidget);
      expect(matches[1].matchedLocation, '/login');
      expect(find.byType(LoginScreen), findsOneWidget);
    });

    testWidgets('match sub-routes', (WidgetTester tester) async {
      final List<GoRoute> routes = <GoRoute>[
        GoRoute(
          path: '/',
          builder: (BuildContext context, GoRouterState state) =>
              const HomeScreen(),
          routes: <GoRoute>[
            GoRoute(
              path: 'family/:fid',
              builder: (BuildContext context, GoRouterState state) =>
                  const FamilyScreen('dummy'),
              routes: <GoRoute>[
                GoRoute(
                  path: 'person/:pid',
                  builder: (BuildContext context, GoRouterState state) =>
                      const PersonScreen('dummy', 'dummy'),
                ),
              ],
            ),
            GoRoute(
              path: 'login',
              builder: (BuildContext context, GoRouterState state) =>
                  const LoginScreen(),
            ),
          ],
        ),
      ];

      final GoRouter router = await createRouter(routes, tester);
      {
        final RouteMatchList matches =
            router.routerDelegate.currentConfiguration;
        expect(matches.matches, hasLength(1));
        expect(matches.uri.toString(), '/');
        expect(find.byType(HomeScreen), findsOneWidget);
      }

      router.go('/login');
      await tester.pumpAndSettle();
      {
        final RouteMatchList matches =
            router.routerDelegate.currentConfiguration;
        expect(matches.matches.length, 2);
        expect(matches.matches.first.matchedLocation, '/');
        expect(find.byType(HomeScreen, skipOffstage: false), findsOneWidget);
        expect(matches.matches[1].matchedLocation, '/login');
        expect(find.byType(LoginScreen), findsOneWidget);
      }

      router.go('/family/f2');
      await tester.pumpAndSettle();
      {
        final RouteMatchList matches =
            router.routerDelegate.currentConfiguration;
        expect(matches.matches.length, 2);
        expect(matches.matches.first.matchedLocation, '/');
        expect(find.byType(HomeScreen, skipOffstage: false), findsOneWidget);
        expect(matches.matches[1].matchedLocation, '/family/f2');
        expect(find.byType(FamilyScreen), findsOneWidget);
      }

      router.go('/family/f2/person/p1');
      await tester.pumpAndSettle();
      {
        final RouteMatchList matches =
            router.routerDelegate.currentConfiguration;
        expect(matches.matches.length, 3);
        expect(matches.matches.first.matchedLocation, '/');
        expect(find.byType(HomeScreen, skipOffstage: false), findsOneWidget);
        expect(matches.matches[1].matchedLocation, '/family/f2');
        expect(find.byType(FamilyScreen, skipOffstage: false), findsOneWidget);
        expect(matches.matches[2].matchedLocation, '/family/f2/person/p1');
        expect(find.byType(PersonScreen), findsOneWidget);
      }
    });

    testWidgets('return first matching route if too many subroutes',
        (WidgetTester tester) async {
      final List<GoRoute> routes = <GoRoute>[
        GoRoute(
          path: '/',
          builder: (BuildContext context, GoRouterState state) =>
              const HomeScreen(),
          routes: <GoRoute>[
            GoRoute(
              path: 'foo/bar',
              builder: (BuildContext context, GoRouterState state) =>
                  const FamilyScreen(''),
            ),
            GoRoute(
              path: 'bar',
              builder: (BuildContext context, GoRouterState state) =>
                  const Page1Screen(),
            ),
            GoRoute(
              path: 'foo',
              builder: (BuildContext context, GoRouterState state) =>
                  const Page2Screen(),
              routes: <GoRoute>[
                GoRoute(
                  path: 'bar',
                  builder: (BuildContext context, GoRouterState state) =>
                      const LoginScreen(),
                ),
              ],
            ),
          ],
        ),
      ];

      final GoRouter router = await createRouter(routes, tester);
      router.go('/bar');
      await tester.pumpAndSettle();
      List<RouteMatchBase> matches =
          router.routerDelegate.currentConfiguration.matches;
      expect(matches, hasLength(2));
      expect(find.byType(Page1Screen), findsOneWidget);

      router.go('/foo/bar');
      await tester.pumpAndSettle();
      matches = router.routerDelegate.currentConfiguration.matches;
      expect(matches, hasLength(2));
      expect(find.byType(FamilyScreen), findsOneWidget);

      router.go('/foo');
      await tester.pumpAndSettle();
      matches = router.routerDelegate.currentConfiguration.matches;
      expect(matches, hasLength(2));
      expect(find.byType(Page2Screen), findsOneWidget);
    });

    testWidgets('router state', (WidgetTester tester) async {
      final List<GoRoute> routes = <GoRoute>[
        GoRoute(
          name: 'home',
          path: '/',
          builder: (BuildContext context, GoRouterState state) {
            expect(state.uri.toString(), '/');
            expect(state.matchedLocation, '/');
            expect(state.name, 'home');
            expect(state.path, '/');
            expect(state.fullPath, '/');
            expect(state.pathParameters, <String, String>{});
            expect(state.error, null);
            if (state.extra != null) {
              expect(state.extra! as int, 1);
            }
            return const HomeScreen();
          },
          routes: <GoRoute>[
            GoRoute(
              name: 'login',
              path: 'login',
              builder: (BuildContext context, GoRouterState state) {
                expect(state.uri.toString(), '/login');
                expect(state.matchedLocation, '/login');
                expect(state.name, 'login');
                expect(state.path, 'login');
                expect(state.fullPath, '/login');
                expect(state.pathParameters, <String, String>{});
                expect(state.error, null);
                expect(state.extra! as int, 2);
                return const LoginScreen();
              },
            ),
            GoRoute(
              name: 'family',
              path: 'family/:fid',
              builder: (BuildContext context, GoRouterState state) {
                expect(
                  state.uri.toString(),
                  anyOf(<String>['/family/f2', '/family/f2/person/p1']),
                );
                expect(state.matchedLocation, '/family/f2');
                expect(state.name, 'family');
                expect(state.path, 'family/:fid');
                expect(state.fullPath, '/family/:fid');
                expect(state.pathParameters, <String, String>{'fid': 'f2'});
                expect(state.error, null);
                expect(state.extra! as int, 3);
                return FamilyScreen(state.pathParameters['fid']!);
              },
              routes: <GoRoute>[
                GoRoute(
                  name: 'person',
                  path: 'person/:pid',
                  builder: (BuildContext context, GoRouterState state) {
                    expect(state.uri.toString(), '/family/f2/person/p1');
                    expect(state.matchedLocation, '/family/f2/person/p1');
                    expect(state.name, 'person');
                    expect(state.path, 'person/:pid');
                    expect(state.fullPath, '/family/:fid/person/:pid');
                    expect(
                      state.pathParameters,
                      <String, String>{'fid': 'f2', 'pid': 'p1'},
                    );
                    expect(state.error, null);
                    expect(state.extra! as int, 4);
                    return PersonScreen(state.pathParameters['fid']!,
                        state.pathParameters['pid']!);
                  },
                ),
              ],
            ),
          ],
        ),
      ];

      final GoRouter router = await createRouter(routes, tester);
      router.go('/', extra: 1);
      await tester.pump();
      router.push('/login', extra: 2);
      await tester.pump();
      router.push('/family/f2', extra: 3);
      await tester.pump();
      router.push('/family/f2/person/p1', extra: 4);
      await tester.pump();
    });

    testWidgets('match path case insensitively', (WidgetTester tester) async {
      final List<GoRoute> routes = <GoRoute>[
        GoRoute(
          path: '/',
          builder: (BuildContext context, GoRouterState state) =>
              const HomeScreen(),
        ),
        GoRoute(
          path: '/family/:fid',
          builder: (BuildContext context, GoRouterState state) =>
              FamilyScreen(state.pathParameters['fid']!),
        ),
      ];

      final GoRouter router = await createRouter(routes, tester);
      const String loc = '/FaMiLy/f2';
      router.go(loc);
      await tester.pumpAndSettle();
      final List<RouteMatchBase> matches =
          router.routerDelegate.currentConfiguration.matches;

      // NOTE: match the lower case, since location is canonicalized to match the
      // path case whereas the location can be any case; so long as the path
      // produces a match regardless of the location case, we win!
      expect(
          router.routerDelegate.currentConfiguration.uri
              .toString()
              .toLowerCase(),
          loc.toLowerCase());

      expect(matches, hasLength(1));
      expect(find.byType(FamilyScreen), findsOneWidget);
    });

    testWidgets(
        'If there is more than one route to match, use the first match.',
        (WidgetTester tester) async {
      final List<GoRoute> routes = <GoRoute>[
        GoRoute(path: '/', builder: dummy),
        GoRoute(path: '/page1', builder: dummy),
        GoRoute(path: '/page1', builder: dummy),
        GoRoute(path: '/:ok', builder: dummy),
      ];

      final GoRouter router = await createRouter(routes, tester);
      router.go('/user');
      await tester.pumpAndSettle();
      final List<RouteMatchBase> matches =
          router.routerDelegate.currentConfiguration.matches;
      expect(matches, hasLength(1));
      expect(find.byType(DummyScreen), findsOneWidget);
    });

    testWidgets('Handles the Android back button correctly',
        (WidgetTester tester) async {
      final List<RouteBase> routes = <RouteBase>[
        GoRoute(
          path: '/',
          builder: (BuildContext context, GoRouterState state) {
            return const Scaffold(
              body: Text('Screen A'),
            );
          },
          routes: <RouteBase>[
            GoRoute(
              path: 'b',
              builder: (BuildContext context, GoRouterState state) {
                return const Scaffold(
                  body: Text('Screen B'),
                );
              },
            ),
          ],
        ),
      ];

      await createRouter(routes, tester, initialLocation: '/b');
      expect(find.text('Screen A'), findsNothing);
      expect(find.text('Screen B'), findsOneWidget);

      await simulateAndroidBackButton(tester);
      await tester.pumpAndSettle();
      expect(find.text('Screen A'), findsOneWidget);
      expect(find.text('Screen B'), findsNothing);
    });

    testWidgets('Handles the Android back button correctly with ShellRoute',
        (WidgetTester tester) async {
      final GlobalKey<NavigatorState> rootNavigatorKey =
          GlobalKey<NavigatorState>();

      final List<RouteBase> routes = <RouteBase>[
        ShellRoute(
          builder: (BuildContext context, GoRouterState state, Widget child) {
            return Scaffold(
              appBar: AppBar(title: const Text('Shell')),
              body: child,
            );
          },
          routes: <GoRoute>[
            GoRoute(
              path: '/a',
              builder: (BuildContext context, GoRouterState state) {
                return const Scaffold(
                  body: Text('Screen A'),
                );
              },
              routes: <GoRoute>[
                GoRoute(
                  path: 'b',
                  builder: (BuildContext context, GoRouterState state) {
                    return const Scaffold(
                      body: Text('Screen B'),
                    );
                  },
                  routes: <GoRoute>[
                    GoRoute(
                      path: 'c',
                      builder: (BuildContext context, GoRouterState state) {
                        return const Scaffold(
                          body: Text('Screen C'),
                        );
                      },
                      routes: <GoRoute>[
                        GoRoute(
                          path: 'd',
                          parentNavigatorKey: rootNavigatorKey,
                          builder: (BuildContext context, GoRouterState state) {
                            return const Scaffold(
                              body: Text('Screen D'),
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
        ),
      ];

      await createRouter(routes, tester,
          initialLocation: '/a/b/c/d', navigatorKey: rootNavigatorKey);
      expect(find.text('Shell'), findsNothing);
      expect(find.text('Screen A'), findsNothing);
      expect(find.text('Screen B'), findsNothing);
      expect(find.text('Screen C'), findsNothing);
      expect(find.text('Screen D'), findsOneWidget);

      await simulateAndroidBackButton(tester);
      await tester.pumpAndSettle();
      expect(find.text('Shell'), findsOneWidget);
      expect(find.text('Screen A'), findsNothing);
      expect(find.text('Screen B'), findsNothing);
      expect(find.text('Screen C'), findsOneWidget);
      expect(find.text('Screen D'), findsNothing);

      await simulateAndroidBackButton(tester);
      await tester.pumpAndSettle();
      expect(find.text('Shell'), findsOneWidget);
      expect(find.text('Screen A'), findsNothing);
      expect(find.text('Screen B'), findsOneWidget);
      expect(find.text('Screen C'), findsNothing);
    });

    testWidgets(
        'Handles the Android back button when parentNavigatorKey is set to the root navigator',
        (WidgetTester tester) async {
      final List<MethodCall> log = <MethodCall>[];
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform,
              (MethodCall methodCall) async {
        log.add(methodCall);
        return null;
      });

      Future<void> verify(AsyncCallback test, List<Object> expectations) async {
        log.clear();
        await test();
        expect(log, expectations);
      }

      final GlobalKey<NavigatorState> rootNavigatorKey =
          GlobalKey<NavigatorState>();

      final List<RouteBase> routes = <RouteBase>[
        GoRoute(
          parentNavigatorKey: rootNavigatorKey,
          path: '/a',
          builder: (BuildContext context, GoRouterState state) {
            return const Scaffold(
              body: Text('Screen A'),
            );
          },
        ),
      ];

      await createRouter(routes, tester,
          initialLocation: '/a', navigatorKey: rootNavigatorKey);
      expect(find.text('Screen A'), findsOneWidget);

      await tester.runAsync(() async {
        await verify(() => simulateAndroidBackButton(tester), <Object>[
          isMethodCall('SystemNavigator.pop', arguments: null),
        ]);
      });
    });

    testWidgets("Handles the Android back button when ShellRoute can't pop",
        (WidgetTester tester) async {
      final List<MethodCall> log = <MethodCall>[];
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform,
              (MethodCall methodCall) async {
        log.add(methodCall);
        return null;
      });

      Future<void> verify(AsyncCallback test, List<Object> expectations) async {
        log.clear();
        await test();
        expect(log, expectations);
      }

      final GlobalKey<NavigatorState> rootNavigatorKey =
          GlobalKey<NavigatorState>();

      final List<RouteBase> routes = <RouteBase>[
        GoRoute(
          parentNavigatorKey: rootNavigatorKey,
          path: '/a',
          builder: (BuildContext context, GoRouterState state) {
            return const Scaffold(
              body: Text('Screen A'),
            );
          },
        ),
        ShellRoute(
          builder: (BuildContext context, GoRouterState state, Widget child) {
            return Scaffold(
              appBar: AppBar(
                title: const Text('Shell'),
              ),
              body: child,
            );
          },
          routes: <RouteBase>[
            GoRoute(
              path: '/b',
              builder: (BuildContext context, GoRouterState state) {
                return const Scaffold(
                  body: Text('Screen B'),
                );
              },
            ),
          ],
        ),
      ];

      await createRouter(routes, tester,
          initialLocation: '/b', navigatorKey: rootNavigatorKey);
      expect(find.text('Screen B'), findsOneWidget);

      await tester.runAsync(() async {
        await verify(() => simulateAndroidBackButton(tester), <Object>[
          isMethodCall('SystemNavigator.pop', arguments: null),
        ]);
      });
    });
  });

  testWidgets('does not crash when inherited widget changes',
      (WidgetTester tester) async {
    final ValueNotifier<String> notifier = ValueNotifier<String>('initial');

    addTearDown(notifier.dispose);
    final List<GoRoute> routes = <GoRoute>[
      GoRoute(
          path: '/',
          pageBuilder: (BuildContext context, GoRouterState state) {
            final String value = context
                .dependOnInheritedWidgetOfExactType<TestInheritedNotifier>()!
                .notifier!
                .value;
            return MaterialPage<void>(
              key: state.pageKey,
              child: Text(value),
            );
          }),
    ];
    final GoRouter router = GoRouter(
      routes: routes,
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      MaterialApp.router(
        routerConfig: router,
        builder: (BuildContext context, Widget? child) {
          return TestInheritedNotifier(notifier: notifier, child: child!);
        },
      ),
    );

    expect(find.text(notifier.value), findsOneWidget);
    notifier.value = 'updated';
    await tester.pump();
    expect(find.text(notifier.value), findsOneWidget);
  });

  testWidgets(
      'Handles the Android back button when a second Shell has a GoRoute with parentNavigator key',
      (WidgetTester tester) async {
    final List<MethodCall> log = <MethodCall>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform,
            (MethodCall methodCall) async {
      log.add(methodCall);
      return null;
    });

    Future<void> verify(AsyncCallback test, List<Object> expectations) async {
      log.clear();
      await test();
      expect(log, expectations);
    }

    final GlobalKey<NavigatorState> rootNavigatorKey =
        GlobalKey<NavigatorState>();
    final GlobalKey<NavigatorState> shellNavigatorKeyA =
        GlobalKey<NavigatorState>();
    final GlobalKey<NavigatorState> shellNavigatorKeyB =
        GlobalKey<NavigatorState>();

    final List<RouteBase> routes = <RouteBase>[
      ShellRoute(
        navigatorKey: shellNavigatorKeyA,
        builder: (BuildContext context, GoRouterState state, Widget child) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Shell'),
            ),
            body: child,
          );
        },
        routes: <RouteBase>[
          GoRoute(
            path: '/a',
            builder: (BuildContext context, GoRouterState state) {
              return const Scaffold(
                body: Text('Screen A'),
              );
            },
            routes: <RouteBase>[
              ShellRoute(
                navigatorKey: shellNavigatorKeyB,
                builder:
                    (BuildContext context, GoRouterState state, Widget child) {
                  return Scaffold(
                    appBar: AppBar(
                      title: const Text('Shell'),
                    ),
                    body: child,
                  );
                },
                routes: <RouteBase>[
                  GoRoute(
                    path: 'b',
                    parentNavigatorKey: shellNavigatorKeyB,
                    builder: (BuildContext context, GoRouterState state) {
                      return const Scaffold(
                        body: Text('Screen B'),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ];

    await createRouter(routes, tester,
        initialLocation: '/a/b', navigatorKey: rootNavigatorKey);
    expect(find.text('Screen B'), findsOneWidget);

    // The first pop should not exit the app.
    await tester.runAsync(() async {
      await verify(() => simulateAndroidBackButton(tester), <Object>[]);
    });

    // The second pop should exit the app.
    await tester.runAsync(() async {
      await verify(() => simulateAndroidBackButton(tester), <Object>[
        isMethodCall('SystemNavigator.pop', arguments: null),
      ]);
    });
  });

  group('report correct url', () {
    final List<MethodCall> log = <MethodCall>[];
    setUp(() {
      GoRouter.optionURLReflectsImperativeAPIs = false;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.navigation,
              (MethodCall methodCall) async {
        log.add(methodCall);
        return null;
      });
    });
    tearDown(() {
      GoRouter.optionURLReflectsImperativeAPIs = false;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.navigation, null);
      log.clear();
    });

    testWidgets(
        'on push shell route with optionURLReflectImperativeAPIs = true',
        (WidgetTester tester) async {
      GoRouter.optionURLReflectsImperativeAPIs = true;
      final List<RouteBase> routes = <RouteBase>[
        GoRoute(
          path: '/',
          builder: (BuildContext context, GoRouterState state) =>
              const DummyScreen(),
          routes: <RouteBase>[
            ShellRoute(
              builder:
                  (BuildContext context, GoRouterState state, Widget child) =>
                      child,
              routes: <RouteBase>[
                GoRoute(
                  path: 'c',
                  builder: (BuildContext context, GoRouterState state) =>
                      const DummyScreen(),
                )
              ],
            ),
          ],
        ),
      ];

      final GoRouter router = await createRouter(routes, tester);

      log.clear();
      router.push('/c?foo=bar');
      final RouteMatchListCodec codec =
          RouteMatchListCodec(router.configuration);
      await tester.pumpAndSettle();
      expect(log, <Object>[
        isMethodCall('selectMultiEntryHistory', arguments: null),
        IsRouteUpdateCall('/c?foo=bar', false,
            codec.encode(router.routerDelegate.currentConfiguration)),
      ]);
      GoRouter.optionURLReflectsImperativeAPIs = false;
    });

    testWidgets('on push with optionURLReflectImperativeAPIs = true',
        (WidgetTester tester) async {
      GoRouter.optionURLReflectsImperativeAPIs = true;
      final List<GoRoute> routes = <GoRoute>[
        GoRoute(
          path: '/',
          builder: (_, __) => const DummyScreen(),
        ),
        GoRoute(
          path: '/settings',
          builder: (_, __) => const DummyScreen(),
        ),
      ];

      final GoRouter router = await createRouter(routes, tester);

      log.clear();
      router.push('/settings');
      final RouteMatchListCodec codec =
          RouteMatchListCodec(router.configuration);
      await tester.pumpAndSettle();
      expect(log, <Object>[
        isMethodCall('selectMultiEntryHistory', arguments: null),
        IsRouteUpdateCall('/settings', false,
            codec.encode(router.routerDelegate.currentConfiguration)),
      ]);
      GoRouter.optionURLReflectsImperativeAPIs = false;
    });

    testWidgets('on push', (WidgetTester tester) async {
      final List<GoRoute> routes = <GoRoute>[
        GoRoute(
          path: '/',
          builder: (_, __) => const DummyScreen(),
        ),
        GoRoute(
          path: '/settings',
          builder: (_, __) => const DummyScreen(),
        ),
      ];

      final GoRouter router = await createRouter(routes, tester);

      log.clear();
      router.push('/settings');
      final RouteMatchListCodec codec =
          RouteMatchListCodec(router.configuration);
      await tester.pumpAndSettle();
      expect(log, <Object>[
        isMethodCall('selectMultiEntryHistory', arguments: null),
        IsRouteUpdateCall('/', false,
            codec.encode(router.routerDelegate.currentConfiguration)),
      ]);
    });

    testWidgets('on pop', (WidgetTester tester) async {
      final List<GoRoute> routes = <GoRoute>[
        GoRoute(
            path: '/',
            builder: (_, __) => const DummyScreen(),
            routes: <RouteBase>[
              GoRoute(
                path: 'settings',
                builder: (_, __) => const DummyScreen(),
              ),
            ]),
      ];

      final GoRouter router =
          await createRouter(routes, tester, initialLocation: '/settings');
      final RouteMatchListCodec codec =
          RouteMatchListCodec(router.configuration);
      log.clear();
      router.pop();
      await tester.pumpAndSettle();
      expect(log, <Object>[
        isMethodCall('selectMultiEntryHistory', arguments: null),
        IsRouteUpdateCall('/', false,
            codec.encode(router.routerDelegate.currentConfiguration)),
      ]);
    });

    testWidgets('on pop twice', (WidgetTester tester) async {
      final List<GoRoute> routes = <GoRoute>[
        GoRoute(
            path: '/',
            builder: (_, __) => const DummyScreen(),
            routes: <RouteBase>[
              GoRoute(
                  path: 'settings',
                  builder: (_, __) => const DummyScreen(),
                  routes: <RouteBase>[
                    GoRoute(
                      path: 'profile',
                      builder: (_, __) => const DummyScreen(),
                    ),
                  ]),
            ]),
      ];

      final GoRouter router = await createRouter(routes, tester,
          initialLocation: '/settings/profile');
      final RouteMatchListCodec codec =
          RouteMatchListCodec(router.configuration);
      log.clear();
      router.pop();
      router.pop();
      await tester.pumpAndSettle();
      expect(log, <Object>[
        isMethodCall('selectMultiEntryHistory', arguments: null),
        IsRouteUpdateCall('/', false,
            codec.encode(router.routerDelegate.currentConfiguration)),
      ]);
    });

    testWidgets('on pop with path parameters', (WidgetTester tester) async {
      final List<GoRoute> routes = <GoRoute>[
        GoRoute(
            path: '/',
            builder: (_, __) => const DummyScreen(),
            routes: <RouteBase>[
              GoRoute(
                path: 'settings/:id',
                builder: (_, __) => const DummyScreen(),
              ),
            ]),
      ];

      final GoRouter router =
          await createRouter(routes, tester, initialLocation: '/settings/123');
      final RouteMatchListCodec codec =
          RouteMatchListCodec(router.configuration);
      log.clear();
      router.pop();
      await tester.pumpAndSettle();
      expect(log, <Object>[
        isMethodCall('selectMultiEntryHistory', arguments: null),
        IsRouteUpdateCall('/', false,
            codec.encode(router.routerDelegate.currentConfiguration)),
      ]);
    });

    testWidgets('on pop with path parameters case 2',
        (WidgetTester tester) async {
      final List<GoRoute> routes = <GoRoute>[
        GoRoute(
            path: '/',
            builder: (_, __) => const DummyScreen(),
            routes: <RouteBase>[
              GoRoute(
                path: ':id',
                builder: (_, __) => const DummyScreen(),
              ),
            ]),
      ];

      final GoRouter router =
          await createRouter(routes, tester, initialLocation: '/123/');
      final RouteMatchListCodec codec =
          RouteMatchListCodec(router.configuration);
      log.clear();
      router.pop();
      await tester.pumpAndSettle();
      expect(log, <Object>[
        isMethodCall('selectMultiEntryHistory', arguments: null),
        IsRouteUpdateCall('/', false,
            codec.encode(router.routerDelegate.currentConfiguration)),
      ]);
    });

    testWidgets('Can manually pop root navigator and display correct url',
        (WidgetTester tester) async {
      final GlobalKey<NavigatorState> rootNavigatorKey =
          GlobalKey<NavigatorState>();

      final List<RouteBase> routes = <RouteBase>[
        GoRoute(
          path: '/',
          builder: (BuildContext context, GoRouterState state) {
            return const Scaffold(
              body: Text('Home'),
            );
          },
          routes: <RouteBase>[
            ShellRoute(
              builder:
                  (BuildContext context, GoRouterState state, Widget child) {
                return Scaffold(
                  appBar: AppBar(),
                  body: child,
                );
              },
              routes: <RouteBase>[
                GoRoute(
                  path: 'b',
                  builder: (BuildContext context, GoRouterState state) {
                    return const Scaffold(
                      body: Text('Screen B'),
                    );
                  },
                  routes: <RouteBase>[
                    GoRoute(
                      path: 'c',
                      builder: (BuildContext context, GoRouterState state) {
                        return const Scaffold(
                          body: Text('Screen C'),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ];

      final GoRouter router = await createRouter(routes, tester,
          initialLocation: '/b/c', navigatorKey: rootNavigatorKey);
      final RouteMatchListCodec codec =
          RouteMatchListCodec(router.configuration);
      expect(find.text('Screen C'), findsOneWidget);
      expect(log, <Object>[
        isMethodCall('selectMultiEntryHistory', arguments: null),
        IsRouteUpdateCall('/b/c', true,
            codec.encode(router.routerDelegate.currentConfiguration)),
      ]);

      log.clear();
      rootNavigatorKey.currentState!.pop();
      await tester.pumpAndSettle();

      expect(find.text('Home'), findsOneWidget);
      expect(log, <Object>[
        isMethodCall('selectMultiEntryHistory', arguments: null),
        IsRouteUpdateCall('/', false,
            codec.encode(router.routerDelegate.currentConfiguration)),
      ]);
    });

    testWidgets('can handle route information update from browser',
        (WidgetTester tester) async {
      final List<GoRoute> routes = <GoRoute>[
        GoRoute(
          path: '/',
          builder: (_, __) => const DummyScreen(key: ValueKey<String>('home')),
          routes: <RouteBase>[
            GoRoute(
              path: 'settings',
              builder: (_, GoRouterState state) =>
                  DummyScreen(key: ValueKey<String>('settings-${state.extra}')),
            ),
          ],
        ),
      ];

      final GoRouter router = await createRouter(routes, tester);
      expect(find.byKey(const ValueKey<String>('home')), findsOneWidget);

      router.push('/settings', extra: 0);
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey<String>('settings-0')), findsOneWidget);

      log.clear();
      router.push('/settings', extra: 1);
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey<String>('settings-1')), findsOneWidget);

      final Map<Object?, Object?> arguments =
          log.last.arguments as Map<Object?, Object?>;
      // Stores the state after the last push. This should contain the encoded
      // RouteMatchList.
      final Object? state =
          (log.last.arguments as Map<Object?, Object?>)['state'];
      final String location =
          (arguments['location'] ?? arguments['uri']!) as String;

      router.go('/');
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey<String>('home')), findsOneWidget);

      router.routeInformationProvider.didPushRouteInformation(
          RouteInformation(uri: Uri.parse(location), state: state));
      await tester.pumpAndSettle();
      // Make sure it has all the imperative routes.
      expect(find.byKey(const ValueKey<String>('settings-1')), findsOneWidget);

      router.pop();
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey<String>('settings-0')), findsOneWidget);

      router.pop();
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey<String>('home')), findsOneWidget);
    });

    testWidgets('works correctly with async redirect',
        (WidgetTester tester) async {
      final UniqueKey login = UniqueKey();
      final List<GoRoute> routes = <GoRoute>[
        GoRoute(
          path: '/',
          builder: (_, __) => const DummyScreen(),
        ),
        GoRoute(
          path: '/login',
          builder: (_, __) => DummyScreen(key: login),
        ),
      ];
      final Completer<void> completer = Completer<void>();
      final GoRouter router =
          await createRouter(routes, tester, redirect: (_, __) async {
        await completer.future;
        return '/login';
      });
      final RouteMatchListCodec codec =
          RouteMatchListCodec(router.configuration);
      await tester.pumpAndSettle();
      expect(find.byKey(login), findsNothing);
      expect(tester.takeException(), isNull);
      expect(log, <Object>[]);

      completer.complete();
      await tester.pumpAndSettle();

      expect(find.byKey(login), findsOneWidget);
      expect(tester.takeException(), isNull);
      expect(log, <Object>[
        isMethodCall('selectMultiEntryHistory', arguments: null),
        IsRouteUpdateCall('/login', true,
            codec.encode(router.routerDelegate.currentConfiguration)),
      ]);
    });
  });

  group('named routes', () {
    testWidgets('match home route', (WidgetTester tester) async {
      final List<GoRoute> routes = <GoRoute>[
        GoRoute(
            name: 'home',
            path: '/',
            builder: (BuildContext context, GoRouterState state) =>
                const HomeScreen()),
      ];

      final GoRouter router = await createRouter(routes, tester);
      router.goNamed('home');
    });

    testWidgets('match too many routes', (WidgetTester tester) async {
      final List<GoRoute> routes = <GoRoute>[
        GoRoute(name: 'home', path: '/', builder: dummy),
        GoRoute(name: 'home', path: '/', builder: dummy),
      ];

      await expectLater(() async {
        await createRouter(routes, tester);
      }, throwsA(isAssertionError));
    });

    test('empty name', () {
      expect(() {
        GoRoute(name: '', path: '/');
      }, throwsA(isAssertionError));
    });

    testWidgets('match no routes', (WidgetTester tester) async {
      await expectLater(() async {
        final List<GoRoute> routes = <GoRoute>[
          GoRoute(name: 'home', path: '/', builder: dummy),
        ];
        final GoRouter router = await createRouter(routes, tester);
        router.goNamed('work');
      }, throwsA(isAssertionError));
    });

    testWidgets('match 2nd top level route', (WidgetTester tester) async {
      final List<GoRoute> routes = <GoRoute>[
        GoRoute(
          name: 'home',
          path: '/',
          builder: (BuildContext context, GoRouterState state) =>
              const HomeScreen(),
        ),
        GoRoute(
          name: 'login',
          path: '/login',
          builder: (BuildContext context, GoRouterState state) =>
              const LoginScreen(),
        ),
      ];

      final GoRouter router = await createRouter(routes, tester);
      router.goNamed('login');
    });

    testWidgets('match sub-route', (WidgetTester tester) async {
      final List<GoRoute> routes = <GoRoute>[
        GoRoute(
          name: 'home',
          path: '/',
          builder: (BuildContext context, GoRouterState state) =>
              const HomeScreen(),
          routes: <GoRoute>[
            GoRoute(
              name: 'login',
              path: 'login',
              builder: (BuildContext context, GoRouterState state) =>
                  const LoginScreen(),
            ),
          ],
        ),
      ];

      final GoRouter router = await createRouter(routes, tester);
      router.goNamed('login');
    });

    testWidgets('match w/ params', (WidgetTester tester) async {
      final List<GoRoute> routes = <GoRoute>[
        GoRoute(
          name: 'home',
          path: '/',
          builder: (BuildContext context, GoRouterState state) =>
              const HomeScreen(),
          routes: <GoRoute>[
            GoRoute(
              name: 'family',
              path: 'family/:fid',
              builder: (BuildContext context, GoRouterState state) =>
                  const FamilyScreen('dummy'),
              routes: <GoRoute>[
                GoRoute(
                  name: 'person',
                  path: 'person/:pid',
                  builder: (BuildContext context, GoRouterState state) {
                    expect(state.pathParameters,
                        <String, String>{'fid': 'f2', 'pid': 'p1'});
                    return const PersonScreen('dummy', 'dummy');
                  },
                ),
              ],
            ),
          ],
        ),
      ];

      final GoRouter router = await createRouter(routes, tester);
      router.goNamed('person',
          pathParameters: <String, String>{'fid': 'f2', 'pid': 'p1'});
    });

    testWidgets('too few params', (WidgetTester tester) async {
      final List<GoRoute> routes = <GoRoute>[
        GoRoute(
          name: 'home',
          path: '/',
          builder: (BuildContext context, GoRouterState state) =>
              const HomeScreen(),
          routes: <GoRoute>[
            GoRoute(
              name: 'family',
              path: 'family/:fid',
              builder: (BuildContext context, GoRouterState state) =>
                  const FamilyScreen('dummy'),
              routes: <GoRoute>[
                GoRoute(
                  name: 'person',
                  path: 'person/:pid',
                  builder: (BuildContext context, GoRouterState state) =>
                      const PersonScreen('dummy', 'dummy'),
                ),
              ],
            ),
          ],
        ),
      ];
      await expectLater(() async {
        final GoRouter router = await createRouter(routes, tester);
        router.goNamed('person', pathParameters: <String, String>{'fid': 'f2'});
        await tester.pump();
      }, throwsA(isAssertionError));
    });

    testWidgets('cannot match case insensitive', (WidgetTester tester) async {
      final List<GoRoute> routes = <GoRoute>[
        GoRoute(
          name: 'home',
          path: '/',
          builder: (BuildContext context, GoRouterState state) =>
              const HomeScreen(),
          routes: <GoRoute>[
            GoRoute(
              name: 'family',
              path: 'family/:fid',
              builder: (BuildContext context, GoRouterState state) =>
                  const FamilyScreen('dummy'),
              routes: <GoRoute>[
                GoRoute(
                  name: 'PeRsOn',
                  path: 'person/:pid',
                  builder: (BuildContext context, GoRouterState state) {
                    expect(state.pathParameters,
                        <String, String>{'fid': 'f2', 'pid': 'p1'});
                    return const PersonScreen('dummy', 'dummy');
                  },
                ),
              ],
            ),
          ],
        ),
      ];

      final GoRouter router = await createRouter(routes, tester);
      expect(
        () {
          router.goNamed(
            'person',
            pathParameters: <String, String>{'fid': 'f2', 'pid': 'p1'},
          );
        },
        throwsAssertionError,
      );
    });

    testWidgets('too few params', (WidgetTester tester) async {
      final List<GoRoute> routes = <GoRoute>[
        GoRoute(
          name: 'family',
          path: '/family/:fid',
          builder: (BuildContext context, GoRouterState state) =>
              const FamilyScreen('dummy'),
        ),
      ];
      await expectLater(() async {
        final GoRouter router = await createRouter(routes, tester);
        router.goNamed('family');
      }, throwsA(isAssertionError));
    });

    testWidgets('too many params', (WidgetTester tester) async {
      final List<GoRoute> routes = <GoRoute>[
        GoRoute(
          name: 'family',
          path: '/family/:fid',
          builder: (BuildContext context, GoRouterState state) =>
              const FamilyScreen('dummy'),
        ),
      ];
      await expectLater(() async {
        final GoRouter router = await createRouter(routes, tester);
        router.goNamed('family',
            pathParameters: <String, String>{'fid': 'f2', 'pid': 'p1'});
      }, throwsA(isAssertionError));
    });

    testWidgets('sparsely named routes', (WidgetTester tester) async {
      final List<GoRoute> routes = <GoRoute>[
        GoRoute(
          path: '/',
          builder: dummy,
          redirect: (_, __) => '/family/f2',
        ),
        GoRoute(
          path: '/family/:fid',
          builder: (BuildContext context, GoRouterState state) => FamilyScreen(
            state.pathParameters['fid']!,
          ),
          routes: <GoRoute>[
            GoRoute(
              name: 'person',
              path: 'person:pid',
              builder: (BuildContext context, GoRouterState state) =>
                  PersonScreen(
                state.pathParameters['fid']!,
                state.pathParameters['pid']!,
              ),
            ),
          ],
        ),
      ];

      final GoRouter router = await createRouter(routes, tester);
      router.goNamed('person',
          pathParameters: <String, String>{'fid': 'f2', 'pid': 'p1'});
      await tester.pumpAndSettle();
      expect(find.byType(PersonScreen), findsOneWidget);
    });

    testWidgets('preserve path param spaces and slashes',
        (WidgetTester tester) async {
      const String param1 = 'param w/ spaces and slashes';
      final List<GoRoute> routes = <GoRoute>[
        GoRoute(
          name: 'page1',
          path: '/page1/:param1',
          builder: (BuildContext c, GoRouterState s) {
            expect(s.pathParameters['param1'], param1);
            return const DummyScreen();
          },
        ),
      ];

      final GoRouter router = await createRouter(routes, tester);
      final String loc = router.namedLocation('page1',
          pathParameters: <String, String>{'param1': param1});
      router.go(loc);
      await tester.pumpAndSettle();

      final RouteMatchList matches = router.routerDelegate.currentConfiguration;
      expect(find.byType(DummyScreen), findsOneWidget);
      expect(matches.pathParameters['param1'], param1);
    });

    testWidgets('preserve query param spaces and slashes',
        (WidgetTester tester) async {
      const String param1 = 'param w/ spaces and slashes';
      final List<GoRoute> routes = <GoRoute>[
        GoRoute(
          name: 'page1',
          path: '/page1',
          builder: (BuildContext c, GoRouterState s) {
            expect(s.uri.queryParameters['param1'], param1);
            return const DummyScreen();
          },
        ),
      ];

      final GoRouter router = await createRouter(routes, tester);
      final String loc = router.namedLocation('page1',
          queryParameters: <String, String>{'param1': param1});
      router.go(loc);
      await tester.pumpAndSettle();
      final RouteMatchList matches = router.routerDelegate.currentConfiguration;
      expect(find.byType(DummyScreen), findsOneWidget);
      expect(matches.uri.queryParameters['param1'], param1);
    });
  });

  group('redirects', () {
    testWidgets('top-level redirect', (WidgetTester tester) async {
      final List<GoRoute> routes = <GoRoute>[
        GoRoute(
          path: '/',
          builder: (BuildContext context, GoRouterState state) =>
              const HomeScreen(),
          routes: <GoRoute>[
            GoRoute(
                path: 'dummy',
                builder: (BuildContext context, GoRouterState state) =>
                    const DummyScreen()),
            GoRoute(
                path: 'login',
                builder: (BuildContext context, GoRouterState state) =>
                    const LoginScreen()),
          ],
        ),
      ];
      bool redirected = false;

      final GoRouter router = await createRouter(routes, tester,
          redirect: (BuildContext context, GoRouterState state) {
        redirected = true;
        return state.matchedLocation == '/login' ? null : '/login';
      });

      expect(
          router.routerDelegate.currentConfiguration.uri.toString(), '/login');
      expect(redirected, isTrue);

      redirected = false;
      // Directly set the url through platform message.
      await sendPlatformUrl('/dummy', tester);

      await tester.pumpAndSettle();
      expect(
          router.routerDelegate.currentConfiguration.uri.toString(), '/login');
      expect(redirected, isTrue);
    });

    testWidgets('redirect can redirect to same path',
        (WidgetTester tester) async {
      final List<GoRoute> routes = <GoRoute>[
        GoRoute(
          path: '/',
          builder: (BuildContext context, GoRouterState state) =>
              const HomeScreen(),
          routes: <GoRoute>[
            GoRoute(
                path: 'dummy',
                // Return same location.
                redirect: (_, GoRouterState state) => state.uri.toString(),
                builder: (BuildContext context, GoRouterState state) =>
                    const DummyScreen()),
          ],
        ),
      ];

      final GoRouter router = await createRouter(routes, tester,
          redirect: (BuildContext context, GoRouterState state) {
        // Return same location.
        return state.uri.toString();
      });

      expect(router.routerDelegate.currentConfiguration.uri.toString(), '/');
      // Directly set the url through platform message.
      await sendPlatformUrl('/dummy', tester);
      await tester.pumpAndSettle();
      expect(
          router.routerDelegate.currentConfiguration.uri.toString(), '/dummy');
    });

    testWidgets('top-level redirect w/ named routes',
        (WidgetTester tester) async {
      final List<GoRoute> routes = <GoRoute>[
        GoRoute(
          name: 'home',
          path: '/',
          builder: (BuildContext context, GoRouterState state) =>
              const HomeScreen(),
          routes: <GoRoute>[
            GoRoute(
              name: 'dummy',
              path: 'dummy',
              builder: (BuildContext context, GoRouterState state) =>
                  const DummyScreen(),
            ),
            GoRoute(
              name: 'login',
              path: 'login',
              builder: (BuildContext context, GoRouterState state) =>
                  const LoginScreen(),
            ),
          ],
        ),
      ];

      final GoRouter router = await createRouter(
        routes,
        tester,
        redirect: (BuildContext context, GoRouterState state) =>
            state.matchedLocation == '/login'
                ? null
                : state.namedLocation('login'),
      );
      expect(
          router.routerDelegate.currentConfiguration.uri.toString(), '/login');
    });

    testWidgets('route-level redirect', (WidgetTester tester) async {
      final List<GoRoute> routes = <GoRoute>[
        GoRoute(
          path: '/',
          builder: (BuildContext context, GoRouterState state) =>
              const HomeScreen(),
          routes: <GoRoute>[
            GoRoute(
              path: 'dummy',
              builder: (BuildContext context, GoRouterState state) =>
                  const DummyScreen(),
              redirect: (BuildContext context, GoRouterState state) => '/login',
            ),
            GoRoute(
              path: 'login',
              builder: (BuildContext context, GoRouterState state) =>
                  const LoginScreen(),
            ),
          ],
        ),
      ];

      final GoRouter router = await createRouter(routes, tester);
      router.go('/dummy');
      await tester.pump();
      expect(
          router.routerDelegate.currentConfiguration.uri.toString(), '/login');
    });

    testWidgets('top-level redirect take priority over route level',
        (WidgetTester tester) async {
      final List<GoRoute> routes = <GoRoute>[
        GoRoute(
          path: '/',
          builder: (BuildContext context, GoRouterState state) =>
              const HomeScreen(),
          routes: <GoRoute>[
            GoRoute(
                path: 'dummy',
                builder: (BuildContext context, GoRouterState state) =>
                    const DummyScreen(),
                redirect: (BuildContext context, GoRouterState state) {
                  // should never be reached.
                  assert(false);
                  return '/dummy2';
                }),
            GoRoute(
                path: 'dummy2',
                builder: (BuildContext context, GoRouterState state) =>
                    const DummyScreen()),
            GoRoute(
                path: 'login',
                builder: (BuildContext context, GoRouterState state) =>
                    const LoginScreen()),
          ],
        ),
      ];
      bool redirected = false;
      final GoRouter router = await createRouter(routes, tester,
          redirect: (BuildContext context, GoRouterState state) {
        redirected = true;
        return state.matchedLocation == '/login' ? null : '/login';
      });
      redirected = false;
      // Directly set the url through platform message.
      await sendPlatformUrl('/dummy', tester);

      await tester.pumpAndSettle();
      expect(
          router.routerDelegate.currentConfiguration.uri.toString(), '/login');
      expect(redirected, isTrue);
    });

    testWidgets('route-level redirect w/ named routes',
        (WidgetTester tester) async {
      final List<GoRoute> routes = <GoRoute>[
        GoRoute(
          name: 'home',
          path: '/',
          builder: (BuildContext context, GoRouterState state) =>
              const HomeScreen(),
          routes: <GoRoute>[
            GoRoute(
              name: 'dummy',
              path: 'dummy',
              builder: (BuildContext context, GoRouterState state) =>
                  const DummyScreen(),
              redirect: (BuildContext context, GoRouterState state) =>
                  state.namedLocation('login'),
            ),
            GoRoute(
              name: 'login',
              path: 'login',
              builder: (BuildContext context, GoRouterState state) =>
                  const LoginScreen(),
            ),
          ],
        ),
      ];

      final GoRouter router = await createRouter(routes, tester);
      router.go('/dummy');
      await tester.pump();
      expect(
          router.routerDelegate.currentConfiguration.uri.toString(), '/login');
    });

    testWidgets('multiple mixed redirect', (WidgetTester tester) async {
      final List<GoRoute> routes = <GoRoute>[
        GoRoute(
          path: '/',
          builder: (BuildContext context, GoRouterState state) =>
              const HomeScreen(),
          routes: <GoRoute>[
            GoRoute(
              path: 'dummy1',
              builder: (BuildContext context, GoRouterState state) =>
                  const DummyScreen(),
            ),
            GoRoute(
              path: 'dummy2',
              builder: (BuildContext context, GoRouterState state) =>
                  const DummyScreen(),
              redirect: (BuildContext context, GoRouterState state) => '/',
            ),
          ],
        ),
      ];

      final GoRouter router = await createRouter(routes, tester,
          redirect: (BuildContext context, GoRouterState state) =>
              state.matchedLocation == '/dummy1' ? '/dummy2' : null);
      router.go('/dummy1');
      await tester.pump();
      expect(router.routerDelegate.currentConfiguration.uri.toString(), '/');
    });

    testWidgets('top-level redirect loop', (WidgetTester tester) async {
      final GoRouter router = await createRouter(
        <GoRoute>[],
        tester,
        redirect: (BuildContext context, GoRouterState state) =>
            state.matchedLocation == '/'
                ? '/login'
                : state.matchedLocation == '/login'
                    ? '/'
                    : null,
        errorBuilder: (BuildContext context, GoRouterState state) =>
            TestErrorScreen(state.error!),
      );
      final List<RouteMatchBase> matches =
          router.routerDelegate.currentConfiguration.matches;
      expect(matches, hasLength(0));
      expect(find.byType(TestErrorScreen), findsOneWidget);
      final TestErrorScreen screen =
          tester.widget<TestErrorScreen>(find.byType(TestErrorScreen));
      expect(screen.ex, isNotNull);
    });

    testWidgets('route-level redirect loop', (WidgetTester tester) async {
      final GoRouter router = await createRouter(
        <GoRoute>[
          GoRoute(
            path: '/',
            builder: dummy,
            redirect: (BuildContext context, GoRouterState state) => '/login',
          ),
          GoRoute(
            path: '/login',
            builder: dummy,
            redirect: (BuildContext context, GoRouterState state) => '/',
          ),
        ],
        tester,
        errorBuilder: (BuildContext context, GoRouterState state) =>
            TestErrorScreen(state.error!),
      );

      final List<RouteMatchBase> matches =
          router.routerDelegate.currentConfiguration.matches;
      expect(matches, hasLength(0));
      expect(find.byType(TestErrorScreen), findsOneWidget);
      final TestErrorScreen screen =
          tester.widget<TestErrorScreen>(find.byType(TestErrorScreen));
      expect(screen.ex, isNotNull);
    });

    testWidgets('mixed redirect loop', (WidgetTester tester) async {
      final GoRouter router = await createRouter(
        <GoRoute>[
          GoRoute(
            path: '/login',
            builder: dummy,
            redirect: (BuildContext context, GoRouterState state) => '/',
          ),
        ],
        tester,
        redirect: (BuildContext context, GoRouterState state) =>
            state.matchedLocation == '/' ? '/login' : null,
        errorBuilder: (BuildContext context, GoRouterState state) =>
            TestErrorScreen(state.error!),
      );

      final List<RouteMatchBase> matches =
          router.routerDelegate.currentConfiguration.matches;
      expect(matches, hasLength(0));
      expect(find.byType(TestErrorScreen), findsOneWidget);
      final TestErrorScreen screen =
          tester.widget<TestErrorScreen>(find.byType(TestErrorScreen));
      expect(screen.ex, isNotNull);
    });

    testWidgets('top-level redirect loop w/ query params',
        (WidgetTester tester) async {
      final GoRouter router = await createRouter(
        <GoRoute>[],
        tester,
        redirect: (BuildContext context, GoRouterState state) =>
            state.matchedLocation == '/'
                ? '/login?from=${state.uri}'
                : state.matchedLocation == '/login'
                    ? '/'
                    : null,
        errorBuilder: (BuildContext context, GoRouterState state) =>
            TestErrorScreen(state.error!),
      );

      final List<RouteMatchBase> matches =
          router.routerDelegate.currentConfiguration.matches;
      expect(matches, hasLength(0));
      expect(find.byType(TestErrorScreen), findsOneWidget);
      final TestErrorScreen screen =
          tester.widget<TestErrorScreen>(find.byType(TestErrorScreen));
      expect(screen.ex, isNotNull);
    });

    testWidgets('expect null path/fullPath on top-level redirect',
        (WidgetTester tester) async {
      final List<GoRoute> routes = <GoRoute>[
        GoRoute(
          path: '/',
          builder: (BuildContext context, GoRouterState state) =>
              const HomeScreen(),
        ),
        GoRoute(
          path: '/dummy',
          builder: dummy,
          redirect: (BuildContext context, GoRouterState state) => '/',
        ),
      ];

      final GoRouter router = await createRouter(
        routes,
        tester,
        initialLocation: '/dummy',
      );
      expect(router.routerDelegate.currentConfiguration.uri.toString(), '/');
    });

    testWidgets('top-level redirect state', (WidgetTester tester) async {
      final List<GoRoute> routes = <GoRoute>[
        GoRoute(
          path: '/',
          builder: (BuildContext context, GoRouterState state) =>
              const HomeScreen(),
        ),
        GoRoute(
          path: '/login',
          builder: (BuildContext context, GoRouterState state) =>
              const LoginScreen(),
        ),
      ];

      final GoRouter router = await createRouter(
        routes,
        tester,
        initialLocation: '/login?from=/',
        redirect: (BuildContext context, GoRouterState state) {
          expect(Uri.parse(state.uri.toString()).queryParameters, isNotEmpty);
          expect(Uri.parse(state.matchedLocation).queryParameters, isEmpty);
          expect(state.path, isNull);
          expect(state.fullPath, '/login');
          expect(state.pathParameters.length, 0);
          expect(state.uri.queryParameters.length, 1);
          expect(state.uri.queryParameters['from'], '/');
          return null;
        },
      );

      final List<RouteMatchBase> matches =
          router.routerDelegate.currentConfiguration.matches;
      expect(matches, hasLength(1));
      expect(find.byType(LoginScreen), findsOneWidget);
    });

    testWidgets('top-level redirect state contains path parameters',
        (WidgetTester tester) async {
      final List<GoRoute> routes = <GoRoute>[
        GoRoute(
            path: '/',
            builder: (BuildContext context, GoRouterState state) =>
                const DummyScreen(),
            routes: <RouteBase>[
              GoRoute(
                path: ':id',
                builder: (BuildContext context, GoRouterState state) =>
                    const DummyScreen(),
              ),
            ]),
      ];

      final GoRouter router = await createRouter(
        routes,
        tester,
        initialLocation: '/123',
        redirect: (BuildContext context, GoRouterState state) {
          expect(state.path, isNull);
          expect(state.fullPath, '/:id');
          expect(state.pathParameters.length, 1);
          expect(state.pathParameters['id'], '123');
          return null;
        },
      );

      final List<RouteMatchBase> matches =
          router.routerDelegate.currentConfiguration.matches;
      expect(matches, hasLength(2));
    });

    testWidgets('route-level redirect state', (WidgetTester tester) async {
      const String loc = '/book/0';
      final List<GoRoute> routes = <GoRoute>[
        GoRoute(
          path: '/book/:bookId',
          redirect: (BuildContext context, GoRouterState state) {
            expect(state.uri.toString(), loc);
            expect(state.matchedLocation, loc);
            expect(state.path, '/book/:bookId');
            expect(state.fullPath, '/book/:bookId');
            expect(state.pathParameters, <String, String>{'bookId': '0'});
            expect(state.uri.queryParameters.length, 0);
            return null;
          },
          builder: (BuildContext c, GoRouterState s) => const HomeScreen(),
        ),
      ];

      final GoRouter router = await createRouter(
        routes,
        tester,
        initialLocation: loc,
      );

      final List<RouteMatchBase> matches =
          router.routerDelegate.currentConfiguration.matches;
      expect(matches, hasLength(1));
      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets('sub-sub-route-level redirect params',
        (WidgetTester tester) async {
      final List<GoRoute> routes = <GoRoute>[
        GoRoute(
          path: '/',
          builder: (BuildContext c, GoRouterState s) => const HomeScreen(),
          routes: <GoRoute>[
            GoRoute(
              path: 'family/:fid',
              builder: (BuildContext c, GoRouterState s) =>
                  FamilyScreen(s.pathParameters['fid']!),
              routes: <GoRoute>[
                GoRoute(
                  path: 'person/:pid',
                  redirect: (BuildContext context, GoRouterState s) {
                    expect(s.pathParameters['fid'], 'f2');
                    expect(s.pathParameters['pid'], 'p1');
                    return null;
                  },
                  builder: (BuildContext c, GoRouterState s) => PersonScreen(
                    s.pathParameters['fid']!,
                    s.pathParameters['pid']!,
                  ),
                ),
              ],
            ),
          ],
        ),
      ];

      final GoRouter router = await createRouter(
        routes,
        tester,
        initialLocation: '/family/f2/person/p1',
      );

      final List<RouteMatchBase> matches =
          router.routerDelegate.currentConfiguration.matches;
      expect(matches.length, 3);
      expect(find.byType(HomeScreen, skipOffstage: false), findsOneWidget);
      expect(find.byType(FamilyScreen, skipOffstage: false), findsOneWidget);
      final PersonScreen page =
          tester.widget<PersonScreen>(find.byType(PersonScreen));
      expect(page.fid, 'f2');
      expect(page.pid, 'p1');
    });

    testWidgets('redirect limit', (WidgetTester tester) async {
      final GoRouter router = await createRouter(
        <GoRoute>[],
        tester,
        redirect: (BuildContext context, GoRouterState state) =>
            '/${state.uri}+',
        errorBuilder: (BuildContext context, GoRouterState state) =>
            TestErrorScreen(state.error!),
        redirectLimit: 10,
      );

      final List<RouteMatchBase> matches =
          router.routerDelegate.currentConfiguration.matches;
      expect(matches, hasLength(0));
      expect(find.byType(TestErrorScreen), findsOneWidget);
      final TestErrorScreen screen =
          tester.widget<TestErrorScreen>(find.byType(TestErrorScreen));
      expect(screen.ex, isNotNull);
    });

    testWidgets('can push error page', (WidgetTester tester) async {
      final GoRouter router = await createRouter(
        <GoRoute>[
          GoRoute(path: '/', builder: (_, __) => const Text('/')),
        ],
        tester,
        errorBuilder: (_, GoRouterState state) {
          return Text(state.uri.toString());
        },
      );

      expect(find.text('/'), findsOneWidget);

      router.push('/error1');
      await tester.pumpAndSettle();

      expect(find.text('/'), findsNothing);
      expect(find.text('/error1'), findsOneWidget);

      router.push('/error2');
      await tester.pumpAndSettle();

      expect(find.text('/'), findsNothing);
      expect(find.text('/error1'), findsNothing);
      expect(find.text('/error2'), findsOneWidget);

      router.pop();
      await tester.pumpAndSettle();

      expect(find.text('/'), findsNothing);
      expect(find.text('/error1'), findsOneWidget);
      expect(find.text('/error2'), findsNothing);

      router.pop();
      await tester.pumpAndSettle();

      expect(find.text('/'), findsOneWidget);
      expect(find.text('/error1'), findsNothing);
      expect(find.text('/error2'), findsNothing);
    });

    testWidgets('extra not null in redirect', (WidgetTester tester) async {
      bool isCallTopRedirect = false;
      bool isCallRouteRedirect = false;

      final List<GoRoute> routes = <GoRoute>[
        GoRoute(
          name: 'home',
          path: '/',
          builder: (BuildContext context, GoRouterState state) =>
              const HomeScreen(),
          routes: <GoRoute>[
            GoRoute(
              name: 'login',
              path: 'login',
              builder: (BuildContext context, GoRouterState state) {
                return const LoginScreen();
              },
              redirect: (BuildContext context, GoRouterState state) {
                isCallRouteRedirect = true;
                expect(state.extra, isNotNull);
                return null;
              },
              routes: const <GoRoute>[],
            ),
          ],
        ),
      ];

      final GoRouter router = await createRouter(
        routes,
        tester,
        redirect: (BuildContext context, GoRouterState state) {
          if (state.uri.toString() == '/login') {
            isCallTopRedirect = true;
            expect(state.extra, isNotNull);
          }

          return null;
        },
      );

      router.go('/login', extra: 1);
      await tester.pump();

      expect(isCallTopRedirect, true);
      expect(isCallRouteRedirect, true);
    });

    testWidgets('parent route level redirect take priority over child',
        (WidgetTester tester) async {
      final List<GoRoute> routes = <GoRoute>[
        GoRoute(
          path: '/',
          builder: (BuildContext context, GoRouterState state) =>
              const HomeScreen(),
          routes: <GoRoute>[
            GoRoute(
                path: 'dummy',
                builder: (BuildContext context, GoRouterState state) =>
                    const DummyScreen(),
                redirect: (BuildContext context, GoRouterState state) =>
                    '/other',
                routes: <GoRoute>[
                  GoRoute(
                    path: 'dummy2',
                    builder: (BuildContext context, GoRouterState state) =>
                        const DummyScreen(),
                    redirect: (BuildContext context, GoRouterState state) {
                      assert(false);
                      return '/other2';
                    },
                  ),
                ]),
            GoRoute(
                path: 'other',
                builder: (BuildContext context, GoRouterState state) =>
                    const DummyScreen()),
            GoRoute(
                path: 'other2',
                builder: (BuildContext context, GoRouterState state) =>
                    const DummyScreen()),
          ],
        ),
      ];

      final GoRouter router = await createRouter(routes, tester);

      // Directly set the url through platform message.
      await sendPlatformUrl('/dummy/dummy2', tester);

      await tester.pumpAndSettle();
      expect(
          router.routerDelegate.currentConfiguration.uri.toString(), '/other');
    });
  });

  group('initial location', () {
    testWidgets('initial location', (WidgetTester tester) async {
      final List<GoRoute> routes = <GoRoute>[
        GoRoute(
          path: '/',
          builder: (BuildContext context, GoRouterState state) =>
              const HomeScreen(),
          routes: <GoRoute>[
            GoRoute(
              path: 'dummy',
              builder: (BuildContext context, GoRouterState state) =>
                  const DummyScreen(),
            ),
          ],
        ),
      ];

      final GoRouter router = await createRouter(
        routes,
        tester,
        initialLocation: '/dummy',
      );
      expect(
          router.routerDelegate.currentConfiguration.uri.toString(), '/dummy');
    });

    testWidgets('initial location with extra', (WidgetTester tester) async {
      final List<GoRoute> routes = <GoRoute>[
        GoRoute(
          path: '/',
          builder: (BuildContext context, GoRouterState state) =>
              const HomeScreen(),
          routes: <GoRoute>[
            GoRoute(
              path: 'dummy',
              builder: (BuildContext context, GoRouterState state) {
                return DummyScreen(key: ValueKey<Object?>(state.extra));
              },
            ),
          ],
        ),
      ];

      final GoRouter router = await createRouter(
        routes,
        tester,
        initialLocation: '/dummy',
        initialExtra: 'extra',
      );
      expect(
          router.routerDelegate.currentConfiguration.uri.toString(), '/dummy');
      expect(find.byKey(const ValueKey<Object?>('extra')), findsOneWidget);
    });

    testWidgets('initial location w/ redirection', (WidgetTester tester) async {
      final List<GoRoute> routes = <GoRoute>[
        GoRoute(
          path: '/',
          builder: (BuildContext context, GoRouterState state) =>
              const HomeScreen(),
        ),
        GoRoute(
          path: '/dummy',
          builder: dummy,
          redirect: (BuildContext context, GoRouterState state) => '/',
        ),
      ];

      final GoRouter router = await createRouter(
        routes,
        tester,
        initialLocation: '/dummy',
      );
      expect(router.routerDelegate.currentConfiguration.uri.toString(), '/');
    });

    testWidgets(
        'does not take precedence over platformDispatcher.defaultRouteName',
        (WidgetTester tester) async {
      TestWidgetsFlutterBinding
          .instance.platformDispatcher.defaultRouteNameTestValue = '/dummy';

      final List<GoRoute> routes = <GoRoute>[
        GoRoute(
          path: '/',
          builder: (BuildContext context, GoRouterState state) =>
              const HomeScreen(),
          routes: <GoRoute>[
            GoRoute(
              path: 'dummy',
              builder: (BuildContext context, GoRouterState state) =>
                  const DummyScreen(),
            ),
          ],
        ),
      ];

      final GoRouter router = await createRouter(
        routes,
        tester,
      );
      expect(router.routeInformationProvider.value.uri.path, '/dummy');
      TestWidgetsFlutterBinding.instance.platformDispatcher
          .clearDefaultRouteNameTestValue();
    });

    test('throws assertion if initialExtra is set w/o initialLocation', () {
      expect(
        () => GoRouter(
          routes: const <GoRoute>[],
          initialExtra: 1,
        ),
        throwsA(
          isA<AssertionError>().having(
            (AssertionError e) => e.message,
            'error message',
            'initialLocation must be set in order to use initialExtra',
          ),
        ),
      );
    });
  });

  group('_effectiveInitialLocation()', () {
    final List<GoRoute> routes = <GoRoute>[
      GoRoute(
        path: '/',
        builder: (BuildContext context, GoRouterState state) =>
            const HomeScreen(),
      ),
    ];

    testWidgets(
        'When platformDispatcher.defaultRouteName is deep-link Uri with '
        'scheme, authority, no path', (WidgetTester tester) async {
      TestWidgetsFlutterBinding.instance.platformDispatcher
          .defaultRouteNameTestValue = 'https://domain.com';
      final GoRouter router = await createRouter(
        routes,
        tester,
      );
      expect(router.routeInformationProvider.value.uri.path, '/');
      TestWidgetsFlutterBinding.instance.platformDispatcher
          .clearDefaultRouteNameTestValue();
    });

    testWidgets(
        'When platformDispatcher.defaultRouteName is deep-link Uri with '
        'scheme, authority, no path, but trailing slash',
        (WidgetTester tester) async {
      TestWidgetsFlutterBinding.instance.platformDispatcher
          .defaultRouteNameTestValue = 'https://domain.com/';
      final GoRouter router = await createRouter(
        routes,
        tester,
      );
      expect(router.routeInformationProvider.value.uri.path, '/');
      TestWidgetsFlutterBinding.instance.platformDispatcher
          .clearDefaultRouteNameTestValue();
    });

    testWidgets(
        'When platformDispatcher.defaultRouteName is deep-link Uri with '
        'scheme, authority, no path, and query parameters',
        (WidgetTester tester) async {
      TestWidgetsFlutterBinding.instance.platformDispatcher
          .defaultRouteNameTestValue = 'https://domain.com?param=1';
      final GoRouter router = await createRouter(
        routes,
        tester,
      );
      expect(router.routeInformationProvider.value.uri.toString(), '/?param=1');
      TestWidgetsFlutterBinding.instance.platformDispatcher
          .clearDefaultRouteNameTestValue();
    });
  });

  group('params', () {
    testWidgets('preserve path param case', (WidgetTester tester) async {
      final List<GoRoute> routes = <GoRoute>[
        GoRoute(
          path: '/',
          builder: (BuildContext context, GoRouterState state) =>
              const HomeScreen(),
        ),
        GoRoute(
          path: '/family/:fid',
          builder: (BuildContext context, GoRouterState state) =>
              FamilyScreen(state.pathParameters['fid']!),
        ),
      ];

      final GoRouter router = await createRouter(routes, tester);
      for (final String fid in <String>['f2', 'F2']) {
        final String loc = '/family/$fid';
        router.go(loc);
        await tester.pumpAndSettle();
        final RouteMatchList matches =
            router.routerDelegate.currentConfiguration;

        expect(router.routerDelegate.currentConfiguration.uri.toString(), loc);
        expect(matches.matches, hasLength(1));
        expect(find.byType(FamilyScreen), findsOneWidget);
        expect(matches.pathParameters['fid'], fid);
      }
    });

    testWidgets('preserve query param case', (WidgetTester tester) async {
      final List<GoRoute> routes = <GoRoute>[
        GoRoute(
          path: '/',
          builder: (BuildContext context, GoRouterState state) =>
              const HomeScreen(),
        ),
        GoRoute(
          path: '/family',
          builder: (BuildContext context, GoRouterState state) => FamilyScreen(
            state.uri.queryParameters['fid']!,
          ),
        ),
      ];

      final GoRouter router = await createRouter(routes, tester);
      for (final String fid in <String>['f2', 'F2']) {
        final String loc = '/family?fid=$fid';
        router.go(loc);
        await tester.pumpAndSettle();
        final RouteMatchList matches =
            router.routerDelegate.currentConfiguration;

        expect(router.routerDelegate.currentConfiguration.uri.toString(), loc);
        expect(matches.matches, hasLength(1));
        expect(find.byType(FamilyScreen), findsOneWidget);
        expect(matches.uri.queryParameters['fid'], fid);
      }
    });

    testWidgets('preserve path param spaces and slashes',
        (WidgetTester tester) async {
      const String param1 = 'param w/ spaces and slashes';
      final List<GoRoute> routes = <GoRoute>[
        GoRoute(
          path: '/page1/:param1',
          builder: (BuildContext c, GoRouterState s) {
            expect(s.pathParameters['param1'], param1);
            return const DummyScreen();
          },
        ),
      ];

      final GoRouter router = await createRouter(routes, tester);
      final String loc = '/page1/${Uri.encodeComponent(param1)}';
      router.go(loc);
      await tester.pumpAndSettle();

      final RouteMatchList matches = router.routerDelegate.currentConfiguration;
      expect(find.byType(DummyScreen), findsOneWidget);
      expect(matches.pathParameters['param1'], param1);
    });

    testWidgets('preserve query param spaces and slashes',
        (WidgetTester tester) async {
      const String param1 = 'param w/ spaces and slashes';
      final List<GoRoute> routes = <GoRoute>[
        GoRoute(
          path: '/page1',
          builder: (BuildContext c, GoRouterState s) {
            expect(s.uri.queryParameters['param1'], param1);
            return const DummyScreen();
          },
        ),
      ];

      final GoRouter router = await createRouter(routes, tester);
      router.go('/page1?param1=$param1');
      await tester.pumpAndSettle();

      final RouteMatchList matches = router.routerDelegate.currentConfiguration;
      expect(find.byType(DummyScreen), findsOneWidget);
      expect(matches.uri.queryParameters['param1'], param1);

      final String loc = '/page1?param1=${Uri.encodeQueryComponent(param1)}';
      router.go(loc);
      await tester.pumpAndSettle();

      final RouteMatchList matches2 =
          router.routerDelegate.currentConfiguration;
      expect(find.byType(DummyScreen), findsOneWidget);
      expect(matches2.uri.queryParameters['param1'], param1);
    });

    test('error: duplicate path param', () {
      try {
        GoRouter(
          routes: <GoRoute>[
            GoRoute(
              path: '/:id/:blah/:bam/:id/:blah',
              builder: dummy,
            ),
          ],
          errorBuilder: (BuildContext context, GoRouterState state) =>
              TestErrorScreen(state.error!),
          initialLocation: '/0/1/2/0/1',
        );
        expect(false, true);
      } on Exception catch (ex) {
        log.info(ex);
      }
    });

    testWidgets('duplicate query param', (WidgetTester tester) async {
      final GoRouter router = await createRouter(
        <GoRoute>[
          GoRoute(
            path: '/',
            builder: (BuildContext context, GoRouterState state) {
              log.info('id= ${state.pathParameters['id']}');
              expect(state.pathParameters.length, 0);
              expect(state.uri.queryParameters.length, 1);
              expect(state.uri.queryParameters['id'], anyOf('0', '1'));
              return const HomeScreen();
            },
          ),
        ],
        tester,
        initialLocation: '/?id=0&id=1',
      );
      final RouteMatchList matches = router.routerDelegate.currentConfiguration;
      expect(matches.matches, hasLength(1));
      expect(matches.fullPath, '/');
      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets('duplicate path + query param', (WidgetTester tester) async {
      final GoRouter router = await createRouter(
        <GoRoute>[
          GoRoute(
            path: '/:id',
            builder: (BuildContext context, GoRouterState state) {
              expect(state.pathParameters, <String, String>{'id': '0'});
              expect(state.uri.queryParameters, <String, String>{'id': '1'});
              return const HomeScreen();
            },
          ),
        ],
        tester,
      );

      router.go('/0?id=1');
      await tester.pumpAndSettle();
      final RouteMatchList matches = router.routerDelegate.currentConfiguration;
      expect(matches.matches, hasLength(1));
      expect(matches.fullPath, '/:id');
      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets('push + query param', (WidgetTester tester) async {
      final GoRouter router = await createRouter(
        <GoRoute>[
          GoRoute(path: '/', builder: dummy),
          GoRoute(
            path: '/family',
            builder: (BuildContext context, GoRouterState state) =>
                FamilyScreen(
              state.uri.queryParameters['fid']!,
            ),
          ),
          GoRoute(
            path: '/person',
            builder: (BuildContext context, GoRouterState state) =>
                PersonScreen(
              state.uri.queryParameters['fid']!,
              state.uri.queryParameters['pid']!,
            ),
          ),
        ],
        tester,
      );

      router.go('/family?fid=f2');
      await tester.pumpAndSettle();
      router.push('/person?fid=f2&pid=p1');
      await tester.pumpAndSettle();
      final FamilyScreen page1 = tester
          .widget<FamilyScreen>(find.byType(FamilyScreen, skipOffstage: false));
      expect(page1.fid, 'f2');

      final PersonScreen page2 =
          tester.widget<PersonScreen>(find.byType(PersonScreen));
      expect(page2.fid, 'f2');
      expect(page2.pid, 'p1');
    });

    testWidgets('push + extra param', (WidgetTester tester) async {
      final GoRouter router = await createRouter(
        <GoRoute>[
          GoRoute(path: '/', builder: dummy),
          GoRoute(
            path: '/family',
            builder: (BuildContext context, GoRouterState state) =>
                FamilyScreen(
              (state.extra! as Map<String, String>)['fid']!,
            ),
          ),
          GoRoute(
            path: '/person',
            builder: (BuildContext context, GoRouterState state) =>
                PersonScreen(
              (state.extra! as Map<String, String>)['fid']!,
              (state.extra! as Map<String, String>)['pid']!,
            ),
          ),
        ],
        tester,
      );

      router.go('/family', extra: <String, String>{'fid': 'f2'});
      await tester.pumpAndSettle();
      router.push('/person', extra: <String, String>{'fid': 'f2', 'pid': 'p1'});
      await tester.pumpAndSettle();
      final FamilyScreen page1 = tester
          .widget<FamilyScreen>(find.byType(FamilyScreen, skipOffstage: false));
      expect(page1.fid, 'f2');

      final PersonScreen page2 =
          tester.widget<PersonScreen>(find.byType(PersonScreen));
      expect(page2.fid, 'f2');
      expect(page2.pid, 'p1');
    });

    testWidgets('keep param in nested route', (WidgetTester tester) async {
      final List<GoRoute> routes = <GoRoute>[
        GoRoute(
          path: '/',
          builder: (BuildContext context, GoRouterState state) =>
              const HomeScreen(),
        ),
        GoRoute(
          path: '/family/:fid',
          builder: (BuildContext context, GoRouterState state) =>
              FamilyScreen(state.pathParameters['fid']!),
          routes: <GoRoute>[
            GoRoute(
              path: 'person/:pid',
              builder: (BuildContext context, GoRouterState state) {
                final String fid = state.pathParameters['fid']!;
                final String pid = state.pathParameters['pid']!;

                return PersonScreen(fid, pid);
              },
            ),
          ],
        ),
      ];

      final GoRouter router = await createRouter(routes, tester);
      const String fid = 'f1';
      const String pid = 'p2';
      const String loc = '/family/$fid/person/$pid';

      router.push(loc);
      await tester.pumpAndSettle();
      final RouteMatchList matches = router.routerDelegate.currentConfiguration;

      expect(matches.matches, hasLength(2));
      expect(find.byType(PersonScreen), findsOneWidget);
      final ImperativeRouteMatch imperativeRouteMatch =
          matches.matches.last as ImperativeRouteMatch;
      expect(imperativeRouteMatch.matches.uri.toString(), loc);
      expect(imperativeRouteMatch.matches.pathParameters['fid'], fid);
      expect(imperativeRouteMatch.matches.pathParameters['pid'], pid);
    });

    testWidgets('StatefulShellRoute supports nested routes with params',
        (WidgetTester tester) async {
      StatefulNavigationShell? routeState;
      final List<RouteBase> routes = <RouteBase>[
        StatefulShellRoute.indexedStack(
          builder: (BuildContext context, GoRouterState state,
              StatefulNavigationShell navigationShell) {
            routeState = navigationShell;
            return navigationShell;
          },
          branches: <StatefulShellBranch>[
            StatefulShellBranch(
              routes: <RouteBase>[
                GoRoute(
                  path: '/a',
                  builder: (BuildContext context, GoRouterState state) =>
                      const Text('Screen A'),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: <RouteBase>[
                GoRoute(
                    path: '/family',
                    builder: (BuildContext context, GoRouterState state) =>
                        const Text('Families'),
                    routes: <RouteBase>[
                      GoRoute(
                        path: ':fid',
                        builder: (BuildContext context, GoRouterState state) =>
                            FamilyScreen(state.pathParameters['fid']!),
                        routes: <GoRoute>[
                          GoRoute(
                            path: 'person/:pid',
                            builder:
                                (BuildContext context, GoRouterState state) {
                              final String fid = state.pathParameters['fid']!;
                              final String pid = state.pathParameters['pid']!;

                              return PersonScreen(fid, pid);
                            },
                          ),
                        ],
                      )
                    ]),
              ],
            ),
          ],
        ),
      ];

      final GoRouter router =
          await createRouter(routes, tester, initialLocation: '/a');
      const String fid = 'f1';
      const String pid = 'p2';
      const String loc = '/family/$fid/person/$pid';

      router.go(loc);
      await tester.pumpAndSettle();
      RouteMatchList matches = router.routerDelegate.currentConfiguration;

      expect(router.routerDelegate.currentConfiguration.uri.toString(), loc);
      expect(matches.matches, hasLength(1));
      final ShellRouteMatch shellRouteMatch =
          matches.matches.first as ShellRouteMatch;
      expect(shellRouteMatch.matches, hasLength(3));
      expect(find.byType(PersonScreen), findsOneWidget);
      expect(matches.pathParameters['fid'], fid);
      expect(matches.pathParameters['pid'], pid);

      routeState?.goBranch(0);
      await tester.pumpAndSettle();
      expect(find.text('Screen A'), findsOneWidget);
      expect(find.byType(PersonScreen), findsNothing);

      routeState?.goBranch(1);
      await tester.pumpAndSettle();
      expect(find.text('Screen A'), findsNothing);
      expect(find.byType(PersonScreen), findsOneWidget);
      matches = router.routerDelegate.currentConfiguration;
      expect(matches.pathParameters['fid'], fid);
      expect(matches.pathParameters['pid'], pid);
    });

    testWidgets('StatefulShellRoute preserve extra when switching branch',
        (WidgetTester tester) async {
      StatefulNavigationShell? routeState;
      Object? latestExtra;
      final List<RouteBase> routes = <RouteBase>[
        StatefulShellRoute.indexedStack(
          builder: (BuildContext context, GoRouterState state,
              StatefulNavigationShell navigationShell) {
            routeState = navigationShell;
            return navigationShell;
          },
          branches: <StatefulShellBranch>[
            StatefulShellBranch(
              routes: <RouteBase>[
                GoRoute(
                  path: '/a',
                  builder: (BuildContext context, GoRouterState state) =>
                      const Text('Screen A'),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: <RouteBase>[
                GoRoute(
                    path: '/b',
                    builder: (BuildContext context, GoRouterState state) {
                      latestExtra = state.extra;
                      return const DummyScreen();
                    }),
              ],
            ),
          ],
        ),
      ];
      final Object expectedExtra = Object();

      await createRouter(routes, tester,
          initialLocation: '/b', initialExtra: expectedExtra);
      expect(latestExtra, expectedExtra);
      routeState!.goBranch(0);
      await tester.pumpAndSettle();
      routeState!.goBranch(1);
      await tester.pumpAndSettle();
      expect(latestExtra, expectedExtra);
    });

    testWidgets('goNames should allow dynamics values for queryParams',
        (WidgetTester tester) async {
      const Map<String, dynamic> queryParametersAll = <String, List<dynamic>>{
        'q1': <String>['v1'],
        'q2': <String>['v2', 'v3'],
      };
      void expectLocationWithQueryParams(String location) {
        final Uri uri = Uri.parse(location);
        expect(uri.path, '/page');
        expect(uri.queryParametersAll, queryParametersAll);
      }

      final List<GoRoute> routes = <GoRoute>[
        GoRoute(
          path: '/',
          builder: (BuildContext context, GoRouterState state) =>
              const HomeScreen(),
        ),
        GoRoute(
          name: 'page',
          path: '/page',
          builder: (BuildContext context, GoRouterState state) {
            expect(state.uri.queryParametersAll, queryParametersAll);
            expectLocationWithQueryParams(state.uri.toString());
            return DummyScreen(
              queryParametersAll: state.uri.queryParametersAll,
            );
          },
        ),
      ];

      final GoRouter router = await createRouter(routes, tester);

      router.goNamed('page', queryParameters: const <String, dynamic>{
        'q1': 'v1',
        'q2': <String>['v2', 'v3'],
      });
      await tester.pumpAndSettle();
      final List<RouteMatchBase> matches =
          router.routerDelegate.currentConfiguration.matches;

      expect(matches, hasLength(1));
      expectLocationWithQueryParams(
          router.routerDelegate.currentConfiguration.uri.toString());
      expect(
        tester.widget<DummyScreen>(find.byType(DummyScreen)),
        isA<DummyScreen>().having(
          (DummyScreen screen) => screen.queryParametersAll,
          'screen.queryParametersAll',
          queryParametersAll,
        ),
      );
    });
  });

  testWidgets('go should preserve the query parameters when navigating',
      (WidgetTester tester) async {
    const Map<String, dynamic> queryParametersAll = <String, List<dynamic>>{
      'q1': <String>['v1'],
      'q2': <String>['v2', 'v3'],
    };
    void expectLocationWithQueryParams(String location) {
      final Uri uri = Uri.parse(location);
      expect(uri.path, '/page');
      expect(uri.queryParametersAll, queryParametersAll);
    }

    final List<GoRoute> routes = <GoRoute>[
      GoRoute(
        path: '/',
        builder: (BuildContext context, GoRouterState state) =>
            const HomeScreen(),
      ),
      GoRoute(
        name: 'page',
        path: '/page',
        builder: (BuildContext context, GoRouterState state) {
          expect(state.uri.queryParametersAll, queryParametersAll);
          expectLocationWithQueryParams(state.uri.toString());
          return DummyScreen(
            queryParametersAll: state.uri.queryParametersAll,
          );
        },
      ),
    ];

    final GoRouter router = await createRouter(routes, tester);

    router.go('/page?q1=v1&q2=v2&q2=v3');
    await tester.pumpAndSettle();
    final List<RouteMatchBase> matches =
        router.routerDelegate.currentConfiguration.matches;

    expect(matches, hasLength(1));
    expectLocationWithQueryParams(
        router.routerDelegate.currentConfiguration.uri.toString());
    expect(
      tester.widget<DummyScreen>(find.byType(DummyScreen)),
      isA<DummyScreen>().having(
        (DummyScreen screen) => screen.queryParametersAll,
        'screen.queryParametersAll',
        queryParametersAll,
      ),
    );
  });

  testWidgets('goRouter should rebuild widget if ',
      (WidgetTester tester) async {
    const Map<String, dynamic> queryParametersAll = <String, List<dynamic>>{
      'q1': <String>['v1'],
      'q2': <String>['v2', 'v3'],
    };
    void expectLocationWithQueryParams(String location) {
      final Uri uri = Uri.parse(location);
      expect(uri.path, '/page');
      expect(uri.queryParametersAll, queryParametersAll);
    }

    final List<GoRoute> routes = <GoRoute>[
      GoRoute(
        path: '/',
        builder: (BuildContext context, GoRouterState state) =>
            const HomeScreen(),
      ),
      GoRoute(
        name: 'page',
        path: '/page',
        builder: (BuildContext context, GoRouterState state) {
          expect(state.uri.queryParametersAll, queryParametersAll);
          expectLocationWithQueryParams(state.uri.toString());
          return DummyScreen(
            queryParametersAll: state.uri.queryParametersAll,
          );
        },
      ),
    ];

    final GoRouter router = await createRouter(routes, tester);

    router.go('/page?q1=v1&q2=v2&q2=v3');
    await tester.pumpAndSettle();
    final List<RouteMatchBase> matches =
        router.routerDelegate.currentConfiguration.matches;

    expect(matches, hasLength(1));
    expectLocationWithQueryParams(
        router.routerDelegate.currentConfiguration.uri.toString());
    expect(
      tester.widget<DummyScreen>(find.byType(DummyScreen)),
      isA<DummyScreen>().having(
        (DummyScreen screen) => screen.queryParametersAll,
        'screen.queryParametersAll',
        queryParametersAll,
      ),
    );
  });

  group('GoRouterHelper extensions', () {
    final GlobalKey<DummyStatefulWidgetState> key =
        GlobalKey<DummyStatefulWidgetState>();
    final List<GoRoute> routes = <GoRoute>[
      GoRoute(
        path: '/',
        name: 'home',
        builder: (BuildContext context, GoRouterState state) =>
            DummyStatefulWidget(key: key),
      ),
      GoRoute(
        path: '/page1',
        name: 'page1',
        builder: (BuildContext context, GoRouterState state) =>
            const Page1Screen(),
      ),
    ];

    const String name = 'page1';
    final Map<String, String> params = <String, String>{
      'a-param-key': 'a-param-value',
    };
    final Map<String, String> queryParams = <String, String>{
      'a-query-key': 'a-query-value',
    };
    const String location = '/page1';
    const String extra = 'Hello';

    testWidgets('calls [namedLocation] on closest GoRouter',
        (WidgetTester tester) async {
      final GoRouterNamedLocationSpy router =
          GoRouterNamedLocationSpy(routes: routes);
      addTearDown(router.dispose);
      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: router,
          title: 'GoRouter Example',
        ),
      );
      key.currentContext!.namedLocation(
        name,
        pathParameters: params,
        queryParameters: queryParams,
      );
      expect(router.name, name);
      expect(router.pathParameters, params);
      expect(router.queryParameters, queryParams);
    });

    testWidgets('calls [go] on closest GoRouter', (WidgetTester tester) async {
      final GoRouterGoSpy router = GoRouterGoSpy(routes: routes);
      addTearDown(router.dispose);
      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: router,
          title: 'GoRouter Example',
        ),
      );
      key.currentContext!.go(
        location,
        extra: extra,
      );
      expect(router.myLocation, location);
      expect(router.extra, extra);
    });

    testWidgets('calls [goNamed] on closest GoRouter',
        (WidgetTester tester) async {
      final GoRouterGoNamedSpy router = GoRouterGoNamedSpy(routes: routes);
      addTearDown(router.dispose);
      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: router,
          title: 'GoRouter Example',
        ),
      );
      key.currentContext!.goNamed(
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

    testWidgets('calls [push] on closest GoRouter',
        (WidgetTester tester) async {
      final GoRouterPushSpy router = GoRouterPushSpy(routes: routes);
      addTearDown(router.dispose);
      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: router,
          title: 'GoRouter Example',
        ),
      );
      key.currentContext!.push(
        location,
        extra: extra,
      );
      expect(router.myLocation, location);
      expect(router.extra, extra);
    });

    testWidgets('calls [push] on closest GoRouter and waits for result',
        (WidgetTester tester) async {
      final GoRouterPushSpy router = GoRouterPushSpy(routes: routes);
      addTearDown(router.dispose);
      await tester.pumpWidget(
        MaterialApp.router(
          routeInformationProvider: router.routeInformationProvider,
          routeInformationParser: router.routeInformationParser,
          routerDelegate: router.routerDelegate,
          title: 'GoRouter Example',
        ),
      );
      final String? result = await router.push<String>(
        location,
        extra: extra,
      );
      expect(result, extra);
      expect(router.myLocation, location);
      expect(router.extra, extra);
    });

    testWidgets('calls [pushNamed] on closest GoRouter',
        (WidgetTester tester) async {
      final GoRouterPushNamedSpy router = GoRouterPushNamedSpy(routes: routes);
      addTearDown(router.dispose);
      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: router,
          title: 'GoRouter Example',
        ),
      );
      key.currentContext!.pushNamed(
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

    testWidgets('calls [pushNamed] on closest GoRouter and waits for result',
        (WidgetTester tester) async {
      final GoRouterPushNamedSpy router = GoRouterPushNamedSpy(routes: routes);
      addTearDown(router.dispose);
      await tester.pumpWidget(
        MaterialApp.router(
          routeInformationProvider: router.routeInformationProvider,
          routeInformationParser: router.routeInformationParser,
          routerDelegate: router.routerDelegate,
          title: 'GoRouter Example',
        ),
      );
      final String? result = await router.pushNamed<String>(
        name,
        pathParameters: params,
        queryParameters: queryParams,
        extra: extra,
      );
      expect(result, extra);
      expect(router.extra, extra);
      expect(router.name, name);
      expect(router.pathParameters, params);
      expect(router.queryParameters, queryParams);
    });

    testWidgets('calls [pop] on closest GoRouter', (WidgetTester tester) async {
      final GoRouterPopSpy router = GoRouterPopSpy(routes: routes);
      addTearDown(router.dispose);
      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: router,
          title: 'GoRouter Example',
        ),
      );
      key.currentContext!.pop();
      expect(router.popped, true);
      expect(router.poppedResult, null);
    });

    testWidgets('calls [pop] on closest GoRouter with result',
        (WidgetTester tester) async {
      final GoRouterPopSpy router = GoRouterPopSpy(routes: routes);
      addTearDown(router.dispose);
      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: router,
          title: 'GoRouter Example',
        ),
      );
      key.currentContext!.pop('result');
      expect(router.popped, true);
      expect(router.poppedResult, 'result');
    });
  });

  group('ShellRoute', () {
    testWidgets('defaultRoute', (WidgetTester tester) async {
      final List<RouteBase> routes = <RouteBase>[
        ShellRoute(
          builder: (BuildContext context, GoRouterState state, Widget child) {
            return Scaffold(
              body: child,
            );
          },
          routes: <RouteBase>[
            GoRoute(
              path: '/a',
              builder: (BuildContext context, GoRouterState state) {
                return const Scaffold(
                  body: Text('Screen A'),
                );
              },
            ),
            GoRoute(
              path: '/b',
              builder: (BuildContext context, GoRouterState state) {
                return const Scaffold(
                  body: Text('Screen B'),
                );
              },
            ),
          ],
        ),
      ];

      await createRouter(routes, tester, initialLocation: '/b');
      expect(find.text('Screen B'), findsOneWidget);
    });

    testWidgets(
        'Pops from the correct Navigator when the Android back button is pressed',
        (WidgetTester tester) async {
      final List<RouteBase> routes = <RouteBase>[
        ShellRoute(
          builder: (BuildContext context, GoRouterState state, Widget child) {
            return Scaffold(
              body: Column(
                children: <Widget>[
                  const Text('Screen A'),
                  Expanded(child: child),
                ],
              ),
            );
          },
          routes: <RouteBase>[
            GoRoute(
              path: '/b',
              builder: (BuildContext context, GoRouterState state) {
                return const Scaffold(
                  body: Text('Screen B'),
                );
              },
              routes: <RouteBase>[
                GoRoute(
                  path: 'c',
                  builder: (BuildContext context, GoRouterState state) {
                    return const Scaffold(
                      body: Text('Screen C'),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ];

      await createRouter(routes, tester, initialLocation: '/b/c');
      expect(find.text('Screen A'), findsOneWidget);
      expect(find.text('Screen B'), findsNothing);
      expect(find.text('Screen C'), findsOneWidget);

      await simulateAndroidBackButton(tester);
      await tester.pumpAndSettle();

      expect(find.text('Screen A'), findsOneWidget);
      expect(find.text('Screen B'), findsOneWidget);
      expect(find.text('Screen C'), findsNothing);
    });

    testWidgets(
        'Pops from the correct navigator when a sub-route is placed on '
        'the root Navigator', (WidgetTester tester) async {
      final GlobalKey<NavigatorState> rootNavigatorKey =
          GlobalKey<NavigatorState>();
      final GlobalKey<NavigatorState> shellNavigatorKey =
          GlobalKey<NavigatorState>();

      final List<RouteBase> routes = <RouteBase>[
        ShellRoute(
          navigatorKey: shellNavigatorKey,
          builder: (BuildContext context, GoRouterState state, Widget child) {
            return Scaffold(
              body: Column(
                children: <Widget>[
                  const Text('Screen A'),
                  Expanded(child: child),
                ],
              ),
            );
          },
          routes: <RouteBase>[
            GoRoute(
              path: '/b',
              builder: (BuildContext context, GoRouterState state) {
                return const Scaffold(
                  body: Text('Screen B'),
                );
              },
              routes: <RouteBase>[
                GoRoute(
                  path: 'c',
                  parentNavigatorKey: rootNavigatorKey,
                  builder: (BuildContext context, GoRouterState state) {
                    return const Scaffold(
                      body: Text('Screen C'),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ];

      await createRouter(routes, tester,
          initialLocation: '/b/c', navigatorKey: rootNavigatorKey);
      expect(find.text('Screen A'), findsNothing);
      expect(find.text('Screen B'), findsNothing);
      expect(find.text('Screen C'), findsOneWidget);

      await simulateAndroidBackButton(tester);
      await tester.pumpAndSettle();

      expect(find.text('Screen A'), findsOneWidget);
      expect(find.text('Screen B'), findsOneWidget);
      expect(find.text('Screen C'), findsNothing);
    });

    testWidgets('Builds StatefulShellRoute', (WidgetTester tester) async {
      final GlobalKey<NavigatorState> rootNavigatorKey =
          GlobalKey<NavigatorState>();

      final List<RouteBase> routes = <RouteBase>[
        StatefulShellRoute.indexedStack(
          builder: (BuildContext context, GoRouterState state,
                  StatefulNavigationShell navigationShell) =>
              navigationShell,
          branches: <StatefulShellBranch>[
            StatefulShellBranch(routes: <GoRoute>[
              GoRoute(
                path: '/a',
                builder: (BuildContext context, GoRouterState state) =>
                    const Text('Screen A'),
              ),
            ]),
            StatefulShellBranch(routes: <GoRoute>[
              GoRoute(
                path: '/b',
                builder: (BuildContext context, GoRouterState state) =>
                    const Text('Screen B'),
              ),
            ]),
          ],
        ),
      ];

      final GoRouter router = await createRouter(routes, tester,
          initialLocation: '/a', navigatorKey: rootNavigatorKey);
      expect(find.text('Screen A'), findsOneWidget);
      expect(find.text('Screen B'), findsNothing);

      router.go('/b');
      await tester.pumpAndSettle();
      expect(find.text('Screen A'), findsNothing);
      expect(find.text('Screen B'), findsOneWidget);
    });

    testWidgets('Builds StatefulShellRoute as a sub-route',
        (WidgetTester tester) async {
      final GlobalKey<NavigatorState> rootNavigatorKey =
          GlobalKey<NavigatorState>();

      final List<RouteBase> routes = <RouteBase>[
        GoRoute(
          path: '/root',
          builder: (BuildContext context, GoRouterState state) =>
              const Text('Root'),
          routes: <RouteBase>[
            StatefulShellRoute.indexedStack(
              builder: (BuildContext context, GoRouterState state,
                      StatefulNavigationShell navigationShell) =>
                  navigationShell,
              branches: <StatefulShellBranch>[
                StatefulShellBranch(routes: <GoRoute>[
                  GoRoute(
                    path: 'a',
                    builder: (BuildContext context, GoRouterState state) =>
                        const Text('Screen A'),
                  ),
                ]),
                StatefulShellBranch(routes: <GoRoute>[
                  GoRoute(
                    path: 'b',
                    builder: (BuildContext context, GoRouterState state) =>
                        const Text('Screen B'),
                  ),
                ]),
              ],
            ),
          ],
        ),
      ];

      final GoRouter router = await createRouter(routes, tester,
          initialLocation: '/root/a', navigatorKey: rootNavigatorKey);
      expect(find.text('Screen A'), findsOneWidget);
      expect(find.text('Screen B'), findsNothing);

      router.go('/root/b');
      await tester.pumpAndSettle();
      expect(find.text('Screen A'), findsNothing);
      expect(find.text('Screen B'), findsOneWidget);
    });

    testWidgets(
        'Navigation with goBranch is correctly handled in StatefulShellRoute',
        (WidgetTester tester) async {
      final GlobalKey<NavigatorState> rootNavigatorKey =
          GlobalKey<NavigatorState>();
      final GlobalKey<DummyStatefulWidgetState> statefulWidgetKey =
          GlobalKey<DummyStatefulWidgetState>();
      StatefulNavigationShell? routeState;

      final List<RouteBase> routes = <RouteBase>[
        StatefulShellRoute.indexedStack(
          builder: (BuildContext context, GoRouterState state,
              StatefulNavigationShell navigationShell) {
            routeState = navigationShell;
            return navigationShell;
          },
          branches: <StatefulShellBranch>[
            StatefulShellBranch(
              routes: <RouteBase>[
                GoRoute(
                  path: '/a',
                  builder: (BuildContext context, GoRouterState state) =>
                      const Text('Screen A'),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: <RouteBase>[
                GoRoute(
                  path: '/b',
                  builder: (BuildContext context, GoRouterState state) =>
                      const Text('Screen B'),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: <RouteBase>[
                GoRoute(
                  path: '/c',
                  builder: (BuildContext context, GoRouterState state) =>
                      const Text('Screen C'),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: <RouteBase>[
                GoRoute(
                  path: '/d',
                  builder: (BuildContext context, GoRouterState state) =>
                      const Text('Screen D'),
                ),
              ],
            ),
          ],
        ),
      ];

      await createRouter(routes, tester,
          initialLocation: '/a', navigatorKey: rootNavigatorKey);
      statefulWidgetKey.currentState?.increment();
      expect(find.text('Screen A'), findsOneWidget);
      expect(find.text('Screen B'), findsNothing);
      expect(find.text('Screen C'), findsNothing);
      expect(find.text('Screen D'), findsNothing);

      routeState!.goBranch(1);
      await tester.pumpAndSettle();
      expect(find.text('Screen A'), findsNothing);
      expect(find.text('Screen B'), findsOneWidget);
      expect(find.text('Screen C'), findsNothing);
      expect(find.text('Screen D'), findsNothing);

      routeState!.goBranch(2);
      await tester.pumpAndSettle();
      expect(find.text('Screen A'), findsNothing);
      expect(find.text('Screen B'), findsNothing);
      expect(find.text('Screen C'), findsOneWidget);
      expect(find.text('Screen D'), findsNothing);

      routeState!.goBranch(3);
      await tester.pumpAndSettle();
      expect(find.text('Screen A'), findsNothing);
      expect(find.text('Screen B'), findsNothing);
      expect(find.text('Screen C'), findsNothing);
      expect(find.text('Screen D'), findsOneWidget);

      expect(() {
        // Verify that navigation to unknown index fails
        routeState!.goBranch(4);
      }, throwsA(isA<Error>()));
    });

    testWidgets(
        'Navigates to correct nested navigation tree in StatefulShellRoute '
        'and maintains state', (WidgetTester tester) async {
      final GlobalKey<NavigatorState> rootNavigatorKey =
          GlobalKey<NavigatorState>();
      final GlobalKey<DummyStatefulWidgetState> statefulWidgetKey =
          GlobalKey<DummyStatefulWidgetState>();
      StatefulNavigationShell? routeState;

      final List<RouteBase> routes = <RouteBase>[
        StatefulShellRoute.indexedStack(
          builder: (BuildContext context, GoRouterState state,
              StatefulNavigationShell navigationShell) {
            routeState = navigationShell;
            return navigationShell;
          },
          branches: <StatefulShellBranch>[
            StatefulShellBranch(routes: <GoRoute>[
              GoRoute(
                path: '/a',
                builder: (BuildContext context, GoRouterState state) =>
                    const Text('Screen A'),
                routes: <RouteBase>[
                  GoRoute(
                    path: 'detailA',
                    builder: (BuildContext context, GoRouterState state) =>
                        Column(children: <Widget>[
                      const Text('Screen A Detail'),
                      DummyStatefulWidget(key: statefulWidgetKey),
                    ]),
                  ),
                ],
              ),
            ]),
            StatefulShellBranch(routes: <GoRoute>[
              GoRoute(
                path: '/b',
                builder: (BuildContext context, GoRouterState state) =>
                    const Text('Screen B'),
              ),
            ]),
          ],
        ),
      ];

      final GoRouter router = await createRouter(routes, tester,
          initialLocation: '/a/detailA', navigatorKey: rootNavigatorKey);
      statefulWidgetKey.currentState?.increment();
      expect(find.text('Screen A'), findsNothing);
      expect(find.text('Screen A Detail'), findsOneWidget);
      expect(find.text('Screen B'), findsNothing);

      routeState!.goBranch(1);
      await tester.pumpAndSettle();
      expect(find.text('Screen A'), findsNothing);
      expect(find.text('Screen A Detail'), findsNothing);
      expect(find.text('Screen B'), findsOneWidget);

      routeState!.goBranch(0);
      await tester.pumpAndSettle();
      expect(statefulWidgetKey.currentState?.counter, equals(1));

      router.go('/a');
      await tester.pumpAndSettle();
      expect(find.text('Screen A'), findsOneWidget);
      expect(find.text('Screen A Detail'), findsNothing);
      router.go('/a/detailA');
      await tester.pumpAndSettle();
      expect(statefulWidgetKey.currentState?.counter, equals(0));
    });

    testWidgets('Maintains state for nested StatefulShellRoute',
        (WidgetTester tester) async {
      final GlobalKey<NavigatorState> rootNavigatorKey =
          GlobalKey<NavigatorState>();
      final GlobalKey<DummyStatefulWidgetState> statefulWidgetKey =
          GlobalKey<DummyStatefulWidgetState>();
      StatefulNavigationShell? routeState1;
      StatefulNavigationShell? routeState2;

      final List<RouteBase> routes = <RouteBase>[
        StatefulShellRoute.indexedStack(
          builder: (BuildContext context, GoRouterState state,
              StatefulNavigationShell navigationShell) {
            routeState1 = navigationShell;
            return navigationShell;
          },
          branches: <StatefulShellBranch>[
            StatefulShellBranch(routes: <RouteBase>[
              StatefulShellRoute.indexedStack(
                  builder: (BuildContext context, GoRouterState state,
                      StatefulNavigationShell navigationShell) {
                    routeState2 = navigationShell;
                    return navigationShell;
                  },
                  branches: <StatefulShellBranch>[
                    StatefulShellBranch(routes: <RouteBase>[
                      GoRoute(
                        path: '/a',
                        builder: (BuildContext context, GoRouterState state) =>
                            const Text('Screen A'),
                        routes: <RouteBase>[
                          GoRoute(
                            path: 'detailA',
                            builder:
                                (BuildContext context, GoRouterState state) =>
                                    Column(children: <Widget>[
                              const Text('Screen A Detail'),
                              DummyStatefulWidget(key: statefulWidgetKey),
                            ]),
                          ),
                        ],
                      ),
                    ]),
                    StatefulShellBranch(routes: <RouteBase>[
                      GoRoute(
                        path: '/b',
                        builder: (BuildContext context, GoRouterState state) =>
                            const Text('Screen B'),
                      ),
                    ]),
                    StatefulShellBranch(routes: <RouteBase>[
                      GoRoute(
                        path: '/c',
                        builder: (BuildContext context, GoRouterState state) =>
                            const Text('Screen C'),
                      ),
                    ]),
                  ]),
            ]),
            StatefulShellBranch(routes: <GoRoute>[
              GoRoute(
                path: '/d',
                builder: (BuildContext context, GoRouterState state) =>
                    const Text('Screen D'),
              ),
            ]),
          ],
        ),
      ];

      await createRouter(routes, tester,
          initialLocation: '/a/detailA', navigatorKey: rootNavigatorKey);
      statefulWidgetKey.currentState?.increment();
      expect(find.text('Screen A Detail'), findsOneWidget);
      routeState2!.goBranch(1);
      await tester.pumpAndSettle();
      expect(find.text('Screen B'), findsOneWidget);

      routeState1!.goBranch(1);
      await tester.pumpAndSettle();
      expect(find.text('Screen D'), findsOneWidget);

      routeState1!.goBranch(0);
      await tester.pumpAndSettle();
      expect(find.text('Screen B'), findsOneWidget);

      routeState2!.goBranch(2);
      await tester.pumpAndSettle();
      expect(find.text('Screen C'), findsOneWidget);

      routeState2!.goBranch(0);
      await tester.pumpAndSettle();
      expect(find.text('Screen A Detail'), findsOneWidget);
      expect(statefulWidgetKey.currentState?.counter, equals(1));
    });

    testWidgets(
        'Pops from the correct Navigator in a StatefulShellRoute when the '
        'Android back button is pressed', (WidgetTester tester) async {
      final GlobalKey<NavigatorState> rootNavigatorKey =
          GlobalKey<NavigatorState>();
      final GlobalKey<NavigatorState> sectionANavigatorKey =
          GlobalKey<NavigatorState>();
      final GlobalKey<NavigatorState> sectionBNavigatorKey =
          GlobalKey<NavigatorState>();
      StatefulNavigationShell? routeState;

      final List<RouteBase> routes = <RouteBase>[
        StatefulShellRoute.indexedStack(
          builder: (BuildContext context, GoRouterState state,
              StatefulNavigationShell navigationShell) {
            routeState = navigationShell;
            return navigationShell;
          },
          branches: <StatefulShellBranch>[
            StatefulShellBranch(
                navigatorKey: sectionANavigatorKey,
                routes: <GoRoute>[
                  GoRoute(
                    path: '/a',
                    builder: (BuildContext context, GoRouterState state) =>
                        const Text('Screen A'),
                    routes: <RouteBase>[
                      GoRoute(
                        path: 'detailA',
                        builder: (BuildContext context, GoRouterState state) =>
                            const Text('Screen A Detail'),
                      ),
                    ],
                  ),
                ]),
            StatefulShellBranch(
                navigatorKey: sectionBNavigatorKey,
                routes: <GoRoute>[
                  GoRoute(
                    path: '/b',
                    builder: (BuildContext context, GoRouterState state) =>
                        const Text('Screen B'),
                    routes: <RouteBase>[
                      GoRoute(
                        path: 'detailB',
                        builder: (BuildContext context, GoRouterState state) =>
                            const Text('Screen B Detail'),
                      ),
                    ],
                  ),
                ]),
          ],
        ),
      ];

      final GoRouter router = await createRouter(routes, tester,
          initialLocation: '/a/detailA', navigatorKey: rootNavigatorKey);
      expect(find.text('Screen A'), findsNothing);
      expect(find.text('Screen A Detail'), findsOneWidget);
      expect(find.text('Screen B'), findsNothing);
      expect(find.text('Screen B Detail'), findsNothing);

      router.go('/b/detailB');
      await tester.pumpAndSettle();

      expect(find.text('Screen A'), findsNothing);
      expect(find.text('Screen A Detail'), findsNothing);
      expect(find.text('Screen B'), findsNothing);
      expect(find.text('Screen B Detail'), findsOneWidget);

      await simulateAndroidBackButton(tester);
      await tester.pumpAndSettle();

      expect(find.text('Screen A'), findsNothing);
      expect(find.text('Screen A Detail'), findsNothing);
      expect(find.text('Screen B'), findsOneWidget);
      expect(find.text('Screen B Detail'), findsNothing);

      routeState!.goBranch(0);
      await tester.pumpAndSettle();
      expect(find.text('Screen A'), findsNothing);
      expect(find.text('Screen A Detail'), findsOneWidget);

      await simulateAndroidBackButton(tester);
      await tester.pumpAndSettle();
      expect(find.text('Screen A'), findsOneWidget);
      expect(find.text('Screen A Detail'), findsNothing);
    });

    testWidgets(
        'Maintains extra navigation information when navigating '
        'between branches in StatefulShellRoute', (WidgetTester tester) async {
      final GlobalKey<NavigatorState> rootNavigatorKey =
          GlobalKey<NavigatorState>();
      StatefulNavigationShell? routeState;

      final List<RouteBase> routes = <RouteBase>[
        StatefulShellRoute.indexedStack(
          builder: (BuildContext context, GoRouterState state,
              StatefulNavigationShell navigationShell) {
            routeState = navigationShell;
            return navigationShell;
          },
          branches: <StatefulShellBranch>[
            StatefulShellBranch(routes: <GoRoute>[
              GoRoute(
                path: '/a',
                builder: (BuildContext context, GoRouterState state) =>
                    const Text('Screen A'),
              ),
            ]),
            StatefulShellBranch(routes: <GoRoute>[
              GoRoute(
                path: '/b',
                builder: (BuildContext context, GoRouterState state) =>
                    Text('Screen B - ${state.extra}'),
              ),
            ]),
          ],
        ),
      ];

      final GoRouter router = await createRouter(routes, tester,
          initialLocation: '/a', navigatorKey: rootNavigatorKey);
      expect(find.text('Screen A'), findsOneWidget);

      router.go('/b', extra: 'X');
      await tester.pumpAndSettle();
      expect(find.text('Screen A'), findsNothing);
      expect(find.text('Screen B - X'), findsOneWidget);

      routeState!.goBranch(0);
      await tester.pumpAndSettle();
      expect(find.text('Screen A'), findsOneWidget);
      expect(find.text('Screen B - X'), findsNothing);

      routeState!.goBranch(1);
      await tester.pumpAndSettle();
      expect(find.text('Screen A'), findsNothing);
      expect(find.text('Screen B - X'), findsOneWidget);
    });

    testWidgets(
        'Pushed non-descendant routes are correctly restored when '
        'navigating between branches in StatefulShellRoute',
        (WidgetTester tester) async {
      final GlobalKey<NavigatorState> rootNavigatorKey =
          GlobalKey<NavigatorState>();
      StatefulNavigationShell? routeState;

      final List<RouteBase> routes = <RouteBase>[
        GoRoute(
          path: '/common',
          builder: (BuildContext context, GoRouterState state) =>
              Text('Common - ${state.extra}'),
        ),
        StatefulShellRoute.indexedStack(
          builder: (BuildContext context, GoRouterState state,
              StatefulNavigationShell navigationShell) {
            routeState = navigationShell;
            return navigationShell;
          },
          branches: <StatefulShellBranch>[
            StatefulShellBranch(routes: <GoRoute>[
              GoRoute(
                path: '/a',
                builder: (BuildContext context, GoRouterState state) =>
                    const Text('Screen A'),
              ),
            ]),
            StatefulShellBranch(routes: <GoRoute>[
              GoRoute(
                path: '/b',
                builder: (BuildContext context, GoRouterState state) =>
                    const Text('Screen B'),
              ),
            ]),
          ],
        ),
      ];

      final GoRouter router = await createRouter(routes, tester,
          initialLocation: '/a', navigatorKey: rootNavigatorKey);
      expect(find.text('Screen A'), findsOneWidget);

      router.go('/b');
      await tester.pumpAndSettle();
      expect(find.text('Screen A'), findsNothing);
      expect(find.text('Screen B'), findsOneWidget);

      // This push '/common' on top of entire stateful shell route page.
      router.push('/common', extra: 'X');
      await tester.pumpAndSettle();
      expect(find.text('Screen A'), findsNothing);
      expect(find.text('Screen B'), findsNothing);
      expect(find.text('Common - X'), findsOneWidget);

      routeState!.goBranch(0);
      await tester.pumpAndSettle();
      expect(find.text('Screen A'), findsOneWidget);

      routeState!.goBranch(1);
      await tester.pumpAndSettle();
      expect(find.text('Screen A'), findsNothing);
      expect(find.text('Screen B'), findsOneWidget);
    });

    testWidgets(
        'Redirects are correctly handled when switching branch in a '
        'StatefulShellRoute', (WidgetTester tester) async {
      final GlobalKey<NavigatorState> rootNavigatorKey =
          GlobalKey<NavigatorState>();
      StatefulNavigationShell? routeState;

      final List<RouteBase> routes = <RouteBase>[
        StatefulShellRoute.indexedStack(
          builder: (BuildContext context, GoRouterState state,
              StatefulNavigationShell navigationShell) {
            routeState = navigationShell;
            return navigationShell;
          },
          branches: <StatefulShellBranch>[
            StatefulShellBranch(routes: <GoRoute>[
              GoRoute(
                path: '/a',
                builder: (BuildContext context, GoRouterState state) =>
                    const Text('Screen A'),
              ),
            ]),
            StatefulShellBranch(routes: <GoRoute>[
              GoRoute(
                path: '/b',
                builder: (BuildContext context, GoRouterState state) =>
                    const Text('Screen B'),
                routes: <RouteBase>[
                  GoRoute(
                    path: 'details1',
                    builder: (BuildContext context, GoRouterState state) =>
                        const Text('Screen B Detail1'),
                  ),
                  GoRoute(
                    path: 'details2',
                    builder: (BuildContext context, GoRouterState state) =>
                        const Text('Screen B Detail2'),
                  ),
                ],
              ),
            ]),
            StatefulShellBranch(routes: <GoRoute>[
              GoRoute(
                path: '/c',
                redirect: (_, __) => '/c/main2',
              ),
              GoRoute(
                path: '/c/main1',
                builder: (BuildContext context, GoRouterState state) =>
                    const Text('Screen C1'),
              ),
              GoRoute(
                path: '/c/main2',
                builder: (BuildContext context, GoRouterState state) =>
                    const Text('Screen C2'),
              ),
            ]),
          ],
        ),
      ];

      String redirectDestinationBranchB = '/b/details1';
      await createRouter(
        routes,
        tester,
        initialLocation: '/a',
        navigatorKey: rootNavigatorKey,
        redirect: (_, GoRouterState state) {
          if (state.uri.toString().startsWith('/b')) {
            return redirectDestinationBranchB;
          }
          return null;
        },
      );
      expect(find.text('Screen A'), findsOneWidget);
      expect(find.text('Screen B Detail'), findsNothing);

      routeState!.goBranch(1);
      await tester.pumpAndSettle();
      expect(find.text('Screen A'), findsNothing);
      expect(find.text('Screen B Detail1'), findsOneWidget);

      routeState!.goBranch(2);
      await tester.pumpAndSettle();
      expect(find.text('Screen A'), findsNothing);
      expect(find.text('Screen B Detail1'), findsNothing);
      expect(find.text('Screen C2'), findsOneWidget);

      redirectDestinationBranchB = '/b/details2';
      routeState!.goBranch(1);
      await tester.pumpAndSettle();
      expect(find.text('Screen A'), findsNothing);
      expect(find.text('Screen B Detail2'), findsOneWidget);
      expect(find.text('Screen C2'), findsNothing);
    });

    testWidgets(
        'Pushed top-level route is correctly handled by StatefulShellRoute',
        (WidgetTester tester) async {
      final GlobalKey<NavigatorState> rootNavigatorKey =
          GlobalKey<NavigatorState>();
      final GlobalKey<NavigatorState> nestedNavigatorKey =
          GlobalKey<NavigatorState>();
      StatefulNavigationShell? routeState;

      final List<RouteBase> routes = <RouteBase>[
        // First level shell
        StatefulShellRoute.indexedStack(
          builder: (BuildContext context, GoRouterState state,
              StatefulNavigationShell navigationShell) {
            routeState = navigationShell;
            return navigationShell;
          },
          branches: <StatefulShellBranch>[
            StatefulShellBranch(routes: <GoRoute>[
              GoRoute(
                path: '/a',
                builder: (BuildContext context, GoRouterState state) =>
                    const Text('Screen A'),
              ),
            ]),
            StatefulShellBranch(routes: <RouteBase>[
              // Second level / nested shell
              StatefulShellRoute.indexedStack(
                builder: (BuildContext context, GoRouterState state,
                        StatefulNavigationShell navigationShell) =>
                    navigationShell,
                branches: <StatefulShellBranch>[
                  StatefulShellBranch(routes: <GoRoute>[
                    GoRoute(
                      path: '/b1',
                      builder: (BuildContext context, GoRouterState state) =>
                          const Text('Screen B1'),
                    ),
                  ]),
                  StatefulShellBranch(
                      navigatorKey: nestedNavigatorKey,
                      routes: <GoRoute>[
                        GoRoute(
                          path: '/b2',
                          builder:
                              (BuildContext context, GoRouterState state) =>
                                  const Text('Screen B2'),
                        ),
                        GoRoute(
                          path: '/b2-modal',
                          // We pass an explicit parentNavigatorKey here, to
                          // properly test the logic in RouteBuilder, i.e.
                          // routes with parentNavigatorKeys under the shell
                          // should not be stripped.
                          parentNavigatorKey: nestedNavigatorKey,
                          builder:
                              (BuildContext context, GoRouterState state) =>
                                  const Text('Nested Modal'),
                        ),
                      ]),
                ],
              ),
            ]),
          ],
        ),
        GoRoute(
          path: '/top-modal',
          parentNavigatorKey: rootNavigatorKey,
          builder: (BuildContext context, GoRouterState state) =>
              const Text('Top Modal'),
        ),
      ];

      final GoRouter router = await createRouter(routes, tester,
          initialLocation: '/a', navigatorKey: rootNavigatorKey);
      expect(find.text('Screen A'), findsOneWidget);

      routeState!.goBranch(1);
      await tester.pumpAndSettle();
      expect(find.text('Screen B1'), findsOneWidget);

      // Navigate nested (second level) shell to second branch
      router.go('/b2');
      await tester.pumpAndSettle();
      expect(find.text('Screen B2'), findsOneWidget);

      // Push route over second branch of nested (second level) shell
      router.push('/b2-modal');
      await tester.pumpAndSettle();
      expect(find.text('Nested Modal'), findsOneWidget);

      // Push top-level route while on second branch
      router.push('/top-modal');
      await tester.pumpAndSettle();
      expect(find.text('Top Modal'), findsOneWidget);

      // Return to shell and first branch
      router.go('/a');
      await tester.pumpAndSettle();
      expect(find.text('Screen A'), findsOneWidget);

      // Switch to second branch, which should only contain 'Nested Modal'
      // (in the nested shell)
      routeState!.goBranch(1);
      await tester.pumpAndSettle();
      expect(find.text('Screen A'), findsNothing);
      expect(find.text('Screen B1'), findsNothing);
      expect(find.text('Screen B2'), findsNothing);
      expect(find.text('Top Modal'), findsNothing);
      expect(find.text('Nested Modal'), findsOneWidget);
    });
  });

  group('Imperative navigation', () {
    group('canPop', () {
      testWidgets(
        'It should return false if Navigator.canPop() returns false.',
        (WidgetTester tester) async {
          final GlobalKey<NavigatorState> navigatorKey =
              GlobalKey<NavigatorState>();
          final GoRouter router = GoRouter(
            initialLocation: '/',
            navigatorKey: navigatorKey,
            routes: <GoRoute>[
              GoRoute(
                path: '/',
                builder: (BuildContext context, _) {
                  return Scaffold(
                    body: TextButton(
                      onPressed: () async {
                        navigatorKey.currentState!.push(
                          MaterialPageRoute<void>(
                            builder: (BuildContext context) {
                              return const Scaffold(
                                body: Text('pageless route'),
                              );
                            },
                          ),
                        );
                      },
                      child: const Text('Push'),
                    ),
                  );
                },
              ),
              GoRoute(path: '/a', builder: (_, __) => const DummyScreen()),
            ],
          );
          addTearDown(router.dispose);

          await tester.pumpWidget(
            MaterialApp.router(
                routeInformationProvider: router.routeInformationProvider,
                routeInformationParser: router.routeInformationParser,
                routerDelegate: router.routerDelegate),
          );

          expect(router.canPop(), false);

          await tester.tap(find.text('Push'));
          await tester.pumpAndSettle();

          expect(
              find.text('pageless route', skipOffstage: false), findsOneWidget);
          expect(router.canPop(), true);
        },
      );

      testWidgets(
        'It checks if ShellRoute navigators can pop',
        (WidgetTester tester) async {
          final GlobalKey<NavigatorState> shellNavigatorKey =
              GlobalKey<NavigatorState>();
          final GoRouter router = GoRouter(
            initialLocation: '/a',
            routes: <RouteBase>[
              ShellRoute(
                navigatorKey: shellNavigatorKey,
                builder:
                    (BuildContext context, GoRouterState state, Widget child) {
                  return Scaffold(
                    appBar: AppBar(title: const Text('Shell')),
                    body: child,
                  );
                },
                routes: <GoRoute>[
                  GoRoute(
                    path: '/a',
                    builder: (BuildContext context, _) {
                      return Scaffold(
                        body: TextButton(
                          onPressed: () async {
                            shellNavigatorKey.currentState!.push(
                              MaterialPageRoute<void>(
                                builder: (BuildContext context) {
                                  return const Scaffold(
                                    body: Text('pageless route'),
                                  );
                                },
                              ),
                            );
                          },
                          child: const Text('Push'),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          );
          addTearDown(router.dispose);

          await tester.pumpWidget(
            MaterialApp.router(
                routeInformationProvider: router.routeInformationProvider,
                routeInformationParser: router.routeInformationParser,
                routerDelegate: router.routerDelegate),
          );

          expect(router.canPop(), false);
          expect(find.text('Push'), findsOneWidget);

          await tester.tap(find.text('Push'));
          await tester.pumpAndSettle();

          expect(
              find.text('pageless route', skipOffstage: false), findsOneWidget);
          expect(router.canPop(), true);
        },
      );

      testWidgets(
        'It checks if StatefulShellRoute navigators can pop',
        (WidgetTester tester) async {
          final GlobalKey<NavigatorState> rootNavigatorKey =
              GlobalKey<NavigatorState>();
          final GoRouter router = GoRouter(
            navigatorKey: rootNavigatorKey,
            initialLocation: '/a',
            routes: <RouteBase>[
              StatefulShellRoute.indexedStack(
                builder: mockStackedShellBuilder,
                branches: <StatefulShellBranch>[
                  StatefulShellBranch(routes: <GoRoute>[
                    GoRoute(
                      path: '/a',
                      builder: (BuildContext context, _) {
                        return const Scaffold(
                          body: Text('Screen A'),
                        );
                      },
                    ),
                  ]),
                  StatefulShellBranch(routes: <GoRoute>[
                    GoRoute(
                      path: '/b',
                      builder: (BuildContext context, _) {
                        return const Scaffold(
                          body: Text('Screen B'),
                        );
                      },
                      routes: <RouteBase>[
                        GoRoute(
                          path: 'detail',
                          builder: (BuildContext context, _) {
                            return const Scaffold(
                              body: Text('Screen B detail'),
                            );
                          },
                        ),
                      ],
                    ),
                  ]),
                ],
              ),
            ],
          );
          addTearDown(router.dispose);

          await tester.pumpWidget(
            MaterialApp.router(
                routeInformationProvider: router.routeInformationProvider,
                routeInformationParser: router.routeInformationParser,
                routerDelegate: router.routerDelegate),
          );

          expect(router.canPop(), false);

          router.go('/b/detail');
          await tester.pumpAndSettle();

          expect(find.text('Screen B detail', skipOffstage: false),
              findsOneWidget);
          expect(router.canPop(), true);
          // Verify that it is actually the StatefulShellRoute that reports
          // canPop = true
          expect(rootNavigatorKey.currentState?.canPop(), false);
        },
      );

      testWidgets('Pageless route should include in can pop',
          (WidgetTester tester) async {
        final GlobalKey<NavigatorState> root =
            GlobalKey<NavigatorState>(debugLabel: 'root');
        final GlobalKey<NavigatorState> shell =
            GlobalKey<NavigatorState>(debugLabel: 'shell');

        final GoRouter router = GoRouter(
          navigatorKey: root,
          routes: <RouteBase>[
            ShellRoute(
              navigatorKey: shell,
              builder:
                  (BuildContext context, GoRouterState state, Widget child) {
                return Scaffold(
                  body: Center(
                    child: Column(
                      children: <Widget>[
                        const Text('Shell'),
                        Expanded(child: child),
                      ],
                    ),
                  ),
                );
              },
              routes: <RouteBase>[
                GoRoute(
                  path: '/',
                  builder: (_, __) => const Text('A Screen'),
                ),
              ],
            ),
          ],
        );
        addTearDown(router.dispose);

        await tester.pumpWidget(MaterialApp.router(routerConfig: router));

        expect(router.canPop(), isFalse);
        expect(find.text('A Screen'), findsOneWidget);
        expect(find.text('Shell'), findsOneWidget);
        showDialog<void>(
            context: root.currentContext!,
            builder: (_) => const Text('A dialog'));
        await tester.pumpAndSettle();
        expect(find.text('A dialog'), findsOneWidget);
        expect(router.canPop(), isTrue);
      });
    });

    group('pop', () {
      testWidgets(
        'Should pop from the correct navigator when parentNavigatorKey is set',
        (WidgetTester tester) async {
          final GlobalKey<NavigatorState> root =
              GlobalKey<NavigatorState>(debugLabel: 'root');
          final GlobalKey<NavigatorState> shell =
              GlobalKey<NavigatorState>(debugLabel: 'shell');

          final GoRouter router = GoRouter(
            initialLocation: '/a/b',
            navigatorKey: root,
            routes: <GoRoute>[
              GoRoute(
                path: '/',
                builder: (BuildContext context, _) {
                  return const Scaffold(
                    body: Text('Home'),
                  );
                },
                routes: <RouteBase>[
                  ShellRoute(
                    navigatorKey: shell,
                    builder: (BuildContext context, GoRouterState state,
                        Widget child) {
                      return Scaffold(
                        body: Center(
                          child: Column(
                            children: <Widget>[
                              const Text('Shell'),
                              Expanded(child: child),
                            ],
                          ),
                        ),
                      );
                    },
                    routes: <RouteBase>[
                      GoRoute(
                        path: 'a',
                        builder: (_, __) => const Text('A Screen'),
                        routes: <RouteBase>[
                          GoRoute(
                            parentNavigatorKey: root,
                            path: 'b',
                            builder: (_, __) => const Text('B Screen'),
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

          await tester.pumpWidget(
            MaterialApp.router(
                routeInformationProvider: router.routeInformationProvider,
                routeInformationParser: router.routeInformationParser,
                routerDelegate: router.routerDelegate),
          );

          expect(router.canPop(), isTrue);
          expect(find.text('B Screen'), findsOneWidget);
          expect(find.text('A Screen'), findsNothing);
          expect(find.text('Shell'), findsNothing);
          expect(find.text('Home'), findsNothing);
          router.pop();
          await tester.pumpAndSettle();
          expect(find.text('A Screen'), findsOneWidget);
          expect(find.text('Shell'), findsOneWidget);
          expect(router.canPop(), isTrue);
          router.pop();
          await tester.pumpAndSettle();
          expect(find.text('Home'), findsOneWidget);
          expect(find.text('Shell'), findsNothing);
        },
      );

      testWidgets('Should pop dialog if it is present',
          (WidgetTester tester) async {
        final GlobalKey<NavigatorState> root =
            GlobalKey<NavigatorState>(debugLabel: 'root');
        final GlobalKey<NavigatorState> shell =
            GlobalKey<NavigatorState>(debugLabel: 'shell');

        final GoRouter router = GoRouter(
          initialLocation: '/a',
          navigatorKey: root,
          routes: <GoRoute>[
            GoRoute(
              path: '/',
              builder: (BuildContext context, _) {
                return const Scaffold(
                  body: Text('Home'),
                );
              },
              routes: <RouteBase>[
                ShellRoute(
                  navigatorKey: shell,
                  builder: (BuildContext context, GoRouterState state,
                      Widget child) {
                    return Scaffold(
                      body: Center(
                        child: Column(
                          children: <Widget>[
                            const Text('Shell'),
                            Expanded(child: child),
                          ],
                        ),
                      ),
                    );
                  },
                  routes: <RouteBase>[
                    GoRoute(
                      path: 'a',
                      builder: (_, __) => const Text('A Screen'),
                    ),
                  ],
                ),
              ],
            ),
          ],
        );
        addTearDown(router.dispose);

        await tester.pumpWidget(MaterialApp.router(routerConfig: router));

        expect(router.canPop(), isTrue);
        expect(find.text('A Screen'), findsOneWidget);
        expect(find.text('Shell'), findsOneWidget);
        expect(find.text('Home'), findsNothing);
        final Future<bool?> resultFuture = showDialog<bool>(
            context: root.currentContext!,
            builder: (_) => const Text('A dialog'));
        await tester.pumpAndSettle();
        expect(find.text('A dialog'), findsOneWidget);
        expect(router.canPop(), isTrue);

        router.pop<bool>(true);
        await tester.pumpAndSettle();
        expect(find.text('A Screen'), findsOneWidget);
        expect(find.text('Shell'), findsOneWidget);
        expect(find.text('A dialog'), findsNothing);
        final bool? result = await resultFuture;
        expect(result, isTrue);
      });

      testWidgets('Triggers a Hero inside a ShellRoute',
          (WidgetTester tester) async {
        final UniqueKey heroKey = UniqueKey();
        const String kHeroTag = 'hero';

        final List<RouteBase> routes = <RouteBase>[
          ShellRoute(
            builder: (BuildContext context, GoRouterState state, Widget child) {
              return child;
            },
            routes: <GoRoute>[
              GoRoute(
                  path: '/a',
                  builder: (BuildContext context, _) {
                    return Hero(
                      tag: kHeroTag,
                      child: Container(),
                      flightShuttleBuilder: (_, __, ___, ____, _____) {
                        return Container(key: heroKey);
                      },
                    );
                  }),
              GoRoute(
                  path: '/b',
                  builder: (BuildContext context, _) {
                    return Hero(
                      tag: kHeroTag,
                      child: Container(),
                    );
                  }),
            ],
          )
        ];
        final GoRouter router =
            await createRouter(routes, tester, initialLocation: '/a');

        // check that flightShuttleBuilder widget is not yet present
        expect(find.byKey(heroKey), findsNothing);

        // start navigation
        router.go('/b');
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 10));
        // check that flightShuttleBuilder widget is visible
        expect(find.byKey(heroKey), isOnstage);
        // // Waits for the animation finishes.
        await tester.pumpAndSettle();
        expect(find.byKey(heroKey), findsNothing);
      });
    });
  });

  group('of', () {
    testWidgets(
      'It should return the go router instance of the widget tree',
      (WidgetTester tester) async {
        const Key key = Key('key');
        final List<RouteBase> routes = <RouteBase>[
          GoRoute(
            path: '/',
            builder: (_, __) => const SizedBox(key: key),
          ),
        ];

        final GoRouter router = await createRouter(routes, tester);
        final Element context = tester.element(find.byKey(key));
        final GoRouter foundRouter = GoRouter.of(context);
        expect(foundRouter, router);
      },
    );

    testWidgets(
      'It should throw if there is no go router in the widget tree',
      (WidgetTester tester) async {
        const Key key = Key('key');
        await tester.pumpWidget(const SizedBox(key: key));

        final Element context = tester.element(find.byKey(key));
        expect(() => GoRouter.of(context), throwsA(anything));
      },
    );
  });

  group('maybeOf', () {
    testWidgets(
      'It should return the go router instance of the widget tree',
      (WidgetTester tester) async {
        const Key key = Key('key');
        final List<RouteBase> routes = <RouteBase>[
          GoRoute(
            path: '/',
            builder: (_, __) => const SizedBox(key: key),
          ),
        ];

        final GoRouter router = await createRouter(routes, tester);
        final Element context = tester.element(find.byKey(key));
        final GoRouter? foundRouter = GoRouter.maybeOf(context);
        expect(foundRouter, router);
      },
    );

    testWidgets(
      'It should return null if there is no go router in the widget tree',
      (WidgetTester tester) async {
        const Key key = Key('key');
        await tester.pumpWidget(const SizedBox(key: key));

        final Element context = tester.element(find.byKey(key));
        expect(GoRouter.maybeOf(context), isNull);
      },
    );
  });

  group('state restoration', () {
    testWidgets('Restores state correctly', (WidgetTester tester) async {
      final GlobalKey<DummyRestorableStatefulWidgetState> statefulWidgetKeyA =
          GlobalKey<DummyRestorableStatefulWidgetState>();

      final List<RouteBase> routes = <RouteBase>[
        GoRoute(
          path: '/a',
          pageBuilder: createPageBuilder(
              restorationId: 'screenA', child: const Text('Screen A')),
          routes: <RouteBase>[
            GoRoute(
              path: 'detail',
              pageBuilder: createPageBuilder(
                  restorationId: 'screenADetail',
                  child: Column(children: <Widget>[
                    const Text('Screen A Detail'),
                    DummyRestorableStatefulWidget(
                        key: statefulWidgetKeyA, restorationId: 'counterA'),
                  ])),
            ),
          ],
        ),
      ];

      await createRouter(routes, tester,
          initialLocation: '/a/detail', restorationScopeId: 'test');
      await tester.pumpAndSettle();
      statefulWidgetKeyA.currentState?.increment();
      expect(statefulWidgetKeyA.currentState?.counter, equals(1));
      await tester.pumpAndSettle(); // Give state change time to persist

      await tester.restartAndRestore();

      await tester.pumpAndSettle();
      expect(find.text('Screen A Detail'), findsOneWidget);
      expect(statefulWidgetKeyA.currentState?.counter, equals(1));
    });

    testWidgets('Restores state of branches in StatefulShellRoute correctly',
        (WidgetTester tester) async {
      final GlobalKey<NavigatorState> rootNavigatorKey =
          GlobalKey<NavigatorState>();
      final GlobalKey<DummyRestorableStatefulWidgetState> statefulWidgetKeyA =
          GlobalKey<DummyRestorableStatefulWidgetState>();
      final GlobalKey<DummyRestorableStatefulWidgetState> statefulWidgetKeyB =
          GlobalKey<DummyRestorableStatefulWidgetState>();
      final GlobalKey<DummyRestorableStatefulWidgetState> statefulWidgetKeyC =
          GlobalKey<DummyRestorableStatefulWidgetState>();
      StatefulNavigationShell? routeState;

      final List<RouteBase> routes = <RouteBase>[
        StatefulShellRoute.indexedStack(
          restorationScopeId: 'shell',
          pageBuilder: (BuildContext context, GoRouterState state,
              StatefulNavigationShell navigationShell) {
            routeState = navigationShell;
            return MaterialPage<dynamic>(
                restorationId: 'shellWidget', child: navigationShell);
          },
          branches: <StatefulShellBranch>[
            StatefulShellBranch(
                restorationScopeId: 'branchA',
                routes: <GoRoute>[
                  GoRoute(
                    path: '/a',
                    pageBuilder: createPageBuilder(
                        restorationId: 'screenA',
                        child: const Text('Screen A')),
                    routes: <RouteBase>[
                      GoRoute(
                        path: 'detailA',
                        pageBuilder: createPageBuilder(
                            restorationId: 'screenADetail',
                            child: Column(children: <Widget>[
                              const Text('Screen A Detail'),
                              DummyRestorableStatefulWidget(
                                  key: statefulWidgetKeyA,
                                  restorationId: 'counterA'),
                            ])),
                      ),
                    ],
                  ),
                ]),
            StatefulShellBranch(
                restorationScopeId: 'branchB',
                routes: <GoRoute>[
                  GoRoute(
                    path: '/b',
                    pageBuilder: createPageBuilder(
                        restorationId: 'screenB',
                        child: const Text('Screen B')),
                    routes: <RouteBase>[
                      GoRoute(
                        path: 'detailB',
                        pageBuilder: createPageBuilder(
                            restorationId: 'screenBDetail',
                            child: Column(children: <Widget>[
                              const Text('Screen B Detail'),
                              DummyRestorableStatefulWidget(
                                  key: statefulWidgetKeyB,
                                  restorationId: 'counterB'),
                            ])),
                      ),
                    ],
                  ),
                ]),
            StatefulShellBranch(routes: <GoRoute>[
              GoRoute(
                path: '/c',
                pageBuilder: createPageBuilder(
                    restorationId: 'screenC', child: const Text('Screen C')),
                routes: <RouteBase>[
                  GoRoute(
                    path: 'detailC',
                    pageBuilder: createPageBuilder(
                        restorationId: 'screenCDetail',
                        child: Column(children: <Widget>[
                          const Text('Screen C Detail'),
                          DummyRestorableStatefulWidget(
                              key: statefulWidgetKeyC,
                              restorationId: 'counterC'),
                        ])),
                  ),
                ],
              ),
            ]),
          ],
        ),
      ];

      final GoRouter router = await createRouter(routes, tester,
          initialLocation: '/a/detailA',
          navigatorKey: rootNavigatorKey,
          restorationScopeId: 'test');
      await tester.pumpAndSettle();
      statefulWidgetKeyA.currentState?.increment();
      expect(statefulWidgetKeyA.currentState?.counter, equals(1));

      router.go('/b/detailB');
      await tester.pumpAndSettle();
      statefulWidgetKeyB.currentState?.increment();
      expect(statefulWidgetKeyB.currentState?.counter, equals(1));

      router.go('/c/detailC');
      await tester.pumpAndSettle();
      statefulWidgetKeyC.currentState?.increment();
      expect(statefulWidgetKeyC.currentState?.counter, equals(1));

      routeState!.goBranch(0);
      await tester.pumpAndSettle();
      expect(find.text('Screen A Detail'), findsOneWidget);

      await tester.restartAndRestore();

      await tester.pumpAndSettle();
      expect(find.text('Screen A Detail'), findsOneWidget);
      expect(statefulWidgetKeyA.currentState?.counter, equals(1));

      routeState!.goBranch(1);
      await tester.pumpAndSettle();
      expect(find.text('Screen B Detail'), findsOneWidget);
      expect(statefulWidgetKeyB.currentState?.counter, equals(1));

      routeState!.goBranch(2);
      await tester.pumpAndSettle();
      expect(find.text('Screen C Detail'), findsOneWidget);
      // State of branch C should not have been restored
      expect(statefulWidgetKeyC.currentState?.counter, equals(0));
    });

    testWidgets(
        'Restores state of imperative routes in StatefulShellRoute correctly',
        (WidgetTester tester) async {
      final GlobalKey<NavigatorState> rootNavigatorKey =
          GlobalKey<NavigatorState>();
      final GlobalKey<DummyRestorableStatefulWidgetState> statefulWidgetKeyA =
          GlobalKey<DummyRestorableStatefulWidgetState>();
      final GlobalKey<DummyRestorableStatefulWidgetState> statefulWidgetKeyB =
          GlobalKey<DummyRestorableStatefulWidgetState>();
      StatefulNavigationShell? routeStateRoot;
      StatefulNavigationShell? routeStateNested;

      final List<RouteBase> routes = <RouteBase>[
        StatefulShellRoute.indexedStack(
          restorationScopeId: 'shell',
          pageBuilder: (BuildContext context, GoRouterState state,
              StatefulNavigationShell navigationShell) {
            routeStateRoot = navigationShell;
            return MaterialPage<dynamic>(
                restorationId: 'shellWidget', child: navigationShell);
          },
          branches: <StatefulShellBranch>[
            StatefulShellBranch(
                restorationScopeId: 'branchA',
                routes: <GoRoute>[
                  GoRoute(
                    path: '/a',
                    pageBuilder: createPageBuilder(
                        restorationId: 'screenA',
                        child: const Text('Screen A')),
                    routes: <RouteBase>[
                      GoRoute(
                        path: 'detailA',
                        pageBuilder: createPageBuilder(
                            restorationId: 'screenADetail',
                            child: Column(children: <Widget>[
                              const Text('Screen A Detail'),
                              DummyRestorableStatefulWidget(
                                  key: statefulWidgetKeyA,
                                  restorationId: 'counterA'),
                            ])),
                      ),
                    ],
                  ),
                ]),
            StatefulShellBranch(
                restorationScopeId: 'branchB',
                routes: <RouteBase>[
                  StatefulShellRoute.indexedStack(
                      restorationScopeId: 'branchB-nested-shell',
                      pageBuilder: (BuildContext context, GoRouterState state,
                          StatefulNavigationShell navigationShell) {
                        routeStateNested = navigationShell;
                        return MaterialPage<dynamic>(
                            restorationId: 'shellWidget-nested',
                            child: navigationShell);
                      },
                      branches: <StatefulShellBranch>[
                        StatefulShellBranch(
                            restorationScopeId: 'branchB-nested',
                            routes: <GoRoute>[
                              GoRoute(
                                path: '/b',
                                pageBuilder: createPageBuilder(
                                    restorationId: 'screenB',
                                    child: const Text('Screen B')),
                                routes: <RouteBase>[
                                  GoRoute(
                                    path: 'detailB',
                                    pageBuilder: createPageBuilder(
                                        restorationId: 'screenBDetail',
                                        child: Column(children: <Widget>[
                                          const Text('Screen B Detail'),
                                          DummyRestorableStatefulWidget(
                                              key: statefulWidgetKeyB,
                                              restorationId: 'counterB'),
                                        ])),
                                  ),
                                ],
                              ),
                            ]),
                        StatefulShellBranch(
                            restorationScopeId: 'branchC-nested',
                            routes: <GoRoute>[
                              GoRoute(
                                path: '/c',
                                pageBuilder: createPageBuilder(
                                    restorationId: 'screenC',
                                    child: const Text('Screen C')),
                              ),
                            ]),
                      ])
                ]),
          ],
        ),
      ];

      final GoRouter router = await createRouter(routes, tester,
          initialLocation: '/a/detailA',
          navigatorKey: rootNavigatorKey,
          restorationScopeId: 'test');
      await tester.pumpAndSettle();
      statefulWidgetKeyA.currentState?.increment();
      expect(statefulWidgetKeyA.currentState?.counter, equals(1));

      routeStateRoot!.goBranch(1);
      await tester.pumpAndSettle();

      router.go('/b/detailB');
      await tester.pumpAndSettle();
      statefulWidgetKeyB.currentState?.increment();
      expect(statefulWidgetKeyB.currentState?.counter, equals(1));

      routeStateRoot!.goBranch(0);
      await tester.pumpAndSettle();
      expect(find.text('Screen A Detail'), findsOneWidget);
      expect(find.text('Screen B'), findsNothing);
      expect(find.text('Screen B Pushed Detail'), findsNothing);

      await tester.restartAndRestore();

      await tester.pumpAndSettle();
      expect(find.text('Screen A Detail'), findsOneWidget);
      expect(find.text('Screen B'), findsNothing);
      expect(find.text('Screen B Pushed Detail'), findsNothing);
      expect(statefulWidgetKeyA.currentState?.counter, equals(1));

      routeStateRoot!.goBranch(1);
      await tester.pumpAndSettle();
      expect(find.text('Screen A Detail'), findsNothing);
      expect(find.text('Screen B'), findsNothing);
      expect(find.text('Screen B Detail'), findsOneWidget);
      expect(statefulWidgetKeyB.currentState?.counter, equals(1));

      routeStateNested!.goBranch(1);
      await tester.pumpAndSettle();
      routeStateNested!.goBranch(0);
      await tester.pumpAndSettle();

      expect(find.text('Screen B Detail'), findsOneWidget);
      expect(statefulWidgetKeyB.currentState?.counter, equals(1));
    });
  });

  ///Regression tests for https://github.com/flutter/flutter/issues/132557
  group('overridePlatformDefaultLocation', () {
    test('No initial location provided', () {
      expect(
          () => GoRouter(
                overridePlatformDefaultLocation: true,
                routes: <RouteBase>[
                  GoRoute(
                    path: '/a',
                    builder: (BuildContext context, GoRouterState state) =>
                        const Placeholder(),
                  ),
                  GoRoute(
                    path: '/b',
                    builder: (BuildContext context, GoRouterState state) =>
                        const Placeholder(),
                  ),
                ],
              ),
          throwsA(const TypeMatcher<AssertionError>()));
    });
    testWidgets('Test override using routeInformationProvider',
        (WidgetTester tester) async {
      tester.binding.platformDispatcher.defaultRouteNameTestValue =
          '/some-route';
      final String platformRoute =
          WidgetsBinding.instance.platformDispatcher.defaultRouteName;
      const String expectedInitialRoute = '/kyc';
      expect(platformRoute != expectedInitialRoute, isTrue);

      final List<RouteBase> routes = <RouteBase>[
        GoRoute(
          path: '/abc',
          builder: (BuildContext context, GoRouterState state) =>
              const Placeholder(),
        ),
        GoRoute(
          path: '/bcd',
          builder: (BuildContext context, GoRouterState state) =>
              const Placeholder(),
        ),
      ];

      final GoRouter router = await createRouter(
        routes,
        tester,
        overridePlatformDefaultLocation: true,
        initialLocation: expectedInitialRoute,
      );
      expect(router.routeInformationProvider.value.uri.toString(),
          expectedInitialRoute);
    });
  });

  testWidgets(
      'test the pathParameters in redirect when the Router is recreated',
      (WidgetTester tester) async {
    final GoRouter router = GoRouter(
      initialLocation: '/foo',
      routes: <RouteBase>[
        GoRoute(
          path: '/foo',
          builder: dummy,
          routes: <GoRoute>[
            GoRoute(
              path: ':id',
              redirect: (_, GoRouterState state) {
                expect(state.pathParameters['id'], isNotNull);
                return null;
              },
              builder: dummy,
            ),
          ],
        ),
      ],
    );
    await tester.pumpWidget(
      MaterialApp.router(
        key: UniqueKey(),
        routerConfig: router,
      ),
    );
    router.push('/foo/123');
    await tester.pump(); // wait reportRouteInformation
    await tester.pumpWidget(
      MaterialApp.router(
        key: UniqueKey(),
        routerConfig: router,
      ),
    );
  });
}

class TestInheritedNotifier extends InheritedNotifier<ValueNotifier<String>> {
  const TestInheritedNotifier({
    super.key,
    required super.notifier,
    required super.child,
  });
}

class IsRouteUpdateCall extends Matcher {
  const IsRouteUpdateCall(this.uri, this.replace, this.state);

  final String uri;
  final bool replace;
  final Object? state;

  @override
  bool matches(dynamic item, Map<dynamic, dynamic> matchState) {
    if (item is! MethodCall) {
      return false;
    }
    if (item.method != 'routeInformationUpdated') {
      return false;
    }
    if (item.arguments is! Map) {
      return false;
    }
    final Map<String, dynamic> arguments =
        item.arguments as Map<String, dynamic>;
    // TODO(chunhtai): update this when minimum flutter version includes
    // https://github.com/flutter/flutter/pull/119968.
    // https://github.com/flutter/flutter/issues/124045.
    if (arguments['uri'] != uri && arguments['location'] != uri) {
      return false;
    }

    if (!const DeepCollectionEquality().equals(arguments['state'], state)) {
      return false;
    }
    return arguments['replace'] == replace;
  }

  @override
  Description describe(Description description) {
    return description
        .add("has method name: 'routeInformationUpdated'")
        .add(' with uri: ')
        .addDescriptionOf(uri)
        .add(' with state: ')
        .addDescriptionOf(state)
        .add(' with replace: ')
        .addDescriptionOf(replace);
  }
}
