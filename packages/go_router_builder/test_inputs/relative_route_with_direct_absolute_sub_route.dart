// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:go_router/go_router.dart';

mixin _$HomeRoute {}
mixin _$RelativeRoute {}
mixin _$NonRelativeRoute {}

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
  routes: <TypedRoute<RouteData>>[
    TypedGoRoute<NonRelativeRoute>(path: 'non-relative-route'),
  ],
);

class RelativeRoute extends RelativeGoRouteData with _$RelativeRoute {
  const RelativeRoute();
}

class NonRelativeRoute extends GoRouteData with _$NonRelativeRoute {
  const NonRelativeRoute();
}
