// ignore_for_file: cascade_invocations, diagnostic_describe_all_properties

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/diagnostics.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:go_router/src/go_route_match.dart';
import 'package:logging/logging.dart';

const enableLogs = true;
final log = Logger('GoRouter tests');

void main() {
  if (enableLogs) Logger.root.onRecord.listen((e) => debugPrint('$e'));

  group('path routes', () {
    test('match home route', () {
      final routes = [
        GoRoute(path: '/', builder: (builder, state) => const HomeScreen()),
      ];

      final router = _router(routes);
      final matches = router.routerDelegate.matches;
      expect(matches, hasLength(1));
      expect(matches.first.fullpath, '/');
      expect(router.screenFor(matches.first).runtimeType, HomeScreen);
    });

    test('match too many routes', () {
      final routes = [
        GoRoute(path: '/', builder: _dummy),
        GoRoute(path: '/', builder: _dummy),
      ];

      final router = _router(routes);
      router.go('/');
      final matches = router.routerDelegate.matches;
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
          routes: [
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
          routes: [
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
        final routes = [
          GoRoute(path: 'foo', builder: _dummy),
        ];
        _router(routes);
      }, throwsException);
    });

    test('match no routes', () {
      final routes = [
        GoRoute(path: '/', builder: _dummy),
      ];

      final router = _router(routes);
      router.go('/foo');
      final matches = router.routerDelegate.matches;
      expect(matches, hasLength(1));
      expect(router.screenFor(matches.first).runtimeType, ErrorScreen);
    });

    test('match 2nd top level route', () {
      final routes = [
        GoRoute(path: '/', builder: (builder, state) => const HomeScreen()),
        GoRoute(
            path: '/login', builder: (builder, state) => const LoginScreen()),
      ];

      final router = _router(routes);
      router.go('/login');
      final matches = router.routerDelegate.matches;
      expect(matches, hasLength(1));
      expect(matches.first.subloc, '/login');
      expect(router.screenFor(matches.first).runtimeType, LoginScreen);
    });

    test('match top level route when location has trailing /', () {
      final routes = [
        GoRoute(
          path: '/',
          builder: (builder, state) => const HomeScreen(),
        ),
        GoRoute(
          path: '/login',
          builder: (builder, state) => const LoginScreen(),
        ),
      ];

      final router = _router(routes);
      router.go('/login/');
      final matches = router.routerDelegate.matches;
      expect(matches, hasLength(1));
      expect(matches.first.subloc, '/login');
      expect(router.screenFor(matches.first).runtimeType, LoginScreen);
    });

    test('match top level route when location has trailing / (2)', () {
      final routes = [
        GoRoute(path: '/profile', redirect: (_) => '/profile/foo'),
        GoRoute(path: '/profile/:kind', builder: _dummy),
      ];

      final router = _router(routes);
      router.go('/profile/');
      final matches = router.routerDelegate.matches;
      expect(matches, hasLength(1));
      expect(matches.first.subloc, '/profile/foo');
      expect(router.screenFor(matches.first).runtimeType, DummyScreen);
    });

    test('match top level route when location has trailing / (3)', () {
      final routes = [
        GoRoute(path: '/profile', redirect: (_) => '/profile/foo'),
        GoRoute(path: '/profile/:kind', builder: _dummy),
      ];

      final router = _router(routes);
      router.go('/profile/?bar=baz');
      final matches = router.routerDelegate.matches;
      expect(matches, hasLength(1));
      expect(matches.first.subloc, '/profile/foo');
      expect(router.screenFor(matches.first).runtimeType, DummyScreen);
    });

    test('match sub-route', () {
      final routes = [
        GoRoute(
          path: '/',
          builder: (builder, state) => const HomeScreen(),
          routes: [
            GoRoute(
              path: 'login',
              builder: (builder, state) => const LoginScreen(),
            ),
          ],
        ),
      ];

      final router = _router(routes);
      router.go('/login');
      final matches = router.routerDelegate.matches;
      expect(matches.length, 2);
      expect(matches.first.subloc, '/');
      expect(router.screenFor(matches.first).runtimeType, HomeScreen);
      expect(matches[1].subloc, '/login');
      expect(router.screenFor(matches[1]).runtimeType, LoginScreen);
    });

    test('match sub-routes', () {
      final routes = [
        GoRoute(
          path: '/',
          builder: (context, state) => const HomeScreen(),
          routes: [
            GoRoute(
              path: 'family/:fid',
              builder: (context, state) => const FamilyScreen('dummy'),
              routes: [
                GoRoute(
                  path: 'person/:pid',
                  builder: (context, state) =>
                      const PersonScreen('dummy', 'dummy'),
                ),
              ],
            ),
            GoRoute(
              path: 'login',
              builder: (context, state) => const LoginScreen(),
            ),
          ],
        ),
      ];

      final router = _router(routes);
      {
        final matches = router.routerDelegate.matches;
        expect(matches, hasLength(1));
        expect(matches.first.fullpath, '/');
        expect(router.screenFor(matches.first).runtimeType, HomeScreen);
      }

      router.go('/login');
      {
        final matches = router.routerDelegate.matches;
        expect(matches.length, 2);
        expect(matches.first.subloc, '/');
        expect(router.screenFor(matches.first).runtimeType, HomeScreen);
        expect(matches[1].subloc, '/login');
        expect(router.screenFor(matches[1]).runtimeType, LoginScreen);
      }

      router.go('/family/f2');
      {
        final matches = router.routerDelegate.matches;
        expect(matches.length, 2);
        expect(matches.first.subloc, '/');
        expect(router.screenFor(matches.first).runtimeType, HomeScreen);
        expect(matches[1].subloc, '/family/f2');
        expect(router.screenFor(matches[1]).runtimeType, FamilyScreen);
      }

      router.go('/family/f2/person/p1');
      {
        final matches = router.routerDelegate.matches;
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
      final routes = [
        GoRoute(
          path: '/',
          builder: _dummy,
          routes: [
            GoRoute(
              path: 'foo/bar',
              builder: _dummy,
            ),
            GoRoute(
              path: 'foo',
              builder: _dummy,
              routes: [
                GoRoute(
                  path: 'bar',
                  builder: _dummy,
                ),
              ],
            ),
          ],
        ),
      ];

      final router = _router(routes);
      router.go('/foo/bar');
      final matches = router.routerDelegate.matches;
      expect(matches, hasLength(1));
      expect(router.screenFor(matches.first).runtimeType, ErrorScreen);
    });

    test('router state', () {
      final routes = [
        GoRoute(
          name: 'home',
          path: '/',
          builder: (builder, state) {
            expect(
              state.location,
              anyOf(['/', '/login', '/family/f2', '/family/f2/person/p1']),
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
          routes: [
            GoRoute(
              name: 'login',
              path: 'login',
              builder: (builder, state) {
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
              builder: (builder, state) {
                expect(
                  state.location,
                  anyOf(['/family/f2', '/family/f2/person/p1']),
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
              routes: [
                GoRoute(
                  name: 'person',
                  path: 'person/:pid',
                  builder: (context, state) {
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

      final router = _router(routes);
      router.go('/', extra: 1);
      router.go('/login', extra: 2);
      router.go('/family/f2', extra: 3);
      router.go('/family/f2/person/p1', extra: 4);
    });

    test('match path case insensitively', () {
      final routes = [
        GoRoute(
          path: '/',
          builder: (builder, state) => const HomeScreen(),
        ),
        GoRoute(
          path: '/family/:fid',
          builder: (builder, state) => FamilyScreen(state.params['fid']!),
        ),
      ];

      final router = _router(routes);
      const loc = '/FaMiLy/f2';
      router.go(loc);
      final matches = router.routerDelegate.matches;

      // NOTE: match the lower case, since subloc is canonicalized to match the
      // path case whereas the location can be any case; so long as the path
      // produces a match regardless of the location case, we win!
      expect(router.location.toLowerCase(), loc.toLowerCase());

      expect(matches, hasLength(1));
      expect(router.screenFor(matches.first).runtimeType, FamilyScreen);
    });

    test('match too many routes, ignoring case', () {
      final routes = [
        GoRoute(path: '/page1', builder: _dummy),
        GoRoute(path: '/PaGe1', builder: _dummy),
      ];

      final router = _router(routes);
      router.go('/PAGE1');
      final matches = router.routerDelegate.matches;
      expect(matches, hasLength(1));
      expect(router.screenFor(matches.first).runtimeType, ErrorScreen);
    });
  });

  group('named routes', () {
    test('match home route', () {
      final routes = [
        GoRoute(
            name: 'home',
            path: '/',
            builder: (builder, state) => const HomeScreen()),
      ];

      final router = _router(routes);
      router.goNamed('home');
    });

    test('match too many routes', () {
      final routes = [
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
        final routes = [
          GoRoute(name: 'home', path: '/', builder: _dummy),
        ];
        final router = _router(routes);
        router.goNamed('work');
      }, throwsException);
    });

    test('match 2nd top level route', () {
      final routes = [
        GoRoute(
          name: 'home',
          path: '/',
          builder: (builder, state) => const HomeScreen(),
        ),
        GoRoute(
          name: 'login',
          path: '/login',
          builder: (builder, state) => const LoginScreen(),
        ),
      ];

      final router = _router(routes);
      router.goNamed('login');
    });

    test('match sub-route', () {
      final routes = [
        GoRoute(
          name: 'home',
          path: '/',
          builder: (builder, state) => const HomeScreen(),
          routes: [
            GoRoute(
              name: 'login',
              path: 'login',
              builder: (builder, state) => const LoginScreen(),
            ),
          ],
        ),
      ];

      final router = _router(routes);
      router.goNamed('login');
    });

    test('match sub-route case insensitive', () {
      final routes = [
        GoRoute(
          name: 'home',
          path: '/',
          builder: (builder, state) => const HomeScreen(),
          routes: [
            GoRoute(
              name: 'page1',
              path: 'page1',
              builder: (builder, state) => const Page1Screen(),
            ),
            GoRoute(
              name: 'page2',
              path: 'Page2',
              builder: (builder, state) => const Page2Screen(),
            ),
          ],
        ),
      ];

      final router = _router(routes);
      router.goNamed('Page1');
      router.goNamed('page2');
    });

    test('match w/ params', () {
      final routes = [
        GoRoute(
          name: 'home',
          path: '/',
          builder: (context, state) => const HomeScreen(),
          routes: [
            GoRoute(
              name: 'family',
              path: 'family/:fid',
              builder: (context, state) => const FamilyScreen('dummy'),
              routes: [
                GoRoute(
                  name: 'person',
                  path: 'person/:pid',
                  builder: (context, state) {
                    expect(state.params, {'fid': 'f2', 'pid': 'p1'});
                    return const PersonScreen('dummy', 'dummy');
                  },
                ),
              ],
            ),
          ],
        ),
      ];

      final router = _router(routes);
      router.goNamed('person', params: {'fid': 'f2', 'pid': 'p1'});
    });

    test('too few params', () {
      final routes = [
        GoRoute(
          name: 'home',
          path: '/',
          builder: (context, state) => const HomeScreen(),
          routes: [
            GoRoute(
              name: 'family',
              path: 'family/:fid',
              builder: (context, state) => const FamilyScreen('dummy'),
              routes: [
                GoRoute(
                  name: 'person',
                  path: 'person/:pid',
                  builder: (context, state) =>
                      const PersonScreen('dummy', 'dummy'),
                ),
              ],
            ),
          ],
        ),
      ];
      expect(() {
        final router = _router(routes);
        router.goNamed('person', params: {'fid': 'f2'});
      }, throwsException);
    });

    test('match case insensitive w/ params', () {
      final routes = [
        GoRoute(
          name: 'home',
          path: '/',
          builder: (context, state) => const HomeScreen(),
          routes: [
            GoRoute(
              name: 'family',
              path: 'family/:fid',
              builder: (context, state) => const FamilyScreen('dummy'),
              routes: [
                GoRoute(
                  name: 'PeRsOn',
                  path: 'person/:pid',
                  builder: (context, state) {
                    expect(state.params, {'fid': 'f2', 'pid': 'p1'});
                    return const PersonScreen('dummy', 'dummy');
                  },
                ),
              ],
            ),
          ],
        ),
      ];

      final router = _router(routes);
      router.goNamed('person', params: {'fid': 'f2', 'pid': 'p1'});
    });

    test('too few params', () {
      final routes = [
        GoRoute(
          name: 'family',
          path: '/family/:fid',
          builder: (context, state) => const FamilyScreen('dummy'),
        ),
      ];
      expect(() {
        final router = _router(routes);
        router.goNamed('family');
      }, throwsException);
    });

    test('too many params', () {
      final routes = [
        GoRoute(
          name: 'family',
          path: '/family/:fid',
          builder: (context, state) => const FamilyScreen('dummy'),
        ),
      ];
      expect(() {
        final router = _router(routes);
        router.goNamed('family', params: {'fid': 'f2', 'pid': 'p1'});
      }, throwsException);
    });

    test('sparsely named routes', () {
      final routes = [
        GoRoute(
          path: '/',
          redirect: (_) => '/family/f2',
        ),
        GoRoute(
          path: '/family/:fid',
          builder: (context, state) => FamilyScreen(
            state.params['fid']!,
          ),
          routes: [
            GoRoute(
              name: 'person',
              path: 'person:pid',
              builder: (context, state) => PersonScreen(
                state.params['fid']!,
                state.params['pid']!,
              ),
            ),
          ],
        ),
      ];

      final router = _router(routes);
      router.goNamed('person', params: {'fid': 'f2', 'pid': 'p1'});

      final matches = router.routerDelegate.matches;
      expect(router.screenFor(matches.last).runtimeType, PersonScreen);
    });

    test('preserve path param spaces and slashes', () {
      const param1 = 'param w/ spaces and slashes';
      final routes = [
        GoRoute(
          name: 'page1',
          path: '/page1/:param1',
          builder: (c, s) {
            expect(s.params['param1'], param1);
            return const DummyScreen();
          },
        ),
      ];

      final router = _router(routes);
      final loc = router.namedLocation('page1', params: {'param1': param1});
      log.info('loc= $loc');
      router.go(loc);

      final matches = router.routerDelegate.matches;
      log.info('param1= ${matches.first.decodedParams['param1']}');
      expect(router.screenFor(matches.first).runtimeType, DummyScreen);
      expect(matches.first.decodedParams['param1'], param1);
    });

    test('preserve query param spaces and slashes', () {
      const param1 = 'param w/ spaces and slashes';
      final routes = [
        GoRoute(
          name: 'page1',
          path: '/page1',
          builder: (c, s) {
            expect(s.queryParams['param1'], param1);
            return const DummyScreen();
          },
        ),
      ];

      final router = _router(routes);
      final loc =
          router.namedLocation('page1', queryParams: {'param1': param1});
      log.info('loc= $loc');
      router.go(loc);

      final matches = router.routerDelegate.matches;
      log.info('param1= ${matches.first.queryParams['param1']}');
      expect(router.screenFor(matches.first).runtimeType, DummyScreen);
      expect(matches.first.queryParams['param1'], param1);
    });
  });

  group('redirects', () {
    test('top-level redirect', () {
      final routes = [
        GoRoute(
          path: '/',
          builder: (builder, state) => const HomeScreen(),
          routes: [
            GoRoute(
                path: 'dummy',
                builder: (builder, state) => const DummyScreen()),
            GoRoute(
                path: 'login',
                builder: (builder, state) => const LoginScreen()),
          ],
        ),
      ];

      final router = GoRouter(
        routes: routes,
        errorBuilder: _dummy,
        redirect: (state) => state.subloc == '/login' ? null : '/login',
      );
      expect(router.location, '/login');
    });

    test('top-level redirect w/ named routes', () {
      final routes = [
        GoRoute(
          name: 'home',
          path: '/',
          builder: (builder, state) => const HomeScreen(),
          routes: [
            GoRoute(
              name: 'dummy',
              path: 'dummy',
              builder: (builder, state) => const DummyScreen(),
            ),
            GoRoute(
              name: 'login',
              path: 'login',
              builder: (builder, state) => const LoginScreen(),
            ),
          ],
        ),
      ];

      final router = GoRouter(
        debugLogDiagnostics: true,
        routes: routes,
        errorBuilder: _dummy,
        redirect: (state) =>
            state.subloc == '/login' ? null : state.namedLocation('login'),
      );
      expect(router.location, '/login');
    });

    test('route-level redirect', () {
      final routes = [
        GoRoute(
          path: '/',
          builder: (builder, state) => const HomeScreen(),
          routes: [
            GoRoute(
              path: 'dummy',
              builder: (builder, state) => const DummyScreen(),
              redirect: (state) => '/login',
            ),
            GoRoute(
              path: 'login',
              builder: (builder, state) => const LoginScreen(),
            ),
          ],
        ),
      ];

      final router = GoRouter(
        routes: routes,
        errorBuilder: _dummy,
      );
      router.go('/dummy');
      expect(router.location, '/login');
    });

    test('route-level redirect w/ named routes', () {
      final routes = [
        GoRoute(
          name: 'home',
          path: '/',
          builder: (builder, state) => const HomeScreen(),
          routes: [
            GoRoute(
              name: 'dummy',
              path: 'dummy',
              builder: (builder, state) => const DummyScreen(),
              redirect: (state) => state.namedLocation('login'),
            ),
            GoRoute(
              name: 'login',
              path: 'login',
              builder: (builder, state) => const LoginScreen(),
            ),
          ],
        ),
      ];

      final router = GoRouter(
        routes: routes,
        errorBuilder: _dummy,
      );
      router.go('/dummy');
      expect(router.location, '/login');
    });

    test('multiple mixed redirect', () {
      final routes = [
        GoRoute(
          path: '/',
          builder: (builder, state) => const HomeScreen(),
          routes: [
            GoRoute(
              path: 'dummy1',
              builder: (builder, state) => const DummyScreen(),
            ),
            GoRoute(
              path: 'dummy2',
              builder: (builder, state) => const DummyScreen(),
              redirect: (state) => '/',
            ),
          ],
        ),
      ];

      final router = GoRouter(
        routes: routes,
        errorBuilder: _dummy,
        redirect: (state) => state.subloc == '/dummy1' ? '/dummy2' : null,
      );
      router.go('/dummy1');
      expect(router.location, '/');
    });

    test('top-level redirect loop', () {
      final router = GoRouter(
        routes: [],
        errorBuilder: (context, state) => ErrorScreen(state.error!),
        redirect: (state) => state.subloc == '/'
            ? '/login'
            : state.subloc == '/login'
                ? '/'
                : null,
      );

      final matches = router.routerDelegate.matches;
      expect(matches, hasLength(1));
      expect(router.screenFor(matches.first).runtimeType, ErrorScreen);
      expect((router.screenFor(matches.first) as ErrorScreen).ex, isNotNull);
      log.info((router.screenFor(matches.first) as ErrorScreen).ex);
    });

    test('route-level redirect loop', () {
      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            redirect: (state) => '/login',
          ),
          GoRoute(
            path: '/login',
            redirect: (state) => '/',
          ),
        ],
        errorBuilder: (context, state) => ErrorScreen(state.error!),
      );

      final matches = router.routerDelegate.matches;
      expect(matches, hasLength(1));
      expect(router.screenFor(matches.first).runtimeType, ErrorScreen);
      expect((router.screenFor(matches.first) as ErrorScreen).ex, isNotNull);
      log.info((router.screenFor(matches.first) as ErrorScreen).ex);
    });

    test('mixed redirect loop', () {
      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/login',
            redirect: (state) => '/',
          ),
        ],
        errorBuilder: (context, state) => ErrorScreen(state.error!),
        redirect: (state) => state.subloc == '/' ? '/login' : null,
      );

      final matches = router.routerDelegate.matches;
      expect(matches, hasLength(1));
      expect(router.screenFor(matches.first).runtimeType, ErrorScreen);
      expect((router.screenFor(matches.first) as ErrorScreen).ex, isNotNull);
      log.info((router.screenFor(matches.first) as ErrorScreen).ex);
    });

    test('top-level redirect loop w/ query params', () {
      final router = GoRouter(
        routes: [],
        errorBuilder: (context, state) => ErrorScreen(state.error!),
        redirect: (state) => state.subloc == '/'
            ? '/login?from=${state.location}'
            : state.subloc == '/login'
                ? '/'
                : null,
      );

      final matches = router.routerDelegate.matches;
      expect(matches, hasLength(1));
      expect(router.screenFor(matches.first).runtimeType, ErrorScreen);
      expect((router.screenFor(matches.first) as ErrorScreen).ex, isNotNull);
      log.info((router.screenFor(matches.first) as ErrorScreen).ex);
    });

    test('expect null path/fullpath on top-level redirect', () {
      final routes = [
        GoRoute(
          path: '/',
          builder: (builder, state) => const HomeScreen(),
        ),
        GoRoute(
          path: '/dummy',
          redirect: (state) => '/',
        ),
      ];

      final router = GoRouter(
        routes: routes,
        errorBuilder: _dummy,
        initialLocation: '/dummy',
      );
      expect(router.location, '/');
    });

    test('top-level redirect state', () {
      final routes = [
        GoRoute(
          path: '/',
          builder: (builder, state) => const HomeScreen(),
        ),
        GoRoute(
          path: '/login',
          builder: (builder, state) => const LoginScreen(),
        ),
      ];

      final router = GoRouter(
        routes: routes,
        errorBuilder: _dummy,
        initialLocation: '/login?from=/',
        debugLogDiagnostics: true,
        redirect: (state) {
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

      final matches = router.routerDelegate.matches;
      expect(matches, hasLength(1));
      expect(router.screenFor(matches.first).runtimeType, LoginScreen);
    });

    test('route-level redirect state', () {
      const loc = '/book/0';
      final routes = [
        GoRoute(
          path: '/book/:bookId',
          redirect: (state) {
            expect(state.location, loc);
            expect(state.subloc, loc);
            expect(state.path, '/book/:bookId');
            expect(state.fullpath, '/book/:bookId');
            expect(state.params, {'bookId': '0'});
            expect(state.queryParams.length, 0);
            return null;
          },
          builder: (c, s) => const HomeScreen(),
        ),
      ];

      final router = GoRouter(
        routes: routes,
        errorBuilder: _dummy,
        initialLocation: loc,
        debugLogDiagnostics: true,
      );

      final matches = router.routerDelegate.matches;
      expect(matches, hasLength(1));
      expect(router.screenFor(matches.first).runtimeType, HomeScreen);
    });

    test('sub-sub-route-level redirect params', () {
      final routes = [
        GoRoute(
          path: '/',
          builder: (c, s) => const HomeScreen(),
          routes: [
            GoRoute(
              path: 'family/:fid',
              builder: (c, s) => FamilyScreen(s.params['fid']!),
              routes: [
                GoRoute(
                  path: 'person/:pid',
                  redirect: (s) {
                    expect(s.params['fid'], 'f2');
                    expect(s.params['pid'], 'p1');
                    return null;
                  },
                  builder: (c, s) => PersonScreen(
                    s.params['fid']!,
                    s.params['pid']!,
                  ),
                ),
              ],
            ),
          ],
        ),
      ];

      final router = GoRouter(
        routes: routes,
        errorBuilder: _dummy,
        initialLocation: '/family/f2/person/p1',
        debugLogDiagnostics: true,
      );

      final matches = router.routerDelegate.matches;
      expect(matches.length, 3);
      expect(router.screenFor(matches.first).runtimeType, HomeScreen);
      expect(router.screenFor(matches[1]).runtimeType, FamilyScreen);
      final page = router.screenFor(matches[2]) as PersonScreen;
      expect(page.fid, 'f2');
      expect(page.pid, 'p1');
    });

    test('redirect limit', () {
      final router = GoRouter(
        routes: [],
        errorBuilder: (context, state) => ErrorScreen(state.error!),
        debugLogDiagnostics: true,
        redirect: (state) => '${state.location}+',
        redirectLimit: 10,
      );

      final matches = router.routerDelegate.matches;
      expect(matches, hasLength(1));
      expect(router.screenFor(matches.first).runtimeType, ErrorScreen);
      expect((router.screenFor(matches.first) as ErrorScreen).ex, isNotNull);
      log.info((router.screenFor(matches.first) as ErrorScreen).ex);
    });
  });

  group('initial location', () {
    test('initial location', () {
      final routes = [
        GoRoute(
          path: '/',
          builder: (builder, state) => const HomeScreen(),
          routes: [
            GoRoute(
              path: 'dummy',
              builder: (builder, state) => const DummyScreen(),
            ),
          ],
        ),
      ];

      final router = GoRouter(
        routes: routes,
        errorBuilder: _dummy,
        initialLocation: '/dummy',
      );
      expect(router.location, '/dummy');
    });

    test('initial location w/ redirection', () {
      final routes = [
        GoRoute(
          path: '/',
          builder: (builder, state) => const HomeScreen(),
        ),
        GoRoute(
          path: '/dummy',
          redirect: (state) => '/',
        ),
      ];

      final router = GoRouter(
        routes: routes,
        errorBuilder: _dummy,
        initialLocation: '/dummy',
      );
      expect(router.location, '/');
    });
  });

  group('params', () {
    test('preserve path param case', () {
      final routes = [
        GoRoute(
          path: '/',
          builder: (builder, state) => const HomeScreen(),
        ),
        GoRoute(
          path: '/family/:fid',
          builder: (builder, state) => FamilyScreen(state.params['fid']!),
        ),
      ];

      final router = _router(routes);
      for (final fid in ['f2', 'F2']) {
        final loc = '/family/$fid';
        router.go(loc);
        final matches = router.routerDelegate.matches;

        expect(router.location, loc);
        expect(matches, hasLength(1));
        expect(router.screenFor(matches.first).runtimeType, FamilyScreen);
        expect(matches.first.decodedParams['fid'], fid);
      }
    });

    test('preserve query param case', () {
      final routes = [
        GoRoute(
          path: '/',
          builder: (builder, state) => const HomeScreen(),
        ),
        GoRoute(
          path: '/family',
          builder: (builder, state) => FamilyScreen(
            state.queryParams['fid']!,
          ),
        ),
      ];

      final router = _router(routes);
      for (final fid in ['f2', 'F2']) {
        final loc = '/family?fid=$fid';
        router.go(loc);
        final matches = router.routerDelegate.matches;

        expect(router.location, loc);
        expect(matches, hasLength(1));
        expect(router.screenFor(matches.first).runtimeType, FamilyScreen);
        expect(matches.first.queryParams['fid'], fid);
      }
    });

    test('preserve path param spaces and slashes', () {
      const param1 = 'param w/ spaces and slashes';
      final routes = [
        GoRoute(
          path: '/page1/:param1',
          builder: (c, s) {
            expect(s.params['param1'], param1);
            return const DummyScreen();
          },
        ),
      ];

      final router = _router(routes);
      final loc = '/page1/${Uri.encodeComponent(param1)}';
      router.go(loc);

      final matches = router.routerDelegate.matches;
      log.info('param1= ${matches.first.decodedParams['param1']}');
      expect(router.screenFor(matches.first).runtimeType, DummyScreen);
      expect(matches.first.decodedParams['param1'], param1);
    });

    test('preserve query param spaces and slashes', () {
      const param1 = 'param w/ spaces and slashes';
      final routes = [
        GoRoute(
          path: '/page1',
          builder: (c, s) {
            expect(s.queryParams['param1'], param1);
            return const DummyScreen();
          },
        ),
      ];

      final router = _router(routes);
      router.go('/page1?param1=$param1');

      final matches = router.routerDelegate.matches;
      expect(router.screenFor(matches.first).runtimeType, DummyScreen);
      expect(matches.first.queryParams['param1'], param1);

      final loc = '/page1?param1=${Uri.encodeQueryComponent(param1)}';
      router.go(loc);

      final matches2 = router.routerDelegate.matches;
      expect(router.screenFor(matches2[0]).runtimeType, DummyScreen);
      expect(matches2[0].queryParams['param1'], param1);
    });

    test('error: duplicate path param', () {
      try {
        GoRouter(
          routes: [
            GoRoute(
              path: '/:id/:blah/:bam/:id/:blah',
              builder: _dummy,
            ),
          ],
          errorBuilder: (context, state) => ErrorScreen(state.error!),
          initialLocation: '/0/1/2/0/1',
        );
        expect(false, true);
      } on Exception catch (ex) {
        log.info(ex);
      }
    });

    test('duplicate query param', () {
      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) {
              log.info('id= ${state.params['id']}');
              expect(state.params.length, 0);
              expect(state.queryParams.length, 1);
              expect(state.queryParams['id'], anyOf('0', '1'));
              return const HomeScreen();
            },
          ),
        ],
        errorBuilder: (context, state) => ErrorScreen(state.error!),
      );

      router.go('/?id=0&id=1');
      final matches = router.routerDelegate.matches;
      expect(matches, hasLength(1));
      expect(matches.first.fullpath, '/');
      expect(router.screenFor(matches.first).runtimeType, HomeScreen);
    });

    test('duplicate path + query param', () {
      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/:id',
            builder: (context, state) {
              expect(state.params, {'id': '0'});
              expect(state.queryParams, {'id': '1'});
              return const HomeScreen();
            },
          ),
        ],
        errorBuilder: _dummy,
      );

      router.go('/0?id=1');
      final matches = router.routerDelegate.matches;
      expect(matches, hasLength(1));
      expect(matches.first.fullpath, '/:id');
      expect(router.screenFor(matches.first).runtimeType, HomeScreen);
    });

    test('push + query param', () {
      final router = GoRouter(
        routes: [
          GoRoute(path: '/', builder: _dummy),
          GoRoute(
            path: '/family',
            builder: (context, state) => FamilyScreen(
              state.queryParams['fid']!,
            ),
          ),
          GoRoute(
            path: '/person',
            builder: (context, state) => PersonScreen(
              state.queryParams['fid']!,
              state.queryParams['pid']!,
            ),
          ),
        ],
        errorBuilder: _dummy,
      );

      router.go('/family?fid=f2');
      router.push('/person?fid=f2&pid=p1');
      final page1 =
          router.screenFor(router.routerDelegate.matches.first) as FamilyScreen;
      expect(page1.fid, 'f2');

      final page2 =
          router.screenFor(router.routerDelegate.matches[1]) as PersonScreen;
      expect(page2.fid, 'f2');
      expect(page2.pid, 'p1');
    });

    test('push + extra param', () {
      final router = GoRouter(
        routes: [
          GoRoute(path: '/', builder: _dummy),
          GoRoute(
            path: '/family',
            builder: (context, state) => FamilyScreen(
              (state.extra! as Map<String, String>)['fid']!,
            ),
          ),
          GoRoute(
            path: '/person',
            builder: (context, state) => PersonScreen(
              (state.extra! as Map<String, String>)['fid']!,
              (state.extra! as Map<String, String>)['pid']!,
            ),
          ),
        ],
        errorBuilder: _dummy,
      );

      router.go('/family', extra: {'fid': 'f2'});
      router.push('/person', extra: {'fid': 'f2', 'pid': 'p1'});
      final page1 =
          router.screenFor(router.routerDelegate.matches.first) as FamilyScreen;
      expect(page1.fid, 'f2');

      final page2 =
          router.screenFor(router.routerDelegate.matches[1]) as PersonScreen;
      expect(page2.fid, 'f2');
      expect(page2.pid, 'p1');
    });
  });

  group('refresh listenable', () {
    late StreamController<int> streamController;

    setUpAll(() async {
      streamController = StreamController<int>.broadcast();
      await streamController.addStream(Stream.value(0));
    });

    tearDownAll(() {
      streamController.close();
    });

    group('stream', () {
      test('no stream emits', () async {
        // Act
        final notifyListener = MockGoRouterRefreshStream(
          streamController.stream,
        );

        // Assert
        expect(notifyListener.notifyCount, equals(1));

        // Cleanup
        notifyListener.dispose();
      });

      test('three stream emits', () async {
        // Arrange
        final toEmit = [1, 2, 3];

        // Act
        final notifyListener = MockGoRouterRefreshStream(
          streamController.stream,
        );

        await streamController.addStream(Stream.fromIterable(toEmit));

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
    Stream stream,
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
      errorBuilder: (context, state) => ErrorScreen(state.error!),
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
    final matches = routerDelegate.matches;
    final i = matches.indexOf(match);
    final pages =
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
