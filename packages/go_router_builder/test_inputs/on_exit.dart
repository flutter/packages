// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

mixin $HomeRoute {}
mixin $ConfirmExitRoute {}

@TypedGoRoute<HomeRoute>(
  path: '/',
  routes: <TypedGoRoute<GoRouteData>>[TypedGoRoute<ConfirmExitRoute>(path: 'confirm-exit')],
)
class HomeRoute extends GoRouteData with $HomeRoute {
  const HomeRoute();
}

class ConfirmExitRoute extends GoRouteData with $ConfirmExitRoute {
  const ConfirmExitRoute();

  @override
  Future<bool> onExit(BuildContext context, GoRouterState state) async => false;
}
