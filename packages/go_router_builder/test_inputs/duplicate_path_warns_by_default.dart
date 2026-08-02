// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:go_router/go_router.dart';

mixin $HomeRoute {}
mixin $FirstRoute {}
mixin $SecondRoute {}

@TypedGoRoute<HomeRoute>(
  path: '/home',
  routes: <TypedGoRoute<GoRouteData>>[
    TypedGoRoute<FirstRoute>(path: 'details'),
    TypedGoRoute<SecondRoute>(path: 'details'),
  ],
)
class HomeRoute extends GoRouteData with $HomeRoute {}

class FirstRoute extends GoRouteData with $FirstRoute {}

class SecondRoute extends GoRouteData with $SecondRoute {}
