// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:go_router/go_router.dart';

mixin $HomeRoute {}
mixin $ShellRoute {}
mixin $RelativeRoute {}
mixin $AbsoluteRoute {}

@TypedGoRoute<HomeRoute>(
  path: '/',
  routes: <TypedRoute<RouteData>>[relativeRoute],
)
class HomeRoute extends GoRouteData with $HomeRoute {
  const HomeRoute();
}

const TypedRelativeGoRoute<RelativeRoute> relativeRoute =
    TypedRelativeGoRoute<RelativeRoute>(
      path: 'relative-route',
      routes: <TypedRoute<RouteData>>[shellRoute],
    );

const TypedShellRoute<ShellRoute> shellRoute = TypedShellRoute<ShellRoute>(
  routes: <TypedRoute<RouteData>>[absoluteRoute],
);

const TypedGoRoute<AbsoluteRoute> absoluteRoute = TypedGoRoute<AbsoluteRoute>(
  path: 'absolute-route',
);

class RelativeRoute extends RelativeGoRouteData with $RelativeRoute {
  const RelativeRoute();
}

class ShellRoute extends ShellRouteData with $ShellRoute {
  const ShellRoute();
}

class AbsoluteRoute extends GoRouteData with $AbsoluteRoute {
  const AbsoluteRoute();
}
