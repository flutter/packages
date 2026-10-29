// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

abstract class OnExitBaseRoute extends RelativeGoRouteData {
  @override
  FutureOr<bool> onExit(BuildContext context, GoRouterState state) => true;
}

mixin $HasRelativeInheritedOnExitRoute {}

@TypedRelativeGoRoute<HasRelativeInheritedOnExitRoute>(path: 'has-relative-inherited-on-exit-route')
class HasRelativeInheritedOnExitRoute extends OnExitBaseRoute
    with $HasRelativeInheritedOnExitRoute {}
