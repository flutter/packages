// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:go_router/go_router.dart';

mixin $HomeRoute {}
mixin $FirstRoute {}
mixin $SecondRoute {}

@TypedGoRoute<HomeRoute>(
  path: '/home',
  routes: <TypedRoute<RouteData>>[
    TypedRelativeGoRoute<FirstRoute>(path: 'details'),
    TypedRelativeGoRoute<SecondRoute>(path: 'details'),
  ],
)
class HomeRoute extends GoRouteData with $HomeRoute {}

class FirstRoute extends RelativeGoRouteData with $FirstRoute {}

class SecondRoute extends RelativeGoRouteData with $SecondRoute {}
