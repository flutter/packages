import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'pages/pages.dart';
import 'routes.dart';

/// The root navigator key for the main router of the app.
final GlobalKey<NavigatorState> rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');

/// The [GlobalRouter] maintains the main route configuration for the app.
///
/// Routes that are `fullScreenDialogs` should also set `_rootNavigatorKey` as
/// the `parentNavigatorKey` to ensure that the dialog is displayed correctly.
class GlobalRouter {
  /// The authentication status of the user.
  static bool authenticated = false;

  static final Iterable<GoRoute> _unauthenticatedGoRoutes =
      RouteBase.routesRecursively(Routes.unauthenticatedRoutes.routes)
          .whereType<GoRoute>();

  static final Iterable<GoRoute> _authenticatedGoRoutes =
      RouteBase.routesRecursively(Routes.authenticatedRoutes.routes)
          .whereType<GoRoute>();

  /// The router with the routes of pages that should be displayed.
  static final GoRouter router = GoRouter(
    navigatorKey: rootNavigatorKey,
    debugLogDiagnostics: true,
    errorPageBuilder: (BuildContext context, GoRouterState state) {
      return const MaterialPage<void>(child: NavigationErrorPage());
    },
    routes: <RouteBase>[
      Routes.unauthenticatedRoutes,
      Routes.authenticatedRoutes,
      ...Routes.commonRoutes,
    ],
  );
}
