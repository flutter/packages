// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

mixin $OnEnterRoute {}

@TypedGoRoute<OnEnterRoute>(path: '/on-enter')
class OnEnterRoute extends GoRouteData with $OnEnterRoute {
  const OnEnterRoute();

  @override
  FutureOr<OnEnterResult> onEnter(
    BuildContext context,
    GoRouterState current,
    GoRouterState next,
    GoRouter router,
  ) {
    // Example navigation guard
    if (someCondition) {
      return const Block.stop();
    }
    return const Allow();
  }

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const Placeholder();
  }
}

const bool someCondition = false;
