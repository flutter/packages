// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

mixin $RedirectWithOnExitRoute {}

class RedirectBase extends GoRouteData {
  @override
  String? redirect(BuildContext context, GoRouterState state) => null;

  @override
  bool onExit(BuildContext context, GoRouterState state) => true;
}

@TypedGoRoute<RedirectWithOnExitRoute>(path: '/redirect')
class RedirectWithOnExitRoute extends RedirectBase with $RedirectWithOnExitRoute {}
