// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:go_router/go_router.dart';

mixin $HomeRoute {}
mixin $SettingsRoute {}
mixin $DuplicateRoute {}

@TypedGoRoute<HomeRoute>(
  path: '/home',
  routes: <TypedGoRoute<GoRouteData>>[
    TypedGoRoute<SettingsRoute>(path: 'details/:id'),
    TypedGoRoute<DuplicateRoute>(path: 'details/:id'),
  ],
)
class HomeRoute extends GoRouteData with $HomeRoute {}

class SettingsRoute extends GoRouteData with $SettingsRoute {
  const SettingsRoute({required this.id});
  final String id;
}

class DuplicateRoute extends GoRouteData with $DuplicateRoute {
  const DuplicateRoute({required this.id});
  final String id;
}
