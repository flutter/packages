// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:go_router/go_router.dart';

mixin _$Route1 {}
mixin _$Route2 {}
mixin _$RelativeRoute {}
mixin _$InnerRelativeRoute {}

const TypedRelativeGoRoute<RelativeRoute> relativeRoute =
    TypedRelativeGoRoute<RelativeRoute>(
  path: 'relative-route',
  routes: <TypedRoute<RouteData>>[
    TypedRelativeGoRoute<InnerRelativeRoute>(path: 'inner-relative-route')
  ],
);

@TypedGoRoute<Route1>(
  path: 'route-1',
  routes: <TypedRoute<RouteData>>[relativeRoute],
)
class Route1 extends GoRouteData with _$Route1 {
  const Route1();
}

@TypedGoRoute<Route2>(
  path: 'route-2',
  routes: <TypedRoute<RouteData>>[relativeRoute],
)
class Route2 extends GoRouteData with _$Route2 {
  const Route2();
}

class RelativeRoute extends RelativeGoRouteData with _$RelativeRoute {
  const RelativeRoute();
}

class InnerRelativeRoute extends RelativeGoRouteData with _$InnerRelativeRoute {
  const InnerRelativeRoute();
}
