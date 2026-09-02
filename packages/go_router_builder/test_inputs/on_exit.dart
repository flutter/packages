// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

mixin $HomeRoute {}
mixin $ConfirmExitRoute {}
mixin $InheritedExitRoute {}
mixin $RelativeExitRoute {}

@TypedGoRoute<HomeRoute>(
  path: '/',
  routes: <TypedRoute<RouteData>>[
    TypedGoRoute<ConfirmExitRoute>(path: 'confirm-exit'),
    TypedGoRoute<InheritedExitRoute>(path: 'inherited-exit'),
    TypedRelativeGoRoute<RelativeExitRoute>(path: 'relative-exit'),
  ],
)
class HomeRoute extends GoRouteData with $HomeRoute {
  const HomeRoute();
}

class ConfirmExitRoute extends GoRouteData with $ConfirmExitRoute {
  const ConfirmExitRoute();

  @override
  bool onExit(BuildContext context, GoRouterState state) => false;
}

abstract class BaseExitRoute extends GoRouteData {
  const BaseExitRoute();

  @override
  bool onExit(BuildContext context, GoRouterState state) => false;
}

class InheritedExitRoute extends BaseExitRoute with $InheritedExitRoute {
  const InheritedExitRoute();
}

class RelativeExitRoute extends RelativeGoRouteData with $RelativeExitRoute {
  const RelativeExitRoute();

  @override
  bool onExit(BuildContext context, GoRouterState state) => false;
}
