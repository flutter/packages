// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

mixin HasInheritedOnExit on GoRouteData {
  @override
  FutureOr<bool> onExit(BuildContext context, GoRouterState state) => true;
}

mixin $HasInheritedOnExitRoute {}

@TypedGoRoute<HasInheritedOnExitRoute>(path: '/has-inherited-on-exit-route')
class HasInheritedOnExitRoute extends GoRouteData
    with $HasInheritedOnExitRoute, HasInheritedOnExit {}
