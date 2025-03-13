// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'test_helpers.dart';

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
          createRouteConfiguration(
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
          createRouteConfiguration(
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
        'throws when StatefulShellRoute sub-route uses incorrect parentNavigatorKey',
        () {
      final GlobalKey<NavigatorState> root =
          GlobalKey<NavigatorState>(debugLabel: 'root');
      final GlobalKey<NavigatorState> keyA =
          GlobalKey<NavigatorState>(debugLabel: 'A');
      final GlobalKey<NavigatorState> keyB =
          GlobalKey<NavigatorState>(debugLabel: 'B');

      expect(
        () {
          createRouteConfiguration(
            navigatorKey: root,
            routes: <RouteBase>[
              StatefulShellRoute.indexedStack(branches: <StatefulShellBranch>[
                StatefulShellBranch(
                  navigatorKey: keyA,
                  routes: <RouteBase>[
                    GoRoute(
                        path: '/a',
                        builder: _mockScreenBuilder,
                        routes: <RouteBase>[
                          GoRoute(
                              path: 'details',
                              builder: _mockScreenBuilder,
                              parentNavigatorKey: keyB),
                        ]),
                  ],
                ),
              ], builder: mockStackedShellBuilder),
            ],
            redirectLimit: 10,
            topRedirect: (BuildContext context, GoRouterState state) {
              return null;
            },
          );
        },
        throwsA(isA<AssertionError>()),
      );
    });

    test(
        'does not throw when StatefulShellRoute sub-route uses correct parentNavigatorKeys',
        () {
      final GlobalKey<NavigatorState> root =
          GlobalKey<NavigatorState>(debugLabel: 'root');
      final GlobalKey<NavigatorState> keyA =
          GlobalKey<NavigatorState>(debugLabel: 'A');

      createRouteConfiguration(
        navigatorKey: root,
        routes: <RouteBase>[
          StatefulShellRoute.indexedStack(branches: <StatefulShellBranch>[
            StatefulShellBranch(
              navigatorKey: keyA,
              routes: <RouteBase>[
                GoRoute(
                    path: '/a',
                    builder: _mockScreenBuilder,
                    routes: <RouteBase>[
                      GoRoute(
                          path: 'details',
                          builder: _mockScreenBuilder,
                          parentNavigatorKey: keyA),
                    ]),
              ],
            ),
          ], builder: mockStackedShellBuilder),
        ],
        redirectLimit: 10,
        topRedirect: (BuildContext context, GoRouterState state) {
          return null;
        },
      );
    });

    test(
        'throws when a sub-route of StatefulShellRoute has a parentNavigatorKey',
        () {
      final GlobalKey<NavigatorState> root =
          GlobalKey<NavigatorState>(debugLabel: 'root');
      final GlobalKey<NavigatorState> someNavigatorKey =
          GlobalKey<NavigatorState>();
      expect(
        () {
          createRouteConfiguration(
            navigatorKey: root,
            routes: <RouteBase>[
              StatefulShellRoute.indexedStack(branches: <StatefulShellBranch>[
                StatefulShellBranch(
                  routes: <RouteBase>[
                    GoRoute(
                        path: '/a',
                        builder: _mockScreenBuilder,
                        routes: <RouteBase>[
                          GoRoute(
                              path: 'details',
                              builder: _mockScreenBuilder,
                              parentNavigatorKey: someNavigatorKey),
                        ]),
                  ],
                ),
                StatefulShellBranch(
                  routes: <RouteBase>[
                    GoRoute(
                        path: '/b',
                        builder: _mockScreenBuilder,
                        parentNavigatorKey: someNavigatorKey),
                  ],
                ),
              ], builder: mockStackedShellBuilder),
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

    test('throws when StatefulShellRoute has duplicate navigator keys', () {
      final GlobalKey<NavigatorState> root =
          GlobalKey<NavigatorState>(debugLabel: 'root');
      final GlobalKey<NavigatorState> keyA =
          GlobalKey<NavigatorState>(debugLabel: 'A');
      final List<GoRoute> shellRouteChildren = <GoRoute>[
        GoRoute(
            path: '/a', builder: _mockScreenBuilder, parentNavigatorKey: keyA),
        GoRoute(
            path: '/b', builder: _mockScreenBuilder, parentNavigatorKey: keyA),
      ];
      expect(
        () {
          createRouteConfiguration(
            navigatorKey: root,
            routes: <RouteBase>[
              StatefulShellRoute.indexedStack(branches: <StatefulShellBranch>[
                StatefulShellBranch(routes: shellRouteChildren)
              ], builder: mockStackedShellBuilder),
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
        'throws when a child of StatefulShellRoute has an incorrect '
        'parentNavigatorKey', () {
      final GlobalKey<NavigatorState> root =
          GlobalKey<NavigatorState>(debugLabel: 'root');
      final GlobalKey<NavigatorState> sectionANavigatorKey =
          GlobalKey<NavigatorState>();
      final GlobalKey<NavigatorState> sectionBNavigatorKey =
          GlobalKey<NavigatorState>();
      final GoRoute routeA = GoRoute(
          path: '/a',
          builder: _mockScreenBuilder,
          parentNavigatorKey: sectionBNavigatorKey);
      final GoRoute routeB = GoRoute(
          path: '/b',
          builder: _mockScreenBuilder,
          parentNavigatorKey: sectionANavigatorKey);
      expect(
        () {
          createRouteConfiguration(
            navigatorKey: root,
            routes: <RouteBase>[
              StatefulShellRoute.indexedStack(branches: <StatefulShellBranch>[
                StatefulShellBranch(
                    routes: <RouteBase>[routeA],
                    navigatorKey: sectionANavigatorKey),
                StatefulShellBranch(
                    routes: <RouteBase>[routeB],
                    navigatorKey: sectionBNavigatorKey),
              ], builder: mockStackedShellBuilder),
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
        'throws when a branch of a StatefulShellRoute has an incorrect '
        'initialLocation', () {
      final GlobalKey<NavigatorState> root =
          GlobalKey<NavigatorState>(debugLabel: 'root');
      final GlobalKey<NavigatorState> sectionANavigatorKey =
          GlobalKey<NavigatorState>();
      final GlobalKey<NavigatorState> sectionBNavigatorKey =
          GlobalKey<NavigatorState>();
      expect(
        () {
          createRouteConfiguration(
            navigatorKey: root,
            routes: <RouteBase>[
              StatefulShellRoute.indexedStack(branches: <StatefulShellBranch>[
                StatefulShellBranch(
                  initialLocation: '/x',
                  navigatorKey: sectionANavigatorKey,
                  routes: <RouteBase>[
                    GoRoute(
                      path: '/a',
                      builder: _mockScreenBuilder,
                    ),
                  ],
                ),
                StatefulShellBranch(
                  navigatorKey: sectionBNavigatorKey,
                  routes: <RouteBase>[
                    GoRoute(
                      path: '/b',
                      builder: _mockScreenBuilder,
                    ),
                  ],
                ),
              ], builder: mockStackedShellBuilder),
            ],
            redirectLimit: 10,
            topRedirect: (BuildContext context, GoRouterState state) {
              return null;
            },
          );
        },
        throwsA(isA<AssertionError>()),
      );
    });

    test(
        'throws when a branch of a StatefulShellRoute has a initialLocation '
        'that is not a descendant of the same branch', () {
      final GlobalKey<NavigatorState> root =
          GlobalKey<NavigatorState>(debugLabel: 'root');
      final GlobalKey<NavigatorState> sectionANavigatorKey =
          GlobalKey<NavigatorState>();
      final GlobalKey<NavigatorState> sectionBNavigatorKey =
          GlobalKey<NavigatorState>();
      expect(
        () {
          createRouteConfiguration(
            navigatorKey: root,
            routes: <RouteBase>[
              StatefulShellRoute.indexedStack(branches: <StatefulShellBranch>[
                StatefulShellBranch(
                  initialLocation: '/b',
                  navigatorKey: sectionANavigatorKey,
                  routes: <RouteBase>[
                    GoRoute(
                      path: '/a',
                      builder: _mockScreenBuilder,
                    ),
                  ],
                ),
                StatefulShellBranch(
                  initialLocation: '/b',
                  navigatorKey: sectionBNavigatorKey,
                  routes: <RouteBase>[
                    StatefulShellRoute.indexedStack(
                        branches: <StatefulShellBranch>[
                          StatefulShellBranch(
                            routes: <RouteBase>[
                              GoRoute(
                                path: '/b',
                                builder: _mockScreenBuilder,
                              ),
                            ],
                          ),
                        ],
                        builder: mockStackedShellBuilder),
                  ],
                ),
              ], builder: mockStackedShellBuilder),
            ],
            redirectLimit: 10,
            topRedirect: (BuildContext context, GoRouterState state) {
              return null;
            },
          );
        },
        throwsA(isA<AssertionError>()),
      );
    });

    test(
        'does not throw when a branch of a StatefulShellRoute has correctly '
        'configured initialLocations', () {
      final GlobalKey<NavigatorState> root =
          GlobalKey<NavigatorState>(debugLabel: 'root');

      createRouteConfiguration(
        navigatorKey: root,
        routes: <RouteBase>[
          StatefulShellRoute.indexedStack(branches: <StatefulShellBranch>[
            StatefulShellBranch(
              routes: <RouteBase>[
                GoRoute(
                    path: '/a',
                    builder: _mockScreenBuilder,
                    routes: <RouteBase>[
                      GoRoute(
                        path: 'detail',
                        builder: _mockScreenBuilder,
                      ),
                    ]),
              ],
            ),
            StatefulShellBranch(
              initialLocation: '/b/detail',
              routes: <RouteBase>[
                GoRoute(
                    path: '/b',
                    builder: _mockScreenBuilder,
                    routes: <RouteBase>[
                      GoRoute(
                        path: 'detail',
                        builder: _mockScreenBuilder,
                      ),
                    ]),
              ],
            ),
            StatefulShellBranch(
              initialLocation: '/c/detail',
              routes: <RouteBase>[
                StatefulShellRoute.indexedStack(branches: <StatefulShellBranch>[
                  StatefulShellBranch(
                    routes: <RouteBase>[
                      GoRoute(
                          path: '/c',
                          builder: _mockScreenBuilder,
                          routes: <RouteBase>[
                            GoRoute(
                              path: 'detail',
                              builder: _mockScreenBuilder,
                            ),
                          ]),
                    ],
                  ),
                  StatefulShellBranch(
                    initialLocation: '/d/detail',
                    routes: <RouteBase>[
                      GoRoute(
                          path: '/d',
                          builder: _mockScreenBuilder,
                          routes: <RouteBase>[
                            GoRoute(
                              path: 'detail',
                              builder: _mockScreenBuilder,
                            ),
                          ]),
                    ],
                  ),
                ], builder: mockStackedShellBuilder),
              ],
            ),
            StatefulShellBranch(routes: <RouteBase>[
              ShellRoute(
                builder: _mockShellBuilder,
                routes: <RouteBase>[
                  ShellRoute(
                    builder: _mockShellBuilder,
                    routes: <RouteBase>[
                      GoRoute(
                        path: '/e',
                        builder: _mockScreenBuilder,
                      ),
                    ],
                  )
                ],
              ),
            ]),
          ], builder: mockStackedShellBuilder),
        ],
        redirectLimit: 10,
        topRedirect: (BuildContext context, GoRouterState state) {
          return null;
        },
      );
    });

    test(
      'derives the correct initialLocation for a StatefulShellBranch',
      () {
        final StatefulShellBranch branchA;
        final StatefulShellBranch branchY;
        final StatefulShellBranch branchB;

        final RouteConfiguration config = createRouteConfiguration(
          navigatorKey: GlobalKey<NavigatorState>(debugLabel: 'root'),
          routes: <RouteBase>[
            StatefulShellRoute.indexedStack(
              builder: mockStackedShellBuilder,
              branches: <StatefulShellBranch>[
                branchA = StatefulShellBranch(routes: <RouteBase>[
                  GoRoute(
                    path: '/a',
                    builder: _mockScreenBuilder,
                    routes: <RouteBase>[
                      GoRoute(
                        path: 'x',
                        builder: _mockScreenBuilder,
                        routes: <RouteBase>[
                          StatefulShellRoute.indexedStack(
                              builder: mockStackedShellBuilder,
                              branches: <StatefulShellBranch>[
                                branchY =
                                    StatefulShellBranch(routes: <RouteBase>[
                                  ShellRoute(
                                      builder: _mockShellBuilder,
                                      routes: <RouteBase>[
                                        GoRoute(
                                          path: 'y1',
                                          builder: _mockScreenBuilder,
                                        ),
                                        GoRoute(
                                          path: 'y2',
                                          builder: _mockScreenBuilder,
                                        ),
                                      ])
                                ])
                              ]),
                        ],
                      ),
                    ],
                  ),
                ]),
                branchB = StatefulShellBranch(routes: <RouteBase>[
                  ShellRoute(
                    builder: _mockShellBuilder,
                    routes: <RouteBase>[
                      ShellRoute(
                        builder: _mockShellBuilder,
                        routes: <RouteBase>[
                          GoRoute(
                            path: '/b1',
                            builder: _mockScreenBuilder,
                          ),
                          GoRoute(
                            path: '/b2',
                            builder: _mockScreenBuilder,
                          ),
                        ],
                      )
                    ],
                  ),
                ]),
              ],
            ),
          ],
          redirectLimit: 10,
          topRedirect: (BuildContext context, GoRouterState state) {
            return null;
          },
        );

        String? initialLocation(StatefulShellBranch branch) {
          final GoRoute? route = branch.defaultRoute;
          return route != null ? config.locationForRoute(route) : null;
        }

        expect('/a', initialLocation(branchA));
        expect('/a/x/y1', initialLocation(branchY));
        expect('/b1', initialLocation(branchB));
      },
    );

    test(
        'throws when there is a GoRoute ancestor with a different parentNavigatorKey',
        () {
      final GlobalKey<NavigatorState> root =
          GlobalKey<NavigatorState>(debugLabel: 'root');
      final GlobalKey<NavigatorState> shell =
          GlobalKey<NavigatorState>(debugLabel: 'shell');
      expect(
        () {
          createRouteConfiguration(
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
        createRouteConfiguration(
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
        createRouteConfiguration(
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
          () => createRouteConfiguration(
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
          throwsA(isA<AssertionError>()),
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
        createRouteConfiguration(
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
          () => createRouteConfiguration(
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
          throwsA(isA<AssertionError>()),
        );
      },
    );
    test('does not throw when ShellRoute is the child of another ShellRoute',
        () {
      final GlobalKey<NavigatorState> root =
          GlobalKey<NavigatorState>(debugLabel: 'root');
      createRouteConfiguration(
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
        createRouteConfiguration(
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
          createRouteConfiguration(
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

    test(
      'All known route strings returned by debugKnownRoutes are correct',
      () {
        final GlobalKey<NavigatorState> root =
            GlobalKey<NavigatorState>(debugLabel: 'root');
        final GlobalKey<NavigatorState> shell =
            GlobalKey<NavigatorState>(debugLabel: 'shell');

        expect(
          createRouteConfiguration(
            navigatorKey: root,
            routes: <RouteBase>[
              GoRoute(
                path: '/a',
                parentNavigatorKey: root,
                builder: _mockScreenBuilder,
                routes: <RouteBase>[
                  ShellRoute(
                    navigatorKey: shell,
                    builder: _mockShellBuilder,
                    routes: <RouteBase>[
                      GoRoute(
                        path: 'b',
                        parentNavigatorKey: shell,
                        builder: _mockScreenBuilder,
                      ),
                      GoRoute(
                        path: 'c',
                        parentNavigatorKey: shell,
                        builder: _mockScreenBuilder,
                      ),
                    ],
                  ),
                ],
              ),
              GoRoute(
                path: '/d',
                parentNavigatorKey: root,
                builder: _mockScreenBuilder,
                routes: <RouteBase>[
                  GoRoute(
                    path: 'e',
                    parentNavigatorKey: root,
                    builder: _mockScreenBuilder,
                    routes: <RouteBase>[
                      GoRoute(
                        path: 'f',
                        parentNavigatorKey: root,
                        builder: _mockScreenBuilder,
                      ),
                    ],
                  ),
                ],
              ),
              GoRoute(
                path: '/g',
                builder: _mockScreenBuilder,
                routes: <RouteBase>[
                  StatefulShellRoute.indexedStack(
                    builder: _mockIndexedStackShellBuilder,
                    branches: <StatefulShellBranch>[
                      StatefulShellBranch(
                        routes: <RouteBase>[
                          GoRoute(
                            path: 'h',
                            builder: _mockScreenBuilder,
                          ),
                        ],
                      ),
                      StatefulShellBranch(
                        routes: <RouteBase>[
                          GoRoute(
                            path: 'i',
                            builder: _mockScreenBuilder,
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
          ).debugKnownRoutes(),
          'Full paths for routes:\n'
          '├─/a (Widget)\n'
          '│ └─ (ShellRoute)\n'
          '│   ├─/a/b (Widget)\n'
          '│   └─/a/c (Widget)\n'
          '├─/d (Widget)\n'
          '│ └─/d/e (Widget)\n'
          '│   └─/d/e/f (Widget)\n'
          '└─/g (Widget)\n'
          '  └─ (ShellRoute)\n'
          '    ├─/g/h (Widget)\n'
          '    └─/g/i (Widget)\n',
        );
      },
    );
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

Widget _mockIndexedStackShellBuilder(BuildContext context, GoRouterState state,
        StatefulNavigationShell shell) =>
    shell;
