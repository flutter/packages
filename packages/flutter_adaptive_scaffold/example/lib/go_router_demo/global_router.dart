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

  /// The router with the routes of pages that should be displayed.
  static final GoRouter router = GoRouter(
    navigatorKey: rootNavigatorKey,
    debugLogDiagnostics: true,
    errorPageBuilder: (BuildContext context, GoRouterState state) {
      return const MaterialPage<void>(child: NavigationErrorPage());
    },
    redirect: (BuildContext context, GoRouterState state) async {
      // Get the path the user is trying to navigate to.
      final String? path = state.fullPath;

      // If the route is part of the common routes, no auth check is required.
      if (Routes.commonRoutes
          .any((GoRoute e) => path?.contains(e.path) ?? false)) {
        return null;
      }

      final Iterable<GoRoute> unauthenticatedRoutes =
          RouteBase.routesRecursively(Routes.unauthenticatedRoutes.routes)
              .whereType<GoRoute>();
      final Iterable<GoRoute> authenticatedRoutes =
          RouteBase.routesRecursively(Routes.authenticatedRoutes.routes)
              .whereType<GoRoute>();

      // If the user is not authenticated
      if (!authenticated) {
        if (unauthenticatedRoutes.any((GoRoute route) => route.path == path)) {
          return null; // Allow navigation to unauthenticated routes
        } else {
          return LoginPage.path; // Redirect to login page
        }
      } else if (authenticated) {
        if (authenticatedRoutes.any((GoRoute route) => route.path == path)) {
          return null; // Allow navigation to authenticated routes
        } else {
          return HomePage.path; // Redirect to home page
        }
      }

      // In any other case the redirect can be safely ignored and handled as is.
      return null;
    },
    routes: <RouteBase>[
      Routes.unauthenticatedRoutes,
      Routes.authenticatedRoutes,
      ...Routes.commonRoutes,
    ],
  );
}
