// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:go_router/go_router.dart';

@TypedShellRoute<ShellRouteWithoutUnnamedConstructor>(
  routes: <TypedRoute<RouteData>>[],
)
class ShellRouteWithoutUnnamedConstructor extends ShellRouteData {
  const ShellRouteWithoutUnnamedConstructor.namedConstructor();
}
