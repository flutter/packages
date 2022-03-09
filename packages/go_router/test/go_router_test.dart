// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: cascade_invocations, diagnostic_describe_all_properties

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/diagnostics.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:go_router/src/go_route_match.dart';
import 'package:logging/logging.dart';

const bool enableLogs = true;
final Logger log = Logger('GoRouter tests');

void main() {
  if (enableLogs)
    Logger.root.onRecord.listen((LogRecord e) => debugPrint('$e'));

  group('path routes', () {
    test('match home route', () {
      final List<GoRoute> routes = <GoRoute>[
        GoRoute(
            path: '/',
            builder: (BuildContext context, GoRouterState state) =>
                const HomeScreen()),
      ];

      final GoRouter router = _router(routes);
      final List<GoRouteMatch> matches = router.routerDelegate.matches;
      expect(matches, hasLength(1));
      expect(matches.first.fullpath, '/');
      expect(router.screenFor(matches.first).runtimeType, HomeScreen);
    });

    test('match too many routes', () {
      final List<GoRoute> routes = <GoRoute>[
        GoRoute(path: '/', builder: _dummy),
        GoRoute(path: '/', builder: _dummy),
      ];

      final GoRouter router = _router(routes);
      router.go('/');
      final List<GoRouteMatch> matches = router.routerDelegate.matches;
      expect(matches, hasLength(1));
      expect(matches.first.fullpath, '/');
      expect(router.screenFor(matches.first).runtimeType, ErrorScreen);
    });

    test('empty path', () {
      expect(() {
        GoRoute(path: '');
      }, throwsException);
    });

    test('leading / on sub-route', () {
      expect(() {
        GoRoute(
          path: '/',
          builder: _dummy,
          routes: <GoRoute>[
            GoRoute(
              path: '/foo',
              builder: _dummy,
            ),
          ],
        );
      }, throwsException);
    });

    test('trailing / on sub-route', () {
      expect(() {
        GoRoute(
          path: '/',
          builder: _dummy,
          routes: <GoRoute>[
            GoRoute(
              path: 'foo/',
              builder: _dummy,
            ),
          ],
        );
      }, throwsException);
    });

    test('lack of leading / on top-level route', () {
      expect(() {
        final List<GoRoute> routes = <GoRoute>[
          GoRoute(path: 'foo', builder: _dummy),
        ];
        _router(routes);
      }, throwsException);
    });

    test('match no routes', () {
      final List<GoRoute> routes = <GoRoute>[
        GoRoute(path: '/', builder: _dummy),
      ];

      final GoRouter router = _router(routes);
      router.go('/foo');
      final List<GoRouteMatch> matches = router.routerDelegate.matches;
      expect(matches, hasLength(1));
      expect(router.screenFor(matches.first).runtimeType, ErrorScreen);
    });

    test('match 2nd top level route', () {
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

      final GoRouter router = _router(routes);
      router.go('/login');
      final List<GoRouteMatch> matches = router.routerDelegate.matches;
      expect(matches, hasLength(1));
      expect(matches.first.subloc, '/login');
      expect(router.screenFor(matches.first).runtimeType, LoginScreen);
    });

    test('match top level route when location has trailing /', () {
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

      final GoRouter router = _router(routes);
      router.go('/login/');
      final List<GoRouteMatch> matches = router.routerDelegate.matches;
      expect(matches, hasLength(1));
      expect(matches.first.subloc, '/login');
      expect(router.screenFor(matches.first).runtimeType, LoginScreen);
    });

    test('match top level route when location has trailing / (2)', () {
      final List<GoRoute> routes = <GoRoute>[
        GoRoute(path: '/profile', redirect: (_) => '/profile/foo'),
        GoRoute(path: '/profile/:kind', builder: _dummy),
      ];

      final GoRouter router = _router(routes);
      router.go('/profile/');
      final List<GoRouteMatch> matches = router.routerDelegate.matches;
      expect(matches, hasLength(1));
      expect(matches.first.subloc, '/profile/foo');
      expect(router.screenFor(matches.first).runtimeType, DummyScreen);
    });

    test('match top level route when location has trailing / (3)', () {
      final List<GoRoute> routes = <GoRoute>[
        GoRoute(path: '/profile', redirect: (_) => '/profile/foo'),
        GoRoute(path: '/profile/:kind', builder: _dummy),
      ];

      final GoRouter router = _router(routes);
      router.go('/profile/?bar=baz');
      final List<GoRouteMatch> matches = router.routerDelegate.matches;
      expect(matches, hasLength(1));
      expect(matches.first.subloc, '/profile/foo');
      expect(router.screenFor(matches.first).runtimeType, DummyScreen);
    });

    test('match sub-route', () {
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

      final GoRouter router = _router(routes);
      router.go('/login');
      final List<GoRouteMatch> matches = router.routerDelegate.matches;
      expect(matches.length, 2);
      expect(matches.first.subloc, '/');
      expect(router.screenFor(matches.first).runtimeType, HomeScreen);
      expect(matches[1].subloc, '/login');
      expect(router.screenFor(matches[1]).runtimeType, LoginScreen);
    });

    test('match sub-routes', () {
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

      final GoRouter router = _router(routes);
      {
        final List<GoRouteMatch> matches = router.routerDelegate.matches;
        expect(matches, hasLength(1));
        expect(matches.first.fullpath, '/');
        expect(router.screenFor(matches.first).runtimeType, HomeScreen);
      }

      router.go('/login');
      {
        final List<GoRouteMatch> matches = router.routerDelegate.matches;
        expect(matches.length, 2);
        expect(matches.first.subloc, '/');
        expect(router.screenFor(matches.first).runtimeType, HomeScreen);
        expect(matches[1].subloc, '/login');
        expect(router.screenFor(matches[1]).runtimeType, LoginScreen);
      }

      router.go('/family/f2');
      {
        final List<GoRouteMatch> matches = router.routerDelegate.matches;
        expect(matches.length, 2);
        expect(matches.first.subloc, '/');
        expect(router.screenFor(matches.first).runtimeType, HomeScreen);
        expect(matches[1].subloc, '/family/f2');
        expect(router.screenFor(matches[1]).runtimeType, FamilyScreen);
      }

      router.go('/family/f2/person/p1');
      {
        final List<GoRouteMatch> matches = router.routerDelegate.matches;
        expect(matches.length, 3);
        expect(matches.first.subloc, '/');
        expect(router.screenFor(matches.first).runtimeType, HomeScreen);
        expect(matches[1].subloc, '/family/f2');
        expect(router.screenFor(matches[1]).runtimeType, FamilyScreen);
        expect(matches[2].subloc, '/family/f2/person/p1');
        expect(router.screenFor(matches[2]).runtimeType, PersonScreen);
      }
    });

    test('match too many sub-routes', () {
      final List<GoRoute> routes = <GoRoute>[
        GoRoute(
          path: '/',
          builder: _dummy,
          routes: <GoRoute>[
            GoRoute(
              path: 'foo/bar',
              builder: _dummy,
            ),
            GoRoute(
              path: 'foo',
              builder: _dummy,
              routes: <GoRoute>[
                GoRoute(
                  path: 'bar',
                  builder: _dummy,
                ),
              ],
            ),
          ],
        ),
      ];

      final GoRouter router = _router(routes);
      router.go('/foo/bar');
      final List<GoRouteMatch> matches = router.routerDelegate.matches;
      expect(matches, hasLength(1));
      expect(router.screenFor(matches.first).runtimeType, ErrorScreen);
    });

    test('router state', () {
      final List<GoRoute> routes = <GoRoute>[
        GoRoute(
          name: 'home',
          path: '/',
          builder: (BuildContext context, GoRouterState state) {
            expect(
              state.location,
              anyOf(<String>[
                '/',
                '/login',
                '/family/f2',
                '/family/f2/person/p1'
              ]),
            );
            expect(state.subloc, '/');
            expect(state.name, 'home');
            expect(state.path, '/');
            expect(state.fullpath, '/');
            expect(state.params, <String, String>{});
            expect(state.error, null);
            expect(state.extra! as int, 1);
            return const HomeScreen();
          },
          routes: <GoRoute>[
            GoRoute(
              name: 'login',
              path: 'login',
              builder: (BuildContext context, GoRouterState state) {
                expect(state.location, '/login');
                expect(state.subloc, '/login');
                expect(state.name, 'login');
                expect(state.path, 'login');
                expect(state.fullpath, '/login');
                expect(state.params, <String, String>{});
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
                  state.location,
                  anyOf(<String>['/family/f2', '/family/f2/person/p1']),
                );
                expect(state.subloc, '/family/f2');
                expect(state.name, 'family');
                expect(state.path, 'family/:fid');
                expect(state.fullpath, '/family/:fid');
                expect(state.params, <String, String>{'fid': 'f2'});
                expect(state.error, null);
                expect(state.extra! as int, 3);
                return FamilyScreen(state.params['fid']!);
              },
              routes: <GoRoute>[
                GoRoute(
                  name: 'person',
                  path: 'person/:pid',
                  builder: (BuildContext context, GoRouterState state) {
                    expect(state.location, '/family/f2/person/p1');
                    expect(state.subloc, '/family/f2/person/p1');
                    expect(state.name, 'person');
                    expect(state.path, 'person/:pid');
                    expect(state.fullpath, '/family/:fid/person/:pid');
                    expect(
                      state.params,
                      <String, String>{'fid': 'f2', 'pid': 'p1'},
                    );
                    expect(state.error, null);
                    expect(state.extra! as int, 4);
                    return PersonScreen(
                        state.params['fid']!, state.params['pid']!);
                  },
                ),
              ],
            ),
          ],
        ),
      ];

      final GoRouter router = _router(routes);
      router.go('/', extra: 1);
      router.go('/login', extra: 2);
      router.go('/family/f2', extra: 3);
      router.go('/family/f2/person/p1', extra: 4);
    });

    test('match path case insensitively', () {
      final List<GoRoute> routes = <GoRoute>[
        GoRoute(
          path: '/',
          builder: (BuildContext context, GoRouterState state) =>
              const HomeScreen(),
        ),
        GoRoute(
          path: '/family/:fid',
          builder: (BuildContext context, GoRouterState state) =>
              FamilyScreen(state.params['fid']!),
        ),
      ];

      final GoRouter router = _router(routes);
      const String loc = '/FaMiLy/f2';
      router.go(loc);
      final List<GoRouteMatch> matches = router.routerDelegate.matches;

      // NOTE: match the lower case, since subloc is canonicalized to match the
      // path case whereas the location can be any case; so long as the path
      // produces a match regardless of the location case, we win!
      expect(router.location.toLowerCase(), loc.toLowerCase());

      expect(matches, hasLength(1));
      expect(router.screenFor(matches.first).runtimeType, FamilyScreen);
    });

    test('match too many routes, ignoring case', () {
      final List<GoRoute> routes = <GoRoute>[
        GoRoute(path: '/page1', builder: _dummy),
        GoRoute(path: '/PaGe1', builder: _dummy),
      ];

      final GoRouter router = _router(routes);
      router.go('/PAGE1');
      final List<GoRouteMatch> matches = router.routerDelegate.matches;
      expect(matches, hasLength(1));
      expect(router.screenFor(matches.first).runtimeType, ErrorScreen);
    });
  });

  group('named routes', () {
    test('match home route', () {
      final List<GoRoute> routes = <GoRoute>[
        GoRoute(
            name: 'home',
            path: '/',
            builder: (BuildContext context, GoRouterState state) =>
                const HomeScreen()),
      ];

      final GoRouter router = _router(routes);
      router.goNamed('home');
    });

    test('match too many routes', () {
      final List<GoRoute> routes = <GoRoute>[
        GoRoute(name: 'home', path: '/', builder: _dummy),
        GoRoute(name: 'home', path: '/', builder: _dummy),
      ];

      expect(() {
        _router(routes);
      }, throwsException);
    });

    test('empty name', () {
      expect(() {
        GoRoute(name: '', path: '/');
      }, throwsException);
    });

    test('match no routes', () {
      expect(() {
        final List<GoRoute> routes = <GoRoute>[
          GoRoute(name: 'home', path: '/', builder: _dummy),
        ];
        final GoRouter router = _router(routes);
        router.goNamed('work');
      }, throwsException);
    });

    test('match 2nd top level route', () {
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

      final GoRouter router = _router(routes);
      router.goNamed('login');
    });

    test('match sub-route', () {
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

      final GoRouter router = _router(routes);
      router.goNamed('login');
    });

    test('match sub-route case insensitive', () {
      final List<GoRoute> routes = <GoRoute>[
        GoRoute(
          name: 'home',
          path: '/',
          builder: (BuildContext context, GoRouterState state) =>
              const HomeScreen(),
          routes: <GoRoute>[
            GoRoute(
              name: 'page1',
              path: 'page1',
              builder: (BuildContext context, GoRouterState state) =>
                  const Page1Screen(),
            ),
            GoRoute(
              name: 'page2',
              path: 'Page2',
              builder: (BuildContext context, GoRouterState state) =>
                  const Page2Screen(),
            ),
          ],
        ),
      ];

      final GoRouter router = _router(routes);
      router.goNamed('Page1');
      router.goNamed('page2');
    });

    test('match w/ params', () {
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
                    expect(state.params,
                        <String, String>{'fid': 'f2', 'pid': 'p1'});
                    return const PersonScreen('dummy', 'dummy');
                  },
                ),
              ],
            ),
          ],
        ),
      ];

      final GoRouter router = _router(routes);
      router.goNamed('person',
          params: <String, String>{'fid': 'f2', 'pid': 'p1'});
    });

    test('too few params', () {
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
      expect(() {
        final GoRouter router = _router(routes);
        router.goNamed('person', params: <String, String>{'fid': 'f2'});
      }, throwsException);
    });

    test('match case insensitive w/ params', () {
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
                    expect(state.params,
                        <String, String>{'fid': 'f2', 'pid': 'p1'});
                    return const PersonScreen('dummy', 'dummy');
                  },
                ),
              ],
            ),
          ],
        ),
      ];

      final GoRouter router = _router(routes);
      router.goNamed('person',
          params: <String, String>{'fid': 'f2', 'pid': 'p1'});
    });

    test('too few params', () {
      final List<GoRoute> routes = <GoRoute>[
        GoRoute(
          name: 'family',
          path: '/family/:fid',
          builder: (BuildContext context, GoRouterState state) =>
              const FamilyScreen('dummy'),
        ),
      ];
      expect(() {
        final GoRouter router = _router(routes);
        router.goNamed('family');
      }, throwsException);
    });

    test('too many params', () {
      final List<GoRoute> routes = <GoRoute>[
        GoRoute(
          name: 'family',
          path: '/family/:fid',
          builder: (BuildContext context, GoRouterState state) =>
              const FamilyScreen('dummy'),
        ),
      ];
      expect(() {
        final GoRouter router = _router(routes);
        router.goNamed('family',
            params: <String, String>{'fid': 'f2', 'pid': 'p1'});
      }, throwsException);
    });

    test('sparsely named routes', () {
      final List<GoRoute> routes = <GoRoute>[
        GoRoute(
          path: '/',
          redirect: (_) => '/family/f2',
        ),
        GoRoute(
          path: '/family/:fid',
          builder: (BuildContext context, GoRouterState state) => FamilyScreen(
            state.params['fid']!,
          ),
          routes: <GoRoute>[
            GoRoute(
              name: 'person',
              path: 'person:pid',
              builder: (BuildContext context, GoRouterState state) =>
                  PersonScreen(
                state.params['fid']!,
                state.params['pid']!,
              ),
            ),
          ],
        ),
      ];

      final GoRouter router = _router(routes);
      router.goNamed('person',
          params: <String, String>{'fid': 'f2', 'pid': 'p1'});

      final List<GoRouteMatch> matches = router.routerDelegate.matches;
      expect(router.screenFor(matches.last).runtimeType, PersonScreen);
    });

    test('preserve path param spaces and slashes', () {
      const String param1 = 'param w/ spaces and slashes';
      final List<GoRoute> routes = <GoRoute>[
        GoRoute(
          name: 'page1',
          path: '/page1/:param1',
          builder: (BuildContext c, GoRouterState s) {
            expect(s.params['param1'], param1);
            return const DummyScreen();
          },
        ),
      ];

      final GoRouter router = _router(routes);
      final String loc = router
          .namedLocation('page1', params: <String, String>{'param1': param1});
      log.info('loc= $loc');
      router.go(loc);

      final List<GoRouteMatch> matches = router.routerDelegate.matches;
      log.info('param1= ${matches.first.decodedParams['param1']}');
      expect(router.screenFor(matches.first).runtimeType, DummyScreen);
      expect(matches.first.decodedParams['param1'], param1);
    });

    test('preserve query param spaces and slashes', () {
      const String param1 = 'param w/ spaces and slashes';
      final List<GoRoute> routes = <GoRoute>[
        GoRoute(
          name: 'page1',
          path: '/page1',
          builder: (BuildContext c, GoRouterState s) {
            expect(s.queryParams['param1'], param1);
            return const DummyScreen();
          },
        ),
      ];

      final GoRouter router = _router(routes);
      final String loc = router.namedLocation('page1',
          queryParams: <String, String>{'param1': param1});
      log.info('loc= $loc');
      router.go(loc);

      final List<GoRouteMatch> matches = router.routerDelegate.matches;
      log.info('param1= ${matches.first.queryParams['param1']}');
      expect(router.screenFor(matches.first).runtimeType, DummyScreen);
      expect(matches.first.queryParams['param1'], param1);
    });
  });

  group('redirects', () {
    test('top-level redirect', () {
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

      final GoRouter router = GoRouter(
        routes: routes,
        errorBuilder: _dummy,
        redirect: (GoRouterState state) =>
            state.subloc == '/login' ? null : '/login',
      );
      expect(router.location, '/login');
    });

    test('top-level redirect w/ named routes', () {
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

      final GoRouter router = GoRouter(
        debugLogDiagnostics: true,
        routes: routes,
        errorBuilder: _dummy,
        redirect: (GoRouterState state) =>
            state.subloc == '/login' ? null : state.namedLocation('login'),
      );
      expect(router.location, '/login');
    });

    test('route-level redirect', () {
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
              redirect: (GoRouterState state) => '/login',
            ),
            GoRoute(
              path: 'login',
              builder: (BuildContext context, GoRouterState state) =>
                  const LoginScreen(),
            ),
          ],
        ),
      ];

      final GoRouter router = GoRouter(
        routes: routes,
        errorBuilder: _dummy,
      );
      router.go('/dummy');
      expect(router.location, '/login');
    });

    test('route-level redirect w/ named routes', () {
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
              redirect: (GoRouterState state) => state.namedLocation('login'),
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

      final GoRouter router = GoRouter(
        routes: routes,
        errorBuilder: _dummy,
      );
      router.go('/dummy');
      expect(router.location, '/login');
    });

    test('multiple mixed redirect', () {
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
              redirect: (GoRouterState state) => '/',
            ),
          ],
        ),
      ];

      final GoRouter router = GoRouter(
        routes: routes,
        errorBuilder: _dummy,
        redirect: (GoRouterState state) =>
            state.subloc == '/dummy1' ? '/dummy2' : null,
      );
      router.go('/dummy1');
      expect(router.location, '/');
    });

    test('top-level redirect loop', () {
      final GoRouter router = GoRouter(
        routes: <GoRoute>[],
        errorBuilder: (BuildContext context, GoRouterState state) =>
            ErrorScreen(state.error!),
        redirect: (GoRouterState state) => state.subloc == '/'
            ? '/login'
            : state.subloc == '/login'
                ? '/'
                : null,
      );

      final List<GoRouteMatch> matches = router.routerDelegate.matches;
      expect(matches, hasLength(1));
      expect(router.screenFor(matches.first).runtimeType, ErrorScreen);
      expect((router.screenFor(matches.first) as ErrorScreen).ex, isNotNull);
      log.info((router.screenFor(matches.first) as ErrorScreen).ex);
    });

    test('route-level redirect loop', () {
      final GoRouter router = GoRouter(
        routes: <GoRoute>[
          GoRoute(
            path: '/',
            redirect: (GoRouterState state) => '/login',
          ),
          GoRoute(
            path: '/login',
            redirect: (GoRouterState state) => '/',
          ),
        ],
        errorBuilder: (BuildContext context, GoRouterState state) =>
            ErrorScreen(state.error!),
      );

      final List<GoRouteMatch> matches = router.routerDelegate.matches;
      expect(matches, hasLength(1));
      expect(router.screenFor(matches.first).runtimeType, ErrorScreen);
      expect((router.screenFor(matches.first) as ErrorScreen).ex, isNotNull);
      log.info((router.screenFor(matches.first) as ErrorScreen).ex);
    });

    test('mixed redirect loop', () {
      final GoRouter router = GoRouter(
        routes: <GoRoute>[
          GoRoute(
            path: '/login',
            redirect: (GoRouterState state) => '/',
          ),
        ],
        errorBuilder: (BuildContext context, GoRouterState state) =>
            ErrorScreen(state.error!),
        redirect: (GoRouterState state) =>
            state.subloc == '/' ? '/login' : null,
      );

      final List<GoRouteMatch> matches = router.routerDelegate.matches;
      expect(matches, hasLength(1));
      expect(router.screenFor(matches.first).runtimeType, ErrorScreen);
      expect((router.screenFor(matches.first) as ErrorScreen).ex, isNotNull);
      log.info((router.screenFor(matches.first) as ErrorScreen).ex);
    });

    test('top-level redirect loop w/ query params', () {
      final GoRouter router = GoRouter(
        routes: <GoRoute>[],
        errorBuilder: (BuildContext context, GoRouterState state) =>
            ErrorScreen(state.error!),
        redirect: (GoRouterState state) => state.subloc == '/'
            ? '/login?from=${state.location}'
            : state.subloc == '/login'
                ? '/'
                : null,
      );

      final List<GoRouteMatch> matches = router.routerDelegate.matches;
      expect(matches, hasLength(1));
      expect(router.screenFor(matches.first).runtimeType, ErrorScreen);
      expect((router.screenFor(matches.first) as ErrorScreen).ex, isNotNull);
      log.info((router.screenFor(matches.first) as ErrorScreen).ex);
    });

    test('expect null path/fullpath on top-level redirect', () {
      final List<GoRoute> routes = <GoRoute>[
        GoRoute(
          path: '/',
          builder: (BuildContext context, GoRouterState state) =>
              const HomeScreen(),
        ),
        GoRoute(
          path: '/dummy',
          redirect: (GoRouterState state) => '/',
        ),
      ];

      final GoRouter router = GoRouter(
        routes: routes,
        errorBuilder: _dummy,
        initialLocation: '/dummy',
      );
      expect(router.location, '/');
    });

    test('top-level redirect state', () {
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

      final GoRouter router = GoRouter(
        routes: routes,
        errorBuilder: _dummy,
        initialLocation: '/login?from=/',
        debugLogDiagnostics: true,
        redirect: (GoRouterState state) {
          expect(Uri.parse(state.location).queryParameters, isNotEmpty);
          expect(Uri.parse(state.subloc).queryParameters, isEmpty);
          expect(state.path, isNull);
          expect(state.fullpath, isNull);
          expect(state.params.length, 0);
          expect(state.queryParams.length, 1);
          expect(state.queryParams['from'], '/');
          return null;
        },
      );

      final List<GoRouteMatch> matches = router.routerDelegate.matches;
      expect(matches, hasLength(1));
      expect(router.screenFor(matches.first).runtimeType, LoginScreen);
    });

    test('route-level redirect state', () {
      const String loc = '/book/0';
      final List<GoRoute> routes = <GoRoute>[
        GoRoute(
          path: '/book/:bookId',
          redirect: (GoRouterState state) {
            expect(state.location, loc);
            expect(state.subloc, loc);
            expect(state.path, '/book/:bookId');
            expect(state.fullpath, '/book/:bookId');
            expect(state.params, <String, String>{'bookId': '0'});
            expect(state.queryParams.length, 0);
            return null;
          },
          builder: (BuildContext c, GoRouterState s) => const HomeScreen(),
        ),
      ];

      final GoRouter router = GoRouter(
        routes: routes,
        errorBuilder: _dummy,
        initialLocation: loc,
        debugLogDiagnostics: true,
      );

      final List<GoRouteMatch> matches = router.routerDelegate.matches;
      expect(matches, hasLength(1));
      expect(router.screenFor(matches.first).runtimeType, HomeScreen);
    });

    test('sub-sub-route-level redirect params', () {
      final List<GoRoute> routes = <GoRoute>[
        GoRoute(
          path: '/',
          builder: (BuildContext c, GoRouterState s) => const HomeScreen(),
          routes: <GoRoute>[
            GoRoute(
              path: 'family/:fid',
              builder: (BuildContext c, GoRouterState s) =>
                  FamilyScreen(s.params['fid']!),
              routes: <GoRoute>[
                GoRoute(
                  path: 'person/:pid',
                  redirect: (GoRouterState s) {
                    expect(s.params['fid'], 'f2');
                    expect(s.params['pid'], 'p1');
                    return null;
                  },
                  builder: (BuildContext c, GoRouterState s) => PersonScreen(
                    s.params['fid']!,
                    s.params['pid']!,
                  ),
                ),
              ],
            ),
          ],
        ),
      ];

      final GoRouter router = GoRouter(
        routes: routes,
        errorBuilder: _dummy,
        initialLocation: '/family/f2/person/p1',
        debugLogDiagnostics: true,
      );

      final List<GoRouteMatch> matches = router.routerDelegate.matches;
      expect(matches.length, 3);
      expect(router.screenFor(matches.first).runtimeType, HomeScreen);
      expect(router.screenFor(matches[1]).runtimeType, FamilyScreen);
      final PersonScreen page = router.screenFor(matches[2]) as PersonScreen;
      expect(page.fid, 'f2');
      expect(page.pid, 'p1');
    });

    test('redirect limit', () {
      final GoRouter router = GoRouter(
        routes: <GoRoute>[],
        errorBuilder: (BuildContext context, GoRouterState state) =>
            ErrorScreen(state.error!),
        debugLogDiagnostics: true,
        redirect: (GoRouterState state) => '${state.location}+',
        redirectLimit: 10,
      );

      final List<GoRouteMatch> matches = router.routerDelegate.matches;
      expect(matches, hasLength(1));
      expect(router.screenFor(matches.first).runtimeType, ErrorScreen);
      expect((router.screenFor(matches.first) as ErrorScreen).ex, isNotNull);
      log.info((router.screenFor(matches.first) as ErrorScreen).ex);
    });
  });

  group('initial location', () {
    test('initial location', () {
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

      final GoRouter router = GoRouter(
        routes: routes,
        errorBuilder: _dummy,
        initialLocation: '/dummy',
      );
      expect(router.location, '/dummy');
    });

    test('initial location w/ redirection', () {
      final List<GoRoute> routes = <GoRoute>[
        GoRoute(
          path: '/',
          builder: (BuildContext context, GoRouterState state) =>
              const HomeScreen(),
        ),
        GoRoute(
          path: '/dummy',
          redirect: (GoRouterState state) => '/',
        ),
      ];

      final GoRouter router = GoRouter(
        routes: routes,
        errorBuilder: _dummy,
        initialLocation: '/dummy',
      );
      expect(router.location, '/');
    });
  });

  group('params', () {
    test('preserve path param case', () {
      final List<GoRoute> routes = <GoRoute>[
        GoRoute(
          path: '/',
          builder: (BuildContext context, GoRouterState state) =>
              const HomeScreen(),
        ),
        GoRoute(
          path: '/family/:fid',
          builder: (BuildContext context, GoRouterState state) =>
              FamilyScreen(state.params['fid']!),
        ),
      ];

      final GoRouter router = _router(routes);
      for (final String fid in <String>['f2', 'F2']) {
        final String loc = '/family/$fid';
        router.go(loc);
        final List<GoRouteMatch> matches = router.routerDelegate.matches;

        expect(router.location, loc);
        expect(matches, hasLength(1));
        expect(router.screenFor(matches.first).runtimeType, FamilyScreen);
        expect(matches.first.decodedParams['fid'], fid);
      }
    });

    test('preserve query param case', () {
      final List<GoRoute> routes = <GoRoute>[
        GoRoute(
          path: '/',
          builder: (BuildContext context, GoRouterState state) =>
              const HomeScreen(),
        ),
        GoRoute(
          path: '/family',
          builder: (BuildContext context, GoRouterState state) => FamilyScreen(
            state.queryParams['fid']!,
          ),
        ),
      ];

      final GoRouter router = _router(routes);
      for (final String fid in <String>['f2', 'F2']) {
        final String loc = '/family?fid=$fid';
        router.go(loc);
        final List<GoRouteMatch> matches = router.routerDelegate.matches;

        expect(router.location, loc);
        expect(matches, hasLength(1));
        expect(router.screenFor(matches.first).runtimeType, FamilyScreen);
        expect(matches.first.queryParams['fid'], fid);
      }
    });

    test('preserve path param spaces and slashes', () {
      const String param1 = 'param w/ spaces and slashes';
      final List<GoRoute> routes = <GoRoute>[
        GoRoute(
          path: '/page1/:param1',
          builder: (BuildContext c, GoRouterState s) {
            expect(s.params['param1'], param1);
            return const DummyScreen();
          },
        ),
      ];

      final GoRouter router = _router(routes);
      final String loc = '/page1/${Uri.encodeComponent(param1)}';
      router.go(loc);

      final List<GoRouteMatch> matches = router.routerDelegate.matches;
      log.info('param1= ${matches.first.decodedParams['param1']}');
      expect(router.screenFor(matches.first).runtimeType, DummyScreen);
      expect(matches.first.decodedParams['param1'], param1);
    });

    test('preserve query param spaces and slashes', () {
      const String param1 = 'param w/ spaces and slashes';
      final List<GoRoute> routes = <GoRoute>[
        GoRoute(
          path: '/page1',
          builder: (BuildContext c, GoRouterState s) {
            expect(s.queryParams['param1'], param1);
            return const DummyScreen();
          },
        ),
      ];

      final GoRouter router = _router(routes);
      router.go('/page1?param1=$param1');

      final List<GoRouteMatch> matches = router.routerDelegate.matches;
      expect(router.screenFor(matches.first).runtimeType, DummyScreen);
      expect(matches.first.queryParams['param1'], param1);

      final String loc = '/page1?param1=${Uri.encodeQueryComponent(param1)}';
      router.go(loc);

      final List<GoRouteMatch> matches2 = router.routerDelegate.matches;
      expect(router.screenFor(matches2[0]).runtimeType, DummyScreen);
      expect(matches2[0].queryParams['param1'], param1);
    });

    test('error: duplicate path param', () {
      try {
        GoRouter(
          routes: <GoRoute>[
            GoRoute(
              path: '/:id/:blah/:bam/:id/:blah',
              builder: _dummy,
            ),
          ],
          errorBuilder: (BuildContext context, GoRouterState state) =>
              ErrorScreen(state.error!),
          initialLocation: '/0/1/2/0/1',
        );
        expect(false, true);
      } on Exception catch (ex) {
        log.info(ex);
      }
    });

    test('duplicate query param', () {
      final GoRouter router = GoRouter(
        routes: <GoRoute>[
          GoRoute(
            path: '/',
            builder: (BuildContext context, GoRouterState state) {
              log.info('id= ${state.params['id']}');
              expect(state.params.length, 0);
              expect(state.queryParams.length, 1);
              expect(state.queryParams['id'], anyOf('0', '1'));
              return const HomeScreen();
            },
          ),
        ],
        errorBuilder: (BuildContext context, GoRouterState state) =>
            ErrorScreen(state.error!),
      );

      router.go('/?id=0&id=1');
      final List<GoRouteMatch> matches = router.routerDelegate.matches;
      expect(matches, hasLength(1));
      expect(matches.first.fullpath, '/');
      expect(router.screenFor(matches.first).runtimeType, HomeScreen);
    });

    test('duplicate path + query param', () {
      final GoRouter router = GoRouter(
        routes: <GoRoute>[
          GoRoute(
            path: '/:id',
            builder: (BuildContext context, GoRouterState state) {
              expect(state.params, <String, String>{'id': '0'});
              expect(state.queryParams, <String, String>{'id': '1'});
              return const HomeScreen();
            },
          ),
        ],
        errorBuilder: _dummy,
      );

      router.go('/0?id=1');
      final List<GoRouteMatch> matches = router.routerDelegate.matches;
      expect(matches, hasLength(1));
      expect(matches.first.fullpath, '/:id');
      expect(router.screenFor(matches.first).runtimeType, HomeScreen);
    });

    test('push + query param', () {
      final GoRouter router = GoRouter(
        routes: <GoRoute>[
          GoRoute(path: '/', builder: _dummy),
          GoRoute(
            path: '/family',
            builder: (BuildContext context, GoRouterState state) =>
                FamilyScreen(
              state.queryParams['fid']!,
            ),
          ),
          GoRoute(
            path: '/person',
            builder: (BuildContext context, GoRouterState state) =>
                PersonScreen(
              state.queryParams['fid']!,
              state.queryParams['pid']!,
            ),
          ),
        ],
        errorBuilder: _dummy,
      );

      router.go('/family?fid=f2');
      router.push('/person?fid=f2&pid=p1');
      final FamilyScreen page1 =
          router.screenFor(router.routerDelegate.matches.first) as FamilyScreen;
      expect(page1.fid, 'f2');

      final PersonScreen page2 =
          router.screenFor(router.routerDelegate.matches[1]) as PersonScreen;
      expect(page2.fid, 'f2');
      expect(page2.pid, 'p1');
    });

    test('push + extra param', () {
      final GoRouter router = GoRouter(
        routes: <GoRoute>[
          GoRoute(path: '/', builder: _dummy),
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
        errorBuilder: _dummy,
      );

      router.go('/family', extra: <String, String>{'fid': 'f2'});
      router.push('/person', extra: <String, String>{'fid': 'f2', 'pid': 'p1'});
      final FamilyScreen page1 =
          router.screenFor(router.routerDelegate.matches.first) as FamilyScreen;
      expect(page1.fid, 'f2');

      final PersonScreen page2 =
          router.screenFor(router.routerDelegate.matches[1]) as PersonScreen;
      expect(page2.fid, 'f2');
      expect(page2.pid, 'p1');
    });

    test('keep param in nested route', () {
      final List<GoRoute> routes = <GoRoute>[
        GoRoute(
          path: '/',
          builder: (BuildContext context, GoRouterState state) =>
              const HomeScreen(),
        ),
        GoRoute(
          path: '/family/:fid',
          builder: (BuildContext context, GoRouterState state) =>
              FamilyScreen(state.params['fid']!),
          routes: <GoRoute>[
            GoRoute(
              path: 'person/:pid',
              builder: (BuildContext context, GoRouterState state) {
                final String fid = state.params['fid']!;
                final String pid = state.params['pid']!;

                return PersonScreen(fid, pid);
              },
            ),
          ],
        ),
      ];

      final GoRouter router = _router(routes);
      const String fid = 'f1';
      const String pid = 'p2';
      const String loc = '/family/$fid/person/$pid';

      router.push(loc);
      final List<GoRouteMatch> matches = router.routerDelegate.matches;

      expect(router.location, loc);
      expect(matches, hasLength(2));
      expect(router.screenFor(matches.last).runtimeType, PersonScreen);
      expect(matches.last.decodedParams['fid'], fid);
      expect(matches.last.decodedParams['pid'], pid);
    });
  });

  group('refresh listenable', () {
    late StreamController<int> streamController;

    setUpAll(() async {
      streamController = StreamController<int>.broadcast();
      await streamController.addStream(Stream<int>.value(0));
    });

    tearDownAll(() {
      streamController.close();
    });

    group('stream', () {
      test('no stream emits', () async {
        // Act
        final MockGoRouterRefreshStream notifyListener =
            MockGoRouterRefreshStream(
          streamController.stream,
        );

        // Assert
        expect(notifyListener.notifyCount, equals(1));

        // Cleanup
        notifyListener.dispose();
      });

      test('three stream emits', () async {
        // Arrange
        final List<int> toEmit = <int>[1, 2, 3];

        // Act
        final MockGoRouterRefreshStream notifyListener =
            MockGoRouterRefreshStream(
          streamController.stream,
        );

        await streamController.addStream(Stream<int>.fromIterable(toEmit));

        // Assert
        expect(notifyListener.notifyCount, equals(toEmit.length + 1));

        // Cleanup
        notifyListener.dispose();
      });
    });
  });
}

class MockGoRouterRefreshStream extends GoRouterRefreshStream {
  MockGoRouterRefreshStream(
    Stream<dynamic> stream,
  )   : notifyCount = 0,
        super(stream);

  late int notifyCount;

  @override
  void notifyListeners() {
    notifyCount++;
    super.notifyListeners();
  }
}

GoRouter _router(List<GoRoute> routes) => GoRouter(
      routes: routes,
      errorBuilder: (BuildContext context, GoRouterState state) =>
          ErrorScreen(state.error!),
      debugLogDiagnostics: true,
    );

class ErrorScreen extends DummyScreen {
  const ErrorScreen(this.ex, {Key? key}) : super(key: key);
  final Exception ex;
}

class HomeScreen extends DummyScreen {
  const HomeScreen({Key? key}) : super(key: key);
}

class Page1Screen extends DummyScreen {
  const Page1Screen({Key? key}) : super(key: key);
}

class Page2Screen extends DummyScreen {
  const Page2Screen({Key? key}) : super(key: key);
}

class LoginScreen extends DummyScreen {
  const LoginScreen({Key? key}) : super(key: key);
}

class FamilyScreen extends DummyScreen {
  const FamilyScreen(this.fid, {Key? key}) : super(key: key);
  final String fid;
}

class FamiliesScreen extends DummyScreen {
  const FamiliesScreen({required this.selectedFid, Key? key}) : super(key: key);
  final String selectedFid;
}

class PersonScreen extends DummyScreen {
  const PersonScreen(this.fid, this.pid, {Key? key}) : super(key: key);
  final String fid;
  final String pid;
}

class DummyScreen extends StatelessWidget {
  const DummyScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => throw UnimplementedError();
}

Widget _dummy(BuildContext context, GoRouterState state) => const DummyScreen();

extension on GoRouter {
  Page<dynamic> _pageFor(GoRouteMatch match) {
    final List<GoRouteMatch> matches = routerDelegate.matches;
    final int i = matches.indexOf(match);
    final List<Page<dynamic>> pages =
        routerDelegate.getPages(DummyBuildContext(), matches).toList();
    return pages[i];
  }

  Widget screenFor(GoRouteMatch match) =>
      (_pageFor(match) as NoTransitionPage<void>).child;
}

class DummyBuildContext implements BuildContext {
  @override
  bool get debugDoingBuild => throw UnimplementedError();

  @override
  InheritedWidget dependOnInheritedElement(InheritedElement ancestor,
      {Object aspect = 1}) {
    throw UnimplementedError();
  }

  @override
  T? dependOnInheritedWidgetOfExactType<T extends InheritedWidget>(
      {Object? aspect}) {
    throw UnimplementedError();
  }

  @override
  DiagnosticsNode describeElement(String name,
      {DiagnosticsTreeStyle style = DiagnosticsTreeStyle.errorProperty}) {
    throw UnimplementedError();
  }

  @override
  List<DiagnosticsNode> describeMissingAncestor(
      {required Type expectedAncestorType}) {
    throw UnimplementedError();
  }

  @override
  DiagnosticsNode describeOwnershipChain(String name) {
    throw UnimplementedError();
  }

  @override
  DiagnosticsNode describeWidget(String name,
      {DiagnosticsTreeStyle style = DiagnosticsTreeStyle.errorProperty}) {
    throw UnimplementedError();
  }

  @override
  T? findAncestorRenderObjectOfType<T extends RenderObject>() {
    throw UnimplementedError();
  }

  @override
  T? findAncestorStateOfType<T extends State<StatefulWidget>>() {
    throw UnimplementedError();
  }

  @override
  T? findAncestorWidgetOfExactType<T extends Widget>() {
    throw UnimplementedError();
  }

  @override
  RenderObject? findRenderObject() {
    throw UnimplementedError();
  }

  @override
  T? findRootAncestorStateOfType<T extends State<StatefulWidget>>() {
    throw UnimplementedError();
  }

  @override
  InheritedElement?
      getElementForInheritedWidgetOfExactType<T extends InheritedWidget>() {
    throw UnimplementedError();
  }

  @override
  BuildOwner? get owner => throw UnimplementedError();

  @override
  Size? get size => throw UnimplementedError();

  @override
  void visitAncestorElements(bool Function(Element element) visitor) {}

  @override
  void visitChildElements(ElementVisitor visitor) {}

  @override
  Widget get widget => throw UnimplementedError();
}
