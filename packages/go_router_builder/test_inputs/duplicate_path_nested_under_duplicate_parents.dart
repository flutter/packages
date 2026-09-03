// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// Two declarations of one parent are sound on their own, but their children
// share a URL namespace, so a child path repeated across them is a collision.

import 'package:go_router/go_router.dart';

mixin $HomeRoute {}
mixin $DetailsRoute {}
mixin $FirstSubRoute {}
mixin $SecondSubRoute {}

@TypedGoRoute<HomeRoute>(
  path: '/home',
  routes: <TypedGoRoute<GoRouteData>>[
    TypedGoRoute<DetailsRoute>(
      path: 'details',
      routes: <TypedGoRoute<GoRouteData>>[TypedGoRoute<FirstSubRoute>(path: 'sub')],
    ),
    TypedGoRoute<DetailsRoute>(
      path: 'details',
      routes: <TypedGoRoute<GoRouteData>>[TypedGoRoute<SecondSubRoute>(path: 'sub')],
    ),
  ],
)
class HomeRoute extends GoRouteData with $HomeRoute {}

class DetailsRoute extends GoRouteData with $DetailsRoute {}

class FirstSubRoute extends GoRouteData with $FirstSubRoute {}

class SecondSubRoute extends GoRouteData with $SecondSubRoute {}
