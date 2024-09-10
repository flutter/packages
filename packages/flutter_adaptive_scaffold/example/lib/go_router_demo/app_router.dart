// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'pages/pages.dart';
import 'scaffold_shell.dart';

/// The root navigator key for the main router of the app.
final GlobalKey<NavigatorState> rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');

final GlobalKey<NavigatorState> _homeNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'home');
final GlobalKey<NavigatorState> _counterNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'counter');
final GlobalKey<NavigatorState> _moreNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'more');

/// The [AppRouter] maintains the main route configuration for the app.
///
/// Routes that are `fullScreenDialogs` should also set `_rootNavigatorKey` as
/// the `parentNavigatorKey` to ensure that the dialog is displayed correctly.
class AppRouter {
  /// The authentication status of the user.
  static ValueNotifier<bool> authenticatedNotifier = ValueNotifier<bool>(false);

  /// The router with the routes of pages that should be displayed.
  static final GoRouter router = GoRouter(
    navigatorKey: rootNavigatorKey,
    debugLogDiagnostics: true,
    errorPageBuilder: (BuildContext context, GoRouterState state) {
      return const MaterialPage<void>(child: NavigationErrorPage());
    },
    redirect: (BuildContext context, GoRouterState state) {
      if (state.uri.path == '/') {
        return HomePage.path;
      }
      return null;
    },
    refreshListenable: authenticatedNotifier,
    routes: <RouteBase>[
      _unauthenticatedRoutes,
      _authenticatedRoutes,
      ..._openRoutes,
    ],
  );

  static final GoRoute _unauthenticatedRoutes = GoRoute(
    name: LoginPage.name,
    path: LoginPage.path,
    pageBuilder: (BuildContext context, GoRouterState state) {
      return const MaterialPage<void>(child: LoginPage());
    },
    redirect: (BuildContext context, GoRouterState state) {
      if (authenticatedNotifier.value) {
        return HomePage.path;
      }
      return null;
    },
    routes: <RouteBase>[
      GoRoute(
        name: ForgotPasswordPage.name,
        path: ForgotPasswordPage.path,
        pageBuilder: (BuildContext context, GoRouterState state) {
          return const MaterialPage<void>(
            child: ForgotPasswordPage(),
          );
        },
      ),
    ],
  );

  static final StatefulShellRoute _authenticatedRoutes =
      StatefulShellRoute.indexedStack(
    parentNavigatorKey: rootNavigatorKey,
    builder: (
      BuildContext context,
      GoRouterState state,
      StatefulNavigationShell navigationShell,
    ) {
      return ScaffoldShell(navigationShell: navigationShell);
    },
    redirect: (BuildContext context, GoRouterState state) {
      if (!authenticatedNotifier.value) {
        return LoginPage.path;
      }
      return null;
    },
    branches: <StatefulShellBranch>[
      StatefulShellBranch(
        navigatorKey: _homeNavigatorKey,
        routes: <RouteBase>[
          GoRoute(
            name: HomePage.name,
            path: HomePage.path,
            pageBuilder: (BuildContext context, GoRouterState state) {
              return const NoTransitionPage<void>(
                child: HomePage(),
              );
            },
            routes: <RouteBase>[
              GoRoute(
                  name: DetailOverviewPage.name,
                  path: DetailOverviewPage.path,
                  pageBuilder: (BuildContext context, GoRouterState state) {
                    return const MaterialPage<void>(
                      child: DetailOverviewPage(),
                    );
                  },
                  routes: <RouteBase>[
                    GoRoute(
                      name: DetailPage.name,
                      path: DetailPage.path,
                      pageBuilder: (BuildContext context, GoRouterState state) {
                        return MaterialPage<void>(
                          child: DetailPage(
                              itemName: state.uri.queryParameters['itemName']!),
                        );
                      },
                    ),
                  ]),
              GoRoute(
                name: DetailModalPage.name,
                path: DetailModalPage.path,
                parentNavigatorKey: rootNavigatorKey,
                pageBuilder: (BuildContext context, GoRouterState state) {
                  return const MaterialPage<void>(
                    fullscreenDialog: true,
                    child: DetailModalPage(),
                  );
                },
              ),
            ],
          ),
        ],
      ),
      StatefulShellBranch(
        navigatorKey: _counterNavigatorKey,
        routes: <RouteBase>[
          GoRoute(
            name: CounterPage.name,
            path: CounterPage.path,
            pageBuilder: (BuildContext context, GoRouterState state) {
              return const NoTransitionPage<void>(child: CounterPage());
            },
          ),
        ],
      ),
      StatefulShellBranch(
        navigatorKey: _moreNavigatorKey,
        routes: <RouteBase>[
          GoRoute(
            name: MorePage.name,
            path: MorePage.path,
            pageBuilder: (BuildContext context, GoRouterState state) {
              return const NoTransitionPage<void>(
                key: ValueKey<String>(MorePage.name),
                child: MorePage(),
              );
            },
            routes: <RouteBase>[
              GoRoute(
                path: ProfilePage.path,
                name: ProfilePage.name,
                pageBuilder: (BuildContext context, GoRouterState state) {
                  return const MaterialPage<void>(child: ProfilePage());
                },
              ),
              GoRoute(
                name: SettingsPage.name,
                path: SettingsPage.path,
                pageBuilder: (BuildContext context, GoRouterState state) {
                  return const MaterialPage<void>(child: SettingsPage());
                },
              ),
            ],
          ),
        ],
      ),
    ],
  );

  static final List<GoRoute> _openRoutes = <GoRoute>[
    GoRoute(
      name: LanguagePage.name,
      path: LanguagePage.path,
      pageBuilder: (BuildContext context, GoRouterState state) {
        return const MaterialPage<void>(
          child: LanguagePage(),
        );
      },
    ),
  ];
}
