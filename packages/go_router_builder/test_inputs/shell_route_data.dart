// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:go_router/go_router.dart';

@TypedShellRoute<ShellRouteNoConstConstructor>(
  routes: <TypedRoute<RouteData>>[],
)
class ShellRouteNoConstConstructor extends ShellRouteData {}

@TypedShellRoute<ShellRouteWithConstConstructor>(
  routes: <TypedRoute<RouteData>>[],
)
class ShellRouteWithConstConstructor extends ShellRouteData {
  const ShellRouteWithConstConstructor();
}

@TypedShellRoute<ShellRouteWithRestorationScopeId>(
  routes: <TypedRoute<RouteData>>[],
)
class ShellRouteWithRestorationScopeId extends ShellRouteData {
  const ShellRouteWithRestorationScopeId();

  static const String $restorationScopeId = 'shellRouteWithRestorationScopeId';
}
