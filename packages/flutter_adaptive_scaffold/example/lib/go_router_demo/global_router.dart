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
  /// The router with the routes of pages that should be displayed.
  static final GoRouter router = GoRouter(
    navigatorKey: rootNavigatorKey,
    errorPageBuilder: (BuildContext context, GoRouterState state) {
      return const MaterialPage<void>(child: NavigationErrorPage());
    },
    redirect: (BuildContext context, GoRouterState state) async {
      // Check if the route we want navigate to is a shared route, so we don't
      // need to check auth status.
      if (Routes.commonRoutes.any(
        (GoRoute e) => state.fullPath?.contains(e.path) ?? false,
      )) {
        return null;
      }

      // TODO: Implement authentication status check
      final bool authenticated = false;

      //TODO: check unauthenticated routes
      // if (!authenticated && routes.unauthenticatedRoutes.any(state.fullPath)
      // return null;
      // else if(!authenticated)
      // return LoginPage.path;
      // else if(authenticated && state.fullPath == LoginPage.path)
      // return HomePage.path;

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
