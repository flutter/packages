// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

mixin $HasOverriddenOnExitRoute {}
mixin $HasNotOverriddenOnExitRoute {}

@TypedGoRoute<HasOverriddenOnExitRoute>(path: '/has-overridden-on-exit-route')
class HasOverriddenOnExitRoute extends GoRouteData
    with $HasOverriddenOnExitRoute {
  @override
  FutureOr<bool> onExit(BuildContext context, GoRouterState state) {
    return true;
  }
}

@TypedGoRoute<HasNotOverriddenOnExitRoute>(path: '/has-not-overridden-on-exit-route')
class HasNotOverriddenOnExitRoute extends GoRouteData
    with $HasNotOverriddenOnExitRoute {}
