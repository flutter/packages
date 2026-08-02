// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// A relative route owns its own URL namespace, so `/home/details/edit` and
// `/home/edit` are distinct and must not be reported as duplicates.

import 'package:go_router/go_router.dart';

mixin $HomeRoute {}
mixin $DetailsRoute {}
mixin $NestedEditRoute {}
mixin $SiblingEditRoute {}

@TypedGoRoute<HomeRoute>(
  path: '/home',
  routes: <TypedRoute<RouteData>>[
    TypedRelativeGoRoute<DetailsRoute>(
      path: 'details',
      routes: <TypedRoute<RouteData>>[
        TypedRelativeGoRoute<NestedEditRoute>(path: 'edit'),
      ],
    ),
    TypedGoRoute<SiblingEditRoute>(path: 'edit'),
  ],
)
class HomeRoute extends GoRouteData with $HomeRoute {}

class DetailsRoute extends RelativeGoRouteData with $DetailsRoute {}

class NestedEditRoute extends RelativeGoRouteData with $NestedEditRoute {}

class SiblingEditRoute extends GoRouteData with $SiblingEditRoute {}
