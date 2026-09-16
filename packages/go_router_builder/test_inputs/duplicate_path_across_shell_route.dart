// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// A shell route owns no path, so a route inside one competes with a route
// declared beside the shell.

import 'package:go_router/go_router.dart';

mixin $InsideShellRoute {}
mixin $OutsideShellRoute {}

@TypedShellRoute<AppShellRouteData>(
  routes: <TypedRoute<RouteData>>[TypedGoRoute<InsideShellRoute>(path: '/settings')],
)
class AppShellRouteData extends ShellRouteData {
  const AppShellRouteData();
}

@TypedGoRoute<OutsideShellRoute>(path: '/settings')
class OutsideShellRoute extends GoRouteData with $OutsideShellRoute {}

class InsideShellRoute extends GoRouteData with $InsideShellRoute {}
