// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:go_router/go_router.dart';

mixin _$HomeRoute {}
mixin _$ShellRoute {}
mixin _$RelativeRoute {}
mixin _$AbsoluteRoute {}

@TypedGoRoute<HomeRoute>(
  path: '/',
  routes: <TypedRoute<RouteData>>[relativeRoute],
)
class HomeRoute extends GoRouteData with _$HomeRoute {
  const HomeRoute();
}

const TypedRelativeGoRoute<RelativeRoute> relativeRoute =
    TypedRelativeGoRoute<RelativeRoute>(
  path: 'relative-route',
  routes: <TypedRoute<RouteData>>[shellRoute],
);

const TypedShellRoute<ShellRoute> shellRoute =
    TypedShellRoute<ShellRoute>(routes: <TypedRoute<RouteData>>[absoluteRoute]);

const TypedGoRoute<AbsoluteRoute> absoluteRoute =
    TypedGoRoute<AbsoluteRoute>(path: 'absolute-route');

class RelativeRoute extends RelativeGoRouteData with _$RelativeRoute {
  const RelativeRoute();
}

class ShellRoute extends ShellRouteData with _$ShellRoute {
  const ShellRoute();
}

class AbsoluteRoute extends GoRouteData with _$AbsoluteRoute {
  const AbsoluteRoute();
}
