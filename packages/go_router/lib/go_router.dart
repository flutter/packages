// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// A declarative router for Flutter based on Navigation 2 supporting
/// deep linking, data-driven routes and more.
library go_router;

export 'src/configuration.dart'
    show
        GoRoute,
        GoRouterState,
        RouteBase,
        ShellRoute,
        ShellNavigationContainerBuilder,
        StatefulNavigationShell,
        StatefulNavigationShellState,
        StatefulShellBranch,
        StatefulShellRoute;
export 'src/misc/extensions.dart';
export 'src/misc/inherited_router.dart';
export 'src/pages/custom_transition_page.dart';
export 'src/route_data.dart'
    show
        RouteData,
        GoRouteData,
        ShellRouteData,
        TypedRoute,
        TypedGoRoute,
        TypedShellRoute;
export 'src/router.dart';
export 'src/typedefs.dart'
    show
        GoRouterPageBuilder,
        GoRouterRedirect,
        GoRouterWidgetBuilder,
        ShellRouteBuilder,
        ShellRoutePageBuilder,
        StatefulShellRouteBuilder,
        StatefulShellRoutePageBuilder;
