// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:go_router/go_router.dart';

mixin $Route1 {}
mixin $Route2 {}
mixin $RelativeRoute {}
mixin $InnerRelativeRoute {}

const TypedRelativeGoRoute<RelativeRoute> relativeRoute =
    TypedRelativeGoRoute<RelativeRoute>(
      path: 'relative-route',
      routes: <TypedRoute<RouteData>>[
        TypedRelativeGoRoute<InnerRelativeRoute>(path: 'inner-relative-route'),
      ],
    );

@TypedGoRoute<Route1>(
  path: 'route-1',
  routes: <TypedRoute<RouteData>>[relativeRoute],
)
class Route1 extends GoRouteData with $Route1 {
  const Route1();
}

@TypedGoRoute<Route2>(
  path: 'route-2',
  routes: <TypedRoute<RouteData>>[relativeRoute],
)
class Route2 extends GoRouteData with $Route2 {
  const Route2();
}

class RelativeRoute extends RelativeGoRouteData with $RelativeRoute {
  const RelativeRoute();
}

class InnerRelativeRoute extends RelativeGoRouteData with $InnerRelativeRoute {
  const InnerRelativeRoute();
}
