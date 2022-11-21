// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/src/configuration.dart';

void main() {
  group('RouteConfiguration', () {
    test('throws when parentNavigatorKey is not an ancestor', () {
      final GlobalKey<NavigatorState> root =
          GlobalKey<NavigatorState>(debugLabel: 'root');
      final GlobalKey<NavigatorState> a =
          GlobalKey<NavigatorState>(debugLabel: 'a');
      final GlobalKey<NavigatorState> b =
          GlobalKey<NavigatorState>(debugLabel: 'b');

      expect(
        () {
          RouteConfiguration(
            navigatorKey: root,
            routes: <RouteBase>[
              GoRoute(
                path: '/a',
                builder: _mockScreenBuilder,
                routes: <RouteBase>[
                  ShellRoute(
                    navigatorKey: a,
                    builder: _mockShellBuilder,
                    routes: <RouteBase>[
                      GoRoute(
                        path: 'b',
                        builder: _mockScreenBuilder,
                      )
                    ],
                  ),
                  ShellRoute(
                    navigatorKey: b,
                    builder: _mockShellBuilder,
                    routes: <RouteBase>[
                      GoRoute(
                        path: 'c',
                        parentNavigatorKey: a,
                        builder: _mockScreenBuilder,
                      )
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
        },
        throwsAssertionError,
      );
    });

    test('throws when ShellRoute has no children', () {
      final GlobalKey<NavigatorState> root =
          GlobalKey<NavigatorState>(debugLabel: 'root');
      final List<RouteBase> shellRouteChildren = <RouteBase>[];
      expect(
        () {
          RouteConfiguration(
            navigatorKey: root,
            routes: <RouteBase>[
              ShellRoute(routes: shellRouteChildren),
            ],
            redirectLimit: 10,
            topRedirect: (BuildContext context, GoRouterState state) {
              return null;
            },
          );
        },
        throwsAssertionError,
      );
    });

    test(
        'throws when there is a GoRoute ancestor with a different parentNavigatorKey',
        () {
      final GlobalKey<NavigatorState> root =
          GlobalKey<NavigatorState>(debugLabel: 'root');
      final GlobalKey<NavigatorState> shell =
          GlobalKey<NavigatorState>(debugLabel: 'shell');
      expect(
        () {
          RouteConfiguration(
            navigatorKey: root,
            routes: <RouteBase>[
              ShellRoute(
                navigatorKey: shell,
                routes: <RouteBase>[
                  GoRoute(
                    path: '/',
                    builder: _mockScreenBuilder,
                    parentNavigatorKey: root,
                    routes: <RouteBase>[
                      GoRoute(
                        path: 'a',
                        builder: _mockScreenBuilder,
                        parentNavigatorKey: shell,
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
        },
        throwsAssertionError,
      );
    });

    test(
      'Does not throw with valid parentNavigatorKey configuration',
      () {
        final GlobalKey<NavigatorState> root =
            GlobalKey<NavigatorState>(debugLabel: 'root');
        final GlobalKey<NavigatorState> shell =
            GlobalKey<NavigatorState>(debugLabel: 'shell');
        final GlobalKey<NavigatorState> shell2 =
            GlobalKey<NavigatorState>(debugLabel: 'shell2');
        RouteConfiguration(
          navigatorKey: root,
          routes: <RouteBase>[
            ShellRoute(
              navigatorKey: shell,
              routes: <RouteBase>[
                GoRoute(
                  path: '/',
                  builder: _mockScreenBuilder,
                  routes: <RouteBase>[
                    GoRoute(
                      path: 'a',
                      builder: _mockScreenBuilder,
                      parentNavigatorKey: root,
                      routes: <RouteBase>[
                        ShellRoute(
                          navigatorKey: shell2,
                          routes: <RouteBase>[
                            GoRoute(
                              path: 'b',
                              builder: _mockScreenBuilder,
                              routes: <RouteBase>[
                                GoRoute(
                                  path: 'b',
                                  builder: _mockScreenBuilder,
                                  parentNavigatorKey: shell2,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
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
      },
    );

    test(
      'Does not throw with multiple nested GoRoutes using parentNavigatorKey in ShellRoute',
      () {
        final GlobalKey<NavigatorState> root =
            GlobalKey<NavigatorState>(debugLabel: 'root');
        final GlobalKey<NavigatorState> shell =
            GlobalKey<NavigatorState>(debugLabel: 'shell');
        RouteConfiguration(
          navigatorKey: root,
          routes: <RouteBase>[
            ShellRoute(
              navigatorKey: shell,
              routes: <RouteBase>[
                GoRoute(
                  path: '/',
                  builder: _mockScreenBuilder,
                  routes: <RouteBase>[
                    GoRoute(
                      path: 'a',
                      builder: _mockScreenBuilder,
                      parentNavigatorKey: root,
                      routes: <RouteBase>[
                        GoRoute(
                          path: 'b',
                          builder: _mockScreenBuilder,
                          parentNavigatorKey: root,
                          routes: <RouteBase>[
                            GoRoute(
                              path: 'c',
                              builder: _mockScreenBuilder,
                              parentNavigatorKey: root,
                            ),
                          ],
                        ),
                      ],
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
      },
    );

    test(
      'Throws when parentNavigatorKeys are overlapping',
      () {
        final GlobalKey<NavigatorState> root =
            GlobalKey<NavigatorState>(debugLabel: 'root');
        final GlobalKey<NavigatorState> shell =
            GlobalKey<NavigatorState>(debugLabel: 'shell');
        expect(
          () => RouteConfiguration(
            navigatorKey: root,
            routes: <RouteBase>[
              ShellRoute(
                navigatorKey: shell,
                routes: <RouteBase>[
                  GoRoute(
                    path: '/',
                    builder: _mockScreenBuilder,
                    routes: <RouteBase>[
                      GoRoute(
                        path: 'a',
                        builder: _mockScreenBuilder,
                        parentNavigatorKey: root,
                        routes: <RouteBase>[
                          GoRoute(
                            path: 'b',
                            builder: _mockScreenBuilder,
                            routes: <RouteBase>[
                              GoRoute(
                                path: 'b',
                                builder: _mockScreenBuilder,
                                parentNavigatorKey: shell,
                              ),
                            ],
                          ),
                        ],
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
          ),
          throwsAssertionError,
        );
      },
    );

    test(
      'Does not throw when parentNavigatorKeys are overlapping correctly',
      () {
        final GlobalKey<NavigatorState> root =
            GlobalKey<NavigatorState>(debugLabel: 'root');
        final GlobalKey<NavigatorState> shell =
            GlobalKey<NavigatorState>(debugLabel: 'shell');
        RouteConfiguration(
          navigatorKey: root,
          routes: <RouteBase>[
            ShellRoute(
              navigatorKey: shell,
              routes: <RouteBase>[
                GoRoute(
                  path: '/',
                  builder: _mockScreenBuilder,
                  routes: <RouteBase>[
                    GoRoute(
                      path: 'a',
                      builder: _mockScreenBuilder,
                      parentNavigatorKey: shell,
                      routes: <RouteBase>[
                        GoRoute(
                          path: 'b',
                          builder: _mockScreenBuilder,
                          routes: <RouteBase>[
                            GoRoute(
                              path: 'b',
                              builder: _mockScreenBuilder,
                              parentNavigatorKey: root,
                            ),
                          ],
                        ),
                      ],
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
      },
    );

    test(
      'throws when a GoRoute with a different parentNavigatorKey '
      'exists between a GoRoute with a parentNavigatorKey and '
      'its ShellRoute ancestor',
      () {
        final GlobalKey<NavigatorState> root =
            GlobalKey<NavigatorState>(debugLabel: 'root');
        final GlobalKey<NavigatorState> shell =
            GlobalKey<NavigatorState>(debugLabel: 'shell');
        final GlobalKey<NavigatorState> shell2 =
            GlobalKey<NavigatorState>(debugLabel: 'shell2');
        expect(
          () => RouteConfiguration(
            navigatorKey: root,
            routes: <RouteBase>[
              ShellRoute(
                navigatorKey: shell,
                routes: <RouteBase>[
                  GoRoute(
                    path: '/',
                    builder: _mockScreenBuilder,
                    routes: <RouteBase>[
                      GoRoute(
                        path: 'a',
                        parentNavigatorKey: root,
                        builder: _mockScreenBuilder,
                        routes: <RouteBase>[
                          ShellRoute(
                            navigatorKey: shell2,
                            routes: <RouteBase>[
                              GoRoute(
                                path: 'b',
                                builder: _mockScreenBuilder,
                                routes: <RouteBase>[
                                  GoRoute(
                                    path: 'c',
                                    builder: _mockScreenBuilder,
                                    parentNavigatorKey: shell,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
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
          ),
          throwsAssertionError,
        );
      },
    );
    test('does not throw when ShellRoute is the child of another ShellRoute',
        () {
      final GlobalKey<NavigatorState> root =
          GlobalKey<NavigatorState>(debugLabel: 'root');
      RouteConfiguration(
        routes: <RouteBase>[
          ShellRoute(
            builder: _mockShellBuilder,
            routes: <RouteBase>[
              ShellRoute(
                builder: _mockShellBuilder,
                routes: <GoRoute>[
                  GoRoute(
                    path: '/a',
                    builder: _mockScreenBuilder,
                  ),
                ],
              ),
              GoRoute(
                path: '/b',
                builder: _mockScreenBuilder,
              ),
            ],
          ),
          GoRoute(
            path: '/c',
            builder: _mockScreenBuilder,
          ),
        ],
        redirectLimit: 10,
        topRedirect: (BuildContext context, GoRouterState state) {
          return null;
        },
        navigatorKey: root,
      );
    });

    test(
      'Does not throw with valid parentNavigatorKey configuration',
      () {
        final GlobalKey<NavigatorState> root =
            GlobalKey<NavigatorState>(debugLabel: 'root');
        final GlobalKey<NavigatorState> shell =
            GlobalKey<NavigatorState>(debugLabel: 'shell');
        final GlobalKey<NavigatorState> shell2 =
            GlobalKey<NavigatorState>(debugLabel: 'shell2');
        RouteConfiguration(
          navigatorKey: root,
          routes: <RouteBase>[
            ShellRoute(
              navigatorKey: shell,
              routes: <RouteBase>[
                GoRoute(
                  path: '/',
                  builder: _mockScreenBuilder,
                  routes: <RouteBase>[
                    GoRoute(
                      path: 'a',
                      builder: _mockScreenBuilder,
                      parentNavigatorKey: root,
                      routes: <RouteBase>[
                        ShellRoute(
                          navigatorKey: shell2,
                          routes: <RouteBase>[
                            GoRoute(
                              path: 'b',
                              builder: _mockScreenBuilder,
                              routes: <RouteBase>[
                                GoRoute(
                                  path: 'b',
                                  builder: _mockScreenBuilder,
                                  parentNavigatorKey: shell2,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
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
      },
    );

    test('throws when ShellRoute contains a GoRoute with a parentNavigatorKey',
        () {
      final GlobalKey<NavigatorState> root =
          GlobalKey<NavigatorState>(debugLabel: 'root');
      expect(
        () {
          RouteConfiguration(
            navigatorKey: root,
            routes: <RouteBase>[
              ShellRoute(
                routes: <RouteBase>[
                  GoRoute(
                    path: '/a',
                    builder: _mockScreenBuilder,
                    parentNavigatorKey: root,
                  ),
                ],
              ),
            ],
            redirectLimit: 10,
            topRedirect: (BuildContext context, GoRouterState state) {
              return null;
            },
          );
        },
        throwsAssertionError,
      );
    });
  });
}

class _MockScreen extends StatelessWidget {
  const _MockScreen({super.key});

  @override
  Widget build(BuildContext context) => const Placeholder();
}

Widget _mockScreenBuilder(BuildContext context, GoRouterState state) =>
    _MockScreen(key: state.pageKey);

Widget _mockShellBuilder(
        BuildContext context, GoRouterState state, Widget child) =>
    child;
